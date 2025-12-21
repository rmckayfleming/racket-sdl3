#lang racket/base

;; SDL3 Type Definitions
;; This module contains FFI type definitions (structs, cpointer types, FFI type aliases).
;; For constants and flags, see constants.rkt.
;; For keycodes and scancodes, see enums.rkt.

(require ffi/unsafe)

(provide check-sdl-bool
         _sdl-bool
         ;; FFI type aliases
         _SDL_InitFlags
         _SDL_WindowFlags
         _SDL_PropertiesID
         _SDL_GLContext-pointer
         _SDL_GLContext-pointer/null
         _SDL_GLAttr
         ;; Vulkan types
         _VkInstance
         _VkPhysicalDevice
         _VkSurfaceKHR
         _VkAllocationCallbacks-pointer/null
         ;; Pointer types
         _SDL_Window-pointer
         _SDL_Window-pointer/null
         _SDL_Renderer-pointer
         _SDL_Renderer-pointer/null
         _SDL_Texture-pointer
         _SDL_Texture-pointer/null
         _SDL_IOStream-pointer
         _SDL_IOStream-pointer/null
         _SDL_Cursor-pointer
         _SDL_Cursor-pointer/null
         _SDL_Tray-pointer
         _SDL_Tray-pointer/null
         _SDL_TrayMenu-pointer
         _SDL_TrayMenu-pointer/null
         _SDL_TrayEntry-pointer
         _SDL_TrayEntry-pointer/null
         _SDL_Camera-pointer
         _SDL_Camera-pointer/null
         _SDL_GPUDevice-pointer
         _SDL_GPUDevice-pointer/null
         _SDL_GPUTexture-pointer
         _SDL_GPUTexture-pointer/null
         _SDL_GPUBuffer-pointer
         _SDL_GPUBuffer-pointer/null
         _SDL_GPUTransferBuffer-pointer
         _SDL_GPUTransferBuffer-pointer/null
         _SDL_GPUSampler-pointer
         _SDL_GPUSampler-pointer/null
         _SDL_GPUShader-pointer
         _SDL_GPUShader-pointer/null
         _SDL_GPUComputePipeline-pointer
         _SDL_GPUComputePipeline-pointer/null
         _SDL_GPUGraphicsPipeline-pointer
         _SDL_GPUGraphicsPipeline-pointer/null
         _SDL_GPUCommandBuffer-pointer
         _SDL_GPUCommandBuffer-pointer/null
         _SDL_GPURenderPass-pointer
         _SDL_GPURenderPass-pointer/null
         _SDL_GPUComputePass-pointer
         _SDL_GPUComputePass-pointer/null
         _SDL_GPUCopyPass-pointer
         _SDL_GPUCopyPass-pointer/null
         _SDL_GPUFence-pointer
         _SDL_GPUFence-pointer/null
         ;; GPU enums
         _SDL_GPUPrimitiveType
         _SDL_GPULoadOp
         _SDL_GPUStoreOp
         _SDL_GPUIndexElementSize
         _SDL_GPUTextureFormat
         _SDL_GPUTextureUsageFlags
         _SDL_GPUTextureType
         _SDL_GPUSampleCount
         _SDL_GPUBufferUsageFlags
         _SDL_GPUTransferBufferUsage
         _SDL_GPUShaderStage
         _SDL_GPUShaderFormat
         _SDL_GPUVertexElementFormat
         _SDL_GPUVertexInputRate
         _SDL_GPUFillMode
         _SDL_GPUCullMode
         _SDL_GPUFrontFace
         _SDL_GPUCompareOp
         _SDL_GPUStencilOp
         _SDL_GPUBlendOp
         _SDL_GPUBlendFactor
         _SDL_GPUColorComponentFlags
         _SDL_GPUFilter
         _SDL_GPUSamplerMipmapMode
         _SDL_GPUSamplerAddressMode
         _SDL_GPUPresentMode
         _SDL_GPUSwapchainComposition
         ;; GPU structs
         _SDL_GPUViewport
         _SDL_GPUViewport-pointer
         make-SDL_GPUViewport
         SDL_GPUViewport-x
         SDL_GPUViewport-y
         SDL_GPUViewport-w
         SDL_GPUViewport-h
         SDL_GPUViewport-min_depth
         SDL_GPUViewport-max_depth
         _SDL_GPUColorTargetInfo
         _SDL_GPUColorTargetInfo-pointer
         make-SDL_GPUColorTargetInfo
         SDL_GPUColorTargetInfo-texture
         SDL_GPUColorTargetInfo-mip_level
         SDL_GPUColorTargetInfo-layer_or_depth_plane
         SDL_GPUColorTargetInfo-clear_color
         SDL_GPUColorTargetInfo-load_op
         SDL_GPUColorTargetInfo-store_op
         SDL_GPUColorTargetInfo-resolve_texture
         SDL_GPUColorTargetInfo-resolve_mip_level
         SDL_GPUColorTargetInfo-resolve_layer
         SDL_GPUColorTargetInfo-cycle
         SDL_GPUColorTargetInfo-cycle_resolve_texture
         set-SDL_GPUColorTargetInfo-texture!
         set-SDL_GPUColorTargetInfo-mip_level!
         set-SDL_GPUColorTargetInfo-layer_or_depth_plane!
         set-SDL_GPUColorTargetInfo-clear_color!
         set-SDL_GPUColorTargetInfo-load_op!
         set-SDL_GPUColorTargetInfo-store_op!
         set-SDL_GPUColorTargetInfo-resolve_texture!
         set-SDL_GPUColorTargetInfo-resolve_mip_level!
         set-SDL_GPUColorTargetInfo-resolve_layer!
         set-SDL_GPUColorTargetInfo-cycle!
         set-SDL_GPUColorTargetInfo-cycle_resolve_texture!
         _SDL_GPUDepthStencilTargetInfo
         _SDL_GPUDepthStencilTargetInfo-pointer
         _SDL_GPUDepthStencilTargetInfo-pointer/null
         make-SDL_GPUDepthStencilTargetInfo
         _SDL_GPUSamplerCreateInfo
         _SDL_GPUSamplerCreateInfo-pointer
         make-SDL_GPUSamplerCreateInfo
         _SDL_GPUVertexBufferDescription
         _SDL_GPUVertexBufferDescription-pointer
         make-SDL_GPUVertexBufferDescription
         set-SDL_GPUVertexBufferDescription-slot!
         set-SDL_GPUVertexBufferDescription-pitch!
         set-SDL_GPUVertexBufferDescription-input_rate!
         set-SDL_GPUVertexBufferDescription-instance_step_rate!
         _SDL_GPUVertexAttribute
         _SDL_GPUVertexAttribute-pointer
         make-SDL_GPUVertexAttribute
         set-SDL_GPUVertexAttribute-location!
         set-SDL_GPUVertexAttribute-buffer_slot!
         set-SDL_GPUVertexAttribute-format!
         set-SDL_GPUVertexAttribute-offset!
         _SDL_GPUVertexInputState
         _SDL_GPUVertexInputState-pointer
         make-SDL_GPUVertexInputState
         _SDL_GPUStencilOpState
         make-SDL_GPUStencilOpState
         _SDL_GPUColorTargetBlendState
         make-SDL_GPUColorTargetBlendState
         _SDL_GPUColorTargetDescription
         _SDL_GPUColorTargetDescription-pointer
         make-SDL_GPUColorTargetDescription
         set-SDL_GPUColorTargetDescription-format!
         set-SDL_GPUColorTargetDescription-blend_state!
         _SDL_GPURasterizerState
         make-SDL_GPURasterizerState
         _SDL_GPUMultisampleState
         make-SDL_GPUMultisampleState
         _SDL_GPUDepthStencilState
         make-SDL_GPUDepthStencilState
         _SDL_GPUGraphicsPipelineTargetInfo
         make-SDL_GPUGraphicsPipelineTargetInfo
         _SDL_GPUGraphicsPipelineCreateInfo
         _SDL_GPUGraphicsPipelineCreateInfo-pointer
         make-SDL_GPUGraphicsPipelineCreateInfo
         _SDL_GPUShaderCreateInfo
         _SDL_GPUShaderCreateInfo-pointer
         make-SDL_GPUShaderCreateInfo
         _SDL_GPUTextureCreateInfo
         _SDL_GPUTextureCreateInfo-pointer
         make-SDL_GPUTextureCreateInfo
         _SDL_GPUBufferCreateInfo
         _SDL_GPUBufferCreateInfo-pointer
         make-SDL_GPUBufferCreateInfo
         _SDL_GPUTransferBufferCreateInfo
         _SDL_GPUTransferBufferCreateInfo-pointer
         make-SDL_GPUTransferBufferCreateInfo
         _SDL_GPUBufferBinding
         _SDL_GPUBufferBinding-pointer
         make-SDL_GPUBufferBinding
         set-SDL_GPUBufferBinding-buffer!
         set-SDL_GPUBufferBinding-offset!
         _SDL_GPUTextureSamplerBinding
         _SDL_GPUTextureSamplerBinding-pointer
         make-SDL_GPUTextureSamplerBinding
         _SDL_GPUBufferRegion
         _SDL_GPUBufferRegion-pointer
         make-SDL_GPUBufferRegion
         _SDL_GPUTransferBufferLocation
         _SDL_GPUTransferBufferLocation-pointer
         make-SDL_GPUTransferBufferLocation
         _SDL_GPUBufferLocation
         _SDL_GPUBufferLocation-pointer
         make-SDL_GPUBufferLocation
         _SDL_GPUTextureLocation
         _SDL_GPUTextureLocation-pointer
         make-SDL_GPUTextureLocation
         _SDL_GPUTextureRegion
         _SDL_GPUTextureRegion-pointer
         make-SDL_GPUTextureRegion
         _SDL_GPUTextureTransferInfo
         _SDL_GPUTextureTransferInfo-pointer
         make-SDL_GPUTextureTransferInfo
         _SDL_GPUBlitRegion
         make-SDL_GPUBlitRegion
         _SDL_GPUBlitInfo
         _SDL_GPUBlitInfo-pointer
         make-SDL_GPUBlitInfo
         _SDL_GPUComputePipelineCreateInfo
         _SDL_GPUComputePipelineCreateInfo-pointer
         make-SDL_GPUComputePipelineCreateInfo
         _SDL_GPUStorageBufferReadWriteBinding
         _SDL_GPUStorageBufferReadWriteBinding-pointer
         make-SDL_GPUStorageBufferReadWriteBinding
         _SDL_GPUStorageTextureReadWriteBinding
         _SDL_GPUStorageTextureReadWriteBinding-pointer
         make-SDL_GPUStorageTextureReadWriteBinding
         ;; Surface struct
         _SDL_Surface
         _SDL_Surface-pointer
         _SDL_Surface-pointer/null
         SDL_Surface-flags
         SDL_Surface-format
         SDL_Surface-w
         SDL_Surface-h
         SDL_Surface-pitch
         SDL_Surface-pixels
         ;; Integer point struct
         _SDL_Point
         _SDL_Point-pointer
         _SDL_Point-pointer/null
         make-SDL_Point
         SDL_Point-x
         SDL_Point-y
         set-SDL_Point-x!
         set-SDL_Point-y!
         ;; Float point struct
         _SDL_FPoint
         _SDL_FPoint-pointer
         _SDL_FPoint-pointer/null
         make-SDL_FPoint
         SDL_FPoint-x
         SDL_FPoint-y
         set-SDL_FPoint-x!
         set-SDL_FPoint-y!
         ;; Integer rect struct
         _SDL_Rect
         _SDL_Rect-pointer
         _SDL_Rect-pointer/null
         make-SDL_Rect
         SDL_Rect-x
         SDL_Rect-y
         SDL_Rect-w
         SDL_Rect-h
         set-SDL_Rect-x!
         set-SDL_Rect-y!
         set-SDL_Rect-w!
         set-SDL_Rect-h!
         ;; Float rect struct
         _SDL_FRect
         _SDL_FRect-pointer
         _SDL_FRect-pointer/null
         make-SDL_FRect
         SDL_FRect-x
         SDL_FRect-y
         SDL_FRect-w
         SDL_FRect-h
         set-SDL_FRect-x!
         set-SDL_FRect-y!
         set-SDL_FRect-w!
         set-SDL_FRect-h!
         ;; Color struct
         _SDL_Color
         _SDL_Color-pointer
         make-SDL_Color
         SDL_Color-r
         SDL_Color-g
         SDL_Color-b
         SDL_Color-a
         ;; Float color struct (for geometry rendering)
         _SDL_FColor
         _SDL_FColor-pointer
         make-SDL_FColor
         SDL_FColor-r
         SDL_FColor-g
         SDL_FColor-b
         SDL_FColor-a
         ;; Vertex struct (for geometry rendering)
         _SDL_Vertex
         _SDL_Vertex-pointer
         make-SDL_Vertex
         SDL_Vertex-position
         SDL_Vertex-color
         SDL_Vertex-tex_coord
         ;; Event structs
         _SDL_CommonEvent
         _SDL_CommonEvent-pointer
         SDL_CommonEvent-type
         SDL_CommonEvent-reserved
         SDL_CommonEvent-timestamp
         _SDL_KeyboardEvent
         _SDL_KeyboardEvent-pointer
         SDL_KeyboardEvent-type
         SDL_KeyboardEvent-windowID
         SDL_KeyboardEvent-which
         SDL_KeyboardEvent-scancode
         SDL_KeyboardEvent-key
         SDL_KeyboardEvent-mod
         SDL_KeyboardEvent-raw
         SDL_KeyboardEvent-down
         SDL_KeyboardEvent-repeat
         _SDL_MouseMotionEvent
         _SDL_MouseMotionEvent-pointer
         SDL_MouseMotionEvent-type
         SDL_MouseMotionEvent-windowID
         SDL_MouseMotionEvent-which
         SDL_MouseMotionEvent-state
         SDL_MouseMotionEvent-x
         SDL_MouseMotionEvent-y
         SDL_MouseMotionEvent-xrel
         SDL_MouseMotionEvent-yrel
         _SDL_MouseButtonEvent
         _SDL_MouseButtonEvent-pointer
         SDL_MouseButtonEvent-type
         SDL_MouseButtonEvent-windowID
         SDL_MouseButtonEvent-which
         SDL_MouseButtonEvent-button
         SDL_MouseButtonEvent-down
         SDL_MouseButtonEvent-clicks
         SDL_MouseButtonEvent-x
         SDL_MouseButtonEvent-y
         _SDL_TextInputEvent
         _SDL_TextInputEvent-pointer
         SDL_TextInputEvent-type
         SDL_TextInputEvent-windowID
         SDL_TextInputEvent-text
         _SDL_MouseWheelEvent
         _SDL_MouseWheelEvent-pointer
         SDL_MouseWheelEvent-type
         SDL_MouseWheelEvent-windowID
         SDL_MouseWheelEvent-which
         SDL_MouseWheelEvent-x
         SDL_MouseWheelEvent-y
         SDL_MouseWheelEvent-direction
         SDL_MouseWheelEvent-mouse_x
         SDL_MouseWheelEvent-mouse_y
         _SDL_DropEvent
         _SDL_DropEvent-pointer
         SDL_DropEvent-type
         SDL_DropEvent-windowID
         SDL_DropEvent-x
         SDL_DropEvent-y
         SDL_DropEvent-source
         SDL_DropEvent-data
         _SDL_ClipboardEvent
         _SDL_ClipboardEvent-pointer
         SDL_ClipboardEvent-type
         SDL_ClipboardEvent-owner
         SDL_ClipboardEvent-num_mime_types
         SDL_ClipboardEvent-mime_types
         _SDL_AudioDeviceEvent
         _SDL_AudioDeviceEvent-pointer
         SDL_AudioDeviceEvent-type
         SDL_AudioDeviceEvent-which
         SDL_AudioDeviceEvent-recording
         _SDL_CameraDeviceEvent
         _SDL_CameraDeviceEvent-pointer
         SDL_CameraDeviceEvent-type
         SDL_CameraDeviceEvent-which
         ;; Event union helpers
         sdl-event-type
         event->keyboard
         event->mouse-motion
         event->mouse-button
         event->text-input
         event->mouse-wheel
         event->drop
         event->clipboard
         event->audio-device
         event->camera-device
         ;; Keycode type
         _SDL_Keycode
         ;; Modifier key type
         _SDL_Keymod
         ;; Scancode type
         _SDL_Scancode
         ;; Blend mode type
         _SDL_BlendMode
         ;; Flip mode type
         _SDL_FlipMode
         ;; Texture access type
         _SDL_TextureAccess
         ;; Scale mode type
         _SDL_ScaleMode
         ;; Pixel format type
         _SDL_PixelFormat
         ;; Colorspace type
         _SDL_Colorspace
         ;; Tray entry flags type
         _SDL_TrayEntryFlags
         ;; System cursor type
         _SDL_SystemCursor
         ;; Audio types
         _SDL_AudioDeviceID
         ;; Input device IDs
         _SDL_KeyboardID
         _SDL_MouseID
         _SDL_AudioFormat
         _SDL_AudioSpec
         _SDL_AudioSpec-pointer
         _SDL_AudioSpec-pointer/null
         make-SDL_AudioSpec
         SDL_AudioSpec-format
         SDL_AudioSpec-channels
         SDL_AudioSpec-freq
         set-SDL_AudioSpec-format!
         set-SDL_AudioSpec-channels!
         set-SDL_AudioSpec-freq!
         _SDL_AudioStream-pointer
         _SDL_AudioStream-pointer/null
         _SDL_AudioStreamCallback
         ;; Timer types
         _SDL_TimerID
         _SDL_TimerCallback
         _SDL_NSTimerCallback
         ;; Window ID type
         _SDL_WindowID
         ;; Display ID type
         _SDL_DisplayID
         ;; Camera types
         _SDL_CameraID
         _SDL_CameraPosition
         _SDL_CameraSpec
         _SDL_CameraSpec-pointer
         _SDL_CameraSpec-pointer/null
         make-SDL_CameraSpec
         SDL_CameraSpec-format
         SDL_CameraSpec-colorspace
         SDL_CameraSpec-width
         SDL_CameraSpec-height
         SDL_CameraSpec-framerate_numerator
         SDL_CameraSpec-framerate_denominator
         ;; Display mode struct
         _SDL_DisplayMode
         _SDL_DisplayMode-pointer
         _SDL_DisplayMode-pointer/null
         make-SDL_DisplayMode
         SDL_DisplayMode-displayID
         SDL_DisplayMode-format
         SDL_DisplayMode-w
         SDL_DisplayMode-h
         SDL_DisplayMode-pixel_density
         SDL_DisplayMode-refresh_rate
         SDL_DisplayMode-refresh_rate_numerator
         SDL_DisplayMode-refresh_rate_denominator
         ;; Flash operation type
         _SDL_FlashOperation
         ;; Message box types
         _SDL_MessageBoxFlags
         _SDL_MessageBoxButtonFlags
         _SDL_MessageBoxButtonData
         _SDL_MessageBoxButtonData-pointer
         make-SDL_MessageBoxButtonData
         SDL_MessageBoxButtonData-flags
         SDL_MessageBoxButtonData-buttonID
         SDL_MessageBoxButtonData-text
         _SDL_MessageBoxColor
         make-SDL_MessageBoxColor
         SDL_MessageBoxColor-r
         SDL_MessageBoxColor-g
         SDL_MessageBoxColor-b
         _SDL_MessageBoxColorScheme
         _SDL_MessageBoxColorScheme-pointer
         _SDL_MessageBoxColorScheme-pointer/null
         make-SDL_MessageBoxColorScheme
         SDL_MessageBoxColorScheme-colors
         _SDL_MessageBoxData
         _SDL_MessageBoxData-pointer
         make-SDL_MessageBoxData
         SDL_MessageBoxData-flags
         SDL_MessageBoxData-window
         SDL_MessageBoxData-title
         SDL_MessageBoxData-message
         SDL_MessageBoxData-numbuttons
         SDL_MessageBoxData-buttons
         SDL_MessageBoxData-colorScheme
         ;; File dialog types
         _SDL_DialogFileFilter
         _SDL_DialogFileFilter-pointer
         _SDL_DialogFileFilter-pointer/null
         make-SDL_DialogFileFilter
         SDL_DialogFileFilter-name
         SDL_DialogFileFilter-pattern
         _SDL_DialogFileCallback
         _SDL_TrayCallback
         ;; Joystick types
         _SDL_Joystick-pointer
         _SDL_Joystick-pointer/null
         _SDL_JoystickID
         _SDL_JoystickType
         _SDL_JoystickConnectionState
         _SDL_PowerState
         ;; Gamepad types
         _SDL_Gamepad-pointer
         _SDL_Gamepad-pointer/null
         _SDL_GamepadType
         _SDL_GamepadButton
         _SDL_GamepadAxis
         _SDL_GamepadButtonLabel
         ;; Joystick event structs
         _SDL_JoyAxisEvent
         _SDL_JoyAxisEvent-pointer
         SDL_JoyAxisEvent-type
         SDL_JoyAxisEvent-timestamp
         SDL_JoyAxisEvent-which
         SDL_JoyAxisEvent-axis
         SDL_JoyAxisEvent-value
         _SDL_JoyButtonEvent
         _SDL_JoyButtonEvent-pointer
         SDL_JoyButtonEvent-type
         SDL_JoyButtonEvent-timestamp
         SDL_JoyButtonEvent-which
         SDL_JoyButtonEvent-button
         SDL_JoyButtonEvent-down
         _SDL_JoyHatEvent
         _SDL_JoyHatEvent-pointer
         SDL_JoyHatEvent-type
         SDL_JoyHatEvent-timestamp
         SDL_JoyHatEvent-which
         SDL_JoyHatEvent-hat
         SDL_JoyHatEvent-value
         _SDL_JoyDeviceEvent
         _SDL_JoyDeviceEvent-pointer
         SDL_JoyDeviceEvent-type
         SDL_JoyDeviceEvent-timestamp
         SDL_JoyDeviceEvent-which
         ;; Gamepad event structs
         _SDL_GamepadAxisEvent
         _SDL_GamepadAxisEvent-pointer
         SDL_GamepadAxisEvent-type
         SDL_GamepadAxisEvent-timestamp
         SDL_GamepadAxisEvent-which
         SDL_GamepadAxisEvent-axis
         SDL_GamepadAxisEvent-value
         _SDL_GamepadButtonEvent
         _SDL_GamepadButtonEvent-pointer
         SDL_GamepadButtonEvent-type
         SDL_GamepadButtonEvent-timestamp
         SDL_GamepadButtonEvent-which
         SDL_GamepadButtonEvent-button
         SDL_GamepadButtonEvent-down
         _SDL_GamepadDeviceEvent
         _SDL_GamepadDeviceEvent-pointer
         SDL_GamepadDeviceEvent-type
         SDL_GamepadDeviceEvent-timestamp
         SDL_GamepadDeviceEvent-which
         ;; Touch event structs
         _SDL_TouchFingerEvent
         _SDL_TouchFingerEvent-pointer
         SDL_TouchFingerEvent-type
         SDL_TouchFingerEvent-timestamp
         SDL_TouchFingerEvent-touchID
         SDL_TouchFingerEvent-fingerID
         SDL_TouchFingerEvent-x
         SDL_TouchFingerEvent-y
         SDL_TouchFingerEvent-dx
         SDL_TouchFingerEvent-dy
         SDL_TouchFingerEvent-pressure
         SDL_TouchFingerEvent-windowID
         ;; Pen event structs
         _SDL_PenProximityEvent
         _SDL_PenProximityEvent-pointer
         SDL_PenProximityEvent-type
         SDL_PenProximityEvent-timestamp
         SDL_PenProximityEvent-windowID
         SDL_PenProximityEvent-which
         _SDL_PenMotionEvent
         _SDL_PenMotionEvent-pointer
         SDL_PenMotionEvent-type
         SDL_PenMotionEvent-timestamp
         SDL_PenMotionEvent-windowID
         SDL_PenMotionEvent-which
         SDL_PenMotionEvent-pen_state
         SDL_PenMotionEvent-x
         SDL_PenMotionEvent-y
         _SDL_PenTouchEvent
         _SDL_PenTouchEvent-pointer
         SDL_PenTouchEvent-type
         SDL_PenTouchEvent-timestamp
         SDL_PenTouchEvent-windowID
         SDL_PenTouchEvent-which
         SDL_PenTouchEvent-pen_state
         SDL_PenTouchEvent-x
         SDL_PenTouchEvent-y
         SDL_PenTouchEvent-eraser
         SDL_PenTouchEvent-down
         _SDL_PenButtonEvent
         _SDL_PenButtonEvent-pointer
         SDL_PenButtonEvent-type
         SDL_PenButtonEvent-timestamp
         SDL_PenButtonEvent-windowID
         SDL_PenButtonEvent-which
         SDL_PenButtonEvent-pen_state
         SDL_PenButtonEvent-x
         SDL_PenButtonEvent-y
         SDL_PenButtonEvent-button
         SDL_PenButtonEvent-down
         _SDL_PenAxisEvent
         _SDL_PenAxisEvent-pointer
         SDL_PenAxisEvent-type
         SDL_PenAxisEvent-timestamp
         SDL_PenAxisEvent-windowID
         SDL_PenAxisEvent-which
         SDL_PenAxisEvent-pen_state
         SDL_PenAxisEvent-x
         SDL_PenAxisEvent-y
         SDL_PenAxisEvent-axis
         SDL_PenAxisEvent-value
         ;; Touch/Pen type aliases
         _SDL_TouchID
         _SDL_FingerID
         _SDL_PenID
         _SDL_PenInputFlags
         _SDL_PenAxis
         _SDL_TouchDeviceType
         ;; Event conversion helpers
         event->joy-axis
         event->joy-button
         event->joy-hat
         event->joy-device
         event->gamepad-axis
         event->gamepad-button
         event->gamepad-device
         event->touch-finger
         event->pen-proximity
         event->pen-motion
         event->pen-touch
         event->pen-button
         event->pen-axis
         ;; Error handling forward reference
         sdl-get-error-proc)

