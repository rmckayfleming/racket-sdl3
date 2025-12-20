#lang racket/base

;; Idiomatic high-precision timer helpers

(require ffi/unsafe/custodian
         "../raw.rkt")

(provide
 ;; Time queries
 current-ticks        ; milliseconds since init
 current-ticks-ns     ; nanoseconds since init
 current-time-ns      ; high-precision nanoseconds (using performance counter)

 ;; Delays
 delay!               ; milliseconds
 delay-ns!            ; nanoseconds
 delay-precise!       ; nanoseconds with busy-waiting

 ;; Timer callbacks
 add-timer
 add-timer-ns
 remove-timer!
 timer?
 timer-id
 timer-active?

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

;; Yield to allow async FFI callbacks (like SDL timers) to run.
(define (yield-for-callbacks)
  (sleep 0))

;; Delay for specified milliseconds
(define (delay! ms)
  (SDL-Delay ms)
  (yield-for-callbacks))

;; Delay for specified nanoseconds
(define (delay-ns! ns)
  (SDL-DelayNS ns)
  (yield-for-callbacks))

;; Delay for specified nanoseconds with busy-waiting for precision
;; More CPU-intensive but more accurate - good for frame timing
(define (delay-precise! ns)
  (SDL-DelayPrecise ns)
  (yield-for-callbacks))

;; =========================================================================
;; Timer Callbacks
;; =========================================================================

(define UINT32_MAX #xffffffff)
(define UINT64_MAX #xffffffffffffffff)

;; Keep timers reachable so callbacks are not collected while active.
(define active-timers (make-hasheq))

(struct timer ([id #:mutable] callback [active? #:mutable]) #:transparent)

(define (check-interval who interval max)
  (unless (and (integer? interval) (>= interval 0) (<= interval max))
    (error who "expected integer interval in [0, ~a], got: ~a" max interval))
  (if (exact? interval) interval (inexact->exact interval)))

(define (coerce-next-interval val max)
  (cond
    [(or (not val) (zero? val)) 0]
    [(and (integer? val) (>= val 0) (<= val max))
     (if (exact? val) val (inexact->exact val))]
    [else 0]))

(define (make-callback who proc userdata)
  (cond
    [(procedure-arity-includes? proc 3)
     (lambda (t interval) (proc t interval userdata))]
    [(procedure-arity-includes? proc 2)
     (lambda (t interval) (proc t interval))]
    [(procedure-arity-includes? proc 1)
     (lambda (_t interval) (proc interval))]
    [else
     (error who "callback must accept 1, 2, or 3 arguments, got: ~a"
            (procedure-arity proc))]))

(define (unregister-timer! t)
  (define id (timer-id t))
  (unless (zero? id)
    (hash-remove! active-timers id)))

(define (remove-timer! t)
  (unless (timer? t)
    (error 'remove-timer! "expected timer, got: ~a" t))
  (if (timer-active? t)
      (begin
        (set-timer-active?! t #f)
        (unregister-timer! t)
        (let ([id (timer-id t)])
          (if (zero? id)
              #f
              (SDL-RemoveTimer id))))
      #f))

(define (add-timer interval proc
                   #:userdata [userdata #f]
                   #:custodian [cust (current-custodian)])
  (define checked (check-interval 'add-timer interval UINT32_MAX))
  (define call-proc (make-callback 'add-timer proc userdata))
  (define timer-box (box #f))

  (define (callback _userdata _timer-id current-interval)
    (define t (unbox timer-box))
    (if (and t (timer-active? t))
        (with-handlers ([exn:fail? (lambda (_)
                                     (set-timer-active?! t #f)
                                     (unregister-timer! t)
                                     0)])
          (define next (call-proc t current-interval))
          (define next-interval (coerce-next-interval next UINT32_MAX))
          (when (= next-interval 0)
            (set-timer-active?! t #f)
            (unregister-timer! t))
          next-interval)
        0))

  (define t (timer 0 callback #t))
  (set-box! timer-box t)

  (define id (SDL-AddTimer checked callback #f))
  (when (= id 0)
    (set-timer-active?! t #f)
    (error 'add-timer "Failed to add timer: ~a" (SDL-GetError)))
  (set-timer-id! t id)
  (hash-set! active-timers id t)

  (when (not (timer-active? t))
    (SDL-RemoveTimer id))
  (when (not (timer-active? t))
    (hash-remove! active-timers id))

  (register-custodian-shutdown t remove-timer! cust #:at-exit? #t)
  t)

(define (add-timer-ns interval proc
                      #:userdata [userdata #f]
                      #:custodian [cust (current-custodian)])
  (define checked (check-interval 'add-timer-ns interval UINT64_MAX))
  (define call-proc (make-callback 'add-timer-ns proc userdata))
  (define timer-box (box #f))

  (define (callback _userdata _timer-id current-interval)
    (define t (unbox timer-box))
    (if (and t (timer-active? t))
        (with-handlers ([exn:fail? (lambda (_)
                                     (set-timer-active?! t #f)
                                     (unregister-timer! t)
                                     0)])
          (define next (call-proc t current-interval))
          (define next-interval (coerce-next-interval next UINT64_MAX))
          (when (= next-interval 0)
            (set-timer-active?! t #f)
            (unregister-timer! t))
          next-interval)
        0))

  (define t (timer 0 callback #t))
  (set-box! timer-box t)

  (define id (SDL-AddTimerNS checked callback #f))
  (when (= id 0)
    (set-timer-active?! t #f)
    (error 'add-timer-ns "Failed to add timer: ~a" (SDL-GetError)))
  (set-timer-id! t id)
  (hash-set! active-timers id t)

  (when (not (timer-active? t))
    (SDL-RemoveTimer id))
  (when (not (timer-active? t))
    (hash-remove! active-timers id))

  (register-custodian-shutdown t remove-timer! cust #:at-exit? #t)
  t)

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
