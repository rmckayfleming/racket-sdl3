#lang racket/base

;; SDL3 Constants and Flags
;; This module contains constant values, flags, and enumerations (excluding keycodes/scancodes).
;; For type definitions (structs, cpointer types), see types.rkt.
;; For keycodes and scancodes, see enums.rkt.

(require ffi/unsafe)

(provide
 ;; Init flags
 SDL_INIT_AUDIO
 SDL_INIT_VIDEO
 SDL_INIT_EVENTS
 ;; Window flags
 SDL_WINDOW_FULLSCREEN
 SDL_WINDOW_RESIZABLE
 SDL_WINDOW_HIGH_PIXEL_DENSITY
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
 ;; Event union size
 SDL_EVENT_SIZE
 ;; Blend mode constants
 SDL_BLENDMODE_NONE
 SDL_BLENDMODE_BLEND
 SDL_BLENDMODE_BLEND_PREMULTIPLIED
 SDL_BLENDMODE_ADD
 SDL_BLENDMODE_ADD_PREMULTIPLIED
 SDL_BLENDMODE_MOD
 SDL_BLENDMODE_MUL
 SDL_BLENDMODE_INVALID
 ;; Flip mode constants
 SDL_FLIP_NONE
 SDL_FLIP_HORIZONTAL
 SDL_FLIP_VERTICAL
 ;; Texture access constants
 SDL_TEXTUREACCESS_STATIC
 SDL_TEXTUREACCESS_STREAMING
 SDL_TEXTUREACCESS_TARGET
 ;; Scale mode constants
 SDL_SCALEMODE_INVALID
 SDL_SCALEMODE_NEAREST
 SDL_SCALEMODE_LINEAR
 ;; Pixel format constants
 SDL_PIXELFORMAT_UNKNOWN
 SDL_PIXELFORMAT_RGBA8888
 SDL_PIXELFORMAT_ARGB8888
 SDL_PIXELFORMAT_ABGR8888
 SDL_PIXELFORMAT_BGRA8888
 SDL_PIXELFORMAT_RGB24
 SDL_PIXELFORMAT_RGBA32
 ;; System cursor constants
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
 ;; Audio constants
 SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK
 SDL_AUDIO_DEVICE_DEFAULT_RECORDING
 SDL_AUDIO_UNKNOWN
 SDL_AUDIO_U8
 SDL_AUDIO_S8
 SDL_AUDIO_S16LE
 SDL_AUDIO_S16BE
 SDL_AUDIO_S32LE
 SDL_AUDIO_S32BE
 SDL_AUDIO_F32LE
 SDL_AUDIO_F32BE
 SDL_AUDIO_S16
 SDL_AUDIO_S32
 SDL_AUDIO_F32
 ;; Flash operation constants
 SDL_FLASH_CANCEL
 SDL_FLASH_BRIEFLY
 SDL_FLASH_UNTIL_FOCUSED
 ;; Message box constants
 SDL_MESSAGEBOX_ERROR
 SDL_MESSAGEBOX_WARNING
 SDL_MESSAGEBOX_INFORMATION
 SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT
 SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT
 SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT
 SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT)

