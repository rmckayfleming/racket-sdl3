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
         "../private/types.rkt"
         "../private/syntax.rkt")

(provide ;; Functions
         IMG-LoadTexture
         IMG-LoadTextureIO
         IMG-LoadTextureTypedIO
         IMG-Load
         IMG-LoadIO
         IMG-LoadTypedIO
         IMG-SavePNG
         IMG-SaveJPG
         IMG-IsAVIF
         IMG-IsICO
         IMG-IsCUR
         IMG-IsBMP
         IMG-IsGIF
         IMG-IsJPG
         IMG-IsJXL
         IMG-IsLBM
         IMG-IsPCX
         IMG-IsPNG
         IMG-IsPNM
         IMG-IsSVG
         IMG-IsQOI
         IMG-IsTIF
         IMG-IsXCF
         IMG-IsXPM
         IMG-IsXV
         IMG-IsWEBP
         IMG-Version)

;; ============================================================================
;; Library Loading
;; ============================================================================

(define sdl3-image-lib (load-sdl-library "SDL3_image"))

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

;; IMG_LoadTexture_IO: Load image from an IOStream to a GPU texture
;; renderer: the rendering context
;; src: IOStream
;; closeio: whether SDL_image should close the stream
;; Returns: texture pointer or NULL on failure
(define-img IMG-LoadTextureIO
  (_fun _SDL_Renderer-pointer _SDL_IOStream-pointer _sdl-bool -> _SDL_Texture-pointer/null)
  #:c-id IMG_LoadTexture_IO)

;; IMG_LoadTextureTyped_IO: Load image from an IOStream to a GPU texture
;; renderer: the rendering context
;; src: IOStream
;; closeio: whether SDL_image should close the stream
;; type: explicit image type hint (e.g., "PNG"), or NULL
;; Returns: texture pointer or NULL on failure
(define-img IMG-LoadTextureTypedIO
  (_fun _SDL_Renderer-pointer _SDL_IOStream-pointer _sdl-bool _string/utf-8
        -> _SDL_Texture-pointer/null)
  #:c-id IMG_LoadTextureTyped_IO)

;; IMG_Load: Load image to a software surface (CPU memory)
;; file: path to the image file
;; Returns: surface pointer, or NULL on failure (use SDL_GetError for message)
;;
;; Use this when you need to manipulate pixel data or save images.
;; For rendering, prefer IMG_LoadTexture instead.
(define-img IMG-Load
  (_fun _string/utf-8 -> _SDL_Surface-pointer/null)
  #:c-id IMG_Load)

;; IMG_Load_IO: Load image from an IOStream to a software surface
;; src: IOStream
;; closeio: whether SDL_image should close the stream
;; Returns: surface pointer or NULL on failure
(define-img IMG-LoadIO
  (_fun _SDL_IOStream-pointer _sdl-bool -> _SDL_Surface-pointer/null)
  #:c-id IMG_Load_IO)

;; IMG_LoadTyped_IO: Load image from an IOStream with an explicit type hint
;; src: IOStream
;; closeio: whether SDL_image should close the stream
;; type: explicit image type hint (e.g., "PNG"), or NULL
;; Returns: surface pointer or NULL on failure
(define-img IMG-LoadTypedIO
  (_fun _SDL_IOStream-pointer _sdl-bool _string/utf-8 -> _SDL_Surface-pointer/null)
  #:c-id IMG_LoadTyped_IO)

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

;; ============================================================================
;; Format Detection
;; ============================================================================

;; IMG_is* functions check if an IOStream matches a specific image format.

(define-img IMG-IsAVIF (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isAVIF)
(define-img IMG-IsICO (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isICO)
(define-img IMG-IsCUR (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isCUR)
(define-img IMG-IsBMP (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isBMP)
(define-img IMG-IsGIF (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isGIF)
(define-img IMG-IsJPG (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isJPG)
(define-img IMG-IsJXL (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isJXL)
(define-img IMG-IsLBM (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isLBM)
(define-img IMG-IsPCX (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isPCX)
(define-img IMG-IsPNG (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isPNG)
(define-img IMG-IsPNM (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isPNM)
(define-img IMG-IsSVG (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isSVG)
(define-img IMG-IsQOI (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isQOI)
(define-img IMG-IsTIF (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isTIF)
(define-img IMG-IsXCF (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isXCF)
(define-img IMG-IsXPM (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isXPM)
(define-img IMG-IsXV (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isXV)
(define-img IMG-IsWEBP (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id IMG_isWEBP)
