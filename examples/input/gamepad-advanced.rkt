#lang racket/base

;; Gamepad Advanced Features Example
;;
;; Demonstrates advanced gamepad APIs:
;; - Adding custom gamepad mappings
;; - Querying and modifying mappings
;; - Sending effects to controllers (rumble)
;; - Getting all registered mappings
;;
;; Note: Custom effects require controller-specific data packets
;; and only work on certain controllers with specific drivers.
;;
;; Controls:
;; - R: Test rumble effect
;; - M: Show current gamepad mapping
;; - L: List all registered mapping count
;; - ESC / close: quit

(require racket/match
         racket/format
         ffi/unsafe
         sdl3
         sdl3/raw)

(define window-width 800)
(define window-height 500)

(define (main)
  ;; Note: SDL_INIT_JOYSTICK is required for gamepad detection on some platforms
  (sdl-init! (bitwise-ior SDL_INIT_VIDEO SDL_INIT_GAMEPAD SDL_INIT_JOYSTICK))

  (define-values (window renderer)
    (make-window+renderer "Gamepad Advanced" window-width window-height
                          #:window-flags SDL_WINDOW_HIGH_PIXEL_DENSITY))

  (define font (open-font "/System/Library/Fonts/Supplemental/Arial.ttf" 18.0))
  (define small-font (open-font "/System/Library/Fonts/Supplemental/Arial.ttf" 14.0))

  ;; Current gamepad (or #f if none)
  (define current-gamepad #f)
  (define status-message "Connect a gamepad to test advanced features")
  (define mapping-info #f)

  ;; Check for already-connected gamepads
  ;; Note: On macOS, opening a gamepad too early after SDL init can cause
  ;; events to not fire (SDL bug #8177). A short delay helps work around this.
  (delay! 100)
  (define initial-gamepads (get-gamepads))
  (when (not (null? initial-gamepads))
    (define id (car initial-gamepads))
    (set! current-gamepad (open-gamepad id))
    (set! status-message (~a "Connected: " (gamepad-name current-gamepad))))

  ;; Get the mapping string for current gamepad
  (define (update-mapping-info!)
    (when current-gamepad
      (define ptr (SDL-GetGamepadMapping (gamepad-ptr current-gamepad)))
      (if ptr
          (begin
            (set! mapping-info (cast ptr _pointer _string/utf-8))
            (SDL-free ptr))
          (set! mapping-info "No mapping available"))))

  ;; Test rumble
  (define (test-rumble!)
    (if current-gamepad
        (begin
          (set! status-message "Testing rumble...")
          ;; Full intensity rumble on both motors for 800ms
          (gamepad-rumble! current-gamepad 65535 65535 800)
          (set! status-message "Rumble sent!"))
        (set! status-message "No gamepad connected - connect one first")))

  ;; Count all mappings
  (define (show-mapping-count!)
    (define-values (arr count) (SDL-GetGamepadMappings))
    (when arr
      (SDL-free arr))
    (set! status-message (~a "Total registered mappings: " count)))

  ;; Demonstrate adding a custom mapping (this is a no-op example mapping)
  ;; Real mappings use GUID,name,button:mapping format
  (define (show-mapping-format!)
    (set! status-message
          "Mapping format: GUID,name,platform:...,a:b0,b:b1,..."))

  (let loop ([running? #t])
    (when running?
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down 'escape _ _ _) #f]
            [(key-event 'down 'r _ _ _)
             (test-rumble!) run?]
            [(key-event 'down 'm _ _ _)
             (if current-gamepad
                 (begin
                   (update-mapping-info!)
                   (set! status-message "Mapping info updated (see below)"))
                 (set! status-message "No gamepad connected - connect one first"))
             run?]
            [(key-event 'down 'l _ _ _)
             (show-mapping-count!) run?]
            [(key-event 'down 'f _ _ _)
             (show-mapping-format!) run?]

            ;; Gamepad connected (or joystick that might be a gamepad)
            ;; Note: On some platforms (macOS), only joystick events fire
            [(or (gamepad-device-event 'added which)
                 (joy-device-event 'added which))
             (when (and (not current-gamepad) (is-gamepad? which))
               (set! current-gamepad (open-gamepad which))
               (set! status-message (~a "Connected: " (gamepad-name current-gamepad)))
               (set! mapping-info #f))
             run?]

            ;; Gamepad disconnected
            [(or (gamepad-device-event 'removed which)
                 (joy-device-event 'removed which))
             (when (and current-gamepad
                        (= (gamepad-id current-gamepad) which))
               (gamepad-destroy! current-gamepad)
               (set! current-gamepad #f)
               (set! status-message "Gamepad disconnected")
               (set! mapping-info #f)
               ;; Try to open another
               (define remaining (get-gamepads))
               (unless (null? remaining)
                 (set! current-gamepad (open-gamepad (car remaining)))
                 (set! status-message (~a "Switched to: " (gamepad-name current-gamepad)))))
             run?]

            [_ run?])))

      (when still-running?
        (set-draw-color! renderer 30 30 40)
        (render-clear! renderer)

        ;; Title
        (draw-text! renderer font "Gamepad Advanced Features" 30 20 '(255 255 255 255))

        ;; Status
        (draw-text! renderer small-font status-message 30 60 '(200 200 200 255))

        ;; Controls
        (draw-text! renderer small-font "Controls:" 30 100 '(150 200 255 255))
        (draw-text! renderer small-font "R - Test rumble effect" 50 125 '(200 200 200 255))
        (draw-text! renderer small-font "M - Show gamepad mapping" 50 145 '(200 200 200 255))
        (draw-text! renderer small-font "L - List mapping count" 50 165 '(200 200 200 255))
        (draw-text! renderer small-font "F - Show mapping format" 50 185 '(200 200 200 255))

        ;; Gamepad info or "no gamepad" message
        (if current-gamepad
            (begin
              (draw-text! renderer small-font "Gamepad Info:" 30 220 '(150 200 255 255))
              (draw-text! renderer small-font
                          (~a "Name: " (gamepad-name current-gamepad))
                          50 245 '(200 200 200 255))
              (draw-text! renderer small-font
                          (~a "Type: " (gamepad-type current-gamepad))
                          50 265 '(200 200 200 255))
              (draw-text! renderer small-font
                          (~a "ID: " (gamepad-id current-gamepad))
                          50 285 '(200 200 200 255)))
            (begin
              (draw-text! renderer font "No Gamepad Connected" 30 240 '(255 180 100 255))
              (draw-text! renderer small-font
                          "Please connect an Xbox, PlayStation, or Switch controller"
                          30 275 '(180 180 180 255))))

        ;; Mapping info (word-wrapped display)
        (when mapping-info
          (draw-text! renderer small-font "Current Mapping:" 30 320 '(150 200 255 255))
          ;; Split long mapping into chunks for display
          (define max-chars 80)
          (define lines
            (for/list ([i (in-range 0 (string-length mapping-info) max-chars)])
              (substring mapping-info i (min (+ i max-chars) (string-length mapping-info)))))
          (for ([line (in-list lines)]
                [y (in-naturals)])
            (draw-text! renderer small-font line 50 (+ 345 (* y 18)) '(180 180 180 255))))

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))

  ;; Cleanup
  (when current-gamepad
    (gamepad-destroy! current-gamepad))
  (close-font! small-font)
  (close-font! font)
  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
