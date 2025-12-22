#lang racket/base

;; Comprehensive Keyboard Demo
;;
;; Displays a virtual keyboard and highlights keys as they're pressed.
;; Shows keycode, scancode, key name, and active modifiers.
;;
;; Press Escape to quit.

(require racket/match
         sdl3)

(define window-width 800)
(define window-height 500)

;; Track pressed keys (keycodes -> #t)
(define pressed-keys (make-hash))

;; Last key event info
(define last-key #f)
(define last-scancode #f)
(define last-key-name "")
(define last-mod 0)

;; Key layout for virtual keyboard display
;; Each row is a list of (key-symbol display-label width)
(define keyboard-layout
  (list
   ;; Row 1: Escape and Function keys
   (list (list 'escape "Esc" 1.5)
         (list #f #f 0.5)  ; gap
         (list 'f1 "F1" 1) (list 'f2 "F2" 1) (list 'f3 "F3" 1) (list 'f4 "F4" 1)
         (list #f #f 0.5)
         (list 'f5 "F5" 1) (list 'f6 "F6" 1) (list 'f7 "F7" 1) (list 'f8 "F8" 1)
         (list #f #f 0.5)
         (list 'f9 "F9" 1) (list 'f10 "F10" 1) (list 'f11 "F11" 1) (list 'f12 "F12" 1))
   ;; Row 2: Numbers
   (list (list '1 "1" 1) (list '2 "2" 1) (list '3 "3" 1) (list '4 "4" 1) (list '5 "5" 1)
         (list '6 "6" 1) (list '7 "7" 1) (list '8 "8" 1) (list '9 "9" 1) (list '0 "0" 1)
         (list 'backspace "Back" 2))
   ;; Row 3: QWERTY top row
   (list (list 'tab "Tab" 1.5)
         (list 'q "Q" 1) (list 'w "W" 1) (list 'e "E" 1) (list 'r "R" 1) (list 't "T" 1)
         (list 'y "Y" 1) (list 'u "U" 1) (list 'i "I" 1) (list 'o "O" 1) (list 'p "P" 1))
   ;; Row 4: ASDF row
   (list (list #f "Caps" 1.75)  ; Caps lock - not tracking
         (list 'a "A" 1) (list 's "S" 1) (list 'd "D" 1) (list 'f "F" 1) (list 'g "G" 1)
         (list 'h "H" 1) (list 'j "J" 1) (list 'k "K" 1) (list 'l "L" 1)
         (list 'return "Enter" 1.75))
   ;; Row 5: ZXCV row
   (list (list #f "Shift" 2.25)  ; Shift - shown in modifier display
         (list 'z "Z" 1) (list 'x "X" 1) (list 'c "C" 1) (list 'v "V" 1) (list 'b "B" 1)
         (list 'n "N" 1) (list 'm "M" 1)
         (list #f "Shift" 2.25))
   ;; Row 6: Space row
   (list (list #f "Ctrl" 1.5) (list #f "Alt" 1.25) (list #f "Cmd" 1.25)
         (list 'space "Space" 6)
         (list #f "Cmd" 1.25) (list #f "Alt" 1.25)
         (list 'left "<" 1) (list 'down "v" 1) (list 'up "^" 1) (list 'right ">" 1))))

;; Drawing constants
(define key-size 45)
(define key-gap 4)
(define keyboard-x 50)
(define keyboard-y 120)

;; Draw a single key
(define (draw-key! renderer x y w label pressed? is-modifier?)
  (define key-w (- (* w key-size) key-gap))
  (define key-h (- key-size key-gap))

  ;; Key background
  (cond
    [pressed?
     (set-draw-color! renderer 100 200 255)]  ; Blue when pressed
    [is-modifier?
     (set-draw-color! renderer 60 60 80)]     ; Dark for modifiers
    [else
     (set-draw-color! renderer 50 50 55)])    ; Normal key
  (fill-rect! renderer x y key-w key-h)

  ;; Key border
  (if pressed?
      (set-draw-color! renderer 150 230 255)
      (set-draw-color! renderer 80 80 90))
  (draw-rect! renderer x y key-w key-h))

;; Draw the virtual keyboard
(define (draw-keyboard! renderer)
  (define y keyboard-y)

  (for ([row keyboard-layout])
    (define x keyboard-x)
    (for ([key-spec row])
      (match-define (list keycode label width) key-spec)
      (when (and label (> width 0))
        (define pressed? (and keycode (hash-ref pressed-keys keycode #f)))
        (define is-mod? (not keycode))
        (draw-key! renderer x y width label pressed? is-mod?))
      (set! x (+ x (* width key-size))))
    (set! y (+ y key-size))))

;; Draw key info panel
(define (draw-info-panel! renderer)
  ;; Background panel
  (set-draw-color! renderer 35 35 45)
  (fill-rect! renderer 50 20 700 80)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 50 20 700 80)

  ;; Draw colored boxes for info sections
  ;; Keycode box
  (set-draw-color! renderer 80 60 60)
  (fill-rect! renderer 60 30 150 25)
  (set-draw-color! renderer 120 80 80)
  (draw-rect! renderer 60 30 150 25)

  ;; Key name box
  (set-draw-color! renderer 60 80 60)
  (fill-rect! renderer 220 30 200 25)
  (set-draw-color! renderer 80 120 80)
  (draw-rect! renderer 220 30 200 25)

  ;; Scancode box
  (set-draw-color! renderer 60 60 80)
  (fill-rect! renderer 430 30 150 25)
  (set-draw-color! renderer 80 80 120)
  (draw-rect! renderer 430 30 150 25))

;; Draw modifier indicator boxes
(define (draw-modifiers! renderer)
  (define base-x 60)
  (define base-y 65)
  (define box-w 80)
  (define box-h 25)
  (define gap 10)

  (define mods
    (list (list "Shift" (mod-shift? last-mod) '(255 200 100))
          (list "Ctrl" (mod-ctrl? last-mod) '(100 200 255))
          (list "Alt" (mod-alt? last-mod) '(100 255 150))
          (list "Cmd" (mod-gui? last-mod) '(255 150 200))))

  (for ([mod mods]
        [i (in-naturals)])
    (match-define (list label active? color) mod)
    (define x (+ base-x (* i (+ box-w gap))))
    (if active?
        (apply set-draw-color! renderer color)
        (set-draw-color! renderer 50 50 55))
    (fill-rect! renderer x base-y box-w box-h)
    (set-draw-color! renderer 80 80 90)
    (draw-rect! renderer x base-y box-w box-h)))

;; Draw instructions
(define (draw-instructions! renderer)
  (set-draw-color! renderer 40 40 50)
  (fill-rect! renderer 50 420 700 60)
  (set-draw-color! renderer 60 60 70)
  (draw-rect! renderer 50 420 700 60))

(define (main)
  (printf "Keyboard Demo~n")
  (printf "=============~n")
  (printf "Press keys to see them highlighted on the virtual keyboard.~n")
  (printf "Key info (keycode, name, scancode) shown at top.~n")
  (printf "Modifier keys (Shift, Ctrl, Alt, Cmd) shown as colored boxes.~n")
  (printf "Press Escape to quit.~n~n")

  (with-sdl
    (with-window+renderer "SDL3 Keyboard Demo" window-width window-height (window renderer)
      (let loop ([running? #t])
    (when running?
      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             #f]

            ;; Key down
            [(key-event 'down key scancode mod _)
             (hash-set! pressed-keys key #t)
             (set! last-key key)
             (set! last-scancode scancode)
             (set! last-key-name (key-name key))
             (set! last-mod mod)
             (printf "DOWN: ~a (keycode=~a, scancode=~a, mod=~a)~n"
                     last-key-name key scancode mod)
             (if (eq? key 'escape) #f run?)]

            ;; Key up
            [(key-event 'up key _ mod _)
             (hash-remove! pressed-keys key)
             (set! last-mod mod)
             run?]

            [_ run?])))

      (when still-running?
        ;; Clear background
        (set-draw-color! renderer 30 30 35)
        (render-clear! renderer)

        ;; Draw components
        (draw-info-panel! renderer)
        (draw-modifiers! renderer)
        (draw-keyboard! renderer)
        (draw-instructions! renderer)

        (render-present! renderer)
        (delay! 16)
        (loop still-running?))))))

  (printf "~nDone.~n"))

;; Run when executed directly
(module+ main
  (main))
