#lang racket/base

;; Idiomatic SDL_ttf helpers with custodian-based cleanup

(require ffi/unsafe
         ffi/unsafe/custodian
         racket/port
         "../raw.rkt"
         "../raw/ttf.rkt"
         "../private/constants.rkt"
         "texture.rkt"
         "window.rkt"
         "draw.rkt"
         "../private/safe-syntax.rkt")

(provide
 ;; Font management
 open-font
 open-font-io
 open-font-with-properties
 close-font!
 font?
 font-ptr
 font-destroy!
 copy-font
 add-fallback-font!
 remove-fallback-font!
 clear-fallback-fonts!

 ;; Font properties - getters
 font-size
 font-height
 font-ascent
 font-descent
 font-style
 font-outline
 font-hinting
 font-sdf?
 font-line-skip
 font-kerning?
 font-weight
 font-family-name
 font-style-name
 font-fixed-width?
 font-scalable?
 font-wrap-alignment
 font-direction
 font-properties
 font-generation

 ;; Font properties - setters
 set-font-style!
 set-font-outline!
 set-font-hinting!
 set-font-sdf!
 set-font-size!
 set-font-line-skip!
 set-font-kerning!
 set-font-wrap-alignment!
 set-font-direction!

 ;; Text measurement
 text-size
 text-size-wrapped
 measure-text

 ;; Text engines and objects
 make-renderer-text-engine
 make-renderer-text-engine-with-properties
 renderer-text-engine?
 renderer-text-engine-ptr
 renderer-text-engine-destroy!

 make-surface-text-engine
 surface-text-engine?
 surface-text-engine-ptr
 surface-text-engine-destroy!

 make-gpu-text-engine
 make-gpu-text-engine-with-properties
 gpu-text-engine?
 gpu-text-engine-ptr
 gpu-text-engine-destroy!
 gpu-text-engine-winding
 set-gpu-text-engine-winding!
 gpu-text-draw-data
 (struct-out gpu-text-draw-sequence)

 make-text
 text?
 text-ptr
 text-destroy!
 text-set-string!
 text-append-string!
 text-insert-string!
 text-delete-string!
 text-object-size
 text-color
 set-text-color!
 text-color-float
 set-text-color-float!
 text-position
 set-text-position!
 text-wrap-width
 set-text-wrap-width!
 text-wrap-whitespace-visible?
 set-text-wrap-whitespace-visible!
 text-properties
 text-engine
 set-text-engine!
 text-font
 set-text-font!
 text-direction
 set-text-direction!
 text-script
 set-text-script!
 update-text!
 draw-renderer-text!
 draw-surface-text!
 text-substring
 text-substring-for-line
 text-substrings-for-range
 text-substring-for-point
 text-substring-next
 text-substring-prev
 (struct-out text-substring-info)

 ;; Glyph operations
 font-has-glyph?
 glyph-metrics
 glyph-kerning

 ;; Rendering
 render-text
 draw-text!

 ;; Version info
 ttf-version
 freetype-version
 harfbuzz-version

 ;; TTF properties and flags
 TTF_PROP_FONT_CREATE_FILENAME_STRING
 TTF_PROP_FONT_CREATE_IOSTREAM_POINTER
 TTF_PROP_FONT_CREATE_IOSTREAM_OFFSET_NUMBER
 TTF_PROP_FONT_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN
 TTF_PROP_FONT_CREATE_SIZE_FLOAT
 TTF_PROP_FONT_CREATE_FACE_NUMBER
 TTF_PROP_FONT_CREATE_HORIZONTAL_DPI_NUMBER
 TTF_PROP_FONT_CREATE_VERTICAL_DPI_NUMBER
 TTF_PROP_FONT_CREATE_EXISTING_FONT
 TTF_PROP_FONT_OUTLINE_LINE_CAP_NUMBER
 TTF_PROP_FONT_OUTLINE_LINE_JOIN_NUMBER
 TTF_PROP_FONT_OUTLINE_MITER_LIMIT_NUMBER
 TTF_PROP_RENDERER_TEXT_ENGINE_RENDERER
 TTF_PROP_RENDERER_TEXT_ENGINE_ATLAS_TEXTURE_SIZE
 TTF_PROP_GPU_TEXT_ENGINE_DEVICE
 TTF_PROP_GPU_TEXT_ENGINE_ATLAS_TEXTURE_SIZE
 TTF_SUBSTRING_DIRECTION_MASK
 TTF_SUBSTRING_TEXT_START
 TTF_SUBSTRING_LINE_START
 TTF_SUBSTRING_LINE_END
 TTF_SUBSTRING_TEXT_END
 TTF_GPU_TEXTENGINE_WINDING_INVALID
 TTF_GPU_TEXTENGINE_WINDING_CLOCKWISE
 TTF_GPU_TEXTENGINE_WINDING_COUNTER_CLOCKWISE)

;; ==========================================================================
;; Font wrapper struct
;; ==========================================================================

(define-sdl-resource font TTF-CloseFont)

;; Text engine and text wrappers
(define-sdl-resource renderer-text-engine TTF-DestroyRendererTextEngine)
(define-sdl-resource surface-text-engine TTF-DestroySurfaceTextEngine)
(define-sdl-resource gpu-text-engine TTF-DestroyGPUTextEngine)
(define-sdl-resource text TTF-DestroyText)

