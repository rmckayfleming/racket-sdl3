#lang racket/base

;; Raw C-style FFI bindings - direct mapping to SDL3 C API
;;
;; This module provides raw bindings to SDL3 functions with minimal abstraction.
;; Function names follow SDL3 conventions with hyphens instead of underscores
;; (e.g., SDL-Init instead of SDL_Init).
;;
;; For Racket-idiomatic wrappers with automatic resource management,
;; see the pretty.rkt module.

(require "private/lib.rkt"
         "private/types.rkt")

(provide (all-from-out "private/lib.rkt")
         (all-from-out "private/types.rkt"))

;; SDL3 FFI bindings will be added here
