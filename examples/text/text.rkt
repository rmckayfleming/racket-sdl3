#lang racket/base

;; SDL3_ttf example using the safe interface
;; - Static greeting, live typed text, and FPS counter
;; - Escape quits, backspace deletes
;; - Cmd/Ctrl+C copies text, Cmd/Ctrl+V pastes from clipboard

(require racket/match
         racket/format
         sdl3)

(define window-width 800)
(define window-height 600)
(define font-path "/System/Library/Fonts/Supplemental/Arial.ttf")
(define base-font-size 24.0)

(define (trim-last s)
  (if (zero? (string-length s))
      s
      (substring s 0 (sub1 (string-length s)))))

(define (main)
  (sdl-init!)

  ;; Create window and renderer (managed by custodian)
  (define-values (window renderer)
    (make-window+renderer "SDL3 TTF - Type to see text"
                          window-width window-height
                          #:window-flags 'high-pixel-density))

  ;; Scale font for high-DPI displays
  (define pixel-density (window-pixel-density window))
  (define font-size (* base-font-size pixel-density))
  (define font (open-font font-path font-size))

  ;; Enable text input events
  (start-text-input! window)

  (define static-color '(255 255 255 255))
  (define typed-color '(0 255 0 255))
  (define fps-color '(255 255 0 255))

  ;; Render once and reuse
  (define static-texture
    (render-text font "Hello from SDL3_ttf!"
                 static-color
                 #:renderer renderer))

  ;; Cache textures for typed text and FPS counter
  ;; Only recreate when the text changes
  (define typed-texture #f)
  (define typed-texture-text "")
  (define fps-texture #f)
  (define fps-texture-text "")

  (define (update-typed-texture! new-text)
    (unless (string=? new-text typed-texture-text)
      (when typed-texture (texture-destroy! typed-texture))
      (set! typed-texture (render-text font new-text typed-color #:renderer renderer))
      (set! typed-texture-text new-text)))

  (define (update-fps-texture! new-text)
    (unless (string=? new-text fps-texture-text)
      (when fps-texture (texture-destroy! fps-texture))
      (set! fps-texture (render-text font new-text fps-color #:renderer renderer))
      (set! fps-texture-text new-text)))

  (let loop ([typed-text ""] [fps-text "FPS: --"]
             [frame-count 0]
             [last-time (current-inexact-milliseconds)]
             [running? #t])
    (when running?
      ;; Process events
      (define-values (new-text still-running?)
        (for/fold ([curr-text typed-text] [run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values curr-text #f)]

            [(key-event 'down 'escape _ _ _)
             (values curr-text #f)]

            [(key-event 'down 'backspace _ _ _)
             (values (trim-last curr-text) run?)]

            ;; Cmd/Ctrl+C: copy current text
            [(key-event 'down 'c _ mod _)
             #:when (or (mod-gui? mod) (mod-ctrl? mod))
             (when (> (string-length curr-text) 0)
               (set-clipboard-text! curr-text)
               (printf "Copied: ~a~n" curr-text))
             (values curr-text run?)]

            ;; Cmd/Ctrl+V: paste from clipboard
            [(key-event 'down 'v _ mod _)
             #:when (or (mod-gui? mod) (mod-ctrl? mod))
             (define pasted (clipboard-text))
             (if pasted
                 (begin
                   (printf "Pasted: ~a~n" pasted)
                   (values (string-append curr-text pasted) run?))
                 (values curr-text run?))]

            [(text-input-event txt)
             (values (string-append curr-text txt) run?)]

            [_ (values curr-text run?)])))

      ;; Update FPS counter (~2x per second)
      (define next-frame-count (add1 frame-count))
      (define current-time (current-inexact-milliseconds))
      (define elapsed (- current-time last-time))

      (define-values (next-fps-text next-frame next-last-time)
        (if (>= elapsed 500.0)
            (let ([fps (/ (* next-frame-count 1000.0) elapsed)])
              (values (format "FPS: ~a" (~r fps #:precision 1))
                      0
                      current-time))
            (values fps-text next-frame-count last-time)))

      (when still-running?
        ;; Update cached textures only when text changes
        (update-typed-texture! new-text)
        (update-fps-texture! next-fps-text)

        ;; Clear background
        (set-draw-color! renderer 0 0 0)
        (render-clear! renderer)

        ;; Static greeting
        (when static-texture
          (render-texture! renderer static-texture 20 20))

        ;; Live typed text (from cache)
        (when typed-texture
          (render-texture! renderer typed-texture 20 80))

        ;; FPS counter (from cache)
        (when fps-texture
          (render-texture! renderer fps-texture 20 (- window-height 60)))

        (render-present! renderer)
        ;; No delay! needed - render-present! waits for vsync (~60 FPS)

        (loop new-text next-fps-text next-frame next-last-time still-running?))))

  (stop-text-input! window)

  ;; Clean up cached textures
  (when typed-texture (texture-destroy! typed-texture))
  (when fps-texture (texture-destroy! fps-texture))
  (when static-texture (texture-destroy! static-texture))

  (close-font! font)

  ;; Clean up (important for REPL usage)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
