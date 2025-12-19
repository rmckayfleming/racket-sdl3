#lang racket/base

;; Idiomatic image loading, saving, and surface operations with custodian-based cleanup
;;
;; This module provides safe wrappers for SDL3_image surface operations
;; and core SDL3 surface creation/manipulation.
;; For texture loading directly to GPU, use load-texture from safe/texture.rkt.

(require ffi/unsafe
         ffi/unsafe/custodian
         racket/list
         "../raw.rkt"
         "../raw/image.rkt"
         "../raw/surface.rkt"
         "../raw/texture.rkt"
         "../private/constants.rkt"
         "../private/types.rkt"
         "window.rkt"
         "texture.rkt"
         "../private/safe-syntax.rkt")

(provide ;; Surface management
         load-surface
         surface?
         surface-ptr
         surface-destroy!
         wrap-surface

         ;; Surface creation
         make-surface
         duplicate-surface
         convert-surface

         ;; Surface to texture conversion
         surface->texture

         ;; Surface properties
         surface-width
         surface-height
         surface-pitch
         surface-format
         surface-pixels

         ;; Surface locking
         surface-lock!
         surface-unlock!
         call-with-locked-surface

         ;; Pixel access
         surface-get-pixel
         surface-set-pixel!
         surface-get-pixel-float
         surface-set-pixel-float!

         ;; Color mapping
         surface-map-rgb
         surface-map-rgba

         ;; Bulk pixel access
         surface-fill-pixels!
         call-with-surface-pixels

         ;; Blitting
         blit-surface!
         blit-surface-scaled!

         ;; Filling
         fill-surface!
         clear-surface!

         ;; Transformations
         flip-surface!
         scale-surface

         ;; BMP file I/O
         load-bmp
         save-bmp!

         ;; Saving (PNG/JPG via SDL_image)
         save-png!
         save-jpg!

         ;; Screenshots
         render-read-pixels

         ;; Pixel format symbols
         symbol->pixel-format
         pixel-format->symbol)

;; ============================================================================
;; Surface Wrapper
;; ============================================================================

;; Define a surface resource with automatic custodian cleanup
(define-sdl-resource surface SDL-DestroySurface)

;; ============================================================================
;; Surface Loading
;; ============================================================================

