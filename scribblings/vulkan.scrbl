#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "vulkan" #:style 'quiet]{Vulkan}

This section covers Vulkan surface creation for use with external Vulkan
libraries.

Note: This module provides SDL-Vulkan integration only. For actual Vulkan
rendering, use a separate Vulkan binding library.

@section{Window Flag}

@defthing[SDL_WINDOW_VULKAN exact-nonnegative-integer?]{
  Window flag for Vulkan support. Use when creating a window for Vulkan rendering.

  @codeblock|{
    (define win (make-window "Vulkan" 800 600
                             #:flags (list SDL_WINDOW_VULKAN)))
  }|
}

@section{Instance Extensions}

@defproc[(vulkan-instance-extensions) (listof string?)]{
  Returns the list of Vulkan instance extensions required by SDL.

  Call this to get the extensions needed when creating your Vulkan instance.

  @codeblock|{
    (define extensions (vulkan-instance-extensions))
    ;; Pass these to vkCreateInstance
  }|
}

@section{Surface Creation}

@defproc[(create-vulkan-surface [window window?]
                                [instance cpointer?]
                                [#:custodian cust custodian? (current-custodian)])
         vulkan-surface?]{
  Creates a Vulkan surface for a window.

  @racket[instance] is your VkInstance handle.

  The window must have been created with the @racket[SDL_WINDOW_VULKAN] flag.

  @codeblock|{
    ;; After creating your Vulkan instance...
    (define surface (create-vulkan-surface win vk-instance))
  }|
}

@defproc[(vulkan-surface? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a Vulkan surface.
}

@defproc[(vulkan-surface-ptr [surf vulkan-surface?]) cpointer?]{
  Returns the underlying VkSurfaceKHR handle.
}

@defproc[(vulkan-surface-destroy! [surf vulkan-surface?]) void?]{
  Destroys a Vulkan surface.

  Note: Surfaces are automatically destroyed when their custodian shuts down.
}
