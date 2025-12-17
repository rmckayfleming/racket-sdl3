#lang racket/base

;; Raw C-style FFI bindings - direct mapping to SDL3 C API
;;
;; This module provides raw bindings to SDL3 functions with minimal abstraction.
;; Function names follow SDL3 conventions with hyphens instead of underscores
;; (e.g., SDL-Init instead of SDL_Init).
;;
;; For Racket-idiomatic wrappers with automatic resource management,
;; see the pretty.rkt module.

(require ffi/unsafe
         "private/lib.rkt"
         "private/types.rkt")

(provide (all-from-out "private/lib.rkt")
         (all-from-out "private/types.rkt")
         ;; Initialization
         SDL-Init
         SDL-Quit
         ;; Error handling
         SDL-GetError
         ;; Window management
         SDL-CreateWindow
         SDL-CreateWindowAndRenderer
         SDL-DestroyWindow
         SDL-SetWindowTitle
         SDL-GetWindowTitle
         SDL-SetWindowIcon
         SDL-GetWindowID
         SDL-GetWindowFromID
         SDL-ShowWindow
         SDL-HideWindow
         SDL-RaiseWindow
         SDL-MaximizeWindow
         SDL-MinimizeWindow
         SDL-RestoreWindow
         SDL-SetWindowMinimumSize
         SDL-SetWindowMaximumSize
         SDL-GetWindowMinimumSize
         SDL-GetWindowMaximumSize
         SDL-SetWindowBordered
         SDL-SetWindowResizable
         SDL-SetWindowOpacity
         SDL-GetWindowOpacity
         SDL-FlashWindow
         SDL-GetWindowSurface
         SDL-UpdateWindowSurface
         SDL-GetWindowPixelDensity
         SDL-GetWindowSize
         SDL-SetWindowSize
         SDL-GetWindowPosition
         SDL-SetWindowPosition
         SDL-GetWindowFlags
         SDL-SetWindowFullscreen
         ;; Renderer
         SDL-CreateRenderer
         SDL-DestroyRenderer
         SDL-SetRenderDrawColor
         SDL-RenderClear
         SDL-RenderPresent
         ;; Renderer Query Functions
         SDL-GetNumRenderDrivers
         SDL-GetRenderDriver
         SDL-GetRenderer
         SDL-GetRenderWindow
         SDL-GetRendererName
         SDL-GetRenderOutputSize
         SDL-GetCurrentRenderOutputSize
         SDL-GetRenderDrawColor
         SDL-SetRenderDrawColorFloat
         SDL-GetRenderDrawColorFloat
         SDL-SetRenderVSync
         SDL-GetRenderVSync
         ;; Viewport and Clipping
         SDL-SetRenderViewport
         SDL-GetRenderViewport
         SDL-SetRenderClipRect
         SDL-GetRenderClipRect
         SDL-RenderClipEnabled
         SDL-SetRenderScale
         SDL-GetRenderScale
         ;; Texture
         SDL-CreateTexture
         SDL-DestroyTexture
         SDL-RenderTexture
         SDL-RenderTextureRotated
         SDL-RenderTextureAffine
         SDL-RenderTextureTiled
         SDL-RenderTexture9Grid
         SDL-GetTextureSize
         SDL-CreateTextureFromSurface
         ;; Render targets
         SDL-SetRenderTarget
         SDL-GetRenderTarget
         ;; Texture scale mode
         SDL-SetTextureScaleMode
         SDL-GetTextureScaleMode
         ;; Drawing primitives
         SDL-RenderPoint
         SDL-RenderPoints
         SDL-RenderLine
         SDL-RenderLines
         SDL-RenderRect
         SDL-RenderRects
         SDL-RenderFillRect
         SDL-RenderFillRects
         ;; Geometry rendering
         SDL-RenderGeometry
         ;; Debug text
         SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE
         SDL-RenderDebugText
         ;; Blend modes
         SDL-SetRenderDrawBlendMode
         SDL-GetRenderDrawBlendMode
         SDL-SetTextureBlendMode
         SDL-GetTextureBlendMode
         ;; Texture color/alpha modulation
         SDL-SetTextureColorMod
         SDL-GetTextureColorMod
         SDL-SetTextureAlphaMod
         SDL-GetTextureAlphaMod
         ;; Surface
         SDL-DestroySurface
         ;; Screenshots
         SDL-RenderReadPixels
         ;; Rectangle utilities
         SDL-HasRectIntersection
         SDL-GetRectIntersection
         SDL-HasRectIntersectionFloat
         SDL-GetRectIntersectionFloat
         ;; Events
         SDL-PollEvent
         SDL-WaitEvent
         SDL-WaitEventTimeout
         ;; Keyboard
         SDL-GetKeyName
         ;; Text Input
         SDL-StartTextInput
         SDL-StopTextInput
         ;; Mouse
         SDL-GetMouseState
         SDL-GetRelativeMouseState
         SDL-SetWindowRelativeMouseMode
         SDL-GetWindowRelativeMouseMode
         ;; Cursor
         SDL-CreateSystemCursor
         SDL-SetCursor
         SDL-GetCursor
         SDL-DestroyCursor
         SDL-ShowCursor
         SDL-HideCursor
         SDL-CursorVisible
         ;; Timer
         SDL-GetTicks
         SDL-GetTicksNS
         SDL-GetPerformanceCounter
         SDL-GetPerformanceFrequency
         SDL-Delay
         SDL-DelayNS
         SDL-DelayPrecise
         ;; Clipboard
         SDL-SetClipboardText
         SDL-GetClipboardText
         SDL-HasClipboardText
         ;; Memory
         SDL-free
         ;; Audio - Drivers
         SDL-GetNumAudioDrivers
         SDL-GetAudioDriver
         SDL-GetCurrentAudioDriver
         ;; Audio - Device Enumeration
         SDL-GetAudioPlaybackDevices
         SDL-GetAudioRecordingDevices
         SDL-GetAudioDeviceName
         ;; Audio - Device Control
         SDL-OpenAudioDevice
         SDL-CloseAudioDevice
         SDL-PauseAudioDevice
         SDL-ResumeAudioDevice
         SDL-AudioDevicePaused
         ;; Audio - Streams
         SDL-CreateAudioStream
         SDL-DestroyAudioStream
         SDL-GetAudioStreamFormat
         SDL-SetAudioStreamFormat
         SDL-PutAudioStreamData
         SDL-GetAudioStreamData
         SDL-GetAudioStreamAvailable
         SDL-FlushAudioStream
         SDL-ClearAudioStream
         SDL-BindAudioStream
         SDL-UnbindAudioStream
         ;; Audio - WAV Loading
         SDL-LoadWAV)

;; ============================================================================
;; Initialization
;; ============================================================================

