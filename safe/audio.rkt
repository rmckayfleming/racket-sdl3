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
         "../raw.rkt")

(provide
 ;; Device management
 open-audio-device       ; open default or specific device
 close-audio-device!     ; close a device
 pause-audio-device!     ; pause playback
 resume-audio-device!    ; resume playback
 audio-device-paused?    ; check if paused

 ;; Device enumeration
 audio-playback-devices  ; list available playback devices
 audio-recording-devices ; list available recording devices
 audio-device-name       ; get device name

 ;; Stream management
 make-audio-stream       ; create a stream
 destroy-audio-stream!   ; destroy a stream
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

 ;; Audio spec helpers
 make-audio-spec         ; create spec (format channels freq)
 audio-spec-format       ; get format
 audio-spec-channels     ; get channels
 audio-spec-freq         ; get sample rate

 ;; Convenience
 play-audio!             ; one-shot: put data into stream

 ;; Constants re-exported for convenience
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

;; =========================================================================
;; Stream Management
;; =========================================================================

;; Create an audio stream
;; src-spec: source audio format
;; dst-spec: destination format (#f to use src-spec)
;; Returns: audio stream, raises error on failure
(define (make-audio-stream src-spec [dst-spec #f])
  (define stream (SDL-CreateAudioStream src-spec (or dst-spec src-spec)))
  (unless stream
    (error 'make-audio-stream "Failed to create audio stream: ~a" (SDL-GetError)))
  stream)

;; Destroy an audio stream
(define (destroy-audio-stream! stream)
  (SDL-DestroyAudioStream stream))

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

;; Load a WAV file
;; path: file path to WAV file
;; Returns: (values audio-spec audio-data audio-length)
;; Note: audio-data must be freed with free-audio-data!
(define (load-wav path)
  (define spec (make-SDL_AudioSpec 0 0 0 0))
  (define-values (success data length) (SDL-LoadWAV path spec))
  (unless success
    (error 'load-wav "Failed to load WAV file '~a': ~a" path (SDL-GetError)))
  (values spec data length))

;; Free audio data returned by load-wav
(define (free-audio-data! data)
  (SDL-free data))

;; =========================================================================
;; Convenience Functions
;; =========================================================================

;; Play audio data through a stream (convenience for one-shot sounds)
;; stream: audio stream (must already be bound to device)
;; data: pointer to audio data
;; length: number of bytes
(define (play-audio! stream data length)
  (audio-stream-put! stream data length))
