#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "drawing" #:style 'quiet]{Drawing}

This section covers 2D drawing operations: colors, shapes, and rendering.

@section{Basic Rendering}

@defproc[(render-clear! [ren renderer?]) void?]{
  Clears the entire rendering target with the current draw color.
  Call this at the start of each frame before drawing.
}

@defproc[(render-present! [ren renderer?]) void?]{
  Displays the rendered content to the screen.
  Call this at the end of each frame after all drawing is complete.
}

The basic rendering pattern is:

@codeblock|{
  ;; Each frame:
  (set-draw-color! ren 0 0 0)   ; Black background
  (render-clear! ren)
  ;; ... draw shapes, textures, text ...
  (render-present! ren)
}|

@section{Colors}

@defproc[(set-draw-color! [ren renderer?]
                          [r (integer-in 0 255)]
                          [g (integer-in 0 255)]
                          [b (integer-in 0 255)]
                          [a (integer-in 0 255) 255])
         void?]{
  Sets the color used for drawing operations. Color components are integers
  from 0 to 255.

  @itemlist[
    @item{@racket[r] --- Red component}
    @item{@racket[g] --- Green component}
    @item{@racket[b] --- Blue component}
    @item{@racket[a] --- Alpha (opacity), 255 = fully opaque (default)}
  ]

  @codeblock|{
    (set-draw-color! ren 255 0 0)       ; Red
    (set-draw-color! ren 0 255 0 128)   ; Semi-transparent green
  }|
}

@defproc[(get-draw-color [ren renderer?])
         (values (integer-in 0 255)
                 (integer-in 0 255)
                 (integer-in 0 255)
                 (integer-in 0 255))]{
  Returns the current draw color as four values: r, g, b, a.
}

@defproc[(set-draw-color-float! [ren renderer?]
                                [r real?]
                                [g real?]
                                [b real?]
                                [a real? 1.0])
         void?]{
  Sets the draw color using floating-point values. Standard range is 0.0 to 1.0,
  but values can exceed 1.0 for HDR rendering.
}

@defproc[(get-draw-color-float [ren renderer?])
         (values real? real? real? real?)]{
  Returns the current draw color as four floating-point values.
}