;; ============================================================================
;; SDL3 Boolean Type
;; ============================================================================

;; SDL3 boolean type - SDL3 uses C99 bool (1 byte, not int like SDL2)
;; Racket's _bool is 4 bytes, but _stdbool is 1 byte like C99 bool
(define _sdl-bool _stdbool)

;; ============================================================================
;; FFI Type Aliases
;; ============================================================================

;; SDL_InitFlags is a 32-bit unsigned integer (flags can be combined with bitwise-ior)
(define _SDL_InitFlags _uint32)

;; SDL_WindowFlags is a 64-bit unsigned integer in SDL3 (flags can be combined with bitwise-ior)
(define _SDL_WindowFlags _uint64)

;; SDL_PropertiesID is a 32-bit unsigned integer
(define _SDL_PropertiesID _uint32)

;; SDL_AudioDeviceID - audio device instance ID (uint32)
;; Zero signifies an invalid/null device
(define _SDL_AudioDeviceID _uint32)

;; SDL_KeyboardID - keyboard instance ID (uint32)
(define _SDL_KeyboardID _uint32)

;; SDL_MouseID - mouse instance ID (uint32)
(define _SDL_MouseID _uint32)

;; SDL_CameraID - camera instance ID (uint32)
(define _SDL_CameraID _uint32)

