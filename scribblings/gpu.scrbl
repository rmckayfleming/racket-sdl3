#lang scribble/manual

@(require (for-label racket/base
                     racket/contract
                     sdl3))

@title[#:tag "gpu" #:style 'quiet]{GPU API}

This section covers SDL3's new GPU API, which provides a modern cross-platform
graphics abstraction supporting Vulkan, Direct3D 12, and Metal backends.

The GPU API is more complex than the 2D renderer but provides much more power
and control for 3D graphics and compute workloads.

@section{Devices}

@defproc[(make-gpu-device [#:shader-formats formats exact-nonnegative-integer?
                                            SDL_GPU_SHADERFORMAT_SPIRV]
                          [#:debug? debug? boolean? #f]
                          [#:driver driver (or/c string? #f) #f]) gpu-device?]{
  Creates a GPU device.

  @racket[formats] specifies which shader formats are required (e.g., SPIRV, DXBC, MSL).
  @racket[debug?] enables debug/validation layers.
  @racket[driver] optionally forces a specific backend.

  @codeblock|{
    (define device (make-gpu-device #:debug? #t))
  }|
}

@defproc[(gpu-device? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a GPU device.
}

@defproc[(gpu-device-destroy! [device gpu-device?]) void?]{
  Destroys a GPU device.

  Note: Devices are automatically destroyed when their custodian shuts down.
}

@defproc[(gpu-device-driver [device gpu-device?]) string?]{
  Returns the name of the GPU driver in use.
}

@defproc[(gpu-device-shader-formats [device gpu-device?]) exact-nonnegative-integer?]{
  Returns the shader formats supported by the device.
}

@defproc[(gpu-supports-shader-formats? [formats exact-nonnegative-integer?]
                                       [#:driver driver (or/c string? #f) #f]) boolean?]{
  Returns @racket[#t] if the specified shader formats are supported.
}

@section{Swapchain}

The swapchain manages the images presented to a window.

@defproc[(gpu-claim-window! [device gpu-device?] [window cpointer?]) void?]{
  Claims a window for GPU rendering.

  Must be called before acquiring swapchain textures.
}

@defproc[(gpu-release-window! [device gpu-device?] [window cpointer?]) void?]{
  Releases a window from GPU rendering.
}

@defproc[(gpu-swapchain-texture-format [device gpu-device?] [window cpointer?])
         exact-nonnegative-integer?]{
  Returns the pixel format of the swapchain.
}

@defproc[(gpu-set-swapchain-parameters! [device gpu-device?]
                                        [window cpointer?]
                                        [composition exact-nonnegative-integer?]
                                        [present-mode exact-nonnegative-integer?]) void?]{
  Sets swapchain presentation parameters.
}

@defproc[(gpu-acquire-swapchain-texture [cmd-buffer cpointer?]
                                        [window cpointer?])
         (values (or/c cpointer? #f) exact-nonnegative-integer? exact-nonnegative-integer?)]{
  Acquires the next swapchain texture for rendering.

  Returns @racket[(values texture width height)], or @racket[(values #f 0 0)]
  if no texture is available.
}

@defproc[(gpu-wait-for-swapchain! [device gpu-device?] [window cpointer?]) void?]{
  Waits for the swapchain to be ready.
}

@section{Command Buffers}

Command buffers record GPU commands for later submission.

@defproc[(gpu-acquire-command-buffer [device gpu-device?]) cpointer?]{
  Acquires a command buffer for recording commands.
}

@defproc[(gpu-submit! [cmd-buffer cpointer?]) void?]{
  Submits a command buffer for execution.
}

@defproc[(gpu-submit-and-acquire-fence! [device gpu-device?]
                                        [cmd-buffer cpointer?]) gpu-fence?]{
  Submits a command buffer and returns a fence for synchronization.
}

@defproc[(gpu-cancel-command-buffer! [cmd-buffer cpointer?]) void?]{
  Cancels a command buffer without submitting.
}

@section{Render Passes}

Render passes define a set of render targets and rendering operations.

@defproc[(gpu-begin-render-pass [cmd-buffer cpointer?]
                                [color-targets cpointer?]
                                [#:depth-stencil-target depth-stencil (or/c cpointer? #f) #f])
         cpointer?]{
  Begins a render pass.

  @racket[color-targets] is a pointer to color target info structures.
}

@defproc[(gpu-end-render-pass! [pass cpointer?]) void?]{
  Ends a render pass.
}

@section{Graphics Pipelines}

Pipelines define the complete graphics state for rendering.

@defproc[(make-gpu-graphics-pipeline [device gpu-device?]
                                     [create-info cpointer?]) gpu-graphics-pipeline?]{
  Creates a graphics pipeline.
}

@defproc[(gpu-graphics-pipeline? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a graphics pipeline.
}

@defproc[(gpu-graphics-pipeline-destroy! [pipeline gpu-graphics-pipeline?]) void?]{
  Destroys a graphics pipeline.
}

@defproc[(gpu-bind-graphics-pipeline! [render-pass cpointer?]
                                      [pipeline gpu-graphics-pipeline?]) void?]{
  Binds a graphics pipeline in a render pass.
}

@section{Shaders}

@defproc[(make-gpu-shader [device gpu-device?]
                          [create-info cpointer?]) gpu-shader?]{
  Creates a shader from compiled bytecode.
}

@defproc[(gpu-shader? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a shader.
}

@defproc[(gpu-shader-ptr [shader gpu-shader?]) cpointer?]{
  Returns the underlying shader pointer.
}

@defproc[(gpu-shader-destroy! [shader gpu-shader?]) void?]{
  Destroys a shader.
}

@section{Buffers}

@subsection{GPU Buffers}

GPU buffers hold vertex, index, and uniform data on the GPU.

@defproc[(make-gpu-buffer [device gpu-device?]
                          [create-info cpointer?]) gpu-buffer?]{
  Creates a GPU buffer.
}

@defproc[(gpu-buffer? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a GPU buffer.
}

@defproc[(gpu-buffer-ptr [buffer gpu-buffer?]) cpointer?]{
  Returns the underlying buffer pointer.
}

@defproc[(gpu-buffer-destroy! [buffer gpu-buffer?]) void?]{
  Destroys a GPU buffer.
}

@subsection{Transfer Buffers}

Transfer buffers are used to upload data from CPU to GPU.

@defproc[(make-gpu-transfer-buffer [device gpu-device?]
                                   [create-info cpointer?]) gpu-transfer-buffer?]{
  Creates a transfer buffer.
}

@defproc[(gpu-transfer-buffer? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a transfer buffer.
}

@defproc[(gpu-transfer-buffer-ptr [buffer gpu-transfer-buffer?]) cpointer?]{
  Returns the underlying buffer pointer.
}

@defproc[(gpu-transfer-buffer-destroy! [buffer gpu-transfer-buffer?]) void?]{
  Destroys a transfer buffer.
}

@defproc[(gpu-map-transfer-buffer [device gpu-device?]
                                  [buffer gpu-transfer-buffer?]
                                  [#:cycle? cycle? boolean? #f]) cpointer?]{
  Maps a transfer buffer for CPU access.

  Returns a pointer to the buffer memory.
}

@defproc[(gpu-unmap-transfer-buffer! [device gpu-device?]
                                     [buffer gpu-transfer-buffer?]) void?]{
  Unmaps a transfer buffer.
}

@section{Copy Passes}

Copy passes transfer data between buffers and textures.

@defproc[(gpu-begin-copy-pass [cmd-buffer cpointer?]) cpointer?]{
  Begins a copy pass.
}

@defproc[(gpu-end-copy-pass! [pass cpointer?]) void?]{
  Ends a copy pass.
}

@defproc[(gpu-upload-to-buffer! [copy-pass cpointer?]
                                [source cpointer?]
                                [destination cpointer?]
                                [#:cycle? cycle? boolean? #f]) void?]{
  Uploads data from a transfer buffer to a GPU buffer.
}

@defproc[(gpu-upload-to-texture! [copy-pass cpointer?]
                                 [source cpointer?]
                                 [destination cpointer?]
                                 [#:cycle? cycle? boolean? #f]) void?]{
  Uploads data from a transfer buffer to a texture.
}

@section{Textures}

@defproc[(make-gpu-texture [device gpu-device?]
                           [create-info cpointer?]) gpu-texture?]{
  Creates a GPU texture.
}

@defproc[(gpu-texture? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a GPU texture.
}

@defproc[(gpu-texture-destroy! [texture gpu-texture?]) void?]{
  Destroys a GPU texture.
}

@defproc[(gpu-set-texture-name! [device gpu-device?]
                                [texture gpu-texture?]
                                [name string?]) void?]{
  Sets a debug name for a texture.
}

@section{Samplers}

@defproc[(make-gpu-sampler [device gpu-device?]
                           [create-info cpointer?]) gpu-sampler?]{
  Creates a texture sampler.
}

@defproc[(gpu-sampler? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a sampler.
}

@defproc[(gpu-sampler-destroy! [sampler gpu-sampler?]) void?]{
  Destroys a sampler.
}

@section{Drawing}

@defproc[(gpu-bind-vertex-buffers! [render-pass cpointer?]
                                   [bindings cpointer?]
                                   [#:first-slot first-slot exact-nonnegative-integer? 0]) void?]{
  Binds vertex buffers in a render pass.
}

@defproc[(gpu-bind-index-buffer! [render-pass cpointer?]
                                 [binding cpointer?]
                                 [element-size exact-nonnegative-integer?]) void?]{
  Binds an index buffer in a render pass.
}

@defproc[(gpu-set-viewport! [render-pass cpointer?]
                            [viewport cpointer?]) void?]{
  Sets the viewport in a render pass.
}

@defproc[(gpu-set-scissor! [render-pass cpointer?]
                           [rect cpointer?]) void?]{
  Sets the scissor rectangle in a render pass.
}

@defproc[(gpu-push-vertex-uniform-data! [cmd-buffer cpointer?]
                                        [slot exact-nonnegative-integer?]
                                        [data cpointer?]
                                        [length exact-nonnegative-integer?]) void?]{
  Pushes vertex shader uniform data.
}

@defproc[(gpu-push-fragment-uniform-data! [cmd-buffer cpointer?]
                                          [slot exact-nonnegative-integer?]
                                          [data cpointer?]
                                          [length exact-nonnegative-integer?]) void?]{
  Pushes fragment shader uniform data.
}

@defproc[(gpu-draw-primitives! [render-pass cpointer?]
                               [num-vertices exact-nonnegative-integer?]
                               [#:num-instances num-instances exact-nonnegative-integer? 1]
                               [#:first-vertex first-vertex exact-nonnegative-integer? 0]
                               [#:first-instance first-instance exact-nonnegative-integer? 0]) void?]{
  Draws non-indexed primitives.
}

@defproc[(gpu-draw-indexed-primitives! [render-pass cpointer?]
                                       [num-indices exact-nonnegative-integer?]
                                       [#:num-instances num-instances exact-nonnegative-integer? 1]
                                       [#:first-index first-index exact-nonnegative-integer? 0]
                                       [#:vertex-offset vertex-offset exact-integer? 0]
                                       [#:first-instance first-instance exact-nonnegative-integer? 0]) void?]{
  Draws indexed primitives.
}

@section{Fences}

Fences are used for GPU-CPU synchronization.

@defproc[(gpu-fence? [v any/c]) boolean?]{
  Returns @racket[#t] if @racket[v] is a fence.
}

@defproc[(gpu-query-fence [fence gpu-fence?]) boolean?]{
  Returns @racket[#t] if the fence has signaled.
}

@defproc[(gpu-release-fence! [fence gpu-fence?]) void?]{
  Releases a fence.
}

@defproc[(gpu-wait-for-idle! [device gpu-device?]) void?]{
  Waits for all GPU work to complete.
}

@section{Blitting}

@defproc[(gpu-blit-texture! [cmd-buffer cpointer?]
                            [blit-info cpointer?]) void?]{
  Copies and optionally scales/converts a texture region.
}
