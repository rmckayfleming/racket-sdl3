#lang racket/base

;; Keyboard Input Demo
;;
;; Demonstrates two approaches to keyboard input in SDL3:
;;
;; Section 1: EVENT-DRIVEN INPUT
;; - Best for discrete actions (menus, typing, one-shot actions)
;; - Responds to key-down and key-up events
;; - Can detect key repeats
;;
;; Section 2: STATE POLLING
;; - Best for smooth, continuous input (game movement)
;; - Query keyboard state each frame
;; - No missed inputs between frames
;;
;; This demo shows both approaches working together:
;; - Event-driven: Press R/G/B to change background color (discrete action)
;; - State polling: WASD/Arrows for smooth character movement (continuous)
;;
;; Controls:
;;   R/G/B - Change background color (event-driven)
;;   WASD or Arrows - Move the square (state polling)
;;   Shift - Move faster
;;   Escape - Quit

(require racket/match
         racket/format
         sdl3)

(define window-width 800)
(define window-height 600)

;; Player state (controlled by state polling)
(define player-x 400.0)
(define player-y 300.0)
(define player-size 40.0)
(define move-speed 5.0)

;; Background color state (controlled by events)
(define bg-r 30)
(define bg-g 30)
(define bg-b 35)

;; Key press tracking for visual feedback
(define last-key-pressed "")
(define last-key-time 0)

;; Draw the player (a simple square)
(define (draw-player! renderer)
  (set-draw-color! renderer 100 200 255)
  (fill-rect! renderer
              (- player-x (/ player-size 2))
              (- player-y (/ player-size 2))
              player-size
              player-size)
  ;; Draw border
  (set-draw-color! renderer 150 230 255)
  (draw-rect! renderer
              (- player-x (/ player-size 2))
              (- player-y (/ player-size 2))
              player-size
              player-size))

;; Draw a single key indicator with label
(define (draw-key-box! renderer x y w h label pressed? color-on)
  (if pressed?
      (apply set-draw-color! renderer color-on)
      (set-draw-color! renderer 60 60 70))
  (fill-rect! renderer x y w h)
  (set-draw-color! renderer 80 80 90)
  (draw-rect! renderer x y w h)
  ;; Draw label centered in box
  (set-draw-color! renderer 200 200 200)
  (define label-x (+ x (/ (- w (* (string-length label) 8)) 2)))
  (define label-y (+ y (/ (- h 8) 2)))
  (render-debug-text! renderer label-x label-y label))

;; Draw a panel showing pressed keys (state polling)
(define (draw-pressed-keys! renderer kbd)
  ;; Background panel
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 10 280 120)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 10 280 120)

  ;; Title
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 18 "STATE POLLING (continuous)")

  ;; Draw indicator boxes for WASD
  (define wasd-y 40)
  (define wasd-x 30)
  (define key-w 35)
  (define key-h 28)
  (define gap 5)
  (define green '(100 200 100))
  (define yellow '(200 200 100))

  ;; WASD keys
  (draw-key-box! renderer (+ wasd-x key-w gap) wasd-y key-w key-h "W"
                 (kbd SDL_SCANCODE_W) green)
  (draw-key-box! renderer wasd-x (+ wasd-y key-h gap) key-w key-h "A"
                 (kbd SDL_SCANCODE_A) green)
  (draw-key-box! renderer (+ wasd-x key-w gap) (+ wasd-y key-h gap) key-w key-h "S"
                 (kbd SDL_SCANCODE_S) green)
  (draw-key-box! renderer (+ wasd-x (* 2 (+ key-w gap))) (+ wasd-y key-h gap) key-w key-h "D"
                 (kbd SDL_SCANCODE_D) green)

  ;; Arrow keys
  (define arrow-x 160)
  (draw-key-box! renderer (+ arrow-x key-w gap) wasd-y key-w key-h "^"
                 (kbd SDL_SCANCODE_UP) yellow)
  (draw-key-box! renderer arrow-x (+ wasd-y key-h gap) key-w key-h "<"
                 (kbd SDL_SCANCODE_LEFT) yellow)
  (draw-key-box! renderer (+ arrow-x key-w gap) (+ wasd-y key-h gap) key-w key-h "v"
                 (kbd SDL_SCANCODE_DOWN) yellow)
  (draw-key-box! renderer (+ arrow-x (* 2 (+ key-w gap))) (+ wasd-y key-h gap) key-w key-h ">"
                 (kbd SDL_SCANCODE_RIGHT) yellow))

;; Draw modifier state
(define (draw-mod-state! renderer)
  (define mods (get-mod-state))

  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 140 280 45)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 140 280 45)

  ;; Title
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 148 "MODIFIERS")

  (define mod-x 20)
  (define mod-y 162)
  (define box-w 60)
  (define box-h 18)
  (define gap 5)

  ;; Shift
  (draw-key-box! renderer mod-x mod-y box-w box-h "SHIFT"
                 (not (zero? (bitwise-and mods SDL_KMOD_SHIFT)))
                 '(255 200 100))

  ;; Ctrl
  (draw-key-box! renderer (+ mod-x box-w gap) mod-y box-w box-h "CTRL"
                 (not (zero? (bitwise-and mods SDL_KMOD_CTRL)))
                 '(100 200 255))

  ;; Alt
  (draw-key-box! renderer (+ mod-x (* 2 (+ box-w gap))) mod-y box-w box-h "ALT"
                 (not (zero? (bitwise-and mods SDL_KMOD_ALT)))
                 '(100 255 150))

  ;; Gui/Cmd
  (draw-key-box! renderer (+ mod-x (* 3 (+ box-w gap))) mod-y box-w box-h "CMD"
                 (not (zero? (bitwise-and mods SDL_KMOD_GUI)))
                 '(255 150 200)))

;; Draw event-driven panel (shows last key press)
(define (draw-event-panel! renderer current-time)
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer (- window-width 290) 10 280 80)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer (- window-width 290) 10 280 80)

  ;; Title
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer (- window-width 280) 18 "EVENT-DRIVEN (discrete)")

  ;; Last key
  (define age (- current-time last-key-time))
  (define alpha (max 0 (- 255 (quotient age 10))))
  (if (> alpha 50)
      (set-draw-color! renderer 255 200 100)
      (set-draw-color! renderer 100 100 100))
  (render-debug-text! renderer (- window-width 280) 40
                      (~a "Last key: " last-key-pressed))

  ;; Color instruction
  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer (- window-width 280) 60
                      "Press R/G/B to change color"))

