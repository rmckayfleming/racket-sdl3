#lang racket/base

;; Idiomatic image loading and saving with custodian-based cleanup
;;
;; This module provides safe wrappers for SDL3_image surface operations.
;; For texture loading directly to GPU, use load-texture from safe/texture.rkt.

(require ffi/unsafe
         ffi/unsafe/custodian
         "../raw.rkt"
         "../raw/image.rkt"
         "window.rkt"
         "../private/safe-syntax.rkt")

(provide ;; Surface management
         load-surface
         surface?
         surface-ptr
         surface-destroy!

         ;; Saving
         save-png!
         save-jpg!

         ;; Screenshots
         render-read-pixels)

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
