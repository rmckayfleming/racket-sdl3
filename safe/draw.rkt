#lang racket/base

;; Basic drawing operations for the renderer

(require ffi/unsafe
         "../raw.rkt"
         "window.rkt"
         "syntax.rkt")

(provide
 ;; Color
 set-draw-color!
 get-draw-color
 set-draw-color-float!
 get-draw-color-float
 color->SDL_Color

 ;; Blend modes
 set-blend-mode!
 get-blend-mode
 blend-mode->symbol
 symbol->blend-mode

 ;; Basic rendering
 render-clear!
 render-present!

 ;; Renderer info
 num-render-drivers
 render-driver-name
 renderer-name
 render-output-size
 current-render-output-size
 get-renderer
 get-render-window

 ;; VSync
 set-render-vsync!
 get-render-vsync

 ;; Viewport and Clipping
 set-render-viewport!
 get-render-viewport
 set-render-clip-rect!
 get-render-clip-rect
 render-clip-enabled?
 set-render-scale!
 get-render-scale

 ;; Shapes
 draw-point!
 draw-points!
 draw-line!
 draw-lines!
 draw-rect!
 draw-rects!
 fill-rect!
 fill-rects!

 ;; Geometry rendering
 render-geometry!
 make-vertex

 ;; Debug text
 render-debug-text!
 debug-text-font-size)

;; ============================================================================
;; Color
;; ============================================================================

(define (set-draw-color! rend r g b [a 255])
  (SDL-SetRenderDrawColor (renderer-ptr rend) r g b a))

