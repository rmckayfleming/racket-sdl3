#lang racket/base

;; Safe rectangle collision detection API

(require ffi/unsafe
         "../raw.rkt"
         "../private/types.rkt")

(provide
 ;; Rectangle creation and accessors
 make-rect
 rect-x
 rect-y
 rect-w
 rect-h
 rect->values
 make-frect
 frect-x
 frect-y
 frect-w
 frect-h
 frect->values

 ;; Collision detection
 rects-intersect?
 rect-intersection
 frects-intersect?
 frect-intersection

 ;; Rectangle utilities
 rect-union
 rect-enclosing-points
 rect-line-intersection
 frect-union
 frect-enclosing-points
 frect-line-intersection)

;; ============================================================================
;; Rectangle creation and accessors
;; ============================================================================

;; Create a rectangle (x y w h)
;; Returns an opaque rect object
(define (make-rect x y w h)
  (make-SDL_Rect (inexact->exact (truncate x))
                 (inexact->exact (truncate y))
                 (inexact->exact (truncate w))
                 (inexact->exact (truncate h))))

;; Create a floating point rectangle (x y w h)
(define (make-frect x y w h)
  (make-SDL_FRect (exact->inexact x)
                  (exact->inexact y)
                  (exact->inexact w)
                  (exact->inexact h)))

;; Accessors for rect components
(define (rect-x r) (SDL_Rect-x r))
(define (rect-y r) (SDL_Rect-y r))
(define (rect-w r) (SDL_Rect-w r))
(define (rect-h r) (SDL_Rect-h r))

;; Accessors for floating rect components
(define (frect-x r) (SDL_FRect-x r))
(define (frect-y r) (SDL_FRect-y r))
(define (frect-w r) (SDL_FRect-w r))
(define (frect-h r) (SDL_FRect-h r))

;; Destructure rect into multiple values for convenient binding
;; Example: (define-values (x y w h) (rect->values r))
(define (rect->values r)
  (values (SDL_Rect-x r) (SDL_Rect-y r) (SDL_Rect-w r) (SDL_Rect-h r)))

;; Destructure floating rect into multiple values
;; Example: (define-values (x y w h) (frect->values r))
(define (frect->values r)
  (values (SDL_FRect-x r) (SDL_FRect-y r) (SDL_FRect-w r) (SDL_FRect-h r)))

;; ============================================================================
;; Internal helpers
;; ============================================================================

(define (_->int v)
  (inexact->exact (truncate v)))

(define (_->float v)
  (exact->inexact v))

