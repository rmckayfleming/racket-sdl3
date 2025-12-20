#lang racket/base

;; SDL3 Audio Functions
;;
;; Functions for audio playback and recording.

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide ;; Audio - Drivers
         SDL-GetNumAudioDrivers
         SDL-GetAudioDriver
         SDL-GetCurrentAudioDriver
         ;; Audio - Device Enumeration
         SDL-GetAudioPlaybackDevices
         SDL-GetAudioRecordingDevices
         SDL-GetAudioDeviceName
         ;; Audio - Device Control
         SDL-OpenAudioDevice
         SDL-CloseAudioDevice
         SDL-PauseAudioDevice
         SDL-ResumeAudioDevice
         SDL-AudioDevicePaused
         SDL-GetAudioDeviceFormat
         SDL-GetAudioDeviceGain
         SDL-SetAudioDeviceGain
         ;; Audio - Streams
         SDL-CreateAudioStream
         SDL-OpenAudioDeviceStream
         SDL-GetAudioStreamDevice
         SDL-PauseAudioStreamDevice
         SDL-ResumeAudioStreamDevice
         SDL-AudioStreamDevicePaused
         SDL-DestroyAudioStream
         SDL-GetAudioStreamFormat
         SDL-SetAudioStreamFormat
         SDL-PutAudioStreamData
         SDL-GetAudioStreamData
         SDL-GetAudioStreamAvailable
         SDL-FlushAudioStream
         SDL-ClearAudioStream
         SDL-BindAudioStream
         SDL-UnbindAudioStream
         ;; Audio - WAV Loading
         SDL-LoadWAV
         SDL-LoadWAV_IO
         ;; Audio - Mixing/Conversion
         SDL-MixAudio
         SDL-ConvertAudioSamples
         SDL-GetAudioFormatName)

;; ============================================================================
;; Audio - Drivers
;; ============================================================================

