#lang racket/base

;; Basic drawing operations for the renderer

(require ffi/unsafe
         "../raw.rkt"
         "window.rkt")

(provide
 ;; Color
 set-draw-color!

 ;; Blend modes
 set-blend-mode!
 get-blend-mode
 blend-mode->symbol
 symbol->blend-mode

 ;; Basic rendering
 render-clear!
 render-present!

 ;; Shapes
 draw-point!
 draw-points!
 draw-line!
 draw-lines!
 draw-rect!
 draw-rects!
 fill-rect!
 fill-rects!)

;; ============================================================================
;; Color
;; ============================================================================

(define (set-draw-color! rend r g b [a 255])
  (SDL-SetRenderDrawColor (renderer-ptr rend) r g b a))

;; ============================================================================
;; Blend Modes
;; ============================================================================

;; Convert a blend mode symbol to SDL constant
(define (symbol->blend-mode sym)
  (case sym
    [(none) SDL_BLENDMODE_NONE]
    [(blend alpha) SDL_BLENDMODE_BLEND]
    [(blend-premultiplied) SDL_BLENDMODE_BLEND_PREMULTIPLIED]
    [(add additive) SDL_BLENDMODE_ADD]
    [(add-premultiplied) SDL_BLENDMODE_ADD_PREMULTIPLIED]
    [(mod modulate) SDL_BLENDMODE_MOD]
    [(mul multiply) SDL_BLENDMODE_MUL]
    [else (error 'symbol->blend-mode
                 "unknown blend mode: ~a (expected one of: none, blend, add, mod, mul)"
                 sym)]))

;; Convert an SDL blend mode constant to a symbol
(define (blend-mode->symbol mode)
  (cond
    [(= mode SDL_BLENDMODE_NONE) 'none]
    [(= mode SDL_BLENDMODE_BLEND) 'blend]
    [(= mode SDL_BLENDMODE_BLEND_PREMULTIPLIED) 'blend-premultiplied]
    [(= mode SDL_BLENDMODE_ADD) 'add]
    [(= mode SDL_BLENDMODE_ADD_PREMULTIPLIED) 'add-premultiplied]
    [(= mode SDL_BLENDMODE_MOD) 'mod]
    [(= mode SDL_BLENDMODE_MUL) 'mul]
    [else 'unknown]))

;; Set the blend mode for the renderer
;; mode can be a symbol ('none, 'blend, 'add, 'mod, 'mul) or an SDL constant
(define (set-blend-mode! rend mode)
  (define blend-mode
    (if (symbol? mode)
        (symbol->blend-mode mode)
        mode))
  (SDL-SetRenderDrawBlendMode (renderer-ptr rend) blend-mode))

;; Get the current blend mode for the renderer (returns a symbol)
(define (get-blend-mode rend)
  (define-values (success mode) (SDL-GetRenderDrawBlendMode (renderer-ptr rend)))
  (if success
      (blend-mode->symbol mode)
      (error 'get-blend-mode "failed to get blend mode")))

;; ============================================================================
;; Basic Rendering
;; ============================================================================

(define (render-clear! rend)
  (SDL-RenderClear (renderer-ptr rend)))

(define (render-present! rend)
  (SDL-RenderPresent (renderer-ptr rend)))

;; =========================================================================
;; Internal helpers
;; =========================================================================

(define (_->float v)
  (exact->inexact v))

(define (_fpoint-struct? v)
  (with-handlers ([exn:fail? (λ (_) #f)])
    (SDL_FPoint-x v)
    #t))

(define (_rect-struct? v)
  (with-handlers ([exn:fail? (λ (_) #f)])
    (SDL_FRect-x v)
    #t))

(define (point->xy pt)
  (cond
    [(_fpoint-struct? pt) (values (SDL_FPoint-x pt) (SDL_FPoint-y pt))]
    [(pair? pt)
     (values (car pt) (cadr pt))]
    [(vector? pt)
     (values (vector-ref pt 0) (vector-ref pt 1))]
    [else
     (error 'draw-points!
            "point must be an SDL_FPoint, list/cons, or vector of 2 numbers")]))

(define (rect->xywh r)
  (cond
    [(_rect-struct? r)
     (values (SDL_FRect-x r) (SDL_FRect-y r) (SDL_FRect-w r) (SDL_FRect-h r))]
    [(and (pair? r) (>= (length r) 4))
     (values (list-ref r 0) (list-ref r 1) (list-ref r 2) (list-ref r 3))]
    [(and (vector? r) (>= (vector-length r) 4))
     (values (vector-ref r 0) (vector-ref r 1) (vector-ref r 2) (vector-ref r 3))]
    [else
     (error 'draw-rects!
            "rect must be an SDL_FRect, list, or vector of 4 numbers")]))

(define (with-fpoint-array points f)
  (define n (length points))
  (when (> n 0)
    (define size (ctype-sizeof _SDL_FPoint))
    (define buf (malloc (* n size) 'atomic-interior))
    (for ([pt (in-list points)]
          [i (in-naturals)])
      (define p (ptr-add buf (* i size)))
      (define-values (x y) (point->xy pt))
      (ptr-set! p _float 0 (_->float x))
      (ptr-set! p _float 1 (_->float y)))
    (f buf n)))

(define (with-frect-array rects f)
  (define n (length rects))
  (when (> n 0)
    (define size (ctype-sizeof _SDL_FRect))
    (define buf (malloc (* n size) 'atomic-interior))
    (for ([r (in-list rects)]
          [i (in-naturals)])
      (define p (ptr-add buf (* i size)))
      (define-values (x y w h) (rect->xywh r))
      (ptr-set! p _float 0 (_->float x))
      (ptr-set! p _float 1 (_->float y))
      (ptr-set! p _float 2 (_->float w))
      (ptr-set! p _float 3 (_->float h)))
    (f buf n)))

;; =========================================================================
;; Shapes
;; =========================================================================

(define (draw-point! rend x y)
  (SDL-RenderPoint (renderer-ptr rend) (_->float x) (_->float y)))

(define (draw-points! rend points)
  (with-fpoint-array points
    (λ (buf n)
      (SDL-RenderPoints (renderer-ptr rend) buf n))))

(define (draw-line! rend x1 y1 x2 y2)
  (SDL-RenderLine (renderer-ptr rend)
                  (_->float x1) (_->float y1)
                  (_->float x2) (_->float y2)))

(define (draw-lines! rend points)
  (with-fpoint-array points
    (λ (buf n)
      (SDL-RenderLines (renderer-ptr rend) buf n))))

(define (draw-rect! rend x y w h)
  (define rect (make-SDL_FRect (_->float x) (_->float y) (_->float w) (_->float h)))
  (SDL-RenderRect (renderer-ptr rend) rect))

(define (draw-rects! rend rects)
  (with-frect-array rects
    (λ (buf n)
      (SDL-RenderRects (renderer-ptr rend) buf n))))

(define (fill-rect! rend x y w h)
  (define rect (make-SDL_FRect (_->float x) (_->float y) (_->float w) (_->float h)))
  (SDL-RenderFillRect (renderer-ptr rend) rect))

(define (fill-rects! rend rects)
  (with-frect-array rects
    (λ (buf n)
      (SDL-RenderFillRects (renderer-ptr rend) buf n))))
