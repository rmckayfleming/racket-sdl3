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
         ;; Event conversion helpers
         event->joy-axis
         event->joy-button
         event->joy-hat
         event->joy-device
         event->gamepad-axis
         event->gamepad-button
         event->gamepad-device
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

;; SDL_AudioDeviceID - audio device instance ID (uint32)
;; Zero signifies an invalid/null device
(define _SDL_AudioDeviceID _uint32)

;; SDL_KeyboardID - keyboard instance ID (uint32)
(define _SDL_KeyboardID _uint32)

;; SDL_MouseID - mouse instance ID (uint32)
(define _SDL_MouseID _uint32)

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
