#lang racket/base

;; SDL3 OpenGL Example - Spinning Triangle
;;
;; This example demonstrates using the external 'opengl' package with SDL3.
;; It requires the 'opengl' package to be installed:
;;   raco pkg install opengl
;;
;; We use lazy-require so this file can exist in the repository without
;; forcing 'opengl' as a dependency for the whole project.

(require racket/match
         racket/math
         racket/lazy-require
         sdl3)

;; Lazy require the OpenGL functions.
;; If 'opengl' is not installed, these identifiers will exist but
;; will raise an error when called.
(lazy-require
 [opengl (glClear
          glClearColor
          glViewport
          glMatrixMode
          glLoadIdentity
          glOrtho
          glRotatef
          glBegin
          glEnd
          glColor3f
          glVertex3f)])

(define window-width 800)
(define window-height 600)

(define (gl-const name)
  (dynamic-require 'opengl name))

(define (main)
  ;; Check if opengl is actually available before starting SDL
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (printf "Error: The 'opengl' package is required for this example.~n")
                     (printf "Please install it with: raco pkg install opengl~n")
                     (printf "Details: ~a~n" (exn-message e))
                     (exit 0))])
    ;; Trigger a load to see if it exists
    (dynamic-require 'opengl #f))

  (sdl-init!)

  ;; Set GL attributes
  (gl-set-attribute! SDL_GL_CONTEXT_MAJOR_VERSION 2)
  (gl-set-attribute! SDL_GL_CONTEXT_MINOR_VERSION 1)
  (gl-set-attribute! SDL_GL_DOUBLEBUFFER 1)
  (gl-set-attribute! SDL_GL_DEPTH_SIZE 24)

  (define window (make-window "SDL3 OpenGL Triangle" window-width window-height
                              #:flags (bitwise-ior SDL_WINDOW_RESIZABLE
                                                   SDL_WINDOW_OPENGL)))

  (define ctx (create-gl-context window))
  (gl-make-current! window ctx)
  (gl-set-swap-interval! 1)

  (printf "OpenGL context created.~n")

  ;; Initial GL setup
  (glViewport 0 0 window-width window-height)
  (glMatrixMode (gl-const 'GL_PROJECTION))
  (glLoadIdentity)
  (glOrtho -1.0 1.0 -1.0 1.0 -1.0 1.0)
  (glMatrixMode (gl-const 'GL_MODELVIEW))

  (define start-time (current-ticks))

  (let loop ([running? #t])
    (when running?
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]
            [(key-event 'down 'escape _ _ _) #f]
            [(window-event 'resized)
             (define-values (w h) (window-size window))
             (glViewport 0 0 w h)
             run?]
            [_ run?])))

      (when still-running?
        (define now (current-ticks))
        (define time-sec (/ (- now start-time) 1000.0))
        
        ;; Update rotation
        (glLoadIdentity)
        (glRotatef (* time-sec 90.0) 0.0 0.0 1.0)

        ;; Draw
        (glClearColor 0.1 0.1 0.1 1.0)
        (glClear (gl-const 'GL_COLOR_BUFFER_BIT))

        (glBegin (gl-const 'GL_TRIANGLES))
        
        (glColor3f 1.0 0.0 0.0)
        (glVertex3f 0.0 0.5 0.0)
        
        (glColor3f 0.0 1.0 0.0)
        (glVertex3f 0.5 -0.5 0.0)
        
        (glColor3f 0.0 0.0 1.0)
        (glVertex3f -0.5 -0.5 0.0)
        
        (glEnd)

        (gl-swap-window! window)
        (delay! 1)
        (loop still-running?))))

  (window-destroy! window)
  (sdl-quit!))

(module+ main
  (main))
