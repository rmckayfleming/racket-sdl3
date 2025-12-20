#lang racket/base

;; SDL3_ttf font properties example
;; Demonstrates: font metrics, text measurement, glyph info, styles, version info
;; Press keys 1-5 to toggle font styles, ESC to quit

(require racket/match
         racket/format
         racket/list
         sdl3)

(define window-width 900)
(define window-height 700)
(define font-path "/System/Library/Fonts/Supplemental/Arial.ttf")
(define base-font-size 24.0)

(define (main)
  (sdl-init!)

  ;; Create window and renderer
  (define-values (window renderer)
    (make-window+renderer "SDL3_ttf Font Properties"
                          window-width window-height
                          #:window-flags SDL_WINDOW_HIGH_PIXEL_DENSITY))

  ;; Scale font for high-DPI displays
  (define pixel-density (window-pixel-density window))
  (define scaled-font-size (* base-font-size pixel-density))
  (define font (open-font font-path scaled-font-size))
  (define small-font (open-font font-path (* 18.0 pixel-density)))

  ;; Colors
  (define white '(255 255 255 255))
  (define yellow '(255 255 0 255))
  (define cyan '(0 255 255 255))
  (define green '(0 255 0 255))
  (define gray '(128 128 128 255))

  ;; Current style state
  (define current-styles '(normal))

  ;; Helper to draw text and return height used
  (define (draw-line! y text color [f font])
    (draw-text! renderer f text 20 y color)
    (font-height f))

  ;; Helper to draw a labeled value
  (define (draw-labeled! y label value [color white])
    (draw-text! renderer small-font label 20 y gray)
    (draw-text! renderer small-font value 200 y color)
    (font-height small-font))

  (let loop ([running? #t])
    (when running?
      ;; Process events
      (define still-running?
        (for/fold ([run? #t])
                  ([ev (in-events)]
                   #:break (not run?))
          (match ev
            [(or (quit-event) (window-event 'close-requested))
             #f]
            [(key-event 'down key _ _ _)
             (cond
               [(= key SDLK_ESCAPE) #f]
               [(= key SDLK_1)
                (set! current-styles
                      (if (member 'bold current-styles)
                          (remove 'bold current-styles)
                          (cons 'bold current-styles)))
                (when (null? current-styles) (set! current-styles '(normal)))
                (apply set-font-style! font current-styles)
                run?]
               [(= key SDLK_2)
                (set! current-styles
                      (if (member 'italic current-styles)
                          (remove 'italic current-styles)
                          (cons 'italic current-styles)))
                (when (null? current-styles) (set! current-styles '(normal)))
                (apply set-font-style! font current-styles)
                run?]
               [(= key SDLK_3)
                (set! current-styles
                      (if (member 'underline current-styles)
                          (remove 'underline current-styles)
                          (cons 'underline current-styles)))
                (when (null? current-styles) (set! current-styles '(normal)))
                (apply set-font-style! font current-styles)
                run?]
               [(= key SDLK_4)
                (set! current-styles
                      (if (member 'strikethrough current-styles)
                          (remove 'strikethrough current-styles)
                          (cons 'strikethrough current-styles)))
                (when (null? current-styles) (set! current-styles '(normal)))
                (apply set-font-style! font current-styles)
                run?]
               [(= key SDLK_5)
                (set! current-styles '(normal))
                (set-font-style! font 'normal)
                run?]
               [else run?])]
            [_ run?])))

      (when still-running?
        ;; Clear background
        (set-draw-color! renderer 30 30 40)
        (render-clear! renderer)

        ;; Update current styles from font (in case they changed)
        (set! current-styles (font-style font))

        (define y 20)

        ;; Title
        (set! y (+ y (draw-line! y "Font Properties Demo" yellow)))
        (set! y (+ y 10))

        ;; Version information
        (define-values (ttf-major ttf-minor ttf-patch) (ttf-version))
        (define-values (ft-major ft-minor ft-patch) (freetype-version))
        (define-values (hb-major hb-minor hb-patch) (harfbuzz-version))

        (set! y (+ y (draw-labeled! y "SDL_ttf:" (~a ttf-major "." ttf-minor "." ttf-patch) cyan)))
        (set! y (+ y (draw-labeled! y "FreeType:" (~a ft-major "." ft-minor "." ft-patch) cyan)))
        (set! y (+ y (draw-labeled! y "HarfBuzz:"
                                     (if hb-major
                                         (~a hb-major "." hb-minor "." hb-patch)
                                         "not available")
                                     cyan)))
        (set! y (+ y 15))

        ;; Font metadata
        (draw-text! renderer small-font "--- Font Metadata ---" 20 y yellow)
        (set! y (+ y (font-height small-font) 5))

        (set! y (+ y (draw-labeled! y "Family:" (font-family-name font) green)))
        (set! y (+ y (draw-labeled! y "Style name:" (font-style-name font) green)))
        (set! y (+ y (draw-labeled! y "Fixed width?:" (~a (font-fixed-width? font)) green)))
        (set! y (+ y (draw-labeled! y "Scalable?:" (~a (font-scalable? font)) green)))
        (set! y (+ y (draw-labeled! y "Weight:" (~a (font-weight font)) green)))
        (set! y (+ y 15))

        ;; Font metrics
        (draw-text! renderer small-font "--- Font Metrics ---" 20 y yellow)
        (set! y (+ y (font-height small-font) 5))

        (set! y (+ y (draw-labeled! y "Size:" (~a (font-size font) " pt") green)))
        (set! y (+ y (draw-labeled! y "Height:" (~a (font-height font) " px") green)))
        (set! y (+ y (draw-labeled! y "Ascent:" (~a (font-ascent font) " px") green)))
        (set! y (+ y (draw-labeled! y "Descent:" (~a (font-descent font) " px") green)))
        (set! y (+ y (draw-labeled! y "Line skip:" (~a (font-line-skip font) " px") green)))
        (set! y (+ y 15))

        ;; Font settings
        (draw-text! renderer small-font "--- Font Settings ---" 20 y yellow)
        (set! y (+ y (font-height small-font) 5))

        (set! y (+ y (draw-labeled! y "Current styles:" (~a current-styles) green)))
        (set! y (+ y (draw-labeled! y "Hinting:" (~a (font-hinting font)) green)))
        (set! y (+ y (draw-labeled! y "Kerning?:" (~a (font-kerning? font)) green)))
        (set! y (+ y (draw-labeled! y "Outline:" (~a (font-outline font) " px") green)))
        (set! y (+ y (draw-labeled! y "SDF mode?:" (~a (font-sdf? font)) green)))
        (set! y (+ y (draw-labeled! y "Wrap align:" (~a (font-wrap-alignment font)) green)))
        (set! y (+ y (draw-labeled! y "Direction:" (~a (font-direction font)) green)))
        (set! y (+ y 15))

        ;; Text measurement
        (draw-text! renderer small-font "--- Text Measurement ---" 20 y yellow)
        (set! y (+ y (font-height small-font) 5))

        (define sample-text "Hello, SDL3_ttf!")
        (define-values (text-w text-h) (text-size font sample-text))
        (set! y (+ y (draw-labeled! y "Sample text:" sample-text cyan)))
        (set! y (+ y (draw-labeled! y "Measured size:" (~a text-w " x " text-h " px") green)))

        (define-values (fit-w fit-len) (measure-text font sample-text 100))
        (set! y (+ y (draw-labeled! y "Fits in 100px:" (~a fit-len " chars, " fit-w " px wide") green)))
        (set! y (+ y 15))

        ;; Glyph information
        (draw-text! renderer small-font "--- Glyph Info (letter 'W') ---" 20 y yellow)
        (set! y (+ y (font-height small-font) 5))

        (define test-char #\W)
        (set! y (+ y (draw-labeled! y "Has glyph?:" (~a (font-has-glyph? font test-char)) green)))

        (when (font-has-glyph? font test-char)
          (define-values (minx maxx miny maxy advance) (glyph-metrics font test-char))
          (set! y (+ y (draw-labeled! y "Min X:" (~a minx) green)))
          (set! y (+ y (draw-labeled! y "Max X:" (~a maxx) green)))
          (set! y (+ y (draw-labeled! y "Min Y:" (~a miny) green)))
          (set! y (+ y (draw-labeled! y "Max Y:" (~a maxy) green)))
          (set! y (+ y (draw-labeled! y "Advance:" (~a advance " px") green)))

          ;; Kerning between 'A' and 'W'
          (define kern (glyph-kerning font #\A #\W))
          (set! y (+ y (draw-labeled! y "Kern A->W:" (~a kern " px") green))))

        (set! y (+ y 20))

        ;; Sample styled text
        (draw-text! renderer small-font "--- Sample Styled Text ---" 20 y yellow)
        (set! y (+ y (font-height small-font) 5))
        (draw-text! renderer font "The quick brown fox jumps over the lazy dog." 20 y white)
        (set! y (+ y (font-height font) 10))

        ;; Instructions
        (draw-text! renderer small-font "Press 1=Bold, 2=Italic, 3=Underline, 4=Strikethrough, 5=Reset, ESC=Quit"
                    20 (- window-height 40) gray)

        (render-present! renderer)

        (loop still-running?))))

  ;; Clean up
  (close-font! small-font)
  (close-font! font)
  (renderer-destroy! renderer)
  (window-destroy! window))

;; Run when executed directly
(module+ main
  (main))
