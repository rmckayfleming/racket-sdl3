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
         "safe/draw.rkt"
         "safe/texture.rkt"
         "safe/ttf.rkt"
         "safe/mouse.rkt"
         "safe/clipboard.rkt"
         "safe/timer.rkt")

(provide (all-from-out "safe/window.rkt")
         (all-from-out "safe/events.rkt")
         (all-from-out "safe/draw.rkt")
         (all-from-out "safe/texture.rkt")
         (all-from-out "safe/ttf.rkt")
         (all-from-out "safe/mouse.rkt")
         (all-from-out "safe/clipboard.rkt")
         (all-from-out "safe/timer.rkt"))
