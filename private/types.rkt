#lang racket/base

(require ffi/unsafe)

(provide check-sdl-bool
         _sdl-bool
         ;; Init flags
         _SDL_InitFlags
         SDL_INIT_VIDEO
         ;; Window flags
         _SDL_WindowFlags
         SDL_WINDOW_FULLSCREEN
         SDL_WINDOW_RESIZABLE
         SDL_WINDOW_HIGH_PIXEL_DENSITY
         ;; Pointer types
         _SDL_Window-pointer
         _SDL_Window-pointer/null
         _SDL_Renderer-pointer
         _SDL_Renderer-pointer/null
         _SDL_Texture-pointer
         _SDL_Texture-pointer/null
         _SDL_Surface-pointer
         _SDL_Surface-pointer/null
         _SDL_Cursor-pointer
         _SDL_Cursor-pointer/null
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
         ;; Text input
         SDL_EVENT_TEXT_INPUT
         ;; Mouse events
         SDL_EVENT_MOUSE_MOTION
         SDL_EVENT_MOUSE_BUTTON_DOWN
         SDL_EVENT_MOUSE_BUTTON_UP
         SDL_EVENT_MOUSE_WHEEL
         ;; Mouse wheel direction
         SDL_MOUSEWHEEL_NORMAL
         SDL_MOUSEWHEEL_FLIPPED
         ;; Mouse button constants
         SDL_BUTTON_LEFT
         SDL_BUTTON_MIDDLE
         SDL_BUTTON_RIGHT
         SDL_BUTTON_X1
         SDL_BUTTON_X2
         SDL_BUTTON_LMASK
         SDL_BUTTON_MMASK
         SDL_BUTTON_RMASK
         SDL_BUTTON_X1MASK
         SDL_BUTTON_X2MASK
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
         ;; Event union helpers
         SDL_EVENT_SIZE
         sdl-event-type
         event->keyboard
         event->mouse-motion
         event->mouse-button
         event->text-input
         event->mouse-wheel
         ;; Key constants - Special keys
         SDLK_UNKNOWN SDLK_RETURN SDLK_ESCAPE SDLK_BACKSPACE SDLK_TAB SDLK_SPACE
         ;; Punctuation and symbols
         SDLK_EXCLAIM SDLK_DBLAPOSTROPHE SDLK_HASH SDLK_DOLLAR SDLK_PERCENT
         SDLK_AMPERSAND SDLK_APOSTROPHE SDLK_LEFTPAREN SDLK_RIGHTPAREN
         SDLK_ASTERISK SDLK_PLUS SDLK_COMMA SDLK_MINUS SDLK_PERIOD SDLK_SLASH
         ;; Number keys
         SDLK_0 SDLK_1 SDLK_2 SDLK_3 SDLK_4
         SDLK_5 SDLK_6 SDLK_7 SDLK_8 SDLK_9
         ;; More punctuation
         SDLK_COLON SDLK_SEMICOLON SDLK_LESS SDLK_EQUALS SDLK_GREATER
         SDLK_QUESTION SDLK_AT SDLK_LEFTBRACKET SDLK_BACKSLASH
         SDLK_RIGHTBRACKET SDLK_CARET SDLK_UNDERSCORE SDLK_GRAVE
         ;; Letter keys
         SDLK_A SDLK_B SDLK_C SDLK_D SDLK_E SDLK_F SDLK_G
         SDLK_H SDLK_I SDLK_J SDLK_K SDLK_L SDLK_M SDLK_N
         SDLK_O SDLK_P SDLK_Q SDLK_R SDLK_S SDLK_T SDLK_U
         SDLK_V SDLK_W SDLK_X SDLK_Y SDLK_Z
         ;; More punctuation (after letters)
         SDLK_LEFTBRACE SDLK_PIPE SDLK_RIGHTBRACE SDLK_TILDE SDLK_DELETE
         ;; Lock keys
         SDLK_CAPSLOCK SDLK_SCROLLLOCK SDLK_NUMLOCKCLEAR
         ;; Function keys F1-F12
         SDLK_F1 SDLK_F2 SDLK_F3 SDLK_F4 SDLK_F5 SDLK_F6
         SDLK_F7 SDLK_F8 SDLK_F9 SDLK_F10 SDLK_F11 SDLK_F12
         ;; Function keys F13-F24
         SDLK_F13 SDLK_F14 SDLK_F15 SDLK_F16 SDLK_F17 SDLK_F18
         SDLK_F19 SDLK_F20 SDLK_F21 SDLK_F22 SDLK_F23 SDLK_F24
         ;; Print/Pause
         SDLK_PRINTSCREEN SDLK_PAUSE
         ;; Navigation keys
         SDLK_INSERT SDLK_HOME SDLK_PAGEUP SDLK_END SDLK_PAGEDOWN
         ;; Arrow keys
         SDLK_RIGHT SDLK_LEFT SDLK_DOWN SDLK_UP
         ;; Keypad numbers
         SDLK_KP_0 SDLK_KP_1 SDLK_KP_2 SDLK_KP_3 SDLK_KP_4
         SDLK_KP_5 SDLK_KP_6 SDLK_KP_7 SDLK_KP_8 SDLK_KP_9
         ;; Keypad operators
         SDLK_KP_DIVIDE SDLK_KP_MULTIPLY SDLK_KP_MINUS SDLK_KP_PLUS
         SDLK_KP_ENTER SDLK_KP_PERIOD SDLK_KP_EQUALS
         ;; Application/Menu
         SDLK_APPLICATION SDLK_MENU
         ;; Editing keys
         SDLK_UNDO SDLK_CUT SDLK_COPY SDLK_PASTE SDLK_FIND
         ;; Media keys
         SDLK_MUTE SDLK_VOLUMEUP SDLK_VOLUMEDOWN
         ;; Modifier keycodes
         SDLK_LCTRL SDLK_LSHIFT SDLK_LALT SDLK_LGUI
         SDLK_RCTRL SDLK_RSHIFT SDLK_RALT SDLK_RGUI
         ;; Keycode type
         _SDL_Keycode
         ;; Modifier key masks
         SDL_KMOD_NONE
         SDL_KMOD_LSHIFT
         SDL_KMOD_RSHIFT
         SDL_KMOD_LCTRL
         SDL_KMOD_RCTRL
         SDL_KMOD_LALT
         SDL_KMOD_RALT
         SDL_KMOD_LGUI
         SDL_KMOD_RGUI
         SDL_KMOD_NUM
         SDL_KMOD_CAPS
         SDL_KMOD_MODE
         SDL_KMOD_SCROLL
         SDL_KMOD_CTRL
         SDL_KMOD_SHIFT
         SDL_KMOD_ALT
         SDL_KMOD_GUI
         ;; Blend mode
         _SDL_BlendMode
         SDL_BLENDMODE_NONE
         SDL_BLENDMODE_BLEND
         SDL_BLENDMODE_BLEND_PREMULTIPLIED
         SDL_BLENDMODE_ADD
         SDL_BLENDMODE_ADD_PREMULTIPLIED
         SDL_BLENDMODE_MOD
         SDL_BLENDMODE_MUL
         SDL_BLENDMODE_INVALID
         ;; Flip mode
         _SDL_FlipMode
         SDL_FLIP_NONE
         SDL_FLIP_HORIZONTAL
         SDL_FLIP_VERTICAL
         ;; Texture access modes
         _SDL_TextureAccess
         SDL_TEXTUREACCESS_STATIC
         SDL_TEXTUREACCESS_STREAMING
         SDL_TEXTUREACCESS_TARGET
         ;; Scale modes
         _SDL_ScaleMode
         SDL_SCALEMODE_INVALID
         SDL_SCALEMODE_NEAREST
         SDL_SCALEMODE_LINEAR
         ;; Pixel formats (commonly used)
         _SDL_PixelFormat
         SDL_PIXELFORMAT_UNKNOWN
         SDL_PIXELFORMAT_RGBA8888
         SDL_PIXELFORMAT_ARGB8888
         SDL_PIXELFORMAT_ABGR8888
         SDL_PIXELFORMAT_BGRA8888
         ;; System cursor types
         _SDL_SystemCursor
         SDL_SYSTEM_CURSOR_DEFAULT
         SDL_SYSTEM_CURSOR_TEXT
         SDL_SYSTEM_CURSOR_WAIT
         SDL_SYSTEM_CURSOR_CROSSHAIR
         SDL_SYSTEM_CURSOR_PROGRESS
         SDL_SYSTEM_CURSOR_NWSE_RESIZE
         SDL_SYSTEM_CURSOR_NESW_RESIZE
         SDL_SYSTEM_CURSOR_EW_RESIZE
         SDL_SYSTEM_CURSOR_NS_RESIZE
         SDL_SYSTEM_CURSOR_MOVE
         SDL_SYSTEM_CURSOR_NOT_ALLOWED
         SDL_SYSTEM_CURSOR_POINTER
         SDL_SYSTEM_CURSOR_NW_RESIZE
         SDL_SYSTEM_CURSOR_N_RESIZE
         SDL_SYSTEM_CURSOR_NE_RESIZE
         SDL_SYSTEM_CURSOR_E_RESIZE
         SDL_SYSTEM_CURSOR_SE_RESIZE
         SDL_SYSTEM_CURSOR_S_RESIZE
         SDL_SYSTEM_CURSOR_SW_RESIZE
         SDL_SYSTEM_CURSOR_W_RESIZE
         SDL_SYSTEM_CURSOR_COUNT
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
(define SDL_WINDOW_FULLSCREEN          #x0000000000000001)
(define SDL_WINDOW_RESIZABLE           #x0000000000000020)
(define SDL_WINDOW_HIGH_PIXEL_DENSITY  #x0000000000002000)

;; SDL_WindowFlags is a 64-bit unsigned integer in SDL3 (flags can be combined with bitwise-ior)
(define _SDL_WindowFlags _uint64)

;; ============================================================================
;; Pointer Types
;; ============================================================================
(define-cpointer-type _SDL_Window-pointer)
(define-cpointer-type _SDL_Renderer-pointer)
(define-cpointer-type _SDL_Texture-pointer)
(define-cpointer-type _SDL_Surface-pointer)
(define-cpointer-type _SDL_Cursor-pointer)

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
;; Color Struct
;; ============================================================================

;; SDL_Color - RGBA color (r, g, b, a each 0-255)
(define-cstruct _SDL_Color
  ([r _uint8]
   [g _uint8]
   [b _uint8]
   [a _uint8]))

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
;; Text input
(define SDL_EVENT_TEXT_INPUT #x303)
;; Mouse events
(define SDL_EVENT_MOUSE_MOTION #x400)
(define SDL_EVENT_MOUSE_BUTTON_DOWN #x401)
(define SDL_EVENT_MOUSE_BUTTON_UP #x402)
(define SDL_EVENT_MOUSE_WHEEL #x403)

;; ============================================================================
;; Mouse Wheel Direction
;; ============================================================================
(define SDL_MOUSEWHEEL_NORMAL 0)
(define SDL_MOUSEWHEEL_FLIPPED 1)

;; ============================================================================
;; Mouse Button Constants
;; ============================================================================
;; Mouse button indices
(define SDL_BUTTON_LEFT 1)
(define SDL_BUTTON_MIDDLE 2)
(define SDL_BUTTON_RIGHT 3)
(define SDL_BUTTON_X1 4)
(define SDL_BUTTON_X2 5)

;; Mouse button masks for SDL_GetMouseState return value
(define (SDL_BUTTON_MASK x) (arithmetic-shift 1 (- x 1)))
(define SDL_BUTTON_LMASK (SDL_BUTTON_MASK SDL_BUTTON_LEFT))    ; 1
(define SDL_BUTTON_MMASK (SDL_BUTTON_MASK SDL_BUTTON_MIDDLE))  ; 2
(define SDL_BUTTON_RMASK (SDL_BUTTON_MASK SDL_BUTTON_RIGHT))   ; 4
(define SDL_BUTTON_X1MASK (SDL_BUTTON_MASK SDL_BUTTON_X1))     ; 8
(define SDL_BUTTON_X2MASK (SDL_BUTTON_MASK SDL_BUTTON_X2))     ; 16

;; ============================================================================
;; Key Constants (SDL_Keycode values)
;; ============================================================================
;; SDL3 keycodes: letters are lowercase ASCII, special keys use scancode mask

;; Special keys
(define SDLK_UNKNOWN   #x00000000)
(define SDLK_RETURN    #x0000000D)  ; '\r'
(define SDLK_ESCAPE    #x0000001B)
(define SDLK_BACKSPACE #x00000008)  ; '\b'
(define SDLK_TAB       #x00000009)  ; '\t'
(define SDLK_SPACE     #x00000020)  ; ' '

;; Punctuation and symbols (ASCII order)
(define SDLK_EXCLAIM      #x00000021)  ; '!'
(define SDLK_DBLAPOSTROPHE #x00000022) ; '"'
(define SDLK_HASH         #x00000023)  ; '#'
(define SDLK_DOLLAR       #x00000024)  ; '$'
(define SDLK_PERCENT      #x00000025)  ; '%'
(define SDLK_AMPERSAND    #x00000026)  ; '&'
(define SDLK_APOSTROPHE   #x00000027)  ; '\''
(define SDLK_LEFTPAREN    #x00000028)  ; '('
(define SDLK_RIGHTPAREN   #x00000029)  ; ')'
(define SDLK_ASTERISK     #x0000002A)  ; '*'
(define SDLK_PLUS         #x0000002B)  ; '+'
(define SDLK_COMMA        #x0000002C)  ; ','
(define SDLK_MINUS        #x0000002D)  ; '-'
(define SDLK_PERIOD       #x0000002E)  ; '.'
(define SDLK_SLASH        #x0000002F)  ; '/'

;; Number keys (ASCII '0'-'9')
(define SDLK_0 #x00000030)
(define SDLK_1 #x00000031)
(define SDLK_2 #x00000032)
(define SDLK_3 #x00000033)
(define SDLK_4 #x00000034)
(define SDLK_5 #x00000035)
(define SDLK_6 #x00000036)
(define SDLK_7 #x00000037)
(define SDLK_8 #x00000038)
(define SDLK_9 #x00000039)

;; More punctuation
(define SDLK_COLON        #x0000003A)  ; ':'
(define SDLK_SEMICOLON    #x0000003B)  ; ';'
(define SDLK_LESS         #x0000003C)  ; '<'
(define SDLK_EQUALS       #x0000003D)  ; '='
(define SDLK_GREATER      #x0000003E)  ; '>'
(define SDLK_QUESTION     #x0000003F)  ; '?'
(define SDLK_AT           #x00000040)  ; '@'
(define SDLK_LEFTBRACKET  #x0000005B)  ; '['
(define SDLK_BACKSLASH    #x0000005C)  ; '\\'
(define SDLK_RIGHTBRACKET #x0000005D)  ; ']'
(define SDLK_CARET        #x0000005E)  ; '^'
(define SDLK_UNDERSCORE   #x0000005F)  ; '_'
(define SDLK_GRAVE        #x00000060)  ; '`'

;; Letter keys (SDL3: uppercase names, lowercase ASCII values 'a'-'z')
(define SDLK_A #x00000061)
(define SDLK_B #x00000062)
(define SDLK_C #x00000063)
(define SDLK_D #x00000064)
(define SDLK_E #x00000065)
(define SDLK_F #x00000066)
(define SDLK_G #x00000067)
(define SDLK_H #x00000068)
(define SDLK_I #x00000069)
(define SDLK_J #x0000006A)
(define SDLK_K #x0000006B)
(define SDLK_L #x0000006C)
(define SDLK_M #x0000006D)
(define SDLK_N #x0000006E)
(define SDLK_O #x0000006F)
(define SDLK_P #x00000070)
(define SDLK_Q #x00000071)
(define SDLK_R #x00000072)
(define SDLK_S #x00000073)
(define SDLK_T #x00000074)
(define SDLK_U #x00000075)
(define SDLK_V #x00000076)
(define SDLK_W #x00000077)
(define SDLK_X #x00000078)
(define SDLK_Y #x00000079)
(define SDLK_Z #x0000007A)

;; More punctuation (after letters in ASCII)
(define SDLK_LEFTBRACE  #x0000007B)  ; '{'
(define SDLK_PIPE       #x0000007C)  ; '|'
(define SDLK_RIGHTBRACE #x0000007D)  ; '}'
(define SDLK_TILDE      #x0000007E)  ; '~'
(define SDLK_DELETE     #x0000007F)

;; Lock keys
(define SDLK_CAPSLOCK   #x40000039)
(define SDLK_SCROLLLOCK #x40000047)
(define SDLK_NUMLOCKCLEAR #x40000053)

;; Function keys F1-F12
(define SDLK_F1  #x4000003A)
(define SDLK_F2  #x4000003B)
(define SDLK_F3  #x4000003C)
(define SDLK_F4  #x4000003D)
(define SDLK_F5  #x4000003E)
(define SDLK_F6  #x4000003F)
(define SDLK_F7  #x40000040)
(define SDLK_F8  #x40000041)
(define SDLK_F9  #x40000042)
(define SDLK_F10 #x40000043)
(define SDLK_F11 #x40000044)
(define SDLK_F12 #x40000045)

;; Function keys F13-F24
(define SDLK_F13 #x40000068)
(define SDLK_F14 #x40000069)
(define SDLK_F15 #x4000006A)
(define SDLK_F16 #x4000006B)
(define SDLK_F17 #x4000006C)
(define SDLK_F18 #x4000006D)
(define SDLK_F19 #x4000006E)
(define SDLK_F20 #x4000006F)
(define SDLK_F21 #x40000070)
(define SDLK_F22 #x40000071)
(define SDLK_F23 #x40000072)
(define SDLK_F24 #x40000073)

;; Print/Pause
(define SDLK_PRINTSCREEN #x40000046)
(define SDLK_PAUSE       #x40000048)

;; Navigation keys
(define SDLK_INSERT   #x40000049)
(define SDLK_HOME     #x4000004A)
(define SDLK_PAGEUP   #x4000004B)
(define SDLK_END      #x4000004D)
(define SDLK_PAGEDOWN #x4000004E)

;; Arrow keys
(define SDLK_RIGHT #x4000004F)
(define SDLK_LEFT  #x40000050)
(define SDLK_DOWN  #x40000051)
(define SDLK_UP    #x40000052)

;; Keypad numbers
(define SDLK_KP_0 #x40000062)
(define SDLK_KP_1 #x40000059)
(define SDLK_KP_2 #x4000005A)
(define SDLK_KP_3 #x4000005B)
(define SDLK_KP_4 #x4000005C)
(define SDLK_KP_5 #x4000005D)
(define SDLK_KP_6 #x4000005E)
(define SDLK_KP_7 #x4000005F)
(define SDLK_KP_8 #x40000060)
(define SDLK_KP_9 #x40000061)

;; Keypad operators
(define SDLK_KP_DIVIDE   #x40000054)
(define SDLK_KP_MULTIPLY #x40000055)
(define SDLK_KP_MINUS    #x40000056)
(define SDLK_KP_PLUS     #x40000057)
(define SDLK_KP_ENTER    #x40000058)
(define SDLK_KP_PERIOD   #x40000063)
(define SDLK_KP_EQUALS   #x40000067)

;; Application/Menu key
(define SDLK_APPLICATION #x40000065)
(define SDLK_MENU        #x40000076)

;; Editing keys
(define SDLK_UNDO  #x4000007A)
(define SDLK_CUT   #x4000007B)
(define SDLK_COPY  #x4000007C)
(define SDLK_PASTE #x4000007D)
(define SDLK_FIND  #x4000007E)

;; Media keys
(define SDLK_MUTE       #x4000007F)
(define SDLK_VOLUMEUP   #x40000080)
(define SDLK_VOLUMEDOWN #x40000081)

;; Modifier keys (as keycodes, not mod flags)
(define SDLK_LCTRL  #x400000E0)
(define SDLK_LSHIFT #x400000E1)
(define SDLK_LALT   #x400000E2)
(define SDLK_LGUI   #x400000E3)
(define SDLK_RCTRL  #x400000E4)
(define SDLK_RSHIFT #x400000E5)
(define SDLK_RALT   #x400000E6)
(define SDLK_RGUI   #x400000E7)

;; SDL_Keycode type (32-bit)
(define _SDL_Keycode _uint32)

;; ============================================================================
;; Modifier Key Masks (SDL_Keymod - uint16)
;; ============================================================================
(define SDL_KMOD_NONE   #x0000)
(define SDL_KMOD_LSHIFT #x0001)
(define SDL_KMOD_RSHIFT #x0002)
(define SDL_KMOD_LCTRL  #x0040)
(define SDL_KMOD_RCTRL  #x0080)
(define SDL_KMOD_LALT   #x0100)
(define SDL_KMOD_RALT   #x0200)
(define SDL_KMOD_LGUI   #x0400)
(define SDL_KMOD_RGUI   #x0800)
(define SDL_KMOD_NUM    #x1000)
(define SDL_KMOD_CAPS   #x2000)
(define SDL_KMOD_MODE   #x4000)
(define SDL_KMOD_SCROLL #x8000)
;; Combined masks
(define SDL_KMOD_CTRL  (bitwise-ior SDL_KMOD_LCTRL SDL_KMOD_RCTRL))
(define SDL_KMOD_SHIFT (bitwise-ior SDL_KMOD_LSHIFT SDL_KMOD_RSHIFT))
(define SDL_KMOD_ALT   (bitwise-ior SDL_KMOD_LALT SDL_KMOD_RALT))
(define SDL_KMOD_GUI   (bitwise-ior SDL_KMOD_LGUI SDL_KMOD_RGUI))

;; ============================================================================
;; Blend Modes
;; ============================================================================

;; SDL_BlendMode type (32-bit unsigned)
(define _SDL_BlendMode _uint32)

;; Blend mode constants
(define SDL_BLENDMODE_NONE                #x00000000)  ; no blending
(define SDL_BLENDMODE_BLEND               #x00000001)  ; alpha blending
(define SDL_BLENDMODE_BLEND_PREMULTIPLIED #x00000010)  ; pre-multiplied alpha
(define SDL_BLENDMODE_ADD                 #x00000002)  ; additive blending
(define SDL_BLENDMODE_ADD_PREMULTIPLIED   #x00000020)  ; pre-multiplied additive
(define SDL_BLENDMODE_MOD                 #x00000004)  ; color modulate
(define SDL_BLENDMODE_MUL                 #x00000008)  ; color multiply
(define SDL_BLENDMODE_INVALID             #x7FFFFFFF)

;; ============================================================================
;; Flip Modes
;; ============================================================================

;; SDL_FlipMode - for texture rendering with flipping
(define _SDL_FlipMode _int)

(define SDL_FLIP_NONE       0)  ; no flipping
(define SDL_FLIP_HORIZONTAL 1)  ; flip horizontally
(define SDL_FLIP_VERTICAL   2)  ; flip vertically

;; ============================================================================
;; System Cursor Types
;; ============================================================================

;; SDL_SystemCursor - predefined system cursor types
(define _SDL_SystemCursor _int)

(define SDL_SYSTEM_CURSOR_DEFAULT      0)   ; Default cursor (usually an arrow)
(define SDL_SYSTEM_CURSOR_TEXT         1)   ; Text selection (usually an I-beam)
(define SDL_SYSTEM_CURSOR_WAIT         2)   ; Wait (hourglass or spinning ball)
(define SDL_SYSTEM_CURSOR_CROSSHAIR    3)   ; Crosshair
(define SDL_SYSTEM_CURSOR_PROGRESS     4)   ; Program busy but interactive
(define SDL_SYSTEM_CURSOR_NWSE_RESIZE  5)   ; Double arrow NW-SE
(define SDL_SYSTEM_CURSOR_NESW_RESIZE  6)   ; Double arrow NE-SW
(define SDL_SYSTEM_CURSOR_EW_RESIZE    7)   ; Double arrow E-W
(define SDL_SYSTEM_CURSOR_NS_RESIZE    8)   ; Double arrow N-S
(define SDL_SYSTEM_CURSOR_MOVE         9)   ; Four-pointed arrow (move)
(define SDL_SYSTEM_CURSOR_NOT_ALLOWED  10)  ; Not permitted (slashed circle)
(define SDL_SYSTEM_CURSOR_POINTER      11)  ; Pointer/link (pointing hand)
(define SDL_SYSTEM_CURSOR_NW_RESIZE    12)  ; Window resize top-left
(define SDL_SYSTEM_CURSOR_N_RESIZE     13)  ; Window resize top
(define SDL_SYSTEM_CURSOR_NE_RESIZE    14)  ; Window resize top-right
(define SDL_SYSTEM_CURSOR_E_RESIZE     15)  ; Window resize right
(define SDL_SYSTEM_CURSOR_SE_RESIZE    16)  ; Window resize bottom-right
(define SDL_SYSTEM_CURSOR_S_RESIZE     17)  ; Window resize bottom
(define SDL_SYSTEM_CURSOR_SW_RESIZE    18)  ; Window resize bottom-left
(define SDL_SYSTEM_CURSOR_W_RESIZE     19)  ; Window resize left
(define SDL_SYSTEM_CURSOR_COUNT        20)  ; Number of system cursors

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

(define (event->text-input event-ptr)
  (cast event-ptr _pointer _SDL_TextInputEvent-pointer))

(define (event->mouse-wheel event-ptr)
  (cast event-ptr _pointer _SDL_MouseWheelEvent-pointer))

;; ============================================================================
;; Texture Access Modes
;; ============================================================================

;; SDL_TextureAccess - how the texture data will be accessed
(define _SDL_TextureAccess _int)

(define SDL_TEXTUREACCESS_STATIC    0)  ; changes rarely, not lockable
(define SDL_TEXTUREACCESS_STREAMING 1)  ; changes frequently, lockable
(define SDL_TEXTUREACCESS_TARGET    2)  ; can be used as render target

;; ============================================================================
;; Scale Modes
;; ============================================================================

;; SDL_ScaleMode - how texture scaling is performed
(define _SDL_ScaleMode _int)

(define SDL_SCALEMODE_INVALID -1)
(define SDL_SCALEMODE_NEAREST  0)  ; nearest pixel sampling (pixelated)
(define SDL_SCALEMODE_LINEAR   1)  ; linear filtering (smooth)

;; ============================================================================
;; Pixel Formats
;; ============================================================================

;; SDL_PixelFormat - pixel format values
(define _SDL_PixelFormat _uint32)

(define SDL_PIXELFORMAT_UNKNOWN   #x00000000)
(define SDL_PIXELFORMAT_RGBA8888  #x16462004)
(define SDL_PIXELFORMAT_ARGB8888  #x16362004)
(define SDL_PIXELFORMAT_ABGR8888  #x16762004)
(define SDL_PIXELFORMAT_BGRA8888  #x16862004)

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
