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
         ;; Renderer
         SDL-CreateRenderer
         SDL-DestroyRenderer
         SDL-SetRenderDrawColor
         SDL-RenderClear
         SDL-RenderPresent
         ;; Texture
         SDL-DestroyTexture
         SDL-RenderTexture
         SDL-GetTextureSize
         ;; Events
         SDL-PollEvent
         ;; Keyboard
         SDL-GetKeyName
         ;; Timer
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

;; SDL_GetTextureSize: Query texture dimensions
;; texture: the texture to query
;; w, h: pointers to receive width and height (can be NULL)
;; Returns: true on success, false on failure
(define-sdl SDL-GetTextureSize
  (_fun _SDL_Texture-pointer _pointer _pointer -> _sdl-bool)
  #:c-id SDL_GetTextureSize)

;; ============================================================================
;; Events
;; ============================================================================

;; SDL_PollEvent: Poll for currently pending events
;; event: Pointer to an SDL_Event structure (at least 128 bytes)
;; Returns: true if there is a pending event, false otherwise
(define-sdl SDL-PollEvent (_fun _pointer -> _sdl-bool)
  #:c-id SDL_PollEvent)

;; ============================================================================
;; Keyboard
;; ============================================================================

;; SDL_GetKeyName: Get a human-readable name for a key
;; key: SDL_Keycode value
;; Returns: A human-readable key name string
(define-sdl SDL-GetKeyName (_fun _SDL_Keycode -> _string)
  #:c-id SDL_GetKeyName)

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
;; Timer
;; ============================================================================

;; SDL_Delay: Wait a specified number of milliseconds before returning
;; ms: The number of milliseconds to delay
(define-sdl SDL-Delay (_fun _uint32 -> _void)
  #:c-id SDL_Delay)
