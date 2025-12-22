#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "gl" #:style 'quiet]{OpenGL}

This section covers OpenGL context management for use with external OpenGL
libraries.

Note: This module provides context management only. For actual OpenGL rendering,
use a separate OpenGL binding library.

@section{Creating Contexts}

@defproc[(create-gl-context [window window?]
                            [#:custodian cust custodian? (current-custodian)])
         gl-context?]{
  Creates an OpenGL context for a window.

  The window should be created with OpenGL support enabled.

  @codeblock|{
    ;; Set up OpenGL attributes before creating window
    (gl-set-attribute! SDL_GL_CONTEXT_MAJOR_VERSION 3)
    (gl-set-attribute! SDL_GL_CONTEXT_MINOR_VERSION 3)
    (gl-set-attribute! SDL_GL_CONTEXT_PROFILE_MASK SDL_GL_CONTEXT_PROFILE_CORE)

    ;; Create window with OpenGL flag
    (define win (make-window "OpenGL" 800 600 #:flags '(opengl)))

    ;; Create context
    (define ctx (create-gl-context win))
    (gl-make-current! win ctx)
  }|
}

@defproc[(gl-context? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is an OpenGL context.
}

@defproc[(gl-make-current! [window window?] [ctx gl-context?]) void?]{
  Makes an OpenGL context current for a window.

  This must be called before issuing OpenGL commands.
}

@defproc[(gl-swap-window! [window window?]) void?]{
  Swaps the OpenGL buffers for a window.

  Call this after rendering to display the frame.
}

@section{OpenGL Attributes}

OpenGL attributes control context creation. Set them before creating a context.

@defproc[(gl-set-attribute! [attr exact-nonnegative-integer?]
                            [value exact-integer?]) void?]{
  Sets an OpenGL attribute.

  @codeblock|{
    ;; Request OpenGL 4.1 core profile
    (gl-set-attribute! SDL_GL_CONTEXT_MAJOR_VERSION 4)
    (gl-set-attribute! SDL_GL_CONTEXT_MINOR_VERSION 1)
    (gl-set-attribute! SDL_GL_CONTEXT_PROFILE_MASK SDL_GL_CONTEXT_PROFILE_CORE)

    ;; Request double buffering with 24-bit depth
    (gl-set-attribute! SDL_GL_DOUBLEBUFFER 1)
    (gl-set-attribute! SDL_GL_DEPTH_SIZE 24)
  }|
}

@defproc[(gl-get-attribute [attr exact-nonnegative-integer?]) exact-integer?]{
  Gets an OpenGL attribute value.
}

@subsection{Attribute Constants}

@subsubsection{Buffer Sizes}

@defthing[SDL_GL_RED_SIZE exact-nonnegative-integer?]{Red channel bits.}
@defthing[SDL_GL_GREEN_SIZE exact-nonnegative-integer?]{Green channel bits.}
@defthing[SDL_GL_BLUE_SIZE exact-nonnegative-integer?]{Blue channel bits.}
@defthing[SDL_GL_ALPHA_SIZE exact-nonnegative-integer?]{Alpha channel bits.}
@defthing[SDL_GL_BUFFER_SIZE exact-nonnegative-integer?]{Total color buffer bits.}
@defthing[SDL_GL_DEPTH_SIZE exact-nonnegative-integer?]{Depth buffer bits.}
@defthing[SDL_GL_STENCIL_SIZE exact-nonnegative-integer?]{Stencil buffer bits.}

@subsubsection{Accumulation Buffer}

@defthing[SDL_GL_ACCUM_RED_SIZE exact-nonnegative-integer?]{Accumulation red bits.}
@defthing[SDL_GL_ACCUM_GREEN_SIZE exact-nonnegative-integer?]{Accumulation green bits.}
@defthing[SDL_GL_ACCUM_BLUE_SIZE exact-nonnegative-integer?]{Accumulation blue bits.}
@defthing[SDL_GL_ACCUM_ALPHA_SIZE exact-nonnegative-integer?]{Accumulation alpha bits.}

@subsubsection{Multisampling}

@defthing[SDL_GL_MULTISAMPLEBUFFERS exact-nonnegative-integer?]{Number of multisample buffers.}
@defthing[SDL_GL_MULTISAMPLESAMPLES exact-nonnegative-integer?]{Number of samples per pixel.}

@subsubsection{Context Settings}

@defthing[SDL_GL_DOUBLEBUFFER exact-nonnegative-integer?]{Enable double buffering.}
@defthing[SDL_GL_STEREO exact-nonnegative-integer?]{Enable stereo rendering.}
@defthing[SDL_GL_ACCELERATED_VISUAL exact-nonnegative-integer?]{Require hardware acceleration.}
@defthing[SDL_GL_RETAINED_BACKING exact-nonnegative-integer?]{Retain buffer contents.}
@defthing[SDL_GL_FRAMEBUFFER_SRGB_CAPABLE exact-nonnegative-integer?]{sRGB framebuffer support.}
@defthing[SDL_GL_FLOATBUFFERS exact-nonnegative-integer?]{Floating-point buffers.}

@subsubsection{Context Version and Profile}

@defthing[SDL_GL_CONTEXT_MAJOR_VERSION exact-nonnegative-integer?]{OpenGL major version.}
@defthing[SDL_GL_CONTEXT_MINOR_VERSION exact-nonnegative-integer?]{OpenGL minor version.}
@defthing[SDL_GL_CONTEXT_PROFILE_MASK exact-nonnegative-integer?]{Context profile.}
@defthing[SDL_GL_CONTEXT_FLAGS exact-nonnegative-integer?]{Context flags.}

@subsubsection{Context Profiles}

@defthing[SDL_GL_CONTEXT_PROFILE_CORE exact-nonnegative-integer?]{Core profile (no deprecated features).}
@defthing[SDL_GL_CONTEXT_PROFILE_COMPATIBILITY exact-nonnegative-integer?]{Compatibility profile.}
@defthing[SDL_GL_CONTEXT_PROFILE_ES exact-nonnegative-integer?]{OpenGL ES profile.}

@subsubsection{Context Flags}

@defthing[SDL_GL_CONTEXT_DEBUG_FLAG exact-nonnegative-integer?]{Debug context.}
@defthing[SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG exact-nonnegative-integer?]{Forward compatible.}
@defthing[SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG exact-nonnegative-integer?]{Robust access.}
@defthing[SDL_GL_CONTEXT_RESET_ISOLATION_FLAG exact-nonnegative-integer?]{Reset isolation.}

@subsubsection{Other}

@defthing[SDL_GL_SHARE_WITH_CURRENT_CONTEXT exact-nonnegative-integer?]{Share with current context.}
@defthing[SDL_GL_CONTEXT_RELEASE_BEHAVIOR exact-nonnegative-integer?]{Release behavior.}
@defthing[SDL_GL_CONTEXT_RESET_NOTIFICATION exact-nonnegative-integer?]{Reset notification.}
@defthing[SDL_GL_CONTEXT_NO_ERROR exact-nonnegative-integer?]{No error context.}
@defthing[SDL_GL_EGL_PLATFORM exact-nonnegative-integer?]{EGL platform selection.}

@section{Swap Interval (VSync)}

@defproc[(gl-set-swap-interval! [interval exact-integer?]) void?]{
  Sets the swap interval for the current context.

  @itemlist[
    @item{@racket[0] --- Immediate (no vsync)}
    @item{@racket[1] --- VSync (wait for vertical retrace)}
    @item{@racket[-1] --- Adaptive vsync (vsync if possible, else immediate)}
  ]

  @codeblock|{
    ;; Enable vsync
    (gl-set-swap-interval! 1)

    ;; Disable vsync for maximum framerate
    (gl-set-swap-interval! 0)
  }|
}

@defproc[(gl-get-swap-interval) exact-integer?]{
  Gets the current swap interval.
}
