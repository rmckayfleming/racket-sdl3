#lang racket/base

;; Rectangle Collision Detection - demonstrates rect collision functions
;;
;; - Move the player box with arrow keys or WASD
;; - Player turns red when colliding with obstacle boxes
;; - Shows intersection rectangle when colliding

(require racket/match
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Racket - Rectangle Collision")

;; Player state
(define player-x 100)
(define player-y 100)
(define player-w 60)
(define player-h 60)
(define player-speed 5)

;; Movement state
(define move-left #f)
(define move-right #f)
(define move-up #f)
(define move-down #f)

;; Obstacle boxes (x y w h)
(define obstacles
  '((200 150 100 100)
    (450 200 80 150)
    (300 400 200 60)
    (600 100 80 80)
    (550 350 120 100)))

;; Convert list to rect
(define (list->rect lst)
  (make-rect (list-ref lst 0)
             (list-ref lst 1)
             (list-ref lst 2)
             (list-ref lst 3)))

;; Check collision between player rect and an obstacle
;; Returns intersection rect if colliding, #f otherwise
(define (check-collision player-rect obstacle-lst)
  (define obs-rect (list->rect obstacle-lst))
  (rect-intersection player-rect obs-rect))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  ;; Main loop
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
            ;; Key down - direct symbol matching
            [(key-event 'down 'escape _ _ _) #f]
            [(key-event 'down (or 'left 'a) _ _ _)
             (set! move-left #t) run?]
            [(key-event 'down (or 'right 'd) _ _ _)
             (set! move-right #t) run?]
            [(key-event 'down (or 'up 'w) _ _ _)
             (set! move-up #t) run?]
            [(key-event 'down (or 'down 's) _ _ _)
             (set! move-down #t) run?]
            ;; Key up
            [(key-event 'up (or 'left 'a) _ _ _)
             (set! move-left #f) run?]
            [(key-event 'up (or 'right 'd) _ _ _)
             (set! move-right #f) run?]
            [(key-event 'up (or 'up 'w) _ _ _)
             (set! move-up #f) run?]
            [(key-event 'up (or 'down 's) _ _ _)
             (set! move-down #f) run?]
            [_ run?])))

      (when still-running?
        ;; Update player position
        (when move-left
          (set! player-x (max 0 (- player-x player-speed))))
        (when move-right
          (set! player-x (min (- window-width player-w) (+ player-x player-speed))))
        (when move-up
          (set! player-y (max 0 (- player-y player-speed))))
        (when move-down
          (set! player-y (min (- window-height player-h) (+ player-y player-speed))))

        ;; Create player rect for collision detection
        (define player-rect (make-rect player-x player-y player-w player-h))

        ;; Check for collisions
        (define intersections
          (filter values
                  (map (lambda (obs) (check-collision player-rect obs))
                       obstacles)))

        (define colliding? (not (null? intersections)))

        ;; Clear screen
        (set-draw-color! renderer 30 30 40)
        (render-clear! renderer)

        ;; Draw obstacles (blue)
        (set-draw-color! renderer 60 100 180)
        (for ([obs (in-list obstacles)])
          (fill-rect! renderer
                      (list-ref obs 0)
                      (list-ref obs 1)
                      (list-ref obs 2)
                      (list-ref obs 3)))

        ;; Draw obstacle outlines
        (set-draw-color! renderer 100 150 220)
        (for ([obs (in-list obstacles)])
          (draw-rect! renderer
                      (list-ref obs 0)
                      (list-ref obs 1)
                      (list-ref obs 2)
                      (list-ref obs 3)))

        ;; Draw player (green or red if colliding)
        (if colliding?
            (set-draw-color! renderer 220 80 80)
            (set-draw-color! renderer 80 200 80))
        (fill-rect! renderer player-x player-y player-w player-h)

        ;; Draw player outline
        (if colliding?
            (set-draw-color! renderer 255 120 120)
            (set-draw-color! renderer 120 255 120))
        (draw-rect! renderer player-x player-y player-w player-h)

        ;; Draw intersection rectangles (yellow)
        (set-draw-color! renderer 255 255 0)
        (for ([isect (in-list intersections)])
          (fill-rect! renderer
                      (rect-x isect)
                      (rect-y isect)
                      (rect-w isect)
                      (rect-h isect)))

        ;; Present
        (render-present! renderer)
        (delay! 16)

        (loop still-running?))))

  ;; Cleanup
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run the example when executed directly
(module+ main
  (main))
