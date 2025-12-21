#lang racket/base

;; App Metadata Demo
;;
;; Shows SDL app metadata properties and how to set them before SDL_Init.
;; Press Esc to quit.

(require racket/match
         racket/format
         sdl3)

(define window-width 720)
(define window-height 420)

(define (metadata-pairs)
  (list (cons "name" (get-app-metadata-property SDL_PROP_APP_METADATA_NAME_STRING))
        (cons "version" (get-app-metadata-property SDL_PROP_APP_METADATA_VERSION_STRING))
        (cons "identifier" (get-app-metadata-property SDL_PROP_APP_METADATA_IDENTIFIER_STRING))
        (cons "creator" (get-app-metadata-property SDL_PROP_APP_METADATA_CREATOR_STRING))
        (cons "copyright" (get-app-metadata-property SDL_PROP_APP_METADATA_COPYRIGHT_STRING))
        (cons "url" (get-app-metadata-property SDL_PROP_APP_METADATA_URL_STRING))
        (cons "type" (get-app-metadata-property SDL_PROP_APP_METADATA_TYPE_STRING))))

(define (main)
  ;; Set metadata before SDL_Init.
  (set-app-metadata! "SDL3 Metadata Demo" "0.1.0" "com.example.sdl3.metadata-demo")
  (set-app-metadata-property! SDL_PROP_APP_METADATA_CREATOR_STRING "Racket SDL3 Examples")
  (set-app-metadata-property! SDL_PROP_APP_METADATA_URL_STRING "https://example.com")
  (set-app-metadata-property! SDL_PROP_APP_METADATA_TYPE_STRING "application")

  (sdl-init!)

  (define-values (window renderer)
    (make-window+renderer "SDL3 App Metadata" window-width window-height
                          #:window-flags SDL_WINDOW_RESIZABLE))

  (define running? #t)

  (let loop ()
    (when running?
      (for ([ev (in-events)])
        (match ev
          [(or (quit-event) (window-event 'close-requested))
           (set! running? #f)]
          [(key-event 'down 'escape _ _ _)
           (set! running? #f)]
          [_ (void)]))

      (set-draw-color! renderer 20 20 30)
      (render-clear! renderer)

      (set-draw-color! renderer 200 200 220)
      (render-debug-text! renderer 20 20 "APP METADATA")
      (render-debug-text! renderer 20 40 "Metadata set before SDL_Init.")
      (render-debug-text! renderer 20 60 "Press Esc to quit.")

      (for ([pair (in-list (metadata-pairs))]
            [i (in-naturals)])
        (define key (car pair))
        (define value (cdr pair))
        (render-debug-text! renderer 20 (+ 100 (* i 18))
                            (format "~a: ~a" key (or value "n/a"))))

      (render-present! renderer)
      (loop))))

(main)
