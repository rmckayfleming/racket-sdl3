#lang racket/base

;; Message Box Example - SDL3 Racket Bindings
;;
;; Demonstrates SDL3 message boxes:
;; - Simple message boxes (info, warning, error)
;; - Custom message boxes with multiple buttons
;;
;; Press keys to show different message boxes:
;; - I: Information message
;; - W: Warning message
;; - E: Error message
;; - C: Custom confirmation dialog with Yes/No/Cancel
;; - ESC/Q: Quit

(require racket/match
         sdl3)

(define window-width 640)
(define window-height 480)
(define window-title "SDL3 Racket - Message Box Demo")

(define (main)
  ;; Initialize SDL
  (sdl-init!)

  ;; Create window and renderer
  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Instructions for the user
  (printf "Message Box Demo~n")
  (printf "Press: I=Info, W=Warning, E=Error, C=Custom Dialog~n")
  (printf "Press ESC or Q to quit~n~n")

  ;; Main loop
  (let loop ()
    ;; Process events
    (define quit?
      (for/or ([ev (in-events)])
        (match ev
          [(or (quit-event) (window-event 'close-requested)) #t]
          [(key-event 'down 'escape _ _ _) #t]
          [(key-event 'down 'q _ _ _) #t]
          [(key-event 'down 'i _ _ _)
           (show-info-message window)
           #f]
          [(key-event 'down 'w _ _ _)
           (show-warning-message window)
           #f]
          [(key-event 'down 'e _ _ _)
           (show-error-message window)
           #f]
          [(key-event 'down 'c _ _ _)
           (show-custom-dialog window)
           #f]
          [_ #f])))

    (unless quit?
      ;; Clear to dark blue
      (set-draw-color! renderer 20 40 80)
      (render-clear! renderer)

      ;; Draw instructions using debug text
      (set-draw-color! renderer 255 255 255)
      (render-debug-text! renderer 20 20 "Message Box Demo")
      (render-debug-text! renderer 20 50 "Press: I=Info, W=Warning, E=Error")
      (render-debug-text! renderer 20 70 "       C=Custom Dialog")
      (render-debug-text! renderer 20 100 "ESC or Q to quit")

      ;; Present
      (render-present! renderer)

      ;; Small delay
      (delay! 16)

      (loop)))

  ;; Clean up
  (renderer-destroy! renderer)
  (window-destroy! window)
  (printf "Done!~n"))

;; Show a simple information message box
(define (show-info-message window)
  (printf "Showing info message...~n")
  (show-message-box "Information"
                    "This is an informational message.\n\nSDL3 message boxes work great!"
                    #:type 'info
                    #:window window))

;; Show a simple warning message box
(define (show-warning-message window)
  (printf "Showing warning message...~n")
  (show-message-box "Warning"
                    "This is a warning message.\n\nProceed with caution!"
                    #:type 'warning
                    #:window window))

;; Show a simple error message box
(define (show-error-message window)
  (printf "Showing error message...~n")
  (show-message-box "Error"
                    "This is an error message.\n\nSomething went wrong!"
                    #:type 'error
                    #:window window))

;; Show a custom confirmation dialog with Yes/No/Cancel buttons
(define (show-custom-dialog window)
  (printf "Showing custom dialog...~n")
  (define result
    (show-confirm-dialog "Confirm Action"
                         "Do you want to proceed?\n\nClick Yes, No, or Cancel."
                         #:buttons 'yes-no-cancel
                         #:window window))
  (printf "Dialog result: ~a~n" result))

;; Run the main function when executed directly
(module+ main
  (main))
