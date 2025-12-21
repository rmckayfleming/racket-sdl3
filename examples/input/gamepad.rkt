#lang racket

;; Gamepad Input Example
;;
;; This example demonstrates gamepad support:
;; - Detecting connected gamepads
;; - Handling hot-plug events (connect/disconnect)
;; - Reading button and axis states
;; - Visual display of controller state
;;
;; Connect a gamepad (Xbox, PlayStation, or Switch Pro controller) and
;; watch the visual representation update in real-time.
;;
;; Controls:
;; - Escape: Exit
;; - Connect/disconnect gamepads to see hot-plug events
;; - Press any button to feel haptic feedback (rumble)

(require sdl3)

;; Initialize SDL with gamepad support
;; Note: SDL_INIT_JOYSTICK is required for gamepad detection on some platforms
(sdl-init! (bitwise-ior SDL_INIT_VIDEO SDL_INIT_GAMEPAD SDL_INIT_JOYSTICK))

(define WIDTH 800)
(define HEIGHT 600)

(define-values (win ren) (make-window+renderer "Gamepad Test" WIDTH HEIGHT))

;; Current gamepad (or #f if none connected)
(define current-gamepad #f)

;; Helper to draw a filled circle (approximated with many small rects)
(define (draw-circle ren cx cy radius)
  (for ([y (in-range (- cy radius) (+ cy radius))])
    (define dy (- y cy))
    (define dx (inexact->exact (floor (sqrt (- (* radius radius) (* dy dy))))))
    (fill-rect! ren (- cx dx) y (* 2 dx) 1)))

;; Draw stick position indicator
(define (draw-stick ren cx cy raw-x raw-y [deadzone 8000])
  ;; Draw base circle (dark)
  (set-draw-color! ren 60 60 60)
  (draw-circle ren cx cy 60)

  ;; Calculate position (apply deadzone)
  (define x (if (< (abs raw-x) deadzone) 0 raw-x))
  (define y (if (< (abs raw-y) deadzone) 0 raw-y))

  ;; Map to screen space (-60 to 60 pixels from center)
  (define px (+ cx (quotient (* x 60) 32768)))
  (define py (+ cy (quotient (* y 60) 32768)))

  ;; Draw indicator
  (set-draw-color! ren 100 200 255)
  (draw-circle ren px py 15))

;; Draw trigger bar
(define (draw-trigger ren x y width value label)
  ;; Background
  (set-draw-color! ren 60 60 60)
  (fill-rect! ren x y width 30)

  ;; Fill based on value (0-32767)
  (define fill-width (quotient (* value width) 32767))
  (set-draw-color! ren 100 255 100)
  (fill-rect! ren x y fill-width 30))

;; Draw button indicator
(define (draw-button ren x y pressed? label [size 30])
  (if pressed?
      (set-draw-color! ren 255 100 100)
      (set-draw-color! ren 60 60 60))
  (draw-circle ren x y (quotient size 2)))

;; Draw D-pad
(define (draw-dpad ren cx cy up? down? left? right?)
  (define size 25)
  (define gap 30)

  ;; Up
  (if up?
      (set-draw-color! ren 255 100 100)
      (set-draw-color! ren 60 60 60))
  (fill-rect! ren (- cx (quotient size 2)) (- cy gap size) size size)

  ;; Down
  (if down?
      (set-draw-color! ren 255 100 100)
      (set-draw-color! ren 60 60 60))
  (fill-rect! ren (- cx (quotient size 2)) (+ cy gap) size size)

  ;; Left
  (if left?
      (set-draw-color! ren 255 100 100)
      (set-draw-color! ren 60 60 60))
  (fill-rect! ren (- cx gap size) (- cy (quotient size 2)) size size)

  ;; Right
  (if right?
      (set-draw-color! ren 255 100 100)
      (set-draw-color! ren 60 60 60))
  (fill-rect! ren (+ cx gap) (- cy (quotient size 2)) size size))

;; Draw face buttons (A/B/X/Y layout)
(define (draw-face-buttons ren cx cy south? east? west? north?)
  (define gap 35)
  (draw-button ren cx (+ cy gap) south? "A")  ; South (A/Cross)
  (draw-button ren (+ cx gap) cy east? "B")   ; East (B/Circle)
  (draw-button ren (- cx gap) cy west? "X")   ; West (X/Square)
  (draw-button ren cx (- cy gap) north? "Y")) ; North (Y/Triangle)

(define (render-gamepad-state gp)
  ;; Get axis values
  (define lx (gamepad-axis gp 'left-x))
  (define ly (gamepad-axis gp 'left-y))
  (define rx (gamepad-axis gp 'right-x))
  (define ry (gamepad-axis gp 'right-y))
  (define lt (gamepad-axis gp 'left-trigger))
  (define rt (gamepad-axis gp 'right-trigger))

  ;; Get button states
  (define btn-south (gamepad-button gp 'south))
  (define btn-east (gamepad-button gp 'east))
  (define btn-west (gamepad-button gp 'west))
  (define btn-north (gamepad-button gp 'north))
  (define btn-back (gamepad-button gp 'back))
  (define btn-start (gamepad-button gp 'start))
  (define btn-guide (gamepad-button gp 'guide))
  (define btn-lb (gamepad-button gp 'left-shoulder))
  (define btn-rb (gamepad-button gp 'right-shoulder))
  (define btn-ls (gamepad-button gp 'left-stick))
  (define btn-rs (gamepad-button gp 'right-stick))
  (define dpad-up (gamepad-button gp 'dpad-up))
  (define dpad-down (gamepad-button gp 'dpad-down))
  (define dpad-left (gamepad-button gp 'dpad-left))
  (define dpad-right (gamepad-button gp 'dpad-right))

  ;; Draw triggers (top)
  (draw-trigger ren 100 50 150 lt "LT")
  (draw-trigger ren 550 50 150 rt "RT")

  ;; Draw shoulder buttons
  (draw-button ren 175 100 btn-lb "LB" 40)
  (draw-button ren 625 100 btn-rb "RB" 40)

  ;; Draw left stick
  (draw-stick ren 200 300 lx ly)
  (when btn-ls
    (set-draw-color! ren 255 255 0)
    (draw-circle ren 200 300 5))

  ;; Draw right stick
  (draw-stick ren 600 300 rx ry)
  (when btn-rs
    (set-draw-color! ren 255 255 0)
    (draw-circle ren 600 300 5))

  ;; Draw D-pad
  (draw-dpad ren 200 450 dpad-up dpad-down dpad-left dpad-right)

  ;; Draw face buttons
  (draw-face-buttons ren 600 450 btn-south btn-east btn-west btn-north)

  ;; Draw center buttons (back, guide, start)
  (draw-button ren 350 200 btn-back "Back" 25)
  (draw-button ren 400 200 btn-guide "Guide" 30)
  (draw-button ren 450 200 btn-start "Start" 25))

(define (render-no-gamepad)
  ;; Show waiting message
  (set-draw-color! ren 100 100 100)
  (fill-rect! ren 200 250 400 100)
  (set-draw-color! ren 200 200 200)
  (fill-rect! ren 202 252 396 96))

(define running? #t)

(printf "Gamepad Test - Connect a controller~n")
(printf "Press Escape to exit~n~n")

;; Check for already-connected gamepads
;; Note: On macOS, opening a gamepad too early after SDL init can cause
;; events to not fire (SDL bug #8177). A short delay helps work around this.
(delay! 100)
(define initial-gamepads (get-gamepads))
(when (not (null? initial-gamepads))
  (define id (car initial-gamepads))
  (printf "Found gamepad: ~a~n" (get-gamepad-name-for-id id))
  (set! current-gamepad (open-gamepad id)))

(let loop ()
  ;; Process events
  (for ([e (in-events)])
    (match e
      [(quit-event)
       (set! running? #f)]

      [(key-event 'down (== (symbol->keycode 'escape)) _ _ _)
       (set! running? #f)]

      ;; Gamepad connected (or joystick that might be a gamepad)
      ;; Note: On some platforms (macOS), only joystick events fire, not gamepad events
      [(or (gamepad-device-event 'added which)
           (joy-device-event 'added which))
       (when (is-gamepad? which)
         (printf "Gamepad connected: ~a (id: ~a)~n"
                 (get-gamepad-name-for-id which) which)
         (unless current-gamepad
           (set! current-gamepad (open-gamepad which))
           (printf "Opened gamepad: ~a (type: ~a)~n"
                   (gamepad-name current-gamepad)
                   (gamepad-type current-gamepad))))]

      ;; Gamepad disconnected
      [(or (gamepad-device-event 'removed which)
           (joy-device-event 'removed which))
       (when (and current-gamepad
                  (= (gamepad-id current-gamepad) which))
         (printf "Gamepad disconnected (id: ~a)~n" which)
         (gamepad-destroy! current-gamepad)
         (set! current-gamepad #f)
         ;; Try to open another gamepad if available
         (define remaining (get-gamepads))
         (unless (null? remaining)
           (set! current-gamepad (open-gamepad (car remaining)))
           (printf "Switched to: ~a~n" (gamepad-name current-gamepad))))]

      ;; Button events - rumble on press
      ;; Note: On some platforms, only joystick button events fire (not gamepad events)
      ;; We handle both and use the gamepad API for button name mapping
      [(gamepad-button-event type which button)
       (printf "Button ~a: ~a~n" button type)
       (when (and current-gamepad (eq? type 'down))
         (gamepad-rumble! current-gamepad 40000 40000 100))]

      [(joy-button-event type which button-num)
       ;; Only handle if this joystick is our current gamepad
       (when (and current-gamepad (= (gamepad-id current-gamepad) which))
         (printf "Button ~a: ~a~n" button-num type)
         (when (eq? type 'down)
           (gamepad-rumble! current-gamepad 40000 40000 100)))]

      [_ (void)]))

  ;; Clear screen
  (set-draw-color! ren 30 30 40)
  (render-clear! ren)

  ;; Render gamepad state or waiting message
  (if current-gamepad
      (render-gamepad-state current-gamepad)
      (render-no-gamepad))

  ;; Present
  (render-present! ren)

  ;; Small delay to avoid burning CPU
  (delay! 16)

  (when running?
    (loop)))

;; Cleanup
(when current-gamepad
  (gamepad-destroy! current-gamepad))
(printf "Done!~n")