@defproc[(color->SDL_Color [color (or/c list? vector?)]) any/c]{
  Converts a color specification to an SDL_Color struct. Accepts:
  @itemlist[
    @item{A list @racket['(r g b)] or @racket['(r g b a)]}
    @item{A vector @racket[#(r g b)] or @racket[#(r g b a)]}
  ]
  If alpha is omitted, it defaults to 255.
}

@section{Blend Modes}

@defproc[(set-blend-mode! [ren renderer?]
                          [mode (or/c 'none 'blend 'add 'mod 'mul symbol?)])
         void?]{
  Sets the blend mode for drawing operations.

  @itemlist[
    @item{@racket['none] --- No blending, overwrites destination}
    @item{@racket['blend] (or @racket['alpha]) --- Standard alpha blending}
    @item{@racket['add] (or @racket['additive]) --- Additive blending (good for glow effects)}
    @item{@racket['mod] (or @racket['modulate]) --- Color modulation}
    @item{@racket['mul] (or @racket['multiply]) --- Multiply blending}
  ]
}

@defproc[(get-blend-mode [ren renderer?])
         (or/c 'none 'blend 'add 'mod 'mul symbol?)]{
  Returns the current blend mode as a symbol.
}

@defproc[(symbol->blend-mode [sym symbol?]) exact-integer?]{
  Converts a blend mode symbol to its SDL constant value.
}

@defproc[(blend-mode->symbol [mode exact-integer?]) symbol?]{
  Converts an SDL blend mode constant to a symbol.
}

@section{Drawing Shapes}

All shape-drawing functions use the current draw color set by @racket[set-draw-color!].
Coordinates can be integers or floats.

@subsection{Points}

@defproc[(draw-point! [ren renderer?] [x real?] [y real?]) void?]{
  Draws a single point at the given coordinates.
}

@defproc[(draw-points! [ren renderer?]
                       [points (listof (or/c (list/c real? real?)
                                             (vector/c real? real?)))])
         void?]{
  Draws multiple points. Each point can be a list @racket['(x y)] or
  vector @racket[#(x y)].

  @codeblock|{
    (draw-points! ren '((100 100) (150 120) (200 100)))
  }|
}

@subsection{Lines}

@defproc[(draw-line! [ren renderer?]
                     [x1 real?] [y1 real?]
                     [x2 real?] [y2 real?])
         void?]{
  Draws a line from (x1, y1) to (x2, y2).
}

@defproc[(draw-lines! [ren renderer?]
                      [points (listof (or/c (list/c real? real?)
                                            (vector/c real? real?)))])
         void?]{
  Draws connected line segments through a list of points.

  @codeblock|{
    ;; Draw a triangle outline
    (draw-lines! ren '((100 200) (200 100) (300 200) (100 200)))
  }|
}

@subsection{Rectangles}

@defproc[(draw-rect! [ren renderer?]
                     [x real?] [y real?]
                     [w real?] [h real?])
         void?]{
  Draws a rectangle outline.
}

@defproc[(fill-rect! [ren renderer?]
                     [x real?] [y real?]
                     [w real?] [h real?])
         void?]{
  Draws a filled rectangle.

  @codeblock|{
    (set-draw-color! ren 255 0 0)
    (fill-rect! ren 100 100 200 150)  ; Red filled rectangle
  }|
}

@defproc[(draw-rects! [ren renderer?]
                      [rects (listof (or/c (list/c real? real? real? real?)
                                           (vector/c real? real? real? real?)))])
         void?]{
  Draws multiple rectangle outlines. Each rect is @racket['(x y w h)] or
  @racket[#(x y w h)].
}

@defproc[(fill-rects! [ren renderer?]
                      [rects (listof (or/c (list/c real? real? real? real?)
                                           (vector/c real? real? real? real?)))])
         void?]{
  Draws multiple filled rectangles.
}

@section{Geometry Rendering}

For complex shapes, use vertex-based geometry rendering.

@defproc[(make-vertex [x real?] [y real?]
                      [r real?] [g real?] [b real?]
                      [a real? 1.0]
                      [#:uv uv (or/c (cons/c real? real?) #f) #f])
         any/c]{
  Creates a vertex for geometry rendering.

  @itemlist[
    @item{@racket[x], @racket[y] --- Position coordinates}
    @item{@racket[r], @racket[g], @racket[b], @racket[a] --- Color (0.0 to 1.0)}
    @item{@racket[uv] --- Optional texture coordinates as @racket[(cons u v)]}
  ]
}

@defproc[(render-geometry! [ren renderer?]
                           [vertices (listof any/c)]
                           [#:indices indices (or/c (listof exact-nonnegative-integer?) #f) #f]
                           [#:texture tex (or/c any/c #f) #f])
         void?]{
  Renders triangles using vertex data.

  @itemlist[
    @item{@racket[vertices] --- List of vertices from @racket[make-vertex]}
    @item{@racket[indices] --- Optional index list for indexed rendering}
    @item{@racket[tex] --- Optional texture for textured triangles}
  ]

  Vertices are rendered as triangles (every 3 vertices form a triangle).

  @codeblock|{
    ;; Draw a colored triangle
    (render-geometry! ren
      (list (make-vertex 400 100 1.0 0.0 0.0)   ; Top (red)
            (make-vertex 200 400 0.0 1.0 0.0)   ; Bottom-left (green)
            (make-vertex 600 400 0.0 0.0 1.0))) ; Bottom-right (blue)
  }|
}

@section{Debug Text}

@defproc[(render-debug-text! [ren renderer?]
                             [x real?] [y real?]
                             [text string?])
         void?]{
  Renders text using SDL's built-in 8x8 bitmap font. Useful for debugging,
  FPS counters, and quick UI without loading a TTF font.

  The text color is controlled by @racket[set-draw-color!].

  @codeblock|{
    (set-draw-color! ren 255 255 255)
    (render-debug-text! ren 10 10 "FPS: 60")
  }|
}

@defthing[debug-text-font-size exact-positive-integer?]{
  The size of the debug text font (8 pixels per character).
}

@section{Viewport and Clipping}

@defproc[(set-render-viewport! [ren renderer?] [rect (or/c any/c #f)]) void?]{
  Sets the viewport for rendering. The viewport defines which portion of
  the render target is used for drawing. Pass @racket[#f] to use the entire target.
}

@defproc[(get-render-viewport [ren renderer?]) any/c]{
  Returns the current viewport as an SDL_Rect.
}

@defproc[(set-render-clip-rect! [ren renderer?] [rect (or/c any/c #f)]) void?]{
  Sets a clipping rectangle. Drawing outside this rectangle is clipped.
  Pass @racket[#f] to disable clipping.
}

@defproc[(get-render-clip-rect [ren renderer?]) any/c]{
  Returns the current clipping rectangle.
}

@defproc[(render-clip-enabled? [ren renderer?]) boolean?]{
  Returns @racket[#t] if clipping is currently enabled.
}

@defproc[(set-render-scale! [ren renderer?] [scale-x real?] [scale-y real?]) void?]{
  Sets the render scale. All drawing coordinates are multiplied by these factors.
  Useful for resolution-independent rendering.
}

@defproc[(get-render-scale [ren renderer?]) (values real? real?)]{
  Returns the current render scale as two values.
}

@section{Renderer Information}

@defproc[(renderer-name [ren renderer?]) string?]{
  Returns the name of the rendering backend (e.g., @racket["metal"], @racket["opengl"]).
}

@defproc[(render-output-size [ren renderer?])
         (values exact-nonnegative-integer? exact-nonnegative-integer?)]{
  Returns the renderer's output size in pixels as two values: width and height.
}

@defproc[(current-render-output-size [ren renderer?])
         (values exact-nonnegative-integer? exact-nonnegative-integer?)]{
  Returns the current output size, considering render target and logical size.
}

@defproc[(num-render-drivers) exact-nonnegative-integer?]{
  Returns the number of available render drivers.
}

@defproc[(render-driver-name [index exact-nonnegative-integer?]) string?]{
  Returns the name of the render driver at the given index.
}

@section{VSync}

@defproc[(set-render-vsync! [ren renderer?] [vsync exact-integer?]) void?]{
  Sets the VSync mode for the renderer.

  @itemlist[
    @item{@racket[0] --- VSync off}
    @item{@racket[1] --- VSync on}
    @item{@racket[-1] --- Adaptive VSync (if supported)}
  ]
}

@defproc[(get-render-vsync [ren renderer?]) exact-integer?]{
  Returns the current VSync setting.
}
