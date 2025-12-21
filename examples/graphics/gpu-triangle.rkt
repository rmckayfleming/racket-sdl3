#lang racket/base

;; GPU Triangle Example
;;
;; Demonstrates the SDL3 GPU API by rendering a colored triangle.
;; Uses Metal shaders on macOS.

(require ffi/unsafe
         ffi/vector
         racket/math
         racket/match
         sdl3
         sdl3/raw)

;; Metal shader source code (MSL)
;; Note: SDL3 GPU API uses specific naming conventions for shader inputs/outputs
(define vertex-shader-msl #<<MSL
#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float2 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertexOutput {
    float4 position [[position]];
    float4 color;
};

vertex VertexOutput vs_main(VertexInput in [[stage_in]]) {
    VertexOutput out;
    out.position = float4(in.position, 0.0, 1.0);
    out.color = in.color;
    return out;
}
MSL
)

(define fragment-shader-msl #<<MSL
#include <metal_stdlib>
using namespace metal;

struct FragmentInput {
    float4 color;
};

fragment float4 fs_main(FragmentInput in [[stage_in]]) {
    return in.color;
}
MSL
)

;; Triangle vertex data: position (x, y) + color (r, g, b, a)
;; Layout: x, y, r, g, b, a for each vertex
(define FLOATS-PER-VERTEX 6)
(define VERTEX_SIZE (* FLOATS-PER-VERTEX 4))
(define NUM_VERTICES 3)

(define triangle-base
  (vector
   ;; Top vertex (red)
   (vector 0.0  0.5  1.0 0.0 0.0 1.0)
   ;; Bottom-left vertex (green)
   (vector -0.5 -0.5 0.0 1.0 0.0 1.0)
   ;; Bottom-right vertex (blue)
   (vector 0.5 -0.5 0.0 0.0 1.0 1.0)))

(define triangle-vertices (make-f32vector (* NUM_VERTICES FLOATS-PER-VERTEX)))

(define (write-rotated-vertices! vertices angle)
  (define c (cos angle))
  (define s (sin angle))
  (for ([i (in-range NUM_VERTICES)])
    (define base (vector-ref triangle-base i))
    (define x (vector-ref base 0))
    (define y (vector-ref base 1))
    (define rx (- (* x c) (* y s)))
    (define ry (+ (* x s) (* y c)))
    (define offset (* i FLOATS-PER-VERTEX))
    (f32vector-set! vertices offset rx)
    (f32vector-set! vertices (+ offset 1) ry)
    (f32vector-set! vertices (+ offset 2) (vector-ref base 2))
    (f32vector-set! vertices (+ offset 3) (vector-ref base 3))
    (f32vector-set! vertices (+ offset 4) (vector-ref base 4))
    (f32vector-set! vertices (+ offset 5) (vector-ref base 5))))

