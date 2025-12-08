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
         SDL-DestroyWindow
         SDL-SetWindowTitle
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
         ;; Texture
         SDL-DestroyTexture
         SDL-RenderTexture
         SDL-RenderTextureRotated
         SDL-GetTextureSize
         SDL-CreateTextureFromSurface
         ;; Drawing primitives
         SDL-RenderPoint
         SDL-RenderPoints
         SDL-RenderLine
         SDL-RenderLines
         SDL-RenderRect
         SDL-RenderRects
         SDL-RenderFillRect
         SDL-RenderFillRects
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
         ;; Timer
         SDL-GetTicks
         SDL-Delay)

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

;; ============================================================================
;; Timer
;; ============================================================================

;; SDL_GetTicks: Get the number of milliseconds since SDL library initialization
;; Returns: Uint64 milliseconds since SDL_Init was called
(define-sdl SDL-GetTicks (_fun -> _uint64)
  #:c-id SDL_GetTicks)

;; SDL_Delay: Wait a specified number of milliseconds before returning
;; ms: The number of milliseconds to delay
(define-sdl SDL-Delay (_fun _uint32 -> _void)
  #:c-id SDL_Delay)
