#lang racket/base

;; Racket-idiomatic wrappers with automatic resource management
;;
;; This module provides higher-level wrappers around SDL3 functions that:
;; - Use Racket naming conventions
;; - Provide automatic resource management (e.g., custodians, finalizers)
;; - Convert SDL3 errors to Racket exceptions
;; - Use Racket data structures where appropriate
;;
;; For direct access to the C API, see the raw.rkt module.

(require "private/lib.rkt"
         "private/types.rkt")

;; Racket-idiomatic wrappers will be added here
