#lang racket/base

;; SDL3 Hints API Demo
;;
;; Demonstrates the SDL hints system for configuring SDL behavior.
;; Hints are configuration variables that can be set before or during
;; SDL initialization to customize behavior.
;;
;; This example shows:
;;   - Setting app name and ID hints
;;   - Querying current hint values
;;   - Toggling vsync via hints
;;   - Checking screensaver settings
;;
;; Controls:
;;   V - Toggle vsync hint
;;   S - Toggle screensaver allowed
;;   R - Reset all hints to defaults
;;   ESC - Quit

(require racket/match
         racket/format
         sdl3)

(define window-width 800)
(define window-height 500)
(define window-title "SDL3 Hints Demo")

(define font-path "/System/Library/Fonts/Supplemental/Arial.ttf")
(define base-font-size 16.0)

(define (main)
  ;; Set app name and ID hints BEFORE initializing SDL
  ;; These are used by the OS for audio controls, taskbar, etc.
  (set-app-name! "SDL3 Hints Demo")
  (set-app-id! "com.example.hints-demo")

  ;; We can also check if hints are set
  (printf "App name hint: ~a~n" (or (get-hint 'app-name) "(not set)"))
  (printf "App ID hint: ~a~n" (or (get-hint 'app-id) "(not set)"))

  ;; Initialize SDL
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height
                          #:window-flags 'resizable))

  ;; Scale font for high-DPI
  (define pixel-density (window-pixel-density window))
  (define font-size (* base-font-size pixel-density))
  (define font (open-font font-path font-size))

  (let loop ([running? #t]
             [vsync? #f]
             [screensaver-allowed? #t])
    (when running?
      ;; Handle events
      (define-values (still-running? new-vsync? new-ss?)
        (for/fold ([run? #t]
                   [vs? vsync?]
                   [ss? screensaver-allowed?])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values #f vs? ss?)]

            [(key-event 'down 'escape _ _ _) (values #f vs? ss?)]

            [(key-event 'down 'v _ _ _)
             (define new-vs? (not vs?))
             (set-hint! 'render-vsync (if new-vs? "1" "0"))
             (printf "VSync hint set to: ~a~n" (if new-vs? "1" "0"))
             (values run? new-vs? ss?)]

            [(key-event 'down 's _ _ _)
             (define new-ss? (not ss?))
             (allow-screensaver! new-ss?)
             (printf "Screensaver allowed: ~a~n" new-ss?)
             (values run? vs? new-ss?)]

            [(key-event 'down 'r _ _ _)
             (reset-all-hints!)
             (printf "All hints reset to defaults~n")
             (values run? #f #t)]

            [_ (values run? vs? ss?)])))

      (when still-running?
        ;; Get current window size for layout
        (define-values (win-w win-h) (window-size window))

        ;; Clear to dark background
        (set-draw-color! renderer 30 30 40)
        (render-clear! renderer)

        ;; Title
        (draw-text! renderer font "SDL3 Hints Demo"
                    20 20 '(255 255 255 255))

        ;; Controls
        (draw-text! renderer font "V=Toggle VSync | S=Toggle Screensaver | R=Reset All | ESC=Quit"
                    20 50 '(150 150 150 255))

        ;; Separator
        (set-draw-color! renderer 100 100 120)
        (fill-rect! renderer 20 80 (- win-w 40) 2)

        ;; Current hint values section
        (draw-text! renderer font "Current Hint Values:"
                    20 100 '(200 200 255 255))

        ;; App name
        (define app-name-val (or (get-hint 'app-name) "(not set)"))
        (draw-text! renderer font (format "  App Name: ~a" app-name-val)
                    20 130 '(180 255 180 255))

        ;; App ID
        (define app-id-val (or (get-hint 'app-id) "(not set)"))
        (draw-text! renderer font (format "  App ID: ~a" app-id-val)
                    20 155 '(180 255 180 255))

        ;; VSync
        (define vsync-val (or (get-hint 'render-vsync) "(not set)"))
        (define vsync-bool (get-hint-boolean 'render-vsync #f))
        (draw-text! renderer font (format "  Render VSync: ~a (boolean: ~a)"
                                          vsync-val vsync-bool)
                    20 180 '(255 255 180 255))

        ;; Screensaver
        (define ss-val (or (get-hint 'video-allow-screensaver) "(not set)"))
        (define ss-bool (get-hint-boolean 'video-allow-screensaver #t))
        (draw-text! renderer font (format "  Allow Screensaver: ~a (boolean: ~a)"
                                          ss-val ss-bool)
                    20 205 '(255 255 180 255))

        ;; Render driver
        (define driver-val (or (get-hint 'render-driver) "(auto)"))
        (draw-text! renderer font (format "  Render Driver: ~a" driver-val)
                    20 230 '(180 180 255 255))

        ;; Separator
        (fill-rect! renderer 20 260 (- win-w 40) 2)

        ;; Status section
        (draw-text! renderer font "Local State:"
                    20 280 '(200 200 255 255))

        (draw-text! renderer font (format "  VSync enabled: ~a" (if new-vsync? "YES" "no"))
                    20 310 '(255 200 150 255))

        (draw-text! renderer font (format "  Screensaver allowed: ~a" (if new-ss? "YES" "no"))
                    20 335 '(255 200 150 255))

        ;; Notes
        (set-draw-color! renderer 80 80 100)
        (fill-rect! renderer 20 370 (- win-w 40) 2)

        (draw-text! renderer font "Notes:"
                    20 390 '(150 150 200 255))

        (draw-text! renderer font "- App Name/ID should be set BEFORE SDL_Init for best effect"
                    20 415 '(120 120 150 255))

        (draw-text! renderer font "- VSync changes may require recreating the renderer"
                    20 440 '(120 120 150 255))

        (draw-text! renderer font "- Hints are just suggestions; they may be ignored by SDL"
                    20 465 '(120 120 150 255))

        (render-present! renderer)
        (delay! 16)

        (loop still-running? new-vsync? new-ss?))))

  (close-font! font)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run the example when executed directly
(module+ main
  (main))
