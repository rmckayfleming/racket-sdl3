#lang racket/base

;; Keyboard and mouse enumeration
;;
;; Prints connected device IDs and names. Close the window or press Escape to exit.

(require racket/match
         sdl3)

(define (print-device-list label ids name-for-id)
  (printf "~a (~a):~n" label (length ids))
  (for ([id (in-list ids)]
        [idx (in-naturals 1)])
    (define name (name-for-id id))
    (define display-name
      (if (and name (not (string=? name "")))
          name
          "<unnamed>"))
    (printf "  ~a: ~a (id ~a)~n" idx display-name id)))

(define (main)
  (sdl-init! SDL_INIT_VIDEO)
  (define win (make-window "SDL3 Racket - Device Enumeration" 640 360))

  (printf "Has keyboard? ~a~n" (has-keyboard?))
  (printf "Has mouse? ~a~n" (has-mouse?))
  (print-device-list "Keyboards" (get-keyboards) get-keyboard-name-for-id)
  (print-device-list "Mice" (get-mice) get-mouse-name-for-id)
  (printf "Keyboard focus window: ~a~n"
          (if (get-keyboard-focus) "present" "none"))
  (printf "Mouse focus window: ~a~n"
          (if (get-mouse-focus) "present" "none"))
  (printf "Close the window or press Escape to quit.~n")

  (let loop ()
    (define running?
      (for/fold ([run? #t])
                ([e (in-events)]
                 #:break (not run?))
        (match e
          [(quit-event) #f]
          [(key-event 'down 'escape _ _ _) #f]
          [(key-event 'down _ _ _ _) run?]
          [_ run?])))
    (when running?
      (delay! 16)
      (loop)))

  (window-destroy! win)
  (sdl-quit!))

(module+ main
  (main))
