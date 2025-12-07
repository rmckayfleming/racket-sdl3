#lang racket/base

(require ffi/unsafe)

(provide check-sdl-bool
         _sdl-bool)

;; SDL3 types, enums, and structs
;; This file will be expanded with SDL3 type definitions as bindings are added.

;; SDL3 boolean type - SDL3 uses C99 bool (not int like SDL2)
(define _sdl-bool _bool)

;; NOTE: SDL_GetError will be defined in raw.rkt. For now, we use a forward
;; reference that will be resolved at runtime when check-sdl-bool is called.
;; The actual SDL_GetError binding must be available before check-sdl-bool is used.

;; Placeholder for SDL_GetError - will be replaced with actual FFI binding
;; This is defined here to avoid circular dependencies
(define sdl-get-error-proc (make-parameter #f))

(provide sdl-get-error-proc)

;; Check an SDL3 boolean result and raise an error if false
;; SDL3 functions return true on success, false on failure
(define (check-sdl-bool who result)
  (unless result
    (define get-error (sdl-get-error-proc))
    (define msg (if get-error
                    (get-error)
                    "SDL error (SDL_GetError not yet available)"))
    (error who "SDL error: ~a" msg))
  #t)
