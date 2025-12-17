#lang racket/base

;; Mini Paint - File Dialog Demo
;;
;; A simple drawing program demonstrating file dialogs:
;; - Open single or multiple images
;; - Draw with mouse (freehand)
;; - Transform the canvas (flip, rotate)
;; - Save your work
;;
;; Note: JPEG images with EXIF rotation metadata may appear rotated.
;; Use R/H/V keys to manually correct orientation if needed.
;;
;; Controls:
;;   O - Open file(s) - select multiple images to tile them
;;   S - Save as PNG
;;   C - Clear canvas to white
;;   H - Flip horizontal
;;   V - Flip vertical
;;   R - Rotate 90 degrees clockwise
;;   1-5 - Select color (1=Black, 2=Red, 3=Green, 4=Blue, 5=White)
;;   +/- - Adjust brush size
;;   ESC - Quit

(require racket/match
         racket/format
         sdl3/safe)

(define window-width 900)
(define window-height 700)
(define window-title "Mini Paint - Press O to open, S to save")

;; Canvas size (what we draw on)
(define canvas-width 800)
(define canvas-height 600)

;; Drawing state
(define brush-colors
  (vector (cons 0 (cons 0 0))       ; Black
          (cons 220 (cons 50 50))   ; Red
          (cons 50 (cons 180 50))   ; Green
          (cons 50 (cons 100 220))  ; Blue
          (cons 255 (cons 255 255)))) ; White (eraser)

(define image-filters '(("Image files" . "png;jpg;jpeg;gif;bmp;webp")
                        ("PNG files" . "png")
                        ("JPEG files" . "jpg;jpeg")
                        ("All files" . "*")))

