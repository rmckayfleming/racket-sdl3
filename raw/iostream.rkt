#lang racket/base

;; SDL3 IOStream Functions
;;
;; Functions for creating and closing SDL_IOStream instances.

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide SDL-IOFromFile
         SDL-IOFromMem
         SDL-IOFromConstMem
         SDL-CloseIO)

;; ============================================================================
;; IOStream
;; ============================================================================

;; SDL_IOFromFile: Open a file as an IOStream
;; file: path to the file
;; mode: fopen-style mode string (e.g., "rb")
;; Returns: IOStream pointer or NULL on failure
(define-sdl SDL-IOFromFile
  (_fun _string/utf-8 _string/utf-8 -> _SDL_IOStream-pointer/null)
  #:c-id SDL_IOFromFile)

;; SDL_IOFromMem: Create an IOStream from a memory buffer
;; mem: pointer to memory buffer
;; size: size of buffer in bytes
;; Returns: IOStream pointer or NULL on failure
(define-sdl SDL-IOFromMem
  (_fun _pointer _size -> _SDL_IOStream-pointer/null)
  #:c-id SDL_IOFromMem)

;; SDL_IOFromConstMem: Create a read-only IOStream from a memory buffer
;; mem: pointer to memory buffer
;; size: size of buffer in bytes
;; Returns: IOStream pointer or NULL on failure
(define-sdl SDL-IOFromConstMem
  (_fun _pointer _size -> _SDL_IOStream-pointer/null)
  #:c-id SDL_IOFromConstMem)

;; SDL_CloseIO: Close and destroy an IOStream
;; stream: IOStream pointer
;; Returns: true on success, false on failure
(define-sdl SDL-CloseIO
  (_fun _SDL_IOStream-pointer -> _sdl-bool)
  #:c-id SDL_CloseIO)
