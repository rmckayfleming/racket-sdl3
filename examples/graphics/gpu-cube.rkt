#lang racket/base

;; GPU Cube Example
;;
;; Demonstrates the SDL3 GPU API by rendering a rotating 3D cube with depth.
;; Uses Metal shaders on macOS.

(require ffi/unsafe
         ffi/vector
         racket/math
         racket/match
         sdl3
         sdl3/raw)

;; Metal shader source code (MSL)
(define vertex-shader-msl #<<MSL
#include <metal_stdlib>
using namespace metal;

struct VertexInput {
    float3 position [[attribute(0)]];
    float4 color [[attribute(1)]];
};

struct VertexOutput {
    float4 position [[position]];
    float4 color;
};

vertex VertexOutput vs_main(VertexInput in [[stage_in]]) {
    VertexOutput out;
    out.position = float4(in.position, 1.0);
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

(define (vtx x y z r g b a)
  (vector x y z r g b a))

(define cube-base
  (vector
   ;; Front face (red)
   (vtx -1.0 -1.0  1.0  1.0 0.0 0.0 1.0)
   (vtx  1.0 -1.0  1.0  1.0 0.0 0.0 1.0)
   (vtx  1.0  1.0  1.0  1.0 0.0 0.0 1.0)
   (vtx -1.0 -1.0  1.0  1.0 0.0 0.0 1.0)
   (vtx  1.0  1.0  1.0  1.0 0.0 0.0 1.0)
   (vtx -1.0  1.0  1.0  1.0 0.0 0.0 1.0)

   ;; Back face (green)
   (vtx -1.0 -1.0 -1.0  0.0 1.0 0.0 1.0)
   (vtx -1.0  1.0 -1.0  0.0 1.0 0.0 1.0)
   (vtx  1.0  1.0 -1.0  0.0 1.0 0.0 1.0)
   (vtx -1.0 -1.0 -1.0  0.0 1.0 0.0 1.0)
   (vtx  1.0  1.0 -1.0  0.0 1.0 0.0 1.0)
   (vtx  1.0 -1.0 -1.0  0.0 1.0 0.0 1.0)

   ;; Top face (blue)
   (vtx -1.0  1.0 -1.0  0.0 0.0 1.0 1.0)
   (vtx -1.0  1.0  1.0  0.0 0.0 1.0 1.0)
   (vtx  1.0  1.0  1.0  0.0 0.0 1.0 1.0)
   (vtx -1.0  1.0 -1.0  0.0 0.0 1.0 1.0)
   (vtx  1.0  1.0  1.0  0.0 0.0 1.0 1.0)
   (vtx  1.0  1.0 -1.0  0.0 0.0 1.0 1.0)

   ;; Bottom face (yellow)
   (vtx -1.0 -1.0 -1.0  1.0 1.0 0.0 1.0)
   (vtx  1.0 -1.0 -1.0  1.0 1.0 0.0 1.0)
   (vtx  1.0 -1.0  1.0  1.0 1.0 0.0 1.0)
   (vtx -1.0 -1.0 -1.0  1.0 1.0 0.0 1.0)
   (vtx  1.0 -1.0  1.0  1.0 1.0 0.0 1.0)
   (vtx -1.0 -1.0  1.0  1.0 1.0 0.0 1.0)

   ;; Right face (magenta)
   (vtx  1.0 -1.0 -1.0  1.0 0.0 1.0 1.0)
   (vtx  1.0  1.0 -1.0  1.0 0.0 1.0 1.0)
   (vtx  1.0  1.0  1.0  1.0 0.0 1.0 1.0)
   (vtx  1.0 -1.0 -1.0  1.0 0.0 1.0 1.0)
   (vtx  1.0  1.0  1.0  1.0 0.0 1.0 1.0)
   (vtx  1.0 -1.0  1.0  1.0 0.0 1.0 1.0)

   ;; Left face (cyan)
   (vtx -1.0 -1.0 -1.0  0.0 1.0 1.0 1.0)
   (vtx -1.0 -1.0  1.0  0.0 1.0 1.0 1.0)
   (vtx -1.0  1.0  1.0  0.0 1.0 1.0 1.0)
   (vtx -1.0 -1.0 -1.0  0.0 1.0 1.0 1.0)
   (vtx -1.0  1.0  1.0  0.0 1.0 1.0 1.0)
   (vtx -1.0  1.0 -1.0  0.0 1.0 1.0 1.0)))

(define FLOATS-PER-VERTEX 7)
(define VERTEX_SIZE (* FLOATS-PER-VERTEX 4))
(define NUM_VERTICES (vector-length cube-base))

(define cube-vertices (make-f32vector (* NUM_VERTICES FLOATS-PER-VERTEX)))

(define DEPTH-FORMAT SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT)

(define NEAR-PLANE 1.5)
(define FAR-PLANE 20.0)
(define FOV-Y (* 2.0 (atan (/ 0.75 1.5))))

(define (write-transformed-vertices! vertices angle aspect)
  (define f (/ 1.0 (tan (/ FOV-Y 2.0))))
  (define m00 (/ f aspect))
  (define m11 f)
  (define m22 (/ FAR-PLANE (- NEAR-PLANE FAR-PLANE)))
  (define m23 (/ (* FAR-PLANE NEAR-PLANE) (- NEAR-PLANE FAR-PLANE)))

  (define axis (/ 1.0 (sqrt 2.0)))
  (define ax axis)
  (define ay axis)
  (define az 0.0)
  (define c (cos angle))
  (define s (sin angle))
  (define t (- 1.0 c))
  (define r00 (+ (* t ax ax) c))
  (define r01 (- (* t ax ay) (* s az)))
  (define r02 (+ (* t ax az) (* s ay)))
  (define r10 (+ (* t ax ay) (* s az)))
  (define r11 (+ (* t ay ay) c))
  (define r12 (- (* t ay az) (* s ax)))
  (define r20 (- (* t ax az) (* s ay)))
  (define r21 (+ (* t ay az) (* s ax)))
  (define r22 (+ (* t az az) c))

  (for ([i (in-range NUM_VERTICES)])
    (define base (vector-ref cube-base i))
    (define x (vector-ref base 0))
    (define y (vector-ref base 1))
    (define z (vector-ref base 2))

    (define rx (+ (* r00 x) (* r01 y) (* r02 z)))
    (define ry (+ (* r10 x) (* r11 y) (* r12 z)))
    (define rz (+ (* r20 x) (* r21 y) (* r22 z)))

    (define vz (- rz 6.0))
    (define clip-x (* m00 rx))
    (define clip-y (* m11 ry))
    (define clip-z (+ (* m22 vz) m23))
    (define w (- vz))

    (define ndc-x (/ clip-x w))
    (define ndc-y (/ clip-y w))
    (define ndc-z (/ clip-z w))

    (define offset (* i FLOATS-PER-VERTEX))
    (f32vector-set! vertices offset ndc-x)
    (f32vector-set! vertices (+ offset 1) ndc-y)
    (f32vector-set! vertices (+ offset 2) ndc-z)
    (f32vector-set! vertices (+ offset 3) (vector-ref base 3))
    (f32vector-set! vertices (+ offset 4) (vector-ref base 4))
    (f32vector-set! vertices (+ offset 5) (vector-ref base 5))
    (f32vector-set! vertices (+ offset 6) (vector-ref base 6))))

(define (main)
  (printf "=== SDL3 GPU Cube Example ===\n\n")

  (sdl-init!)

  (define device (make-gpu-device #:shader-formats SDL_GPU_SHADERFORMAT_MSL
                                   #:debug? #t))
  (printf "GPU Device created: ~a\n" (gpu-device-driver device))

  (define win (make-window "GPU Cube" 800 600))

  (gpu-claim-window! device win)
  (printf "Window claimed for GPU rendering\n")

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
                   0 0 0 0
                   0))

  (define fs-info (make-SDL_GPUShaderCreateInfo
                   (bytes-length fragment-shader-bytes)
                   fragment-shader-bytes
                   "fs_main"
                   SDL_GPU_SHADERFORMAT_MSL
                   SDL_GPU_SHADERSTAGE_FRAGMENT
                   0 0 0 0
                   0))

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

  (define src-loc (make-SDL_GPUTransferBufferLocation
                   (gpu-transfer-buffer-ptr transfer-buffer)
                   0))
  (define dst-region (make-SDL_GPUBufferRegion
                      (gpu-buffer-ptr vertex-buffer)
                      0
                      (* VERTEX_SIZE NUM_VERTICES)))

  (define (upload-vertices! cmd)
    (define mapped-ptr (gpu-map-transfer-buffer device transfer-buffer))
    (memcpy mapped-ptr (f32vector->cpointer cube-vertices) (* VERTEX_SIZE NUM_VERTICES))
    (gpu-unmap-transfer-buffer! device transfer-buffer)
    (define copy-pass (gpu-begin-copy-pass cmd))
    (gpu-upload-to-buffer! copy-pass src-loc dst-region)
    (gpu-end-copy-pass! copy-pass))

  ;; Set up vertex input state
  (define vb-desc (make-SDL_GPUVertexBufferDescription
                   0
                   VERTEX_SIZE
                   SDL_GPU_VERTEXINPUTRATE_VERTEX
                   0))
  (define vb-descs-ptr (malloc _SDL_GPUVertexBufferDescription 'atomic))
  (memcpy vb-descs-ptr vb-desc (ctype-sizeof _SDL_GPUVertexBufferDescription))

  (define attr0 (make-SDL_GPUVertexAttribute
                 0
                 0
                 SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3
                 0))
  (define attr1 (make-SDL_GPUVertexAttribute
                 1
                 0
                 SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4
                 12))
  (define v-attrs-ptr (malloc (* 2 (ctype-sizeof _SDL_GPUVertexAttribute)) 'atomic))
  (memcpy v-attrs-ptr attr0 (ctype-sizeof _SDL_GPUVertexAttribute))
  (memcpy (ptr-add v-attrs-ptr (ctype-sizeof _SDL_GPUVertexAttribute))
          attr1 (ctype-sizeof _SDL_GPUVertexAttribute))

  (define vertex-input (make-SDL_GPUVertexInputState
                        vb-descs-ptr
                        1
                        v-attrs-ptr
                        2))

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
                       #f
                       #f
                       0))

  (define color-target-desc (make-SDL_GPUColorTargetDescription
                             swapchain-format
                             blend-state))
  (define color-target-descs-ptr (malloc _SDL_GPUColorTargetDescription 'atomic))
  (memcpy color-target-descs-ptr color-target-desc
          (ctype-sizeof _SDL_GPUColorTargetDescription))

  (define target-info (make-SDL_GPUGraphicsPipelineTargetInfo
                       color-target-descs-ptr
                       1
                       DEPTH-FORMAT
                       #t
                       0 0 0))

  (define raster-state (make-SDL_GPURasterizerState
                        SDL_GPU_FILLMODE_FILL
                        SDL_GPU_CULLMODE_NONE
                        SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE
                        0.0 0.0 0.0
                        #f #f
                        0 0))

  (define ms-state (make-SDL_GPUMultisampleState
                    SDL_GPU_SAMPLECOUNT_1
                    0
                    #f
                    0 0 0))

  (define ds-state (make-SDL_GPUDepthStencilState
                    SDL_GPU_COMPAREOP_LESS
                    (make-SDL_GPUStencilOpState
                     SDL_GPU_STENCILOP_KEEP SDL_GPU_STENCILOP_KEEP
                     SDL_GPU_STENCILOP_KEEP SDL_GPU_COMPAREOP_ALWAYS)
                    (make-SDL_GPUStencilOpState
                     SDL_GPU_STENCILOP_KEEP SDL_GPU_STENCILOP_KEEP
                     SDL_GPU_STENCILOP_KEEP SDL_GPU_COMPAREOP_ALWAYS)
                    0 0
                    #t #t #f
                    0 0 0))

  (define pipeline-info (make-SDL_GPUGraphicsPipelineCreateInfo
                         (gpu-shader-ptr vertex-shader)
                         (gpu-shader-ptr fragment-shader)
                         vertex-input
                         SDL_GPU_PRIMITIVETYPE_TRIANGLELIST
                         raster-state
                         ms-state
                         ds-state
                         target-info
                         0))

  (define pipeline (make-gpu-graphics-pipeline device pipeline-info))
  (printf "Graphics pipeline created\n")

  (gpu-shader-destroy! vertex-shader)
  (gpu-shader-destroy! fragment-shader)

  (define depth-texture #f)
  (define depth-width 0)
  (define depth-height 0)

  (define (ensure-depth-texture width height)
    (when (or (not depth-texture)
              (not (= width depth-width))
              (not (= height depth-height)))
      (when depth-texture
        (gpu-texture-destroy! depth-texture))
      (set! depth-width width)
      (set! depth-height height)
      (define depth-info (make-SDL_GPUTextureCreateInfo
                          SDL_GPU_TEXTURETYPE_2D
                          DEPTH-FORMAT
                          SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET
                          width
                          height
                          1
                          1
                          SDL_GPU_SAMPLECOUNT_1
                          0))
      (set! depth-texture (make-gpu-texture device depth-info))))

  ;; Main render loop
  (printf "Starting render loop (press ESC or close window to exit)...\n")
  (define running? #t)
  (define start-time (current-ticks))

  (let loop ()
    (when running?
      (for ([e (in-events)])
        (match e
          [(quit-event) (set! running? #f)]
          [(key-event 'down 'escape _ _ _) (set! running? #f)]
          [_ (void)]))

      (when running?
        (define now (current-ticks))
        (define t (/ (- now start-time) 1000.0))
        (define angle (* t (degrees->radians 50.0)))

        (define cmd (gpu-acquire-command-buffer device))

        (define-values (swapchain-tex width height)
          (gpu-acquire-swapchain-texture cmd win))

        (when swapchain-tex
          (ensure-depth-texture width height)
          (define aspect (/ (exact->inexact width) (max 1.0 (exact->inexact height))))
          (write-transformed-vertices! cube-vertices angle aspect)
          (upload-vertices! cmd)

          (define clear-color (make-SDL_FColor 0.2 0.2 0.2 1.0))
          (define color-target-info (make-SDL_GPUColorTargetInfo
                                     swapchain-tex
                                     0
                                     0
                                     clear-color
                                     SDL_GPU_LOADOP_CLEAR
                                     SDL_GPU_STOREOP_STORE
                                     #f
                                     0
                                     0
                                     #f
                                     #f
                                     0
                                     0))
          (define color-target-ptr (malloc _SDL_GPUColorTargetInfo 'atomic))
          (memcpy color-target-ptr color-target-info
                  (ctype-sizeof _SDL_GPUColorTargetInfo))

          (define depth-target-info (make-SDL_GPUDepthStencilTargetInfo
                                     depth-texture
                                     1.0
                                     SDL_GPU_LOADOP_CLEAR
                                     SDL_GPU_STOREOP_DONT_CARE
                                     SDL_GPU_LOADOP_DONT_CARE
                                     SDL_GPU_STOREOP_DONT_CARE
                                     #f
                                     0
                                     0 0))
          (define depth-target-ptr (malloc _SDL_GPUDepthStencilTargetInfo 'atomic))
          (memcpy depth-target-ptr depth-target-info
                  (ctype-sizeof _SDL_GPUDepthStencilTargetInfo))

          (define render-pass
            (gpu-begin-render-pass cmd color-target-ptr
                                   #:depth-stencil-target depth-target-ptr))

          (define viewport (make-SDL_GPUViewport 0.0 0.0
                                                 (exact->inexact width)
                                                 (exact->inexact height)
                                                 0.0 1.0))
          (gpu-set-viewport! render-pass viewport)

          (gpu-bind-graphics-pipeline! render-pass pipeline)

          (define vb-binding-struct (make-SDL_GPUBufferBinding
                                     (gpu-buffer-ptr vertex-buffer)
                                     0))
          (define vb-binding-ptr (malloc _SDL_GPUBufferBinding 'atomic))
          (memcpy vb-binding-ptr vb-binding-struct
                  (ctype-sizeof _SDL_GPUBufferBinding))
          (gpu-bind-vertex-buffers! render-pass vb-binding-ptr)

          (gpu-draw-primitives! render-pass NUM_VERTICES)

          (gpu-end-render-pass! render-pass))

        (gpu-submit! cmd)
        (sleep 0.001))

      (loop)))

  (printf "\nCleaning up...\n")
  (gpu-wait-for-idle! device)
  (when depth-texture
    (gpu-texture-destroy! depth-texture))
  (gpu-graphics-pipeline-destroy! pipeline)
  (gpu-buffer-destroy! vertex-buffer)
  (gpu-transfer-buffer-destroy! transfer-buffer)
  (gpu-release-window! device win)
  (window-destroy! win)
  (gpu-device-destroy! device)
  (printf "Done!\n"))

(main)
