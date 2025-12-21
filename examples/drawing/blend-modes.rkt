#lang racket/base

;; Blend Modes Demo - demonstrates SDL3 blend mode effects
;;
;; Controls:
;;   1 - No blending (SDL_BLENDMODE_NONE)
;;   2 - Alpha blending (SDL_BLENDMODE_BLEND) - default
;;   3 - Additive blending (SDL_BLENDMODE_ADD) - glow effects
;;   4 - Color modulate (SDL_BLENDMODE_MOD)
;;   5 - Color multiply (SDL_BLENDMODE_MUL)
;;   ESC - Quit

(require racket/match
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Blend Modes Demo")

(define font-path "/System/Library/Fonts/Supplemental/Arial.ttf")
(define base-font-size 20.0)

;; Blend mode info for display
(define blend-modes
  '((none . "1: None - No blending (opaque)")
    (blend . "2: Blend - Alpha blending (default)")
    (add . "3: Add - Additive blending (glow)")
    (mod . "4: Mod - Color modulate")
    (mul . "5: Mul - Color multiply")))

(define (mode-description mode)
  (cdr (assoc mode blend-modes)))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags SDL_WINDOW_HIGH_PIXEL_DENSITY))

  ;; Scale font for high-DPI
  (define pixel-density (window-pixel-density window))
  (define font-size (* base-font-size pixel-density))
  (define font (open-font font-path font-size))

  (let loop ([current-mode 'blend]
             [running? #t])
    (when running?
      ;; Handle events
      (define-values (new-mode still-running?)
        (for/fold ([mode current-mode] [run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values mode #f)]
            [(key-event 'down 'escape _ _ _) (values mode #f)]

            [(key-event 'down key _ _ _)
             (cond
               [(eq? key '1) (values 'none run?)]
               [(eq? key '2) (values 'blend run?)]
               [(eq? key '3) (values 'add run?)]
               [(eq? key '4) (values 'mod run?)]
               [(eq? key '5) (values 'mul run?)]
               [else (values mode run?)])]
            [_ (values mode run?)])))

      (when still-running?
        ;; Draw dark background
        (set-draw-color! renderer 30 30 30)
        (render-clear! renderer)

        ;; Set the blend mode
        (set-blend-mode! renderer new-mode)

        ;; Draw overlapping semi-transparent rectangles to demonstrate blending
        ;; First, a base white rectangle
        (set-draw-color! renderer 100 100 100 255)
        (fill-rect! renderer 100 150 200 200)

        ;; Red rectangle (semi-transparent)
        (set-draw-color! renderer 255 50 50 180)
        (fill-rect! renderer 150 100 200 200)

        ;; Green rectangle (semi-transparent)
        (set-draw-color! renderer 50 255 50 180)
        (fill-rect! renderer 250 150 200 200)

        ;; Blue rectangle (semi-transparent)
        (set-draw-color! renderer 50 50 255 180)
        (fill-rect! renderer 200 200 200 200)

        ;; Draw "glow" circles using additive blending demonstration
        ;; These show up especially well with additive blending
        (set-draw-color! renderer 255 200 50 100)
        (fill-rect! renderer 550 150 150 150)
        (set-draw-color! renderer 50 200 255 100)
        (fill-rect! renderer 600 200 150 150)
        (set-draw-color! renderer 255 50 200 100)
        (fill-rect! renderer 575 250 150 150)

        ;; Draw UI text (reset to normal blend mode for text)
        (set-blend-mode! renderer 'blend)

        ;; Title
        (draw-text! renderer font "Blend Mode Demo - Press 1-5 to change mode"
                    20 20 '(255 255 255 255))

        ;; Current mode
        (draw-text! renderer font (string-append "Current: " (mode-description new-mode))
                    20 50 '(255 255 0 255))

        ;; Instructions
        (draw-text! renderer font "Left: RGB overlap | Right: Glow effect demo"
                    20 (- window-height 40) '(180 180 180 255))

        (render-present! renderer)
        (delay! 16)

        (loop new-mode still-running?))))

  (close-font! font)

  ;; Clean up (important for REPL usage)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run the example when executed directly
(module+ main
  (main))
