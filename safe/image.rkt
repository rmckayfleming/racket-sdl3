#lang racket/base

;; Idiomatic image loading, saving, and surface operations with custodian-based cleanup
;;
;; This module provides safe wrappers for SDL3_image surface operations
;; and core SDL3 surface creation/manipulation.
;; For texture loading directly to GPU, use load-texture from safe/texture.rkt.

(require ffi/unsafe
         ffi/unsafe/custodian
         "../raw.rkt"
         "../raw/image.rkt"
         "../raw/surface.rkt"
         "../raw/texture.rkt"
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

         ;; Saving
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
