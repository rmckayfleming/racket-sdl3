#lang racket/base

;; Rectangle utilities demo
;;
;; Shows union/intersection, enclosing points, and line clipping.

(require racket/match
         sdl3)

(define window-width 800)
(define window-height 600)

(define rect-a (make-rect 140 140 220 160))
(define rect-b (make-rect 280 220 240 180))

(define points
  '((120 90)
    (220 120)
    (360 100)
    (500 140)
    (560 220)
    (440 320)
    (260 300)))

(define line-start '(60 80))
(define line-end '(740 520))

(define (point-x pt) (car pt))
(define (point-y pt) (cadr pt))

(define (draw-rect-outline! rend rect)
  (draw-rect! rend (rect-x rect) (rect-y rect) (rect-w rect) (rect-h rect)))

(define (draw-point-box! rend x y)
  (fill-rect! rend (- x 2) (- y 2) 4 4))

(define (main)
  (with-sdl
    (with-window+renderer "SDL3 Racket - Rect Utilities" window-width window-height (window renderer)
      (let loop ([running? #t])
    (when running?
      (define still-running?
        (for/fold ([run? #t])
                  ([e (in-events)]
                   #:break (not run?))
          (match e
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down 'escape _ _ _) #f]
            [(key-event 'down _ _ _ _) run?]
            [_ run?])))

      (when still-running?
        (define union-rect (rect-union rect-a rect-b))
        (define intersection (rect-intersection rect-a rect-b))
        (define enclosing (rect-enclosing-points points))
        ;; rect-line-intersection returns (values x1 y1 x2 y2) or #f
        (define clipped-line
          (call-with-values
           (λ () (rect-line-intersection rect-a
                                         (point-x line-start) (point-y line-start)
                                         (point-x line-end) (point-y line-end)))
           (λ vals (and (car vals) vals))))

        (set-draw-color! renderer 25 25 35)
        (render-clear! renderer)

        ;; Base rectangles
        (set-draw-color! renderer 70 130 220)
        (draw-rect-outline! renderer rect-a)
        (set-draw-color! renderer 90 200 120)
        (draw-rect-outline! renderer rect-b)

        ;; Union outline
        (set-draw-color! renderer 240 160 60)
        (draw-rect-outline! renderer union-rect)

        ;; Intersection fill
        (when intersection
          (set-draw-color! renderer 230 220 90)
          (fill-rect! renderer
                      (rect-x intersection)
                      (rect-y intersection)
                      (rect-w intersection)
                      (rect-h intersection)))

        ;; Enclosing points
        (set-draw-color! renderer 200 200 200)
        (for ([pt (in-list points)])
          (draw-point-box! renderer (point-x pt) (point-y pt)))
        (when enclosing
          (set-draw-color! renderer 80 200 180)
          (draw-rect-outline! renderer enclosing))

        ;; Line and clipped segment
        (set-draw-color! renderer 140 140 150)
        (draw-line! renderer
                    (point-x line-start) (point-y line-start)
                    (point-x line-end) (point-y line-end))
        (when clipped-line
          (set-draw-color! renderer 240 90 90)
          (draw-line! renderer
                      (list-ref clipped-line 0)
                      (list-ref clipped-line 1)
                      (list-ref clipped-line 2)
                      (list-ref clipped-line 3)))

        (render-present! renderer)
        (delay! 16)
        (loop still-running?)))))))

(module+ main
  (main))