;; SDL_TimerID - timer handle (Uint32)
(define _SDL_TimerID _uint32)

;; SDL_TimerCallback - millisecond timer callback
(define _SDL_TimerCallback
  (_fun #:async-apply (lambda (thunk) (thunk))
        _pointer
        _SDL_TimerID
        _uint32
        -> _uint32))

;; SDL_NSTimerCallback - nanosecond timer callback
(define _SDL_NSTimerCallback
  (_fun #:async-apply (lambda (thunk) (thunk))
        _pointer
        _SDL_TimerID
        _uint64
        -> _uint64))

;; ============================================================================
;; Pointer Types
;; ============================================================================
(define-cpointer-type _SDL_Window-pointer)
(define-cpointer-type _SDL_Renderer-pointer)
(define-cpointer-type _SDL_Texture-pointer)
(define-cpointer-type _SDL_IOStream-pointer)
(define-cpointer-type _SDL_Cursor-pointer)
(define-cpointer-type _SDL_Tray-pointer)
(define-cpointer-type _SDL_TrayMenu-pointer)
(define-cpointer-type _SDL_TrayEntry-pointer)
(define-cpointer-type _SDL_Camera-pointer)
(define-cpointer-type _SDL_GPUDevice-pointer)
(define-cpointer-type _SDL_GPUTexture-pointer)
(define-cpointer-type _SDL_GPUBuffer-pointer)
(define-cpointer-type _SDL_GPUTransferBuffer-pointer)
(define-cpointer-type _SDL_GPUSampler-pointer)
(define-cpointer-type _SDL_GPUShader-pointer)
(define-cpointer-type _SDL_GPUComputePipeline-pointer)
(define-cpointer-type _SDL_GPUGraphicsPipeline-pointer)
(define-cpointer-type _SDL_GPUCommandBuffer-pointer)
(define-cpointer-type _SDL_GPURenderPass-pointer)
(define-cpointer-type _SDL_GPUComputePass-pointer)
(define-cpointer-type _SDL_GPUCopyPass-pointer)
(define-cpointer-type _SDL_GPUFence-pointer)

