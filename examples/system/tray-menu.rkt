#lang racket/base

;; System Tray Menu Example
;;
;; Demonstrates tray icon creation, menus, submenus, and callbacks.
;; Use the tray icon menu to toggle items or quit.

(require sdl3)

(define (main)
  (sdl-init! '(video events))

  (define icon (load-surface "examples/assets/test.png"))
  (define tray (make-tray icon "SDL3 Tray Menu"))
  (define menu (make-tray-menu tray))

  (define feature-enabled? #t)
  (define status-entry
    (insert-tray-entry! menu "Enable Feature" #:type 'checkbox #:checked? feature-enabled?))
  (define info-entry (insert-tray-entry! menu "Print Status"))
  (insert-tray-entry! menu #f) ; separator
  (define options-entry (insert-tray-entry! menu "Options" #:type 'submenu))
  (define options-menu (make-tray-submenu options-entry))
  (define about-entry (insert-tray-entry! options-menu "About"))
  (insert-tray-entry! menu #f) ; separator
  (define quit-entry (insert-tray-entry! menu "Quit"))

  (define running? #t)

  (set-tray-entry-callback!
   status-entry
   (lambda (entry)
     (set! feature-enabled? (not feature-enabled?))
     (set-tray-entry-checked! entry feature-enabled?)
     (printf "Feature toggled: ~a~n" (if feature-enabled? "on" "off"))))

  (set-tray-entry-callback!
   info-entry
   (lambda (_entry)
     (printf "Current feature state: ~a~n"
             (if feature-enabled? "on" "off"))))

  (set-tray-entry-callback!
   about-entry
   (lambda (_entry)
     (printf "SDL3 tray menu example (Racket).~n")))

  (set-tray-entry-callback!
   quit-entry
   (lambda (_entry)
     (set! running? #f)))

  (let loop ()
    (for ([ev (in-events)])
      (void))
    (update-trays!)
    (sleep 0.05)
    (when running?
      (loop)))

  (tray-destroy! tray)
  (surface-destroy! icon)
  (sdl-quit!))

(module+ main
  (main))
