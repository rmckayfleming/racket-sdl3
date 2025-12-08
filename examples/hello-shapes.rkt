#lang racket/base

;; Hello Shapes - SDL3 Racket Bindings Example
;;
;; Demonstrates drawing primitives: points, lines, rectangles, and filled rectangles.
;; Shows both singular and plural (batched) versions for efficiency.
;; Press ESC or close the window to exit.

(require ffi/unsafe
         sdl3)

(define WINDOW_WIDTH 800)
(define WINDOW_HEIGHT 600)
(define WINDOW_TITLE "SDL3 Racket - Hello Shapes")

;; Helper to create an array of SDL_FPoint structs
(define (make-fpoint-array points)
  (define n (length points))
  (define arr (malloc (* n (ctype-sizeof _SDL_FPoint))))
  (for ([pt (in-list points)]
        [i (in-naturals)])
    (define p (ptr-add arr (* i (ctype-sizeof _SDL_FPoint))))
    (ptr-set! p _float 0 (car pt))   ; x
    (ptr-set! p _float 1 (cadr pt))) ; y
  arr)

;; Helper to create an array of SDL_FRect structs
(define (make-frect-array rects)
  (define n (length rects))
  (define arr (malloc (* n (ctype-sizeof _SDL_FRect))))
  (for ([r (in-list rects)]
        [i (in-naturals)])
    (define p (ptr-add arr (* i (ctype-sizeof _SDL_FRect))))
    (ptr-set! p _float 0 (list-ref r 0)) ; x
    (ptr-set! p _float 1 (list-ref r 1)) ; y
    (ptr-set! p _float 2 (list-ref r 2)) ; w
    (ptr-set! p _float 3 (list-ref r 3))) ; h
  arr)

(define (main)
  ;; Initialize SDL video subsystem
  (unless (SDL-Init SDL_INIT_VIDEO)
    (error 'main "Failed to initialize SDL: ~a" (SDL-GetError)))

  (define window #f)
  (define renderer #f)

  (dynamic-wind
    void
    (λ ()
      ;; Create window
      (set! window (SDL-CreateWindow WINDOW_TITLE
                                     WINDOW_WIDTH
                                     WINDOW_HEIGHT
                                     SDL_WINDOW_RESIZABLE))
      (unless window
        (error 'main "Failed to create window: ~a" (SDL-GetError)))

      ;; Create renderer
      (set! renderer (SDL-CreateRenderer window #f))
      (unless renderer
        (error 'main "Failed to create renderer: ~a" (SDL-GetError)))

      ;; Event buffer
      (define event-buf (malloc SDL_EVENT_SIZE))
      (define running? #t)

      ;; Create rectangle arrays for batched drawing
      ;; Row of filled rectangles at top
      (define filled-rects-data '((50.0 50.0 100.0 80.0)
                                  (170.0 50.0 100.0 80.0)
                                  (290.0 50.0 100.0 80.0)))
      (define filled-rects (make-frect-array filled-rects-data))

      ;; Row of outline rectangles
      (define outline-rects-data '((450.0 50.0 100.0 80.0)
                                   (570.0 50.0 100.0 80.0)
                                   (690.0 50.0 100.0 80.0)))
      (define outline-rects (make-frect-array outline-rects-data))

      ;; Triangle vertices (closed shape needs 4 points: A-B-C-A)
      (define triangle-pts '((400.0 180.0)   ; top
                             (300.0 320.0)   ; bottom-left
                             (500.0 320.0)   ; bottom-right
                             (400.0 180.0))) ; back to top
      (define triangle (make-fpoint-array triangle-pts))

      ;; Star shape using connected lines
      (define star-pts '((200.0 400.0)
                         (240.0 500.0)
                         (150.0 440.0)
                         (250.0 440.0)
                         (160.0 500.0)
                         (200.0 400.0)))
      (define star (make-fpoint-array star-pts))

      ;; Grid of points (20x20 = 400 points)
      (define grid-pts
        (for*/list ([i (in-range 20)]
                    [j (in-range 20)])
          (list (+ 550.0 (* i 4.0))
                (+ 350.0 (* j 4.0)))))
      (define grid (make-fpoint-array grid-pts))

      ;; Sine wave points
      (define wave-pts
        (for/list ([x (in-range 0 400 4)])
          (list (+ 200.0 (exact->inexact x))
                (+ 500.0 (* 30.0 (sin (* x 0.05)))))))
      (define wave (make-fpoint-array wave-pts))

      ;; Main loop
      (let loop ()
        (when running?
          ;; Poll all pending events
          (let poll-events ()
            (when (SDL-PollEvent event-buf)
              (define event-type (sdl-event-type event-buf))
              (cond
                [(= event-type SDL_EVENT_QUIT)
                 (set! running? #f)]
                [(= event-type SDL_EVENT_KEY_DOWN)
                 (define kb-event (event->keyboard event-buf))
                 (define key (SDL_KeyboardEvent-key kb-event))
                 (when (= key SDLK_ESCAPE)
                   (set! running? #f))])
              (poll-events)))

          (when running?
            ;; Clear screen with dark gray background
            (SDL-SetRenderDrawColor renderer 40 40 40 255)
            (SDL-RenderClear renderer)

            ;; Draw multiple filled rectangles at once (red)
            (SDL-SetRenderDrawColor renderer 220 60 60 255)
            (SDL-RenderFillRects renderer filled-rects 3)

            ;; Draw multiple rectangle outlines at once (green)
            (SDL-SetRenderDrawColor renderer 60 220 60 255)
            (SDL-RenderRects renderer outline-rects 3)

            ;; Draw triangle using connected lines (cyan)
            (SDL-SetRenderDrawColor renderer 60 220 220 255)
            (SDL-RenderLines renderer triangle 4)

            ;; Draw star using connected lines (yellow)
            (SDL-SetRenderDrawColor renderer 220 220 60 255)
            (SDL-RenderLines renderer star 6)

            ;; Draw grid of points (white)
            (SDL-SetRenderDrawColor renderer 255 255 255 255)
            (SDL-RenderPoints renderer grid 400)

            ;; Draw sine wave using points (magenta)
            (SDL-SetRenderDrawColor renderer 220 60 220 255)
            (SDL-RenderPoints renderer wave 100)

            ;; Also show single-draw versions for comparison
            ;; Single filled rect (blue)
            (define single-rect (make-SDL_FRect 50.0 350.0 80.0 60.0))
            (SDL-SetRenderDrawColor renderer 60 60 220 255)
            (SDL-RenderFillRect renderer single-rect)

            ;; Single line (orange)
            (SDL-SetRenderDrawColor renderer 220 140 60 255)
            (SDL-RenderLine renderer 50.0 450.0 130.0 550.0)

            ;; Present the rendered frame
            (SDL-RenderPresent renderer)

            ;; Small delay to reduce CPU usage
            (SDL-Delay 16)

            (loop)))))

    ;; Cleanup
    (λ ()
      (when renderer
        (SDL-DestroyRenderer renderer))
      (when window
        (SDL-DestroyWindow window))
      (SDL-Quit))))

;; Run the main function
(main)
