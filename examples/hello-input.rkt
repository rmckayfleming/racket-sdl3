#lang racket/base

;; Interactive SDL3 example - keyboard and mouse input
;; - Press R, G, B to change background color
;; - Mouse position shown in window title
;; - Press Escape or close window to quit
;; - Key presses printed to console

(require ffi/unsafe
         sdl3)

(define WINDOW_WIDTH 800)
(define WINDOW_HEIGHT 600)
(define INITIAL_TITLE "SDL3 Input - Move mouse, press R/G/B")

;; Current background color (mutable)
(define bg-r 0)
(define bg-g 0)
(define bg-b 0)

(define (set-color! r g b)
  (set! bg-r r)
  (set! bg-g g)
  (set! bg-b b))

(define (handle-key-down event-ptr)
  (define kb (event->keyboard event-ptr))
  (define keycode (SDL_KeyboardEvent-key kb))
  (define key-name (SDL-GetKeyName keycode))

  ;; Print key name to console
  (printf "Key pressed: ~a~n" key-name)

  ;; Check for color keys (both uppercase and lowercase)
  (cond
    [(or (= keycode SDLK_r) (= keycode SDLK_R))
     (set-color! 255 0 0)]
    [(or (= keycode SDLK_g) (= keycode SDLK_G))
     (set-color! 0 255 0)]
    [(or (= keycode SDLK_b) (= keycode SDLK_B))
     (set-color! 0 0 255)]
    [else (void)])

  ;; Return whether to quit (escape pressed)
  (= keycode SDLK_ESCAPE))

(define (handle-mouse-motion event-ptr window)
  (define motion (event->mouse-motion event-ptr))
  (define x (inexact->exact (round (SDL_MouseMotionEvent-x motion))))
  (define y (inexact->exact (round (SDL_MouseMotionEvent-y motion))))
  (define title (format "SDL3 Input - Mouse: (~a, ~a)" x y))
  (SDL-SetWindowTitle window title))

(define (main)
  ;; Initialize SDL video subsystem
  (unless (SDL-Init SDL_INIT_VIDEO)
    (error 'main "Failed to initialize SDL: ~a" (SDL-GetError)))

  (define window #f)
  (define renderer #f)

  (dynamic-wind
    void
    (lambda ()
      ;; Create window
      (set! window (SDL-CreateWindow INITIAL_TITLE
                                     WINDOW_WIDTH
                                     WINDOW_HEIGHT
                                     SDL_WINDOW_RESIZABLE))
      (unless window
        (error 'main "Failed to create window: ~a" (SDL-GetError)))

      ;; Create renderer (use default renderer by passing #f)
      (set! renderer (SDL-CreateRenderer window #f))
      (unless renderer
        (error 'main "Failed to create renderer: ~a" (SDL-GetError)))

      ;; Event buffer - SDL_Event is 128 bytes in SDL3
      (define event (malloc SDL_EVENT_SIZE 'atomic-interior))
      (define running? #t)

      ;; Main loop
      (let loop ()
        (when running?
          ;; Poll all pending events
          (let event-loop ()
            (when (SDL-PollEvent event)
              (define type (sdl-event-type event))
              (cond
                [(= type SDL_EVENT_QUIT)
                 (set! running? #f)]
                [(= type SDL_EVENT_WINDOW_CLOSE_REQUESTED)
                 (set! running? #f)]
                [(= type SDL_EVENT_KEY_DOWN)
                 (when (handle-key-down event)
                   (set! running? #f))]
                [(= type SDL_EVENT_MOUSE_MOTION)
                 (handle-mouse-motion event window)]
                [else (void)])
              (event-loop)))

          ;; Render if still running
          (when running?
            ;; Set draw color to current background
            (SDL-SetRenderDrawColor renderer bg-r bg-g bg-b 255)

            ;; Clear the screen
            (SDL-RenderClear renderer)

            ;; Present the rendered frame
            (SDL-RenderPresent renderer)

            ;; Small delay to not spin CPU (approx 60fps)
            (SDL-Delay 16)

            (loop)))))

    ;; Cleanup
    (lambda ()
      (when renderer
        (SDL-DestroyRenderer renderer))
      (when window
        (SDL-DestroyWindow window))
      (SDL-Quit))))

;; Run the main function
(main)