;; load-surface: Load an image file to a software surface
;; path: path to the image file (PNG, JPG, WebP, etc.)
;; Returns: a surface object with custodian-managed cleanup
;;
;; Use this when you need to:
;; - Save screenshots or modified images
;; - Access pixel data directly
;; - Set window icons
;;
;; For rendering images, use load-texture instead (more efficient).
(define (load-surface path #:custodian [cust (current-custodian)])
  (define ptr (IMG-Load path))
  (unless ptr
    (error 'load-surface "failed to load image: ~a (~a)" path (SDL-GetError)))
  (wrap-surface ptr #:custodian cust))

;; ============================================================================
;; Surface Saving
;; ============================================================================

;; save-png!: Save a surface to a PNG file
;; surf: the surface to save (surface object or raw pointer)
;; path: destination file path
(define (save-png! surf path)
  (define ptr (if (surface? surf) (surface-ptr surf) surf))
  (unless (IMG-SavePNG ptr path)
    (error 'save-png! "failed to save PNG: ~a (~a)" path (SDL-GetError))))

;; save-jpg!: Save a surface to a JPG file
;; surf: the surface to save (surface object or raw pointer)
;; path: destination file path
;; quality: 0-100 (higher = better quality, larger file size)
(define (save-jpg! surf path [quality 90])
  (define ptr (if (surface? surf) (surface-ptr surf) surf))
  (unless (IMG-SaveJPG ptr path quality)
    (error 'save-jpg! "failed to save JPG: ~a (~a)" path (SDL-GetError))))

;; ============================================================================
;; Screenshots
;; ============================================================================

;; render-read-pixels: Read pixels from the renderer into a new surface
;; This is used for taking screenshots.
;; rend: the renderer
;; Returns: a surface object with custodian-managed cleanup
(define (render-read-pixels rend #:custodian [cust (current-custodian)])
  (define ptr (SDL-RenderReadPixels (renderer-ptr rend) #f))
  (unless ptr
    (error 'render-read-pixels "failed to read pixels: ~a" (SDL-GetError)))
  (wrap-surface ptr #:custodian cust))

;; ============================================================================
;; Pixel Format Conversion
;; ============================================================================

(define-enum-conversion pixel-format
  ([unknown] SDL_PIXELFORMAT_UNKNOWN)
  ([rgba8888] SDL_PIXELFORMAT_RGBA8888)
  ([argb8888] SDL_PIXELFORMAT_ARGB8888)
  ([abgr8888] SDL_PIXELFORMAT_ABGR8888)
  ([bgra8888] SDL_PIXELFORMAT_BGRA8888)
  ([rgb24] SDL_PIXELFORMAT_RGB24)
  ([rgba32 rgba] SDL_PIXELFORMAT_RGBA32))

;; ============================================================================
;; Surface Creation
;; ============================================================================

;; make-surface: Create a new empty surface
;; width, height: dimensions in pixels
;; #:format: pixel format (symbol or constant, default 'rgba32)
;; Returns: a surface object with custodian-managed cleanup
(define (make-surface width height
                      #:format [format 'rgba32]
                      #:custodian [cust (current-custodian)])
  (define format-val (if (symbol? format)
                         (symbol->pixel-format format)
                         format))
  (define ptr (SDL-CreateSurface width height format-val))
  (unless ptr
    (error 'make-surface "failed to create surface ~ax~a: ~a"
           width height (SDL-GetError)))
  (wrap-surface ptr #:custodian cust))

;; duplicate-surface: Create a copy of a surface
;; surf: the surface to copy
;; Returns: a new surface object with custodian-managed cleanup
(define (duplicate-surface surf #:custodian [cust (current-custodian)])
  (define ptr (SDL-DuplicateSurface (surface-ptr surf)))
  (unless ptr
    (error 'duplicate-surface "failed to duplicate surface: ~a" (SDL-GetError)))
  (wrap-surface ptr #:custodian cust))

;; convert-surface: Convert a surface to a different pixel format
;; surf: the source surface
;; format: target pixel format (symbol or constant)
;; Returns: a new surface object with custodian-managed cleanup
(define (convert-surface surf format #:custodian [cust (current-custodian)])
  (define format-val (if (symbol? format)
                         (symbol->pixel-format format)
                         format))
  (define ptr (SDL-ConvertSurface (surface-ptr surf) format-val))
  (unless ptr
    (error 'convert-surface "failed to convert surface: ~a" (SDL-GetError)))
  (wrap-surface ptr #:custodian cust))

;; surface->texture: Create a texture from a surface
;; rend: the renderer to create the texture for
;; surf: the source surface
;; Returns: a texture object with custodian-managed cleanup
;; Note: The surface is NOT destroyed; you can create multiple textures from it
(define (surface->texture rend surf #:custodian [cust (current-custodian)])
  (define tex-ptr (SDL-CreateTextureFromSurface (renderer-ptr rend) (surface-ptr surf)))
  (unless tex-ptr
    (error 'surface->texture "failed to create texture from surface: ~a" (SDL-GetError)))
  (texture-from-pointer tex-ptr #:custodian cust))

;; ============================================================================
;; Surface Properties
;; ============================================================================

;; Get surface width in pixels
(define (surface-width surf)
  (SDL_Surface-w (surface-ptr surf)))

;; Get surface height in pixels
(define (surface-height surf)
  (SDL_Surface-h (surface-ptr surf)))

;; Get surface pitch (bytes per row)
(define (surface-pitch surf)
  (SDL_Surface-pitch (surface-ptr surf)))

;; Get surface pixel format as a symbol
(define (surface-format surf)
  (pixel-format->symbol (SDL_Surface-format (surface-ptr surf))))

;; Get raw pointer to surface pixels
;; WARNING: Only use this when the surface is locked (or doesn't require locking)
(define (surface-pixels surf)
  (SDL_Surface-pixels (surface-ptr surf)))

;; ============================================================================
;; Surface Locking
;; ============================================================================

;; Lock a surface for direct pixel access
;; Returns #t on success
(define (surface-lock! surf)
  (unless (SDL-LockSurface (surface-ptr surf))
    (error 'surface-lock! "failed to lock surface: ~a" (SDL-GetError)))
  #t)

;; Unlock a surface after direct pixel access
(define (surface-unlock! surf)
  (SDL-UnlockSurface (surface-ptr surf)))

;; Execute a procedure with a locked surface
;; Automatically locks before and unlocks after
;; proc receives: surface, pixels-pointer, width, height, pitch
(define (call-with-locked-surface surf proc)
  (surface-lock! surf)
  (dynamic-wind
    void
    (lambda ()
      (proc surf
            (surface-pixels surf)
            (surface-width surf)
            (surface-height surf)
            (surface-pitch surf)))
    (lambda ()
      (surface-unlock! surf))))

;; ============================================================================
;; Pixel Access
;; ============================================================================

;; surface-get-pixel: Read a pixel from a surface
;; Returns (values r g b a) where each component is 0-255
(define (surface-get-pixel surf x y)
  (define-values (ok r g b a)
    (SDL-ReadSurfacePixel (surface-ptr surf) x y))
  (unless ok
    (error 'surface-get-pixel "failed to read pixel at (~a, ~a): ~a" x y (SDL-GetError)))
  (values r g b a))

;; surface-set-pixel!: Write a pixel to a surface
;; r, g, b, a are 0-255 (a defaults to 255)
(define (surface-set-pixel! surf x y r g b [a 255])
  (unless (SDL-WriteSurfacePixel (surface-ptr surf) x y r g b a)
    (error 'surface-set-pixel! "failed to write pixel at (~a, ~a): ~a" x y (SDL-GetError))))

;; surface-get-pixel-float: Read a pixel from a surface as floats
;; Returns (values r g b a) where each component is 0.0-1.0
(define (surface-get-pixel-float surf x y)
  (define-values (ok r g b a)
    (SDL-ReadSurfacePixelFloat (surface-ptr surf) x y))
  (unless ok
    (error 'surface-get-pixel-float "failed to read pixel at (~a, ~a): ~a" x y (SDL-GetError)))
  (values r g b a))

;; surface-set-pixel-float!: Write a pixel to a surface as floats
;; r, g, b, a are 0.0-1.0 (a defaults to 1.0)
(define (surface-set-pixel-float! surf x y r g b [a 1.0])
  (unless (SDL-WriteSurfacePixelFloat (surface-ptr surf) x y r g b a)
    (error 'surface-set-pixel-float! "failed to write pixel at (~a, ~a): ~a" x y (SDL-GetError))))

;; ============================================================================
;; Color Mapping
;; ============================================================================

;; surface-map-rgb: Map an RGB triple to a pixel value for a surface
;; Returns a 32-bit pixel value suitable for direct buffer access
(define (surface-map-rgb surf r g b)
  (SDL-MapSurfaceRGB (surface-ptr surf) r g b))

;; surface-map-rgba: Map an RGBA quadruple to a pixel value for a surface
;; Returns a 32-bit pixel value suitable for direct buffer access
(define (surface-map-rgba surf r g b a)
  (SDL-MapSurfaceRGBA (surface-ptr surf) r g b a))

;; ============================================================================
;; Bulk Pixel Access
;; ============================================================================

;; surface-fill-pixels!: Fill a surface by calling a generator function for each pixel
;; This is the recommended way to do procedural texture generation.
;; generator: (x y) -> (values r g b a) where r,g,b,a are 0-255
;;
;; Example:
;;   (surface-fill-pixels! surf
;;     (lambda (x y)
;;       (values (quotient (* x 255) width)   ; red gradient
;;               128                           ; constant green
;;               (quotient (* y 255) height)  ; blue gradient
;;               255)))                        ; opaque
(define (surface-fill-pixels! surf generator)
  (define ptr (surface-ptr surf))
  (define w (surface-width surf))
  (define h (surface-height surf))
  (define pitch (surface-pitch surf))
  (define format (SDL_Surface-format ptr))
  (define bpp (bitwise-and format #xFF))
  (surface-lock! surf)
  (define pixels (surface-pixels surf))
  (dynamic-wind
    void
    (lambda ()
      (for* ([y (in-range h)]
             [x (in-range w)])
        (define-values (r g b a) (generator x y))
        (define offset (+ (* y pitch) (* x bpp)))
        (ptr-set! pixels _uint8 offset r)
        (ptr-set! pixels _uint8 (+ offset 1) g)
        (ptr-set! pixels _uint8 (+ offset 2) b)
        (ptr-set! pixels _uint8 (+ offset 3) a)))
    (lambda ()
      (surface-unlock! surf))))

;; call-with-surface-pixels: Low-level access to the pixel buffer
;; Use this when you need maximum performance and are comfortable with FFI.
;; For most cases, prefer surface-fill-pixels! instead.
;; proc receives: pixels-pointer, width, height, pitch, bytes-per-pixel
(define (call-with-surface-pixels surf proc)
  (define ptr (surface-ptr surf))
  (define format (SDL_Surface-format ptr))
  ;; SDL_PIXELFORMAT_* encoding: bytes in bits 0-7, bits in bits 8-15
  (define bytes-per-pixel (bitwise-and format #xFF))
  (surface-lock! surf)
  (dynamic-wind
    void
    (lambda ()
      (proc (surface-pixels surf)
            (surface-width surf)
            (surface-height surf)
            (surface-pitch surf)
            bytes-per-pixel))
    (lambda ()
      (surface-unlock! surf))))

;; ============================================================================
;; Blitting
;; ============================================================================

;; Helper to convert a list (x y w h) to an SDL_Rect pointer
(define (list->rect lst)
  (if lst
      (let ([r (make-SDL_Rect (first lst) (second lst) (third lst) (fourth lst))])
        r)
      #f))

;; blit-surface!: Copy pixels from source to destination surface
;; src: source surface
;; dst: destination surface
;; #:src-rect: source rectangle as (list x y w h), or #f for entire surface
;; #:dst-rect: destination rectangle as (list x y w h), or #f for (0,0)
;; Note: Only position of dst-rect is used; size comes from src-rect
(define (blit-surface! src dst
                       #:src-rect [src-rect #f]
                       #:dst-rect [dst-rect #f])
  (define src-r (list->rect src-rect))
  (define dst-r (list->rect dst-rect))
  (unless (SDL-BlitSurface (surface-ptr src) src-r
                           (surface-ptr dst) dst-r)
    (error 'blit-surface! "failed to blit surface: ~a" (SDL-GetError))))

;; blit-surface-scaled!: Copy and scale pixels from source to destination
;; src: source surface
;; dst: destination surface
;; #:src-rect: source rectangle as (list x y w h), or #f for entire surface
;; #:dst-rect: destination rectangle as (list x y w h), or #f for entire surface
;; #:scale-mode: 'nearest or 'linear (default 'nearest)
(define (blit-surface-scaled! src dst
                              #:src-rect [src-rect #f]
                              #:dst-rect [dst-rect #f]
                              #:scale-mode [scale-mode 'nearest])
  (define src-r (list->rect src-rect))
  (define dst-r (list->rect dst-rect))
  (define mode (case scale-mode
                 [(nearest) SDL_SCALEMODE_NEAREST]
                 [(linear) SDL_SCALEMODE_LINEAR]
                 [else (error 'blit-surface-scaled! "invalid scale mode: ~a" scale-mode)]))
  (unless (SDL-BlitSurfaceScaled (surface-ptr src) src-r
                                 (surface-ptr dst) dst-r
                                 mode)
    (error 'blit-surface-scaled! "failed to blit surface: ~a" (SDL-GetError))))

;; ============================================================================
;; Filling
;; ============================================================================

;; fill-surface!: Fill a surface or rectangle with a color
;; surf: the surface to fill
;; color: color as (list r g b) or (list r g b a), values 0-255
;; #:rect: rectangle as (list x y w h), or #f for entire surface
(define (fill-surface! surf color #:rect [rect #f])
  (define r (first color))
  (define g (second color))
  (define b (third color))
  (define a (if (> (length color) 3) (fourth color) 255))
  (define pixel (SDL-MapSurfaceRGBA (surface-ptr surf) r g b a))
  (define rect-ptr (list->rect rect))
  (unless (SDL-FillSurfaceRect (surface-ptr surf) rect-ptr pixel)
    (error 'fill-surface! "failed to fill surface: ~a" (SDL-GetError))))

;; clear-surface!: Clear a surface to a color (using float values)
;; surf: the surface to clear
;; r, g, b: color components (0.0-1.0)
;; a: alpha component (0.0-1.0, default 1.0)
(define (clear-surface! surf r g b [a 1.0])
  (unless (SDL-ClearSurface (surface-ptr surf) r g b a)
    (error 'clear-surface! "failed to clear surface: ~a" (SDL-GetError))))

;; ============================================================================
;; Transformations
;; ============================================================================

;; flip-surface!: Flip a surface in place
;; surf: the surface to flip
;; mode: 'horizontal or 'vertical
;; Note: To flip both horizontally and vertically, call flip-surface! twice
(define (flip-surface! surf mode)
  (define flip-mode
    (case mode
      [(horizontal) SDL_FLIP_HORIZONTAL]
      [(vertical) SDL_FLIP_VERTICAL]
      [else (error 'flip-surface! "invalid flip mode: ~a (use 'horizontal or 'vertical)" mode)]))
  (unless (SDL-FlipSurface (surface-ptr surf) flip-mode)
    (error 'flip-surface! "failed to flip surface: ~a" (SDL-GetError))))

;; scale-surface: Create a new surface with scaled contents
;; surf: the source surface
;; width: new width
;; height: new height
;; #:mode: 'nearest or 'linear (default 'nearest)
;; Returns: a new surface with custodian-managed cleanup
(define (scale-surface surf width height
                       #:mode [mode 'nearest]
                       #:custodian [cust (current-custodian)])
  (define scale-mode
    (case mode
      [(nearest) SDL_SCALEMODE_NEAREST]
      [(linear) SDL_SCALEMODE_LINEAR]
      [else (error 'scale-surface "invalid scale mode: ~a (use 'nearest or 'linear)" mode)]))
  (define ptr (SDL-ScaleSurface (surface-ptr surf) width height scale-mode))
  (unless ptr
    (error 'scale-surface "failed to scale surface: ~a" (SDL-GetError)))
  (wrap-surface ptr #:custodian cust))

;; ============================================================================
;; BMP File I/O
;; ============================================================================

;; load-bmp: Load a BMP image from a file
;; path: path to the BMP file
;; Returns: a surface object with custodian-managed cleanup
;; Note: For loading PNG/JPG/WebP files, use load-surface instead
(define (load-bmp path #:custodian [cust (current-custodian)])
  (define ptr (SDL-LoadBMP path))
  (unless ptr
    (error 'load-bmp "failed to load BMP: ~a (~a)" path (SDL-GetError)))
  (wrap-surface ptr #:custodian cust))

;; save-bmp!: Save a surface to a BMP file
;; surf: the surface to save (surface object or raw pointer)
;; path: destination file path
;; Note: 24-bit, 32-bit, and paletted 8-bit formats are saved directly.
;;       Other formats are converted before saving.
(define (save-bmp! surf path)
  (define ptr (if (surface? surf) (surface-ptr surf) surf))
  (unless (SDL-SaveBMP ptr path)
    (error 'save-bmp! "failed to save BMP: ~a (~a)" path (SDL-GetError))))
