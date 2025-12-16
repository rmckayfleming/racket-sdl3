#lang racket/base

;; SDL3_image bindings - image loading support for SDL3
;;
;; This module provides bindings to SDL3_image, which adds support for
;; loading PNG, JPG, WebP, and other image formats beyond SDL's built-in BMP.
;;
;; NOTE: SDL3_image no longer requires explicit IMG_Init/IMG_Quit calls.
;; Format support is initialized automatically when needed.

(require ffi/unsafe
         ffi/unsafe/define
         "private/types.rkt")

(provide ;; Functions
         IMG-LoadTexture
         IMG-Load
         IMG-SavePNG
         IMG-SaveJPG
         IMG-Version)

;; ============================================================================
;; Library Loading
;; ============================================================================

;; Platform-specific library paths for SDL3_image
(define sdl3-image-lib-paths
  (case (system-type 'os)
    [(macosx)
     ;; Try Homebrew paths on macOS (both ARM and Intel)
     '("/opt/homebrew/lib/libSDL3_image"    ; ARM Homebrew
       "/usr/local/lib/libSDL3_image"       ; Intel Homebrew
       "libSDL3_image")]                    ; System path
    [(unix)
     '("/usr/local/lib/libSDL3_image"
       "/usr/lib/libSDL3_image"
       "libSDL3_image")]
    [(windows)
     '("SDL3_image")]
    [else '("libSDL3_image")]))

;; Try to load SDL3_image from the first available path
(define sdl3-image-lib
  (let loop ([paths sdl3-image-lib-paths])
    (if (null? paths)
        (ffi-lib "libSDL3_image" '("0" #f))  ; Last resort
        (with-handlers ([exn:fail? (λ (e) (loop (cdr paths)))])
          (ffi-lib (car paths) '("0" #f))))))

(define-ffi-definer define-img sdl3-image-lib
  #:make-c-id convention:hyphen->underscore
  #:default-make-fail make-not-available)

;; ============================================================================
;; Functions
;; ============================================================================

;; IMG_Version: Get the version of SDL3_image
;; Returns: version number (major * 1000000 + minor * 1000 + patch)
(define-img IMG-Version (_fun -> _int)
  #:c-id IMG_Version)

;; IMG_LoadTexture: Load image directly to a GPU texture
;; renderer: the rendering context
;; file: path to the image file
;; Returns: texture pointer, or NULL on failure (use SDL_GetError for message)
;;
;; NOTE: In SDL3_image, format support is initialized automatically.
;; No need to call IMG_Init first.
(define-img IMG-LoadTexture
  (_fun _SDL_Renderer-pointer _string/utf-8 -> _SDL_Texture-pointer/null)
  #:c-id IMG_LoadTexture)

;; IMG_Load: Load image to a software surface (CPU memory)
;; file: path to the image file
;; Returns: surface pointer, or NULL on failure (use SDL_GetError for message)
;;
;; Use this when you need to manipulate pixel data or save images.
;; For rendering, prefer IMG_LoadTexture instead.
(define-img IMG-Load
  (_fun _string/utf-8 -> _SDL_Surface-pointer/null)
  #:c-id IMG_Load)

;; IMG_SavePNG: Save a surface to a PNG file
;; surface: the surface to save
;; file: destination path for the PNG file
;; Returns: true on success, false on failure
(define-img IMG-SavePNG
  (_fun _SDL_Surface-pointer _string/utf-8 -> _bool)
  #:c-id IMG_SavePNG)

;; IMG_SaveJPG: Save a surface to a JPG file
;; surface: the surface to save
;; file: destination path for the JPG file
;; quality: 0-100 (higher = better quality, larger file)
;; Returns: true on success, false on failure
(define-img IMG-SaveJPG
  (_fun _SDL_Surface-pointer _string/utf-8 _int -> _bool)
  #:c-id IMG_SaveJPG)