;; ============================================================================
;; Surface Struct
;; ============================================================================

;; SDL_Surface - image data in CPU memory
;; We define the publicly accessible fields from the SDL3 header
(define-cstruct _SDL_Surface
  ([flags _uint32]        ; SDL_SurfaceFlags
   [format _uint32]       ; SDL_PixelFormat
   [w _int]               ; width
   [h _int]               ; height
   [pitch _int]           ; bytes per row
   [pixels _pointer]      ; pointer to pixel data (void*)
   [refcount _int]))

;; ============================================================================
;; Point and Rectangle Structs
;; ============================================================================

;; SDL_Point - integer 2D point
(define-cstruct _SDL_Point
  ([x _int]
   [y _int]))

;; SDL_FPoint - floating point 2D point
(define-cstruct _SDL_FPoint
  ([x _float]
   [y _float]))

;; SDL_Rect - integer rectangle (for pixel-perfect positioning)
(define-cstruct _SDL_Rect
  ([x _int]
   [y _int]
   [w _int]
   [h _int]))

;; SDL_FRect - floating point rectangle (preferred in SDL3 for rendering)
(define-cstruct _SDL_FRect
  ([x _float]
   [y _float]
   [w _float]
   [h _float]))

;; ============================================================================
;; Color Structs
;; ============================================================================

;; SDL_Color - RGBA color (r, g, b, a each 0-255)
(define-cstruct _SDL_Color
  ([r _uint8]
   [g _uint8]
   [b _uint8]
   [a _uint8]))

;; SDL_FColor - floating point RGBA color (for HDR and geometry rendering)
(define-cstruct _SDL_FColor
  ([r _float]
   [g _float]
   [b _float]
   [a _float]))

;; SDL_Vertex - vertex for geometry rendering
;; Contains position, color (as float), and texture coordinates
(define-cstruct _SDL_Vertex
  ([position _SDL_FPoint]
   [color _SDL_FColor]
   [tex_coord _SDL_FPoint]))

;; ============================================================================
;; Event Structs
;; ============================================================================

;; SDL_CommonEvent - header shared by all events
(define-cstruct _SDL_CommonEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]))

;; SDL_KeyboardEvent - keyboard key press/release
(define-cstruct _SDL_KeyboardEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _uint32]
   [which _uint32]       ; SDL_KeyboardID - keyboard instance id
   [scancode _uint32]    ; SDL_Scancode - physical key code
   [key _uint32]         ; SDL_Keycode - virtual key code
   [mod _uint16]         ; SDL_Keymod - current key modifiers
   [raw _uint16]         ; platform dependent scancode
   [down _bool]          ; true if key is pressed
   [repeat _bool]))

;; SDL_MouseMotionEvent - mouse movement
(define-cstruct _SDL_MouseMotionEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _uint32]
   [which _uint32]
   [state _uint32]
   [x _float]
   [y _float]
   [xrel _float]
   [yrel _float]))

;; SDL_MouseButtonEvent - mouse button press/release
(define-cstruct _SDL_MouseButtonEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _uint32]
   [which _uint32]
   [button _uint8]
   [down _uint8]
   [clicks _uint8]
   [padding _uint8]
   [x _float]
   [y _float]))