;; SDL_Init: Initialize the SDL library
;; flags: SDL_InitFlags bitmask specifying subsystems to initialize
;; Returns: true on success, false on failure
(define-sdl SDL-Init (_fun _SDL_InitFlags -> _sdl-bool)
  #:c-id SDL_Init)

;; SDL_Quit: Clean up all initialized subsystems
(define-sdl SDL-Quit (_fun -> _void)
  #:c-id SDL_Quit)

;; ============================================================================
;; Error Handling
;; ============================================================================

;; SDL_GetError: Get the last error message
;; Returns: A string describing the last error
(define-sdl SDL-GetError (_fun -> _string)
  #:c-id SDL_GetError)

;; Register SDL_GetError with the types module for check-sdl-bool
(sdl-get-error-proc SDL-GetError)

;; ============================================================================
;; Window Management
;; ============================================================================

;; SDL_CreateWindow: Create a window with the specified title, size, and flags
;; title: The title of the window (UTF-8)
;; w: Width of the window in pixels
;; h: Height of the window in pixels
;; flags: SDL_WindowFlags bitmask
;; Returns: Pointer to the window, or NULL on failure
(define-sdl SDL-CreateWindow
  (_fun _string _int _int _SDL_WindowFlags -> _SDL_Window-pointer/null)
  #:c-id SDL_CreateWindow)

;; SDL_CreateWindowAndRenderer: Create a window and default renderer
;; title: The title of the window (UTF-8)
;; width: Width of the window in pixels
;; height: Height of the window in pixels
;; window_flags: SDL_WindowFlags bitmask
;; window: Pointer to receive the created window
;; renderer: Pointer to receive the created renderer
;; Returns: true on success, false on failure
(define-sdl SDL-CreateWindowAndRenderer
  (_fun _string _int _int _SDL_WindowFlags
        (window : (_ptr o _SDL_Window-pointer/null))
        (renderer : (_ptr o _SDL_Renderer-pointer/null))
        -> (result : _sdl-bool)
        -> (values result window renderer))
  #:c-id SDL_CreateWindowAndRenderer)

;; SDL_DestroyWindow: Destroy a window
(define-sdl SDL-DestroyWindow (_fun _SDL_Window-pointer -> _void)
  #:c-id SDL_DestroyWindow)

;; SDL_GetWindowPixelDensity: Get the pixel density of a window
;; window: the window to query
;; Returns: the pixel density (e.g., 2.0 for Retina displays)
(define-sdl SDL-GetWindowPixelDensity (_fun _SDL_Window-pointer -> _float)
  #:c-id SDL_GetWindowPixelDensity)

;; SDL_GetWindowSize: Get the size of a window's client area
;; window: the window to query
;; Returns: (values success? width height)
(define-sdl SDL-GetWindowSize
  (_fun _SDL_Window-pointer
        (w : (_ptr o _int))
        (h : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result w h))
  #:c-id SDL_GetWindowSize)

;; SDL_SetWindowSize: Set the size of a window's client area
;; window: the window to resize
;; w, h: the new width and height
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowSize
  (_fun _SDL_Window-pointer _int _int -> _sdl-bool)
  #:c-id SDL_SetWindowSize)

;; SDL_GetWindowPosition: Get the position of a window
;; window: the window to query
;; Returns: (values success? x y)
(define-sdl SDL-GetWindowPosition
  (_fun _SDL_Window-pointer
        (x : (_ptr o _int))
        (y : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result x y))
  #:c-id SDL_GetWindowPosition)

;; SDL_SetWindowPosition: Set the position of a window
;; window: the window to move
;; x, y: the new position
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowPosition
  (_fun _SDL_Window-pointer _int _int -> _sdl-bool)
  #:c-id SDL_SetWindowPosition)

;; SDL_GetWindowFlags: Get the window flags
;; window: the window to query
;; Returns: SDL_WindowFlags bitmask
(define-sdl SDL-GetWindowFlags
  (_fun _SDL_Window-pointer -> _SDL_WindowFlags)
  #:c-id SDL_GetWindowFlags)

;; SDL_SetWindowFullscreen: Set the fullscreen mode of a window
;; window: the window to modify
;; fullscreen: true for fullscreen, false for windowed
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowFullscreen
  (_fun _SDL_Window-pointer _bool -> _sdl-bool)
  #:c-id SDL_SetWindowFullscreen)

;; ============================================================================
;; Renderer
;; ============================================================================

;; SDL_CreateRenderer: Create a 2D rendering context for a window
;; window: The window for the renderer
;; name: The name of the renderer driver, or NULL for default
;; Returns: Pointer to the renderer, or NULL on failure
(define-sdl SDL-CreateRenderer
  (_fun _SDL_Window-pointer _string/utf-8 -> _SDL_Renderer-pointer/null)
  #:c-id SDL_CreateRenderer)

;; SDL_DestroyRenderer: Destroy a renderer
(define-sdl SDL-DestroyRenderer (_fun _SDL_Renderer-pointer -> _void)
  #:c-id SDL_DestroyRenderer)

;; SDL_SetRenderDrawColor: Set the color for drawing operations
;; r, g, b, a: Color components (0-255)
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderDrawColor
  (_fun _SDL_Renderer-pointer _uint8 _uint8 _uint8 _uint8 -> _sdl-bool)
  #:c-id SDL_SetRenderDrawColor)

;; SDL_RenderClear: Clear the renderer with the current draw color
;; Returns: true on success, false on failure
(define-sdl SDL-RenderClear (_fun _SDL_Renderer-pointer -> _sdl-bool)
  #:c-id SDL_RenderClear)

;; SDL_RenderPresent: Update the screen with any rendering since the last call
;; Returns: true on success, false on failure
(define-sdl SDL-RenderPresent (_fun _SDL_Renderer-pointer -> _sdl-bool)
  #:c-id SDL_RenderPresent)

;; ============================================================================
;; Renderer Query Functions
;; ============================================================================

;; SDL_GetNumRenderDrivers: Get the number of 2D rendering drivers available
;; Returns: the number of built-in render drivers
(define-sdl SDL-GetNumRenderDrivers (_fun -> _int)
  #:c-id SDL_GetNumRenderDrivers)

;; SDL_GetRenderDriver: Get the name of a built-in 2D rendering driver
;; index: the index of the rendering driver (0 to SDL_GetNumRenderDrivers()-1)
;; Returns: the name of the rendering driver, or NULL if invalid index
(define-sdl SDL-GetRenderDriver (_fun _int -> _string/utf-8)
  #:c-id SDL_GetRenderDriver)

;; SDL_GetRenderer: Get the renderer associated with a window
;; window: the window to query
;; Returns: the rendering context, or NULL on failure
(define-sdl SDL-GetRenderer
  (_fun _SDL_Window-pointer -> _SDL_Renderer-pointer/null)
  #:c-id SDL_GetRenderer)

;; SDL_GetRenderWindow: Get the window associated with a renderer
;; renderer: the renderer to query
;; Returns: the window, or NULL on failure
(define-sdl SDL-GetRenderWindow
  (_fun _SDL_Renderer-pointer -> _SDL_Window-pointer/null)
  #:c-id SDL_GetRenderWindow)

;; SDL_GetRendererName: Get the name of a renderer
;; renderer: the rendering context
;; Returns: the name of the selected renderer, or NULL on failure
(define-sdl SDL-GetRendererName (_fun _SDL_Renderer-pointer -> _string/utf-8)
  #:c-id SDL_GetRendererName)

;; SDL_GetRenderOutputSize: Get the output size in pixels of a rendering context
;; renderer: the rendering context
;; Returns: (values success? width height)
(define-sdl SDL-GetRenderOutputSize
  (_fun _SDL_Renderer-pointer
        (w : (_ptr o _int))
        (h : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result w h))
  #:c-id SDL_GetRenderOutputSize)

;; SDL_GetCurrentRenderOutputSize: Get the current output size in pixels
;; This returns the size considering the current render target and logical size.
;; renderer: the rendering context
;; Returns: (values success? width height)
(define-sdl SDL-GetCurrentRenderOutputSize
  (_fun _SDL_Renderer-pointer
        (w : (_ptr o _int))
        (h : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result w h))
  #:c-id SDL_GetCurrentRenderOutputSize)

;; SDL_GetRenderDrawColor: Get the color used for drawing operations
;; renderer: the rendering context
;; Returns: (values success? r g b a)
(define-sdl SDL-GetRenderDrawColor
  (_fun _SDL_Renderer-pointer
        (r : (_ptr o _uint8))
        (g : (_ptr o _uint8))
        (b : (_ptr o _uint8))
        (a : (_ptr o _uint8))
        -> (result : _sdl-bool)
        -> (values result r g b a))
  #:c-id SDL_GetRenderDrawColor)

;; SDL_SetRenderDrawColorFloat: Set the color for drawing operations (float version)
;; renderer: the rendering context
;; r, g, b, a: Color components (0.0 to 1.0, can exceed for HDR)
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderDrawColorFloat
  (_fun _SDL_Renderer-pointer _float _float _float _float -> _sdl-bool)
  #:c-id SDL_SetRenderDrawColorFloat)

;; SDL_GetRenderDrawColorFloat: Get the color used for drawing operations (float version)
;; renderer: the rendering context
;; Returns: (values success? r g b a)
(define-sdl SDL-GetRenderDrawColorFloat
  (_fun _SDL_Renderer-pointer
        (r : (_ptr o _float))
        (g : (_ptr o _float))
        (b : (_ptr o _float))
        (a : (_ptr o _float))
        -> (result : _sdl-bool)
        -> (values result r g b a))
  #:c-id SDL_GetRenderDrawColorFloat)

;; SDL_SetRenderVSync: Toggle VSync for a renderer
;; renderer: the rendering context
;; vsync: the vertical refresh sync interval (1 for on, 0 for off, -1 for adaptive)
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderVSync
  (_fun _SDL_Renderer-pointer _int -> _sdl-bool)
  #:c-id SDL_SetRenderVSync)

;; SDL_GetRenderVSync: Get the VSync setting for a renderer
;; renderer: the rendering context
;; Returns: (values success? vsync)
(define-sdl SDL-GetRenderVSync
  (_fun _SDL_Renderer-pointer
        (vsync : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result vsync))
  #:c-id SDL_GetRenderVSync)

;; ============================================================================
;; Viewport and Clipping
;; ============================================================================

;; SDL_SetRenderViewport: Set the drawing area for rendering on the current target
;; renderer: the rendering context
;; rect: the SDL_Rect representing the drawing area, or NULL to set the viewport
;;       to the entire target
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderViewport
  (_fun _SDL_Renderer-pointer _SDL_Rect-pointer/null -> _sdl-bool)
  #:c-id SDL_SetRenderViewport)

;; SDL_GetRenderViewport: Get the drawing area for the current target
;; renderer: the rendering context
;; rect: an SDL_Rect structure to be filled with the current drawing area
;; Returns: true on success, false on failure
(define-sdl SDL-GetRenderViewport
  (_fun _SDL_Renderer-pointer _SDL_Rect-pointer -> _sdl-bool)
  #:c-id SDL_GetRenderViewport)

;; SDL_SetRenderClipRect: Set the clip rectangle for rendering on the current target
;; renderer: the rendering context
;; rect: an SDL_Rect representing the clip area, or NULL to disable clipping
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderClipRect
  (_fun _SDL_Renderer-pointer _SDL_Rect-pointer/null -> _sdl-bool)
  #:c-id SDL_SetRenderClipRect)

;; SDL_GetRenderClipRect: Get the clip rectangle for the current target
;; renderer: the rendering context
;; rect: an SDL_Rect structure to be filled with the current clip rectangle
;; Returns: true on success, false on failure
(define-sdl SDL-GetRenderClipRect
  (_fun _SDL_Renderer-pointer _SDL_Rect-pointer -> _sdl-bool)
  #:c-id SDL_GetRenderClipRect)

;; SDL_RenderClipEnabled: Get whether clipping is enabled on the given render target
;; renderer: the rendering context
;; Returns: true if clipping is enabled, false if not
(define-sdl SDL-RenderClipEnabled
  (_fun _SDL_Renderer-pointer -> _bool)
  #:c-id SDL_RenderClipEnabled)

;; SDL_SetRenderScale: Set the drawing scale for rendering on the current target
;; renderer: the rendering context
;; scaleX: the horizontal scaling factor
;; scaleY: the vertical scaling factor
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderScale
  (_fun _SDL_Renderer-pointer _float _float -> _sdl-bool)
  #:c-id SDL_SetRenderScale)

;; SDL_GetRenderScale: Get the drawing scale for the current target
;; renderer: the rendering context
;; Returns: (values success? scaleX scaleY)
(define-sdl SDL-GetRenderScale
  (_fun _SDL_Renderer-pointer
        (scaleX : (_ptr o _float))
        (scaleY : (_ptr o _float))
        -> (result : _sdl-bool)
        -> (values result scaleX scaleY))
  #:c-id SDL_GetRenderScale)

;; ============================================================================
;; Texture
;; ============================================================================

;; SDL_DestroyTexture: Destroy a texture
(define-sdl SDL-DestroyTexture (_fun _SDL_Texture-pointer -> _void)
  #:c-id SDL_DestroyTexture)

;; SDL_RenderTexture: Copy texture to renderer at destination rectangle
;; srcrect: portion of texture (NULL for whole texture)
;; dstrect: destination rectangle (NULL for whole renderer)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTexture
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _SDL_FRect-pointer/null
        -> _sdl-bool)
  #:c-id SDL_RenderTexture)

;; SDL_RenderTextureRotated: Copy texture with rotation and flipping
;; renderer: the renderer
;; texture: the source texture
;; srcrect: portion of texture (NULL for whole texture)
;; dstrect: destination rectangle (NULL for whole renderer)
;; angle: rotation angle in degrees (clockwise)
;; center: point around which to rotate (NULL for center of dstrect)
;; flip: SDL_FlipMode value for flipping
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTextureRotated
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _SDL_FRect-pointer/null
        _double
        _SDL_FPoint-pointer/null
        _SDL_FlipMode
        -> _sdl-bool)
  #:c-id SDL_RenderTextureRotated)

;; SDL_RenderTextureAffine: Copy texture with affine transform
;; renderer: the renderer
;; texture: the source texture
;; srcrect: portion of texture (NULL for whole texture)
;; origin: the point in the destination where the top-left corner of srcrect appears
;; right: the point in the destination where the top-right corner of srcrect appears
;; down: the point in the destination where the bottom-left corner of srcrect appears
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTextureAffine
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _SDL_FPoint-pointer/null
        _SDL_FPoint-pointer/null
        _SDL_FPoint-pointer/null
        -> _sdl-bool)
  #:c-id SDL_RenderTextureAffine)

;; SDL_RenderTextureTiled: Tile a texture to fill a destination rectangle
;; renderer: the renderer
;; texture: the source texture
;; srcrect: portion of texture to tile (NULL for whole texture)
;; scale: scale factor for the source rectangle (e.g., 2 makes 32x32 tile fill 64x64)
;; dstrect: destination rectangle to fill (NULL for whole renderer)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTextureTiled
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _float
        _SDL_FRect-pointer/null
        -> _sdl-bool)
  #:c-id SDL_RenderTextureTiled)

;; SDL_RenderTexture9Grid: Render texture using 9-grid (9-slice) algorithm
;; renderer: the renderer
;; texture: the source texture
;; srcrect: source rectangle for the 9-grid (NULL for whole texture)
;; left_width: width of left corners in source pixels
;; right_width: width of right corners in source pixels
;; top_height: height of top corners in source pixels
;; bottom_height: height of bottom corners in source pixels
;; scale: scale factor for corners
;; dstrect: destination rectangle (NULL for whole renderer)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTexture9Grid
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _float _float _float _float  ; left_width, right_width, top_height, bottom_height
        _float                        ; scale
        _SDL_FRect-pointer/null
        -> _sdl-bool)
  #:c-id SDL_RenderTexture9Grid)

;; SDL_GetTextureSize: Query texture dimensions
;; texture: the texture to query
;; w, h: pointers to receive width and height (can be NULL)
;; Returns: true on success, false on failure
(define-sdl SDL-GetTextureSize
  (_fun _SDL_Texture-pointer _pointer _pointer -> _sdl-bool)
  #:c-id SDL_GetTextureSize)

;; SDL_CreateTextureFromSurface: Create a texture from an existing surface
;; renderer: the renderer to use
;; surface: the surface to convert to a texture
;; Returns: pointer to the texture, or NULL on failure
(define-sdl SDL-CreateTextureFromSurface
  (_fun _SDL_Renderer-pointer _SDL_Surface-pointer -> _SDL_Texture-pointer/null)
  #:c-id SDL_CreateTextureFromSurface)

;; SDL_CreateTexture: Create a texture for a renderer
;; renderer: the rendering context
;; format: the pixel format (SDL_PixelFormat)
;; access: the access pattern (SDL_TextureAccess)
;; w, h: the width and height of the texture in pixels
;; Returns: pointer to the texture, or NULL on failure
(define-sdl SDL-CreateTexture
  (_fun _SDL_Renderer-pointer _SDL_PixelFormat _SDL_TextureAccess _int _int
        -> _SDL_Texture-pointer/null)
  #:c-id SDL_CreateTexture)

;; ============================================================================
;; Render Targets
;; ============================================================================

;; SDL_SetRenderTarget: Set a texture as the current rendering target
;; renderer: the rendering context
;; texture: the texture to use as render target, or NULL to render to the window
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderTarget
  (_fun _SDL_Renderer-pointer _SDL_Texture-pointer/null -> _sdl-bool)
  #:c-id SDL_SetRenderTarget)

;; SDL_GetRenderTarget: Get the current render target
;; renderer: the rendering context
;; Returns: the current render target, or NULL for the default (window)
(define-sdl SDL-GetRenderTarget
  (_fun _SDL_Renderer-pointer -> _SDL_Texture-pointer/null)
  #:c-id SDL_GetRenderTarget)

;; ============================================================================
;; Texture Scale Mode
;; ============================================================================

;; SDL_SetTextureScaleMode: Set the scale mode used for texture scale operations
;; texture: the texture to update
;; scaleMode: the scale mode to use
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureScaleMode
  (_fun _SDL_Texture-pointer _SDL_ScaleMode -> _sdl-bool)
  #:c-id SDL_SetTextureScaleMode)

;; SDL_GetTextureScaleMode: Get the scale mode used for texture scale operations
;; texture: the texture to query
;; Returns: (values success? scaleMode)
(define-sdl SDL-GetTextureScaleMode
  (_fun _SDL_Texture-pointer (scaleMode : (_ptr o _SDL_ScaleMode))
        -> (result : _sdl-bool)
        -> (values result scaleMode))
  #:c-id SDL_GetTextureScaleMode)

;; ============================================================================
;; Drawing Primitives
;; ============================================================================

;; SDL_RenderPoint: Draw a point (single pixel) at (x, y)
;; renderer: the renderer to draw on
;; x, y: coordinates of the point
;; Returns: true on success, false on failure
(define-sdl SDL-RenderPoint
  (_fun _SDL_Renderer-pointer _float _float -> _sdl-bool)
  #:c-id SDL_RenderPoint)

;; SDL_RenderPoints: Draw multiple points at once
;; renderer: the renderer to draw on
;; points: pointer to array of SDL_FPoint structs
;; count: number of points to draw
;; Returns: true on success, false on failure
(define-sdl SDL-RenderPoints
  (_fun _SDL_Renderer-pointer _pointer _int -> _sdl-bool)
  #:c-id SDL_RenderPoints)

;; SDL_RenderLine: Draw a line from (x1, y1) to (x2, y2)
;; renderer: the renderer to draw on
;; x1, y1: start point coordinates
;; x2, y2: end point coordinates
;; Returns: true on success, false on failure
(define-sdl SDL-RenderLine
  (_fun _SDL_Renderer-pointer _float _float _float _float -> _sdl-bool)
  #:c-id SDL_RenderLine)

;; SDL_RenderLines: Draw a series of connected lines
;; renderer: the renderer to draw on
;; points: pointer to array of SDL_FPoint structs (vertices)
;; count: number of points (draws count-1 lines)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderLines
  (_fun _SDL_Renderer-pointer _pointer _int -> _sdl-bool)
  #:c-id SDL_RenderLines)

;; SDL_RenderRect: Draw a rectangle outline
;; renderer: the renderer to draw on
;; rect: the rectangle to draw (NULL draws the entire renderer)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderRect
  (_fun _SDL_Renderer-pointer _SDL_FRect-pointer/null -> _sdl-bool)
  #:c-id SDL_RenderRect)

;; SDL_RenderRects: Draw multiple rectangle outlines at once
;; renderer: the renderer to draw on
;; rects: pointer to array of SDL_FRect structs
;; count: number of rectangles to draw
;; Returns: true on success, false on failure
(define-sdl SDL-RenderRects
  (_fun _SDL_Renderer-pointer _pointer _int -> _sdl-bool)
  #:c-id SDL_RenderRects)

;; SDL_RenderFillRect: Draw a filled rectangle
;; renderer: the renderer to draw on
;; rect: the rectangle to fill (NULL fills the entire renderer)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderFillRect
  (_fun _SDL_Renderer-pointer _SDL_FRect-pointer/null -> _sdl-bool)
  #:c-id SDL_RenderFillRect)

;; SDL_RenderFillRects: Draw multiple filled rectangles at once
;; renderer: the renderer to draw on
;; rects: pointer to array of SDL_FRect structs
;; count: number of rectangles to fill
;; Returns: true on success, false on failure
(define-sdl SDL-RenderFillRects
  (_fun _SDL_Renderer-pointer _pointer _int -> _sdl-bool)
  #:c-id SDL_RenderFillRects)

;; ============================================================================
;; Geometry Rendering
;; ============================================================================

;; SDL_RenderGeometry: Render a list of triangles
;; renderer: the rendering context
;; texture: optional texture for textured triangles (NULL for solid colors)
;; vertices: pointer to array of SDL_Vertex structs
;; num_vertices: number of vertices
;; indices: optional array of indices into vertices (NULL for sequential)
;; num_indices: number of indices (0 if indices is NULL)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderGeometry
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer/null
        _pointer          ; vertices array
        _int              ; num_vertices
        _pointer          ; indices array (can be NULL)
        _int              ; num_indices
        -> _sdl-bool)
  #:c-id SDL_RenderGeometry)

;; ============================================================================
;; Debug Text
;; ============================================================================

;; SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE: Size of debug text characters (8x8 pixels)
(define SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE 8)

;; SDL_RenderDebugText: Draw debug text to a renderer
;; This is a simple 8x8 bitmap font for debugging purposes.
;; renderer: the renderer to draw on
;; x, y: position of top-left corner
;; str: the string to render (UTF-8, but only ASCII is rendered)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderDebugText
  (_fun _SDL_Renderer-pointer _float _float _string/utf-8 -> _sdl-bool)
  #:c-id SDL_RenderDebugText)

;; ============================================================================
;; Blend Modes
;; ============================================================================

;; SDL_SetRenderDrawBlendMode: Set the blend mode used for drawing operations
;; renderer: the renderer
;; blendMode: the blend mode to use
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderDrawBlendMode
  (_fun _SDL_Renderer-pointer _SDL_BlendMode -> _sdl-bool)
  #:c-id SDL_SetRenderDrawBlendMode)

;; SDL_GetRenderDrawBlendMode: Get the current blend mode for the renderer
;; renderer: the renderer to query
;; blendMode: pointer to receive the current blend mode
;; Returns: true on success, false on failure
(define-sdl SDL-GetRenderDrawBlendMode
  (_fun _SDL_Renderer-pointer (blendMode : (_ptr o _SDL_BlendMode))
        -> (result : _sdl-bool)
        -> (values result blendMode))
  #:c-id SDL_GetRenderDrawBlendMode)

;; SDL_SetTextureBlendMode: Set the blend mode for a texture
;; texture: the texture to modify
;; blendMode: the blend mode to use
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureBlendMode
  (_fun _SDL_Texture-pointer _SDL_BlendMode -> _sdl-bool)
  #:c-id SDL_SetTextureBlendMode)

;; SDL_GetTextureBlendMode: Get the blend mode for a texture
;; texture: the texture to query
;; blendMode: pointer to receive the current blend mode
;; Returns: true on success, false on failure
(define-sdl SDL-GetTextureBlendMode
  (_fun _SDL_Texture-pointer (blendMode : (_ptr o _SDL_BlendMode))
        -> (result : _sdl-bool)
        -> (values result blendMode))
  #:c-id SDL_GetTextureBlendMode)

;; ============================================================================
;; Texture Color/Alpha Modulation
;; ============================================================================

;; SDL_SetTextureColorMod: Set an additional color value multiplied into render copy operations
;; texture: the texture to modify
;; r, g, b: the color modulation values (0-255)
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureColorMod
  (_fun _SDL_Texture-pointer _uint8 _uint8 _uint8 -> _sdl-bool)
  #:c-id SDL_SetTextureColorMod)

;; SDL_GetTextureColorMod: Get the additional color value multiplied into render copy operations
;; texture: the texture to query
;; Returns: (values success? r g b)
(define-sdl SDL-GetTextureColorMod
  (_fun _SDL_Texture-pointer
        (r : (_ptr o _uint8))
        (g : (_ptr o _uint8))
        (b : (_ptr o _uint8))
        -> (result : _sdl-bool)
        -> (values result r g b))
  #:c-id SDL_GetTextureColorMod)

;; SDL_SetTextureAlphaMod: Set an additional alpha value multiplied into render copy operations
;; texture: the texture to modify
;; alpha: the alpha modulation value (0-255)
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureAlphaMod
  (_fun _SDL_Texture-pointer _uint8 -> _sdl-bool)
  #:c-id SDL_SetTextureAlphaMod)

;; SDL_GetTextureAlphaMod: Get the additional alpha value multiplied into render copy operations
;; texture: the texture to query
;; Returns: (values success? alpha)
(define-sdl SDL-GetTextureAlphaMod
  (_fun _SDL_Texture-pointer
        (alpha : (_ptr o _uint8))
        -> (result : _sdl-bool)
        -> (values result alpha))
  #:c-id SDL_GetTextureAlphaMod)

;; ============================================================================
;; Surface
;; ============================================================================

;; SDL_DestroySurface: Free a surface (replaces SDL_FreeSurface from SDL2)
;; surface: the surface to destroy
(define-sdl SDL-DestroySurface (_fun _SDL_Surface-pointer -> _void)
  #:c-id SDL_DestroySurface)

;; ============================================================================
;; Screenshots
;; ============================================================================

;; SDL_RenderReadPixels: Read pixels from the current rendering target to a surface
;; renderer: the rendering context
;; rect: area to read (NULL for entire render target)
;; Returns: a new surface with the pixels, or NULL on failure
;;
;; Use with IMG_SavePNG or IMG_SaveJPG to save screenshots.
(define-sdl SDL-RenderReadPixels
  (_fun _SDL_Renderer-pointer _SDL_Rect-pointer/null -> _SDL_Surface-pointer/null)
  #:c-id SDL_RenderReadPixels)

;; ============================================================================
;; Rectangle Utilities
;; ============================================================================

;; SDL_HasRectIntersection: Determine whether two rectangles intersect
;; A: an SDL_Rect structure representing the first rectangle
;; B: an SDL_Rect structure representing the second rectangle
;; Returns: true if there is an intersection, false otherwise
(define-sdl SDL-HasRectIntersection
  (_fun _SDL_Rect-pointer _SDL_Rect-pointer -> _sdl-bool)
  #:c-id SDL_HasRectIntersection)

;; SDL_GetRectIntersection: Calculate the intersection of two rectangles
;; A: an SDL_Rect structure representing the first rectangle
;; B: an SDL_Rect structure representing the second rectangle
;; result: an SDL_Rect structure to be filled with the intersection
;; Returns: true if there is an intersection, false otherwise
(define-sdl SDL-GetRectIntersection
  (_fun _SDL_Rect-pointer _SDL_Rect-pointer _SDL_Rect-pointer -> _sdl-bool)
  #:c-id SDL_GetRectIntersection)

;; SDL_HasRectIntersectionFloat: Determine whether two float rectangles intersect
;; A: an SDL_FRect structure representing the first rectangle
;; B: an SDL_FRect structure representing the second rectangle
;; Returns: true if there is an intersection, false otherwise
(define-sdl SDL-HasRectIntersectionFloat
  (_fun _SDL_FRect-pointer _SDL_FRect-pointer -> _sdl-bool)
  #:c-id SDL_HasRectIntersectionFloat)

;; SDL_GetRectIntersectionFloat: Calculate the intersection of two float rectangles
;; A: an SDL_FRect structure representing the first rectangle
;; B: an SDL_FRect structure representing the second rectangle
;; result: an SDL_FRect structure to be filled with the intersection
;; Returns: true if there is an intersection, false otherwise
(define-sdl SDL-GetRectIntersectionFloat
  (_fun _SDL_FRect-pointer _SDL_FRect-pointer _SDL_FRect-pointer -> _sdl-bool)
  #:c-id SDL_GetRectIntersectionFloat)

;; ============================================================================
;; Events
;; ============================================================================

;; SDL_PollEvent: Poll for currently pending events
;; event: Pointer to an SDL_Event structure (at least 128 bytes)
;; Returns: true if there is a pending event, false otherwise
(define-sdl SDL-PollEvent (_fun _pointer -> _sdl-bool)
  #:c-id SDL_PollEvent)

;; SDL_WaitEvent: Wait indefinitely for the next available event
;; event: Pointer to an SDL_Event structure (at least 128 bytes)
;; Returns: true on success, false on error
(define-sdl SDL-WaitEvent (_fun _pointer -> _sdl-bool)
  #:c-id SDL_WaitEvent)

;; SDL_WaitEventTimeout: Wait until timeout for the next available event
;; event: Pointer to an SDL_Event structure (at least 128 bytes)
;; timeoutMS: Maximum time to wait in milliseconds (-1 to wait indefinitely)
;; Returns: true if an event is available, false if timed out or error
(define-sdl SDL-WaitEventTimeout (_fun _pointer _sint32 -> _sdl-bool)
  #:c-id SDL_WaitEventTimeout)

;; ============================================================================
;; Keyboard
;; ============================================================================

;; SDL_GetKeyName: Get a human-readable name for a key
;; key: SDL_Keycode value
;; Returns: A human-readable key name string
(define-sdl SDL-GetKeyName (_fun _SDL_Keycode -> _string)
  #:c-id SDL_GetKeyName)

;; ============================================================================
;; Text Input
;; ============================================================================

;; SDL_StartTextInput: Start accepting text input events
;; window: the window to enable text input for
;; Returns: true on success, false on failure
(define-sdl SDL-StartTextInput (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_StartTextInput)

;; SDL_StopTextInput: Stop accepting text input events
;; window: the window to disable text input for
;; Returns: true on success, false on failure
(define-sdl SDL-StopTextInput (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_StopTextInput)

;; ============================================================================
;; Window (additional functions)
;; ============================================================================

;; SDL_SetWindowTitle: Set the title of a window
;; window: The window to modify
;; title: The new title (UTF-8)
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowTitle (_fun _SDL_Window-pointer _string -> _sdl-bool)
  #:c-id SDL_SetWindowTitle)

;; SDL_GetWindowTitle: Get the title of a window
;; window: The window to query
;; Returns: The title of the window (UTF-8), or empty string on failure
(define-sdl SDL-GetWindowTitle (_fun _SDL_Window-pointer -> _string)
  #:c-id SDL_GetWindowTitle)

;; SDL_SetWindowIcon: Set the icon for a window
;; window: The window to modify
;; icon: An SDL_Surface with the icon image
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowIcon (_fun _SDL_Window-pointer _SDL_Surface-pointer -> _sdl-bool)
  #:c-id SDL_SetWindowIcon)

;; SDL_GetWindowID: Get the numeric ID of a window
;; window: The window to query
;; Returns: The ID of the window, or 0 on failure
(define-sdl SDL-GetWindowID (_fun _SDL_Window-pointer -> _SDL_WindowID)
  #:c-id SDL_GetWindowID)

;; SDL_GetWindowFromID: Get a window from a stored ID
;; id: The ID of the window
;; Returns: The window associated with id, or NULL if not found
(define-sdl SDL-GetWindowFromID (_fun _SDL_WindowID -> _SDL_Window-pointer/null)
  #:c-id SDL_GetWindowFromID)

;; SDL_ShowWindow: Show a window
;; window: The window to show
;; Returns: true on success, false on failure
(define-sdl SDL-ShowWindow (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_ShowWindow)

;; SDL_HideWindow: Hide a window
;; window: The window to hide
;; Returns: true on success, false on failure
(define-sdl SDL-HideWindow (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_HideWindow)

;; SDL_RaiseWindow: Raise a window above other windows and set input focus
;; window: The window to raise
;; Returns: true on success, false on failure
(define-sdl SDL-RaiseWindow (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_RaiseWindow)

;; SDL_MaximizeWindow: Make a window as large as possible
;; window: The window to maximize
;; Returns: true on success, false on failure
(define-sdl SDL-MaximizeWindow (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_MaximizeWindow)

;; SDL_MinimizeWindow: Minimize a window to an iconic representation
;; window: The window to minimize
;; Returns: true on success, false on failure
(define-sdl SDL-MinimizeWindow (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_MinimizeWindow)

;; SDL_RestoreWindow: Restore the size and position of a minimized/maximized window
;; window: The window to restore
;; Returns: true on success, false on failure
(define-sdl SDL-RestoreWindow (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_RestoreWindow)

;; SDL_SetWindowMinimumSize: Set the minimum size of a window's client area
;; window: The window to set the minimum size on
;; min_w, min_h: The minimum width and height
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowMinimumSize
  (_fun _SDL_Window-pointer _int _int -> _sdl-bool)
  #:c-id SDL_SetWindowMinimumSize)

;; SDL_GetWindowMinimumSize: Get the minimum size of a window's client area
;; window: The window to query
;; Returns: (values success? width height)
(define-sdl SDL-GetWindowMinimumSize
  (_fun _SDL_Window-pointer
        (w : (_ptr o _int))
        (h : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result w h))
  #:c-id SDL_GetWindowMinimumSize)

;; SDL_SetWindowMaximumSize: Set the maximum size of a window's client area
;; window: The window to set the maximum size on
;; max_w, max_h: The maximum width and height
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowMaximumSize
  (_fun _SDL_Window-pointer _int _int -> _sdl-bool)
  #:c-id SDL_SetWindowMaximumSize)

;; SDL_GetWindowMaximumSize: Get the maximum size of a window's client area
;; window: The window to query
;; Returns: (values success? width height)
(define-sdl SDL-GetWindowMaximumSize
  (_fun _SDL_Window-pointer
        (w : (_ptr o _int))
        (h : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result w h))
  #:c-id SDL_GetWindowMaximumSize)

;; SDL_SetWindowBordered: Set the border state of a window
;; window: The window to modify
;; bordered: true to add a border, false to remove it
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowBordered (_fun _SDL_Window-pointer _bool -> _sdl-bool)
  #:c-id SDL_SetWindowBordered)

;; SDL_SetWindowResizable: Set the resizable state of a window
;; window: The window to modify
;; resizable: true to allow resizing, false to disallow
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowResizable (_fun _SDL_Window-pointer _bool -> _sdl-bool)
  #:c-id SDL_SetWindowResizable)

;; SDL_SetWindowOpacity: Set the opacity of a window
;; window: The window to set the opacity on
;; opacity: The opacity value (0.0 to 1.0)
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowOpacity (_fun _SDL_Window-pointer _float -> _sdl-bool)
  #:c-id SDL_SetWindowOpacity)

;; SDL_GetWindowOpacity: Get the opacity of a window
;; window: The window to query
;; Returns: The opacity (0.0 to 1.0), or -1.0 on failure
(define-sdl SDL-GetWindowOpacity (_fun _SDL_Window-pointer -> _float)
  #:c-id SDL_GetWindowOpacity)

;; SDL_FlashWindow: Request a window to demand attention from the user
;; window: The window to flash
;; operation: The flash operation (SDL_FLASH_CANCEL, SDL_FLASH_BRIEFLY, SDL_FLASH_UNTIL_FOCUSED)
;; Returns: true on success, false on failure
(define-sdl SDL-FlashWindow (_fun _SDL_Window-pointer _SDL_FlashOperation -> _sdl-bool)
  #:c-id SDL_FlashWindow)

;; SDL_GetWindowSurface: Get the SDL surface associated with a window
;; window: The window to query
;; Returns: The surface associated with the window, or NULL on failure
;; Note: You cannot use a renderer and GetWindowSurface on the same window
(define-sdl SDL-GetWindowSurface (_fun _SDL_Window-pointer -> _SDL_Surface-pointer/null)
  #:c-id SDL_GetWindowSurface)

;; SDL_UpdateWindowSurface: Copy the window surface to the screen
;; window: The window to update
;; Returns: true on success, false on failure
(define-sdl SDL-UpdateWindowSurface (_fun _SDL_Window-pointer -> _sdl-bool)
  #:c-id SDL_UpdateWindowSurface)

;; ============================================================================
;; Mouse
;; ============================================================================

;; SDL_GetMouseState: Get the current state of the mouse
;; x: pointer to receive x position (can be NULL)
;; y: pointer to receive y position (can be NULL)
;; Returns: SDL_MouseButtonFlags bitmask of button states
(define-sdl SDL-GetMouseState
  (_fun _pointer _pointer -> _uint32)
  #:c-id SDL_GetMouseState)

;; SDL_GetRelativeMouseState: Get the relative mouse state (delta since last call)
;; Returns: (values buttons dx dy) - button flags and relative motion
(define-sdl SDL-GetRelativeMouseState
  (_fun (x : (_ptr o _float))
        (y : (_ptr o _float))
        -> (buttons : _uint32)
        -> (values buttons x y))
  #:c-id SDL_GetRelativeMouseState)

;; SDL_SetWindowRelativeMouseMode: Enable/disable relative mouse mode for a window
;; window: the window to set
;; enabled: true to enable relative mode (hides cursor, captures mouse)
;; Returns: true on success, false on failure
(define-sdl SDL-SetWindowRelativeMouseMode
  (_fun _SDL_Window-pointer _bool -> _sdl-bool)
  #:c-id SDL_SetWindowRelativeMouseMode)

;; SDL_GetWindowRelativeMouseMode: Get the relative mouse mode state for a window
;; window: the window to query
;; Returns: true if relative mode is enabled
(define-sdl SDL-GetWindowRelativeMouseMode
  (_fun _SDL_Window-pointer -> _bool)
  #:c-id SDL_GetWindowRelativeMouseMode)

;; ============================================================================
;; Cursor
;; ============================================================================

;; SDL_CreateSystemCursor: Create a system cursor
;; id: SDL_SystemCursor enum value
;; Returns: cursor pointer, or NULL on failure
(define-sdl SDL-CreateSystemCursor
  (_fun _SDL_SystemCursor -> _SDL_Cursor-pointer/null)
  #:c-id SDL_CreateSystemCursor)

;; SDL_SetCursor: Set the active cursor
;; cursor: cursor to set, or NULL to use default
;; Returns: true on success, false on failure
(define-sdl SDL-SetCursor
  (_fun _SDL_Cursor-pointer/null -> _sdl-bool)
  #:c-id SDL_SetCursor)

;; SDL_GetCursor: Get the active cursor
;; Returns: the active cursor, or NULL if no custom cursor is set
(define-sdl SDL-GetCursor
  (_fun -> _SDL_Cursor-pointer/null)
  #:c-id SDL_GetCursor)

;; SDL_DestroyCursor: Free a cursor created with SDL_CreateSystemCursor
;; cursor: the cursor to destroy
(define-sdl SDL-DestroyCursor
  (_fun _SDL_Cursor-pointer -> _void)
  #:c-id SDL_DestroyCursor)

;; SDL_ShowCursor: Show the cursor
;; Returns: true on success, false on failure
(define-sdl SDL-ShowCursor
  (_fun -> _sdl-bool)
  #:c-id SDL_ShowCursor)

;; SDL_HideCursor: Hide the cursor
;; Returns: true on success, false on failure
(define-sdl SDL-HideCursor
  (_fun -> _sdl-bool)
  #:c-id SDL_HideCursor)

;; SDL_CursorVisible: Check if the cursor is visible
;; Returns: true if the cursor is visible
(define-sdl SDL-CursorVisible
  (_fun -> _bool)
  #:c-id SDL_CursorVisible)

;; ============================================================================
;; Timer
;; ============================================================================

;; SDL_GetTicks: Get the number of milliseconds since SDL library initialization
;; Returns: Uint64 milliseconds since SDL_Init was called
(define-sdl SDL-GetTicks (_fun -> _uint64)
  #:c-id SDL_GetTicks)

;; SDL_GetTicksNS: Get the number of nanoseconds since SDL library initialization
;; Returns: Uint64 nanoseconds since SDL_Init was called
(define-sdl SDL-GetTicksNS (_fun -> _uint64)
  #:c-id SDL_GetTicksNS)

;; SDL_GetPerformanceCounter: Get the current value of the high resolution counter
;; Use for profiling. Values are only meaningful relative to each other.
;; Convert differences to time using SDL_GetPerformanceFrequency.
;; Returns: Uint64 current counter value
(define-sdl SDL-GetPerformanceCounter (_fun -> _uint64)
  #:c-id SDL_GetPerformanceCounter)

;; SDL_GetPerformanceFrequency: Get the count per second of the high resolution counter
;; Returns: Uint64 platform-specific counts per second
(define-sdl SDL-GetPerformanceFrequency (_fun -> _uint64)
  #:c-id SDL_GetPerformanceFrequency)

;; SDL_Delay: Wait a specified number of milliseconds before returning
;; ms: The number of milliseconds to delay
(define-sdl SDL-Delay (_fun _uint32 -> _void)
  #:c-id SDL_Delay)

;; SDL_DelayNS: Wait a specified number of nanoseconds before returning
;; ns: The number of nanoseconds to delay
(define-sdl SDL-DelayNS (_fun _uint64 -> _void)
  #:c-id SDL_DelayNS)

;; SDL_DelayPrecise: Wait a specified number of nanoseconds with busy-waiting
;; More precise than SDL_DelayNS, but uses more CPU. Good for frame timing.
;; ns: The number of nanoseconds to delay
(define-sdl SDL-DelayPrecise (_fun _uint64 -> _void)
  #:c-id SDL_DelayPrecise)

;; ============================================================================
;; Clipboard
;; ============================================================================

;; SDL_SetClipboardText: Put UTF-8 text into the clipboard
;; text: the text to store in the clipboard
;; Returns: true on success, false on failure
(define-sdl SDL-SetClipboardText
  (_fun _string/utf-8 -> _sdl-bool)
  #:c-id SDL_SetClipboardText)

;; SDL_GetClipboardText: Get UTF-8 text from the clipboard
;; Returns: pointer to clipboard text (must be freed with SDL_free)
;; Note: Returns empty string if clipboard is empty or on error
(define-sdl SDL-GetClipboardText
  (_fun -> _pointer)
  #:c-id SDL_GetClipboardText)

;; SDL_HasClipboardText: Query whether the clipboard has text
;; Returns: true if the clipboard has text, false otherwise
(define-sdl SDL-HasClipboardText
  (_fun -> _bool)
  #:c-id SDL_HasClipboardText)

;; ============================================================================
;; Memory Management
;; ============================================================================

;; SDL_free: Free memory allocated by SDL functions
;; Use this to free pointers returned by SDL_GetClipboardText, etc.
(define-sdl SDL-free
  (_fun _pointer -> _void)
  #:c-id SDL_free)

;; ============================================================================
;; Audio - Drivers
;; ============================================================================

;; SDL_GetNumAudioDrivers: Get the number of built-in audio drivers
;; Returns: the number of built-in audio drivers
(define-sdl SDL-GetNumAudioDrivers
  (_fun -> _int)
  #:c-id SDL_GetNumAudioDrivers)

;; SDL_GetAudioDriver: Get the name of a built-in audio driver by index
;; index: the index of the audio driver (0 to SDL_GetNumAudioDrivers()-1)
;; Returns: the name of the audio driver, or NULL if invalid index
(define-sdl SDL-GetAudioDriver
  (_fun _int -> _string/utf-8)
  #:c-id SDL_GetAudioDriver)

;; SDL_GetCurrentAudioDriver: Get the name of the current audio driver
;; Returns: the name of the current audio driver, or NULL if not initialized
(define-sdl SDL-GetCurrentAudioDriver
  (_fun -> _string/utf-8)
  #:c-id SDL_GetCurrentAudioDriver)

;; ============================================================================
;; Audio - Device Enumeration
;; ============================================================================

;; SDL_GetAudioPlaybackDevices: Get a list of audio playback devices
;; Returns: (values device-ids count) - array pointer and count, free with SDL_free
;; The returned pointer is a 0-terminated array of SDL_AudioDeviceID values
(define-sdl SDL-GetAudioPlaybackDevices
  (_fun (count : (_ptr o _int))
        -> (result : _pointer)
        -> (values result count))
  #:c-id SDL_GetAudioPlaybackDevices)

;; SDL_GetAudioRecordingDevices: Get a list of audio recording devices
;; Returns: (values device-ids count) - array pointer and count, free with SDL_free
;; The returned pointer is a 0-terminated array of SDL_AudioDeviceID values
(define-sdl SDL-GetAudioRecordingDevices
  (_fun (count : (_ptr o _int))
        -> (result : _pointer)
        -> (values result count))
  #:c-id SDL_GetAudioRecordingDevices)

;; SDL_GetAudioDeviceName: Get the human-readable name of an audio device
;; devid: the device instance ID to query
;; Returns: the name of the audio device, or NULL on failure
(define-sdl SDL-GetAudioDeviceName
  (_fun _SDL_AudioDeviceID -> _string/utf-8)
  #:c-id SDL_GetAudioDeviceName)

;; ============================================================================
;; Audio - Device Control
;; ============================================================================

;; SDL_OpenAudioDevice: Open an audio device for playback or recording
;; devid: device ID, or SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK/RECORDING for default
;; spec: the desired audio format (can be NULL for reasonable defaults)
;; Returns: the device ID on success, or 0 on failure
(define-sdl SDL-OpenAudioDevice
  (_fun _SDL_AudioDeviceID _SDL_AudioSpec-pointer/null -> _SDL_AudioDeviceID)
  #:c-id SDL_OpenAudioDevice)

;; SDL_CloseAudioDevice: Close a previously opened audio device
;; devid: the audio device to close
(define-sdl SDL-CloseAudioDevice
  (_fun _SDL_AudioDeviceID -> _void)
  #:c-id SDL_CloseAudioDevice)

;; SDL_PauseAudioDevice: Pause audio playback on a device
;; devid: the device to pause
;; Returns: true on success, false on failure
(define-sdl SDL-PauseAudioDevice
  (_fun _SDL_AudioDeviceID -> _sdl-bool)
  #:c-id SDL_PauseAudioDevice)

;; SDL_ResumeAudioDevice: Resume audio playback on a device
;; devid: the device to resume
;; Returns: true on success, false on failure
(define-sdl SDL-ResumeAudioDevice
  (_fun _SDL_AudioDeviceID -> _sdl-bool)
  #:c-id SDL_ResumeAudioDevice)

;; SDL_AudioDevicePaused: Check if an audio device is paused
;; devid: the device to query
;; Returns: true if the device is paused, false otherwise
(define-sdl SDL-AudioDevicePaused
  (_fun _SDL_AudioDeviceID -> _bool)
  #:c-id SDL_AudioDevicePaused)

;; ============================================================================
;; Audio - Streams
;; ============================================================================

;; SDL_CreateAudioStream: Create an audio stream for format conversion
;; src-spec: the format of the source audio
;; dst-spec: the format of the desired output audio
;; Returns: a new audio stream, or NULL on failure
(define-sdl SDL-CreateAudioStream
  (_fun _SDL_AudioSpec-pointer _SDL_AudioSpec-pointer -> _SDL_AudioStream-pointer/null)
  #:c-id SDL_CreateAudioStream)

;; SDL_DestroyAudioStream: Destroy an audio stream
;; stream: the audio stream to destroy
(define-sdl SDL-DestroyAudioStream
  (_fun _SDL_AudioStream-pointer -> _void)
  #:c-id SDL_DestroyAudioStream)

;; SDL_GetAudioStreamFormat: Get the current input and output formats of an audio stream
;; stream: the audio stream to query
;; src-spec: pointer to receive input format (can be NULL)
;; dst-spec: pointer to receive output format (can be NULL)
;; Returns: true on success, false on failure
(define-sdl SDL-GetAudioStreamFormat
  (_fun _SDL_AudioStream-pointer
        _SDL_AudioSpec-pointer/null
        _SDL_AudioSpec-pointer/null
        -> _sdl-bool)
  #:c-id SDL_GetAudioStreamFormat)

;; SDL_SetAudioStreamFormat: Change the input and output formats of an audio stream
;; stream: the audio stream to modify
;; src-spec: the new input format (can be NULL to leave unchanged)
;; dst-spec: the new output format (can be NULL to leave unchanged)
;; Returns: true on success, false on failure
(define-sdl SDL-SetAudioStreamFormat
  (_fun _SDL_AudioStream-pointer
        _SDL_AudioSpec-pointer/null
        _SDL_AudioSpec-pointer/null
        -> _sdl-bool)
  #:c-id SDL_SetAudioStreamFormat)

;; SDL_PutAudioStreamData: Add data to the stream for processing
;; stream: the audio stream
;; buf: pointer to the audio data to add
;; len: the number of bytes to write
;; Returns: true on success, false on failure
(define-sdl SDL-PutAudioStreamData
  (_fun _SDL_AudioStream-pointer _pointer _int -> _sdl-bool)
  #:c-id SDL_PutAudioStreamData)

;; SDL_GetAudioStreamData: Get converted audio data from the stream
;; stream: the audio stream
;; buf: buffer to receive the converted audio data
;; len: maximum number of bytes to read
;; Returns: number of bytes read, or -1 on failure
(define-sdl SDL-GetAudioStreamData
  (_fun _SDL_AudioStream-pointer _pointer _int -> _int)
  #:c-id SDL_GetAudioStreamData)

;; SDL_GetAudioStreamAvailable: Get the number of bytes available in the stream
;; stream: the audio stream to query
;; Returns: number of converted bytes available, or -1 on failure
(define-sdl SDL-GetAudioStreamAvailable
  (_fun _SDL_AudioStream-pointer -> _int)
  #:c-id SDL_GetAudioStreamAvailable)

;; SDL_FlushAudioStream: Flush remaining data from the stream
;; Forces any pending data through the conversion process.
;; stream: the audio stream to flush
;; Returns: true on success, false on failure
(define-sdl SDL-FlushAudioStream
  (_fun _SDL_AudioStream-pointer -> _sdl-bool)
  #:c-id SDL_FlushAudioStream)

;; SDL_ClearAudioStream: Clear all data from the stream without processing
;; stream: the audio stream to clear
;; Returns: true on success, false on failure
(define-sdl SDL-ClearAudioStream
  (_fun _SDL_AudioStream-pointer -> _sdl-bool)
  #:c-id SDL_ClearAudioStream)

;; SDL_BindAudioStream: Bind an audio stream to a device for playback
;; devid: the audio device to bind to
;; stream: the audio stream to bind
;; Returns: true on success, false on failure
(define-sdl SDL-BindAudioStream
  (_fun _SDL_AudioDeviceID _SDL_AudioStream-pointer -> _sdl-bool)
  #:c-id SDL_BindAudioStream)

;; SDL_UnbindAudioStream: Unbind an audio stream from its device
;; stream: the audio stream to unbind
(define-sdl SDL-UnbindAudioStream
  (_fun _SDL_AudioStream-pointer -> _void)
  #:c-id SDL_UnbindAudioStream)

;; ============================================================================
;; Audio - WAV Loading
;; ============================================================================

;; SDL_LoadWAV: Load a WAV file from disk
;; path: the file path to load
;; spec: pointer to SDL_AudioSpec to receive the audio format
;; audio_buf: pointer to receive the audio data buffer (free with SDL_free)
;; audio_len: pointer to receive the length in bytes
;; Returns: true on success, false on failure
(define-sdl SDL-LoadWAV
  (_fun _string/utf-8
        _SDL_AudioSpec-pointer
        (audio_buf : (_ptr o _pointer))
        (audio_len : (_ptr o _uint32))
        -> (result : _sdl-bool)
        -> (values result audio_buf audio_len))
  #:c-id SDL_LoadWAV)
