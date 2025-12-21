#lang racket/base

;; Error Handling Demo
;;
;; Demonstrates graceful error handling in SDL3 applications:
;; - Handling missing image files
;; - Handling missing font files
;; - Providing meaningful error messages
;; - Fallback rendering when resources fail to load
;;
;; This example intentionally tries to load non-existent files
;; to show how to handle errors gracefully.
;;
;; Controls:
;;   1 - Try to load missing image (handled)
;;   2 - Try to load missing font (handled)
;;   3 - Try to load valid image
;;   R - Reset/clear errors
;;   Escape - Quit

(require racket/match
         racket/format
         sdl3)

(define window-width 800)
(define window-height 600)
(define window-title "SDL3 Error Handling Demo")

;; Error state tracking
(define current-error #f)
(define current-texture #f)
(define current-font #f)
(define status-message "Press 1, 2, or 3 to test error handling")

;; Safely try to load a texture with error handling
;; Returns: (values texture error-message)
;; If successful, error-message is #f
;; If failed, texture is #f
(define (try-load-texture renderer path)
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (values #f (exn-message e)))])
    (values (load-texture renderer path) #f)))

;; Safely try to open a font with error handling
;; Returns: (values font error-message)
(define (try-open-font path size)
  (with-handlers ([exn:fail?
                   (lambda (e)
                     (values #f (exn-message e)))])
    (values (open-font path size) #f)))

;; Draw a placeholder when texture loading fails
(define (draw-texture-placeholder! renderer x y w h)
  ;; Crosshatch pattern background
  (set-draw-color! renderer 60 30 30)
  (fill-rect! renderer x y w h)

  ;; X pattern
  (set-draw-color! renderer 200 60 60)
  (draw-line! renderer x y (+ x w) (+ y h))
  (draw-line! renderer (+ x w) y x (+ y h))

  ;; Border
  (draw-rect! renderer x y w h)

  ;; "Missing" indicator
  (set-draw-color! renderer 255 100 100)
  (render-debug-text! renderer (+ x 10) (+ y (/ h 2) -4) "IMAGE NOT FOUND"))

;; Draw a placeholder text when font loading fails
(define (draw-font-placeholder! renderer x y text)
  ;; Use debug text with error styling
  (set-draw-color! renderer 255 100 100)
  (render-debug-text! renderer x y "[FONT ERROR]")
  (set-draw-color! renderer 180 180 180)
  (render-debug-text! renderer x (+ y 15) text))

;; Draw the main UI
(define (draw-ui! renderer)
  ;; Header
  (set-draw-color! renderer 40 40 50)
  (fill-rect! renderer 10 10 (- window-width 20) 60)

  (set-draw-color! renderer 255 255 255)
  (render-debug-text! renderer 20 18 "ERROR HANDLING DEMO")

  (set-draw-color! renderer 180 180 180)
  (render-debug-text! renderer 20 35 "Demonstrates graceful error recovery when loading resources")

  ;; Current status
  (set-draw-color! renderer 100 200 100)
  (render-debug-text! renderer 20 50 status-message))

;; Draw the test buttons/options
(define (draw-options! renderer)
  (set-draw-color! renderer 40 40 50)
  (fill-rect! renderer 10 80 350 100)

  (set-draw-color! renderer 200 200 100)
  (render-debug-text! renderer 20 90 "TEST OPTIONS:")

  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 20 110 "1 - Load missing image (shows error)")
  (render-debug-text! renderer 20 125 "2 - Load missing font (shows error)")
  (render-debug-text! renderer 20 140 "3 - Load valid image (should work)")
  (render-debug-text! renderer 20 155 "R - Reset | ESC - Quit"))

;; Draw error display area
(define (draw-error-area! renderer)
  (set-draw-color! renderer 30 30 40)
  (fill-rect! renderer 10 190 (- window-width 20) 150)

  (set-draw-color! renderer 80 80 100)
  (draw-rect! renderer 10 190 (- window-width 20) 150)

  (if current-error
      (let ([error-lines (string-split-lines current-error 90)])
        (set-draw-color! renderer 255 80 80)
        (render-debug-text! renderer 20 200 "ERROR CAUGHT:")
        (set-draw-color! renderer 200 150 150)
        ;; Wrap long error message
        (for ([line error-lines]
              [i (in-naturals)])
          (render-debug-text! renderer 20 (+ 220 (* i 15)) line)))
      (begin
        (set-draw-color! renderer 100 200 100)
        (render-debug-text! renderer 20 200 "No errors - resources loaded successfully"))))

;; Split a long string into lines of max-chars
(define (string-split-lines str max-chars)
  (define len (string-length str))
  (if (<= len max-chars)
      (list str)
      (let loop ([start 0] [lines '()])
        (if (>= start len)
            (reverse lines)
            (let ([end (min (+ start max-chars) len)])
              (loop end (cons (substring str start end) lines)))))))

;; Draw resource display area
(define (draw-resource-area! renderer)
  (set-draw-color! renderer 30 30 40)
  (fill-rect! renderer 10 350 (- window-width 20) 200)

  (set-draw-color! renderer 80 80 100)
  (draw-rect! renderer 10 350 (- window-width 20) 200)

  (set-draw-color! renderer 200 200 200)
  (render-debug-text! renderer 20 360 "LOADED RESOURCES:")

  ;; Texture area
  (if current-texture
      (begin
        (set-draw-color! renderer 100 200 100)
        (render-debug-text! renderer 20 380 "Texture: Loaded")
        (render-texture! renderer current-texture 20 400
                         #:width 150 #:height 100))
      (begin
        (set-draw-color! renderer 150 150 150)
        (render-debug-text! renderer 20 380 "Texture: None")
        ;; Show placeholder where texture would go
        (set-draw-color! renderer 50 50 60)
        (draw-rect! renderer 20 400 150 100)
        (set-draw-color! renderer 80 80 90)
        (render-debug-text! renderer 40 445 "[No texture]")))

  ;; Font area
  (set-draw-color! renderer 150 150 150)
  (render-debug-text! renderer 200 380
                      (if current-font "Font: Loaded" "Font: None"))

  (if current-font
      (draw-text! renderer current-font "Custom Font Text" 200 420 255 255 255)
      (begin
        (set-draw-color! renderer 80 80 90)
        (render-debug-text! renderer 200 420 "[No custom font loaded]"))))

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer window-title window-width window-height))

  (set-blend-mode! renderer 'blend)

  (let loop ([running? #t])
    (when running?
      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested)) #f]

            [(key-event 'down 'escape _ _ _) #f]

            [(key-event 'down key _ _ _)
             (cond
               ;; Test 1: Try to load a missing image
               [(eq? key '1)
                (set! status-message "Attempting to load missing image...")
                (define-values (tex err)
                  (try-load-texture renderer "examples/assets/nonexistent.png"))
                (if err
                    (begin
                      (set! current-error err)
                      (set! status-message "Image load failed (error caught)"))
                    (begin
                      (when current-texture (texture-destroy! current-texture))
                      (set! current-texture tex)
                      (set! current-error #f)
                      (set! status-message "Image loaded successfully")))
                run?]

               ;; Test 2: Try to load a missing font
               [(eq? key '2)
                (set! status-message "Attempting to load missing font...")
                (define-values (fnt err)
                  (try-open-font "examples/assets/nonexistent.ttf" 24))
                (if err
                    (begin
                      (set! current-error err)
                      (set! status-message "Font load failed (error caught)"))
                    (begin
                      (when current-font (font-destroy! current-font))
                      (set! current-font fnt)
                      (set! current-error #f)
                      (set! status-message "Font loaded successfully")))
                run?]

               ;; Test 3: Load a valid image
               [(eq? key '3)
                (set! status-message "Attempting to load valid image...")
                (define-values (tex err)
                  (try-load-texture renderer "examples/assets/test.png"))
                (if err
                    (begin
                      (set! current-error err)
                      (set! status-message "Image load failed unexpectedly"))
                    (begin
                      (when current-texture (texture-destroy! current-texture))
                      (set! current-texture tex)
                      (set! current-error #f)
                      (set! status-message "Image loaded successfully!")))
                run?]

               ;; Reset
               [(eq? key 'r)
                (when current-texture
                  (texture-destroy! current-texture)
                  (set! current-texture #f))
                (when current-font
                  (font-destroy! current-font)
                  (set! current-font #f))
                (set! current-error #f)
                (set! status-message "Reset - press 1, 2, or 3 to test")
                run?]

               [else run?])]

            [_ run?])))

      (when still-running?
        ;; Clear background
        (set-draw-color! renderer 25 25 35)
        (render-clear! renderer)

        ;; Draw UI components
        (draw-ui! renderer)
        (draw-options! renderer)
        (draw-error-area! renderer)
        (draw-resource-area! renderer)

        ;; Footer with best practices
        (set-draw-color! renderer 100 100 120)
        (render-debug-text! renderer 20 (- window-height 30)
                            "Best Practice: Always wrap resource loading in exception handlers")

        (render-present! renderer)
        (delay! 16)

        (loop still-running?))))

  ;; Clean up any loaded resources
  (when current-texture
    (texture-destroy! current-texture))
  (when current-font
    (font-destroy! current-font))

  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