(define (main)
  (printf "=== SDL3 GPU Triangle Example ===\n\n")

  ;; Initialize SDL
  (sdl-init!)

  ;; Create GPU device with MSL shader support (for Metal on macOS)
  (define device (make-gpu-device #:shader-formats SDL_GPU_SHADERFORMAT_MSL
                                   #:debug? #t))
  (printf "GPU Device created: ~a\n" (gpu-device-driver device))

  ;; Create window
  (define win (make-window "GPU Triangle" 800 600))

  ;; Claim window for GPU rendering
  (gpu-claim-window! device win)
  (printf "Window claimed for GPU rendering\n")

  ;; Get swapchain format for the pipeline
  (define swapchain-format (gpu-swapchain-texture-format device win))
  (printf "Swapchain format: ~a\n" swapchain-format)

  ;; Create shaders
  (define vertex-shader-bytes (string->bytes/utf-8 vertex-shader-msl))
  (define fragment-shader-bytes (string->bytes/utf-8 fragment-shader-msl))

  (define vs-info (make-SDL_GPUShaderCreateInfo
                   (bytes-length vertex-shader-bytes)
                   vertex-shader-bytes
                   "vs_main"
                   SDL_GPU_SHADERFORMAT_MSL
                   SDL_GPU_SHADERSTAGE_VERTEX
                   0  ; num_samplers
                   0  ; num_storage_textures
                   0  ; num_storage_buffers
                   0  ; num_uniform_buffers
                   0)) ; props

  (define fs-info (make-SDL_GPUShaderCreateInfo
                   (bytes-length fragment-shader-bytes)
                   fragment-shader-bytes
                   "fs_main"
                   SDL_GPU_SHADERFORMAT_MSL
                   SDL_GPU_SHADERSTAGE_FRAGMENT
                   0  ; num_samplers
                   0  ; num_storage_textures
                   0  ; num_storage_buffers
                   0  ; num_uniform_buffers
                   0)) ; props

  (define vertex-shader (make-gpu-shader device vs-info))
  (define fragment-shader (make-gpu-shader device fs-info))
  (printf "Shaders created\n")

  ;; Create vertex buffer
  (define vb-info (make-SDL_GPUBufferCreateInfo
                   SDL_GPU_BUFFERUSAGE_VERTEX
                   (* VERTEX_SIZE NUM_VERTICES)
                   0))
  (define vertex-buffer (make-gpu-buffer device vb-info))

  ;; Create transfer buffer to upload vertex data
  (define tb-info (make-SDL_GPUTransferBufferCreateInfo
                   SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD
                   (* VERTEX_SIZE NUM_VERTICES)
                   0))
  (define transfer-buffer (make-gpu-transfer-buffer device tb-info))

  ;; Upload to GPU buffer via copy pass
  (define src-loc (make-SDL_GPUTransferBufferLocation
                   (gpu-transfer-buffer-ptr transfer-buffer)
                   0))
  (define dst-region (make-SDL_GPUBufferRegion
                      (gpu-buffer-ptr vertex-buffer)
                      0
                      (* VERTEX_SIZE NUM_VERTICES)))

  (define (upload-vertices! cmd)
    (define mapped-ptr (gpu-map-transfer-buffer device transfer-buffer))
    (memcpy mapped-ptr (f32vector->cpointer triangle-vertices) (* VERTEX_SIZE NUM_VERTICES))
    (gpu-unmap-transfer-buffer! device transfer-buffer)
    (define copy-pass (gpu-begin-copy-pass cmd))
    (gpu-upload-to-buffer! copy-pass src-loc dst-region)
    (gpu-end-copy-pass! copy-pass))

  (write-rotated-vertices! triangle-vertices 0.0)
  (define cmd (gpu-acquire-command-buffer device))
  (upload-vertices! cmd)
  (gpu-submit! cmd)
  (printf "Vertex buffer uploaded to GPU\n")

  ;; Set up vertex input state
  ;; Vertex buffer description - use make- constructor directly
  (define vb-desc (make-SDL_GPUVertexBufferDescription
                   0                                ; slot
                   VERTEX_SIZE                      ; pitch
                   SDL_GPU_VERTEXINPUTRATE_VERTEX   ; input_rate
                   0))                              ; instance_step_rate
  ;; Need pointer for SDL API
  (define vb-descs-ptr (malloc _SDL_GPUVertexBufferDescription 'atomic))
  (memcpy vb-descs-ptr vb-desc (ctype-sizeof _SDL_GPUVertexBufferDescription))

  ;; Vertex attributes - create array of 2 attributes
  (define attr0 (make-SDL_GPUVertexAttribute
                 0                                  ; location
                 0                                  ; buffer_slot
                 SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2 ; format (position)
                 0))                                ; offset
  (define attr1 (make-SDL_GPUVertexAttribute
                 1                                  ; location
                 0                                  ; buffer_slot
                 SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4 ; format (color)
                 8))                                ; offset (2 floats * 4 bytes)
  ;; Allocate and copy array
  (define v-attrs-ptr (malloc (* 2 (ctype-sizeof _SDL_GPUVertexAttribute)) 'atomic))
  (memcpy v-attrs-ptr attr0 (ctype-sizeof _SDL_GPUVertexAttribute))
  (memcpy (ptr-add v-attrs-ptr (ctype-sizeof _SDL_GPUVertexAttribute))
          attr1 (ctype-sizeof _SDL_GPUVertexAttribute))

  ;; Vertex input state
  (define vertex-input (make-SDL_GPUVertexInputState
                        vb-descs-ptr
                        1  ; num_vertex_buffers
                        v-attrs-ptr
                        2)) ; num_vertex_attributes

  ;; Color target blend state (no blending, just write)
  (define blend-state (make-SDL_GPUColorTargetBlendState
                       SDL_GPU_BLENDFACTOR_ONE
                       SDL_GPU_BLENDFACTOR_ZERO
                       SDL_GPU_BLENDOP_ADD
                       SDL_GPU_BLENDFACTOR_ONE
                       SDL_GPU_BLENDFACTOR_ZERO
                       SDL_GPU_BLENDOP_ADD
                       (bitwise-ior SDL_GPU_COLORCOMPONENT_R
                                    SDL_GPU_COLORCOMPONENT_G
                                    SDL_GPU_COLORCOMPONENT_B
                                    SDL_GPU_COLORCOMPONENT_A)
                       #f   ; enable_blend
                       #f   ; enable_color_write_mask
                       0))  ; padding

  ;; Color target description
  (define color-target-desc (make-SDL_GPUColorTargetDescription
                             swapchain-format
                             blend-state))
  (define color-target-descs-ptr (malloc _SDL_GPUColorTargetDescription 'atomic))
  (memcpy color-target-descs-ptr color-target-desc (ctype-sizeof _SDL_GPUColorTargetDescription))

  ;; Target info
  (define target-info (make-SDL_GPUGraphicsPipelineTargetInfo
                       color-target-descs-ptr
                       1  ; num_color_targets
                       SDL_GPU_TEXTUREFORMAT_INVALID  ; no depth
                       #f  ; has_depth_stencil_target
                       0 0 0)) ; padding

  ;; Rasterizer state
  (define raster-state (make-SDL_GPURasterizerState
                        SDL_GPU_FILLMODE_FILL
                        SDL_GPU_CULLMODE_NONE
                        SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE
                        0.0 0.0 0.0  ; depth bias
                        #f #f        ; enable flags
                        0 0))        ; padding

  ;; Multisample state
  (define ms-state (make-SDL_GPUMultisampleState
                    SDL_GPU_SAMPLECOUNT_1
                    0    ; sample_mask
                    #f   ; enable_mask
                    0 0 0)) ; padding

  ;; Depth stencil state (disabled)
  (define ds-state (make-SDL_GPUDepthStencilState
                    SDL_GPU_COMPAREOP_ALWAYS
                    (make-SDL_GPUStencilOpState
                     SDL_GPU_STENCILOP_KEEP SDL_GPU_STENCILOP_KEEP
                     SDL_GPU_STENCILOP_KEEP SDL_GPU_COMPAREOP_ALWAYS)
                    (make-SDL_GPUStencilOpState
                     SDL_GPU_STENCILOP_KEEP SDL_GPU_STENCILOP_KEEP
                     SDL_GPU_STENCILOP_KEEP SDL_GPU_COMPAREOP_ALWAYS)
                    0 0  ; compare_mask, write_mask
                    #f #f #f  ; enable flags
                    0 0 0))   ; padding

  ;; Create graphics pipeline
  (define pipeline-info (make-SDL_GPUGraphicsPipelineCreateInfo
                         (gpu-shader-ptr vertex-shader)
                         (gpu-shader-ptr fragment-shader)
                         vertex-input
                         SDL_GPU_PRIMITIVETYPE_TRIANGLELIST
                         raster-state
                         ms-state
                         ds-state
                         target-info
                         0))  ; props

  (define pipeline (make-gpu-graphics-pipeline device pipeline-info))
  (printf "Graphics pipeline created\n")

  ;; Shaders can be released after pipeline creation
  (gpu-shader-destroy! vertex-shader)
  (gpu-shader-destroy! fragment-shader)

  ;; Main render loop
  (printf "Starting render loop (press ESC or close window to exit)...\n")
  (define running? #t)
  (define start-time (current-ticks))

  (let loop ()
    (when running?
      ;; Process events
      (for ([e (in-events)])
        (match e
          [(quit-event) (set! running? #f)]
          [(key-event 'down 'escape _ _ _) (set! running? #f)]
          [_ (void)]))

      (when running?
        (define now (current-ticks))
        (define time-sec (/ (- now start-time) 1000.0))
        (define angle (* time-sec (degrees->radians 90.0)))
        (write-rotated-vertices! triangle-vertices angle)

        ;; Acquire command buffer
        (define cmd (gpu-acquire-command-buffer device))
        (upload-vertices! cmd)

        ;; Acquire swapchain texture
        (define-values (swapchain-tex width height)
          (gpu-acquire-swapchain-texture cmd win))

        (when swapchain-tex
          ;; Set up color target using constructor
          (define clear-color (make-SDL_FColor 0.1 0.1 0.2 1.0))
          (define color-target-info (make-SDL_GPUColorTargetInfo
                                     swapchain-tex      ; texture
                                     0                  ; mip_level
                                     0                  ; layer_or_depth_plane
                                     clear-color        ; clear_color
                                     SDL_GPU_LOADOP_CLEAR   ; load_op
                                     SDL_GPU_STOREOP_STORE  ; store_op
                                     #f                 ; resolve_texture
                                     0                  ; resolve_mip_level
                                     0                  ; resolve_layer
                                     #f                 ; cycle
                                     #f                 ; cycle_resolve_texture
                                     0                  ; padding1
                                     0))                ; padding2
          (define color-target-ptr (malloc _SDL_GPUColorTargetInfo 'atomic))
          (memcpy color-target-ptr color-target-info (ctype-sizeof _SDL_GPUColorTargetInfo))

          ;; Begin render pass
          (define render-pass (gpu-begin-render-pass cmd color-target-ptr))

          ;; Bind pipeline
          (gpu-bind-graphics-pipeline! render-pass pipeline)

          ;; Bind vertex buffer using constructor
          (define vb-binding-struct (make-SDL_GPUBufferBinding
                                     (gpu-buffer-ptr vertex-buffer)
                                     0))
          (define vb-binding-ptr (malloc _SDL_GPUBufferBinding 'atomic))
          (memcpy vb-binding-ptr vb-binding-struct (ctype-sizeof _SDL_GPUBufferBinding))
          (gpu-bind-vertex-buffers! render-pass vb-binding-ptr)

          ;; Draw triangle
          (gpu-draw-primitives! render-pass 3)

          ;; End render pass
          (gpu-end-render-pass! render-pass))

        ;; Submit command buffer
        (gpu-submit! cmd)

        ;; Small delay to prevent 100% CPU
        (sleep 0.001))

      (loop)))

  ;; Cleanup
  (printf "\nCleaning up...\n")
  (gpu-wait-for-idle! device)
  (gpu-graphics-pipeline-destroy! pipeline)
  (gpu-buffer-destroy! vertex-buffer)
  (gpu-transfer-buffer-destroy! transfer-buffer)
  (gpu-release-window! device win)
  (window-destroy! win)
  (gpu-device-destroy! device)
  (printf "Done!\n"))

(main)
