#lang racket/base

;; Idiomatic Racket interface to SDL3
;;
;; This module provides a higher-level, more Racket-like interface to SDL3.
;; Features:
;; - Custodian-managed resources (automatic cleanup)
;; - Racket structs for events (works with match)
;; - Simpler APIs (no manual pointer manipulation)
;;
;; For low-level C-style bindings, use sdl3/raw instead.

(require "safe/window.rkt"
         "safe/events.rkt"
         "safe/draw.rkt")

(provide (all-from-out "safe/window.rkt")
         (all-from-out "safe/events.rkt")
         (all-from-out "safe/draw.rkt"))