;; ============================================================================
;; Init Flags (SDL_InitFlags) - used with SDL_Init
;; ============================================================================
(define SDL_INIT_AUDIO #x00000010)
(define SDL_INIT_VIDEO #x00000020)
(define SDL_INIT_EVENTS #x00004000)

;; ============================================================================
;; Window Flags (SDL_WindowFlags) - 64-bit in SDL3
;; ============================================================================
(define SDL_WINDOW_FULLSCREEN          #x0000000000000001)
(define SDL_WINDOW_RESIZABLE           #x0000000000000020)
(define SDL_WINDOW_HIGH_PIXEL_DENSITY  #x0000000000002000)

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

;; SDL_Event union size (128 bytes in SDL3)
(define SDL_EVENT_SIZE 128)

;; ============================================================================
;; Blend Modes
;; ============================================================================
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
(define SDL_FLIP_NONE       0)  ; no flipping
(define SDL_FLIP_HORIZONTAL 1)  ; flip horizontally
(define SDL_FLIP_VERTICAL   2)  ; flip vertically

;; ============================================================================
;; Texture Access Modes
;; ============================================================================
(define SDL_TEXTUREACCESS_STATIC    0)  ; changes rarely, not lockable
(define SDL_TEXTUREACCESS_STREAMING 1)  ; changes frequently, lockable
(define SDL_TEXTUREACCESS_TARGET    2)  ; can be used as render target

;; ============================================================================
;; Scale Modes
;; ============================================================================
(define SDL_SCALEMODE_INVALID -1)
(define SDL_SCALEMODE_NEAREST  0)  ; nearest pixel sampling (pixelated)
(define SDL_SCALEMODE_LINEAR   1)  ; linear filtering (smooth)

;; ============================================================================
;; Pixel Formats
;; ============================================================================
(define SDL_PIXELFORMAT_UNKNOWN   #x00000000)
(define SDL_PIXELFORMAT_RGBA8888  #x16462004)
(define SDL_PIXELFORMAT_ARGB8888  #x16362004)
(define SDL_PIXELFORMAT_ABGR8888  #x16762004)
(define SDL_PIXELFORMAT_BGRA8888  #x16862004)
(define SDL_PIXELFORMAT_RGB24     #x17101803)

;; SDL_PIXELFORMAT_RGBA32 is an alias that depends on system endianness
;; On little-endian (macOS ARM/x86, Windows, Linux x86): ABGR8888
;; On big-endian: RGBA8888
;; Most modern systems are little-endian
(define SDL_PIXELFORMAT_RGBA32    SDL_PIXELFORMAT_ABGR8888)

;; ============================================================================
;; System Cursor Types
;; ============================================================================
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
;; Audio Constants
;; ============================================================================
;; Default device constants
(define SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK   #xFFFFFFFF)
(define SDL_AUDIO_DEVICE_DEFAULT_RECORDING  #xFFFFFFFE)

;; Audio format constants
(define SDL_AUDIO_UNKNOWN  #x0000)  ; Unspecified audio format
(define SDL_AUDIO_U8       #x0008)  ; Unsigned 8-bit samples
(define SDL_AUDIO_S8       #x8008)  ; Signed 8-bit samples
(define SDL_AUDIO_S16LE    #x8010)  ; Signed 16-bit samples (little-endian)
(define SDL_AUDIO_S16BE    #x9010)  ; Signed 16-bit samples (big-endian)
(define SDL_AUDIO_S32LE    #x8020)  ; 32-bit integer samples (little-endian)
(define SDL_AUDIO_S32BE    #x9020)  ; 32-bit integer samples (big-endian)
(define SDL_AUDIO_F32LE    #x8120)  ; 32-bit floating point samples (little-endian)
(define SDL_AUDIO_F32BE    #x9120)  ; 32-bit floating point samples (big-endian)

;; Native byte order aliases (little-endian on macOS/x86/ARM)
(define SDL_AUDIO_S16 SDL_AUDIO_S16LE)
(define SDL_AUDIO_S32 SDL_AUDIO_S32LE)
(define SDL_AUDIO_F32 SDL_AUDIO_F32LE)

;; ============================================================================
;; Flash Operation
;; ============================================================================
(define SDL_FLASH_CANCEL        0)  ; Cancel any window flash state
(define SDL_FLASH_BRIEFLY       1)  ; Flash the window briefly to get attention
(define SDL_FLASH_UNTIL_FOCUSED 2)  ; Flash the window until it gets focus

;; ============================================================================
;; Message Box Constants
;; ============================================================================
;; SDL_MessageBoxFlags - flags for message box display
(define SDL_MESSAGEBOX_ERROR                    #x00000010)  ; error dialog
(define SDL_MESSAGEBOX_WARNING                  #x00000020)  ; warning dialog
(define SDL_MESSAGEBOX_INFORMATION              #x00000040)  ; informational dialog
(define SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT    #x00000080)  ; buttons placed left to right
(define SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT    #x00000100)  ; buttons placed right to left

;; SDL_MessageBoxButtonFlags - flags for individual buttons
(define SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT #x00000001)  ; default button when return is hit
(define SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT #x00000002)  ; default button when escape is hit
