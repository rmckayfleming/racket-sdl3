#lang racket/base

;; Timer diagnostics - measure callback jitter and delays.
;; Usage:
;;   racket examples/animation/timer-diagnostics.rkt
;;   racket examples/animation/timer-diagnostics.rkt --mode sdl-delay
;;   racket examples/animation/timer-diagnostics.rkt --mode wait-event

(require racket/cmdline
         sdl3)

(define interval-ms 100)
(define sample-count 20)
(define mode 'sleep) ; sleep | sdl-delay | wait-event

(command-line
 #:once-each
 [("--mode") mode-str "sleep | sdl-delay | wait-event"
  (set! mode (string->symbol mode-str))]
 [("--interval") ms "Interval in milliseconds"
  (set! interval-ms (string->number ms))]
 [("--samples") count "Number of samples"
  (set! sample-count (string->number count))])

(unless (member mode '(sleep sdl-delay wait-event))
  (error 'timer-diagnostics "unknown mode: ~a" mode))

(define (idle-step)
  (case mode
    [(sleep) (sleep 0.01)]
    [(sdl-delay) (delay! 10)]
    [(wait-event) (wait-event-timeout 10)]))

(define (ns->ms ns)
  (/ ns 1000000.0))

(define (summarize-intervals intervals)
  (define count (length intervals))
  (define min-val (apply min intervals))
  (define max-val (apply max intervals))
  (define avg-val (/ (apply + intervals) count))
  (values min-val avg-val max-val))

(define (main)
  (sdl-init!)

  (define times (make-vector sample-count #f))
  (define index-box (box 0))
  (define done-sema (make-semaphore 0))

  (define timer
    (add-timer interval-ms
               (lambda (_timer interval)
                 (define i (unbox index-box))
                 (if (< i sample-count)
                     (let* ([next-i (add1 i)]
                            [done? (= next-i sample-count)])
                       (vector-set! times i (current-ticks-ns))
                       (set-box! index-box next-i)
                       (when done?
                         (semaphore-post done-sema))
                       (if done? 0 interval))
                     0))))

  (let loop ()
    (unless (semaphore-try-wait? done-sema)
      (idle-step)
      (loop)))

  (remove-timer! timer)

  (define intervals
    (for/list ([i (in-range 1 sample-count)])
      (- (vector-ref times i) (vector-ref times (sub1 i)))))

  (define intervals-ms (map ns->ms intervals))
  (define-values (min-ms avg-ms max-ms) (summarize-intervals intervals-ms))

  (printf "mode: ~a, interval: ~a ms, samples: ~a~n" mode interval-ms sample-count)
  (printf "min: ~a ms, avg: ~a ms, max: ~a ms~n" min-ms avg-ms max-ms)

  (sdl-quit!))

(module+ main
  (main))
