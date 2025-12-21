#lang racket/base

;; SDL3 OpenGL Example - Spinning 3D Cube
;;
;; This example demonstrates 3D rendering with depth buffering.
;; It requires the 'opengl' package to be installed:
;;   raco pkg install opengl

(require racket/match
         racket/math
         racket/lazy-require
         sdl3)

(lazy-require
 [opengl (glClear
          glClearColor
          glViewport
          glMatrixMode
          glLoadIdentity
          glFrustum
          glTranslatef
          glRotatef
          glBegin
          glEnd
          glColor3f
          glVertex3f
          glEnable)])

(define window-width 800)
(define window-height 600)

(define (gl-const name)
  (dynamic-require 'opengl name))

(define (main)
  ;; Check for opengl package
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (printf "Error: The 'opengl' package is required for this example.~n")
                     (printf "Please install it with: raco pkg install opengl~n")
                     (printf "Details: ~a~n" (exn-message e))
                     (exit 0))])
    (dynamic-require 'opengl #f))

  (sdl-init!)

  (gl-set-attribute! SDL_GL_CONTEXT_MAJOR_VERSION 2)
  (gl-set-attribute! SDL_GL_CONTEXT_MINOR_VERSION 1)
  (gl-set-attribute! SDL_GL_DOUBLEBUFFER 1)
  (gl-set-attribute! SDL_GL_DEPTH_SIZE 24)

  (define window (make-window "SDL3 OpenGL Cube" window-width window-height
                              #:flags (bitwise-ior SDL_WINDOW_RESIZABLE
                                                   SDL_WINDOW_OPENGL)))

  (define ctx (create-gl-context window))
  (gl-make-current! window ctx)
  (gl-set-swap-interval! 1)

  ;; Setup 3D perspective
  (glViewport 0 0 window-width window-height)
  (glMatrixMode (gl-const 'GL_PROJECTION))
  (glLoadIdentity)
  (glFrustum -1.0 1.0 -0.75 0.75 1.5 20.0)
  (glMatrixMode (gl-const 'GL_MODELVIEW))
  
  (glEnable (gl-const 'GL_DEPTH_TEST))

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
             ;; Re-calculate aspect ratio could go here
             run?]
            [_ run?])))

      (when still-running?
        (define now (current-ticks))
        (define t (/ (- now start-time) 1000.0))
        
        (glClearColor 0.2 0.2 0.2 1.0)
        (glClear (bitwise-ior (gl-const 'GL_COLOR_BUFFER_BIT) (gl-const 'GL_DEPTH_BUFFER_BIT)))
        
        (glLoadIdentity)
        (glTranslatef 0.0 0.0 -6.0)
        (glRotatef (* t 50.0) 1.0 1.0 0.0)
        
        (glBegin (gl-const 'GL_QUADS))
        
        ;; Front face (Red)
        (glColor3f 1.0 0.0 0.0)
        (glVertex3f -1.0 -1.0  1.0)
        (glVertex3f  1.0 -1.0  1.0)
        (glVertex3f  1.0  1.0  1.0)
        (glVertex3f -1.0  1.0  1.0)
        
        ;; Back face (Green)
        (glColor3f 0.0 1.0 0.0)
        (glVertex3f -1.0 -1.0 -1.0)
        (glVertex3f -1.0  1.0 -1.0)
        (glVertex3f  1.0  1.0 -1.0)
        (glVertex3f  1.0 -1.0 -1.0)
        
        ;; Top face (Blue)
        (glColor3f 0.0 0.0 1.0)
        (glVertex3f -1.0  1.0 -1.0)
        (glVertex3f -1.0  1.0  1.0)
        (glVertex3f  1.0  1.0  1.0)
        (glVertex3f  1.0  1.0 -1.0)
        
        ;; Bottom face (Yellow)
        (glColor3f 1.0 1.0 0.0)
        (glVertex3f -1.0 -1.0 -1.0)
        (glVertex3f  1.0 -1.0 -1.0)
        (glVertex3f  1.0 -1.0  1.0)
        (glVertex3f -1.0 -1.0  1.0)
        
        ;; Right face (Magenta)
        (glColor3f 1.0 0.0 1.0)
        (glVertex3f  1.0 -1.0 -1.0)
        (glVertex3f  1.0  1.0 -1.0)
        (glVertex3f  1.0  1.0  1.0)
        (glVertex3f  1.0 -1.0  1.0)
        
        ;; Left face (Cyan)
        (glColor3f 0.0 1.0 1.0)
        (glVertex3f -1.0 -1.0 -1.0)
        (glVertex3f -1.0 -1.0  1.0)
        (glVertex3f -1.0  1.0  1.0)
        (glVertex3f -1.0  1.0 -1.0)
        
        (glEnd)

        (gl-swap-window! window)
        (delay! 1)
        (loop still-running?))))

  (window-destroy! window)
  (sdl-quit!))

(module+ main
  (main))
