#lang racket/base

;; Texture Rotation & Flipping Demo
;;
;; Demonstrates rotating and flipping textures using SDL3.
;;
;; Controls:
;;   Left/Right arrows - Rotate sprite (15 degree steps)
;;   H - Toggle horizontal flip
;;   V - Toggle vertical flip
;;   Space - Toggle continuous rotation
;;   Mouse - Move to set rotation center (when continuous rotation is on)
;;   R - Reset rotation and flipping
;;   ESC - Quit

(require racket/match
         racket/format
         sdl3/safe)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Texture Rotation Demo")

(define font-path "/System/Library/Fonts/Supplemental/Arial.ttf")
(define base-font-size 18.0)
(define image-path "examples/assets/test.png")

;; Rotation step in degrees
(define rotation-step 15.0)
;; Continuous rotation speed (degrees per frame)
(define rotation-speed 2.0)

;; Key codes
(define SDLK_h 104)
(define SDLK_H 72)
(define SDLK_v 118)
(define SDLK_V 86)

(define (flip-symbol h? v?)
  (cond
    [(and h? v?) 'both]
    [h? 'horizontal]
    [v? 'vertical]
    [else 'none]))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags SDL_WINDOW_HIGH_PIXEL_DENSITY))

  ;; Scale font for high-DPI
  (define pixel-density (window-pixel-density window))
  (define font-size (* base-font-size pixel-density))
  (define font (open-font font-path font-size))

  ;; Load texture
  (define tex (load-texture renderer image-path))
  (define-values (tex-w tex-h) (texture-size tex))

  ;; Center texture position
  (define tex-x (/ (- window-width tex-w) 2.0))
  (define tex-y (/ (- window-height tex-h) 2.0))

  ;; Default rotation center (center of texture)
  (define default-center-x (/ tex-w 2.0))
  (define default-center-y (/ tex-h 2.0))

  (let loop ([angle 0.0]
             [flip-h? #f]
             [flip-v? #f]
             [continuous? #f]
             [center-x default-center-x]
             [center-y default-center-y]
             [mouse-x 0.0]
             [mouse-y 0.0]
             [running? #t])
    (when running?
      ;; Handle events
      (define-values (new-angle new-flip-h? new-flip-v? new-continuous?
                      new-center-x new-center-y new-mouse-x new-mouse-y still-running?)
        (for/fold ([a angle] [fh flip-h?] [fv flip-v?] [cont continuous?]
                   [cx center-x] [cy center-y] [mx mouse-x] [my mouse-y] [run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values a fh fv cont cx cy mx my #f)]

            [(key-event 'down key _ _ _)
             (cond
               [(= key SDLK_ESCAPE)
                (values a fh fv cont cx cy mx my #f)]
               ;; Left arrow - rotate counter-clockwise
               [(= key SDLK_LEFT)
                (values (- a rotation-step) fh fv cont cx cy mx my run?)]
               ;; Right arrow - rotate clockwise
               [(= key SDLK_RIGHT)
                (values (+ a rotation-step) fh fv cont cx cy mx my run?)]
               ;; H - toggle horizontal flip
               [(or (= key SDLK_h) (= key SDLK_H))
                (values a (not fh) fv cont cx cy mx my run?)]
               ;; V - toggle vertical flip
               [(or (= key SDLK_v) (= key SDLK_V))
                (values a fh (not fv) cont cx cy mx my run?)]
               ;; Space - toggle continuous rotation
               [(= key SDLK_SPACE)
                (values a fh fv (not cont) cx cy mx my run?)]
               ;; R - reset
               [(or (= key SDLK_r) (= key SDLK_R))
                (values 0.0 #f #f #f default-center-x default-center-y mx my run?)]
               [else
                (values a fh fv cont cx cy mx my run?)])]

            ;; Track mouse position for rotation center
            [(mouse-motion-event x y _ _ _)
             ;; Convert mouse position to texture-relative coordinates
             (define rel-x (- x tex-x))
             (define rel-y (- y tex-y))
             ;; Only update center if continuous rotation is on
             (if cont
                 (values a fh fv cont rel-x rel-y x y run?)
                 (values a fh fv cont cx cy x y run?))]

            [_ (values a fh fv cont cx cy mx my run?)])))

      (when still-running?
        ;; Update angle for continuous rotation
        (define updated-angle
          (if new-continuous?
              (+ new-angle rotation-speed)
              new-angle))

        ;; Clear to dark background
        (set-draw-color! renderer 40 40 40)
        (render-clear! renderer)

        ;; Draw the rotated/flipped texture
        (render-texture! renderer tex tex-x tex-y
                         #:angle updated-angle
                         #:center (cons new-center-x new-center-y)
                         #:flip (flip-symbol new-flip-h? new-flip-v?))

        ;; Draw rotation center marker when continuous mode is on
        (when new-continuous?
          (set-draw-color! renderer 255 0 0 255)
          (define marker-x (+ tex-x new-center-x))
          (define marker-y (+ tex-y new-center-y))
          (draw-line! renderer (- marker-x 10) marker-y (+ marker-x 10) marker-y)
          (draw-line! renderer marker-x (- marker-y 10) marker-x (+ marker-y 10)))

        ;; Draw info text
        (draw-text! renderer font "Texture Rotation & Flipping Demo"
                    20 20 '(255 255 255 255))

        (draw-text! renderer font "Left/Right = Rotate | H/V = Flip | Space = Auto-rotate | R = Reset"
                    20 50 '(180 180 180 255))

        ;; Show current values
        (define angle-text (format "Angle: ~a" (~r (modulo (inexact->exact (round updated-angle)) 360))))
        (define flip-text (format "Flip: H=~a V=~a" (if new-flip-h? "ON" "off") (if new-flip-v? "ON" "off")))
        (define mode-text (format "Continuous: ~a" (if new-continuous? "ON (move mouse to set center)" "off")))

        (draw-text! renderer font angle-text 20 (- window-height 100) '(255 255 0 255))
        (draw-text! renderer font flip-text 20 (- window-height 70) '(255 255 0 255))
        (draw-text! renderer font mode-text 20 (- window-height 40) '(255 255 0 255))

        (render-present! renderer)
        (delay! 16)

        (loop updated-angle new-flip-h? new-flip-v? new-continuous?
              new-center-x new-center-y new-mouse-x new-mouse-y still-running?))))

  (close-font! font))

;; Run the example
(main)