;; SDL_GetNumAudioDrivers: Get the number of built-in audio drivers
;; Returns: the number of built-in audio drivers
(define-sdl SDL-GetNumAudioDrivers
  (_fun -> _int)
  #:c-id SDL_GetNumAudioDrivers)

;; SDL_GetAudioDriver: Get the name of a built-in audio driver by index
;; index: the index of the audio driver (0 to SDL_GetNumAudioDrivers()-1)
;; Returns: the name of the audio driver, or NULL if invalid index
(define-sdl SDL-GetAudioDriver
  (_fun _int -> _string/utf-8)
  #:c-id SDL_GetAudioDriver)

;; SDL_GetCurrentAudioDriver: Get the name of the current audio driver
;; Returns: the name of the current audio driver, or NULL if not initialized
(define-sdl SDL-GetCurrentAudioDriver
  (_fun -> _string/utf-8)
  #:c-id SDL_GetCurrentAudioDriver)

;; ============================================================================
;; Audio - Device Enumeration
;; ============================================================================

;; SDL_GetAudioPlaybackDevices: Get a list of audio playback devices
;; Returns: (values device-ids count) - array pointer and count, free with SDL_free
;; The returned pointer is a 0-terminated array of SDL_AudioDeviceID values
(define-sdl SDL-GetAudioPlaybackDevices
  (_fun (count : (_ptr o _int))
        -> (result : _pointer)
        -> (values result count))
  #:c-id SDL_GetAudioPlaybackDevices)

;; SDL_GetAudioRecordingDevices: Get a list of audio recording devices
;; Returns: (values device-ids count) - array pointer and count, free with SDL_free
;; The returned pointer is a 0-terminated array of SDL_AudioDeviceID values
(define-sdl SDL-GetAudioRecordingDevices
  (_fun (count : (_ptr o _int))
        -> (result : _pointer)
        -> (values result count))
  #:c-id SDL_GetAudioRecordingDevices)

;; SDL_GetAudioDeviceName: Get the human-readable name of an audio device
;; devid: the device instance ID to query
;; Returns: the name of the audio device, or NULL on failure
(define-sdl SDL-GetAudioDeviceName
  (_fun _SDL_AudioDeviceID -> _string/utf-8)
  #:c-id SDL_GetAudioDeviceName)

;; ============================================================================
;; Audio - Device Control
;; ============================================================================

;; SDL_OpenAudioDevice: Open an audio device for playback or recording
;; devid: device ID, or SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK/RECORDING for default
;; spec: the desired audio format (can be NULL for reasonable defaults)
;; Returns: the device ID on success, or 0 on failure
(define-sdl SDL-OpenAudioDevice
  (_fun _SDL_AudioDeviceID _SDL_AudioSpec-pointer/null -> _SDL_AudioDeviceID)
  #:c-id SDL_OpenAudioDevice)

;; SDL_CloseAudioDevice: Close a previously opened audio device
;; devid: the audio device to close
(define-sdl SDL-CloseAudioDevice
  (_fun _SDL_AudioDeviceID -> _void)
  #:c-id SDL_CloseAudioDevice)

;; SDL_PauseAudioDevice: Pause audio playback on a device
;; devid: the device to pause
;; Returns: true on success, false on failure
(define-sdl SDL-PauseAudioDevice
  (_fun _SDL_AudioDeviceID -> _sdl-bool)
  #:c-id SDL_PauseAudioDevice)

;; SDL_ResumeAudioDevice: Resume audio playback on a device
;; devid: the device to resume
;; Returns: true on success, false on failure
(define-sdl SDL-ResumeAudioDevice
  (_fun _SDL_AudioDeviceID -> _sdl-bool)
  #:c-id SDL_ResumeAudioDevice)

;; SDL_AudioDevicePaused: Check if an audio device is paused
;; devid: the device to query
;; Returns: true if the device is paused, false otherwise
(define-sdl SDL-AudioDevicePaused
  (_fun _SDL_AudioDeviceID -> _stdbool)
  #:c-id SDL_AudioDevicePaused)

;; SDL_GetAudioDeviceFormat: Get the current audio format for a device
;; devid: the device to query
;; spec: pointer to receive the audio format
;; sample_frames: pointer to receive buffer size in sample frames
;; Returns: (values success? sample_frames)
(define-sdl SDL-GetAudioDeviceFormat
  (_fun _SDL_AudioDeviceID
        _SDL_AudioSpec-pointer
        (sample_frames : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result sample_frames))
  #:c-id SDL_GetAudioDeviceFormat)

;; SDL_GetAudioDeviceGain: Get the current gain for a device
;; devid: the device to query
;; Returns: device gain (0.0 - 1.0+ depending on backend)
(define-sdl SDL-GetAudioDeviceGain
  (_fun _SDL_AudioDeviceID -> _float)
  #:c-id SDL_GetAudioDeviceGain)

;; SDL_SetAudioDeviceGain: Set the gain for a device
;; devid: the device to set
;; gain: new gain value
;; Returns: true on success, false on failure
(define-sdl SDL-SetAudioDeviceGain
  (_fun _SDL_AudioDeviceID _float -> _sdl-bool)
  #:c-id SDL_SetAudioDeviceGain)

;; ============================================================================
;; Audio - Streams
;; ============================================================================

;; SDL_CreateAudioStream: Create an audio stream for format conversion
;; src-spec: the format of the source audio
;; dst-spec: the format of the desired output audio
;; Returns: a new audio stream, or NULL on failure
(define-sdl SDL-CreateAudioStream
  (_fun _SDL_AudioSpec-pointer _SDL_AudioSpec-pointer -> _SDL_AudioStream-pointer/null)
  #:c-id SDL_CreateAudioStream)

;; SDL_OpenAudioDeviceStream: Open a device and create/bind a stream
;; devid: device instance ID or SDL_AUDIO_DEVICE_DEFAULT_* constant
;; spec: desired stream format (can be NULL)
;; callback: optional stream callback (can be NULL)
;; userdata: pointer passed to callback (can be NULL)
;; Returns: audio stream pointer, or NULL on failure
(define-sdl SDL-OpenAudioDeviceStream
  (_fun _SDL_AudioDeviceID
        _SDL_AudioSpec-pointer/null
        (_or-null _SDL_AudioStreamCallback)
        _pointer
        -> _SDL_AudioStream-pointer/null)
  #:c-id SDL_OpenAudioDeviceStream)

;; SDL_GetAudioStreamDevice: Get the device associated with a stream
;; stream: the audio stream to query
;; Returns: device instance ID, or 0 on failure
(define-sdl SDL-GetAudioStreamDevice
  (_fun _SDL_AudioStream-pointer -> _SDL_AudioDeviceID)
  #:c-id SDL_GetAudioStreamDevice)

;; SDL_PauseAudioStreamDevice: Pause the device associated with a stream
;; stream: the audio stream to pause
;; Returns: true on success, false on failure
(define-sdl SDL-PauseAudioStreamDevice
  (_fun _SDL_AudioStream-pointer -> _sdl-bool)
  #:c-id SDL_PauseAudioStreamDevice)

;; SDL_ResumeAudioStreamDevice: Resume the device associated with a stream
;; stream: the audio stream to resume
;; Returns: true on success, false on failure
(define-sdl SDL-ResumeAudioStreamDevice
  (_fun _SDL_AudioStream-pointer -> _sdl-bool)
  #:c-id SDL_ResumeAudioStreamDevice)

;; SDL_AudioStreamDevicePaused: Check if a stream's device is paused
;; stream: the audio stream to query
;; Returns: true if paused, false otherwise
(define-sdl SDL-AudioStreamDevicePaused
  (_fun _SDL_AudioStream-pointer -> _stdbool)
  #:c-id SDL_AudioStreamDevicePaused)

;; SDL_DestroyAudioStream: Destroy an audio stream
;; stream: the audio stream to destroy
(define-sdl SDL-DestroyAudioStream
  (_fun _SDL_AudioStream-pointer -> _void)
  #:c-id SDL_DestroyAudioStream)

;; SDL_GetAudioStreamFormat: Get the current input and output formats of an audio stream
;; stream: the audio stream to query
;; src-spec: pointer to receive input format (can be NULL)
;; dst-spec: pointer to receive output format (can be NULL)
;; Returns: true on success, false on failure
(define-sdl SDL-GetAudioStreamFormat
  (_fun _SDL_AudioStream-pointer
        _SDL_AudioSpec-pointer/null
        _SDL_AudioSpec-pointer/null
        -> _sdl-bool)
  #:c-id SDL_GetAudioStreamFormat)

;; SDL_SetAudioStreamFormat: Change the input and output formats of an audio stream
;; stream: the audio stream to modify
;; src-spec: the new input format (can be NULL to leave unchanged)
;; dst-spec: the new output format (can be NULL to leave unchanged)
;; Returns: true on success, false on failure
(define-sdl SDL-SetAudioStreamFormat
  (_fun _SDL_AudioStream-pointer
        _SDL_AudioSpec-pointer/null
        _SDL_AudioSpec-pointer/null
        -> _sdl-bool)
  #:c-id SDL_SetAudioStreamFormat)

;; SDL_PutAudioStreamData: Add data to the stream for processing
;; stream: the audio stream
;; buf: pointer to the audio data to add
;; len: the number of bytes to write
;; Returns: true on success, false on failure
(define-sdl SDL-PutAudioStreamData
  (_fun _SDL_AudioStream-pointer _pointer _int -> _sdl-bool)
  #:c-id SDL_PutAudioStreamData)

;; SDL_GetAudioStreamData: Get converted audio data from the stream
;; stream: the audio stream
;; buf: buffer to receive the converted audio data
;; len: maximum number of bytes to read
;; Returns: number of bytes read, or -1 on failure
(define-sdl SDL-GetAudioStreamData
  (_fun _SDL_AudioStream-pointer _pointer _int -> _int)
  #:c-id SDL_GetAudioStreamData)

;; SDL_GetAudioStreamAvailable: Get the number of bytes available in the stream
;; stream: the audio stream to query
;; Returns: number of converted bytes available, or -1 on failure
(define-sdl SDL-GetAudioStreamAvailable
  (_fun _SDL_AudioStream-pointer -> _int)
  #:c-id SDL_GetAudioStreamAvailable)

;; SDL_FlushAudioStream: Flush remaining data from the stream
;; Forces any pending data through the conversion process.
;; stream: the audio stream to flush
;; Returns: true on success, false on failure
(define-sdl SDL-FlushAudioStream
  (_fun _SDL_AudioStream-pointer -> _sdl-bool)
  #:c-id SDL_FlushAudioStream)

;; SDL_ClearAudioStream: Clear all data from the stream without processing
;; stream: the audio stream to clear
;; Returns: true on success, false on failure
(define-sdl SDL-ClearAudioStream
  (_fun _SDL_AudioStream-pointer -> _sdl-bool)
  #:c-id SDL_ClearAudioStream)

;; SDL_BindAudioStream: Bind an audio stream to a device for playback
;; devid: the audio device to bind to
;; stream: the audio stream to bind
;; Returns: true on success, false on failure
(define-sdl SDL-BindAudioStream
  (_fun _SDL_AudioDeviceID _SDL_AudioStream-pointer -> _sdl-bool)
  #:c-id SDL_BindAudioStream)

;; SDL_UnbindAudioStream: Unbind an audio stream from its device
;; stream: the audio stream to unbind
(define-sdl SDL-UnbindAudioStream
  (_fun _SDL_AudioStream-pointer -> _void)
  #:c-id SDL_UnbindAudioStream)

;; ============================================================================
;; Audio - WAV Loading
;; ============================================================================

;; SDL_LoadWAV: Load a WAV file from disk
;; path: the file path to load
;; spec: pointer to SDL_AudioSpec to receive the audio format
;; audio_buf: pointer to receive the audio data buffer (free with SDL_free)
;; audio_len: pointer to receive the length in bytes
;; Returns: true on success, false on failure
(define-sdl SDL-LoadWAV
  (_fun _string/utf-8
        _SDL_AudioSpec-pointer
        (audio_buf : (_ptr o _pointer))
        (audio_len : (_ptr o _uint32))
        -> (result : _sdl-bool)
        -> (values result audio_buf audio_len))
  #:c-id SDL_LoadWAV)

;; SDL_LoadWAV_IO: Load a WAV file from an IOStream
;; src: SDL_IOStream to read from
;; closeio: close the IOStream when done
;; spec: pointer to SDL_AudioSpec to receive the audio format
;; audio_buf: pointer to receive the audio data buffer (free with SDL_free)
;; audio_len: pointer to receive the length in bytes
;; Returns: true on success, false on failure
(define-sdl SDL-LoadWAV_IO
  (_fun _SDL_IOStream-pointer
        _stdbool
        _SDL_AudioSpec-pointer
        (audio_buf : (_ptr o _pointer))
        (audio_len : (_ptr o _uint32))
        -> (result : _sdl-bool)
        -> (values result audio_buf audio_len))
  #:c-id SDL_LoadWAV_IO)

;; ============================================================================
;; Audio - Mixing and Conversion
;; ============================================================================

;; SDL_MixAudio: Mix audio data into a destination buffer
;; dst: destination buffer
;; src: source buffer
;; format: SDL_AudioFormat of the buffers
;; len: number of bytes to mix
;; volume: mix volume (0.0 - 1.0)
;; Returns: true on success, false on failure
(define-sdl SDL-MixAudio
  (_fun _pointer _pointer _SDL_AudioFormat _uint32 _float -> _sdl-bool)
  #:c-id SDL_MixAudio)

;; SDL_ConvertAudioSamples: Convert audio data between formats
;; src_spec: source format
;; src_data: pointer to source data
;; src_len: length of source data
;; dst_spec: destination format
;; dst_data: receives newly allocated destination buffer (free with SDL_free)
;; dst_len: receives length of destination data
;; Returns: (values success? dst_data dst_len)
(define-sdl SDL-ConvertAudioSamples
  (_fun _SDL_AudioSpec-pointer
        _pointer
        _int
        _SDL_AudioSpec-pointer
        (dst_data : (_ptr o _pointer))
        (dst_len : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result dst_data dst_len))
  #:c-id SDL_ConvertAudioSamples)

;; SDL_GetAudioFormatName: Get a human-readable name for an audio format
;; format: SDL_AudioFormat value
;; Returns: format name string (or "SDL_AUDIO_UNKNOWN")
(define-sdl SDL-GetAudioFormatName
  (_fun _SDL_AudioFormat -> _string/utf-8)
  #:c-id SDL_GetAudioFormatName)
