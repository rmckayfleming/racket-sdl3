#lang racket/base

;; SDL_ttf advanced text object demo
;;
;; Demonstrates:
;; - open-font-io (loading from bytes)
;; - open-font-with-properties (using SDL properties)
;; - renderer text engine + text objects
;; - substring queries
;;
;; Controls:
;; - W: toggle wrap whitespace visibility
;; - ESC / close: quit

(require racket/format
         racket/match
         racket/port
         sdl3)

(define window-width 900)
(define window-height 600)
(define font-path "/System/Library/Fonts/Supplemental/Arial.ttf")

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL_ttf Advanced Text" window-width window-height
                          #:window-flags SDL_WINDOW_HIGH_PIXEL_DENSITY))

  ;; Load font from bytes using open-font-io
  (define font-bytes (call-with-input-file font-path port->bytes))
  (define font (open-font-io font-bytes 28.0))

  ;; Load a smaller font using properties
  (define props (make-properties))
  (set-property-string! props TTF_PROP_FONT_CREATE_FILENAME_STRING font-path)
  (set-property-float! props TTF_PROP_FONT_CREATE_SIZE_FLOAT 18.0)
  (define small-font (open-font-with-properties props))
  (destroy-properties! props)

  ;; Create renderer text engine with a custom atlas size
  (define engine (make-renderer-text-engine-with-properties renderer #:atlas-size 1024))

  (define text-x 40)
  (define text-y 140)
  ;; Text with multiple wrap points to make whitespace visibility effect clearer
  (define sample-text
    "Advanced SDL_ttf text objects support wrapping,     scripts,     and substring queries.     Notice the extra spaces.")

  (define text-obj (make-text font sample-text #:engine engine))
  (set-text-wrap-width! text-obj 400)  ; narrower to force more wraps
  (set-text-color-float! text-obj '(1.0 0.9 0.2 1.0))
  (update-text! text-obj)

  (define highlight (text-substring text-obj 10))
  (define wrap-visible? #f)

  (let loop ([running? #t])
    (when running?
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down 'escape _ _ _) #f]

            [(key-event 'down 'w _ _ _)
             (set! wrap-visible? (not wrap-visible?))
             (set-text-wrap-whitespace-visible! text-obj wrap-visible?)
             (update-text! text-obj)
             run?]
            [_ run?])))

      (when still-running?
        (set-draw-color! renderer 28 28 36)
        (render-clear! renderer)

        ;; Show current state
        (define status-text
          (format "SDL_ttf Advanced | W: toggle wrap whitespace (currently ~a)"
                  (if wrap-visible? "VISIBLE" "HIDDEN")))
        (draw-text! renderer small-font status-text 40 30 '(200 200 200 255))

        ;; Show text size
        (define-values (tw th) (text-object-size text-obj))
        (draw-text! renderer small-font
                    (format "Text size: ~a x ~a" tw th) 40 60 '(150 150 150 255))

        ;; Draw bounding box for text
        (set-draw-color! renderer 60 60 80 255)
        (draw-rect! renderer text-x text-y tw th)

        ;; Draw text object
        (draw-renderer-text! text-obj text-x text-y)

        ;; Highlight substring bounds
        (define rect (text-substring-info-rect highlight))
        (set-draw-color! renderer 120 220 240 255)
        (draw-rect! renderer
                    (+ text-x (list-ref rect 0))
                    (+ text-y (list-ref rect 1))
                    (list-ref rect 2)
                    (list-ref rect 3))

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))

  (text-destroy! text-obj)
  (renderer-text-engine-destroy! engine)
  (close-font! small-font)
  (close-font! font)
  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
