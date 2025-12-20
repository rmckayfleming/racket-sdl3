#lang racket/base

;; Image IOStream Demo
;;
;; Demonstrates loading textures from bytes/ports and detecting formats.

(require racket/match
         racket/file
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Image IOStream Demo")

(define image-path "examples/assets/test.png")

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Detect format from bytes
  (define image-bytes (file->bytes image-path))
  (define fmt (image-format image-bytes))

  ;; Load texture from a port
  (define in (open-input-file image-path #:mode 'binary))
  (define tex (load-texture renderer in))
  (close-input-port in)

  (define-values (tex-w tex-h) (texture-size tex))
  (define tex-x (/ (- window-width tex-w) 2.0))
  (define tex-y (/ (- window-height tex-h) 2.0))

  (let loop ([running? #t])
    (when running?
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down key _ _ _) (if (= key SDLK_ESCAPE) #f run?)]
            [_ run?])))

      (when still-running?
        (set-draw-color! renderer 20 25 35)
        (render-clear! renderer)

        (render-texture! renderer tex tex-x tex-y
                         #:width tex-w
                         #:height tex-h)
        (set-draw-color! renderer 240 240 240)
        (render-debug-text! renderer 20 20 (format "format: ~a" (or fmt 'unknown)))
        (render-debug-text! renderer 20 40 "Loaded from input port; press ESC to quit.")

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))

  (texture-destroy! tex)
  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