;; SDL_TextInputEvent - text input with actual characters (handles shift/caps automatically)
(define-cstruct _SDL_TextInputEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _uint32]
   [text _pointer]))  ; const char* - UTF-8 encoded text

;; SDL_MouseWheelEvent - mouse wheel/scroll
(define-cstruct _SDL_MouseWheelEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _uint32]
   [which _uint32]      ; mouse instance id
   [x _float]           ; horizontal scroll amount
   [y _float]           ; vertical scroll amount
   [direction _sint32]  ; SDL_MouseWheelDirection
   [mouse_x _float]     ; mouse x position
   [mouse_y _float]))   ; mouse y position

;; SDL_DropEvent - drag-and-drop event
(define-cstruct _SDL_DropEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _uint32]
   [x _float]
   [y _float]
   [source _pointer]   ; const char*
   [data _pointer]))   ; const char*

;; SDL_ClipboardEvent - clipboard update event
(define-cstruct _SDL_ClipboardEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [owner _stdbool]
   [padding1 _uint8]
   [padding2 _uint8]
   [padding3 _uint8]
   [num_mime_types _sint32]
   [mime_types _pointer])) ; const char**

;; SDL_AudioDeviceEvent - audio device add/remove/format change
(define-cstruct _SDL_AudioDeviceEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_AudioDeviceID]
   [recording _stdbool]
   [padding1 _uint8]
   [padding2 _uint8]
   [padding3 _uint8]))

;; SDL_CameraDeviceEvent - camera device add/remove/approval
(define-cstruct _SDL_CameraDeviceEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_CameraID]))

;; Helper to get event type from any event pointer
(define (sdl-event-type event-ptr)
  (ptr-ref event-ptr _uint32))

;; Helper to cast event pointer to specific struct types
(define (event->keyboard event-ptr)
  (cast event-ptr _pointer _SDL_KeyboardEvent-pointer))

(define (event->mouse-motion event-ptr)
  (cast event-ptr _pointer _SDL_MouseMotionEvent-pointer))

(define (event->mouse-button event-ptr)
  (cast event-ptr _pointer _SDL_MouseButtonEvent-pointer))

(define (event->text-input event-ptr)
  (cast event-ptr _pointer _SDL_TextInputEvent-pointer))

(define (event->mouse-wheel event-ptr)
  (cast event-ptr _pointer _SDL_MouseWheelEvent-pointer))

(define (event->drop event-ptr)
  (cast event-ptr _pointer _SDL_DropEvent-pointer))

(define (event->clipboard event-ptr)
  (cast event-ptr _pointer _SDL_ClipboardEvent-pointer))

(define (event->audio-device event-ptr)
  (cast event-ptr _pointer _SDL_AudioDeviceEvent-pointer))

(define (event->camera-device event-ptr)
  (cast event-ptr _pointer _SDL_CameraDeviceEvent-pointer))

;; ============================================================================
;; FFI Type Aliases for Enums
;; ============================================================================

;; SDL_Keycode type (32-bit)
(define _SDL_Keycode _uint32)

;; SDL_Keymod type (16-bit)
(define _SDL_Keymod _uint16)

;; SDL_Scancode type
(define _SDL_Scancode _int)

;; SDL_BlendMode type (32-bit unsigned)
(define _SDL_BlendMode _uint32)

;; SDL_FlipMode - for texture rendering with flipping
(define _SDL_FlipMode _int)

;; SDL_TextureAccess - how the texture data will be accessed
(define _SDL_TextureAccess _int)

;; SDL_ScaleMode - how texture scaling is performed
(define _SDL_ScaleMode _int)

;; SDL_PixelFormat - pixel format values
(define _SDL_PixelFormat _uint32)

;; SDL_Colorspace - colorspace values
(define _SDL_Colorspace _uint32)

;; SDL_TrayEntryFlags - tray entry flag bitfield
(define _SDL_TrayEntryFlags _uint32)

;; SDL_SystemCursor - predefined system cursor types
(define _SDL_SystemCursor _int)

;; ============================================================================
;; Audio Types
;; ============================================================================

;; SDL_AudioFormat - audio format specifier (uint16 enum)
(define _SDL_AudioFormat _uint16)

;; SDL_AudioSpec - audio format specification struct
;; Note: explicit padding added for C struct alignment (uint16 followed by int)
(define-cstruct _SDL_AudioSpec
  ([format _SDL_AudioFormat]  ; Audio data format
   [_pad _uint16]             ; Padding for alignment
   [channels _int]            ; Number of channels: 1 mono, 2 stereo, etc
   [freq _int]))              ; Sample rate: sample frames per second

;; SDL_AudioStream opaque pointer type
(define-cpointer-type _SDL_AudioStream-pointer)

;; SDL_AudioStreamCallback - called when audio stream needs data
(define _SDL_AudioStreamCallback
  (_fun #:async-apply (lambda (thunk) (thunk))
        _pointer
        _SDL_AudioStream-pointer
        _int
        _int
        -> _void))

;; ============================================================================
;; Window ID
;; ============================================================================

;; SDL_WindowID - unique identifier for a window (uint32)
(define _SDL_WindowID _uint32)

;; ============================================================================
;; Display Types
;; ============================================================================

;; SDL_DisplayID - unique identifier for a display (uint32)
(define _SDL_DisplayID _uint32)

;; SDL_DisplayMode - describes a display mode
;; Note: The 'internal' pointer field is private/opaque, included for ABI compatibility
(define-cstruct _SDL_DisplayMode
  ([displayID _SDL_DisplayID]              ; the display this mode is associated with
   [format _SDL_PixelFormat]               ; pixel format
   [w _int]                                ; width
   [h _int]                                ; height
   [pixel_density _float]                  ; scale converting size to pixels
   [refresh_rate _float]                   ; refresh rate (or 0.0 for unspecified)
   [refresh_rate_numerator _int]           ; precise refresh rate numerator
   [refresh_rate_denominator _int]         ; precise refresh rate denominator
   [internal _pointer]))                   ; private data (opaque)

;; ============================================================================
;; Camera Types
;; ============================================================================

;; SDL_CameraPosition enum
(define _SDL_CameraPosition _int)

;; SDL_CameraSpec - camera output format specification
(define-cstruct _SDL_CameraSpec
  ([format _SDL_PixelFormat]
   [colorspace _SDL_Colorspace]
   [width _int]
   [height _int]
   [framerate_numerator _int]
   [framerate_denominator _int]))

;; ============================================================================
;; Flash Operation
;; ============================================================================

;; SDL_FlashOperation - window flash behavior
(define _SDL_FlashOperation _int)

;; ============================================================================
;; Message Box Types
;; ============================================================================

;; SDL_MessageBoxFlags type
(define _SDL_MessageBoxFlags _uint32)

;; SDL_MessageBoxButtonFlags type
(define _SDL_MessageBoxButtonFlags _uint32)

;; SDL_MessageBoxButtonData - individual button data
(define-cstruct _SDL_MessageBoxButtonData
  ([flags _SDL_MessageBoxButtonFlags]
   [buttonID _int]
   [text _string/utf-8]))

;; SDL_MessageBoxColor - RGB value for message box colors
(define-cstruct _SDL_MessageBoxColor
  ([r _uint8]
   [g _uint8]
   [b _uint8]))

;; SDL_MessageBoxColorScheme - set of colors for message box dialogs
;; Contains 5 colors: background, text, button border, button background, button selected
(define-cstruct _SDL_MessageBoxColorScheme
  ([colors (_array _SDL_MessageBoxColor 5)]))

;; SDL_MessageBoxData - full message box structure
(define-cstruct _SDL_MessageBoxData
  ([flags _SDL_MessageBoxFlags]
   [window _SDL_Window-pointer/null]
   [title _string/utf-8]
   [message _string/utf-8]
   [numbuttons _int]
   [buttons _SDL_MessageBoxButtonData-pointer]
   [colorScheme _SDL_MessageBoxColorScheme-pointer/null]))

;; ============================================================================
;; File Dialog Types
;; ============================================================================

;; SDL_DialogFileFilter - filter for file dialogs
(define-cstruct _SDL_DialogFileFilter
  ([name _string/utf-8]      ; user-readable label (e.g., "Image files")
   [pattern _string/utf-8])) ; semicolon-separated extensions (e.g., "png;jpg;gif")

