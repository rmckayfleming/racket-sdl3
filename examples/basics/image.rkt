#lang racket/base

;; Basic Image - Loading and Displaying Images
;;
;; Demonstrates loading and displaying an image file.
;; The image is centered in the window.
;;
;; Press Escape to exit.

(require racket/match
         sdl3)

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "Basic Image" 800 600))

  ;; Load an image as a texture
  ;; The load-texture function handles PNG, JPG, and other formats
  (define tex (load-texture renderer "examples/assets/test.png"))

  ;; Get image dimensions for centering
  (define-values (tex-w tex-h) (texture-size tex))

  ;; Calculate centered position
  (define x (/ (- 800 tex-w) 2))
  (define y (/ (- 600 tex-h) 2))

  (let loop ()
    (define quit?
      (for/or ([ev (in-events)])
        (match ev
          [(quit-event) #t]
          [(key-event 'down 'escape _ _ _) #t]
          [_ #f])))

    (unless quit?
      ;; Dark background
      (set-draw-color! renderer 30 30 40)
      (render-clear! renderer)

      ;; Draw the image centered
      (render-texture! renderer tex x y)

      ;; Instructions
      (set-draw-color! renderer 150 150 150)
      (render-debug-text! renderer 10 10 "Basic Image Demo")
      (render-debug-text! renderer 10 25 "Press ESC to quit")

      (render-present! renderer)
      (delay! 16)
      (loop)))

  ;; Clean up
  (texture-destroy! tex)
  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
