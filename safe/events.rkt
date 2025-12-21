#lang racket/base

;; Idiomatic event handling with Racket structs and match support

(require ffi/unsafe
         racket/match
         "../raw.rkt"
         "keyboard.rkt")

(provide
 ;; Base event type
 sdl-event

 ;; Event structs (all transparent for match)
 quit-event quit-event?

 window-event window-event? window-event-type

 key-event key-event?
 key-event-type key-event-key key-event-scancode key-event-mod key-event-repeat?

 mouse-motion-event mouse-motion-event?
 mouse-motion-event-x mouse-motion-event-y
 mouse-motion-event-xrel mouse-motion-event-yrel
 mouse-motion-event-state

 mouse-button-event mouse-button-event?
 mouse-button-event-type mouse-button-event-button
 mouse-button-event-x mouse-button-event-y mouse-button-event-clicks

 text-input-event text-input-event? text-input-event-text

 mouse-wheel-event mouse-wheel-event?
 mouse-wheel-event-x mouse-wheel-event-y
 mouse-wheel-event-direction
 mouse-wheel-event-mouse-x mouse-wheel-event-mouse-y

 drop-event drop-event?
 drop-event-type drop-event-x drop-event-y drop-event-source drop-event-data

 clipboard-event clipboard-event?
 clipboard-event-owner? clipboard-event-mime-types

 audio-device-event audio-device-event?
 audio-device-event-type audio-device-event-which audio-device-event-recording?

 camera-device-event camera-device-event?
 camera-device-event-type camera-device-event-which

 ;; Joystick events
 joy-axis-event joy-axis-event?
 joy-axis-event-which joy-axis-event-axis joy-axis-event-value

 joy-button-event joy-button-event?
 joy-button-event-type joy-button-event-which joy-button-event-button

 joy-hat-event joy-hat-event?
 joy-hat-event-which joy-hat-event-hat joy-hat-event-value

 joy-device-event joy-device-event?
 joy-device-event-type joy-device-event-which

 ;; Gamepad events
 gamepad-axis-event gamepad-axis-event?
 gamepad-axis-event-which gamepad-axis-event-axis gamepad-axis-event-value

 gamepad-button-event gamepad-button-event?
 gamepad-button-event-type gamepad-button-event-which gamepad-button-event-button

 gamepad-device-event gamepad-device-event?
 gamepad-device-event-type gamepad-device-event-which

 ;; Touch events
 touch-finger-event touch-finger-event?
 touch-finger-event-type touch-finger-event-touch-id touch-finger-event-finger-id
 touch-finger-event-x touch-finger-event-y
 touch-finger-event-dx touch-finger-event-dy
 touch-finger-event-pressure

 ;; Pen events
 pen-proximity-event pen-proximity-event?
 pen-proximity-event-type pen-proximity-event-which

 pen-motion-event pen-motion-event?
 pen-motion-event-which pen-motion-event-pen-state
 pen-motion-event-x pen-motion-event-y

 pen-touch-event pen-touch-event?
 pen-touch-event-type pen-touch-event-which pen-touch-event-pen-state
 pen-touch-event-x pen-touch-event-y
 pen-touch-event-eraser?

 pen-button-event pen-button-event?
 pen-button-event-type pen-button-event-which pen-button-event-pen-state
 pen-button-event-x pen-button-event-y pen-button-event-button

 pen-axis-event pen-axis-event?
 pen-axis-event-which pen-axis-event-pen-state
 pen-axis-event-x pen-axis-event-y
 pen-axis-event-axis pen-axis-event-value

 ;; Pen state predicates
 pen-state-down?
 pen-state-button?
 pen-state-eraser?

 ;; Pen axis symbols
 pen-axis->symbol

 unknown-event unknown-event? unknown-event-type

 ;; Polling functions
 poll-event
 in-events

 ;; Blocking event functions
 wait-event
 wait-event-timeout

 ;; Event loop helpers
 should-quit?

 ;; Key utilities
 key-name

 ;; Modifier predicates
 mod-shift?
 mod-ctrl?
 mod-alt?
 mod-gui?

 ;; Re-export key constants - Special keys
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

 ;; Re-export modifier constants
 SDL_KMOD_NONE SDL_KMOD_LSHIFT SDL_KMOD_RSHIFT
 SDL_KMOD_LCTRL SDL_KMOD_RCTRL SDL_KMOD_LALT SDL_KMOD_RALT
 SDL_KMOD_LGUI SDL_KMOD_RGUI SDL_KMOD_NUM SDL_KMOD_CAPS
 SDL_KMOD_MODE SDL_KMOD_SCROLL
 SDL_KMOD_CTRL SDL_KMOD_SHIFT SDL_KMOD_ALT SDL_KMOD_GUI)

