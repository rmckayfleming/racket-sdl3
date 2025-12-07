#lang racket/base

(require ffi/unsafe)

(provide check-sdl-bool
         _sdl-bool
         ;; Init flags
         _SDL_InitFlags
         SDL_INIT_VIDEO
         ;; Window flags
         _SDL_WindowFlags
         SDL_WINDOW_RESIZABLE
         ;; Pointer types
         _SDL_Window-pointer
         _SDL_Window-pointer/null
         _SDL_Renderer-pointer
         _SDL_Renderer-pointer/null
         _SDL_Texture-pointer
         _SDL_Texture-pointer/null
         ;; Rect structs
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
         ;; Event constants
         SDL_EVENT_QUIT
         ;; Window events
         SDL_EVENT_WINDOW_SHOWN
         SDL_EVENT_WINDOW_HIDDEN
         SDL_EVENT_WINDOW_EXPOSED
         SDL_EVENT_WINDOW_MOVED
         SDL_EVENT_WINDOW_RESIZED
         SDL_EVENT_WINDOW_FOCUS_GAINED
         SDL_EVENT_WINDOW_FOCUS_LOST
         SDL_EVENT_WINDOW_CLOSE_REQUESTED
         ;; Keyboard events
         SDL_EVENT_KEY_DOWN
         SDL_EVENT_KEY_UP
         ;; Mouse events
         SDL_EVENT_MOUSE_MOTION
         SDL_EVENT_MOUSE_BUTTON_DOWN
         SDL_EVENT_MOUSE_BUTTON_UP
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
         SDL_KeyboardEvent-state
         SDL_KeyboardEvent-repeat
         SDL_KeyboardEvent-mod
         SDL_KeyboardEvent-scancode
         SDL_KeyboardEvent-key
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
         ;; Event union helpers
         SDL_EVENT_SIZE
         sdl-event-type
         event->keyboard
         event->mouse-motion
         event->mouse-button
         ;; Key constants
         SDLK_ESCAPE
         SDLK_R
         SDLK_G
         SDLK_B
         SDLK_SPACE
         SDLK_r
         SDLK_g
         SDLK_b
         ;; Arrow keys
         SDLK_RIGHT
         SDLK_LEFT
         SDLK_DOWN
         SDLK_UP
         ;; Keycode type
         _SDL_Keycode
         ;; Error handling forward reference
         sdl-get-error-proc)

;; SDL3 types, enums, and structs
;; This file will be expanded with SDL3 type definitions as bindings are added.

;; SDL3 boolean type - SDL3 uses C99 bool (not int like SDL2)
(define _sdl-bool _bool)

;; ============================================================================
;; Init Flags (SDL_InitFlags) - used with SDL_Init
;; ============================================================================
(define SDL_INIT_VIDEO #x00000020)

;; SDL_InitFlags is a 32-bit unsigned integer (flags can be combined with bitwise-ior)
(define _SDL_InitFlags _uint32)

;; ============================================================================
;; Window Flags (SDL_WindowFlags) - 64-bit in SDL3
;; ============================================================================
(define SDL_WINDOW_RESIZABLE #x0000000000000020)

;; SDL_WindowFlags is a 64-bit unsigned integer in SDL3 (flags can be combined with bitwise-ior)
(define _SDL_WindowFlags _uint64)

;; ============================================================================
;; Pointer Types
;; ============================================================================
(define-cpointer-type _SDL_Window-pointer)
(define-cpointer-type _SDL_Renderer-pointer)
(define-cpointer-type _SDL_Texture-pointer)

;; ============================================================================
;; Rectangle Structs
;; ============================================================================

;; SDL_FRect - floating point rectangle (preferred in SDL3 for rendering)
(define-cstruct _SDL_FRect
  ([x _float]
   [y _float]
   [w _float]
   [h _float]))

;; ============================================================================
;; Event Constants
;; ============================================================================
(define SDL_EVENT_QUIT #x100)
;; Window events
(define SDL_EVENT_WINDOW_SHOWN #x202)
(define SDL_EVENT_WINDOW_HIDDEN #x203)
(define SDL_EVENT_WINDOW_EXPOSED #x204)
(define SDL_EVENT_WINDOW_MOVED #x205)
(define SDL_EVENT_WINDOW_RESIZED #x206)
(define SDL_EVENT_WINDOW_FOCUS_GAINED #x209)
(define SDL_EVENT_WINDOW_FOCUS_LOST #x20A)
(define SDL_EVENT_WINDOW_CLOSE_REQUESTED #x212)
;; Keyboard events
(define SDL_EVENT_KEY_DOWN #x300)
(define SDL_EVENT_KEY_UP #x301)
;; Mouse events
(define SDL_EVENT_MOUSE_MOTION #x400)
(define SDL_EVENT_MOUSE_BUTTON_DOWN #x401)
(define SDL_EVENT_MOUSE_BUTTON_UP #x402)

;; ============================================================================
;; Key Constants (SDL_Keycode values)
;; ============================================================================
;; SDL3 keycodes are mostly ASCII for letter/number keys
(define SDLK_ESCAPE 27)      ; '\x1B'
(define SDLK_SPACE 32)
(define SDLK_R 82)           ; uppercase 'R'
(define SDLK_G 71)           ; uppercase 'G'
(define SDLK_B 66)           ; uppercase 'B'
(define SDLK_r 114)          ; lowercase 'r'
(define SDLK_g 103)          ; lowercase 'g'
(define SDLK_b 98)           ; lowercase 'b'

;; Arrow keys use scancodes with SDLK_SCANCODE_MASK (0x40000000)
(define SDLK_RIGHT #x4000004F)
(define SDLK_LEFT  #x40000050)
(define SDLK_DOWN  #x40000051)
(define SDLK_UP    #x40000052)

;; SDL_Keycode type (32-bit)
(define _SDL_Keycode _uint32)

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
   [state _uint8]
   [repeat _uint8]
   [padding2 _uint8]
   [padding3 _uint8]
   [mod _uint16]
   [scancode _uint32]
   [key _uint32]))

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

;; SDL_Event union size (128 bytes in SDL3)
(define SDL_EVENT_SIZE 128)

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
