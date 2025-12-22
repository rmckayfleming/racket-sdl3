#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "camera"]{Camera}

This section covers camera (webcam) capture.

@section{Driver and Device Enumeration}

@defproc[(camera-driver-count) exact-nonnegative-integer?]{
  Returns the number of available camera drivers.
}

@defproc[(camera-driver-name [index exact-nonnegative-integer?]) (or/c string? #f)]{
  Returns the name of a camera driver.
}

@defproc[(current-camera-driver) (or/c string? #f)]{
  Returns the name of the current camera driver.
}

@defproc[(get-cameras) (listof exact-nonnegative-integer?)]{
  Returns a list of available camera instance IDs.

  @codeblock|{
    (for ([id (get-cameras)])
      (printf "Camera: ~a (~a)~n"
              (camera-name id)
              (camera-position id)))
  }|
}

@defproc[(camera-name [instance-id exact-nonnegative-integer?]) (or/c string? #f)]{
  Returns the name of a camera.
}

@defproc[(camera-position [instance-id exact-nonnegative-integer?]) symbol?]{
  Returns the physical position of a camera.

  Values: @racket['unknown], @racket['front-facing], @racket['back-facing].
}

@defproc[(camera-supported-formats [instance-id exact-nonnegative-integer?])
         (listof camera-spec?)]{
  Returns a list of supported camera formats.
}

@section{Camera Specs}

Camera specs describe the format and resolution of a camera.

@defstruct*[camera-spec ([format exact-nonnegative-integer?]
                         [colorspace exact-nonnegative-integer?]
                         [width exact-nonnegative-integer?]
                         [height exact-nonnegative-integer?]
                         [framerate-numerator exact-nonnegative-integer?]
                         [framerate-denominator exact-nonnegative-integer?])]{
  A camera specification describing format and resolution.
}

@defproc[(make-camera-spec [format exact-nonnegative-integer?]
                           [width exact-nonnegative-integer?]
                           [height exact-nonnegative-integer?]
                           [#:colorspace colorspace exact-nonnegative-integer? 0]
                           [#:framerate-numerator num exact-nonnegative-integer? 0]
                           [#:framerate-denominator den exact-nonnegative-integer? 0])
         camera-spec?]{
  Creates a camera spec.
}

@section{Opening Cameras}

@defproc[(open-camera [instance-id exact-nonnegative-integer?]
                      [#:spec spec (or/c camera-spec? #f) #f]
                      [#:custodian cust custodian? (current-custodian)]) camera?]{
  Opens a camera.

  If @racket[spec] is provided, requests that specific format.

  @codeblock|{
    (define cameras (get-cameras))
    (when (pair? cameras)
      (define cam (open-camera (car cameras))))
  }|
}

@defproc[(camera? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a camera.
}

@defproc[(camera-ptr [cam camera?]) cpointer?]{
  Returns the underlying SDL camera pointer.
}

@defproc[(camera-destroy! [cam camera?]) void?]{
  Closes a camera.

  Note: Cameras are automatically closed when their custodian shuts down.
}

@section{Camera Information}

@defproc[(camera-permission-state [cam camera?]) symbol?]{
  Returns the camera permission state.

  Values: @racket['approved], @racket['denied], @racket['pending].

  On some platforms, you must wait for permission before capturing frames.
}

@defproc[(camera-id [cam camera?]) exact-nonnegative-integer?]{
  Returns the camera's instance ID.
}

@defproc[(camera-properties [cam camera?]) exact-nonnegative-integer?]{
  Returns the camera's properties ID.
}

@defproc[(camera-format [cam camera?]) (or/c camera-spec? #f)]{
  Returns the actual format being used.
}

@section{Frame Capture}

@defproc[(camera-acquire-frame [cam camera?]) (or/c camera-frame? #f)]{
  Acquires the next available frame.

  Returns @racket[#f] if no frame is available yet.

  @codeblock|{
    (let loop ()
      (define frame (camera-acquire-frame cam))
      (cond
        [frame
         ;; Process the frame
         (define tex (camera-frame->texture ren frame))
         (render-texture! ren tex 0 0)
         (camera-frame-release! frame)]
        [else
         (delay! 10)])
      (loop))
  }|
}

@defproc[(camera-frame? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a camera frame.
}

@defproc[(camera-frame-release! [frame camera-frame?]) void?]{
  Releases a frame back to the camera.

  You must release frames after processing to allow new frames to be captured.
}

@defproc[(camera-frame->texture [renderer renderer?]
                                 [frame camera-frame?]
                                 [#:custodian cust custodian? (current-custodian)])
         texture?]{
  Creates a texture from a camera frame.
}

@defproc[(camera-frame-surface [frame camera-frame?]) cpointer?]{
  Returns the underlying surface pointer.
}

@defproc[(camera-frame-timestamp-ns [frame camera-frame?]) exact-nonnegative-integer?]{
  Returns the frame timestamp in nanoseconds.
}

@defproc[(camera-frame-width [frame camera-frame?]) exact-integer?]{
  Returns the frame width in pixels.
}

@defproc[(camera-frame-height [frame camera-frame?]) exact-integer?]{
  Returns the frame height in pixels.
}

@defproc[(camera-frame-pitch [frame camera-frame?]) exact-integer?]{
  Returns the frame pitch (bytes per row).
}

@defproc[(camera-frame-format [frame camera-frame?]) exact-nonnegative-integer?]{
  Returns the frame pixel format.
}
