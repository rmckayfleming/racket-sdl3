#lang racket/base

;; SDL3 OpenGL Example
;;
;; Demonstrates creating an OpenGL context and basic clearing/swapping.
;; Note: This only uses SDL's GL context functions. To do actual drawing,
;; you would typically use a library like 'opengl' or direct FFI calls to GL.
;; Here we just use SDL's minimal context management.

(require racket/match
         sdl3)

;; You would normally require 'opengl' here for glClearColor, etc.
;; Since we don't want to add a dependency on the 'opengl' package just for this
;; basic binding test, we'll just demonstrate context creation and swapping.
;; The clear color will likely be black or undefined, but the swap should work.

(define window-width 800)
(define window-height 600)

(define (main)
  (sdl-init!)

  ;; Set GL attributes *before* creating the window
  (gl-set-attribute! SDL_GL_CONTEXT_MAJOR_VERSION 3)
  (gl-set-attribute! SDL_GL_CONTEXT_MINOR_VERSION 3)
  (gl-set-attribute! SDL_GL_CONTEXT_PROFILE_MASK SDL_GL_CONTEXT_PROFILE_CORE)
  (gl-set-attribute! SDL_GL_DOUBLEBUFFER 1)
  (gl-set-attribute! SDL_GL_DEPTH_SIZE 24)

  ;; Create window with OpenGL flag
  (define window (make-window "SDL3 OpenGL Window" window-width window-height
                              #:flags (bitwise-ior SDL_WINDOW_RESIZABLE
                                                   SDL_WINDOW_OPENGL)))

  ;; Create OpenGL context
  (printf "Creating OpenGL context...~n")
  (define ctx (create-gl-context window))
  (gl-make-current! window ctx)

  ;; Enable VSync
  (gl-set-swap-interval! 1)

  (printf "OpenGL context created successfully.~n")
  (printf "Window: ~a~n" window)
  (printf "Context: ~a~n" ctx)

  (let loop ([running? #t])
    (when running?
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down 'escape _ _ _) #f]
            [_ run?])))

      (when still-running?
        ;; In a real app: (glClearColor 0.2 0.3 0.3 1.0)
        ;; In a real app: (glClear GL_COLOR_BUFFER_BIT)
        
        ;; Swap buffers
        (gl-swap-window! window)
        
        ;; Small sleep to yield CPU if VSync isn't active
        (delay! 1)
        (loop still-running?))))

  (window-destroy! window)
  (sdl-quit!))

(module+ main
  (main))
