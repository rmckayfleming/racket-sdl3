#lang racket/base

;; Idiomatic audio helpers for SDL3
;;
;; SDL3 audio uses a stream-based model:
;; 1. Open an audio device
;; 2. Create audio streams
;; 3. Bind streams to the device
;; 4. Push audio data into streams
;; 5. SDL automatically mixes and plays

(require ffi/unsafe
         racket/port
         "../raw.rkt")

(provide
 ;; Device management
 open-audio-device       ; open default or specific device
 close-audio-device!     ; close a device
 pause-audio-device!     ; pause playback
 resume-audio-device!    ; resume playback
 audio-device-paused?    ; check if paused
 audio-device-format     ; query device format
 audio-device-gain       ; get device gain
 set-audio-device-gain!  ; set device gain

 ;; Device enumeration
 audio-playback-devices  ; list available playback devices
 audio-recording-devices ; list available recording devices
 audio-device-name       ; get device name

 ;; Stream management
 make-audio-stream       ; create a stream
 open-audio-device-stream ; open device and stream in one call
 destroy-audio-stream!   ; destroy a stream
 audio-stream-device     ; get device associated with stream
 pause-audio-stream-device!
 resume-audio-stream-device!
 audio-stream-device-paused?
 bind-audio-stream!      ; bind stream to device
 unbind-audio-stream!    ; unbind stream from device

 ;; Stream operations
 audio-stream-put!       ; add audio data
 audio-stream-available  ; bytes available
 audio-stream-clear!     ; clear buffered data
 audio-stream-flush!     ; flush pending data

 ;; WAV loading
 load-wav                ; load WAV file, returns (values spec data length)
 free-audio-data!        ; free loaded audio data

 ;; Mixing/Conversion
 mix-audio!              ; mix src into dst buffer
 convert-audio-samples   ; convert samples between formats
 audio-format-name       ; format name string

 ;; Audio spec helpers
 make-audio-spec         ; create spec (format channels freq)
 audio-spec-format       ; get format
 audio-spec-channels     ; get channels
 audio-spec-freq         ; get sample rate

 ;; Convenience
 play-audio!             ; one-shot: put data into stream

 ;; Constants re-exported for convenience
 SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK
 SDL_AUDIO_DEVICE_DEFAULT_RECORDING
 SDL_AUDIO_S16
 SDL_AUDIO_S32
 SDL_AUDIO_F32
 SDL_AUDIO_U8
 SDL_AUDIO_S8)

;; =========================================================================
;; Audio Spec Helpers
;; =========================================================================

;; Create an audio spec with format, channels, and sample rate
;; format: SDL_AUDIO_S16, SDL_AUDIO_F32, etc.
;; channels: 1 for mono, 2 for stereo
;; freq: sample rate in Hz (e.g., 44100, 48000)
(define (make-audio-spec format channels freq)
  (make-SDL_AudioSpec format 0 channels freq))

;; Get format from audio spec
(define (audio-spec-format spec)
  (SDL_AudioSpec-format spec))

;; Get channel count from audio spec
(define (audio-spec-channels spec)
  (SDL_AudioSpec-channels spec))

;; Get sample rate from audio spec
(define (audio-spec-freq spec)
  (SDL_AudioSpec-freq spec))

;; =========================================================================
;; Device Enumeration
;; =========================================================================

