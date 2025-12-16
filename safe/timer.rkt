#lang racket/base

;; Idiomatic high-precision timer helpers

(require "../raw.rkt")

(provide
 ;; Time queries
 current-ticks        ; milliseconds since init
 current-ticks-ns     ; nanoseconds since init
 current-time-ns      ; high-precision nanoseconds (using performance counter)

 ;; Delays
 delay!               ; milliseconds
 delay-ns!            ; nanoseconds
 delay-precise!       ; nanoseconds with busy-waiting

 ;; Performance counter (for advanced timing)
 performance-counter
 performance-frequency

 ;; Timing utilities
 with-timing          ; measure elapsed time of body

 ;; Time unit constants
 NS_PER_SECOND
 NS_PER_MS
 NS_PER_US
 MS_PER_SECOND)

;; =========================================================================
;; Time Unit Constants
;; =========================================================================

(define NS_PER_SECOND 1000000000)
(define NS_PER_MS 1000000)
(define NS_PER_US 1000)
(define MS_PER_SECOND 1000)

;; =========================================================================
;; Time Queries
;; =========================================================================

;; Get milliseconds since SDL initialization
(define (current-ticks)
  (SDL-GetTicks))

;; Get nanoseconds since SDL initialization
(define (current-ticks-ns)
  (SDL-GetTicksNS))

;; Get high-precision time in nanoseconds using performance counter
;; More accurate than current-ticks-ns for profiling
(define (current-time-ns)
  (define counter (SDL-GetPerformanceCounter))
  (define freq (SDL-GetPerformanceFrequency))
  ;; Convert to nanoseconds: counter * 1e9 / freq
  ;; Use exact arithmetic to avoid floating point precision issues
  (quotient (* counter NS_PER_SECOND) freq))

;; =========================================================================
;; Performance Counter (Advanced)
;; =========================================================================

;; Get raw performance counter value
;; Values are only meaningful relative to each other
(define (performance-counter)
  (SDL-GetPerformanceCounter))

;; Get performance counter frequency (counts per second)
(define (performance-frequency)
  (SDL-GetPerformanceFrequency))

;; =========================================================================
;; Delays
;; =========================================================================

;; Delay for specified milliseconds
(define (delay! ms)
  (SDL-Delay ms))

;; Delay for specified nanoseconds
(define (delay-ns! ns)
  (SDL-DelayNS ns))

;; Delay for specified nanoseconds with busy-waiting for precision
;; More CPU-intensive but more accurate - good for frame timing
(define (delay-precise! ns)
  (SDL-DelayPrecise ns))

;; =========================================================================
;; Timing Utilities
;; =========================================================================

;; Execute body and return (values result elapsed-ns)
;; Uses high-precision performance counter
(define-syntax-rule (with-timing body ...)
  (let ([start (SDL-GetPerformanceCounter)])
    (define result (begin body ...))
    (define end (SDL-GetPerformanceCounter))
    (define freq (SDL-GetPerformanceFrequency))
    (define elapsed-ns (quotient (* (- end start) NS_PER_SECOND) freq))
    (values result elapsed-ns)))
