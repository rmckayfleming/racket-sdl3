#lang racket/base

;; Rectangle Collision Detection - demonstrates SDL_Rect and intersection functions
;;
;; - Move the player box with arrow keys or WASD
;; - Player turns red when colliding with obstacle boxes
;; - Shows intersection rectangle when colliding

(require racket/match
         ffi/unsafe
         sdl3/raw)

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

;; Convert list to SDL_Rect
(define (list->rect lst)
  (make-SDL_Rect (list-ref lst 0)
                 (list-ref lst 1)
                 (list-ref lst 2)
                 (list-ref lst 3)))

;; Draw a filled rectangle using SDL_FRect (rendering uses floats)
(define (draw-filled-rect renderer x y w h)
  (define rect (make-SDL_FRect (exact->inexact x)
                               (exact->inexact y)
                               (exact->inexact w)
                               (exact->inexact h)))
  (SDL-RenderFillRect renderer rect))

;; Draw a rectangle outline
(define (draw-rect-outline renderer x y w h)
  (define rect (make-SDL_FRect (exact->inexact x)
                               (exact->inexact y)
                               (exact->inexact w)
                               (exact->inexact h)))
  (SDL-RenderRect renderer rect))

;; Check collision between player and an obstacle
;; Returns intersection rect if colliding, #f otherwise
(define (check-collision player-rect obstacle-lst)
  (define obs-rect (list->rect obstacle-lst))
  (if (SDL-HasRectIntersection player-rect obs-rect)
      (let ([result (make-SDL_Rect 0 0 0 0)])
        (SDL-GetRectIntersection player-rect obs-rect result)
        result)
      #f))

(define (main)
  ;; Initialize SDL
  (unless (SDL-Init SDL_INIT_VIDEO)
    (error 'main "SDL_Init failed: ~a" (SDL-GetError)))

  ;; Create window and renderer
  (define window (SDL-CreateWindow window-title window-width window-height 0))
  (unless window
    (error 'main "SDL_CreateWindow failed: ~a" (SDL-GetError)))

  (define renderer (SDL-CreateRenderer window #f))
  (unless renderer
    (SDL-DestroyWindow window)
    (error 'main "SDL_CreateRenderer failed: ~a" (SDL-GetError)))

  ;; Event buffer
  (define event-buf (malloc SDL_EVENT_SIZE 'atomic-interior))

  ;; Main loop
  (let loop ([running? #t])
    (when running?
      ;; Process events
      (define still-running?
        (let event-loop ([run? #t])
          (if (and run? (SDL-PollEvent event-buf))
              (let ([event-type (sdl-event-type event-buf)])
                (cond
                  [(= event-type SDL_EVENT_QUIT)
                   (event-loop #f)]
                  [(= event-type SDL_EVENT_KEY_DOWN)
                   (define kb (event->keyboard event-buf))
                   (define key (SDL_KeyboardEvent-key kb))
                   (cond
                     [(= key SDLK_ESCAPE) (event-loop #f)]
                     [(or (= key SDLK_LEFT) (= key SDLK_A))
                      (set! move-left #t)
                      (event-loop run?)]
                     [(or (= key SDLK_RIGHT) (= key SDLK_D))
                      (set! move-right #t)
                      (event-loop run?)]
                     [(or (= key SDLK_UP) (= key SDLK_W))
                      (set! move-up #t)
                      (event-loop run?)]
                     [(or (= key SDLK_DOWN) (= key SDLK_S))
                      (set! move-down #t)
                      (event-loop run?)]
                     [else (event-loop run?)])]
                  [(= event-type SDL_EVENT_KEY_UP)
                   (define kb (event->keyboard event-buf))
                   (define key (SDL_KeyboardEvent-key kb))
                   (cond
                     [(or (= key SDLK_LEFT) (= key SDLK_A))
                      (set! move-left #f)
                      (event-loop run?)]
                     [(or (= key SDLK_RIGHT) (= key SDLK_D))
                      (set! move-right #f)
                      (event-loop run?)]
                     [(or (= key SDLK_UP) (= key SDLK_W))
                      (set! move-up #f)
                      (event-loop run?)]
                     [(or (= key SDLK_DOWN) (= key SDLK_S))
                      (set! move-down #f)
                      (event-loop run?)]
                     [else (event-loop run?)])]
                  [else (event-loop run?)]))
              run?)))

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
        (define player-rect (make-SDL_Rect player-x player-y player-w player-h))

        ;; Check for collisions
        (define intersections
          (filter values
                  (map (lambda (obs) (check-collision player-rect obs))
                       obstacles)))

        (define colliding? (not (null? intersections)))

        ;; Clear screen
        (SDL-SetRenderDrawColor renderer 30 30 40 255)
        (SDL-RenderClear renderer)

        ;; Draw obstacles (blue)
        (SDL-SetRenderDrawColor renderer 60 100 180 255)
        (for ([obs (in-list obstacles)])
          (draw-filled-rect renderer
                            (list-ref obs 0)
                            (list-ref obs 1)
                            (list-ref obs 2)
                            (list-ref obs 3)))

        ;; Draw obstacle outlines
        (SDL-SetRenderDrawColor renderer 100 150 220 255)
        (for ([obs (in-list obstacles)])
          (draw-rect-outline renderer
                             (list-ref obs 0)
                             (list-ref obs 1)
                             (list-ref obs 2)
                             (list-ref obs 3)))

        ;; Draw player (green or red if colliding)
        (if colliding?
            (SDL-SetRenderDrawColor renderer 220 80 80 255)
            (SDL-SetRenderDrawColor renderer 80 200 80 255))
        (draw-filled-rect renderer player-x player-y player-w player-h)

        ;; Draw player outline
        (if colliding?
            (SDL-SetRenderDrawColor renderer 255 120 120 255)
            (SDL-SetRenderDrawColor renderer 120 255 120 255))
        (draw-rect-outline renderer player-x player-y player-w player-h)

        ;; Draw intersection rectangles (yellow)
        (SDL-SetRenderDrawColor renderer 255 255 0 200)
        (for ([isect (in-list intersections)])
          (draw-filled-rect renderer
                            (SDL_Rect-x isect)
                            (SDL_Rect-y isect)
                            (SDL_Rect-w isect)
                            (SDL_Rect-h isect)))

        ;; Present
        (SDL-RenderPresent renderer)
        (SDL-Delay 16)

        (loop still-running?))))

  ;; Cleanup
  (SDL-DestroyRenderer renderer)
  (SDL-DestroyWindow window)
  (SDL-Quit))

;; Run the example when executed directly
(module+ main
  (main))