;; Get a list of available playback devices
;; Returns: list of (cons device-id device-name)
(define (audio-playback-devices)
  (define-values (ptr count) (SDL-GetAudioPlaybackDevices))
  (if (and ptr (> count 0))
      (begin0
        (for/list ([i (in-range count)])
          (define dev-id (ptr-ref ptr _uint32 i))
          (cons dev-id (SDL-GetAudioDeviceName dev-id)))
        (SDL-free ptr))
      '()))

;; Get a list of available recording devices
;; Returns: list of (cons device-id device-name)
(define (audio-recording-devices)
  (define-values (ptr count) (SDL-GetAudioRecordingDevices))
  (if (and ptr (> count 0))
      (begin0
        (for/list ([i (in-range count)])
          (define dev-id (ptr-ref ptr _uint32 i))
          (cons dev-id (SDL-GetAudioDeviceName dev-id)))
        (SDL-free ptr))
      '()))

;; Get the name of an audio device
(define (audio-device-name device-id)
  (SDL-GetAudioDeviceName device-id))

;; =========================================================================
;; Device Management
;; =========================================================================

;; Open an audio device
;; device-id: #f for default playback, or specific device ID
;; spec: #f for system default, or audio spec
;; Returns: device ID on success, raises error on failure
(define (open-audio-device [device-id #f] [spec #f])
  (define dev-id (or device-id SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK))
  (define result (SDL-OpenAudioDevice dev-id spec))
  (when (= result 0)
    (error 'open-audio-device "Failed to open audio device: ~a" (SDL-GetError)))
  result)

;; Close an audio device
(define (close-audio-device! device)
  (SDL-CloseAudioDevice device))

;; Pause audio playback on a device
(define (pause-audio-device! device)
  (unless (SDL-PauseAudioDevice device)
    (error 'pause-audio-device! "Failed to pause device: ~a" (SDL-GetError))))

;; Resume audio playback on a device
(define (resume-audio-device! device)
  (unless (SDL-ResumeAudioDevice device)
    (error 'resume-audio-device! "Failed to resume device: ~a" (SDL-GetError))))

;; Check if a device is paused
(define (audio-device-paused? device)
  (SDL-AudioDevicePaused device))

;; Get the audio format and buffer size for a device
;; Returns: (values spec sample-frames)
(define (audio-device-format [device-id SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK])
  (define spec (make-SDL_AudioSpec 0 0 0 0))
  (define-values (success frames) (SDL-GetAudioDeviceFormat device-id spec))
  (unless success
    (error 'audio-device-format "Failed to get device format: ~a" (SDL-GetError)))
  (values spec frames))

;; Get the current device gain
(define (audio-device-gain device-id)
  (SDL-GetAudioDeviceGain device-id))

;; Set the current device gain
(define (set-audio-device-gain! device-id gain)
  (unless (SDL-SetAudioDeviceGain device-id (exact->inexact gain))
    (error 'set-audio-device-gain! "Failed to set device gain: ~a" (SDL-GetError))))

;; =========================================================================
;; Stream Management
;; =========================================================================

;; Keep audio stream callbacks reachable to avoid GC while active.
(define active-audio-stream-callbacks (make-hasheq))

(define (register-audio-stream-callback! stream cb)
  (hash-set! active-audio-stream-callbacks stream cb))

(define (unregister-audio-stream-callback! stream)
  (hash-remove! active-audio-stream-callbacks stream))

(define (make-audio-stream-callback who proc userdata)
  (cond
    [(procedure-arity-includes? proc 4)
     (lambda (_userdata stream additional total)
       (proc userdata stream additional total))]
    [(procedure-arity-includes? proc 3)
     (lambda (_userdata stream additional total)
       (proc stream additional total))]
    [(procedure-arity-includes? proc 2)
     (lambda (_userdata _stream additional total)
       (proc additional total))]
    [else
     (error who "callback must accept 2, 3, or 4 arguments, got: ~a"
            (procedure-arity proc))]))

;; Create an audio stream
;; src-spec: source audio format
;; dst-spec: destination format (#f to use src-spec)
;; Returns: audio stream, raises error on failure
(define (make-audio-stream src-spec [dst-spec #f])
  (define stream (SDL-CreateAudioStream src-spec (or dst-spec src-spec)))
  (unless stream
    (error 'make-audio-stream "Failed to create audio stream: ~a" (SDL-GetError)))
  stream)

;; Open a device and create/bind a stream in one call
;; callback can accept (userdata stream additional total), (stream additional total),
;; or (additional total). The device starts paused; call resume-audio-stream-device!
(define (open-audio-device-stream [device-id SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK]
                                  [spec #f]
                                  #:callback [callback #f]
                                  #:userdata [userdata #f])
  (define cb (and callback (make-audio-stream-callback 'open-audio-device-stream
                                                      callback
                                                      userdata)))
  (define stream (SDL-OpenAudioDeviceStream device-id spec cb #f))
  (unless stream
    (error 'open-audio-device-stream "Failed to open audio device stream: ~a"
           (SDL-GetError)))
  (when cb
    (register-audio-stream-callback! stream cb))
  stream)

;; Destroy an audio stream
(define (destroy-audio-stream! stream)
  (unregister-audio-stream-callback! stream)
  (SDL-DestroyAudioStream stream))

;; Get the device associated with a stream
(define (audio-stream-device stream)
  (SDL-GetAudioStreamDevice stream))

;; Pause the device associated with a stream
(define (pause-audio-stream-device! stream)
  (unless (SDL-PauseAudioStreamDevice stream)
    (error 'pause-audio-stream-device! "Failed to pause stream device: ~a"
           (SDL-GetError))))

;; Resume the device associated with a stream
(define (resume-audio-stream-device! stream)
  (unless (SDL-ResumeAudioStreamDevice stream)
    (error 'resume-audio-stream-device! "Failed to resume stream device: ~a"
           (SDL-GetError))))

;; Check if a stream's device is paused
(define (audio-stream-device-paused? stream)
  (SDL-AudioStreamDevicePaused stream))

;; Bind an audio stream to a device
(define (bind-audio-stream! device stream)
  (unless (SDL-BindAudioStream device stream)
    (error 'bind-audio-stream! "Failed to bind stream: ~a" (SDL-GetError))))

;; Unbind an audio stream from its device
(define (unbind-audio-stream! stream)
  (SDL-UnbindAudioStream stream))

;; =========================================================================
;; Stream Operations
;; =========================================================================

;; Put audio data into a stream
;; stream: the audio stream
;; data: pointer to audio data
;; length: number of bytes
(define (audio-stream-put! stream data length)
  (unless (SDL-PutAudioStreamData stream data length)
    (error 'audio-stream-put! "Failed to put audio data: ~a" (SDL-GetError))))

;; Get number of bytes available in stream
(define (audio-stream-available stream)
  (SDL-GetAudioStreamAvailable stream))

;; Clear all data from stream
(define (audio-stream-clear! stream)
  (unless (SDL-ClearAudioStream stream)
    (error 'audio-stream-clear! "Failed to clear stream: ~a" (SDL-GetError))))

;; Flush pending data through conversion
(define (audio-stream-flush! stream)
  (unless (SDL-FlushAudioStream stream)
    (error 'audio-stream-flush! "Failed to flush stream: ~a" (SDL-GetError))))

;; =========================================================================
;; WAV Loading
;; =========================================================================

;; Load a WAV file from a path, bytes, or input port
;; Returns: (values audio-spec audio-data audio-length)
;; Note: audio-data must be freed with free-audio-data!
(define (load-wav source)
  (define (path->wav path)
    (define spec (make-SDL_AudioSpec 0 0 0 0))
    (define-values (success data length) (SDL-LoadWAV path spec))
    (unless success
      (error 'load-wav "Failed to load WAV file '~a': ~a" path (SDL-GetError)))
    (values spec data length))

  (define (source->bytes who v)
    (cond
      [(bytes? v) v]
      [(input-port? v) (port->bytes v)]
      [else (error who "expected path, bytes, or input port, got: ~a" v)]))

  (define (call-with-const-mem who bytes proc)
    (define len (bytes-length bytes))
    (define mem (malloc (max len 1) 'raw))
    (memcpy mem bytes len)
    (dynamic-wind
      void
      (lambda () (proc mem len))
      (lambda () (free mem))))

  (define (call-with-iostream who bytes proc)
    (call-with-const-mem
     who
     bytes
     (lambda (mem len)
       (define stream (SDL-IOFromConstMem mem len))
       (unless stream
         (error who "failed to create IOStream: ~a" (SDL-GetError)))
       (dynamic-wind
         void
         (lambda () (proc stream))
         (lambda () (SDL-CloseIO stream))))))

  (cond
    [(or (string? source) (path? source))
     (define path (if (path? source) (path->string source) source))
     (path->wav path)]
    [else
     (define bytes (source->bytes 'load-wav source))
     (define spec (make-SDL_AudioSpec 0 0 0 0))
     (define-values (success data length)
       (call-with-iostream
        'load-wav
        bytes
        (lambda (stream)
          (SDL-LoadWAV_IO stream #f spec))))
     (unless success
       (error 'load-wav "Failed to load WAV data: ~a" (SDL-GetError)))
     (values spec data length)]))

;; Free audio data returned by load-wav
(define (free-audio-data! data)
  (SDL-free data))

;; =========================================================================
;; Mixing and Conversion
;; =========================================================================

;; Mix audio data from src into dst with volume adjustment
(define (mix-audio! dst src format length [volume 1.0])
  (unless (SDL-MixAudio dst src format length (exact->inexact volume))
    (error 'mix-audio! "Failed to mix audio: ~a" (SDL-GetError))))

;; Convert audio samples between formats
;; Returns: (values dst-data dst-length)
;; Note: dst-data must be freed with free-audio-data!
(define (convert-audio-samples src-spec src-data src-length dst-spec)
  (define-values (success dst-data dst-length)
    (SDL-ConvertAudioSamples src-spec src-data src-length dst-spec))
  (unless success
    (error 'convert-audio-samples "Failed to convert audio: ~a" (SDL-GetError)))
  (values dst-data dst-length))

;; Get a human-readable name for an audio format
(define (audio-format-name format)
  (SDL-GetAudioFormatName format))

;; =========================================================================
;; Convenience Functions
;; =========================================================================

;; Play audio data through a stream (convenience for one-shot sounds)
;; stream: audio stream (must already be bound to device)
;; data: pointer to audio data
;; length: number of bytes
(define (play-audio! stream data length)
  (audio-stream-put! stream data length))
