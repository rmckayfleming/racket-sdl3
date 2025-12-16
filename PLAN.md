# Implementation Plan: Audio Support

This document outlines the plan for adding audio support to the SDL3 Racket bindings.

## Goals

Enable audio playback for games and applications, including loading WAV files, streaming audio, and basic device management.

---

## Phase 1: Audio Types & Constants

Add necessary types and constants for audio support.

### Types (`private/types.rkt`)

```racket
;; Audio device ID (uint32)
_SDL_AudioDeviceID

;; Audio format enum (SDL_AudioFormat)
_SDL_AudioFormat
SDL_AUDIO_S16      ; signed 16-bit samples
SDL_AUDIO_S32      ; signed 32-bit samples
SDL_AUDIO_F32      ; 32-bit floating point samples

;; Audio spec struct
_SDL_AudioSpec
  - format : SDL_AudioFormat
  - channels : int
  - freq : int

;; Pointer types
_SDL_AudioStream-pointer
```

### Init Flags

```racket
SDL_INIT_AUDIO  ; 0x00000010 - add to existing init flags
```

---

## Phase 2: Audio Device Management

Basic device enumeration and control.

### Raw Bindings (`raw.rkt`)

```racket
;; Drivers
SDL-GetNumAudioDrivers    ; -> int
SDL-GetAudioDriver        ; index -> string
SDL-GetCurrentAudioDriver ; -> string

;; Device enumeration
SDL-GetAudioPlaybackDevices  ; count-ptr -> device-id-array
SDL-GetAudioRecordingDevices ; count-ptr -> device-id-array
SDL-GetAudioDeviceName       ; devid -> string

;; Device control
SDL-OpenAudioDevice        ; devid spec-ptr -> device-id (0 = default device)
SDL-CloseAudioDevice       ; devid -> void
SDL-PauseAudioDevice       ; devid -> bool
SDL-ResumeAudioDevice      ; devid -> bool
SDL-AudioDevicePaused      ; devid -> bool
```

---

## Phase 3: Audio Streams

SDL3's primary audio API uses audio streams for all playback.

### Raw Bindings (`raw.rkt`)

```racket
;; Stream lifecycle
SDL-CreateAudioStream      ; src-spec dst-spec -> stream
SDL-DestroyAudioStream     ; stream -> void

;; Stream properties
SDL-GetAudioStreamFormat   ; stream src-spec-ptr dst-spec-ptr -> bool
SDL-SetAudioStreamFormat   ; stream src-spec dst-spec -> bool

;; Data operations
SDL-PutAudioStreamData     ; stream data len -> bool
SDL-GetAudioStreamData     ; stream buf len -> int (bytes read)
SDL-GetAudioStreamAvailable ; stream -> int (bytes available)
SDL-FlushAudioStream       ; stream -> bool
SDL-ClearAudioStream       ; stream -> bool

;; Binding streams to devices
SDL-BindAudioStream        ; devid stream -> bool
SDL-UnbindAudioStream      ; stream -> void
```

---

## Phase 4: WAV Loading & Convenience Functions

Load WAV files and provide simpler APIs.

### Raw Bindings (`raw.rkt`)

```racket
SDL-LoadWAV                 ; path spec-ptr buf-ptr len-ptr -> bool
SDL-OpenAudioDeviceStream   ; devid spec callback userdata -> stream (convenience)
```

### Safe Wrapper (`safe/audio.rkt`)

```racket
;; Device management
(open-audio-device)                  ; open default playback device
(open-audio-device #:device id)      ; open specific device
(close-audio-device! dev)
(pause-audio-device! dev)
(resume-audio-device! dev)
(audio-device-paused? dev)

;; WAV loading
(load-wav path)                      ; -> (values spec audio-data)

;; Stream management
(create-audio-stream src-spec dst-spec)
(destroy-audio-stream! stream)
(put-audio-stream-data! stream data)
(bind-audio-stream! device stream)
(unbind-audio-stream! stream)

;; High-level convenience
(play-wav device path)               ; load and play WAV file
```

---

## Phase 5: Example

### Example: `18-audio.rkt`

Demonstrate basic audio playback:

- Initialize SDL with audio
- Open default audio device
- Load a WAV file
- Create an audio stream and bind to device
- Play sound on keypress
- Clean shutdown

```racket
;; Pseudocode structure
(define (main)
  (SDL-Init (bitwise-ior SDL_INIT_VIDEO SDL_INIT_AUDIO))

  ;; Open audio
  (define dev (open-audio-device))
  (define-values (spec data) (load-wav "sound.wav"))

  ;; Create stream matching WAV format
  (define stream (create-audio-stream spec spec))
  (bind-audio-stream! dev stream)

  ;; Main loop
  (let loop ()
    (match (poll-event)
      [(key-down-event #:key 'space)
       (put-audio-stream-data! stream data)
       (loop)]
      [(quit-event) 'done]
      [_ (loop)]))

  ;; Cleanup
  (unbind-audio-stream! stream)
  (destroy-audio-stream! stream)
  (close-audio-device! dev)
  (SDL-Quit))
```

---

## Implementation Order

| Step | Files | Deliverable |
|------|-------|-------------|
| 1 | `private/types.rkt` | Audio types, constants, SDL_INIT_AUDIO |
| 2 | `raw.rkt` | Audio device functions |
| 3 | `raw.rkt` | Audio stream functions |
| 4 | `raw.rkt` | WAV loading |
| 5 | `safe/audio.rkt` | Idiomatic wrapper |
| 6 | `examples/18-audio.rkt` | Working example |

---

## Key SDL3 Audio Concepts

1. **Audio Streams**: SDL3 uses streams as the primary abstraction. You push data into a stream, and SDL handles format conversion and buffering.

2. **Device IDs**: `SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK` (0) opens the default playback device.

3. **Audio Spec**: Describes format (S16, F32, etc.), channels (1=mono, 2=stereo), and sample rate (44100, 48000, etc.).

4. **Push Model**: You `SDL_PutAudioStreamData` to queue audio. SDL pulls from the stream as needed.

5. **Binding**: Streams must be bound to a device to play. One device can have multiple streams (mixing).

---

## Notes

- SDL3's audio API is significantly different from SDL2
- No need for callback-based audio - push model is simpler
- SDL3 handles mixing of multiple streams automatically
- Format conversion is automatic when specs differ
- Need to clear compiled cache after modifying types.rkt

---

## Future Enhancements (not in initial scope)

- Audio recording (microphone input)
- Real-time audio generation
- Volume/gain control per stream
- Audio effects
- Music streaming for long files
