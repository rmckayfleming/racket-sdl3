#lang racket/base

;; SDL3_image example - load and display a PNG
;; Arrow keys move the image, Escape quits

(require ffi/unsafe
         sdl3
         sdl3/image)

(define WINDOW_WIDTH 800)
(define WINDOW_HEIGHT 600)
(define MOVE_SPEED 10.0)

;; Helper to get texture dimensions
(define (get-texture-size texture)
  (define w-ptr (malloc _float))
  (define h-ptr (malloc _float))
  (unless (SDL-GetTextureSize texture w-ptr h-ptr)
    (error 'get-texture-size "SDL_GetTextureSize failed: ~a" (SDL-GetError)))
  (values (ptr-ref w-ptr _float) (ptr-ref h-ptr _float)))

;; Handle arrow key movement, return new x and y
(define (handle-key-down event-ptr img-x img-y)
  (define kb (event->keyboard event-ptr))
  (define keycode (SDL_KeyboardEvent-key kb))
  (cond
    [(= keycode SDLK_LEFT)
     (values (- img-x MOVE_SPEED) img-y)]
    [(= keycode SDLK_RIGHT)
     (values (+ img-x MOVE_SPEED) img-y)]
    [(= keycode SDLK_UP)
     (values img-x (- img-y MOVE_SPEED))]
    [(= keycode SDLK_DOWN)
     (values img-x (+ img-y MOVE_SPEED))]
    [else
     (values img-x img-y)]))

(define (main)
  ;; Initialize SDL video subsystem
  (unless (SDL-Init SDL_INIT_VIDEO)
    (error 'main "SDL_Init failed: ~a" (SDL-GetError)))

  ;; Note: SDL3_image no longer requires explicit IMG_Init
  ;; Format support is initialized automatically when loading images

  (define window #f)
  (define renderer #f)
  (define texture #f)

  (dynamic-wind
    void
    (lambda ()
      ;; Create window
      (set! window (SDL-CreateWindow "SDL3 Image - Arrow keys to move"
                                     WINDOW_WIDTH
                                     WINDOW_HEIGHT
                                     SDL_WINDOW_RESIZABLE))
      (unless window
        (error 'main "SDL_CreateWindow failed: ~a" (SDL-GetError)))

      ;; Create renderer
      (set! renderer (SDL-CreateRenderer window #f))
      (unless renderer
        (error 'main "SDL_CreateRenderer failed: ~a" (SDL-GetError)))

      ;; Load texture
      (define image-path "examples/assets/test.png")
      (set! texture (IMG-LoadTexture renderer image-path))
      (unless texture
        (error 'main "IMG_LoadTexture failed for ~a: ~a" image-path (SDL-GetError)))

      ;; Get texture dimensions and center it
      (define-values (tex-w tex-h) (get-texture-size texture))
      (define img-x (/ (- WINDOW_WIDTH tex-w) 2.0))
      (define img-y (/ (- WINDOW_HEIGHT tex-h) 2.0))

      ;; Create destination rect (will be updated each frame)
      (define dst-rect (make-SDL_FRect img-x img-y tex-w tex-h))

      ;; Event buffer
      (define event (malloc SDL_EVENT_SIZE 'atomic-interior))
      (define running? #t)

      ;; Main loop
      (let loop ([x img-x] [y img-y])
        (when running?
          ;; Poll all pending events
          (define-values (new-x new-y quit?)
            (let event-loop ([curr-x x] [curr-y y])
              (if (SDL-PollEvent event)
                  (let ([type (sdl-event-type event)])
                    (cond
                      [(= type SDL_EVENT_QUIT)
                       (set! running? #f)
                       (values curr-x curr-y #t)]
                      [(= type SDL_EVENT_WINDOW_CLOSE_REQUESTED)
                       (set! running? #f)
                       (values curr-x curr-y #t)]
                      [(= type SDL_EVENT_KEY_DOWN)
                       (define kb (event->keyboard event))
                       (define keycode (SDL_KeyboardEvent-key kb))
                       (if (= keycode SDLK_ESCAPE)
                           (begin
                             (set! running? #f)
                             (values curr-x curr-y #t))
                           (let-values ([(nx ny) (handle-key-down event curr-x curr-y)])
                             (event-loop nx ny)))]
                      [else
                       (event-loop curr-x curr-y)]))
                  (values curr-x curr-y #f))))

          ;; Render if still running
          (when running?
            ;; Update destination rect position
            (set-SDL_FRect-x! dst-rect new-x)
            (set-SDL_FRect-y! dst-rect new-y)

            ;; Clear to dark gray
            (SDL-SetRenderDrawColor renderer 40 40 40 255)
            (SDL-RenderClear renderer)

            ;; Draw the texture
            (SDL-RenderTexture renderer texture #f dst-rect)

            ;; Present
            (SDL-RenderPresent renderer)

            ;; Small delay (~60fps)
            (SDL-Delay 16)

            (loop new-x new-y)))))

    ;; Cleanup
    (lambda ()
      (when texture
        (SDL-DestroyTexture texture))
      ;; Note: SDL3_image no longer requires IMG_Quit
      (when renderer
        (SDL-DestroyRenderer renderer))
      (when window
        (SDL-DestroyWindow window))
      (SDL-Quit))))

;; Run
(main)
