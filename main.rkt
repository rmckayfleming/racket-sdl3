#lang racket/base

;; Main entry point for sdl3 package
;; Re-exports safe, idiomatic Racket interface by default
;;
;; For low-level C-style bindings, use: (require sdl3/raw)

(require "safe.rkt")
(provide (all-from-out "safe.rkt"))
