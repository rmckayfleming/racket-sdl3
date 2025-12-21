#lang racket/base

;; SDL3 Audio example - WAV playback with keyboard control
;; - Press SPACE to play a sound
;; - Press P to pause/resume audio
;; - Press Escape or close window to quit
;;
;; This example demonstrates:
;; - Opening an audio device
;; - Loading WAV files
;; - Creating and binding audio streams
;; - Playing sounds on keypress

(require racket/match
         sdl3)

(define window-width 640)
(define window-height 480)

(define (main)
  ;; Initialize SDL with video and audio
  (sdl-init! (bitwise-ior SDL_INIT_VIDEO SDL_INIT_AUDIO))

  ;; Create window and renderer
  (define-values (window renderer)
    (make-window+renderer "SDL3 Audio - SPACE=play, P=pause, ESC=quit"
                          window-width window-height))

  ;; List available audio devices
  (printf "Available audio devices:\n")
  (for ([dev (audio-playback-devices)])
    (printf "  ~a: ~a\n" (car dev) (cdr dev)))

  ;; Open default audio device
  (define device (open-audio-device))
  (printf "Opened audio device: ~a\n" device)

  ;; Load WAV file
  (define wav-path "examples/assets/sound.wav")
  (define-values (wav-spec wav-data wav-length)
    (load-wav wav-path))
  (printf "Loaded WAV: ~a Hz, ~a channels, ~a bytes\n"
          (audio-spec-freq wav-spec)
          (audio-spec-channels wav-spec)
          wav-length)

  ;; Create audio stream matching the WAV format
  (define stream (make-audio-stream wav-spec))

  ;; Bind stream to device
  (bind-audio-stream! device stream)
  (printf "Audio stream bound to device\n")

  ;; Resume the device (starts paused)
  (resume-audio-device! device)

  ;; Track pause state
  (define paused? #f)

  ;; Main loop
  (let loop ([running? #t])
    (when running?
      ;; Process all pending events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            ;; Quit events
            [(or (quit-event) (window-event 'close-requested))
             #f]

            ;; Key down events
            [(key-event 'down 'escape _ _ _) #f]

            [(key-event 'down 'space _ _ _)
             (printf "Playing sound...\n")
             (play-audio! stream wav-data wav-length)
             run?]

            [(key-event 'down 'p _ _ _)
             (if paused?
                 (begin
                   (resume-audio-device! device)
                   (set! paused? #f)
                   (printf "Audio resumed\n"))
                 (begin
                   (pause-audio-device! device)
                   (set! paused? #t)
                   (printf "Audio paused\n")))
             run?]

            ;; Ignore other events
            [_ run?])))

      ;; Render
      (when still-running?
        ;; Draw background - green when playing, gray when paused
        (if paused?
            (set-draw-color! renderer 64 64 64)
            (set-draw-color! renderer 32 96 32))
        (render-clear! renderer)
        (render-present! renderer)

        ;; Small delay
        (delay! 16)

        (loop still-running?))))

  ;; Cleanup
  (printf "Cleaning up...\n")
  (unbind-audio-stream! stream)
  (destroy-audio-stream! stream)
  (close-audio-device! device)
  (free-audio-data! wav-data)
  (renderer-destroy! renderer)
  (window-destroy! window)
  (printf "Done!\n"))

;; Run when executed directly
(module+ main
  (main))
