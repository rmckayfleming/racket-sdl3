#lang racket/base

;; Basic drawing operations for the renderer

(require ffi/unsafe
         "../raw.rkt"
         "window.rkt")

(provide
 ;; Color
 set-draw-color!

 ;; Basic rendering
 render-clear!
 render-present!

 ;; Timer
 delay!)

;; ============================================================================
;; Color
;; ============================================================================

(define (set-draw-color! rend r g b [a 255])
  (SDL-SetRenderDrawColor (renderer-ptr rend) r g b a))

;; ============================================================================
;; Basic Rendering
;; ============================================================================

(define (render-clear! rend)
  (SDL-RenderClear (renderer-ptr rend)))

(define (render-present! rend)
  (SDL-RenderPresent (renderer-ptr rend)))

;; ============================================================================
;; Timer
;; ============================================================================

(define (delay! ms)
  (SDL-Delay ms))
