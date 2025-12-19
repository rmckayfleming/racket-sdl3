#lang racket/base

;; Texture Transforms Demo
;;
;; Demonstrates texture transformations in SDL3:
;; - Color tinting (R/G/B modulation)
;; - Alpha/transparency control
;; - Rotation
;; - Horizontal and vertical flipping
;;
;; Controls:
;;   R/G/B - Apply color tint
;;   Up/Down - Adjust alpha (fade)
;;   Left/Right - Rotate texture
;;   H - Toggle horizontal flip
;;   V - Toggle vertical flip
;;   Space - Toggle continuous rotation
;;   0 - Reset all transforms
;;   ESC - Quit

(require racket/match
         racket/format
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Texture Transforms Demo")

(define image-path "examples/assets/test.png")

;; Transform parameters
(define rotation-step 15.0)
(define rotation-speed 2.0)
(define alpha-step 15)

(define (clamp v lo hi)
  (max lo (min hi v)))

(define (flip-symbol h? v?)
  (cond
    [(and h? v?) 'both]
    [h? 'horizontal]
    [v? 'vertical]
    [else 'none]))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Load texture
  (define tex (load-texture renderer image-path))
  (define-values (tex-w tex-h) (texture-size tex))

  ;; Center texture position
  (define tex-x (/ (- window-width tex-w) 2.0))
  (define tex-y (/ (- window-height tex-h) 2.0))

  ;; Enable blending for alpha modulation
  (set-blend-mode! renderer 'blend)

  (let loop ([r 255] [g 255] [b 255] [alpha 255]
             [angle 0.0]
             [flip-h? #f] [flip-v? #f]
             [continuous? #f]
             [running? #t])
    (when running?
      ;; Handle events
      (define-values (new-r new-g new-b new-alpha new-angle
                      new-flip-h? new-flip-v? new-continuous? still-running?)
        (for/fold ([cr r] [cg g] [cb b] [ca alpha]
                   [a angle] [fh flip-h?] [fv flip-v?] [cont continuous?]
                   [run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values cr cg cb ca a fh fv cont #f)]

            [(key-event 'down key _ _ _)
             (cond
               [(= key SDLK_ESCAPE)
                (values cr cg cb ca a fh fv cont #f)]
               ;; Color modulation
               [(= key SDLK_R)
                (values 255 100 100 ca a fh fv cont run?)]
               [(= key SDLK_G)
                (values 100 255 100 ca a fh fv cont run?)]
               [(= key SDLK_B)
                (values 100 100 255 ca a fh fv cont run?)]
               ;; Alpha modulation
               [(= key SDLK_UP)
                (values cr cg cb (clamp (+ ca alpha-step) 0 255)
                        a fh fv cont run?)]
               [(= key SDLK_DOWN)
                (values cr cg cb (clamp (- ca alpha-step) 0 255)
                        a fh fv cont run?)]
               ;; Rotation
               [(= key SDLK_LEFT)
                (values cr cg cb ca (- a rotation-step) fh fv cont run?)]
               [(= key SDLK_RIGHT)
                (values cr cg cb ca (+ a rotation-step) fh fv cont run?)]
               ;; Flipping
               [(= key SDLK_H)
                (values cr cg cb ca a (not fh) fv cont run?)]
               [(= key SDLK_V)
                (values cr cg cb ca a fh (not fv) cont run?)]
               ;; Continuous rotation toggle
               [(= key SDLK_SPACE)
                (values cr cg cb ca a fh fv (not cont) run?)]
               ;; Reset all
               [(= key SDLK_0)
                (values 255 255 255 255 0.0 #f #f #f run?)]
               [else
                (values cr cg cb ca a fh fv cont run?)])]

            [_ (values cr cg cb ca a fh fv cont run?)])))

      (when still-running?
        ;; Update angle for continuous rotation
        (define updated-angle
          (if new-continuous?
              (+ new-angle rotation-speed)
              new-angle))

        ;; Apply color and alpha modulation
        (texture-set-color-mod! tex new-r new-g new-b)
        (texture-set-alpha-mod! tex new-alpha)

        ;; Clear to dark background
        (set-draw-color! renderer 40 40 40)
        (render-clear! renderer)

        ;; Draw the transformed texture (rotates around center by default)
        (render-texture! renderer tex tex-x tex-y
                         #:angle updated-angle
                         #:flip (flip-symbol new-flip-h? new-flip-v?))

        ;; Draw info text using debug text (no font needed)
        (set-draw-color! renderer 255 255 255)
        (render-debug-text! renderer 20 20 "Texture Transforms Demo")

        (set-draw-color! renderer 180 180 180)
        (render-debug-text! renderer 20 35 "R/G/B=Tint | Up/Down=Alpha | Left/Right=Rotate")
        (render-debug-text! renderer 20 50 "H/V=Flip | Space=Auto-rotate | 0=Reset")

        ;; Status info at bottom
        (set-draw-color! renderer 255 255 0)
        (render-debug-text! renderer 20 (- window-height 60)
                            (~a "Color: R=" new-r " G=" new-g " B=" new-b "  Alpha=" new-alpha))
        (render-debug-text! renderer 20 (- window-height 45)
                            (~a "Angle: " (modulo (inexact->exact (round updated-angle)) 360)
                                "  Flip: H=" (if new-flip-h? "ON" "off")
                                " V=" (if new-flip-v? "ON" "off")))
        (render-debug-text! renderer 20 (- window-height 30)
                            (~a "Auto-rotate: " (if new-continuous? "ON" "off")))

        ;; Draw color preview box
        (set-draw-color! renderer new-r new-g new-b new-alpha)
        (fill-rect! renderer (- window-width 70) 20 50 50)
        (set-draw-color! renderer 255 255 255 255)
        (draw-rect! renderer (- window-width 70) 20 50 50)

        (render-present! renderer)
        (delay! 16)

        (loop new-r new-g new-b new-alpha updated-angle
              new-flip-h? new-flip-v? new-continuous? still-running?))))

  (texture-destroy! tex)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run the example when executed directly
(module+ main
  (main))