(define save-filters '(("PNG files" . "png")))

;; Calculate grid layout for multiple images
(define (calculate-grid-layout count canvas-w canvas-h)
  (cond
    [(= count 0) (values 1 1)]
    [(= count 1) (values 1 1)]
    [(= count 2) (values 2 1)]
    [(<= count 4) (values 2 2)]
    [(<= count 6) (values 3 2)]
    [(<= count 9) (values 3 3)]
    [else (values 4 (ceiling (/ count 4)))]))

;; Draw images tiled onto canvas
(define (draw-images-to-canvas! renderer canvas images)
  (with-render-target renderer canvas
    ;; Clear to white
    (set-draw-color! renderer 255 255 255)
    (render-clear! renderer)

    (unless (null? images)
      (define count (length images))
      (define-values (cols rows) (calculate-grid-layout count canvas-width canvas-height))
      (define cell-w (/ canvas-width cols))
      (define cell-h (/ canvas-height rows))

      (for ([img (in-list images)]
            [i (in-naturals)])
        (define col (modulo i cols))
        (define row (quotient i cols))
        (when (< row rows)
          (define x (* col cell-w))
          (define y (* row cell-h))
          ;; Scale image to fit cell while maintaining aspect ratio
          (define-values (img-w img-h) (texture-size img))
          (define scale (min (/ cell-w img-w) (/ cell-h img-h)))
          (define scaled-w (* img-w scale))
          (define scaled-h (* img-h scale))
          ;; Center in cell
          (define dx (+ x (/ (- cell-w scaled-w) 2)))
          (define dy (+ y (/ (- cell-h scaled-h) 2)))
          (render-texture! renderer img dx dy
                           #:width scaled-w
                           #:height scaled-h))))))

;; Apply flip/rotate to canvas using a temp texture
(define (transform-canvas! renderer canvas transform)
  ;; Create temp texture to hold current canvas
  (define temp (create-texture renderer canvas-width canvas-height
                               #:access 'target))
  (set-texture-blend-mode! temp 'blend)

  ;; Copy canvas to temp
  (with-render-target renderer temp
    (set-draw-color! renderer 255 255 255)
    (render-clear! renderer)
    (render-texture! renderer canvas 0 0))

  ;; Apply transform back to canvas
  (with-render-target renderer canvas
    (set-draw-color! renderer 255 255 255)
    (render-clear! renderer)
    (case transform
      [(flip-h)
       (render-texture! renderer temp 0 0
                        #:width canvas-width
                        #:height canvas-height
                        #:flip 'horizontal)]
      [(flip-v)
       (render-texture! renderer temp 0 0
                        #:width canvas-width
                        #:height canvas-height
                        #:flip 'vertical)]
      [(rotate-cw)
       ;; Rotate 90 degrees around center. Content will be scaled to fit.
       ;; Calculate scale to fit rotated content
       (define scale (min (/ canvas-width canvas-height)
                          (/ canvas-height canvas-width)))
       (define scaled-w (* canvas-width scale))
       (define scaled-h (* canvas-height scale))
       (define cx (/ canvas-width 2))
       (define cy (/ canvas-height 2))
       (render-texture! renderer temp
                        (- cx (/ scaled-w 2))
                        (- cy (/ scaled-h 2))
                        #:width scaled-w
                        #:height scaled-h
                        #:angle 90
                        #:center (cons (/ scaled-w 2) (/ scaled-h 2)))]))

  (texture-destroy! temp))

;; Draw a brush stroke (thick line using filled circles)
(define (draw-brush! renderer x y size)
  (define half (/ size 2))
  ;; Draw a filled circle approximation
  (for* ([dy (in-range (- half) (+ half 1))]
         [dx (in-range (- half) (+ half 1))])
    (when (<= (+ (* dx dx) (* dy dy)) (* half half))
      (fill-rect! renderer (+ x dx) (+ y dy) 1 1))))

;; Draw line between two points with brush
(define (draw-line-brush! renderer x1 y1 x2 y2 size)
  (define dx (- x2 x1))
  (define dy (- y2 y1))
  (define dist (max 1 (sqrt (+ (* dx dx) (* dy dy)))))
  (define steps (max 1 (inexact->exact (ceiling dist))))
  (for ([i (in-range (+ steps 1))])
    (define t (/ i steps))
    (define x (+ x1 (* t dx)))
    (define y (+ y1 (* t dy)))
    (draw-brush! renderer x y size)))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Create canvas texture
  (define canvas (create-texture renderer canvas-width canvas-height
                                 #:access 'target
                                 #:scale 'nearest))
  (set-texture-blend-mode! canvas 'blend)

  ;; Initialize canvas to white
  (with-render-target renderer canvas
    (set-draw-color! renderer 255 255 255)
    (render-clear! renderer))

  ;; Canvas position on screen
  (define canvas-x (/ (- window-width canvas-width) 2))
  (define canvas-y 50)

  ;; Loaded image textures (for cleanup)
  (define loaded-images '())

  ;; Main loop state
  (let loop ([running? #t]
             [color-idx 0]
             [brush-size 8]
             [drawing? #f]
             [last-x #f]
             [last-y #f]
             [status-msg "Press O to open images, draw with mouse"])
    (when running?
      (define new-status status-msg)

      ;; Process events
      (define-values (still-running? new-color new-size new-drawing new-lx new-ly msg)
        (for/fold ([run? #t]
                   [col color-idx]
                   [size brush-size]
                   [draw? drawing?]
                   [lx last-x]
                   [ly last-y]
                   [msg status-msg])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values #f col size draw? lx ly msg)]

            [(key-event 'down key _ _ _)
             (cond
               [(= key SDLK_ESCAPE)
                (values #f col size draw? lx ly msg)]

               ;; Open file
               [(= key SDLK_O)
                (define files (open-file-dialog
                               #:filters image-filters
                               #:allow-multiple? #t
                               #:window (window-ptr window)))
                (raise-window! window)  ; Restore focus after dialog
                (cond
                  [(not files)
                   (values run? col size draw? lx ly "Cancelled or error")]
                  [(string? files)
                   ;; Clean up old images first
                   (for ([old-img (in-list loaded-images)])
                     (texture-destroy! old-img))
                   (set! loaded-images '())
                   ;; Single file
                   (define img (load-texture renderer files))
                   (set! loaded-images (list img))
                   (draw-images-to-canvas! renderer canvas (list img))
                   (values run? col size draw? lx ly
                           (~a "Loaded: " (file-name-from-path files)))]
                  [(list? files)
                   ;; Clean up old images first
                   (for ([old-img (in-list loaded-images)])
                     (texture-destroy! old-img))
                   (set! loaded-images '())
                   ;; Multiple files - load and tile
                   (define imgs
                     (for/list ([f (in-list files)])
                       (load-texture renderer f)))
                   (set! loaded-images imgs)
                   (draw-images-to-canvas! renderer canvas imgs)
                   (values run? col size draw? lx ly
                           (~a "Loaded " (length imgs) " images (tiled)"))]
                  [else (values run? col size draw? lx ly msg)])]

               ;; Save file
               [(= key SDLK_S)
                (define file (save-file-dialog
                              #:filters save-filters
                              #:default-path "drawing.png"
                              #:window (window-ptr window)))
                (raise-window! window)  ; Restore focus after dialog
                (cond
                  [(not file)
                   (values run? col size draw? lx ly "Save cancelled")]
                  [else
                   ;; Read canvas pixels and save
                   (with-render-target renderer canvas
                     (define surface (render-read-pixels renderer))
                     (define path (if (regexp-match? #rx"\\.png$" file)
                                      file
                                      (~a file ".png")))
                     (save-png! surface path)
                     (surface-destroy! surface)
                     (values run? col size draw? lx ly
                             (~a "Saved: " path)))])]

               ;; Clear canvas
               [(= key SDLK_C)
                (with-render-target renderer canvas
                  (set-draw-color! renderer 255 255 255)
                  (render-clear! renderer))
                (values run? col size draw? lx ly "Canvas cleared")]

               ;; Transforms
               [(= key SDLK_H)
                (transform-canvas! renderer canvas 'flip-h)
                (values run? col size draw? lx ly "Flipped horizontal")]
               [(= key SDLK_V)
                (transform-canvas! renderer canvas 'flip-v)
                (values run? col size draw? lx ly "Flipped vertical")]
               [(= key SDLK_R)
                (transform-canvas! renderer canvas 'rotate-cw)
                (values run? col size draw? lx ly "Rotated 90 degrees")]

               ;; Color selection
               [(= key SDLK_1) (values run? 0 size draw? lx ly "Color: Black")]
               [(= key SDLK_2) (values run? 1 size draw? lx ly "Color: Red")]
               [(= key SDLK_3) (values run? 2 size draw? lx ly "Color: Green")]
               [(= key SDLK_4) (values run? 3 size draw? lx ly "Color: Blue")]
               [(= key SDLK_5) (values run? 4 size draw? lx ly "Color: White (eraser)")]

               ;; Brush size
               [(or (= key SDLK_EQUALS) (= key SDLK_PLUS) (= key SDLK_KP_PLUS))
                (define new-size (min 50 (+ size 2)))
                (values run? col new-size draw? lx ly (~a "Brush size: " new-size))]
               [(or (= key SDLK_MINUS) (= key SDLK_KP_MINUS))
                (define new-size (max 2 (- size 2)))
                (values run? col new-size draw? lx ly (~a "Brush size: " new-size))]

               [else (values run? col size draw? lx ly msg)])]

            ;; Mouse button down - start drawing
            [(mouse-button-event 'down 'left x y _)
             (define cx (- x canvas-x))
             (define cy (- y canvas-y))
             (if (and (>= cx 0) (< cx canvas-width)
                      (>= cy 0) (< cy canvas-height))
                 (begin
                   ;; Draw initial point
                   (with-render-target renderer canvas
                     (define c (vector-ref brush-colors col))
                     (set-draw-color! renderer (car c) (cadr c) (cddr c))
                     (draw-brush! renderer cx cy size))
                   (values run? col size #t cx cy msg))
                 ;; Click outside canvas - don't start drawing
                 (values run? col size #f #f #f msg))]

            ;; Mouse button up - stop drawing
            [(mouse-button-event 'up 'left _ _ _)
             (values run? col size #f #f #f msg)]

            ;; Mouse motion - draw if button held
            [(mouse-motion-event x y _ _ buttons)
             (cond
               [(and draw? (positive? (bitwise-and buttons SDL_BUTTON_LMASK)))
                (define cx (- x canvas-x))
                (define cy (- y canvas-y))
                (when (and (>= cx 0) (< cx canvas-width)
                           (>= cy 0) (< cy canvas-height)
                           lx ly)
                  (with-render-target renderer canvas
                    (define c (vector-ref brush-colors col))
                    (set-draw-color! renderer (car c) (cadr c) (cddr c))
                    (draw-line-brush! renderer lx ly cx cy size)))
                (values run? col size draw? cx cy msg)]
               [else (values run? col size draw? lx ly msg)])]

            [_ (values run? col size draw? lx ly msg)])))

      (when still-running?
        ;; Clear window
        (set-draw-color! renderer 60 60 70)
        (render-clear! renderer)

        ;; Draw canvas border
        (set-draw-color! renderer 100 100 100)
        (fill-rect! renderer (- canvas-x 2) (- canvas-y 2)
                    (+ canvas-width 4) (+ canvas-height 4))

        ;; Draw canvas
        (render-texture! renderer canvas canvas-x canvas-y)

        ;; Draw UI area at bottom
        (set-draw-color! renderer 40 40 50)
        (fill-rect! renderer 0 (+ canvas-y canvas-height 10)
                    window-width 40)

        ;; Draw color palette
        (for ([i (in-range 5)])
          (define c (vector-ref brush-colors i))
          (define x (+ 20 (* i 35)))
          (define y (+ canvas-y canvas-height 15))
          ;; Selection indicator
          (when (= i new-color)
            (set-draw-color! renderer 255 255 0)
            (fill-rect! renderer (- x 3) (- y 3) 36 36))
          ;; Color swatch
          (set-draw-color! renderer (car c) (cadr c) (cddr c))
          (fill-rect! renderer x y 30 30)
          ;; Border
          (set-draw-color! renderer 200 200 200)
          (draw-rect! renderer x y 30 30))

        ;; Draw brush size indicator (shows current color and size)
        (define bs-x 210)
        (define bs-y (+ canvas-y canvas-height 15))
        (define bs-area-size 30)
        ;; Background
        (set-draw-color! renderer 80 80 90)
        (fill-rect! renderer bs-x bs-y bs-area-size bs-area-size)
        ;; Brush preview (centered, actual size, current color)
        (define preview-size (min new-size bs-area-size))
        (define c (vector-ref brush-colors new-color))
        (set-draw-color! renderer (car c) (cadr c) (cddr c))
        (define px (+ bs-x (/ (- bs-area-size preview-size) 2)))
        (define py (+ bs-y (/ (- bs-area-size preview-size) 2)))
        (fill-rect! renderer px py preview-size preview-size)
        ;; Border
        (set-draw-color! renderer 200 200 200)
        (draw-rect! renderer bs-x bs-y bs-area-size bs-area-size)

        ;; Status area - print to console
        (when (not (equal? msg new-status))
          (printf "~a\n" msg))

        (render-present! renderer)
        (delay! 16)

        (loop still-running? new-color new-size new-drawing new-lx new-ly msg))))

  ;; Clean up loaded images
  (for ([img (in-list loaded-images)])
    (texture-destroy! img))

  (texture-destroy! canvas)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Helper to extract filename from path
(define (file-name-from-path path)
  (define parts (regexp-split #rx"[/\\\\]" path))
  (if (null? parts) path (last parts)))

(define (last lst)
  (if (null? (cdr lst)) (car lst) (last (cdr lst))))

(module+ main
  (main))
