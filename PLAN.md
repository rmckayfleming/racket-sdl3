# Development Plan

## Phase 1: Cleanup & Simplification [DONE]
- [x] Remove `SDL_AddTimer`, `SDL_AddTimerNS`, and `SDL_RemoveTimer` from `raw/timer.rkt`.
- [x] Remove `SDL_Delay` and `SDL_DelayNS` from `raw/timer.rkt` (superseded by Racket `sleep`).
- [x] Refactor `examples/animation/timer-callbacks.rkt` to use `racket/timer` or Racket threads to demonstrate the idiomatic way.
- [x] Verify `safe/timer.rkt` and all existing examples remain functional.

## Phase 2: OpenGL Support [DONE]
- [x] Bind `SDL_GL_LoadLibrary`, `SDL_GL_CreateContext`, `SDL_GL_MakeCurrent`, `SDL_GL_SwapWindow`, etc.
- [x] Add `safe/gl.rkt` wrapper for context creation and resource management.
- [x] **Example:** Add `examples/graphics/opengl-basic.rkt` showing a simple GL clear and triangle.

## Phase 3: Vulkan Support [DONE]
- [x] Bind `SDL_Vulkan_LoadLibrary`, `SDL_Vulkan_CreateSurface`, `SDL_Vulkan_GetPresentationSupport`.
- [x] Add `safe/vulkan.rkt` wrapper for surface creation.
- [x] **Example:** Add `examples/graphics/vulkan-info.rkt` to demonstrate surface creation and extension enumeration.

## Phase 4: The GPU Subsystem (SDL_gpu) [DONE]
- [x] Bind `SDL_CreateGPUDevice`, `SDL_DestroyGPUDevice`.
- [x] Implement command buffer and pass submission.
- [x] Bind shader and pipeline creation functions.
- [x] Bind buffer, texture, and sampler management.
- [x] Bind render pass and drawing functions.
- [x] Bind compute pipeline and dispatch functions.
- [x] Add `safe/gpu.rkt` wrapper for safe resource management.
- [x] **Example:** Add `examples/graphics/gpu-info.rkt` showing device and format info.
- [x] **Example:** Add `examples/graphics/gpu-triangle.rkt` using the new SDL3 GPU API with Metal shaders.
- [x] **Example:** Add `examples/graphics/gpu-cube.rkt` showing a rotating 3D cube with depth testing.

## Phase 5: Camera & Video Input [DONE]
- [x] Bind `SDL_camera.h` functions (enumeration, open/close).
- [x] Add `safe/camera.rkt` for idiomatic camera usage.
- [x] **Example:** Add `examples/video/camera-preview.rkt` to show a live camera feed.

## Phase 6: System Tray Integration [DONE]
- [x] Implement `SDL_tray.h` bindings for system tray icons and menus.
- [x] **Example:** Add `examples/system/tray-menu.rkt`.