;; SDL_DialogFileCallback - callback invoked when dialog completes
;; (userdata filelist filter) -> void
;; filelist is NULL on error, pointer to NULL if canceled, otherwise null-terminated array
;; filter is the index of selected filter, or -1 if none
(define _SDL_DialogFileCallback
  (_fun #:async-apply (lambda (thunk) (thunk))
        _pointer           ; userdata
        _pointer           ; const char * const * filelist
        _int               ; filter index
        -> _void))

;; SDL_TrayCallback - callback invoked when tray entry is selected
;; (userdata entry) -> void
(define _SDL_TrayCallback
  (_fun #:async-apply (lambda (thunk) (thunk))
        _pointer           ; userdata
        _SDL_TrayEntry-pointer
        -> _void))

;; ============================================================================
;; Joystick Types
;; ============================================================================

;; Joystick opaque pointer
(define-cpointer-type _SDL_Joystick-pointer)

;; Joystick instance ID (Uint32)
(define _SDL_JoystickID _uint32)

;; SDL_JoystickType enum
(define _SDL_JoystickType _int)

;; SDL_JoystickConnectionState enum
(define _SDL_JoystickConnectionState _int)

;; SDL_PowerState enum (shared with gamepad)
(define _SDL_PowerState _int)

;; ============================================================================
;; Gamepad Types
;; ============================================================================

;; Gamepad opaque pointer
(define-cpointer-type _SDL_Gamepad-pointer)

;; SDL_GamepadType enum
(define _SDL_GamepadType _int)

;; SDL_GamepadButton enum
(define _SDL_GamepadButton _int)

;; SDL_GamepadAxis enum
(define _SDL_GamepadAxis _int)

;; SDL_GamepadButtonLabel enum
(define _SDL_GamepadButtonLabel _int)

;; ============================================================================
;; Joystick Event Structs
;; ============================================================================

;; SDL_JoyAxisEvent - joystick axis motion event
(define-cstruct _SDL_JoyAxisEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_JoystickID]
   [axis _uint8]
   [padding1 _uint8]
   [padding2 _uint8]
   [padding3 _uint8]
   [value _sint16]
   [padding4 _uint16]))

;; SDL_JoyButtonEvent - joystick button press/release event
(define-cstruct _SDL_JoyButtonEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_JoystickID]
   [button _uint8]
   [down _stdbool]
   [padding1 _uint8]
   [padding2 _uint8]))

;; SDL_JoyHatEvent - joystick hat position change event
(define-cstruct _SDL_JoyHatEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_JoystickID]
   [hat _uint8]
   [value _uint8]
   [padding1 _uint8]
   [padding2 _uint8]))

;; SDL_JoyDeviceEvent - joystick connected/disconnected event
(define-cstruct _SDL_JoyDeviceEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_JoystickID]))

;; ============================================================================
;; Gamepad Event Structs
;; ============================================================================

;; SDL_GamepadAxisEvent - gamepad axis motion event
(define-cstruct _SDL_GamepadAxisEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_JoystickID]
   [axis _uint8]
   [padding1 _uint8]
   [padding2 _uint8]
   [padding3 _uint8]
   [value _sint16]
   [padding4 _uint16]))

;; SDL_GamepadButtonEvent - gamepad button press/release event
(define-cstruct _SDL_GamepadButtonEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_JoystickID]
   [button _uint8]
   [down _stdbool]
   [padding1 _uint8]
   [padding2 _uint8]))

;; SDL_GamepadDeviceEvent - gamepad connected/disconnected event
(define-cstruct _SDL_GamepadDeviceEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [which _SDL_JoystickID]))

;; ============================================================================
;; Joystick/Gamepad Event Conversion Helpers
;; ============================================================================

(define (event->joy-axis event-ptr)
  (cast event-ptr _pointer _SDL_JoyAxisEvent-pointer))

(define (event->joy-button event-ptr)
  (cast event-ptr _pointer _SDL_JoyButtonEvent-pointer))

(define (event->joy-hat event-ptr)
  (cast event-ptr _pointer _SDL_JoyHatEvent-pointer))

(define (event->joy-device event-ptr)
  (cast event-ptr _pointer _SDL_JoyDeviceEvent-pointer))

(define (event->gamepad-axis event-ptr)
  (cast event-ptr _pointer _SDL_GamepadAxisEvent-pointer))

(define (event->gamepad-button event-ptr)
  (cast event-ptr _pointer _SDL_GamepadButtonEvent-pointer))

(define (event->gamepad-device event-ptr)
  (cast event-ptr _pointer _SDL_GamepadDeviceEvent-pointer))

;; ============================================================================
;; Touch/Pen Type Aliases
;; ============================================================================

;; SDL_TouchID - touch device identifier (Uint64)
(define _SDL_TouchID _uint64)

;; SDL_FingerID - finger identifier within a touch device (Uint64)
(define _SDL_FingerID _uint64)

;; SDL_PenID - pen instance identifier (Uint32)
(define _SDL_PenID _uint32)

;; SDL_PenInputFlags - pen input state flags (Uint32)
(define _SDL_PenInputFlags _uint32)

;; SDL_PenAxis - pen axis type enum
(define _SDL_PenAxis _int)

;; SDL_TouchDeviceType - type of touch device
(define _SDL_TouchDeviceType _int)

;; ============================================================================
;; Touch Event Structs
;; ============================================================================

;; SDL_TouchFingerEvent - touch finger event (down, up, motion, canceled)
(define-cstruct _SDL_TouchFingerEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [touchID _SDL_TouchID]
   [fingerID _SDL_FingerID]
   [x _float]           ; normalized 0...1
   [y _float]           ; normalized 0...1
   [dx _float]          ; normalized -1...1
   [dy _float]          ; normalized -1...1
   [pressure _float]    ; normalized 0...1
   [windowID _SDL_WindowID]))

;; ============================================================================
;; Pen Event Structs
;; ============================================================================

;; SDL_PenProximityEvent - pen enters/leaves proximity
(define-cstruct _SDL_PenProximityEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _SDL_WindowID]
   [which _SDL_PenID]))

;; SDL_PenMotionEvent - pen motion
(define-cstruct _SDL_PenMotionEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _SDL_WindowID]
   [which _SDL_PenID]
   [pen_state _SDL_PenInputFlags]
   [x _float]
   [y _float]))

;; SDL_PenTouchEvent - pen touches/lifts from surface
(define-cstruct _SDL_PenTouchEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _SDL_WindowID]
   [which _SDL_PenID]
   [pen_state _SDL_PenInputFlags]
   [x _float]
   [y _float]
   [eraser _stdbool]
   [down _stdbool]))

;; SDL_PenButtonEvent - pen button pressed/released
(define-cstruct _SDL_PenButtonEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _SDL_WindowID]
   [which _SDL_PenID]
   [pen_state _SDL_PenInputFlags]
   [x _float]
   [y _float]
   [button _uint8]
   [down _stdbool]))

;; SDL_PenAxisEvent - pen axis value changed
(define-cstruct _SDL_PenAxisEvent
  ([type _uint32]
   [reserved _uint32]
   [timestamp _uint64]
   [windowID _SDL_WindowID]
   [which _SDL_PenID]
   [pen_state _SDL_PenInputFlags]
   [x _float]
   [y _float]
   [axis _SDL_PenAxis]
   [value _float]))

;; ============================================================================
;; Touch/Pen Event Conversion Helpers
;; ============================================================================

(define (event->touch-finger event-ptr)
  (cast event-ptr _pointer _SDL_TouchFingerEvent-pointer))

(define (event->pen-proximity event-ptr)
  (cast event-ptr _pointer _SDL_PenProximityEvent-pointer))

(define (event->pen-motion event-ptr)
  (cast event-ptr _pointer _SDL_PenMotionEvent-pointer))

(define (event->pen-touch event-ptr)
  (cast event-ptr _pointer _SDL_PenTouchEvent-pointer))

(define (event->pen-button event-ptr)
  (cast event-ptr _pointer _SDL_PenButtonEvent-pointer))

(define (event->pen-axis event-ptr)
  (cast event-ptr _pointer _SDL_PenAxisEvent-pointer))

;; ============================================================================
;; Error Handling
;; ============================================================================

