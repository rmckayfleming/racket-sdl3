#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "image"]{Images and Surfaces}

This section covers image loading, saving, and surface operations using SDL_image.

For texture loading directly to GPU, see the @secref{texture} section.
Surfaces are CPU-side images useful for pixel manipulation, screenshots,
and window icons.

@section{Loading Images}

@defproc[(load-surface [source (or/c string? path? bytes? input-port?)]
                       [#:type type (or/c symbol? string? #f) #f]
                       [#:custodian cust custodian? (current-custodian)]) surface?]{
  Loads an image file as a software surface.

  Supports PNG, JPEG, BMP, GIF, WebP, and many other formats via SDL_image.

  The @racket[#:type] hint specifies the format when loading from bytes
  or a port (e.g., @racket['png], @racket['jpg]).

  @codeblock|{
    ;; Load from file
    (define surf (load-surface "image.png"))

    ;; Load from bytes with format hint
    (define surf2 (load-surface image-bytes #:type 'png))
  }|
}

@defproc[(surface? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a surface.
}

@defproc[(surface-ptr [surf surface?]) cpointer?]{
  Returns the underlying SDL surface pointer.
}

@defproc[(surface-destroy! [surf surface?]) void?]{
  Destroys a surface and frees its memory.

  Note: Surfaces are automatically destroyed when their custodian shuts down.
}

@section{Creating Surfaces}

@defproc[(make-surface [width exact-nonnegative-integer?]
                       [height exact-nonnegative-integer?]
                       [#:format format (or/c symbol? exact-nonnegative-integer?) 'rgba32]
                       [#:custodian cust custodian? (current-custodian)]) surface?]{
  Creates a new blank surface.

  Format symbols include: @racket['rgba32], @racket['rgba8888], @racket['argb8888],
  @racket['rgb24].
}

@defproc[(duplicate-surface [surf surface?]
                            [#:custodian cust custodian? (current-custodian)]) surface?]{
  Creates a copy of a surface.
}

@defproc[(convert-surface [surf surface?]
                          [format (or/c symbol? exact-nonnegative-integer?)]
                          [#:custodian cust custodian? (current-custodian)]) surface?]{
  Converts a surface to a different pixel format.
}

@defproc[(surface->texture [renderer renderer?]
                           [surf surface?]
                           [#:custodian cust custodian? (current-custodian)]) texture?]{
  Creates a texture from a surface.

  The surface is not destroyed; you can create multiple textures from it.
}

@section{Surface Properties}

@defproc[(surface-width [surf surface?]) exact-integer?]{
  Returns the width in pixels.
}

@defproc[(surface-height [surf surface?]) exact-integer?]{
  Returns the height in pixels.
}

@defproc[(surface-pitch [surf surface?]) exact-integer?]{
  Returns the pitch (bytes per row).
}

@defproc[(surface-format [surf surface?]) symbol?]{
  Returns the pixel format as a symbol.
}

@defproc[(surface-pixels [surf surface?]) cpointer?]{
  Returns a pointer to the raw pixel data.

  Only use when the surface is locked.
}

@section{Pixel Access}

@defproc[(surface-get-pixel [surf surface?] [x exact-integer?] [y exact-integer?])
         (values byte? byte? byte? byte?)]{
  Reads a pixel from a surface.

  Returns @racket[(values r g b a)] where each component is 0-255.
}

@defproc[(surface-set-pixel! [surf surface?]
                             [x exact-integer?] [y exact-integer?]
                             [r byte?] [g byte?] [b byte?]
                             [a byte? 255]) void?]{
  Writes a pixel to a surface.
}

@defproc[(surface-get-pixel-float [surf surface?]
                                  [x exact-integer?] [y exact-integer?])
         (values real? real? real? real?)]{
  Reads a pixel as float values (0.0-1.0).
}

@defproc[(surface-set-pixel-float! [surf surface?]
                                   [x exact-integer?] [y exact-integer?]
                                   [r real?] [g real?] [b real?]
                                   [a real? 1.0]) void?]{
  Writes a pixel using float values (0.0-1.0).
}

@section{Bulk Pixel Access}

@defproc[(surface-fill-pixels! [surf surface?]
                               [generator (-> exact-integer? exact-integer?
                                              (values byte? byte? byte? byte?))]) void?]{
  Fills a surface by calling a generator function for each pixel.

  The generator receives @racket[(x y)] and returns @racket[(values r g b a)].

  @codeblock|{
    ;; Create a gradient
    (surface-fill-pixels! surf
      (lambda (x y)
        (values (quotient (* x 255) width)   ; red gradient
                128                           ; constant green
                (quotient (* y 255) height)  ; blue gradient
                255)))                        ; opaque
  }|
}

@defproc[(call-with-surface-pixels [surf surface?]
                                    [proc (-> cpointer? exact-integer? exact-integer?
                                              exact-integer? exact-integer? any)]) any]{
  Low-level access to the pixel buffer.

  The procedure receives: @racket[(pixels width height pitch bytes-per-pixel)].
}

@section{Surface Locking}

Some operations require locking the surface first.

@defproc[(surface-lock! [surf surface?]) #t]{
  Locks a surface for direct pixel access.
}

@defproc[(surface-unlock! [surf surface?]) void?]{
  Unlocks a surface after direct pixel access.
}

@defproc[(call-with-locked-surface [surf surface?]
                                    [proc (-> surface? cpointer?
                                              exact-integer? exact-integer?
                                              exact-integer? any)]) any]{
  Locks, calls the procedure, then unlocks.

  The procedure receives: @racket[(surface pixels width height pitch)].
}

@section{Blitting}

@defproc[(blit-surface! [src surface?]
                        [dst surface?]
                        [#:src-rect src-rect (or/c (list/c real? real? real? real?) #f) #f]
                        [#:dst-rect dst-rect (or/c (list/c real? real? real? real?) #f) #f]) void?]{
  Copies pixels from source to destination surface.

  Rectangles are specified as @racket[(list x y w h)].
}

@defproc[(blit-surface-scaled! [src surface?]
                               [dst surface?]
                               [#:src-rect src-rect (or/c (list/c real? real? real? real?) #f) #f]
                               [#:dst-rect dst-rect (or/c (list/c real? real? real? real?) #f) #f]
                               [#:scale-mode scale-mode (or/c 'nearest 'linear) 'nearest]) void?]{
  Copies and scales pixels from source to destination.
}

@section{Filling and Clearing}

@defproc[(fill-surface! [surf surface?]
                        [color (or/c (list/c byte? byte? byte?)
                                     (list/c byte? byte? byte? byte?))]
                        [#:rect rect (or/c (list/c real? real? real? real?) #f) #f]) void?]{
  Fills a surface or rectangle with a color.

  Color is @racket[(list r g b)] or @racket[(list r g b a)].
}

@defproc[(clear-surface! [surf surface?]
                         [r real?] [g real?] [b real?]
                         [a real? 1.0]) void?]{
  Clears a surface to a color (using float values 0.0-1.0).
}

@section{Transformations}

@defproc[(flip-surface! [surf surface?]
                        [mode (or/c 'horizontal 'vertical)]) void?]{
  Flips a surface in place.

  To flip both ways, call twice with different modes.
}

@defproc[(scale-surface [surf surface?]
                        [width exact-nonnegative-integer?]
                        [height exact-nonnegative-integer?]
                        [#:mode mode (or/c 'nearest 'linear) 'nearest]
                        [#:custodian cust custodian? (current-custodian)]) surface?]{
  Creates a new surface with scaled contents.
}

@section{Saving Images}

@defproc[(save-png! [surf surface?] [path (or/c string? path?)]) void?]{
  Saves a surface to a PNG file.
}

@defproc[(save-jpg! [surf surface?]
                    [path (or/c string? path?)]
                    [quality exact-nonnegative-integer? 90]) void?]{
  Saves a surface to a JPEG file.

  @racket[quality] is 0-100 (higher = better quality, larger file).
}

@defproc[(save-bmp! [surf surface?] [path (or/c string? path?)]) void?]{
  Saves a surface to a BMP file.
}

@defproc[(load-bmp [path (or/c string? path?)]
                   [#:custodian cust custodian? (current-custodian)]) surface?]{
  Loads a BMP image from a file.

  For other formats (PNG, JPEG, etc.), use @racket[load-surface].
}

@section{Screenshots}

@defproc[(render-read-pixels [renderer renderer?]
                             [#:custodian cust custodian? (current-custodian)]) surface?]{
  Reads pixels from the renderer into a new surface.

  Use this to take screenshots:

  @codeblock|{
    (define screenshot (render-read-pixels ren))
    (save-png! screenshot "screenshot.png")
  }|
}

@section{Format Detection}

@defproc[(image-format [source (or/c bytes? input-port?)]) (or/c symbol? #f)]{
  Detects the image format from bytes or a port.

  Returns a symbol like @racket['png], @racket['jpg], @racket['gif],
  or @racket[#f] if the format is unknown.
}

@section{Color Key and Modulation}

@defproc[(set-surface-color-key! [surf surface?]
                                  [color (or/c (list/c byte? byte? byte?) #f)]) void?]{
  Sets the transparent color for a surface.

  Pass @racket[#f] to disable the color key.
}

@defproc[(surface-has-color-key? [surf surface?]) boolean?]{
  Returns @racket[#t] if a color key is set.
}

@defproc[(set-surface-color-mod! [surf surface?]
                                  [r byte?] [g byte?] [b byte?]) void?]{
  Sets color modulation for blit operations.
}

@defproc[(set-surface-alpha-mod! [surf surface?] [alpha byte?]) void?]{
  Sets alpha modulation for blit operations.
}

@defproc[(set-surface-blend-mode! [surf surface?]
                                   [mode (or/c 'none 'blend 'add 'mod 'mul)]) void?]{
  Sets the blend mode for blit operations.
}
