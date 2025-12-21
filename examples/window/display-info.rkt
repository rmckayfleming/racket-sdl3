#lang racket/base

;; Display Information Demo
;;
;; Demonstrates the display management API to query monitor information.
;; Useful for multi-monitor setups, fullscreen mode selection, and HiDPI handling.
;;
;; Controls:
;;   Tab - Cycle through displays (for multi-monitor setups)
;;   F   - Toggle fullscreen
;;   ESC - Quit

(require racket/match
         racket/format
         ffi/unsafe
         sdl3
         sdl3/raw)

;; State
(define selected-display 0)
(define display-list '())

(define (main)
  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 Display Info" 600 400
                          #:window-flags SDL_WINDOW_RESIZABLE))

  ;; Get display list
  (set! display-list (get-displays))

  ;; Print info to console
  (printf "Found ~a display(s)~n~n" (length display-list))
  (for ([display-id (in-list display-list)]
        [i (in-naturals)])
    (define mode (current-display-mode display-id))
    (printf "Display ~a: ~a~n" i (display-name display-id))
    (printf "  Resolution: ~ax~a @ ~aHz~n"
            (SDL_DisplayMode-w mode)
            (SDL_DisplayMode-h mode)
            (~r (SDL_DisplayMode-refresh_rate mode) #:precision 1))
    (printf "  Scale: ~ax~n~n"
            (~r (display-content-scale display-id) #:precision 2)))

  (let loop ()
    (define quit?
      (for/or ([ev (in-events)])
        (match ev
          [(quit-event) #t]
          [(key-event 'down 'escape _ _ _) #t]
          [(key-event 'down 'tab _ _ _)
           (set! selected-display (modulo (add1 selected-display) (length display-list)))
           #f]
          [(key-event 'down 'f _ _ _)
           (window-set-fullscreen! window (not (window-fullscreen? window)))
           #f]
          [_ #f])))

    (unless quit?
      (set-draw-color! renderer 30 30 40)
      (render-clear! renderer)

      ;; Get current display info
      (define display-id (list-ref display-list selected-display))
      (define name (display-name display-id))
      (define mode (current-display-mode display-id))
      (define-values (mw mh) (display-mode-resolution mode))
      (define refresh (display-mode-refresh-rate mode))
      (define scale (display-content-scale display-id))
      (define primary? (= display-id (primary-display)))
      (define-values (bx by bw bh) (display-bounds display-id))
      (define-values (ux uy uw uh) (display-usable-bounds display-id))

      ;; Window info
      (define win-display (window-display window))
      (define win-scale (window-display-scale window))

      ;; Draw display info
      (define y 20)
      (define (line! text [color '(200 200 200)])
        (apply set-draw-color! renderer color)
        (render-debug-text! renderer 20 y text)
        (set! y (+ y 18)))

      (line! (~a "DISPLAY " selected-display (if primary? " (Primary)" "")) '(100 180 255))
      (line! name '(150 150 150))
      (set! y (+ y 8))

      (line! (~a "Resolution: " mw "x" mh " @ " (~r refresh #:precision 1) "Hz"))
      (line! (~a "Scale: " (~r scale #:precision 2) "x"))
      (line! (~a "Bounds: " bx "," by " - " bw "x" bh))
      (line! (~a "Usable: " ux "," uy " - " uw "x" uh))
      (set! y (+ y 8))

      (line! "WINDOW" '(100 180 255))
      (line! (~a "On display: " (display-name win-display)))
      (line! (~a "Window scale: " (~r win-scale #:precision 2) "x"))
      (line! (~a "Fullscreen: " (if (window-fullscreen? window) "Yes" "No")))
      (set! y (+ y 8))

      ;; Show a few fullscreen modes
      (line! "FULLSCREEN MODES (first 5)" '(100 180 255))
      (define modes (fullscreen-display-modes display-id))
      (for ([mode (in-list modes)]
            [i (in-range 5)])
        (define mode-ptr (cast mode _pointer _SDL_DisplayMode-pointer))
        (line! (~a "  " (SDL_DisplayMode-w mode-ptr) "x" (SDL_DisplayMode-h mode-ptr)
                   " @ " (~r (SDL_DisplayMode-refresh_rate mode-ptr) #:precision 1) "Hz")))

      ;; Instructions
      (set-draw-color! renderer 100 100 100)
      (render-debug-text! renderer 20 370 "Tab: Next display | F: Fullscreen | ESC: Quit")

      (render-present! renderer)
      (delay! 16)
      (loop)))

  (renderer-destroy! renderer)
  (window-destroy! window))

(module+ main
  (main))
