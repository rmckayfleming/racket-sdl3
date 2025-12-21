#lang racket/base

;; SDL3 Audio Advanced Example
;;
;; Demonstrates:
;; - SDL_OpenAudioDeviceStream (stream-backed device)
;; - Audio device format + gain
;; - Audio format names
;; - Audio conversion + mixing
;;
;; Controls:
;; - SPACE: play original sound
;; - M: play mixed sound
;; - P: pause/resume audio
;; - ESC or close window: quit

(require ffi/unsafe
         racket/match
         sdl3)

(define window-width 720)
(define window-height 420)

(define (main)
  (sdl-init! (bitwise-ior SDL_INIT_VIDEO SDL_INIT_AUDIO))

  (define-values (window renderer)
    (make-window+renderer "SDL3 Audio - Advanced" window-width window-height))

  ;; Query device format (recommended default playback device).
  (define-values (device-spec sample-frames)
    (audio-device-format SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK))
  (printf "Device format: ~a Hz, ~a channels, ~a (~a), buffer ~a frames\n"
          (audio-spec-freq device-spec)
          (audio-spec-channels device-spec)
          (audio-spec-format device-spec)
          (audio-format-name (audio-spec-format device-spec))
          sample-frames)

  ;; Load WAV and convert to device format.
  (define wav-path "examples/assets/sound.wav")
  (define-values (wav-spec wav-data wav-length)
    (load-wav wav-path))
  (printf "WAV format: ~a Hz, ~a channels, ~a (~a), ~a bytes\n"
          (audio-spec-freq wav-spec)
          (audio-spec-channels wav-spec)
          (audio-spec-format wav-spec)
          (audio-format-name (audio-spec-format wav-spec))
          wav-length)

  (define-values (converted-data converted-length)
    (convert-audio-samples wav-spec wav-data wav-length device-spec))

  ;; Make a mixed copy at a lower volume for comparison.
  (define mix-buf (malloc (max converted-length 1) 'raw))
  (memcpy mix-buf converted-data converted-length)
  (mix-audio! mix-buf converted-data (audio-spec-format device-spec)
              converted-length 0.35)

  ;; Open stream-backed device and start playback.
  (define stream (open-audio-device-stream SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK
                                           device-spec))
  (define stream-device (audio-stream-device stream))
  (printf "Stream device id: ~a\n" stream-device)
  (printf "Device gain: ~a\n" (audio-device-gain stream-device))
  (with-handlers ([exn:fail? (lambda (e)
                               (printf "Gain set failed: ~a\n" (exn-message e)))])
    (set-audio-device-gain! stream-device 0.85)
    (printf "Device gain updated: ~a\n" (audio-device-gain stream-device)))

  (resume-audio-stream-device! stream)

  (define paused? #f)

  (let loop ([running? #t])
    (when running?
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down 'escape _ _ _) #f]

            [(key-event 'down 'space _ _ _)
             (play-audio! stream converted-data converted-length)
             run?]

            [(key-event 'down key _ _ _)
             (cond
               [(or (eq? key 'm) (eq? key 'n))
                (play-audio! stream mix-buf converted-length)
                run?]
               [(eq? key 'p)
                (if paused?
                    (begin
                      (resume-audio-stream-device! stream)
                      (set! paused? #f))
                    (begin
                      (pause-audio-stream-device! stream)
                      (set! paused? #t)))
                run?]
               [else run?])]
            [_ run?])))

      (when still-running?
        (if paused?
            (set-draw-color! renderer 70 70 80)
            (set-draw-color! renderer 40 90 40))
        (render-clear! renderer)
        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))

  (destroy-audio-stream! stream)
  (free-audio-data! wav-data)
  (free-audio-data! converted-data)
  (free mix-buf)
  (renderer-destroy! renderer)
  (window-destroy! window)
  (sdl-quit!))

(module+ main
  (main))
