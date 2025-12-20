#lang racket/base

;; SDL3 Initialization and Error Handling
;;
;; Core functions for initializing SDL subsystems and retrieving errors.

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide SDL-Init
         SDL-InitSubSystem
         SDL-QuitSubSystem
         SDL-WasInit
         SDL-SetAppMetadata
         SDL-SetAppMetadataProperty
         SDL-GetAppMetadataProperty
         SDL-Quit
         SDL-GetError
         SDL-free)

;; ============================================================================
;; Initialization
;; ============================================================================

;; SDL_Init: Initialize the SDL library
;; flags: SDL_InitFlags bitmask specifying subsystems to initialize
;; Returns: true on success, false on failure
(define-sdl SDL-Init (_fun _SDL_InitFlags -> _sdl-bool)
  #:c-id SDL_Init)

;; SDL_InitSubSystem: Initialize specific SDL subsystems
;; flags: SDL_InitFlags bitmask
;; Returns: true on success, false on failure
(define-sdl SDL-InitSubSystem (_fun _SDL_InitFlags -> _sdl-bool)
  #:c-id SDL_InitSubSystem)

;; SDL_QuitSubSystem: Shut down specific SDL subsystems
;; flags: SDL_InitFlags bitmask
(define-sdl SDL-QuitSubSystem (_fun _SDL_InitFlags -> _void)
  #:c-id SDL_QuitSubSystem)

;; SDL_WasInit: Query initialized subsystems
;; flags: SDL_InitFlags bitmask to check
;; Returns: flags that are initialized
(define-sdl SDL-WasInit (_fun _SDL_InitFlags -> _SDL_InitFlags)
  #:c-id SDL_WasInit)

;; SDL_SetAppMetadata: Set basic app metadata
;; Returns: true on success, false on failure
(define-sdl SDL-SetAppMetadata (_fun _string/utf-8 _string/utf-8 _string/utf-8 -> _sdl-bool)
  #:c-id SDL_SetAppMetadata)

;; SDL_SetAppMetadataProperty: Set metadata key/value
;; Returns: true on success, false on failure
(define-sdl SDL-SetAppMetadataProperty (_fun _string/utf-8 _string/utf-8 -> _sdl-bool)
  #:c-id SDL_SetAppMetadataProperty)

;; SDL_GetAppMetadataProperty: Get metadata value
;; Returns: string or #f
(define-sdl SDL-GetAppMetadataProperty (_fun _string -> _string/utf-8)
  #:c-id SDL_GetAppMetadataProperty)

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
;; Memory Management
;; ============================================================================

;; SDL_free: Free memory allocated by SDL functions
;; Use this to free pointers returned by SDL_GetClipboardText, etc.
(define-sdl SDL-free
  (_fun _pointer -> _void)
  #:c-id SDL_free)
