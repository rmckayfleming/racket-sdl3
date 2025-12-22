#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "texture" #:style 'quiet]{Textures}

This section covers texture loading, creation, manipulation, and rendering.
Textures are GPU-accelerated images that can be rendered efficiently.

@section{Loading Textures}

@defproc[(load-texture [renderer renderer?]
                       [source (or/c string? path? bytes? input-port?)]
                       [#:type type (or/c symbol? string? #f) #f]
                       [#:custodian cust custodian? (current-custodian)]) texture?]{
  Loads an image as a texture.

  The @racket[source] can be:
  @itemlist[
    @item{A file path (string or path)}
    @item{Bytes containing image data}
    @item{An input port}
  ]

  Supported formats include PNG, JPEG, BMP, GIF, and others via SDL_image.

  The @racket[#:type] hint specifies the image format when loading from bytes
  or a port. Use symbols like @racket['png], @racket['jpg], etc.

  @codeblock|{
    ;; Load from file
    (define tex (load-texture ren "sprites/player.png"))

    ;; Load from bytes with format hint
    (define tex2 (load-texture ren image-bytes #:type 'png))
  }|
}

@defproc[(texture? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a texture.
}

@defproc[(texture-ptr [tex texture?]) cpointer?]{
  Returns the underlying SDL texture pointer.
}

@defproc[(texture-destroy! [tex texture?]) void?]{
  Destroys a texture and frees its GPU resources.

  Note: Textures are automatically destroyed when their custodian shuts down,
  so manual destruction is usually not necessary.
}

@section{Creating Textures}

@defproc[(create-texture [renderer renderer?]
                         [width exact-nonnegative-integer?]
                         [height exact-nonnegative-integer?]
                         [#:access access (or/c 'static 'streaming 'target) 'target]
                         [#:scale scale (or/c 'nearest 'linear) 'nearest]
                         [#:format format exact-nonnegative-integer? SDL_PIXELFORMAT_RGBA8888]
                         [#:custodian cust custodian? (current-custodian)]) texture?]{
  Creates a blank texture with the specified dimensions.

  Access modes:
  @itemlist[
    @item{@racket['static] --- Texture rarely changes, not lockable}
    @item{@racket['streaming] --- Texture changes frequently, lockable for CPU access}
    @item{@racket['target] --- Can be used as a render target}
  ]

  Scale modes:
  @itemlist[
    @item{@racket['nearest] --- Nearest-neighbor sampling (pixelated look)}
    @item{@racket['linear] --- Linear filtering (smooth scaling)}
  ]

  @codeblock|{
    ;; Create a render target texture
    (define target (create-texture ren 256 256 #:access 'target))

    ;; Create a streaming texture for dynamic updates
    (define dynamic-tex (create-texture ren 64 64 #:access 'streaming))
  }|
}

@defproc[(texture-from-pointer [ptr cpointer?]
                                [#:custodian cust custodian? (current-custodian)]) texture?]{
  Wraps an existing SDL texture pointer in a texture struct.

  The texture will be registered with the custodian for automatic cleanup.
}

@section{Texture Properties}

@defproc[(texture-size [tex texture?]) (values real? real?)]{
  Returns the width and height of the texture in pixels.
}

@subsection{Scale Mode}

@defproc[(texture-set-scale-mode! [tex texture?] [mode (or/c 'nearest 'linear)]) void?]{
  Sets the scale mode for a texture.
}

@defproc[(texture-get-scale-mode [tex texture?]) symbol?]{
  Returns the current scale mode (@racket['nearest] or @racket['linear]).
}

@subsection{Blend Mode}

@defproc[(set-texture-blend-mode! [tex texture?]
                                   [mode (or/c symbol? exact-nonnegative-integer?)]) void?]{
  Sets the blend mode for a texture.

  Mode symbols include:
  @itemlist[
    @item{@racket['none] --- No blending}
    @item{@racket['blend] --- Alpha blending}
    @item{@racket['add] --- Additive blending}
    @item{@racket['mod] --- Color modulation}
    @item{@racket['mul] --- Multiplicative blending}
  ]
}

@defproc[(get-texture-blend-mode [tex texture?]) symbol?]{
  Returns the current blend mode as a symbol.
}

@section{Color and Alpha Modulation}

Color modulation tints the texture. Alpha modulation controls transparency.

@defproc[(texture-set-color-mod! [tex texture?]
                                  [r byte?] [g byte?] [b byte?]) void?]{
  Sets the color modulation (tint) for a texture.

  Values are 0-255. The default (255, 255, 255) means no tint.

  @codeblock|{
    ;; Tint texture red
    (texture-set-color-mod! tex 255 100 100)

    ;; Remove tint
    (texture-set-color-mod! tex 255 255 255)
  }|
}

@defproc[(texture-get-color-mod [tex texture?]) (values byte? byte? byte?)]{
  Returns the current color modulation values.
}

@defproc[(texture-set-alpha-mod! [tex texture?] [alpha byte?]) void?]{
  Sets the alpha modulation (transparency) for a texture.

  0 = fully transparent, 255 = fully opaque.
}

@defproc[(texture-get-alpha-mod [tex texture?]) byte?]{
  Returns the current alpha modulation value.
}

@subsection{Float Color/Alpha Modulation}

For extended range and precision, float versions are available:

@defproc[(texture-set-color-mod-float! [tex texture?]
                                        [r real?] [g real?] [b real?]) void?]{
  Sets color modulation using float values (typically 0.0-1.0).
}

@defproc[(texture-get-color-mod-float [tex texture?]) (values real? real? real?)]{
  Returns float color modulation values.
}

@defproc[(texture-set-alpha-mod-float! [tex texture?] [alpha real?]) void?]{
  Sets alpha modulation using a float value (typically 0.0-1.0).
}

@defproc[(texture-get-alpha-mod-float [tex texture?]) real?]{
  Returns float alpha modulation value.
}

@section{Rendering Textures}

@defproc[(render-texture! [renderer renderer?]
                          [texture texture?]
                          [x real?]
                          [y real?]
                          [#:width width (or/c real? #f) #f]
                          [#:height height (or/c real? #f) #f]
                          [#:src-x src-x (or/c real? #f) #f]
                          [#:src-y src-y (or/c real? #f) #f]
                          [#:src-w src-w (or/c real? #f) #f]
                          [#:src-h src-h (or/c real? #f) #f]
                          [#:angle angle (or/c real? #f) #f]
                          [#:center center (or/c (cons/c real? real?) #f) #f]
                          [#:flip flip (or/c 'none 'horizontal 'vertical 'both #f) #f]) void?]{
  Renders a texture at the specified position.

  Optional parameters:
  @itemlist[
    @item{@racket[#:width], @racket[#:height] --- Scale the texture to this size}
    @item{@racket[#:src-x], @racket[#:src-y], @racket[#:src-w], @racket[#:src-h] ---
          Render only a portion of the texture (sprite sheet support)}
    @item{@racket[#:angle] --- Rotation in degrees (clockwise)}
    @item{@racket[#:center] --- Rotation center as @racket[(cons x y)], defaults to texture center}
    @item{@racket[#:flip] --- Flip the texture horizontally, vertically, or both}
  ]

  @codeblock|{
    ;; Simple render at position
    (render-texture! ren tex 100 100)

    ;; Scale to specific size
    (render-texture! ren tex 100 100 #:width 64 #:height 64)

    ;; Render a sprite from a sprite sheet
    (render-texture! ren sprites 100 100
                     #:src-x (* frame 32) #:src-y 0
                     #:src-w 32 #:src-h 32)

    ;; Rotate 45 degrees
    (render-texture! ren tex 100 100 #:angle 45.0)

    ;; Flip horizontally (for character facing)
    (render-texture! ren tex 100 100 #:flip 'horizontal)
  }|
}

@defproc[(render-texture-affine! [renderer renderer?]
                                  [texture texture?]
                                  [origin (or/c (cons/c real? real?) #f)]
                                  [right (or/c (cons/c real? real?) #f)]
                                  [down (or/c (cons/c real? real?) #f)]
                                  [#:src-x src-x (or/c real? #f) #f]
                                  [#:src-y src-y (or/c real? #f) #f]
                                  [#:src-w src-w (or/c real? #f) #f]
                                  [#:src-h src-h (or/c real? #f) #f]) void?]{
  Renders a texture with an arbitrary affine transformation.

  This allows for skewing, shearing, and other 2D transformations.

  @itemlist[
    @item{@racket[origin] --- Where the top-left corner appears}
    @item{@racket[right] --- Where the top-right corner appears}
    @item{@racket[down] --- Where the bottom-left corner appears}
  ]

  The bottom-right is inferred from these three points.
}

@defproc[(render-texture-tiled! [renderer renderer?]
                                 [texture texture?]
                                 [dst-x real?]
                                 [dst-y real?]
                                 [dst-w real?]
                                 [dst-h real?]
                                 [#:scale scale real? 1.0]
                                 [#:src-x src-x (or/c real? #f) #f]
                                 [#:src-y src-y (or/c real? #f) #f]
                                 [#:src-w src-w (or/c real? #f) #f]
                                 [#:src-h src-h (or/c real? #f) #f]) void?]{
  Renders a texture tiled to fill a destination rectangle.

  Useful for repeating patterns like backgrounds and floors.

  @codeblock|{
    ;; Tile a grass texture across the ground
    (render-texture-tiled! ren grass-tex 0 400 800 200)
  }|
}

@defproc[(render-texture-9grid! [renderer renderer?]
                                 [texture texture?]
                                 [dst-x real?]
                                 [dst-y real?]
                                 [dst-w real?]
                                 [dst-h real?]
                                 [#:left-width left-width real?]
                                 [#:right-width right-width real?]
                                 [#:top-height top-height real?]
                                 [#:bottom-height bottom-height real?]
                                 [#:scale scale real? 1.0]
                                 [#:src-x src-x (or/c real? #f) #f]
                                 [#:src-y src-y (or/c real? #f) #f]
                                 [#:src-w src-w (or/c real? #f) #f]
                                 [#:src-h src-h (or/c real? #f) #f]) void?]{
  Renders a texture using 9-slice scaling.

  This is ideal for UI elements like buttons and panels that need to scale
  without distorting corners.

  The texture is divided into 9 regions: 4 corners (which don't scale),
  4 edges (which scale in one direction), and a center (which scales in both).
}

@section{Render Targets}

Textures created with @racket[#:access 'target] can be used as render targets,
allowing you to draw onto them instead of the screen.

@defproc[(set-render-target! [renderer renderer?] [texture (or/c texture? #f)]) void?]{
  Sets the current render target.

  Pass @racket[#f] to restore rendering to the default target (the window).

  @codeblock|{
    ;; Draw to an offscreen texture
    (define offscreen (create-texture ren 256 256 #:access 'target))
    (set-render-target! ren offscreen)
    (set-draw-color! ren 0 0 0)
    (render-clear! ren)
    (set-draw-color! ren 255 0 0)
    (fill-rect! ren 10 10 50 50)

    ;; Restore normal rendering and use the texture
    (set-render-target! ren #f)
    (render-texture! ren offscreen 100 100)
  }|
}

@defproc[(get-render-target [renderer renderer?]) (or/c texture? #f)]{
  Returns the current render target, or @racket[#f] if rendering to the window.
}

@defform[(with-render-target renderer texture body ...)]{
  Temporarily renders to a texture, then restores the previous target.

  @codeblock|{
    (with-render-target ren offscreen
      (set-draw-color! ren 0 0 0)
      (render-clear! ren)
      (draw-scene-to-texture!))
  }|
}

@section{Texture Updates and Locking}

For streaming textures, you can update pixel data directly.

@defproc[(texture-update! [texture texture?]
                          [pixels (or/c bytes? cpointer?)]
                          [pitch exact-nonnegative-integer?]
                          [#:rect rect (or/c (list/c real? real? real? real?) #f) #f]) void?]{
  Updates texture pixel data.

  @racket[pitch] is the number of bytes per row in the source data.
  @racket[rect] specifies the region to update as @racket[(list x y w h)],
  or @racket[#f] for the entire texture.
}

@defproc[(texture-lock! [texture texture?]
                        [#:rect rect (or/c (list/c real? real? real? real?) #f) #f])
         (values cpointer? exact-nonnegative-integer?)]{
  Locks a streaming texture for direct pixel access.

  Returns a pointer to the pixel data and the pitch (bytes per row).
  Call @racket[texture-unlock!] when done.
}

@defproc[(texture-unlock! [texture texture?]) void?]{
  Unlocks a texture after locking.
}

@defproc[(call-with-locked-texture [texture texture?]
                                    [proc (-> cpointer? exact-nonnegative-integer?
                                              exact-nonnegative-integer? exact-nonnegative-integer?
                                              any)]
                                    [#:rect rect (or/c (list/c real? real? real? real?) #f) #f]) any]{
  Locks a texture, calls the procedure, and unlocks it.

  The procedure receives: pixels-pointer, width, height, pitch.

  @codeblock|{
    (call-with-locked-texture tex
      (lambda (pixels w h pitch)
        ;; Modify pixels directly
        (for ([y (in-range h)])
          (for ([x (in-range w)])
            (define offset (+ (* y pitch) (* x 4)))
            ;; Set pixel to red (RGBA)
            (ptr-set! pixels _uint8 offset 255)
            (ptr-set! pixels _uint8 (+ offset 1) 0)
            (ptr-set! pixels _uint8 (+ offset 2) 0)
            (ptr-set! pixels _uint8 (+ offset 3) 255)))))
  }|
}

@section{Flip Mode Conversion}

@defproc[(symbol->flip-mode [sym symbol?]) exact-nonnegative-integer?]{
  Converts a flip mode symbol to its SDL constant.

  Symbols: @racket['none], @racket['horizontal] (or @racket['h]),
  @racket['vertical] (or @racket['v]), @racket['both] (or @racket['hv]).
}

@defproc[(flip-mode->symbol [mode exact-nonnegative-integer?]) symbol?]{
  Converts an SDL flip mode constant to a symbol.
}

@section{Access Mode Conversion}

@defproc[(symbol->texture-access [sym symbol?]) exact-nonnegative-integer?]{
  Converts an access mode symbol to its SDL constant.

  Symbols: @racket['static], @racket['streaming], @racket['target].
}

@defproc[(texture-access->symbol [mode exact-nonnegative-integer?]) symbol?]{
  Converts an SDL texture access constant to a symbol.
}

@section{Scale Mode Conversion}

@defproc[(symbol->scale-mode [sym symbol?]) exact-nonnegative-integer?]{
  Converts a scale mode symbol to its SDL constant.

  Symbols: @racket['nearest], @racket['linear].
}

@defproc[(scale-mode->symbol [mode exact-nonnegative-integer?]) symbol?]{
  Converts an SDL scale mode constant to a symbol.
}
