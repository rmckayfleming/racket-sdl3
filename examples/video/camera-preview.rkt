#lang racket/base

;; Camera Preview - Live Camera Feed
;;
;; Demonstrates camera enumeration, permission handling, and frame capture.
;; Press ESC to exit.
;; Press H/V to toggle horizontal/vertical flip.

(require racket/match
         sdl3)

(define (main)
  (sdl-init! '(video camera))

  (set-hint! 'render-vsync "1")

  (define-values (window renderer)
    (make-window+renderer "Camera Preview" 960 540))

  (with-handlers ([exn:fail?
                   (lambda (exn)
                     (printf "VSync not available: ~a~n" (exn-message exn))
                     #f)])
    (set-render-vsync! renderer 1))

  (define cameras (get-cameras))
  (unless (pair? cameras)
    (error 'camera-preview "No camera devices detected."))

  (for ([id (in-list cameras)])
    (printf "Camera ~a: ~a (~a)~n"
            id
            (or (camera-name id) "unknown")
            (camera-position id)))

  (define cam (open-camera (car cameras)))

  (define running? #t)
  (define flip-h? #f)
  (define flip-v? #f)
  (define last-tex #f)

  (let loop ()
    (for ([ev (in-events)])
      (match ev
        [(quit-event) (set! running? #f)]
        [(key-event 'down 'escape _ _ _) (set! running? #f)]
        [(key-event 'down 'h _ _ _) (set! flip-h? (not flip-h?))]
        [(key-event 'down 'v _ _ _) (set! flip-v? (not flip-v?))]
        [(camera-device-event 'denied _)
         (printf "Camera permission denied.~n")
         (set! running? #f)]
        [_ (void)]))

    (define perm (camera-permission-state cam))

    (set-draw-color! renderer 20 20 25)
    (render-clear! renderer)

    (cond
      [(eq? perm 'approved)
       (define frame (camera-acquire-frame cam))
       (when frame
         (define tex (camera-frame->texture renderer frame))
         (when last-tex
           (texture-destroy! last-tex))
         (set! last-tex tex)
         (camera-frame-release! frame))
       (define-values (win-w win-h) (window-size window))
       (define flip
         (cond
           [(and flip-h? flip-v?) 'both]
           [flip-h? 'horizontal]
           [flip-v? 'vertical]
           [else #f]))
       (cond
         [last-tex
          (render-texture! renderer last-tex 0 0 #:width win-w #:height win-h #:flip flip)]
         [else
          (set-draw-color! renderer 150 150 150)
          (render-debug-text! renderer 10 10 "Waiting for camera frames...")])]
      [(eq? perm 'denied)
       (set-draw-color! renderer 200 80 80)
       (render-debug-text! renderer 10 10 "Camera access denied")]
      [else
       (set-draw-color! renderer 150 150 150)
       (render-debug-text! renderer 10 10 "Waiting for camera permission...")])

    (render-present! renderer)
    (delay! 10)
    (when running?
      (loop)))

  (when last-tex
    (texture-destroy! last-tex))
  (camera-destroy! cam)
  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