;; Get the current draw color
;; Returns: (values r g b a)
(define (get-draw-color rend)
  (define-values (success r g b a) (SDL-GetRenderDrawColor (renderer-ptr rend)))
  (unless success
    (error 'get-draw-color "Failed to get draw color: ~a" (SDL-GetError)))
  (values r g b a))

;; Set the draw color using float values (0.0 to 1.0, can exceed for HDR)
(define (set-draw-color-float! rend r g b [a 1.0])
  (unless (SDL-SetRenderDrawColorFloat (renderer-ptr rend)
                                        (exact->inexact r)
                                        (exact->inexact g)
                                        (exact->inexact b)
                                        (exact->inexact a))
    (error 'set-draw-color-float! "Failed to set draw color: ~a" (SDL-GetError))))

;; Get the current draw color as floats
;; Returns: (values r g b a)
(define (get-draw-color-float rend)
  (define-values (success r g b a) (SDL-GetRenderDrawColorFloat (renderer-ptr rend)))
  (unless success
    (error 'get-draw-color-float "Failed to get draw color: ~a" (SDL-GetError)))
  (values r g b a))

;; Check if a value is an SDL_Color struct
(define (color-struct? v)
  (with-handlers ([exn:fail? (λ (_) #f)])
    (SDL_Color-r v)
    #t))

;; Convert various color representations to SDL_Color
;; Accepts: SDL_Color struct, list (r g b) or (r g b a), vector #(r g b) or #(r g b a)
(define (color->SDL_Color color)
  (cond
    [(color-struct? color) color]
    [(and (list? color) (>= (length color) 3))
     (make-SDL_Color (list-ref color 0)
                     (list-ref color 1)
                     (list-ref color 2)
                     (if (>= (length color) 4) (list-ref color 3) 255))]
    [(and (vector? color) (>= (vector-length color) 3))
     (make-SDL_Color (vector-ref color 0)
                     (vector-ref color 1)
                     (vector-ref color 2)
                     (if (>= (vector-length color) 4) (vector-ref color 3) 255))]
    [else
     (error 'color->SDL_Color
            "color must be an SDL_Color, list, or vector of 3 or 4 integers")]))

;; ============================================================================
;; Blend Modes
;; ============================================================================

(define-enum-conversion blend-mode
  ([none] SDL_BLENDMODE_NONE)
  ([blend alpha] SDL_BLENDMODE_BLEND)
  ([blend-premultiplied] SDL_BLENDMODE_BLEND_PREMULTIPLIED)
  ([add additive] SDL_BLENDMODE_ADD)
  ([add-premultiplied] SDL_BLENDMODE_ADD_PREMULTIPLIED)
  ([mod modulate] SDL_BLENDMODE_MOD)
  ([mul multiply] SDL_BLENDMODE_MUL))

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

;; ============================================================================
;; Renderer Info
;; ============================================================================

;; Get the number of available render drivers
(define (num-render-drivers)
  (SDL-GetNumRenderDrivers))

;; Get the name of a render driver by index
(define (render-driver-name index)
  (SDL-GetRenderDriver index))

;; Get the name of a renderer (e.g., "metal", "opengl")
(define (renderer-name rend)
  (SDL-GetRendererName (renderer-ptr rend)))

;; Get the output size of the renderer in pixels
;; Returns: (values width height)
(define (render-output-size rend)
  (define-values (success w h) (SDL-GetRenderOutputSize (renderer-ptr rend)))
  (unless success
    (error 'render-output-size "Failed to get render output size: ~a" (SDL-GetError)))
  (values w h))

;; Get the current output size (considering render target and logical size)
;; Returns: (values width height)
(define (current-render-output-size rend)
  (define-values (success w h) (SDL-GetCurrentRenderOutputSize (renderer-ptr rend)))
  (unless success
    (error 'current-render-output-size "Failed to get current render output size: ~a" (SDL-GetError)))
  (values w h))

;; Get the renderer associated with a window
;; Returns raw pointer (for interop) or #f if none
(define (get-renderer win)
  (SDL-GetRenderer (window-ptr win)))

;; Get the window associated with a renderer
;; Returns raw pointer (for interop) or #f if none
(define (get-render-window rend)
  (SDL-GetRenderWindow (renderer-ptr rend)))

;; ============================================================================
;; VSync
;; ============================================================================

;; Set VSync mode for the renderer
;; vsync: 0 = off, 1 = on, -1 = adaptive
(define (set-render-vsync! rend vsync)
  (unless (SDL-SetRenderVSync (renderer-ptr rend) vsync)
    (error 'set-render-vsync! "Failed to set VSync: ~a" (SDL-GetError))))

;; Get the current VSync setting
(define (get-render-vsync rend)
  (define-values (success vsync) (SDL-GetRenderVSync (renderer-ptr rend)))
  (unless success
    (error 'get-render-vsync "Failed to get VSync: ~a" (SDL-GetError)))
  vsync)

;; ============================================================================
;; Viewport and Clipping
;; ============================================================================

;; Set the viewport for rendering
;; rect: an SDL_Rect or #f for the entire target
(define (set-render-viewport! rend rect)
  (unless (SDL-SetRenderViewport (renderer-ptr rend) rect)
    (error 'set-render-viewport! "Failed to set viewport: ~a" (SDL-GetError))))

;; Get the current viewport
;; Returns: SDL_Rect
(define (get-render-viewport rend)
  (define rect (make-SDL_Rect 0 0 0 0))
  (unless (SDL-GetRenderViewport (renderer-ptr rend) rect)
    (error 'get-render-viewport "Failed to get viewport: ~a" (SDL-GetError)))
  rect)

;; Set the clip rectangle for rendering
;; rect: an SDL_Rect or #f to disable clipping
(define (set-render-clip-rect! rend rect)
  (unless (SDL-SetRenderClipRect (renderer-ptr rend) rect)
    (error 'set-render-clip-rect! "Failed to set clip rect: ~a" (SDL-GetError))))

;; Get the current clip rectangle
;; Returns: SDL_Rect (empty if clipping is disabled)
(define (get-render-clip-rect rend)
  (define rect (make-SDL_Rect 0 0 0 0))
  (unless (SDL-GetRenderClipRect (renderer-ptr rend) rect)
    (error 'get-render-clip-rect "Failed to get clip rect: ~a" (SDL-GetError)))
  rect)

;; Check if clipping is enabled
(define (render-clip-enabled? rend)
  (SDL-RenderClipEnabled (renderer-ptr rend)))

;; Set the render scale
(define (set-render-scale! rend scale-x scale-y)
  (unless (SDL-SetRenderScale (renderer-ptr rend)
                               (exact->inexact scale-x)
                               (exact->inexact scale-y))
    (error 'set-render-scale! "Failed to set render scale: ~a" (SDL-GetError))))

;; Get the current render scale
;; Returns: (values scale-x scale-y)
(define (get-render-scale rend)
  (define-values (success sx sy) (SDL-GetRenderScale (renderer-ptr rend)))
  (unless success
    (error 'get-render-scale "Failed to get render scale: ~a" (SDL-GetError)))
  (values sx sy))

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

;; =========================================================================
;; Geometry Rendering
;; =========================================================================

;; Create a vertex for geometry rendering
;; x, y: position coordinates
;; r, g, b, a: color (0.0 to 1.0)
;; u, v: texture coordinates (0.0 to 1.0), optional
(define (make-vertex x y r g b [a 1.0] #:uv [uv #f])
  (define pos (make-SDL_FPoint (_->float x) (_->float y)))
  (define color (make-SDL_FColor (_->float r) (_->float g) (_->float b) (_->float a)))
  (define tex-coord
    (if uv
        (make-SDL_FPoint (_->float (car uv)) (_->float (cdr uv)))
        (make-SDL_FPoint 0.0 0.0)))
  (make-SDL_Vertex pos color tex-coord))

;; Render triangles using vertex geometry
;; vertices: list of SDL_Vertex structs (from make-vertex)
;; #:indices: optional list of integer indices into vertices
;; #:texture: optional texture for textured triangles
(define (render-geometry! rend vertices
                           #:indices [indices #f]
                           #:texture [tex #f])
  (define n (length vertices))
  (when (> n 0)
    ;; Allocate and fill vertex array
    (define vertex-size (ctype-sizeof _SDL_Vertex))
    (define vertex-buf (malloc (* n vertex-size) 'atomic-interior))

    (for ([v (in-list vertices)]
          [i (in-naturals)])
      (define p (ptr-add vertex-buf (* i vertex-size)))
      ;; Copy vertex data: position (2 floats), color (4 floats), tex_coord (2 floats)
      (define pos (SDL_Vertex-position v))
      (define col (SDL_Vertex-color v))
      (define tc (SDL_Vertex-tex_coord v))
      ;; Write position
      (ptr-set! p _float 0 (SDL_FPoint-x pos))
      (ptr-set! p _float 1 (SDL_FPoint-y pos))
      ;; Write color
      (ptr-set! p _float 2 (SDL_FColor-r col))
      (ptr-set! p _float 3 (SDL_FColor-g col))
      (ptr-set! p _float 4 (SDL_FColor-b col))
      (ptr-set! p _float 5 (SDL_FColor-a col))
      ;; Write tex_coord
      (ptr-set! p _float 6 (SDL_FPoint-x tc))
      (ptr-set! p _float 7 (SDL_FPoint-y tc)))

    ;; Handle indices if provided
    (define index-buf #f)
    (define num-indices 0)
    (when indices
      (set! num-indices (length indices))
      (set! index-buf (malloc (* num-indices (ctype-sizeof _int)) 'atomic-interior))
      (for ([idx (in-list indices)]
            [i (in-naturals)])
        (ptr-set! index-buf _int i idx)))

    ;; Get texture pointer if provided
    (define tex-ptr
      (cond
        [(not tex) #f]
        [(procedure? (object-name tex)) (tex)]  ; assume it's a texture struct with ptr accessor
        [else tex]))

    ;; Handle texture struct
    (define actual-tex-ptr
      (if (and tex (not (cpointer? tex)))
          ;; Try to extract pointer from texture struct
          (with-handlers ([exn:fail? (λ (_) #f)])
            ((dynamic-require 'racket-sdl3/safe/texture 'texture-ptr) tex))
          tex))

    (unless (SDL-RenderGeometry (renderer-ptr rend)
                                 actual-tex-ptr
                                 vertex-buf
                                 n
                                 index-buf
                                 num-indices)
      (error 'render-geometry! "Failed to render geometry: ~a" (SDL-GetError)))))

;; =========================================================================
;; Debug Text
;; =========================================================================

;; Size of the debug text font (8x8 pixels per character)
(define debug-text-font-size SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE)

;; Render debug text at the specified position
;; This uses a simple 8x8 bitmap font, useful for FPS counters, debug info, etc.
;; Text color is controlled by set-draw-color!
;; x, y: position of top-left corner
;; text: the string to render (only ASCII characters are displayed)
(define (render-debug-text! rend x y text)
  (unless (SDL-RenderDebugText (renderer-ptr rend)
                                (exact->inexact x)
                                (exact->inexact y)
                                text)
    (error 'render-debug-text! "Failed to render debug text: ~a" (SDL-GetError))))
