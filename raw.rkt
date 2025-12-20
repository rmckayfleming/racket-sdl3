#lang racket/base

;; Raw C-style FFI bindings - direct mapping to SDL3 C API
;;
;; This module provides raw bindings to SDL3 functions with minimal abstraction.
;; Function names follow SDL3 conventions with hyphens instead of underscores
;; (e.g., SDL-Init instead of SDL_Init).
;;
;; For Racket-idiomatic wrappers with automatic resource management,
;; see the safe.rkt module (or just require sdl3).

(require "private/lib.rkt"
         "private/types.rkt"
         "private/constants.rkt"
         "private/enums.rkt"
         "raw/init.rkt"
         "raw/window.rkt"
         "raw/render.rkt"
         "raw/texture.rkt"
         "raw/surface.rkt"
         "raw/events.rkt"
         "raw/keyboard.rkt"
         "raw/mouse.rkt"
         "raw/joystick.rkt"
         "raw/gamepad.rkt"
         "raw/display.rkt"
         "raw/iostream.rkt"
         "raw/properties.rkt"
         "raw/timer.rkt"
         "raw/clipboard.rkt"
         "raw/audio.rkt"
         "raw/dialog.rkt"
         "raw/hints.rkt"
         "raw/image.rkt"
         "raw/ttf.rkt")

(provide (all-from-out "private/lib.rkt")
         (all-from-out "private/types.rkt")
         (all-from-out "private/constants.rkt")
         (all-from-out "private/enums.rkt")
         (all-from-out "raw/init.rkt")
         (all-from-out "raw/window.rkt")
         (all-from-out "raw/render.rkt")
         (all-from-out "raw/texture.rkt")
         (all-from-out "raw/surface.rkt")
         (all-from-out "raw/events.rkt")
         (all-from-out "raw/keyboard.rkt")
         (all-from-out "raw/mouse.rkt")
         (all-from-out "raw/joystick.rkt")
         (all-from-out "raw/gamepad.rkt")
         (all-from-out "raw/display.rkt")
         (all-from-out "raw/iostream.rkt")
         (all-from-out "raw/properties.rkt")
         (all-from-out "raw/timer.rkt")
         (all-from-out "raw/clipboard.rkt")
         (all-from-out "raw/audio.rkt")
         (all-from-out "raw/dialog.rkt")
         (all-from-out "raw/hints.rkt")
         (all-from-out "raw/image.rkt")
         (all-from-out "raw/ttf.rkt"))