;; Draw instructions
(define (draw-instructions! renderer)
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 10 (- window-height 110) 380 100)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 10 (- window-height 110) 380 100)

  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 (- window-height 102) "KEYBOARD INPUT DEMO")
  (set-draw-color! renderer 120 120 120)
  (render-debug-text! renderer 20 (- window-height 85) "WASD/Arrows: Move square (STATE POLLING)")
  (render-debug-text! renderer 20 (- window-height 70) "R/G/B: Change background (EVENT-DRIVEN)")
  (render-debug-text! renderer 20 (- window-height 55) "Shift: Move faster")
  (render-debug-text! renderer 20 (- window-height 40) "Escape: Quit")
  (set-draw-color! renderer 100 150 200)
  (render-debug-text! renderer 20 (- window-height 22) "State=continuous | Events=discrete actions"))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Keyboard Input Demo" window-width window-height))

  (printf "Keyboard Input Demo~n")
  (printf "===================~n")
  (printf "This demo shows two approaches to keyboard input:~n")
  (printf "~n")
  (printf "STATE POLLING (continuous input):~n")
  (printf "  WASD or Arrow keys: Move the square~n")
  (printf "  Shift: Move faster~n")
  (printf "~n")
  (printf "EVENT-DRIVEN (discrete actions):~n")
  (printf "  R/G/B: Change background color~n")
  (printf "~n")
  (printf "Escape: Quit~n~n")

  (let loop ([running? #t])
    (when running?
      ;; Get keyboard state once per frame (for polling-based input)
      (define kbd (get-keyboard-state))
      (define current-time (current-ticks))

      ;; Process events (for event-driven input)
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             #f]

            ;; Event-driven key handling
            [(key-event 'down key _ _ _)
             ;; Track last key for display
             (set! last-key-pressed (key-name key))
             (set! last-key-time current-time)

             (cond
               [(= key SDLK_ESCAPE) #f]
               ;; Event-driven color changes
               [(= key SDLK_R)
                (set! bg-r 80) (set! bg-g 30) (set! bg-b 30)
                run?]
               [(= key SDLK_G)
                (set! bg-r 30) (set! bg-g 80) (set! bg-b 30)
                run?]
               [(= key SDLK_B)
                (set! bg-r 30) (set! bg-g 30) (set! bg-b 80)
                run?]
               [else run?])]

            [_ run?])))

      (when still-running?
        ;; State polling-based movement (smooth, continuous)
        (define speed
          (if (mod-state-has? SDL_KMOD_SHIFT)
              (* move-speed 2)
              move-speed))

        (when (or (kbd SDL_SCANCODE_W) (kbd SDL_SCANCODE_UP))
          (set! player-y (max (/ player-size 2) (- player-y speed))))
        (when (or (kbd SDL_SCANCODE_S) (kbd SDL_SCANCODE_DOWN))
          (set! player-y (min (- window-height (/ player-size 2)) (+ player-y speed))))
        (when (or (kbd SDL_SCANCODE_A) (kbd SDL_SCANCODE_LEFT))
          (set! player-x (max (/ player-size 2) (- player-x speed))))
        (when (or (kbd SDL_SCANCODE_D) (kbd SDL_SCANCODE_RIGHT))
          (set! player-x (min (- window-width (/ player-size 2)) (+ player-x speed))))

        ;; Clear background (color set by events)
        (set-draw-color! renderer bg-r bg-g bg-b)
        (render-clear! renderer)

        ;; Draw everything
        (draw-player! renderer)
        (draw-pressed-keys! renderer kbd)
        (draw-mod-state! renderer)
        (draw-event-panel! renderer current-time)
        (draw-instructions! renderer)

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))

  (printf "~nDone.~n")

  ;; Clean up
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
