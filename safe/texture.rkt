#lang racket/base

;; Idiomatic texture management with custodian-based cleanup

(require ffi/unsafe
         ffi/unsafe/custodian
         "../raw.rkt"
         "../image.rkt"
         "window.rkt"
         "draw.rkt"
         "../private/safe-syntax.rkt")

(provide
 ;; Texture management
 load-texture
 create-texture
 texture-from-pointer
 texture?
 texture-ptr
 texture-destroy!
 texture-size

 ;; Render targets
 set-render-target!
 get-render-target
 with-render-target

 ;; Texture scale mode
 texture-set-scale-mode!
 texture-get-scale-mode

 ;; Texture blend mode
 set-texture-blend-mode!
 get-texture-blend-mode

 ;; Color/Alpha modulation
 texture-set-color-mod!
 texture-get-color-mod
 texture-set-alpha-mod!
 texture-get-alpha-mod

 ;; Flip mode conversion
 symbol->flip-mode
 flip-mode->symbol

 ;; Texture access mode symbols
 symbol->texture-access
 texture-access->symbol

 ;; Scale mode symbols
 symbol->scale-mode
 scale-mode->symbol

 ;; Rendering
 render-texture!
 render-texture-affine!
 render-texture-tiled!
 render-texture-9grid!

 ;; Surface/Image I/O
 load-surface
 save-surface-png
 save-surface-jpg
 render-read-pixels
 surface-destroy!)

;; ============================================================================
;; Texture wrapper struct
;; ============================================================================

(define-sdl-resource texture SDL-DestroyTexture)

;; ============================================================================
;; Texture Loading
;; ============================================================================

