#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "properties"]{Properties}

This section covers SDL property bags, which are key-value stores used
internally by SDL and available for application use.

@section{Creating and Destroying}

@defproc[(make-properties) exact-nonnegative-integer?]{
  Creates a new properties group.

  Returns a properties ID that can be used with the getter and setter functions.
}

@defproc[(destroy-properties! [props exact-nonnegative-integer?]) void?]{
  Destroys a properties group.
}

@section{Setting Properties}

@defproc[(set-property-pointer! [props exact-nonnegative-integer?]
                                 [name string?]
                                 [value cpointer?]) void?]{
  Sets a pointer property.
}

@defproc[(set-property-string! [props exact-nonnegative-integer?]
                                [name string?]
                                [value string?]) void?]{
  Sets a string property.
}

@defproc[(set-property-number! [props exact-nonnegative-integer?]
                                [name string?]
                                [value exact-integer?]) void?]{
  Sets a number (integer) property.
}

@defproc[(set-property-float! [props exact-nonnegative-integer?]
                               [name string?]
                               [value real?]) void?]{
  Sets a float property.
}

@defproc[(set-property-boolean! [props exact-nonnegative-integer?]
                                 [name string?]
                                 [value boolean?]) void?]{
  Sets a boolean property.
}

@section{Getting Properties}

@defproc[(get-property-pointer [props exact-nonnegative-integer?]
                                [name string?]
                                [default cpointer? #f]) (or/c cpointer? #f)]{
  Gets a pointer property.
}

@defproc[(get-property-string [props exact-nonnegative-integer?]
                               [name string?]
                               [default string? ""]) string?]{
  Gets a string property.
}

@defproc[(get-property-number [props exact-nonnegative-integer?]
                               [name string?]
                               [default exact-integer? 0]) exact-integer?]{
  Gets a number (integer) property.
}

@defproc[(get-property-float [props exact-nonnegative-integer?]
                              [name string?]
                              [default real? 0.0]) real?]{
  Gets a float property.
}

@defproc[(get-property-boolean [props exact-nonnegative-integer?]
                                [name string?]
                                [default boolean? #f]) boolean?]{
  Gets a boolean property.
}