(define (_point-struct? v)
  (with-handlers ([exn:fail? (λ (_) #f)])
    (SDL_Point-x v)
    #t))

(define (_fpoint-struct? v)
  (with-handlers ([exn:fail? (λ (_) #f)])
    (SDL_FPoint-x v)
    #t))

(define (point->xy pt)
  (cond
    [(_point-struct? pt) (values (SDL_Point-x pt) (SDL_Point-y pt))]
    [(pair? pt) (values (car pt) (cadr pt))]
    [(vector? pt) (values (vector-ref pt 0) (vector-ref pt 1))]
    [else
     (error 'rect-enclosing-points
            "point must be an SDL_Point, list/cons, or vector of 2 numbers")]))

(define (fpoint->xy pt)
  (cond
    [(_fpoint-struct? pt) (values (SDL_FPoint-x pt) (SDL_FPoint-y pt))]
    [(pair? pt) (values (car pt) (cadr pt))]
    [(vector? pt) (values (vector-ref pt 0) (vector-ref pt 1))]
    [else
     (error 'frect-enclosing-points
            "point must be an SDL_FPoint, list/cons, or vector of 2 numbers")]))

(define (with-point-array points f)
  (define n (length points))
  (if (zero? n)
      #f
      (let* ([size (ctype-sizeof _SDL_Point)]
             [buf (malloc (* n size) 'atomic-interior)])
        (for ([pt (in-list points)]
              [i (in-naturals)])
          (define p (ptr-add buf (* i size)))
          (define-values (x y) (point->xy pt))
          (ptr-set! p _int 0 (_->int x))
          (ptr-set! p _int 1 (_->int y)))
        (f buf n))))

(define (with-fpoint-array points f)
  (define n (length points))
  (if (zero? n)
      #f
      (let* ([size (ctype-sizeof _SDL_FPoint)]
             [buf (malloc (* n size) 'atomic-interior)])
        (for ([pt (in-list points)]
              [i (in-naturals)])
          (define p (ptr-add buf (* i size)))
          (define-values (x y) (fpoint->xy pt))
          (ptr-set! p _float 0 (_->float x))
          (ptr-set! p _float 1 (_->float y)))
        (f buf n))))

;; ============================================================================
;; Collision detection
;; ============================================================================

;; Check if two rectangles intersect
;; Returns #t if they overlap, #f otherwise
(define (rects-intersect? a b)
  (SDL-HasRectIntersection a b))

;; Get the intersection of two rectangles
;; Returns a rect representing the overlap, or #f if they don't intersect
(define (rect-intersection a b)
  (if (SDL-HasRectIntersection a b)
      (let ([result (make-SDL_Rect 0 0 0 0)])
        (SDL-GetRectIntersection a b result)
        result)
      #f))

;; Check if two floating rectangles intersect
(define (frects-intersect? a b)
  (SDL-HasRectIntersectionFloat a b))

;; Get the intersection of two floating rectangles
;; Returns a rect representing the overlap, or #f if they don't intersect
(define (frect-intersection a b)
  (if (SDL-HasRectIntersectionFloat a b)
      (let ([result (make-SDL_FRect 0.0 0.0 0.0 0.0)])
        (SDL-GetRectIntersectionFloat a b result)
        result)
      #f))

;; ============================================================================
;; Rectangle utilities
;; ============================================================================

;; Get the union of two rectangles
(define (rect-union a b)
  (define result (make-SDL_Rect 0 0 0 0))
  (unless (SDL-GetRectUnion a b result)
    (error 'rect-union "Failed to compute rect union: ~a" (SDL-GetError)))
  result)

;; Get the union of two floating rectangles
(define (frect-union a b)
  (define result (make-SDL_FRect 0.0 0.0 0.0 0.0))
  (unless (SDL-GetRectUnionFloat a b result)
    (error 'frect-union "Failed to compute rect union: ~a" (SDL-GetError)))
  result)

;; Get the minimal rect enclosing a list of points
;; clip can be #f or an SDL_Rect to clip the points first
(define (rect-enclosing-points points [clip #f])
  (with-point-array points
    (λ (buf count)
      (define result (make-SDL_Rect 0 0 0 0))
      (define ok? (SDL-GetRectEnclosingPoints buf count clip result))
      (and ok? result))))

;; Get the minimal floating rect enclosing a list of points
;; clip can be #f or an SDL_FRect to clip the points first
(define (frect-enclosing-points points [clip #f])
  (with-fpoint-array points
    (λ (buf count)
      (define result (make-SDL_FRect 0.0 0.0 0.0 0.0))
      (define ok? (SDL-GetRectEnclosingPointsFloat buf count clip result))
      (and ok? result))))

;; Clip a line segment to a rectangle
;; Returns (values x1 y1 x2 y2) if intersection exists, #f otherwise
(define (rect-line-intersection rect x1 y1 x2 y2)
  (define-values (hit? nx1 ny1 nx2 ny2)
    (SDL-GetRectAndLineIntersection rect (_->int x1) (_->int y1) (_->int x2) (_->int y2)))
  (if hit?
      (values nx1 ny1 nx2 ny2)
      #f))

;; Clip a line segment to a floating rect
;; Returns (values x1 y1 x2 y2) if intersection exists, #f otherwise
(define (frect-line-intersection rect x1 y1 x2 y2)
  (define-values (hit? nx1 ny1 nx2 ny2)
    (SDL-GetRectAndLineIntersectionFloat rect
                                         (_->float x1) (_->float y1)
                                         (_->float x2) (_->float y2)))
  (if hit?
      (values nx1 ny1 nx2 ny2)
      #f))