(define (load-texture rend path
                      #:custodian [cust (current-custodian)])
  (define ptr (IMG-LoadTexture (renderer-ptr rend) path))
  (unless ptr
    (error 'load-texture "Failed to load texture ~a: ~a" path (SDL-GetError)))

  (texture-from-pointer ptr #:custodian cust))

(define (texture-from-pointer ptr
                              #:custodian [cust (current-custodian)])
  (unless ptr
    (error 'texture-from-pointer "Texture pointer is null: ~a" (SDL-GetError)))
  (wrap-texture ptr #:custodian cust))

;; ============================================================================
;; Texture Access Mode Conversion
;; ============================================================================

(define-enum-conversion texture-access
  ([static] SDL_TEXTUREACCESS_STATIC)
  ([streaming] SDL_TEXTUREACCESS_STREAMING)
  ([target] SDL_TEXTUREACCESS_TARGET))

;; ============================================================================
;; Scale Mode Conversion
;; ============================================================================

(define-enum-conversion scale-mode
  ([nearest] SDL_SCALEMODE_NEAREST)
  ([linear] SDL_SCALEMODE_LINEAR))

;; ============================================================================
;; Texture Creation
;; ============================================================================

;; Create a blank texture for the given renderer
;; renderer: the renderer to create the texture for
;; width, height: texture dimensions in pixels
;; #:access: texture access mode symbol (default: 'target)
;;   - 'static: changes rarely, not lockable
;;   - 'streaming: changes frequently, lockable
;;   - 'target: can be used as render target
;; #:scale: scale mode symbol (default: 'nearest)
;;   - 'nearest: nearest pixel sampling (pixelated)
;;   - 'linear: linear filtering (smooth)
;; #:format: pixel format (default: SDL_PIXELFORMAT_RGBA8888)
(define (create-texture rend width height
                        #:access [access 'target]
                        #:scale [scale 'nearest]
                        #:format [format SDL_PIXELFORMAT_RGBA8888]
                        #:custodian [cust (current-custodian)])
  (define access-val (if (symbol? access)
                         (symbol->texture-access access)
                         access))
  (define ptr (SDL-CreateTexture (renderer-ptr rend)
                                 format
                                 access-val
                                 width
                                 height))
  (unless ptr
    (error 'create-texture "Failed to create texture: ~a" (SDL-GetError)))

  (define tex (texture-from-pointer ptr #:custodian cust))

  ;; Set scale mode if specified
  (when scale
    (define scale-val (if (symbol? scale)
                          (symbol->scale-mode scale)
                          scale))
    (unless (SDL-SetTextureScaleMode (texture-ptr tex) scale-val)
      (error 'create-texture "Failed to set scale mode: ~a" (SDL-GetError))))

  tex)

;; ============================================================================
;; Render Targets
;; ============================================================================

;; Set a texture as the current render target
;; Pass #f to restore rendering to the default target (the window)
(define (set-render-target! rend tex)
  (define tex-ptr (if tex (texture-ptr tex) #f))
  (unless (SDL-SetRenderTarget (renderer-ptr rend) tex-ptr)
    (error 'set-render-target! "Failed to set render target: ~a" (SDL-GetError))))

;; Get the current render target
;; Returns #f if rendering to the default target (window)
(define (get-render-target rend)
  (define ptr (SDL-GetRenderTarget (renderer-ptr rend)))
  (if ptr
      ;; Wrap in texture struct but don't register with custodian
      ;; since we don't own this pointer
      (texture ptr #f)
      #f))

;; Temporarily render to a texture, then restore the previous target
;; Usage: (with-render-target renderer texture body ...)
(define-syntax-rule (with-render-target rend tex body ...)
  (let ([old-target (SDL-GetRenderTarget (renderer-ptr rend))])
    (dynamic-wind
      (λ () (set-render-target! rend tex))
      (λ () body ...)
      (λ () (SDL-SetRenderTarget (renderer-ptr rend) old-target)))))

;; ============================================================================
;; Texture Scale Mode
;; ============================================================================

;; Set the scale mode for a texture
(define (texture-set-scale-mode! tex mode)
  (define mode-val (if (symbol? mode)
                       (symbol->scale-mode mode)
                       mode))
  (unless (SDL-SetTextureScaleMode (texture-ptr tex) mode-val)
    (error 'texture-set-scale-mode! "Failed to set scale mode: ~a" (SDL-GetError))))

;; Get the scale mode for a texture
;; Returns a symbol: 'nearest or 'linear
(define (texture-get-scale-mode tex)
  (define-values (success mode) (SDL-GetTextureScaleMode (texture-ptr tex)))
  (unless success
    (error 'texture-get-scale-mode "Failed to get scale mode: ~a" (SDL-GetError)))
  (scale-mode->symbol mode))

;; ============================================================================
;; Texture Blend Mode
;; ============================================================================

;; Set the blend mode for a texture
;; mode can be a symbol ('none, 'blend, 'add, 'mod, 'mul) or an SDL constant
(define (set-texture-blend-mode! tex mode)
  (define blend-mode
    (if (symbol? mode)
        (symbol->blend-mode mode)
        mode))
  (unless (SDL-SetTextureBlendMode (texture-ptr tex) blend-mode)
    (error 'set-texture-blend-mode! "Failed to set blend mode: ~a" (SDL-GetError))))

;; Get the current blend mode for a texture (returns a symbol)
(define (get-texture-blend-mode tex)
  (define-values (success mode) (SDL-GetTextureBlendMode (texture-ptr tex)))
  (if success
      (blend-mode->symbol mode)
      (error 'get-texture-blend-mode "Failed to get blend mode: ~a" (SDL-GetError))))

;; ============================================================================
;; Texture Properties
;; ============================================================================

(define (texture-size tex)
  (define w-ptr (malloc _float 'atomic-interior))
  (define h-ptr (malloc _float 'atomic-interior))
  (unless (SDL-GetTextureSize (texture-ptr tex) w-ptr h-ptr)
    (error 'texture-size "Failed to get texture size: ~a" (SDL-GetError)))
  (values (ptr-ref w-ptr _float) (ptr-ref h-ptr _float)))

;; ============================================================================
;; Color/Alpha Modulation
;; ============================================================================

;; Set the color modulation for a texture (tinting)
;; r, g, b: 0-255 color values multiplied with texture colors
;; 255,255,255 = no tint (default), 255,0,0 = red tint, etc.
(define (texture-set-color-mod! tex r g b)
  (unless (SDL-SetTextureColorMod (texture-ptr tex) r g b)
    (error 'texture-set-color-mod! "Failed to set color mod: ~a" (SDL-GetError))))

;; Get the current color modulation for a texture
;; Returns: (values r g b)
(define (texture-get-color-mod tex)
  (define-values (success r g b) (SDL-GetTextureColorMod (texture-ptr tex)))
  (unless success
    (error 'texture-get-color-mod "Failed to get color mod: ~a" (SDL-GetError)))
  (values r g b))

;; Set the alpha modulation for a texture (transparency)
;; alpha: 0-255 (0 = fully transparent, 255 = fully opaque)
(define (texture-set-alpha-mod! tex alpha)
  (unless (SDL-SetTextureAlphaMod (texture-ptr tex) alpha)
    (error 'texture-set-alpha-mod! "Failed to set alpha mod: ~a" (SDL-GetError))))

;; Get the current alpha modulation for a texture
;; Returns: alpha (0-255)
(define (texture-get-alpha-mod tex)
  (define-values (success alpha) (SDL-GetTextureAlphaMod (texture-ptr tex)))
  (unless success
    (error 'texture-get-alpha-mod "Failed to get alpha mod: ~a" (SDL-GetError)))
  alpha)

;; ============================================================================
;; Flip Mode Conversion
;; ============================================================================

;; Convert a flip mode symbol to SDL constant
(define (symbol->flip-mode sym)
  (case sym
    [(none) SDL_FLIP_NONE]
    [(horizontal h) SDL_FLIP_HORIZONTAL]
    [(vertical v) SDL_FLIP_VERTICAL]
    [(both hv vh)
     (bitwise-ior SDL_FLIP_HORIZONTAL SDL_FLIP_VERTICAL)]
    [else (error 'symbol->flip-mode
                 "unknown flip mode: ~a (expected: none, horizontal, vertical, both)"
                 sym)]))

;; Convert an SDL flip mode constant to a symbol
(define (flip-mode->symbol mode)
  (cond
    [(= mode SDL_FLIP_NONE) 'none]
    [(= mode SDL_FLIP_HORIZONTAL) 'horizontal]
    [(= mode SDL_FLIP_VERTICAL) 'vertical]
    [(= mode (bitwise-ior SDL_FLIP_HORIZONTAL SDL_FLIP_VERTICAL)) 'both]
    [else 'unknown]))

;; ============================================================================
;; Texture Rendering
;; ============================================================================

;; Render a texture at position (x, y)
;; Optional #:width and #:height to scale the texture
;; Optional #:src-x, #:src-y, #:src-w, #:src-h to specify source rectangle
;; Optional #:angle for rotation in degrees (clockwise)
;; Optional #:center for rotation center as (cons cx cy), defaults to texture center
;; Optional #:flip for flipping: 'none, 'horizontal, 'vertical, 'both
(define (render-texture! rend tex x y
                         #:width [w #f]
                         #:height [h #f]
                         #:src-x [src-x #f]
                         #:src-y [src-y #f]
                         #:src-w [src-w #f]
                         #:src-h [src-h #f]
                         #:angle [angle #f]
                         #:center [center #f]
                         #:flip [flip #f])
  ;; Get texture size if width/height not specified
  (define-values (tex-w tex-h)
    (if (or (not w) (not h))
        (texture-size tex)
        (values w h)))

  (define actual-w (or w tex-w))
  (define actual-h (or h tex-h))

  ;; Create destination rect
  (define dst-rect (make-SDL_FRect (exact->inexact x)
                                   (exact->inexact y)
                                   (exact->inexact actual-w)
                                   (exact->inexact actual-h)))

  ;; Create source rect if specified
  (define src-rect
    (if (and src-x src-y src-w src-h)
        (make-SDL_FRect (exact->inexact src-x)
                        (exact->inexact src-y)
                        (exact->inexact src-w)
                        (exact->inexact src-h))
        #f))

  ;; Use rotated render if angle, center, or flip is specified
  (if (or angle center flip)
      (let* ([angle-val (exact->inexact (or angle 0.0))]
             [center-point (if center
                               (make-SDL_FPoint (exact->inexact (car center))
                                                (exact->inexact (cdr center)))
                               #f)]
             [flip-val (cond
                         [(not flip) SDL_FLIP_NONE]
                         [(symbol? flip) (symbol->flip-mode flip)]
                         [else flip])])
        (SDL-RenderTextureRotated (renderer-ptr rend)
                                  (texture-ptr tex)
                                  src-rect
                                  dst-rect
                                  angle-val
                                  center-point
                                  flip-val))
      (SDL-RenderTexture (renderer-ptr rend) (texture-ptr tex) src-rect dst-rect)))

;; Render a texture with affine transform
;; This allows arbitrary 2D transformations including shearing/skewing
;; origin: where the top-left of the texture appears (cons x y) or SDL_FPoint
;; right: where the top-right of the texture appears (cons x y) or SDL_FPoint
;; down: where the bottom-left of the texture appears (cons x y) or SDL_FPoint
;; The bottom-right is inferred from these three points
(define (render-texture-affine! rend tex origin right down
                                 #:src-x [src-x #f]
                                 #:src-y [src-y #f]
                                 #:src-w [src-w #f]
                                 #:src-h [src-h #f])
  ;; Create source rect if specified
  (define src-rect
    (if (and src-x src-y src-w src-h)
        (make-SDL_FRect (exact->inexact src-x)
                        (exact->inexact src-y)
                        (exact->inexact src-w)
                        (exact->inexact src-h))
        #f))

  ;; Convert points from cons pairs if needed
  (define (->fpoint p)
    (cond
      [(pair? p) (make-SDL_FPoint (exact->inexact (car p))
                                   (exact->inexact (cdr p)))]
      [else p]))  ; assume it's already an SDL_FPoint

  (define origin-pt (and origin (->fpoint origin)))
  (define right-pt (and right (->fpoint right)))
  (define down-pt (and down (->fpoint down)))

  (unless (SDL-RenderTextureAffine (renderer-ptr rend)
                                    (texture-ptr tex)
                                    src-rect
                                    origin-pt
                                    right-pt
                                    down-pt)
    (error 'render-texture-affine! "Failed to render affine: ~a" (SDL-GetError))))

;; Render a texture tiled to fill a destination area
;; scale: scale factor for the tile (1.0 = original size, 2.0 = double size)
;; dst-x, dst-y, dst-w, dst-h: destination rectangle (required)
(define (render-texture-tiled! rend tex dst-x dst-y dst-w dst-h
                                #:scale [scale 1.0]
                                #:src-x [src-x #f]
                                #:src-y [src-y #f]
                                #:src-w [src-w #f]
                                #:src-h [src-h #f])
  ;; Create source rect if specified
  (define src-rect
    (if (and src-x src-y src-w src-h)
        (make-SDL_FRect (exact->inexact src-x)
                        (exact->inexact src-y)
                        (exact->inexact src-w)
                        (exact->inexact src-h))
        #f))

  (define dst-rect (make-SDL_FRect (exact->inexact dst-x)
                                   (exact->inexact dst-y)
                                   (exact->inexact dst-w)
                                   (exact->inexact dst-h)))

  (unless (SDL-RenderTextureTiled (renderer-ptr rend)
                                   (texture-ptr tex)
                                   src-rect
                                   (exact->inexact scale)
                                   dst-rect)
    (error 'render-texture-tiled! "Failed to render tiled: ~a" (SDL-GetError))))

;; Render a texture using 9-grid (9-slice) scaling
;; This is ideal for UI elements like buttons and panels that need to scale
;; without distorting corners
;; left-width, right-width: width of corner regions in source pixels
;; top-height, bottom-height: height of corner regions in source pixels
;; scale: scale factor for the corners
;; dst-x, dst-y, dst-w, dst-h: destination rectangle
(define (render-texture-9grid! rend tex dst-x dst-y dst-w dst-h
                                #:left-width left-width
                                #:right-width right-width
                                #:top-height top-height
                                #:bottom-height bottom-height
                                #:scale [scale 1.0]
                                #:src-x [src-x #f]
                                #:src-y [src-y #f]
                                #:src-w [src-w #f]
                                #:src-h [src-h #f])
  ;; Create source rect if specified
  (define src-rect
    (if (and src-x src-y src-w src-h)
        (make-SDL_FRect (exact->inexact src-x)
                        (exact->inexact src-y)
                        (exact->inexact src-w)
                        (exact->inexact src-h))
        #f))

  (define dst-rect (make-SDL_FRect (exact->inexact dst-x)
                                   (exact->inexact dst-y)
                                   (exact->inexact dst-w)
                                   (exact->inexact dst-h)))

  (unless (SDL-RenderTexture9Grid (renderer-ptr rend)
                                   (texture-ptr tex)
                                   src-rect
                                   (exact->inexact left-width)
                                   (exact->inexact right-width)
                                   (exact->inexact top-height)
                                   (exact->inexact bottom-height)
                                   (exact->inexact scale)
                                   dst-rect)
    (error 'render-texture-9grid! "Failed to render 9-grid: ~a" (SDL-GetError))))

;; ============================================================================
;; Surface/Image I/O
;; ============================================================================

;; Load an image file to a software surface (CPU memory)
;; Use this when you need to manipulate pixel data or save images.
;; For rendering, prefer load-texture instead.
(define (load-surface path)
  (define ptr (IMG-Load path))
  (unless ptr
    (error 'load-surface "Failed to load surface ~a: ~a" path (SDL-GetError)))
  ptr)

;; Save a surface to a PNG file
;; surface: surface pointer from load-surface or render-read-pixels
;; path: destination file path
;; Returns: #t on success
(define (save-surface-png surface path)
  (unless (IMG-SavePNG surface path)
    (error 'save-surface-png "Failed to save PNG ~a: ~a" path (SDL-GetError)))
  #t)

;; Save a surface to a JPG file
;; surface: surface pointer from load-surface or render-read-pixels
;; path: destination file path
;; quality: 0-100 (higher = better quality, larger file)
;; Returns: #t on success
(define (save-surface-jpg surface path [quality 90])
  (unless (IMG-SaveJPG surface path quality)
    (error 'save-surface-jpg "Failed to save JPG ~a: ~a" path (SDL-GetError)))
  #t)

;; Read pixels from the renderer into a new surface
;; This is used for taking screenshots.
;; Returns: surface pointer (must be freed with surface-destroy!)
(define (render-read-pixels rend)
  (define ptr (SDL-RenderReadPixels (renderer-ptr rend) #f))
  (unless ptr
    (error 'render-read-pixels "Failed to read pixels: ~a" (SDL-GetError)))
  ptr)

;; Destroy a surface (free its memory)
;; Use this to clean up surfaces from load-surface or render-read-pixels
(define (surface-destroy! surface)
  (SDL-DestroySurface surface))
