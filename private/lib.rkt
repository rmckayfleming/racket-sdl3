#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)

(provide define-sdl
         sdl-lib)

;; Load the SDL3 library with version fallbacks
(define sdl-lib
  (ffi-lib "libSDL3" '("0" #f)))

;; Define the FFI definer for SDL3 functions
;; - Uses hyphen-to-underscore conversion (e.g., SDL-Init -> SDL_Init)
;; - Provides graceful failure for unavailable functions
(define-ffi-definer define-sdl sdl-lib
  #:make-c-id convention:hyphen->underscore
  #:default-make-fail make-not-available)
