#lang racket/base

;; Buttons Demo
;;
;; Demonstrates interactive UI buttons in SDL3:
;; - Clickable rectangular buttons
;; - Hover state detection
;; - Click/pressed state visual feedback
;; - Mouse cursor changes on hover (if supported)
;;
;; Controls:
;;   Mouse - Hover over and click buttons
;;   Escape - Quit

(require racket/match
         racket/format
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Buttons Demo")

;; Button state enum
(define STATE-NORMAL 0)
(define STATE-HOVER 1)
(define STATE-PRESSED 2)
(define STATE-DISABLED 3)

;; Button structure
(struct button (x y w h label state action enabled?) #:mutable)

;; Create a new button
(define (make-button x y w h label action #:enabled? [enabled? #t])
  (button x y w h label STATE-NORMAL action enabled?))

;; Check if point is inside button
(define (point-in-button? btn mx my)
  (and (>= mx (button-x btn))
       (< mx (+ (button-x btn) (button-w btn)))
       (>= my (button-y btn))
       (< my (+ (button-y btn) (button-h btn)))))

;; Update button state based on mouse position and button press
(define (update-button-state! btn mx my mouse-down?)
  (cond
    [(not (button-enabled? btn))
     (set-button-state! btn STATE-DISABLED)]
    [(point-in-button? btn mx my)
     (if mouse-down?
         (set-button-state! btn STATE-PRESSED)
         (set-button-state! btn STATE-HOVER))]
    [else
     (set-button-state! btn STATE-NORMAL)]))

;; Draw a single button
(define (draw-button! renderer btn)
  (define x (button-x btn))
  (define y (button-y btn))
  (define w (button-w btn))
  (define h (button-h btn))
  (define state (button-state btn))

  ;; Colors based on state
  (define-values (bg-r bg-g bg-b border-r border-g border-b text-r text-g text-b)
    (case state
      [(0)  ; NORMAL
       (values 60 70 90 100 110 140 200 200 200)]
      [(1)  ; HOVER
       (values 80 100 130 120 150 200 255 255 255)]
      [(2)  ; PRESSED
       (values 40 50 70 80 90 120 180 180 180)]
      [(3)  ; DISABLED
       (values 40 40 45 60 60 70 100 100 100)]
      [else
       (values 60 70 90 100 110 140 200 200 200)]))

  ;; Draw shadow (offset for normal/hover, smaller for pressed)
  (when (button-enabled? btn)
    (define shadow-offset (if (= state STATE-PRESSED) 1 3))
    (set-draw-color! renderer 20 20 30)
    (fill-rect! renderer (+ x shadow-offset) (+ y shadow-offset) w h))

  ;; Draw button background
  (define press-offset (if (= state STATE-PRESSED) 2 0))
  (set-draw-color! renderer bg-r bg-g bg-b)
  (fill-rect! renderer (+ x press-offset) (+ y press-offset) w h)

  ;; Draw border
  (set-draw-color! renderer border-r border-g border-b)
  (draw-rect! renderer (+ x press-offset) (+ y press-offset) w h)

  ;; Draw highlight on top edge (for 3D effect)
  (when (and (button-enabled? btn) (not (= state STATE-PRESSED)))
    (set-draw-color! renderer (min 255 (+ bg-r 40))
                     (min 255 (+ bg-g 40))
                     (min 255 (+ bg-b 40)))
    (draw-line! renderer (+ x 1 press-offset) (+ y 1 press-offset)
                (+ x w -2 press-offset) (+ y 1 press-offset)))

  ;; Draw label (centered)
  (define label (button-label btn))
  (define text-w (* (string-length label) 8))  ; debug font is 8px wide
  (define text-x (+ x press-offset (/ (- w text-w) 2)))
  (define text-y (+ y press-offset (/ (- h 8) 2)))

  (set-draw-color! renderer text-r text-g text-b)
  (render-debug-text! renderer text-x text-y label))

;; Application state
(define click-count 0)
(define last-action "None")
(define counter 0)

;; Button actions
(define (on-increment)
  (set! counter (+ counter 1))
  (set! click-count (+ click-count 1))
  (set! last-action "Increment"))

(define (on-decrement)
  (set! counter (- counter 1))
  (set! click-count (+ click-count 1))
  (set! last-action "Decrement"))

(define (on-reset)
  (set! counter 0)
  (set! click-count (+ click-count 1))
  (set! last-action "Reset"))

(define (on-double)
  (set! counter (* counter 2))
  (set! click-count (+ click-count 1))
  (set! last-action "Double"))

(define (on-random)
  (set! counter (random 100))
  (set! click-count (+ click-count 1))
  (set! last-action "Random"))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  (set-blend-mode! renderer 'blend)

  ;; Create buttons
  (define buttons
    (list
     (make-button 100 200 150 50 "Increment (+)" on-increment)
     (make-button 100 270 150 50 "Decrement (-)" on-decrement)
     (make-button 100 340 150 50 "Reset (0)" on-reset)
     (make-button 280 200 150 50 "Double (x2)" on-double)
     (make-button 280 270 150 50 "Random" on-random)
     (make-button 280 340 150 50 "Disabled" void #:enabled? #f)))

  ;; Track which button was pressed (for click detection)
  (define pressed-button #f)

  (let loop ([running? #t])
    (when running?
      ;; Get mouse state
      (define-values (mx my mouse-buttons) (get-mouse-state))
      (define left-down? (mouse-button-pressed? mouse-buttons SDL_BUTTON_LMASK))

      ;; Process events
      (define-values (clicked-button still-running?)
        (for/fold ([clicked #f]
                   [run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             (values clicked #f)]

            [(key-event 'down 'escape _ _ _)
             (values clicked #f)]

            ;; Mouse button down - track which button was pressed
            [(mouse-button-event 'down 'left x y _)
             (define btn-under
               (for/first ([btn buttons]
                           #:when (and (button-enabled? btn)
                                       (point-in-button? btn x y)))
                 btn))
             (set! pressed-button btn-under)
             (values clicked run?)]

            ;; Mouse button up - trigger action if released over same button
            [(mouse-button-event 'up 'left x y _)
             (define btn-under
               (for/first ([btn buttons]
                           #:when (and (button-enabled? btn)
                                       (point-in-button? btn x y)))
                 btn))
             (define new-clicked
               (if (and pressed-button btn-under (eq? pressed-button btn-under))
                   btn-under
                   clicked))
             (set! pressed-button #f)
             (values new-clicked run?)]

            [_ (values clicked run?)])))

      (when still-running?
        ;; Execute clicked button's action
        (when clicked-button
          ((button-action clicked-button)))

        ;; Update button states
        (for ([btn buttons])
          (update-button-state! btn mx my
                                (and left-down?
                                     pressed-button
                                     (eq? btn pressed-button))))

        ;; Clear background
        (set-draw-color! renderer 30 30 40)
        (render-clear! renderer)

        ;; Draw title
        (set-draw-color! renderer 255 255 255)
        (render-debug-text! renderer 20 20 "BUTTONS DEMO")

        (set-draw-color! renderer 150 150 150)
        (render-debug-text! renderer 20 40 "Click the buttons to modify the counter")

        ;; Draw buttons
        (for ([btn buttons])
          (draw-button! renderer btn))

        ;; Draw counter display
        (set-draw-color! renderer 40 45 55)
        (fill-rect! renderer 500 200 250 190)
        (set-draw-color! renderer 70 80 100)
        (draw-rect! renderer 500 200 250 190)

        (set-draw-color! renderer 200 200 200)
        (render-debug-text! renderer 520 215 "COUNTER")

        ;; Large counter value
        (set-draw-color! renderer 100 200 255)
        (define counter-str (~a counter))
        (define counter-x (+ 500 (/ (- 250 (* (string-length counter-str) 8 3)) 2)))
        ;; Draw counter 3x size by repeating
        (render-debug-text! renderer counter-x 250 counter-str)
        (render-debug-text! renderer (+ counter-x 1) 250 counter-str)
        (render-debug-text! renderer (- counter-x 1) 250 counter-str)

        ;; Stats
        (set-draw-color! renderer 150 150 150)
        (render-debug-text! renderer 520 300 (~a "Total clicks: " click-count))
        (render-debug-text! renderer 520 320 (~a "Last action: " last-action))

        ;; Mouse position display
        (render-debug-text! renderer 520 340 (~a "Mouse: " (inexact->exact (round mx))
                                                  ", " (inexact->exact (round my))))

        ;; Draw hover indicator for hovered button
        (define hovered-btn
          (for/first ([btn buttons]
                      #:when (= (button-state btn) STATE-HOVER))
            btn))
        (when hovered-btn
          (set-draw-color! renderer 100 200 100)
          (render-debug-text! renderer 520 360 (~a "Hovering: " (button-label hovered-btn))))

        ;; Instructions
        (set-draw-color! renderer 100 100 120)
        (render-debug-text! renderer 20 (- window-height 30)
                            "Click buttons to interact | ESC to quit")

        (render-present! renderer)
        (delay! 16)

        (loop still-running?))))

  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
