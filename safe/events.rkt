#lang racket/base

;; Idiomatic event handling with Racket structs and match support

(require ffi/unsafe
         racket/match
         "../raw.rkt")

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
;; key is the SDL keycode (integer)
;; scancode is the physical key scancode (integer)
;; mod is modifier flags (integer)
;; repeat? is #t if this is a key repeat

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
     (key-event (if (= type SDL_EVENT_KEY_DOWN) 'down 'up)
                (SDL_KeyboardEvent-key kb)
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

;; Wait indefinitely for the next event. Returns an event struct.
;; Blocks until an event is available.
(define (wait-event)
  (if (SDL-WaitEvent event-buffer)
      (parse-event event-buffer)
      (error 'wait-event "SDL_WaitEvent failed: ~a" (SDL-GetError))))

;; Wait up to timeout-ms milliseconds for the next event.
;; Returns an event struct if one is available, or #f if timed out.
(define (wait-event-timeout timeout-ms)
  (if (SDL-WaitEventTimeout event-buffer timeout-ms)
      (parse-event event-buffer)
      #f))

;; ============================================================================
;; Key Utilities
;; ============================================================================

;; Get a human-readable name for a keycode
(define (key-name keycode)
  (SDL-GetKeyName keycode))

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
    [(key-event 'down (== SDLK_ESCAPE) _ _ _) #t]
    [_ #f]))