;; ============================================================================
;; Event Structs
;; ============================================================================

;; Base struct (not instantiated directly)
(struct sdl-event () #:transparent)

;; Application quit requested
(struct quit-event sdl-event () #:transparent)

;; Window events (shown, hidden, resized, close-requested, etc.)
(struct window-event sdl-event (type) #:transparent)
;; type is a symbol: 'shown, 'hidden, 'exposed, 'moved, 'resized,
;;                   'focus-gained, 'focus-lost, 'close-requested

;; Keyboard events
(struct key-event sdl-event (type key scancode mod repeat?) #:transparent)
;; type is 'down or 'up
;; key is a symbol ('escape, 'a, 'space, etc.) or the raw keycode if unknown
;; scancode is the physical key scancode (integer)
;; mod is modifier flags (integer)
;; repeat? is #t if this is a key repeat
;;
;; Match examples:
;;   [(key-event 'down 'escape _ _ _) ...]
;;   [(key-event 'down 'w _ _ _) ...]
;;   [(key-event type 'space _ mod _) (when (mod-shift? mod) ...)]

;; Mouse motion
(struct mouse-motion-event sdl-event (x y xrel yrel state) #:transparent)
;; x, y are current position (floats)
;; xrel, yrel are relative motion (floats)
;; state is button state mask (integer)

;; Mouse button press/release
(struct mouse-button-event sdl-event (type button x y clicks) #:transparent)
;; type is 'down or 'up
;; button is 'left, 'middle, 'right, 'x1, 'x2, or integer
;; x, y are position (floats)
;; clicks is click count (1 for single, 2 for double, etc.)

;; Text input (actual characters, handles shift/caps)
(struct text-input-event sdl-event (text) #:transparent)
;; text is a string

;; Mouse wheel/scroll
(struct mouse-wheel-event sdl-event (x y direction mouse-x mouse-y) #:transparent)
;; x, y are scroll amounts (floats, positive = right/away from user)
;; direction is 'normal or 'flipped
;; mouse-x, mouse-y are cursor position (floats)

;; Drop events (drag-and-drop)
(struct drop-event sdl-event (type x y source data) #:transparent)
;; type is 'file, 'text, 'begin, 'complete, or 'position
;; x, y are position (floats, may be 0 for begin/complete)
;; source is source app string or #f
;; data is dropped file path or text, or #f

;; Clipboard update events
(struct clipboard-event sdl-event (owner? mime-types) #:transparent)
;; owner? is #t if we own the clipboard
;; mime-types is a list of mime type strings

;; Audio device events
(struct audio-device-event sdl-event (type which recording?) #:transparent)
;; type is 'added, 'removed, or 'format-changed
;; which is the SDL_AudioDeviceID
;; recording? is #t for recording devices

;; Camera device events
(struct camera-device-event sdl-event (type which) #:transparent)
;; type is 'added, 'removed, 'approved, or 'denied
;; which is the SDL_CameraID

;; Joystick axis motion
(struct joy-axis-event sdl-event (which axis value) #:transparent)
;; which is the joystick instance ID
;; axis is the axis index
;; value is -32768 to 32767

;; Joystick button press/release
(struct joy-button-event sdl-event (type which button) #:transparent)
;; type is 'down or 'up
;; which is the joystick instance ID
;; button is the button index

;; Joystick hat motion
(struct joy-hat-event sdl-event (which hat value) #:transparent)
;; which is the joystick instance ID
;; hat is the hat index
;; value is a symbol: 'centered, 'up, 'down, 'left, 'right, 'up-left, etc.

;; Joystick connected/disconnected
(struct joy-device-event sdl-event (type which) #:transparent)
;; type is 'added or 'removed
;; which is the joystick instance ID

;; Gamepad axis motion
(struct gamepad-axis-event sdl-event (which axis value) #:transparent)
;; which is the joystick instance ID
;; axis is a symbol: 'left-x, 'left-y, 'right-x, 'right-y, 'left-trigger, 'right-trigger
;; value is -32768 to 32767 for sticks, 0 to 32767 for triggers

;; Gamepad button press/release
(struct gamepad-button-event sdl-event (type which button) #:transparent)
;; type is 'down or 'up
;; which is the joystick instance ID
;; button is a symbol: 'south, 'east, 'west, 'north, 'back, 'guide, 'start, etc.

;; Gamepad connected/disconnected/remapped
(struct gamepad-device-event sdl-event (type which) #:transparent)
;; type is 'added, 'removed, or 'remapped
;; which is the joystick instance ID

;; Touch finger events
(struct touch-finger-event sdl-event (type touch-id finger-id x y dx dy pressure) #:transparent)
;; type is 'down, 'up, 'motion, or 'canceled
;; touch-id is the touch device ID
;; finger-id is the finger ID within the device
;; x, y are normalized 0...1 (relative to window)
;; dx, dy are normalized -1...1 (movement delta)
;; pressure is normalized 0...1

;; Pen proximity events
(struct pen-proximity-event sdl-event (type which) #:transparent)
;; type is 'in or 'out
;; which is the pen instance ID

;; Pen motion events
(struct pen-motion-event sdl-event (which pen-state x y) #:transparent)
;; which is the pen instance ID
;; pen-state is the pen input flags (use pen-state-down?, pen-state-button?, etc.)
;; x, y are position relative to window

;; Pen touch events (pen touches/lifts from surface)
(struct pen-touch-event sdl-event (type which pen-state x y eraser?) #:transparent)
;; type is 'down or 'up
;; which is the pen instance ID
;; pen-state is the pen input flags
;; x, y are position relative to window
;; eraser? is #t if the eraser tip is used

;; Pen button events
(struct pen-button-event sdl-event (type which pen-state x y button) #:transparent)
;; type is 'down or 'up
;; which is the pen instance ID
;; pen-state is the pen input flags
;; x, y are position relative to window
;; button is the button index (1-5)

;; Pen axis events
(struct pen-axis-event sdl-event (which pen-state x y axis value) #:transparent)
;; which is the pen instance ID
;; pen-state is the pen input flags
;; x, y are position relative to window
;; axis is a symbol: 'pressure, 'xtilt, 'ytilt, 'distance, 'rotation, 'slider, 'tangential-pressure
;; value is the axis value (normalized or in degrees depending on axis)

;; Unknown/unhandled event type
(struct unknown-event sdl-event (type) #:transparent)
;; type is the raw event type integer

;; ============================================================================
;; Event Buffer (module-level, reused)
;; ============================================================================

(define event-buffer (malloc SDL_EVENT_SIZE 'atomic-interior))

;; ============================================================================
;; Window Event Type Mapping
;; ============================================================================

(define (window-event-type-symbol raw-type)
  (cond
    [(= raw-type SDL_EVENT_WINDOW_SHOWN) 'shown]
    [(= raw-type SDL_EVENT_WINDOW_HIDDEN) 'hidden]
    [(= raw-type SDL_EVENT_WINDOW_EXPOSED) 'exposed]
    [(= raw-type SDL_EVENT_WINDOW_MOVED) 'moved]
    [(= raw-type SDL_EVENT_WINDOW_RESIZED) 'resized]
    [(= raw-type SDL_EVENT_WINDOW_FOCUS_GAINED) 'focus-gained]
    [(= raw-type SDL_EVENT_WINDOW_FOCUS_LOST) 'focus-lost]
    [(= raw-type SDL_EVENT_WINDOW_CLOSE_REQUESTED) 'close-requested]
    [else 'unknown]))

;; ============================================================================
;; Drop Event Type Mapping
;; ============================================================================

(define (drop-event-type-symbol raw-type)
  (cond
    [(= raw-type SDL_EVENT_DROP_FILE) 'file]
    [(= raw-type SDL_EVENT_DROP_TEXT) 'text]
    [(= raw-type SDL_EVENT_DROP_BEGIN) 'begin]
    [(= raw-type SDL_EVENT_DROP_COMPLETE) 'complete]
    [(= raw-type SDL_EVENT_DROP_POSITION) 'position]
    [else 'unknown]))

;; ============================================================================
;; Audio Device Event Type Mapping
;; ============================================================================

(define (audio-device-event-type-symbol raw-type)
  (cond
    [(= raw-type SDL_EVENT_AUDIO_DEVICE_ADDED) 'added]
    [(= raw-type SDL_EVENT_AUDIO_DEVICE_REMOVED) 'removed]
    [(= raw-type SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED) 'format-changed]
    [else 'unknown]))

;; ============================================================================
;; Camera Device Event Type Mapping
;; ============================================================================

(define (camera-device-event-type-symbol raw-type)
  (cond
    [(= raw-type SDL_EVENT_CAMERA_DEVICE_ADDED) 'added]
    [(= raw-type SDL_EVENT_CAMERA_DEVICE_REMOVED) 'removed]
    [(= raw-type SDL_EVENT_CAMERA_DEVICE_APPROVED) 'approved]
    [(= raw-type SDL_EVENT_CAMERA_DEVICE_DENIED) 'denied]
    [else 'unknown]))

;; ============================================================================
;; Pointer Helpers
;; ============================================================================

(define (pointer->maybe-string ptr)
  (and ptr (cast ptr _pointer _string/utf-8)))

(define (clipboard-mime-types cb)
  (define count (SDL_ClipboardEvent-num_mime_types cb))
  (define ptr (SDL_ClipboardEvent-mime_types cb))
  (cond
    [(or (not ptr) (<= count 0)) '()]
    [else
     (for/list ([i (in-range count)]
                #:when (ptr-ref ptr _pointer i))
       (cast (ptr-ref ptr _pointer i) _pointer _string/utf-8))]))

;; ============================================================================
;; Mouse Button Symbol Mapping
;; ============================================================================

(define (button-id->symbol button-id)
  (cond
    [(= button-id SDL_BUTTON_LEFT) 'left]
    [(= button-id SDL_BUTTON_MIDDLE) 'middle]
    [(= button-id SDL_BUTTON_RIGHT) 'right]
    [(= button-id SDL_BUTTON_X1) 'x1]
    [(= button-id SDL_BUTTON_X2) 'x2]
    [else button-id]))

;; ============================================================================
;; Joystick Hat Value Mapping
;; ============================================================================

(define (joy-hat-value->symbol v)
  (cond
    [(= v SDL_HAT_CENTERED) 'centered]
    [(= v SDL_HAT_UP) 'up]
    [(= v SDL_HAT_RIGHT) 'right]
    [(= v SDL_HAT_DOWN) 'down]
    [(= v SDL_HAT_LEFT) 'left]
    [(= v SDL_HAT_RIGHTUP) 'up-right]
    [(= v SDL_HAT_RIGHTDOWN) 'down-right]
    [(= v SDL_HAT_LEFTUP) 'up-left]
    [(= v SDL_HAT_LEFTDOWN) 'down-left]
    [else 'unknown]))

;; ============================================================================
;; Gamepad Button/Axis Mapping
;; ============================================================================

(define (gamepad-button->symbol btn)
  (case btn
    [(0) 'south]
    [(1) 'east]
    [(2) 'west]
    [(3) 'north]
    [(4) 'back]
    [(5) 'guide]
    [(6) 'start]
    [(7) 'left-stick]
    [(8) 'right-stick]
    [(9) 'left-shoulder]
    [(10) 'right-shoulder]
    [(11) 'dpad-up]
    [(12) 'dpad-down]
    [(13) 'dpad-left]
    [(14) 'dpad-right]
    [(15) 'misc1]
    [(16) 'right-paddle1]
    [(17) 'left-paddle1]
    [(18) 'right-paddle2]
    [(19) 'left-paddle2]
    [(20) 'touchpad]
    [else btn]))

(define (gamepad-axis->symbol ax)
  (case ax
    [(0) 'left-x]
    [(1) 'left-y]
    [(2) 'right-x]
    [(3) 'right-y]
    [(4) 'left-trigger]
    [(5) 'right-trigger]
    [else ax]))

;; ============================================================================
;; Pen Axis Mapping
;; ============================================================================

(define (pen-axis->symbol ax)
  (case ax
    [(0) 'pressure]
    [(1) 'xtilt]
    [(2) 'ytilt]
    [(3) 'distance]
    [(4) 'rotation]
    [(5) 'slider]
    [(6) 'tangential-pressure]
    [else ax]))

;; ============================================================================
;; Pen State Predicates
;; ============================================================================

;; Check if pen is pressed down
(define (pen-state-down? state)
  (not (zero? (bitwise-and state SDL_PEN_INPUT_DOWN))))

;; Check if a pen button is pressed (button 1-5)
(define (pen-state-button? state button)
  (define mask (case button
                 [(1) SDL_PEN_INPUT_BUTTON_1]
                 [(2) SDL_PEN_INPUT_BUTTON_2]
                 [(3) SDL_PEN_INPUT_BUTTON_3]
                 [(4) SDL_PEN_INPUT_BUTTON_4]
                 [(5) SDL_PEN_INPUT_BUTTON_5]
                 [else 0]))
  (not (zero? (bitwise-and state mask))))

;; Check if eraser tip is being used
(define (pen-state-eraser? state)
  (not (zero? (bitwise-and state SDL_PEN_INPUT_ERASER_TIP))))

;; ============================================================================
;; Event Parsing
;; ============================================================================

(define (parse-event buf)
  (define type (sdl-event-type buf))
  (cond
    ;; Quit
    [(= type SDL_EVENT_QUIT)
     (quit-event)]

    ;; Window events
    [(or (= type SDL_EVENT_WINDOW_SHOWN)
         (= type SDL_EVENT_WINDOW_HIDDEN)
         (= type SDL_EVENT_WINDOW_EXPOSED)
         (= type SDL_EVENT_WINDOW_MOVED)
         (= type SDL_EVENT_WINDOW_RESIZED)
         (= type SDL_EVENT_WINDOW_FOCUS_GAINED)
         (= type SDL_EVENT_WINDOW_FOCUS_LOST)
         (= type SDL_EVENT_WINDOW_CLOSE_REQUESTED))
     (window-event (window-event-type-symbol type))]

    ;; Keyboard events
    [(or (= type SDL_EVENT_KEY_DOWN) (= type SDL_EVENT_KEY_UP))
     (define kb (event->keyboard buf))
     (define keycode (SDL_KeyboardEvent-key kb))
     ;; Convert keycode to symbol, fall back to integer if unknown
     (define key-sym (or (keycode->symbol keycode) keycode))
     (key-event (if (= type SDL_EVENT_KEY_DOWN) 'down 'up)
                key-sym
                (SDL_KeyboardEvent-scancode kb)
                (SDL_KeyboardEvent-mod kb)
                (SDL_KeyboardEvent-repeat kb))]

    ;; Mouse motion
    [(= type SDL_EVENT_MOUSE_MOTION)
     (define mm (event->mouse-motion buf))
     (mouse-motion-event (SDL_MouseMotionEvent-x mm)
                         (SDL_MouseMotionEvent-y mm)
                         (SDL_MouseMotionEvent-xrel mm)
                         (SDL_MouseMotionEvent-yrel mm)
                         (SDL_MouseMotionEvent-state mm))]

    ;; Mouse button
    [(or (= type SDL_EVENT_MOUSE_BUTTON_DOWN) (= type SDL_EVENT_MOUSE_BUTTON_UP))
     (define mb (event->mouse-button buf))
     (mouse-button-event (if (= type SDL_EVENT_MOUSE_BUTTON_DOWN) 'down 'up)
                         (button-id->symbol (SDL_MouseButtonEvent-button mb))
                         (SDL_MouseButtonEvent-x mb)
                         (SDL_MouseButtonEvent-y mb)
                         (SDL_MouseButtonEvent-clicks mb))]

    ;; Text input
    [(= type SDL_EVENT_TEXT_INPUT)
     (define ti (event->text-input buf))
     (define text-ptr (SDL_TextInputEvent-text ti))
     (define text (cast text-ptr _pointer _string/utf-8))
     (text-input-event text)]

    ;; Mouse wheel
    [(= type SDL_EVENT_MOUSE_WHEEL)
     (define mw (event->mouse-wheel buf))
     (define dir (SDL_MouseWheelEvent-direction mw))
     (mouse-wheel-event (SDL_MouseWheelEvent-x mw)
                        (SDL_MouseWheelEvent-y mw)
                        (if (= dir SDL_MOUSEWHEEL_NORMAL) 'normal 'flipped)
                        (SDL_MouseWheelEvent-mouse_x mw)
                        (SDL_MouseWheelEvent-mouse_y mw))]

    ;; Drop events
    [(or (= type SDL_EVENT_DROP_FILE)
         (= type SDL_EVENT_DROP_TEXT)
         (= type SDL_EVENT_DROP_BEGIN)
         (= type SDL_EVENT_DROP_COMPLETE)
         (= type SDL_EVENT_DROP_POSITION))
     (define drop (event->drop buf))
     (drop-event (drop-event-type-symbol type)
                 (SDL_DropEvent-x drop)
                 (SDL_DropEvent-y drop)
                 (pointer->maybe-string (SDL_DropEvent-source drop))
                 (pointer->maybe-string (SDL_DropEvent-data drop)))]

    ;; Clipboard update
    [(= type SDL_EVENT_CLIPBOARD_UPDATE)
     (define cb (event->clipboard buf))
     (clipboard-event (SDL_ClipboardEvent-owner cb)
                      (clipboard-mime-types cb))]

    ;; Audio device events
    [(or (= type SDL_EVENT_AUDIO_DEVICE_ADDED)
         (= type SDL_EVENT_AUDIO_DEVICE_REMOVED)
         (= type SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED))
     (define ad (event->audio-device buf))
     (audio-device-event (audio-device-event-type-symbol type)
                         (SDL_AudioDeviceEvent-which ad)
                         (SDL_AudioDeviceEvent-recording ad))]

    ;; Camera device events
    [(or (= type SDL_EVENT_CAMERA_DEVICE_ADDED)
         (= type SDL_EVENT_CAMERA_DEVICE_REMOVED)
         (= type SDL_EVENT_CAMERA_DEVICE_APPROVED)
         (= type SDL_EVENT_CAMERA_DEVICE_DENIED))
     (define cd (event->camera-device buf))
     (camera-device-event (camera-device-event-type-symbol type)
                          (SDL_CameraDeviceEvent-which cd))]

    ;; Joystick axis motion
    [(= type SDL_EVENT_JOYSTICK_AXIS_MOTION)
     (define ja (event->joy-axis buf))
     (joy-axis-event (SDL_JoyAxisEvent-which ja)
                     (SDL_JoyAxisEvent-axis ja)
                     (SDL_JoyAxisEvent-value ja))]

    ;; Joystick button
    [(or (= type SDL_EVENT_JOYSTICK_BUTTON_DOWN)
         (= type SDL_EVENT_JOYSTICK_BUTTON_UP))
     (define jb (event->joy-button buf))
     (joy-button-event (if (= type SDL_EVENT_JOYSTICK_BUTTON_DOWN) 'down 'up)
                       (SDL_JoyButtonEvent-which jb)
                       (SDL_JoyButtonEvent-button jb))]

    ;; Joystick hat
    [(= type SDL_EVENT_JOYSTICK_HAT_MOTION)
     (define jh (event->joy-hat buf))
     (joy-hat-event (SDL_JoyHatEvent-which jh)
                    (SDL_JoyHatEvent-hat jh)
                    (joy-hat-value->symbol (SDL_JoyHatEvent-value jh)))]

    ;; Joystick device added/removed
    [(or (= type SDL_EVENT_JOYSTICK_ADDED)
         (= type SDL_EVENT_JOYSTICK_REMOVED))
     (define jd (event->joy-device buf))
     (joy-device-event (if (= type SDL_EVENT_JOYSTICK_ADDED) 'added 'removed)
                       (SDL_JoyDeviceEvent-which jd))]

    ;; Gamepad axis motion
    [(= type SDL_EVENT_GAMEPAD_AXIS_MOTION)
     (define ga (event->gamepad-axis buf))
     (gamepad-axis-event (SDL_GamepadAxisEvent-which ga)
                         (gamepad-axis->symbol (SDL_GamepadAxisEvent-axis ga))
                         (SDL_GamepadAxisEvent-value ga))]

    ;; Gamepad button
    [(or (= type SDL_EVENT_GAMEPAD_BUTTON_DOWN)
         (= type SDL_EVENT_GAMEPAD_BUTTON_UP))
     (define gb (event->gamepad-button buf))
     (gamepad-button-event (if (= type SDL_EVENT_GAMEPAD_BUTTON_DOWN) 'down 'up)
                           (SDL_GamepadButtonEvent-which gb)
                           (gamepad-button->symbol (SDL_GamepadButtonEvent-button gb)))]

    ;; Gamepad device added/removed/remapped
    [(or (= type SDL_EVENT_GAMEPAD_ADDED)
         (= type SDL_EVENT_GAMEPAD_REMOVED)
         (= type SDL_EVENT_GAMEPAD_REMAPPED))
     (define gd (event->gamepad-device buf))
     (gamepad-device-event (cond [(= type SDL_EVENT_GAMEPAD_ADDED) 'added]
                                 [(= type SDL_EVENT_GAMEPAD_REMOVED) 'removed]
                                 [else 'remapped])
                           (SDL_GamepadDeviceEvent-which gd))]

    ;; Touch finger events
    [(or (= type SDL_EVENT_FINGER_DOWN)
         (= type SDL_EVENT_FINGER_UP)
         (= type SDL_EVENT_FINGER_MOTION)
         (= type SDL_EVENT_FINGER_CANCELED))
     (define tf (event->touch-finger buf))
     (touch-finger-event (cond [(= type SDL_EVENT_FINGER_DOWN) 'down]
                               [(= type SDL_EVENT_FINGER_UP) 'up]
                               [(= type SDL_EVENT_FINGER_MOTION) 'motion]
                               [else 'canceled])
                         (SDL_TouchFingerEvent-touchID tf)
                         (SDL_TouchFingerEvent-fingerID tf)
                         (SDL_TouchFingerEvent-x tf)
                         (SDL_TouchFingerEvent-y tf)
                         (SDL_TouchFingerEvent-dx tf)
                         (SDL_TouchFingerEvent-dy tf)
                         (SDL_TouchFingerEvent-pressure tf))]

    ;; Pen proximity events
    [(or (= type SDL_EVENT_PEN_PROXIMITY_IN)
         (= type SDL_EVENT_PEN_PROXIMITY_OUT))
     (define pp (event->pen-proximity buf))
     (pen-proximity-event (if (= type SDL_EVENT_PEN_PROXIMITY_IN) 'in 'out)
                          (SDL_PenProximityEvent-which pp))]

    ;; Pen motion events
    [(= type SDL_EVENT_PEN_MOTION)
     (define pm (event->pen-motion buf))
     (pen-motion-event (SDL_PenMotionEvent-which pm)
                       (SDL_PenMotionEvent-pen_state pm)
                       (SDL_PenMotionEvent-x pm)
                       (SDL_PenMotionEvent-y pm))]

    ;; Pen touch events (pen down/up on surface)
    [(or (= type SDL_EVENT_PEN_DOWN)
         (= type SDL_EVENT_PEN_UP))
     (define pt (event->pen-touch buf))
     (pen-touch-event (if (= type SDL_EVENT_PEN_DOWN) 'down 'up)
                      (SDL_PenTouchEvent-which pt)
                      (SDL_PenTouchEvent-pen_state pt)
                      (SDL_PenTouchEvent-x pt)
                      (SDL_PenTouchEvent-y pt)
                      (SDL_PenTouchEvent-eraser pt))]

    ;; Pen button events
    [(or (= type SDL_EVENT_PEN_BUTTON_DOWN)
         (= type SDL_EVENT_PEN_BUTTON_UP))
     (define pb (event->pen-button buf))
     (pen-button-event (if (= type SDL_EVENT_PEN_BUTTON_DOWN) 'down 'up)
                       (SDL_PenButtonEvent-which pb)
                       (SDL_PenButtonEvent-pen_state pb)
                       (SDL_PenButtonEvent-x pb)
                       (SDL_PenButtonEvent-y pb)
                       (SDL_PenButtonEvent-button pb))]

    ;; Pen axis events
    [(= type SDL_EVENT_PEN_AXIS)
     (define pa (event->pen-axis buf))
     (pen-axis-event (SDL_PenAxisEvent-which pa)
                     (SDL_PenAxisEvent-pen_state pa)
                     (SDL_PenAxisEvent-x pa)
                     (SDL_PenAxisEvent-y pa)
                     (pen-axis->symbol (SDL_PenAxisEvent-axis pa))
                     (SDL_PenAxisEvent-value pa))]

    ;; Unknown
    [else
     (unknown-event type)]))

;; ============================================================================
;; Polling API
;; ============================================================================

;; Poll for a single event. Returns #f if no events pending, or an event struct.
(define (poll-event)
  (if (SDL-PollEvent event-buffer)
      (parse-event event-buffer)
      #f))

;; Sequence of all pending events (for use with `for`)
(define (in-events)
  (make-do-sequence
   (λ ()
     (values
      ;; pos->element: return the event at this position
      (λ (ev) ev)
      ;; next-pos: poll for next event
      (λ (_) (poll-event))
      ;; initial pos: poll for first event
      (poll-event)
      ;; continue-with-pos?: continue while we have an event
      (λ (ev) ev)
      #f
      #f))))

;; ============================================================================
;; Blocking Event Functions
;; ============================================================================

;; Yield to allow async FFI callbacks (like SDL timers) to run.
(define (yield-for-callbacks)
  (sleep 0))

;; Wait indefinitely for the next event. Returns an event struct.
;; Blocks until an event is available.
(define (wait-event)
  (if (SDL-WaitEvent event-buffer)
      (begin
        (yield-for-callbacks)
        (parse-event event-buffer))
      (error 'wait-event "SDL_WaitEvent failed: ~a" (SDL-GetError))))

;; Wait up to timeout-ms milliseconds for the next event.
;; Returns an event struct if one is available, or #f if timed out.
(define (wait-event-timeout timeout-ms)
  (if (SDL-WaitEventTimeout event-buffer timeout-ms)
      (begin
        (yield-for-callbacks)
        (parse-event event-buffer))
      (begin
        (yield-for-callbacks)
        #f)))

;; ============================================================================
;; Key Utilities
;; ============================================================================

;; Get a human-readable name for a key
;; Accepts a keycode (integer) or a key symbol
(define (key-name key)
  (cond
    [(symbol? key) (symbol->string key)]
    [(integer? key) (SDL-GetKeyName key)]
    [else (format "~a" key)]))

;; ============================================================================
;; Modifier Predicates
;; ============================================================================

;; Check if any shift key is pressed
(define (mod-shift? mod)
  (not (zero? (bitwise-and mod SDL_KMOD_SHIFT))))

;; Check if any ctrl key is pressed
(define (mod-ctrl? mod)
  (not (zero? (bitwise-and mod SDL_KMOD_CTRL))))

;; Check if any alt key is pressed
(define (mod-alt? mod)
  (not (zero? (bitwise-and mod SDL_KMOD_ALT))))

;; Check if any gui/command key is pressed
(define (mod-gui? mod)
  (not (zero? (bitwise-and mod SDL_KMOD_GUI))))

;; ============================================================================
;; Event Loop Helpers
;; ============================================================================

;; Check if an event indicates the application should quit
;; Returns #t for:
;;   - quit-event (SDL_QUIT)
;;   - window close-requested
;;   - Escape key pressed
(define (should-quit? ev)
  (match ev
    [(quit-event) #t]
    [(window-event 'close-requested) #t]
    [(key-event 'down 'escape _ _ _) #t]
    [_ #f]))