;; Placeholder for SDL_GetError - will be replaced with actual FFI binding
;; This is defined here to avoid circular dependencies
(define sdl-get-error-proc (make-parameter #f))

;; Check an SDL3 boolean result and raise an error if false
;; SDL3 functions return true on success, false on failure
(define (check-sdl-bool who result)
  (unless result
    (define get-error (sdl-get-error-proc))
    (define msg (if get-error
                    (get-error)
                    "SDL error (SDL_GetError not yet available)"))
    (error who "SDL error: ~a" msg))
  #t)

;; ============================================================================
;; GPU Enums
;; ============================================================================

;; SDL_GPUPrimitiveType - primitive topology for graphics pipeline
(define _SDL_GPUPrimitiveType _int)

;; SDL_GPULoadOp - texture load operation at beginning of render pass
(define _SDL_GPULoadOp _int)

;; SDL_GPUStoreOp - texture store operation at end of render pass
(define _SDL_GPUStoreOp _int)

;; SDL_GPUIndexElementSize - size of index buffer elements
(define _SDL_GPUIndexElementSize _int)

;; SDL_GPUTextureFormat - pixel format of a texture
(define _SDL_GPUTextureFormat _int)

;; SDL_GPUTextureUsageFlags - how texture will be used
(define _SDL_GPUTextureUsageFlags _uint32)

;; SDL_GPUTextureType - type of texture (2D, 3D, cube, etc.)
(define _SDL_GPUTextureType _int)

;; SDL_GPUSampleCount - multisampling level
(define _SDL_GPUSampleCount _int)

;; SDL_GPUBufferUsageFlags - how buffer will be used
(define _SDL_GPUBufferUsageFlags _uint32)

;; SDL_GPUTransferBufferUsage - upload or download
(define _SDL_GPUTransferBufferUsage _int)

;; SDL_GPUShaderStage - vertex or fragment
(define _SDL_GPUShaderStage _int)

;; SDL_GPUShaderFormat - shader bytecode format
(define _SDL_GPUShaderFormat _uint32)

;; SDL_GPUVertexElementFormat - vertex attribute format
(define _SDL_GPUVertexElementFormat _int)

;; SDL_GPUVertexInputRate - per-vertex or per-instance
(define _SDL_GPUVertexInputRate _int)

;; SDL_GPUFillMode - fill or line
(define _SDL_GPUFillMode _int)

;; SDL_GPUCullMode - cull front, back, or none
(define _SDL_GPUCullMode _int)

;; SDL_GPUFrontFace - winding order
(define _SDL_GPUFrontFace _int)

;; SDL_GPUCompareOp - depth/stencil comparison
(define _SDL_GPUCompareOp _int)

;; SDL_GPUStencilOp - stencil operation
(define _SDL_GPUStencilOp _int)

;; SDL_GPUBlendOp - blend operation
(define _SDL_GPUBlendOp _int)

;; SDL_GPUBlendFactor - blend factor
(define _SDL_GPUBlendFactor _int)

;; SDL_GPUColorComponentFlags - which color components to write
(define _SDL_GPUColorComponentFlags _uint8)

;; SDL_GPUFilter - texture filter mode
(define _SDL_GPUFilter _int)

;; SDL_GPUSamplerMipmapMode - mipmap filter mode
(define _SDL_GPUSamplerMipmapMode _int)

;; SDL_GPUSamplerAddressMode - texture addressing mode
(define _SDL_GPUSamplerAddressMode _int)

;; SDL_GPUPresentMode - presentation timing
(define _SDL_GPUPresentMode _int)

;; SDL_GPUSwapchainComposition - swapchain format/colorspace
(define _SDL_GPUSwapchainComposition _int)

;; ============================================================================
;; GPU Structs
;; ============================================================================

;; SDL_GPUViewport - viewport state
(define-cstruct _SDL_GPUViewport
  ([x _float]
   [y _float]
   [w _float]
   [h _float]
   [min_depth _float]
   [max_depth _float]))

;; SDL_GPUColorTargetInfo - color target for render pass
(define-cstruct _SDL_GPUColorTargetInfo
  ([texture _SDL_GPUTexture-pointer/null]
   [mip_level _uint32]
   [layer_or_depth_plane _uint32]
   [clear_color _SDL_FColor]
   [load_op _SDL_GPULoadOp]
   [store_op _SDL_GPUStoreOp]
   [resolve_texture _SDL_GPUTexture-pointer/null]
   [resolve_mip_level _uint32]
   [resolve_layer _uint32]
   [cycle _stdbool]
   [cycle_resolve_texture _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]))

;; SDL_GPUDepthStencilTargetInfo - depth/stencil target for render pass
(define-cstruct _SDL_GPUDepthStencilTargetInfo
  ([texture _SDL_GPUTexture-pointer/null]
   [clear_depth _float]
   [load_op _SDL_GPULoadOp]
   [store_op _SDL_GPUStoreOp]
   [stencil_load_op _SDL_GPULoadOp]
   [stencil_store_op _SDL_GPUStoreOp]
   [cycle _stdbool]
   [clear_stencil _uint8]
   [_padding1 _uint8]
   [_padding2 _uint8]))

;; SDL_GPUSamplerCreateInfo - sampler creation parameters
(define-cstruct _SDL_GPUSamplerCreateInfo
  ([min_filter _SDL_GPUFilter]
   [mag_filter _SDL_GPUFilter]
   [mipmap_mode _SDL_GPUSamplerMipmapMode]
   [address_mode_u _SDL_GPUSamplerAddressMode]
   [address_mode_v _SDL_GPUSamplerAddressMode]
   [address_mode_w _SDL_GPUSamplerAddressMode]
   [mip_lod_bias _float]
   [max_anisotropy _float]
   [compare_op _SDL_GPUCompareOp]
   [min_lod _float]
   [max_lod _float]
   [enable_anisotropy _stdbool]
   [enable_compare _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]
   [props _uint32]))

;; SDL_GPUVertexBufferDescription - vertex buffer layout
(define-cstruct _SDL_GPUVertexBufferDescription
  ([slot _uint32]
   [pitch _uint32]
   [input_rate _SDL_GPUVertexInputRate]
   [instance_step_rate _uint32]))

;; SDL_GPUVertexAttribute - vertex attribute layout
(define-cstruct _SDL_GPUVertexAttribute
  ([location _uint32]
   [buffer_slot _uint32]
   [format _SDL_GPUVertexElementFormat]
   [offset _uint32]))

;; SDL_GPUVertexInputState - vertex input state
;; Use _pointer for the arrays to allow malloc'd memory
(define-cstruct _SDL_GPUVertexInputState
  ([vertex_buffer_descriptions _pointer]
   [num_vertex_buffers _uint32]
   [vertex_attributes _pointer]
   [num_vertex_attributes _uint32]))

;; SDL_GPUStencilOpState - stencil operation state
(define-cstruct _SDL_GPUStencilOpState
  ([fail_op _SDL_GPUStencilOp]
   [pass_op _SDL_GPUStencilOp]
   [depth_fail_op _SDL_GPUStencilOp]
   [compare_op _SDL_GPUCompareOp]))

;; SDL_GPUColorTargetBlendState - per-target blend state
(define-cstruct _SDL_GPUColorTargetBlendState
  ([src_color_blendfactor _SDL_GPUBlendFactor]
   [dst_color_blendfactor _SDL_GPUBlendFactor]
   [color_blend_op _SDL_GPUBlendOp]
   [src_alpha_blendfactor _SDL_GPUBlendFactor]
   [dst_alpha_blendfactor _SDL_GPUBlendFactor]
   [alpha_blend_op _SDL_GPUBlendOp]
   [color_write_mask _SDL_GPUColorComponentFlags]
   [enable_blend _stdbool]
   [enable_color_write_mask _stdbool]
   [_padding1 _uint8]))

;; SDL_GPUColorTargetDescription - color target format
(define-cstruct _SDL_GPUColorTargetDescription
  ([format _SDL_GPUTextureFormat]
   [blend_state _SDL_GPUColorTargetBlendState]))

;; SDL_GPURasterizerState - rasterization state
(define-cstruct _SDL_GPURasterizerState
  ([fill_mode _SDL_GPUFillMode]
   [cull_mode _SDL_GPUCullMode]
   [front_face _SDL_GPUFrontFace]
   [depth_bias_constant_factor _float]
   [depth_bias_clamp _float]
   [depth_bias_slope_factor _float]
   [enable_depth_bias _stdbool]
   [enable_depth_clip _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]))

;; SDL_GPUMultisampleState - multisampling state
(define-cstruct _SDL_GPUMultisampleState
  ([sample_count _SDL_GPUSampleCount]
   [sample_mask _uint32]
   [enable_mask _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]
   [_padding3 _uint8]))

;; SDL_GPUDepthStencilState - depth/stencil state
(define-cstruct _SDL_GPUDepthStencilState
  ([compare_op _SDL_GPUCompareOp]
   [back_stencil_state _SDL_GPUStencilOpState]
   [front_stencil_state _SDL_GPUStencilOpState]
   [compare_mask _uint8]
   [write_mask _uint8]
   [enable_depth_test _stdbool]
   [enable_depth_write _stdbool]
   [enable_stencil_test _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]
   [_padding3 _uint8]))

;; SDL_GPUGraphicsPipelineTargetInfo - render target formats
;; Use _pointer for arrays to allow malloc'd memory
(define-cstruct _SDL_GPUGraphicsPipelineTargetInfo
  ([color_target_descriptions _pointer]
   [num_color_targets _uint32]
   [depth_stencil_format _SDL_GPUTextureFormat]
   [has_depth_stencil_target _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]
   [_padding3 _uint8]))

;; SDL_GPUGraphicsPipelineCreateInfo - graphics pipeline creation
(define-cstruct _SDL_GPUGraphicsPipelineCreateInfo
  ([vertex_shader _SDL_GPUShader-pointer]
   [fragment_shader _SDL_GPUShader-pointer]
   [vertex_input_state _SDL_GPUVertexInputState]
   [primitive_type _SDL_GPUPrimitiveType]
   [rasterizer_state _SDL_GPURasterizerState]
   [multisample_state _SDL_GPUMultisampleState]
   [depth_stencil_state _SDL_GPUDepthStencilState]
   [target_info _SDL_GPUGraphicsPipelineTargetInfo]
   [props _uint32]))

;; SDL_GPUShaderCreateInfo - shader creation
(define-cstruct _SDL_GPUShaderCreateInfo
  ([code_size _size]
   [code _pointer]
   [entrypoint _string/utf-8]
   [format _SDL_GPUShaderFormat]
   [stage _SDL_GPUShaderStage]
   [num_samplers _uint32]
   [num_storage_textures _uint32]
   [num_storage_buffers _uint32]
   [num_uniform_buffers _uint32]
   [props _uint32]))

;; SDL_GPUTextureCreateInfo - texture creation
(define-cstruct _SDL_GPUTextureCreateInfo
  ([type _SDL_GPUTextureType]
   [format _SDL_GPUTextureFormat]
   [usage _SDL_GPUTextureUsageFlags]
   [width _uint32]
   [height _uint32]
   [layer_count_or_depth _uint32]
   [num_levels _uint32]
   [sample_count _SDL_GPUSampleCount]
   [props _uint32]))

;; SDL_GPUBufferCreateInfo - buffer creation
(define-cstruct _SDL_GPUBufferCreateInfo
  ([usage _SDL_GPUBufferUsageFlags]
   [size _uint32]
   [props _uint32]))

;; SDL_GPUTransferBufferCreateInfo - transfer buffer creation
(define-cstruct _SDL_GPUTransferBufferCreateInfo
  ([usage _SDL_GPUTransferBufferUsage]
   [size _uint32]
   [props _uint32]))

;; SDL_GPUBufferBinding - buffer binding for vertex/index buffers
(define-cstruct _SDL_GPUBufferBinding
  ([buffer _SDL_GPUBuffer-pointer]
   [offset _uint32]))

;; SDL_GPUTextureSamplerBinding - texture+sampler binding
(define-cstruct _SDL_GPUTextureSamplerBinding
  ([texture _SDL_GPUTexture-pointer]
   [sampler _SDL_GPUSampler-pointer]))

;; SDL_GPUBufferRegion - region within a buffer
(define-cstruct _SDL_GPUBufferRegion
  ([buffer _SDL_GPUBuffer-pointer]
   [offset _uint32]
   [size _uint32]))

;; SDL_GPUTransferBufferLocation - location in transfer buffer
(define-cstruct _SDL_GPUTransferBufferLocation
  ([transfer_buffer _SDL_GPUTransferBuffer-pointer]
   [offset _uint32]))

;; SDL_GPUBufferLocation - location in a buffer
(define-cstruct _SDL_GPUBufferLocation
  ([buffer _SDL_GPUBuffer-pointer]
   [offset _uint32]))

;; SDL_GPUTextureLocation - location in texture
(define-cstruct _SDL_GPUTextureLocation
  ([texture _SDL_GPUTexture-pointer]
   [mip_level _uint32]
   [layer _uint32]
   [x _uint32]
   [y _uint32]
   [z _uint32]))

;; SDL_GPUTextureRegion - region within a texture
(define-cstruct _SDL_GPUTextureRegion
  ([texture _SDL_GPUTexture-pointer]
   [mip_level _uint32]
   [layer _uint32]
   [x _uint32]
   [y _uint32]
   [z _uint32]
   [w _uint32]
   [h _uint32]
   [d _uint32]))

;; SDL_GPUTextureTransferInfo - transfer buffer location with layout
(define-cstruct _SDL_GPUTextureTransferInfo
  ([transfer_buffer _SDL_GPUTransferBuffer-pointer]
   [offset _uint32]
   [pixels_per_row _uint32]
   [rows_per_layer _uint32]))

;; SDL_GPUBlitRegion - source or dest region for blit
(define-cstruct _SDL_GPUBlitRegion
  ([texture _SDL_GPUTexture-pointer]
   [mip_level _uint32]
   [layer_or_depth_plane _uint32]
   [x _uint32]
   [y _uint32]
   [w _uint32]
   [h _uint32]))

;; SDL_GPUBlitInfo - blit operation parameters
(define-cstruct _SDL_GPUBlitInfo
  ([source _SDL_GPUBlitRegion]
   [destination _SDL_GPUBlitRegion]
   [load_op _SDL_GPULoadOp]
   [clear_color _SDL_FColor]
   [flip_mode _SDL_FlipMode]
   [filter _SDL_GPUFilter]
   [cycle _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]
   [_padding3 _uint8]))

;; SDL_GPUComputePipelineCreateInfo - compute pipeline creation
(define-cstruct _SDL_GPUComputePipelineCreateInfo
  ([code_size _size]
   [code _pointer]
   [entrypoint _string/utf-8]
   [format _SDL_GPUShaderFormat]
   [num_samplers _uint32]
   [num_readonly_storage_textures _uint32]
   [num_readonly_storage_buffers _uint32]
   [num_readwrite_storage_textures _uint32]
   [num_readwrite_storage_buffers _uint32]
   [num_uniform_buffers _uint32]
   [threadcount_x _uint32]
   [threadcount_y _uint32]
   [threadcount_z _uint32]
   [props _uint32]))

;; SDL_GPUStorageBufferReadWriteBinding - storage buffer binding
(define-cstruct _SDL_GPUStorageBufferReadWriteBinding
  ([buffer _SDL_GPUBuffer-pointer]
   [cycle _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]
   [_padding3 _uint8]))

;; SDL_GPUStorageTextureReadWriteBinding - storage texture binding
(define-cstruct _SDL_GPUStorageTextureReadWriteBinding
  ([texture _SDL_GPUTexture-pointer]
   [mip_level _uint32]
   [layer _uint32]
   [cycle _stdbool]
   [_padding1 _uint8]
   [_padding2 _uint8]
   [_padding3 _uint8]))

;; ============================================================================
;; OpenGL Types
;; ============================================================================

;; SDL_GLContext opaque pointer type
(define-cpointer-type _SDL_GLContext-pointer)

;; SDL_GLAttr enum (for setting GL context attributes)
(define _SDL_GLAttr _int)

;; ============================================================================
;; Vulkan Types
;; ============================================================================

;; Vulkan handles (opaque pointers for FFI purposes)
(define _VkInstance _pointer)
(define _VkPhysicalDevice _pointer)
(define _VkSurfaceKHR _uint64) ; Non-dispatchable handle, usually 64-bit int

;; Allocation callbacks (opaque pointer, usually NULL)
(define _VkAllocationCallbacks-pointer/null _pointer)
