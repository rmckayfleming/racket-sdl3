#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "collision"]{Rectangle Collision Detection}

This section covers rectangle creation and collision detection using both
integer-based (@racket[SDL_Rect]) and floating-point (@racket[SDL_FRect])
rectangles.

@section{Creating Rectangles}

@defproc[(make-rect [x real?] [y real?] [w real?] [h real?]) SDL_Rect?]{
  Creates an integer rectangle.

  Values are truncated to integers.

  @codeblock|{
    (define player-hitbox (make-rect 100 200 32 32))
  }|
}

@defproc[(make-frect [x real?] [y real?] [w real?] [h real?]) SDL_FRect?]{
  Creates a floating-point rectangle.

  @codeblock|{
    (define player-hitbox (make-frect 100.5 200.0 32.0 32.0))
  }|
}

@section{Rectangle Accessors}

@defproc[(rect-x [r SDL_Rect?]) exact-integer?]{Returns the x coordinate.}
@defproc[(rect-y [r SDL_Rect?]) exact-integer?]{Returns the y coordinate.}
@defproc[(rect-w [r SDL_Rect?]) exact-integer?]{Returns the width.}
@defproc[(rect-h [r SDL_Rect?]) exact-integer?]{Returns the height.}

@defproc[(frect-x [r SDL_FRect?]) real?]{Returns the x coordinate.}
@defproc[(frect-y [r SDL_FRect?]) real?]{Returns the y coordinate.}
@defproc[(frect-w [r SDL_FRect?]) real?]{Returns the width.}
@defproc[(frect-h [r SDL_FRect?]) real?]{Returns the height.}

@defproc[(rect->values [r SDL_Rect?]) (values exact-integer? exact-integer?
                                               exact-integer? exact-integer?)]{
  Destructures a rectangle into multiple values.

  @codeblock|{
    (define-values (x y w h) (rect->values player-hitbox))
  }|
}

@defproc[(frect->values [r SDL_FRect?]) (values real? real? real? real?)]{
  Destructures a floating-point rectangle into multiple values.
}

@section{Collision Detection}

@defproc[(rects-intersect? [a SDL_Rect?] [b SDL_Rect?]) boolean?]{
  Returns @racket[#t] if two rectangles overlap.

  @codeblock|{
    (when (rects-intersect? player-hitbox enemy-hitbox)
      (handle-collision!))
  }|
}

@defproc[(rect-intersection [a SDL_Rect?] [b SDL_Rect?]) (or/c SDL_Rect? #f)]{
  Returns the overlapping region of two rectangles, or @racket[#f] if they
  don't intersect.

  @codeblock|{
    (define overlap (rect-intersection a b))
    (when overlap
      (printf "Overlap area: ~a x ~a~n"
              (rect-w overlap) (rect-h overlap)))
  }|
}

@defproc[(frects-intersect? [a SDL_FRect?] [b SDL_FRect?]) boolean?]{
  Returns @racket[#t] if two floating-point rectangles overlap.
}

@defproc[(frect-intersection [a SDL_FRect?] [b SDL_FRect?]) (or/c SDL_FRect? #f)]{
  Returns the overlapping region of two floating-point rectangles, or
  @racket[#f] if they don't intersect.
}

@section{Rectangle Utilities}

@defproc[(rect-union [a SDL_Rect?] [b SDL_Rect?]) SDL_Rect?]{
  Returns the smallest rectangle that contains both input rectangles.

  @codeblock|{
    (define bounds (rect-union a b))
  }|
}

@defproc[(frect-union [a SDL_FRect?] [b SDL_FRect?]) SDL_FRect?]{
  Returns the smallest floating-point rectangle that contains both input
  rectangles.
}

@defproc[(rect-enclosing-points [points (listof point?)]
                                 [clip (or/c SDL_Rect? #f) #f]) (or/c SDL_Rect? #f)]{
  Returns the smallest rectangle that encloses all the given points.

  Points can be:
  @itemlist[
    @item{SDL_Point structs}
    @item{Lists of two numbers: @racket[(list x y)]}
    @item{Vectors of two numbers: @racket[#(x y)]}
  ]

  If @racket[clip] is provided, points are first clipped to that rectangle.
  Returns @racket[#f] if no points are enclosed (or the list is empty).

  @codeblock|{
    (define bounds (rect-enclosing-points
                     (list '(10 20) '(50 60) '(30 40))))
  }|
}

@defproc[(frect-enclosing-points [points (listof point?)]
                                  [clip (or/c SDL_FRect? #f) #f]) (or/c SDL_FRect? #f)]{
  Returns the smallest floating-point rectangle that encloses all the given
  points.
}

@section{Line Intersection}

@defproc[(rect-line-intersection [rect SDL_Rect?]
                                  [x1 real?] [y1 real?]
                                  [x2 real?] [y2 real?])
         (or/c (values exact-integer? exact-integer?
                       exact-integer? exact-integer?) #f)]{
  Clips a line segment to a rectangle.

  Returns @racket[(values x1-clipped y1-clipped x2-clipped y2-clipped)] with
  the clipped line endpoints, or @racket[#f] if the line doesn't intersect
  the rectangle.

  @codeblock|{
    (define-values (cx1 cy1 cx2 cy2)
      (or (rect-line-intersection viewport 0 0 800 600)
          (values 0 0 0 0)))
  }|
}

@defproc[(frect-line-intersection [rect SDL_FRect?]
                                   [x1 real?] [y1 real?]
                                   [x2 real?] [y2 real?])
         (or/c (values real? real? real? real?) #f)]{
  Clips a line segment to a floating-point rectangle.

  Returns @racket[(values x1-clipped y1-clipped x2-clipped y2-clipped)] with
  the clipped line endpoints, or @racket[#f] if the line doesn't intersect
  the rectangle.
}