;; Structured outputs for advanced text APIs
(struct gpu-text-draw-sequence (atlas-texture xy uv indices image-type) #:transparent)
(struct text-substring-info (flags offset length line-index cluster-index rect) #:transparent)

;; ==========================================================================
;; Initialization
;; ==========================================================================

;; NOTE: TTF initialization uses module-level mutable state.
;; SDL_ttf (like SDL itself) is not thread-safe and should only be
;; called from the main thread. If you need to use fonts from multiple
;; threads, render all text on the main thread.

(define ttf-initialized? #f)
(define ttf-shutdown-registered? #f)
(define ttf-shutdown-token (vector 'sdl3-ttf-shutdown))

(define (ensure-ttf-initialized! #:custodian [cust (current-custodian)])
  (unless ttf-initialized?
    (unless (TTF-Init)
      (error 'open-font "Failed to initialize SDL_ttf: ~a" (SDL-GetError)))
    (set! ttf-initialized? #t)

    ;; Tear down SDL_ttf when the custodian shuts down
    (unless ttf-shutdown-registered?
      (register-custodian-shutdown
       ttf-shutdown-token
       (λ (_)
         (when ttf-initialized?
           (TTF-Quit)
           (set! ttf-initialized? #f)))
       cust
       #:at-exit? #t)
      (set! ttf-shutdown-registered? #t))))

;; ==========================================================================
;; Font Management
;; ==========================================================================

(define (open-font path size
                   #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)

  (define ptr (TTF-OpenFont path (exact->inexact size)))
  (unless ptr
    (error 'open-font "Failed to load font ~a: ~a" path (SDL-GetError)))
  (wrap-font ptr #:custodian cust))

;; Open a font from an IOStream or bytes/port data
(define (open-font-io source size
                      #:close? [close? #t]
                      #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)

  (define (bytes->iostream bytes)
    (define len (bytes-length bytes))
    (define mem (malloc (max len 1) 'raw))
    (memcpy mem bytes len)
    (define stream (SDL-IOFromConstMem mem len))
    (unless stream
      (free mem)
      (error 'open-font-io "Failed to create IOStream: ~a" (SDL-GetError)))
    (values stream mem))

  (define (register-mem-cleanup mem stream)
    (define token (vector 'ttf-font-io mem stream close?))
    (register-custodian-shutdown
     token
     (λ (_)
       (when (and stream (not close?))
         (SDL-CloseIO stream))
       (free mem))
     cust
     #:at-exit? #t))

  (define (source->bytes who v)
    (cond
      [(bytes? v) v]
      [(input-port? v) (port->bytes v)]
      [else (error who "expected bytes or input port, got: ~a" v)]))

  (define ptr
    (cond
      [(or (bytes? source) (input-port? source))
       (define bytes (source->bytes 'open-font-io source))
       (define-values (stream mem) (bytes->iostream bytes))
       (define font-ptr (TTF-OpenFontIO stream close? (exact->inexact size)))
       (unless font-ptr
         (SDL-CloseIO stream)
         (free mem)
         (error 'open-font-io "Failed to load font from IOStream: ~a" (SDL-GetError)))
       (register-mem-cleanup mem stream)
       font-ptr]
      [(cpointer? source)
       (TTF-OpenFontIO source close? (exact->inexact size))]
      [else
       (error 'open-font-io
              "expected IOStream pointer, bytes, or input port, got: ~a" source)]))

  (unless ptr
    (error 'open-font-io "Failed to load font from IOStream: ~a" (SDL-GetError)))
  (wrap-font ptr #:custodian cust))

;; Open a font using SDL properties
(define (open-font-with-properties props
                                   #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)
  (define ptr (TTF-OpenFontWithProperties props))
  (unless ptr
    (error 'open-font-with-properties "Failed to open font: ~a" (SDL-GetError)))
  (wrap-font ptr #:custodian cust))

;; Alias for consistency with other modules
(define close-font! font-destroy!)

;; ==========================================================================
;; Rendering
;; ==========================================================================

(define (render-text f text color
                     #:renderer [rend #f]
                     #:mode [mode 'blended]
                     #:custodian [cust (current-custodian)])
  (unless rend
    (error 'render-text "renderer is required"))

  (when (font-destroyed? f)
    (error 'render-text "font is closed"))

  (if (string=? text "")
      #f
      (let ()
        (define sdl-color (color->SDL_Color color))

        ;; Render text to a surface using the selected quality mode
        (define surface
          (case mode
            [(solid) (TTF-RenderText-Solid (font-ptr f) text 0 sdl-color)]
            [(blended) (TTF-RenderText-Blended (font-ptr f) text 0 sdl-color)]
            [else (error 'render-text "unsupported mode: ~a" mode)]))

        (unless surface
          (error 'render-text "Failed to render text: ~a" (SDL-GetError)))

        ;; Check surface dimensions - textures are limited to 16384x16384
        (define w (SDL_Surface-w surface))
        (define h (SDL_Surface-h surface))
        (define max-size 16384)

        (cond
          [(or (> w max-size) (> h max-size))
           ;; Text too large for a texture - clean up and return #f
           (SDL-DestroySurface surface)
           #f]
          [else
           ;; Convert to a texture for rendering
           (define tex-ptr (SDL-CreateTextureFromSurface (renderer-ptr rend) surface))
           (SDL-DestroySurface surface)

           (unless tex-ptr
             (error 'render-text "Failed to create texture from text: ~a" (SDL-GetError)))

           (texture-from-pointer tex-ptr #:custodian cust)]))))

(define (draw-text! rend f text x y color
                    #:mode [mode 'blended]
                    #:custodian [cust (current-custodian)])
  (define tex (render-text f text color
                           #:renderer rend
                           #:mode mode
                           #:custodian cust))

  ;; Skip empty text
  (when tex
    (render-texture! rend tex x y)
    (texture-destroy! tex)))

;; ==========================================================================
;; Font Copy and Fallback Fonts
;; ==========================================================================

(define (copy-font f #:custodian [cust (current-custodian)])
  (when (font-destroyed? f)
    (error 'copy-font "font is closed"))
  (define ptr (TTF-CopyFont (font-ptr f)))
  (unless ptr
    (error 'copy-font "Failed to copy font: ~a" (SDL-GetError)))
  (wrap-font ptr #:custodian cust))

(define (add-fallback-font! f fallback)
  (when (font-destroyed? f)
    (error 'add-fallback-font! "primary font is closed"))
  (when (font-destroyed? fallback)
    (error 'add-fallback-font! "fallback font is closed"))
  (unless (TTF-AddFallbackFont (font-ptr f) (font-ptr fallback))
    (error 'add-fallback-font! "Failed to add fallback font: ~a" (SDL-GetError))))

(define (remove-fallback-font! f fallback)
  (when (font-destroyed? f)
    (error 'remove-fallback-font! "primary font is closed"))
  (when (font-destroyed? fallback)
    (error 'remove-fallback-font! "fallback font is closed"))
  (TTF-RemoveFallbackFont (font-ptr f) (font-ptr fallback)))

(define (clear-fallback-fonts! f)
  (when (font-destroyed? f)
    (error 'clear-fallback-fonts! "font is closed"))
  (TTF-ClearFallbackFonts (font-ptr f)))

;; ==========================================================================
;; Font Property Getters
;; ==========================================================================

(define (font-size f)
  (when (font-destroyed? f)
    (error 'font-size "font is closed"))
  (TTF-GetFontSize (font-ptr f)))

(define (font-height f)
  (when (font-destroyed? f)
    (error 'font-height "font is closed"))
  (TTF-GetFontHeight (font-ptr f)))

(define (font-ascent f)
  (when (font-destroyed? f)
    (error 'font-ascent "font is closed"))
  (TTF-GetFontAscent (font-ptr f)))

(define (font-descent f)
  (when (font-destroyed? f)
    (error 'font-descent "font is closed"))
  (TTF-GetFontDescent (font-ptr f)))

(define (font-style f)
  (when (font-destroyed? f)
    (error 'font-style "font is closed"))
  (define style (TTF-GetFontStyle (font-ptr f)))
  (style-flags->symbols style))

(define (font-outline f)
  (when (font-destroyed? f)
    (error 'font-outline "font is closed"))
  (TTF-GetFontOutline (font-ptr f)))

(define (font-hinting f)
  (when (font-destroyed? f)
    (error 'font-hinting "font is closed"))
  (hinting-int->symbol (TTF-GetFontHinting (font-ptr f))))

(define (font-sdf? f)
  (when (font-destroyed? f)
    (error 'font-sdf? "font is closed"))
  (TTF-GetFontSDF (font-ptr f)))

(define (font-line-skip f)
  (when (font-destroyed? f)
    (error 'font-line-skip "font is closed"))
  (TTF-GetFontLineSkip (font-ptr f)))

(define (font-kerning? f)
  (when (font-destroyed? f)
    (error 'font-kerning? "font is closed"))
  (TTF-GetFontKerning (font-ptr f)))

(define (font-weight f)
  (when (font-destroyed? f)
    (error 'font-weight "font is closed"))
  (TTF-GetFontWeight (font-ptr f)))

(define (font-family-name f)
  (when (font-destroyed? f)
    (error 'font-family-name "font is closed"))
  (TTF-GetFontFamilyName (font-ptr f)))

(define (font-style-name f)
  (when (font-destroyed? f)
    (error 'font-style-name "font is closed"))
  (TTF-GetFontStyleName (font-ptr f)))

(define (font-fixed-width? f)
  (when (font-destroyed? f)
    (error 'font-fixed-width? "font is closed"))
  (TTF-FontIsFixedWidth (font-ptr f)))

(define (font-scalable? f)
  (when (font-destroyed? f)
    (error 'font-scalable? "font is closed"))
  (TTF-FontIsScalable (font-ptr f)))

(define (font-wrap-alignment f)
  (when (font-destroyed? f)
    (error 'font-wrap-alignment "font is closed"))
  (alignment-int->symbol (TTF-GetFontWrapAlignment (font-ptr f))))

(define (font-direction f)
  (when (font-destroyed? f)
    (error 'font-direction "font is closed"))
  (direction-int->symbol (TTF-GetFontDirection (font-ptr f))))

(define (font-properties f)
  (when (font-destroyed? f)
    (error 'font-properties "font is closed"))
  (define props (TTF-GetFontProperties (font-ptr f)))
  (when (zero? props)
    (error 'font-properties "Failed to get font properties: ~a" (SDL-GetError)))
  props)

(define (font-generation f)
  (when (font-destroyed? f)
    (error 'font-generation "font is closed"))
  (define gen (TTF-GetFontGeneration (font-ptr f)))
  (when (zero? gen)
    (error 'font-generation "Failed to get font generation: ~a" (SDL-GetError)))
  gen)

;; ==========================================================================
;; Font Property Setters
;; ==========================================================================

(define (set-font-style! f . styles)
  (when (font-destroyed? f)
    (error 'set-font-style! "font is closed"))
  (define style-flags (symbols->style-flags styles))
  (TTF-SetFontStyle (font-ptr f) style-flags))

(define (set-font-outline! f pixels)
  (when (font-destroyed? f)
    (error 'set-font-outline! "font is closed"))
  (unless (TTF-SetFontOutline (font-ptr f) pixels)
    (error 'set-font-outline! "Failed to set outline: ~a" (SDL-GetError))))

(define (set-font-hinting! f mode)
  (when (font-destroyed? f)
    (error 'set-font-hinting! "font is closed"))
  (TTF-SetFontHinting (font-ptr f) (symbol->hinting-int mode)))

(define (set-font-sdf! f enabled?)
  (when (font-destroyed? f)
    (error 'set-font-sdf! "font is closed"))
  (unless (TTF-SetFontSDF (font-ptr f) enabled?)
    (error 'set-font-sdf! "Failed to set SDF mode: ~a" (SDL-GetError))))

(define (set-font-size! f size #:hdpi [hdpi #f] #:vdpi [vdpi #f])
  (when (font-destroyed? f)
    (error 'set-font-size! "font is closed"))
  (define result
    (if (and hdpi vdpi)
        (TTF-SetFontSizeDPI (font-ptr f) (exact->inexact size) hdpi vdpi)
        (TTF-SetFontSize (font-ptr f) (exact->inexact size))))
  (unless result
    (error 'set-font-size! "Failed to set font size: ~a" (SDL-GetError))))

(define (set-font-line-skip! f skip)
  (when (font-destroyed? f)
    (error 'set-font-line-skip! "font is closed"))
  (TTF-SetFontLineSkip (font-ptr f) skip))

(define (set-font-kerning! f enabled?)
  (when (font-destroyed? f)
    (error 'set-font-kerning! "font is closed"))
  (TTF-SetFontKerning (font-ptr f) enabled?))

(define (set-font-wrap-alignment! f alignment)
  (when (font-destroyed? f)
    (error 'set-font-wrap-alignment! "font is closed"))
  (TTF-SetFontWrapAlignment (font-ptr f) (symbol->alignment-int alignment)))

(define (set-font-direction! f direction)
  (when (font-destroyed? f)
    (error 'set-font-direction! "font is closed"))
  (unless (TTF-SetFontDirection (font-ptr f) (symbol->direction-int direction))
    (error 'set-font-direction! "Failed to set direction (HarfBuzz may not be available)")))

;; ==========================================================================
;; Text Measurement
;; ==========================================================================

(define (text-size f text)
  (when (font-destroyed? f)
    (error 'text-size "font is closed"))
  (define w-ptr (malloc _int))
  (define h-ptr (malloc _int))
  (unless (TTF-GetStringSize (font-ptr f) text 0 w-ptr h-ptr)
    (error 'text-size "Failed to measure text: ~a" (SDL-GetError)))
  (values (ptr-ref w-ptr _int) (ptr-ref h-ptr _int)))

(define (text-size-wrapped f text wrap-width)
  (when (font-destroyed? f)
    (error 'text-size-wrapped "font is closed"))
  (define w-ptr (malloc _int))
  (define h-ptr (malloc _int))
  (unless (TTF-GetStringSizeWrapped (font-ptr f) text 0 wrap-width w-ptr h-ptr)
    (error 'text-size-wrapped "Failed to measure wrapped text: ~a" (SDL-GetError)))
  (values (ptr-ref w-ptr _int) (ptr-ref h-ptr _int)))

(define (measure-text f text max-width)
  (when (font-destroyed? f)
    (error 'measure-text "font is closed"))
  (define width-ptr (malloc _int))
  (define length-ptr (malloc _size))
  (unless (TTF-MeasureString (font-ptr f) text 0 max-width width-ptr length-ptr)
    (error 'measure-text "Failed to measure text: ~a" (SDL-GetError)))
  (values (ptr-ref width-ptr _int) (ptr-ref length-ptr _size)))

;; ==========================================================================
;; Text Engines and Text Objects (Advanced)
;; ==========================================================================

(define (ensure-text-engine who engine)
  (cond
    [(not engine) #f]
    [(renderer-text-engine? engine) (renderer-text-engine-ptr engine)]
    [(surface-text-engine? engine) (surface-text-engine-ptr engine)]
    [(gpu-text-engine? engine) (gpu-text-engine-ptr engine)]
    [(cpointer? engine) engine]
    [else (error who "expected text engine or #f, got: ~a" engine)]))

(define (ensure-text who t)
  (cond
    [(text? t) (text-ptr t)]
    [(cpointer? t) t]
    [else (error who "expected text object or pointer, got: ~a" t)]))

(define (with-properties who builder proc)
  (define props (SDL-CreateProperties))
  (when (zero? props)
    (error who "Failed to create properties: ~a" (SDL-GetError)))
  (dynamic-wind
    void
    (λ ()
      (builder props)
      (proc props))
    (λ () (SDL-DestroyProperties props))))

(define (_->int v)
  (if (integer? v) v (inexact->exact (truncate v))))

(define (make-renderer-text-engine rend
                                   #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)
  (define ptr (TTF-CreateRendererTextEngine (renderer-ptr rend)))
  (unless ptr
    (error 'make-renderer-text-engine "Failed to create renderer text engine: ~a"
           (SDL-GetError)))
  (wrap-renderer-text-engine ptr #:custodian cust))

(define (make-renderer-text-engine-with-properties rend
                                                   #:atlas-size [atlas-size #f]
                                                   #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)
  (define ptr
    (with-properties
      'make-renderer-text-engine-with-properties
      (λ (props)
        (unless (SDL-SetPointerProperty props
                                        TTF_PROP_RENDERER_TEXT_ENGINE_RENDERER
                                        (renderer-ptr rend))
          (error 'make-renderer-text-engine-with-properties
                 "Failed to set renderer property: ~a" (SDL-GetError)))
        (when atlas-size
          (unless (SDL-SetNumberProperty props
                                         TTF_PROP_RENDERER_TEXT_ENGINE_ATLAS_TEXTURE_SIZE
                                         (_->int atlas-size))
            (error 'make-renderer-text-engine-with-properties
                   "Failed to set atlas size: ~a" (SDL-GetError)))))
      TTF-CreateRendererTextEngineWithProperties))
  (unless ptr
    (error 'make-renderer-text-engine-with-properties
           "Failed to create renderer text engine: ~a" (SDL-GetError)))
  (wrap-renderer-text-engine ptr #:custodian cust))

(define (make-surface-text-engine
         #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)
  (define ptr (TTF-CreateSurfaceTextEngine))
  (unless ptr
    (error 'make-surface-text-engine "Failed to create surface text engine: ~a"
           (SDL-GetError)))
  (wrap-surface-text-engine ptr #:custodian cust))

(define (make-gpu-text-engine device
                              #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)
  (define ptr (TTF-CreateGPUTextEngine device))
  (unless ptr
    (error 'make-gpu-text-engine "Failed to create GPU text engine: ~a"
           (SDL-GetError)))
  (wrap-gpu-text-engine ptr #:custodian cust))

(define (make-gpu-text-engine-with-properties device
                                              #:atlas-size [atlas-size #f]
                                              #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)
  (define ptr
    (with-properties
      'make-gpu-text-engine-with-properties
      (λ (props)
        (unless (SDL-SetPointerProperty props
                                        TTF_PROP_GPU_TEXT_ENGINE_DEVICE
                                        device)
          (error 'make-gpu-text-engine-with-properties
                 "Failed to set GPU device property: ~a" (SDL-GetError)))
        (when atlas-size
          (unless (SDL-SetNumberProperty props
                                         TTF_PROP_GPU_TEXT_ENGINE_ATLAS_TEXTURE_SIZE
                                         (_->int atlas-size))
            (error 'make-gpu-text-engine-with-properties
                   "Failed to set atlas size: ~a" (SDL-GetError)))))
      TTF-CreateGPUTextEngineWithProperties))
  (unless ptr
    (error 'make-gpu-text-engine-with-properties
           "Failed to create GPU text engine: ~a" (SDL-GetError)))
  (wrap-gpu-text-engine ptr #:custodian cust))

(define (gpu-text-engine-winding engine)
  (define w (TTF-GetGPUTextEngineWinding (gpu-text-engine-ptr engine)))
  (winding-int->symbol w))

(define (set-gpu-text-engine-winding! engine winding)
  (TTF-SetGPUTextEngineWinding (gpu-text-engine-ptr engine)
                               (symbol->winding-int winding)))

(define (read-fpoint-array ptr count)
  (define size (ctype-sizeof _SDL_FPoint))
  (for/list ([i (in-range count)])
    (define p (ptr-add ptr (* i size)))
    (list (ptr-ref p _float 0) (ptr-ref p _float 1))))

(define (read-int-array ptr count)
  (for/list ([i (in-range count)])
    (ptr-ref ptr _int i)))

(define (gpu-text-draw-data t)
  (define ptr (TTF-GetGPUTextDrawData (ensure-text 'gpu-text-draw-data t)))
  (if (not ptr)
      '()
      (let loop ([seq ptr] [acc '()])
        (define num-verts (TTF_GPUAtlasDrawSequence-num_vertices seq))
        (define num-indices (TTF_GPUAtlasDrawSequence-num_indices seq))
        (define xy-ptr (TTF_GPUAtlasDrawSequence-xy seq))
        (define uv-ptr (TTF_GPUAtlasDrawSequence-uv seq))
        (define indices-ptr (TTF_GPUAtlasDrawSequence-indices seq))
        (define next (TTF_GPUAtlasDrawSequence-next seq))
        (define item
          (gpu-text-draw-sequence
           (TTF_GPUAtlasDrawSequence-atlas_texture seq)
           (and xy-ptr (read-fpoint-array xy-ptr num-verts))
           (and uv-ptr (read-fpoint-array uv-ptr num-verts))
           (and indices-ptr (read-int-array indices-ptr num-indices))
           (TTF_GPUAtlasDrawSequence-image_type seq)))
        (if next
            (loop (cast next _pointer _TTF_GPUAtlasDrawSequence-pointer)
                  (cons item acc))
            (reverse (cons item acc))))))

(define (make-text f text
                   #:engine [engine #f]
                   #:custodian [cust (current-custodian)])
  (ensure-ttf-initialized! #:custodian cust)
  (when (font-destroyed? f)
    (error 'make-text "font is closed"))
  (define ptr (TTF-CreateText (ensure-text-engine 'make-text engine)
                              (font-ptr f)
                              text
                              0))
  (unless ptr
    (error 'make-text "Failed to create text: ~a" (SDL-GetError)))
  (wrap-text ptr #:custodian cust))

(define (text-set-string! t text)
  (unless (TTF-SetTextString (ensure-text 'text-set-string! t) text 0)
    (error 'text-set-string! "Failed to set text string: ~a" (SDL-GetError))))

(define (text-append-string! t text)
  (unless (TTF-AppendTextString (ensure-text 'text-append-string! t) text 0)
    (error 'text-append-string! "Failed to append text: ~a" (SDL-GetError))))

(define (text-insert-string! t offset text)
  (unless (TTF-InsertTextString (ensure-text 'text-insert-string! t) offset text 0)
    (error 'text-insert-string! "Failed to insert text: ~a" (SDL-GetError))))

(define (text-delete-string! t offset length)
  (unless (TTF-DeleteTextString (ensure-text 'text-delete-string! t) offset length)
    (error 'text-delete-string! "Failed to delete text: ~a" (SDL-GetError))))

(define (text-object-size t)
  (define w-ptr (malloc _int))
  (define h-ptr (malloc _int))
  (unless (TTF-GetTextSize (ensure-text 'text-object-size t) w-ptr h-ptr)
    (error 'text-object-size "Failed to get text size: ~a" (SDL-GetError)))
  (values (ptr-ref w-ptr _int) (ptr-ref h-ptr _int)))

(define (text-color t)
  (define r-ptr (malloc _uint8))
  (define g-ptr (malloc _uint8))
  (define b-ptr (malloc _uint8))
  (define a-ptr (malloc _uint8))
  (unless (TTF-GetTextColor (ensure-text 'text-color t) r-ptr g-ptr b-ptr a-ptr)
    (error 'text-color "Failed to get text color: ~a" (SDL-GetError)))
  (list (ptr-ref r-ptr _uint8)
        (ptr-ref g-ptr _uint8)
        (ptr-ref b-ptr _uint8)
        (ptr-ref a-ptr _uint8)))

(define (set-text-color! t color)
  (define c (color->SDL_Color color))
  (unless (TTF-SetTextColor (ensure-text 'set-text-color! t)
                            (SDL_Color-r c)
                            (SDL_Color-g c)
                            (SDL_Color-b c)
                            (SDL_Color-a c))
    (error 'set-text-color! "Failed to set text color: ~a" (SDL-GetError))))

(define (text-color-float t)
  (define r-ptr (malloc _float))
  (define g-ptr (malloc _float))
  (define b-ptr (malloc _float))
  (define a-ptr (malloc _float))
  (unless (TTF-GetTextColorFloat (ensure-text 'text-color-float t)
                                 r-ptr g-ptr b-ptr a-ptr)
    (error 'text-color-float "Failed to get text color: ~a" (SDL-GetError)))
  (list (ptr-ref r-ptr _float)
        (ptr-ref g-ptr _float)
        (ptr-ref b-ptr _float)
        (ptr-ref a-ptr _float)))

(define (set-text-color-float! t color)
  (define (color->rgba v)
    (cond
      [(and (list? v) (>= (length v) 3))
       (values (list-ref v 0) (list-ref v 1) (list-ref v 2)
               (if (>= (length v) 4) (list-ref v 3) 1.0))]
      [(and (vector? v) (>= (vector-length v) 3))
       (values (vector-ref v 0) (vector-ref v 1) (vector-ref v 2)
               (if (>= (vector-length v) 4) (vector-ref v 3) 1.0))]
      [else
       (error 'set-text-color-float!
              "color must be list or vector of 3 or 4 numbers")]))
  (define-values (r g b a) (color->rgba color))
  (unless (TTF-SetTextColorFloat (ensure-text 'set-text-color-float! t)
                                 (exact->inexact r)
                                 (exact->inexact g)
                                 (exact->inexact b)
                                 (exact->inexact a))
    (error 'set-text-color-float! "Failed to set text color: ~a" (SDL-GetError))))

(define (text-position t)
  (define x-ptr (malloc _int))
  (define y-ptr (malloc _int))
  (unless (TTF-GetTextPosition (ensure-text 'text-position t) x-ptr y-ptr)
    (error 'text-position "Failed to get text position: ~a" (SDL-GetError)))
  (values (ptr-ref x-ptr _int) (ptr-ref y-ptr _int)))

(define (set-text-position! t x y)
  (unless (TTF-SetTextPosition (ensure-text 'set-text-position! t) x y)
    (error 'set-text-position! "Failed to set text position: ~a" (SDL-GetError))))

(define (text-wrap-width t)
  (define w-ptr (malloc _int))
  (unless (TTF-GetTextWrapWidth (ensure-text 'text-wrap-width t) w-ptr)
    (error 'text-wrap-width "Failed to get wrap width: ~a" (SDL-GetError)))
  (ptr-ref w-ptr _int))

(define (set-text-wrap-width! t width)
  (unless (TTF-SetTextWrapWidth (ensure-text 'set-text-wrap-width! t) width)
    (error 'set-text-wrap-width! "Failed to set wrap width: ~a" (SDL-GetError))))

(define (text-wrap-whitespace-visible? t)
  (TTF-TextWrapWhitespaceVisible (ensure-text 'text-wrap-whitespace-visible? t)))

(define (set-text-wrap-whitespace-visible! t visible?)
  (unless (TTF-SetTextWrapWhitespaceVisible (ensure-text 'set-text-wrap-whitespace-visible! t)
                                            visible?)
    (error 'set-text-wrap-whitespace-visible!
           "Failed to set wrap whitespace visibility: ~a" (SDL-GetError))))

(define (text-properties t)
  (define props (TTF-GetTextProperties (ensure-text 'text-properties t)))
  (when (zero? props)
    (error 'text-properties "Failed to get text properties: ~a" (SDL-GetError)))
  props)

(define (text-engine t)
  (TTF-GetTextEngine (ensure-text 'text-engine t)))

(define (set-text-engine! t engine)
  (unless (TTF-SetTextEngine (ensure-text 'set-text-engine! t)
                             (ensure-text-engine 'set-text-engine! engine))
    (error 'set-text-engine! "Failed to set text engine: ~a" (SDL-GetError))))

(define (text-font t)
  (TTF-GetTextFont (ensure-text 'text-font t)))

(define (set-text-font! t f)
  (when (font-destroyed? f)
    (error 'set-text-font! "font is closed"))
  (unless (TTF-SetTextFont (ensure-text 'set-text-font! t) (font-ptr f))
    (error 'set-text-font! "Failed to set text font: ~a" (SDL-GetError))))

(define (text-direction t)
  (direction-int->symbol (TTF-GetTextDirection (ensure-text 'text-direction t))))

(define (set-text-direction! t direction)
  (unless (TTF-SetTextDirection (ensure-text 'set-text-direction! t)
                                (symbol->direction-int direction))
    (error 'set-text-direction! "Failed to set text direction: ~a" (SDL-GetError))))

(define (script->tag v)
  (cond
    [(integer? v) v]
    [(string? v) (TTF-StringToTag v)]
    [(symbol? v) (TTF-StringToTag (symbol->string v))]
    [else (error 'set-text-script! "script must be integer, string, or symbol")]))

(define (text-script t)
  (TTF-GetTextScript (ensure-text 'text-script t)))

(define (set-text-script! t script)
  (unless (TTF-SetTextScript (ensure-text 'set-text-script! t) (script->tag script))
    (error 'set-text-script! "Failed to set text script: ~a" (SDL-GetError))))

(define (update-text! t)
  (unless (TTF-UpdateText (ensure-text 'update-text! t))
    (error 'update-text! "Failed to update text: ~a" (SDL-GetError))))

(define (draw-renderer-text! t x y)
  (unless (TTF-DrawRendererText (ensure-text 'draw-renderer-text! t)
                                (exact->inexact x)
                                (exact->inexact y))
    (error 'draw-renderer-text! "Failed to draw renderer text: ~a" (SDL-GetError))))

(define (draw-surface-text! t x y surface)
  (unless (TTF-DrawSurfaceText (ensure-text 'draw-surface-text! t)
                               x y surface)
    (error 'draw-surface-text! "Failed to draw surface text: ~a" (SDL-GetError))))

(define (substring->struct ss)
  (define rect (TTF_SubString-rect ss))
  (text-substring-info (TTF_SubString-flags ss)
                       (TTF_SubString-offset ss)
                       (TTF_SubString-length ss)
                       (TTF_SubString-line_index ss)
                       (TTF_SubString-cluster_index ss)
                       (list (SDL_Rect-x rect)
                             (SDL_Rect-y rect)
                             (SDL_Rect-w rect)
                             (SDL_Rect-h rect))))

(define (text-substring t offset)
  (define ss (make-TTF_SubString 0 0 0 0 0 (make-SDL_Rect 0 0 0 0)))
  (unless (TTF-GetTextSubString (ensure-text 'text-substring t) offset ss)
    (error 'text-substring "Failed to get substring: ~a" (SDL-GetError)))
  (substring->struct ss))

(define (text-substring-for-line t line)
  (define ss (make-TTF_SubString 0 0 0 0 0 (make-SDL_Rect 0 0 0 0)))
  (unless (TTF-GetTextSubStringForLine (ensure-text 'text-substring-for-line t) line ss)
    (error 'text-substring-for-line "Failed to get substring: ~a" (SDL-GetError)))
  (substring->struct ss))

(define (text-substrings-for-range t offset length)
  (define-values (ptr count) (TTF-GetTextSubStringsForRange (ensure-text 'text-substrings-for-range t)
                                                           offset length))
  (if (not ptr)
      '()
      (begin0
        (for/list ([i (in-range count)])
          (define sptr (ptr-ref ptr _pointer i))
          (substring->struct (cast sptr _pointer _TTF_SubString-pointer)))
        (SDL-free ptr))))

(define (text-substring-for-point t x y)
  (define ss (make-TTF_SubString 0 0 0 0 0 (make-SDL_Rect 0 0 0 0)))
  (unless (TTF-GetTextSubStringForPoint (ensure-text 'text-substring-for-point t) x y ss)
    (error 'text-substring-for-point "Failed to get substring: ~a" (SDL-GetError)))
  (substring->struct ss))

(define (text-substring-prev t substring)
  (unless (text-substring-info? substring)
    (error 'text-substring-prev "expected text-substring-info, got: ~a" substring))
  (define prev (make-TTF_SubString 0 0 0 0 0 (make-SDL_Rect 0 0 0 0)))
  (define current (make-TTF_SubString (text-substring-info-flags substring)
                                      (text-substring-info-offset substring)
                                      (text-substring-info-length substring)
                                      (text-substring-info-line-index substring)
                                      (text-substring-info-cluster-index substring)
                                      (apply make-SDL_Rect (text-substring-info-rect substring))))
  (unless (TTF-GetPreviousTextSubString (ensure-text 'text-substring-prev t) current prev)
    (error 'text-substring-prev "Failed to get previous substring: ~a" (SDL-GetError)))
  (substring->struct prev))

(define (text-substring-next t substring)
  (unless (text-substring-info? substring)
    (error 'text-substring-next "expected text-substring-info, got: ~a" substring))
  (define next (make-TTF_SubString 0 0 0 0 0 (make-SDL_Rect 0 0 0 0)))
  (define current (make-TTF_SubString (text-substring-info-flags substring)
                                      (text-substring-info-offset substring)
                                      (text-substring-info-length substring)
                                      (text-substring-info-line-index substring)
                                      (text-substring-info-cluster-index substring)
                                      (apply make-SDL_Rect (text-substring-info-rect substring))))
  (unless (TTF-GetNextTextSubString (ensure-text 'text-substring-next t) current next)
    (error 'text-substring-next "Failed to get next substring: ~a" (SDL-GetError)))
  (substring->struct next))

;; ==========================================================================
;; Glyph Operations
;; ==========================================================================

(define (font-has-glyph? f ch)
  (when (font-destroyed? f)
    (error 'font-has-glyph? "font is closed"))
  (define codepoint (if (char? ch) (char->integer ch) ch))
  (TTF-FontHasGlyph (font-ptr f) codepoint))

(define (glyph-metrics f ch)
  (when (font-destroyed? f)
    (error 'glyph-metrics "font is closed"))
  (define codepoint (if (char? ch) (char->integer ch) ch))
  (define minx-ptr (malloc _int))
  (define maxx-ptr (malloc _int))
  (define miny-ptr (malloc _int))
  (define maxy-ptr (malloc _int))
  (define advance-ptr (malloc _int))
  (unless (TTF-GetGlyphMetrics (font-ptr f) codepoint
                                minx-ptr maxx-ptr miny-ptr maxy-ptr advance-ptr)
    (error 'glyph-metrics "Failed to get glyph metrics: ~a" (SDL-GetError)))
  (values (ptr-ref minx-ptr _int)
          (ptr-ref maxx-ptr _int)
          (ptr-ref miny-ptr _int)
          (ptr-ref maxy-ptr _int)
          (ptr-ref advance-ptr _int)))

(define (glyph-kerning f prev-ch ch)
  (when (font-destroyed? f)
    (error 'glyph-kerning "font is closed"))
  (define prev-codepoint (if (char? prev-ch) (char->integer prev-ch) prev-ch))
  (define codepoint (if (char? ch) (char->integer ch) ch))
  (define kerning-ptr (malloc _int))
  (unless (TTF-GetGlyphKerning (font-ptr f) prev-codepoint codepoint kerning-ptr)
    (error 'glyph-kerning "Failed to get glyph kerning: ~a" (SDL-GetError)))
  (ptr-ref kerning-ptr _int))

;; ==========================================================================
;; Version Information
;; ==========================================================================

(define (ttf-version)
  (define packed (TTF-Version))
  ;; SDL_VERSIONNUM format: major * 1000000 + minor * 1000 + patch
  (values (quotient packed 1000000)
          (quotient (remainder packed 1000000) 1000)
          (remainder packed 1000)))

(define (freetype-version)
  (define major-ptr (malloc _int))
  (define minor-ptr (malloc _int))
  (define patch-ptr (malloc _int))
  (TTF-GetFreeTypeVersion major-ptr minor-ptr patch-ptr)
  (values (ptr-ref major-ptr _int)
          (ptr-ref minor-ptr _int)
          (ptr-ref patch-ptr _int)))

(define (harfbuzz-version)
  (define major-ptr (malloc _int))
  (define minor-ptr (malloc _int))
  (define patch-ptr (malloc _int))
  (TTF-GetHarfBuzzVersion major-ptr minor-ptr patch-ptr)
  (define major (ptr-ref major-ptr _int))
  (define minor (ptr-ref minor-ptr _int))
  (define patch (ptr-ref patch-ptr _int))
  ;; Returns (values #f #f #f) if HarfBuzz is not available (all zeros)
  ;; Otherwise returns (values major minor patch)
  (if (and (= major 0) (= minor 0) (= patch 0))
      (values #f #f #f)
      (values major minor patch)))

;; ==========================================================================
;; Helper Functions for Enum Conversion
;; ==========================================================================

;; Style flags <-> symbols
(define (style-flags->symbols flags)
  (if (= flags TTF_STYLE_NORMAL)
      '(normal)
      (filter
       values
       (list (and (not (zero? (bitwise-and flags TTF_STYLE_BOLD))) 'bold)
             (and (not (zero? (bitwise-and flags TTF_STYLE_ITALIC))) 'italic)
             (and (not (zero? (bitwise-and flags TTF_STYLE_UNDERLINE))) 'underline)
             (and (not (zero? (bitwise-and flags TTF_STYLE_STRIKETHROUGH))) 'strikethrough)))))

(define (symbols->style-flags styles)
  (if (or (null? styles) (equal? styles '(normal)))
      TTF_STYLE_NORMAL
      (apply bitwise-ior
             (map (lambda (s)
                    (case s
                      [(normal) TTF_STYLE_NORMAL]
                      [(bold) TTF_STYLE_BOLD]
                      [(italic) TTF_STYLE_ITALIC]
                      [(underline) TTF_STYLE_UNDERLINE]
                      [(strikethrough) TTF_STYLE_STRIKETHROUGH]
                      [else (error 'set-font-style! "unknown style: ~a" s)]))
                  styles))))

;; Hinting mode <-> symbol
(define (hinting-int->symbol h)
  (cond
    [(= h TTF_HINTING_NORMAL) 'normal]
    [(= h TTF_HINTING_LIGHT) 'light]
    [(= h TTF_HINTING_MONO) 'mono]
    [(= h TTF_HINTING_NONE) 'none]
    [(= h TTF_HINTING_LIGHT_SUBPIXEL) 'light-subpixel]
    [else 'invalid]))

(define (symbol->hinting-int s)
  (case s
    [(normal) TTF_HINTING_NORMAL]
    [(light) TTF_HINTING_LIGHT]
    [(mono) TTF_HINTING_MONO]
    [(none) TTF_HINTING_NONE]
    [(light-subpixel) TTF_HINTING_LIGHT_SUBPIXEL]
    [else (error 'set-font-hinting! "unknown hinting mode: ~a" s)]))

;; Alignment <-> symbol
(define (alignment-int->symbol a)
  (cond
    [(= a TTF_HORIZONTAL_ALIGN_LEFT) 'left]
    [(= a TTF_HORIZONTAL_ALIGN_CENTER) 'center]
    [(= a TTF_HORIZONTAL_ALIGN_RIGHT) 'right]
    [else 'invalid]))

(define (symbol->alignment-int s)
  (case s
    [(left) TTF_HORIZONTAL_ALIGN_LEFT]
    [(center) TTF_HORIZONTAL_ALIGN_CENTER]
    [(right) TTF_HORIZONTAL_ALIGN_RIGHT]
    [else (error 'set-font-wrap-alignment! "unknown alignment: ~a" s)]))

;; Direction <-> symbol
(define (direction-int->symbol d)
  (cond
    [(= d TTF_DIRECTION_LTR) 'ltr]
    [(= d TTF_DIRECTION_RTL) 'rtl]
    [(= d TTF_DIRECTION_TTB) 'ttb]
    [(= d TTF_DIRECTION_BTT) 'btt]
    [else 'invalid]))

(define (symbol->direction-int s)
  (case s
    [(ltr) TTF_DIRECTION_LTR]
    [(rtl) TTF_DIRECTION_RTL]
    [(ttb) TTF_DIRECTION_TTB]
    [(btt) TTF_DIRECTION_BTT]
    [else (error 'set-font-direction! "unknown direction: ~a" s)]))

;; GPU text engine winding <-> symbol
(define (winding-int->symbol w)
  (cond
    [(= w TTF_GPU_TEXTENGINE_WINDING_CLOCKWISE) 'clockwise]
    [(= w TTF_GPU_TEXTENGINE_WINDING_COUNTER_CLOCKWISE) 'counter-clockwise]
    [else 'invalid]))

(define (symbol->winding-int s)
  (case s
    [(clockwise) TTF_GPU_TEXTENGINE_WINDING_CLOCKWISE]
    [(counter-clockwise) TTF_GPU_TEXTENGINE_WINDING_COUNTER_CLOCKWISE]
    [else (error 'set-gpu-text-engine-winding! "unknown winding: ~a" s)]))
