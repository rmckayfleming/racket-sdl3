#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "ttf" #:style 'quiet]{TrueType Fonts}

This section covers TrueType font loading and text rendering using SDL_ttf.

@section{Font Management}

@defproc[(open-font [path (or/c string? path?)]
                    [size real?]
                    [#:custodian cust custodian? (current-custodian)]) font?]{
  Opens a TrueType font from a file.

  @racket[size] is the point size of the font.

  @codeblock|{
    (define font (open-font "/path/to/font.ttf" 24))
  }|
}

@defproc[(open-font-io [source (or/c bytes? input-port? cpointer?)]
                       [size real?]
                       [#:close? close? boolean? #t]
                       [#:custodian cust custodian? (current-custodian)]) font?]{
  Opens a font from bytes, an input port, or an IOStream.

  When @racket[close?] is @racket[#t], SDL takes ownership of the stream.
}

@defproc[(font? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a font.
}

@defproc[(font-ptr [f font?]) cpointer?]{
  Returns the underlying SDL_ttf font pointer.
}

@defproc[(close-font! [f font?]) void?]{
  Closes a font and frees its resources.

  Note: Fonts are automatically closed when their custodian shuts down.
}

@defproc[(copy-font [f font?]
                    [#:custodian cust custodian? (current-custodian)]) font?]{
  Creates a copy of a font with independent properties.
}

@section{Font Properties}

@subsection{Metrics}

@defproc[(font-size [f font?]) real?]{
  Returns the point size of the font.
}

@defproc[(font-height [f font?]) exact-integer?]{
  Returns the maximum height of the font in pixels.

  This is the recommended line spacing for text.
}

@defproc[(font-ascent [f font?]) exact-integer?]{
  Returns the ascent (height above baseline) in pixels.
}

@defproc[(font-descent [f font?]) exact-integer?]{
  Returns the descent (depth below baseline) in pixels.

  Note: This is typically a negative value.
}

@defproc[(font-line-skip [f font?]) exact-integer?]{
  Returns the recommended line skip (spacing between lines) in pixels.
}

@subsection{Style}

@defproc[(font-style [f font?]) (listof symbol?)]{
  Returns the current font style as a list of symbols.

  Possible values: @racket['normal], @racket['bold], @racket['italic],
  @racket['underline], @racket['strikethrough].
}

@defproc[(set-font-style! [f font?] [style symbol?] ...) void?]{
  Sets the font style.

  @codeblock|{
    (set-font-style! font 'bold)
    (set-font-style! font 'bold 'italic)
    (set-font-style! font 'normal)  ; Reset to normal
  }|
}

@defproc[(font-outline [f font?]) exact-integer?]{
  Returns the current outline thickness in pixels.
}

@defproc[(set-font-outline! [f font?] [pixels exact-integer?]) void?]{
  Sets the outline thickness. Use 0 for no outline.
}

@defproc[(font-hinting [f font?]) symbol?]{
  Returns the current hinting mode.

  Values: @racket['normal], @racket['light], @racket['mono], @racket['none],
  @racket['light-subpixel].
}

@defproc[(set-font-hinting! [f font?] [mode symbol?]) void?]{
  Sets the hinting mode for the font.
}

@subsection{Other Properties}

@defproc[(font-weight [f font?]) exact-integer?]{
  Returns the font weight (e.g., 400 for normal, 700 for bold).
}

@defproc[(font-family-name [f font?]) (or/c string? #f)]{
  Returns the font family name.
}

@defproc[(font-style-name [f font?]) (or/c string? #f)]{
  Returns the font style name (e.g., "Regular", "Bold").
}

@defproc[(font-fixed-width? [f font?]) boolean?]{
  Returns @racket[#t] if the font is monospaced.
}

@defproc[(font-scalable? [f font?]) boolean?]{
  Returns @racket[#t] if the font is scalable (TrueType/OpenType).
}

@defproc[(font-kerning? [f font?]) boolean?]{
  Returns @racket[#t] if kerning is enabled.
}

@defproc[(set-font-kerning! [f font?] [enabled? boolean?]) void?]{
  Enables or disables kerning.
}

@defproc[(set-font-size! [f font?]
                         [size real?]
                         [#:hdpi hdpi (or/c exact-nonnegative-integer? #f) #f]
                         [#:vdpi vdpi (or/c exact-nonnegative-integer? #f) #f]) void?]{
  Changes the font size.

  Optional DPI parameters allow for high-DPI rendering.
}

@section{Text Measurement}

@defproc[(text-size [f font?] [text string?]) (values exact-integer? exact-integer?)]{
  Returns the width and height needed to render the text.

  @codeblock|{
    (define-values (w h) (text-size font "Hello, World!"))
  }|
}

@defproc[(text-size-wrapped [f font?]
                            [text string?]
                            [wrap-width exact-nonnegative-integer?]) (values exact-integer? exact-integer?)]{
  Returns the size needed for word-wrapped text.
}

@defproc[(measure-text [f font?]
                       [text string?]
                       [max-width exact-nonnegative-integer?]) (values exact-integer? exact-nonnegative-integer?)]{
  Measures how much text fits within a maximum width.

  Returns the actual width used and the number of characters that fit.
}

@section{Text Rendering}

@defproc[(draw-text! [renderer renderer?]
                     [font font?]
                     [text string?]
                     [x real?]
                     [y real?]
                     [color (or/c (list/c byte? byte? byte?)
                                  (list/c byte? byte? byte? byte?))]
                     [#:mode mode (or/c 'solid 'blended) 'blended]
                     [#:custodian cust custodian? (current-custodian)]) void?]{
  Renders text directly to the screen at the specified position.

  This is a convenience function that renders text to a temporary texture
  and draws it immediately.

  @racket[mode] controls rendering quality:
  @itemlist[
    @item{@racket['solid] --- Fast but rough edges}
    @item{@racket['blended] --- High quality with anti-aliasing (default)}
  ]

  @codeblock|{
    (draw-text! ren font "Hello, World!" 100 100 '(255 255 255))
    (draw-text! ren font "Score: 42" 10 10 '(255 255 0))
  }|
}

@defproc[(render-text [font font?]
                      [text string?]
                      [color (or/c (list/c byte? byte? byte?)
                                   (list/c byte? byte? byte? byte?))]
                      [#:renderer renderer renderer?]
                      [#:mode mode (or/c 'solid 'blended) 'blended]
                      [#:custodian cust custodian? (current-custodian)]) (or/c texture? #f)]{
  Renders text to a texture.

  Returns @racket[#f] for empty text or if the text is too large for a texture.

  This is useful when you want to render the same text multiple times without
  re-rasterizing it each frame.

  @codeblock|{
    (define score-label (render-text font "Score:" '(255 255 255)
                                     #:renderer ren))
    ;; Use the texture multiple times
    (render-texture! ren score-label 10 10)
  }|
}

@section{Text Direction and Alignment}

For languages with different text directions (RTL, vertical), these
functions configure text layout.

@defproc[(font-direction [f font?]) symbol?]{
  Returns the text direction.

  Values: @racket['ltr] (left-to-right), @racket['rtl] (right-to-left),
  @racket['ttb] (top-to-bottom), @racket['btt] (bottom-to-top).
}

@defproc[(set-font-direction! [f font?] [direction symbol?]) void?]{
  Sets the text direction.

  Note: Requires HarfBuzz support. May fail on some builds.
}

@defproc[(font-wrap-alignment [f font?]) symbol?]{
  Returns the text alignment for wrapped text.

  Values: @racket['left], @racket['center], @racket['right].
}

@defproc[(set-font-wrap-alignment! [f font?] [alignment symbol?]) void?]{
  Sets the alignment for wrapped text.
}

@section{Fallback Fonts}

Fallback fonts provide glyphs for characters not present in the primary font.

@defproc[(add-fallback-font! [f font?] [fallback font?]) void?]{
  Adds a fallback font.

  When the primary font doesn't have a glyph, SDL_ttf will try the fallback.
}

@defproc[(remove-fallback-font! [f font?] [fallback font?]) void?]{
  Removes a fallback font.
}

@defproc[(clear-fallback-fonts! [f font?]) void?]{
  Removes all fallback fonts.
}

@section{Glyph Operations}

@defproc[(font-has-glyph? [f font?] [ch (or/c char? exact-nonnegative-integer?)]) boolean?]{
  Returns @racket[#t] if the font has a glyph for the character.
}

@defproc[(glyph-metrics [f font?]
                        [ch (or/c char? exact-nonnegative-integer?)])
         (values exact-integer? exact-integer? exact-integer? exact-integer? exact-integer?)]{
  Returns detailed metrics for a glyph.

  Returns: @racket[(values min-x max-x min-y max-y advance)].
}

@defproc[(glyph-kerning [f font?]
                        [prev-ch (or/c char? exact-nonnegative-integer?)]
                        [ch (or/c char? exact-nonnegative-integer?)]) exact-integer?]{
  Returns the kerning adjustment between two characters.
}

@section{Advanced: Text Objects}

For complex text layouts and efficient updates, SDL_ttf provides text objects
that can be modified and re-rendered efficiently.

@defproc[(make-text [font font?]
                    [text string?]
                    [#:engine engine (or/c renderer-text-engine? surface-text-engine?
                                           gpu-text-engine? #f) #f]
                    [#:custodian cust custodian? (current-custodian)]) text?]{
  Creates a text object for advanced text rendering.
}

@defproc[(text? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a text object.
}

@defproc[(text-set-string! [t text?] [text string?]) void?]{
  Replaces the text content.
}

@defproc[(text-append-string! [t text?] [text string?]) void?]{
  Appends to the text content.
}

@defproc[(text-insert-string! [t text?]
                               [offset exact-nonnegative-integer?]
                               [text string?]) void?]{
  Inserts text at the specified byte offset.
}

@defproc[(text-delete-string! [t text?]
                               [offset exact-nonnegative-integer?]
                               [length exact-nonnegative-integer?]) void?]{
  Deletes text starting at the specified byte offset.
}

@defproc[(text-object-size [t text?]) (values exact-integer? exact-integer?)]{
  Returns the size of the rendered text.
}

@defproc[(draw-renderer-text! [t text?] [x real?] [y real?]) void?]{
  Draws a text object using a renderer text engine.
}

@section{Text Engines}

Text engines manage glyph caching and rendering. They're needed for advanced
text object rendering.

@defproc[(make-renderer-text-engine [renderer renderer?]
                                    [#:custodian cust custodian? (current-custodian)])
         renderer-text-engine?]{
  Creates a text engine for renderer-based text drawing.
}

@defproc[(renderer-text-engine? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a renderer text engine.
}

@defproc[(make-surface-text-engine [#:custodian cust custodian? (current-custodian)])
         surface-text-engine?]{
  Creates a text engine for surface-based text drawing.
}

@defproc[(surface-text-engine? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a surface text engine.
}

@section{SDF Rendering}

Signed Distance Field rendering allows for high-quality text at any scale.

@defproc[(font-sdf? [f font?]) boolean?]{
  Returns @racket[#t] if SDF mode is enabled.
}

@defproc[(set-font-sdf! [f font?] [enabled? boolean?]) void?]{
  Enables or disables SDF mode.
}

@section{Version Information}

@defproc[(ttf-version) (values exact-nonnegative-integer?
                                exact-nonnegative-integer?
                                exact-nonnegative-integer?)]{
  Returns the SDL_ttf version as @racket[(values major minor patch)].
}

@defproc[(freetype-version) (values exact-nonnegative-integer?
                                     exact-nonnegative-integer?
                                     exact-nonnegative-integer?)]{
  Returns the FreeType version as @racket[(values major minor patch)].
}

@defproc[(harfbuzz-version) (values (or/c exact-nonnegative-integer? #f)
                                     (or/c exact-nonnegative-integer? #f)
                                     (or/c exact-nonnegative-integer? #f))]{
  Returns the HarfBuzz version as @racket[(values major minor patch)].

  Returns @racket[(values #f #f #f)] if HarfBuzz is not available.
}
