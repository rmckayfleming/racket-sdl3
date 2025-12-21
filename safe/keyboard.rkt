#lang racket/base

;; Idiomatic keyboard state helpers
;;
;; This module provides both symbol-based and scancode-based keyboard APIs.
;; Symbol-based input is preferred for readability:
;;   (key-pressed? 'escape)
;;   (key-pressed? 'w)
;;   (key-pressed? 'left-shift)
;;
;; Scancodes are still available for performance-critical polling or direct use:
;;   (key-pressed? SDL_SCANCODE_W)

(require ffi/unsafe
         racket/match
         "../raw.rkt"
         "../private/enums.rkt"
         "window.rkt")

(provide
 ;; Keyboard enumeration
 has-keyboard?
 get-keyboards
 get-keyboard-count
 get-keyboard-name-for-id
 get-keyboard-focus

 ;; Keyboard state
 get-keyboard-state
 key-pressed?

 ;; Modifier state
 get-mod-state
 mod-state-has?

 ;; Symbol<->scancode/keycode conversion
 symbol->scancode
 scancode->symbol
 symbol->keycode
 keycode->symbol

 ;; Scancode/keycode utilities (raw)
 scancode-name
 scancode-from-name
 key-from-name
 key-from-scancode
 scancode-from-key

 ;; Reset keyboard
 reset-keyboard!

 ;; Text input
 start-text-input!
 stop-text-input!

 ;; Re-export keycodes, scancodes, and modifiers from enums
 (all-from-out "../private/enums.rkt"))

;; =========================================================================
;; Symbol <-> Scancode Mapping
;; =========================================================================
;; Provides idiomatic Racket symbol names for keyboard keys.
;; These map to SDL scancodes (physical key positions).

;; Forward mapping: symbol -> scancode
(define symbol->scancode-table
  (make-hasheq
   (list
    ;; Letter keys (lowercase symbols)
    (cons 'a SDL_SCANCODE_A) (cons 'b SDL_SCANCODE_B) (cons 'c SDL_SCANCODE_C)
    (cons 'd SDL_SCANCODE_D) (cons 'e SDL_SCANCODE_E) (cons 'f SDL_SCANCODE_F)
    (cons 'g SDL_SCANCODE_G) (cons 'h SDL_SCANCODE_H) (cons 'i SDL_SCANCODE_I)
    (cons 'j SDL_SCANCODE_J) (cons 'k SDL_SCANCODE_K) (cons 'l SDL_SCANCODE_L)
    (cons 'm SDL_SCANCODE_M) (cons 'n SDL_SCANCODE_N) (cons 'o SDL_SCANCODE_O)
    (cons 'p SDL_SCANCODE_P) (cons 'q SDL_SCANCODE_Q) (cons 'r SDL_SCANCODE_R)
    (cons 's SDL_SCANCODE_S) (cons 't SDL_SCANCODE_T) (cons 'u SDL_SCANCODE_U)
    (cons 'v SDL_SCANCODE_V) (cons 'w SDL_SCANCODE_W) (cons 'x SDL_SCANCODE_X)
    (cons 'y SDL_SCANCODE_Y) (cons 'z SDL_SCANCODE_Z)

    ;; Number keys
    (cons '0 SDL_SCANCODE_0) (cons '1 SDL_SCANCODE_1) (cons '2 SDL_SCANCODE_2)
    (cons '3 SDL_SCANCODE_3) (cons '4 SDL_SCANCODE_4) (cons '5 SDL_SCANCODE_5)
    (cons '6 SDL_SCANCODE_6) (cons '7 SDL_SCANCODE_7) (cons '8 SDL_SCANCODE_8)
    (cons '9 SDL_SCANCODE_9)

    ;; Special keys
    (cons 'escape SDL_SCANCODE_ESCAPE)
    (cons 'return SDL_SCANCODE_RETURN)
    (cons 'enter SDL_SCANCODE_RETURN)  ; alias
    (cons 'space SDL_SCANCODE_SPACE)
    (cons 'tab SDL_SCANCODE_TAB)
    (cons 'backspace SDL_SCANCODE_BACKSPACE)
    (cons 'delete SDL_SCANCODE_DELETE)
    (cons 'insert SDL_SCANCODE_INSERT)

    ;; Arrow keys
    (cons 'up SDL_SCANCODE_UP)
    (cons 'down SDL_SCANCODE_DOWN)
    (cons 'left SDL_SCANCODE_LEFT)
    (cons 'right SDL_SCANCODE_RIGHT)

    ;; Navigation keys
    (cons 'home SDL_SCANCODE_HOME)
    (cons 'end SDL_SCANCODE_END)
    (cons 'page-up SDL_SCANCODE_PAGEUP)
    (cons 'page-down SDL_SCANCODE_PAGEDOWN)

    ;; Modifier keys
    (cons 'left-shift SDL_SCANCODE_LSHIFT)
    (cons 'right-shift SDL_SCANCODE_RSHIFT)
    (cons 'left-ctrl SDL_SCANCODE_LCTRL)
    (cons 'right-ctrl SDL_SCANCODE_RCTRL)
    (cons 'left-alt SDL_SCANCODE_LALT)
    (cons 'right-alt SDL_SCANCODE_RALT)
    (cons 'left-gui SDL_SCANCODE_LGUI)
    (cons 'right-gui SDL_SCANCODE_RGUI)

    ;; Lock keys
    (cons 'caps-lock SDL_SCANCODE_CAPSLOCK)
    (cons 'scroll-lock SDL_SCANCODE_SCROLLLOCK)
    (cons 'num-lock SDL_SCANCODE_NUMLOCKCLEAR)

    ;; Function keys F1-F12
    (cons 'f1 SDL_SCANCODE_F1) (cons 'f2 SDL_SCANCODE_F2)
    (cons 'f3 SDL_SCANCODE_F3) (cons 'f4 SDL_SCANCODE_F4)
    (cons 'f5 SDL_SCANCODE_F5) (cons 'f6 SDL_SCANCODE_F6)
    (cons 'f7 SDL_SCANCODE_F7) (cons 'f8 SDL_SCANCODE_F8)
    (cons 'f9 SDL_SCANCODE_F9) (cons 'f10 SDL_SCANCODE_F10)
    (cons 'f11 SDL_SCANCODE_F11) (cons 'f12 SDL_SCANCODE_F12)

    ;; Function keys F13-F24
    (cons 'f13 SDL_SCANCODE_F13) (cons 'f14 SDL_SCANCODE_F14)
    (cons 'f15 SDL_SCANCODE_F15) (cons 'f16 SDL_SCANCODE_F16)
    (cons 'f17 SDL_SCANCODE_F17) (cons 'f18 SDL_SCANCODE_F18)
    (cons 'f19 SDL_SCANCODE_F19) (cons 'f20 SDL_SCANCODE_F20)
    (cons 'f21 SDL_SCANCODE_F21) (cons 'f22 SDL_SCANCODE_F22)
    (cons 'f23 SDL_SCANCODE_F23) (cons 'f24 SDL_SCANCODE_F24)

    ;; Punctuation (main keyboard)
    (cons 'minus SDL_SCANCODE_MINUS)
    (cons 'equals SDL_SCANCODE_EQUALS)
    (cons 'left-bracket SDL_SCANCODE_LEFTBRACKET)
    (cons 'right-bracket SDL_SCANCODE_RIGHTBRACKET)
    (cons 'backslash SDL_SCANCODE_BACKSLASH)
    (cons 'semicolon SDL_SCANCODE_SEMICOLON)
    (cons 'apostrophe SDL_SCANCODE_APOSTROPHE)
    (cons 'grave SDL_SCANCODE_GRAVE)
    (cons 'comma SDL_SCANCODE_COMMA)
    (cons 'period SDL_SCANCODE_PERIOD)
    (cons 'slash SDL_SCANCODE_SLASH)

    ;; Keypad numbers
    (cons 'kp-0 SDL_SCANCODE_KP_0) (cons 'kp-1 SDL_SCANCODE_KP_1)
    (cons 'kp-2 SDL_SCANCODE_KP_2) (cons 'kp-3 SDL_SCANCODE_KP_3)
    (cons 'kp-4 SDL_SCANCODE_KP_4) (cons 'kp-5 SDL_SCANCODE_KP_5)
    (cons 'kp-6 SDL_SCANCODE_KP_6) (cons 'kp-7 SDL_SCANCODE_KP_7)
    (cons 'kp-8 SDL_SCANCODE_KP_8) (cons 'kp-9 SDL_SCANCODE_KP_9)

    ;; Keypad operators
    (cons 'kp-divide SDL_SCANCODE_KP_DIVIDE)
    (cons 'kp-multiply SDL_SCANCODE_KP_MULTIPLY)
    (cons 'kp-minus SDL_SCANCODE_KP_MINUS)
    (cons 'kp-plus SDL_SCANCODE_KP_PLUS)
    (cons 'kp-enter SDL_SCANCODE_KP_ENTER)
    (cons 'kp-period SDL_SCANCODE_KP_PERIOD)
    (cons 'kp-equals SDL_SCANCODE_KP_EQUALS)

    ;; Print/Pause
    (cons 'print-screen SDL_SCANCODE_PRINTSCREEN)
    (cons 'pause SDL_SCANCODE_PAUSE)

    ;; Application/Menu
    (cons 'application SDL_SCANCODE_APPLICATION)
    (cons 'menu SDL_SCANCODE_MENU)

    ;; Editing keys
    (cons 'undo SDL_SCANCODE_UNDO)
    (cons 'cut SDL_SCANCODE_CUT)
    (cons 'copy SDL_SCANCODE_COPY)
    (cons 'paste SDL_SCANCODE_PASTE)
    (cons 'find SDL_SCANCODE_FIND)

    ;; Media keys
    (cons 'mute SDL_SCANCODE_MUTE)
    (cons 'volume-up SDL_SCANCODE_VOLUMEUP)
    (cons 'volume-down SDL_SCANCODE_VOLUMEDOWN))))

;; Reverse mapping: scancode -> symbol
(define scancode->symbol-table
  (let ([ht (make-hasheqv)])
    (for ([(sym sc) (in-hash symbol->scancode-table)])
      ;; Don't overwrite if already present (handles aliases like enter/return)
      (unless (hash-has-key? ht sc)
        (hash-set! ht sc sym)))
    ht))

;; Convert a symbol to its corresponding scancode
;; Returns #f if the symbol is not recognized
(define (symbol->scancode sym)
  (hash-ref symbol->scancode-table sym #f))

;; Convert a scancode to its corresponding symbol
;; Returns #f if the scancode has no symbol mapping
(define (scancode->symbol sc)
  (hash-ref scancode->symbol-table sc #f))

;; =========================================================================
;; Symbol <-> Keycode Mapping
;; =========================================================================
;; Keycodes represent the logical key (affected by keyboard layout).
;; Most users should use scancodes for game input (physical key positions).

;; Forward mapping: symbol -> keycode
(define symbol->keycode-table
  (make-hasheq
   (list
    ;; Letter keys (lowercase symbols -> lowercase ASCII keycodes)
    (cons 'a SDLK_A) (cons 'b SDLK_B) (cons 'c SDLK_C)
    (cons 'd SDLK_D) (cons 'e SDLK_E) (cons 'f SDLK_F)
    (cons 'g SDLK_G) (cons 'h SDLK_H) (cons 'i SDLK_I)
    (cons 'j SDLK_J) (cons 'k SDLK_K) (cons 'l SDLK_L)
    (cons 'm SDLK_M) (cons 'n SDLK_N) (cons 'o SDLK_O)
    (cons 'p SDLK_P) (cons 'q SDLK_Q) (cons 'r SDLK_R)
    (cons 's SDLK_S) (cons 't SDLK_T) (cons 'u SDLK_U)
    (cons 'v SDLK_V) (cons 'w SDLK_W) (cons 'x SDLK_X)
    (cons 'y SDLK_Y) (cons 'z SDLK_Z)

    ;; Number keys
    (cons '0 SDLK_0) (cons '1 SDLK_1) (cons '2 SDLK_2)
    (cons '3 SDLK_3) (cons '4 SDLK_4) (cons '5 SDLK_5)
    (cons '6 SDLK_6) (cons '7 SDLK_7) (cons '8 SDLK_8)
    (cons '9 SDLK_9)

    ;; Special keys
    (cons 'escape SDLK_ESCAPE)
    (cons 'return SDLK_RETURN)
    (cons 'enter SDLK_RETURN)  ; alias
    (cons 'space SDLK_SPACE)
    (cons 'tab SDLK_TAB)
    (cons 'backspace SDLK_BACKSPACE)
    (cons 'delete SDLK_DELETE)
    (cons 'insert SDLK_INSERT)

    ;; Arrow keys
    (cons 'up SDLK_UP)
    (cons 'down SDLK_DOWN)
    (cons 'left SDLK_LEFT)
    (cons 'right SDLK_RIGHT)

    ;; Navigation keys
    (cons 'home SDLK_HOME)
    (cons 'end SDLK_END)
    (cons 'page-up SDLK_PAGEUP)
    (cons 'page-down SDLK_PAGEDOWN)

    ;; Modifier keys
    (cons 'left-shift SDLK_LSHIFT)
    (cons 'right-shift SDLK_RSHIFT)
    (cons 'left-ctrl SDLK_LCTRL)
    (cons 'right-ctrl SDLK_RCTRL)
    (cons 'left-alt SDLK_LALT)
    (cons 'right-alt SDLK_RALT)
    (cons 'left-gui SDLK_LGUI)
    (cons 'right-gui SDLK_RGUI)

    ;; Lock keys
    (cons 'caps-lock SDLK_CAPSLOCK)
    (cons 'scroll-lock SDLK_SCROLLLOCK)
    (cons 'num-lock SDLK_NUMLOCKCLEAR)

    ;; Function keys F1-F12
    (cons 'f1 SDLK_F1) (cons 'f2 SDLK_F2)
    (cons 'f3 SDLK_F3) (cons 'f4 SDLK_F4)
    (cons 'f5 SDLK_F5) (cons 'f6 SDLK_F6)
    (cons 'f7 SDLK_F7) (cons 'f8 SDLK_F8)
    (cons 'f9 SDLK_F9) (cons 'f10 SDLK_F10)
    (cons 'f11 SDLK_F11) (cons 'f12 SDLK_F12)

    ;; Function keys F13-F24
    (cons 'f13 SDLK_F13) (cons 'f14 SDLK_F14)
    (cons 'f15 SDLK_F15) (cons 'f16 SDLK_F16)
    (cons 'f17 SDLK_F17) (cons 'f18 SDLK_F18)
    (cons 'f19 SDLK_F19) (cons 'f20 SDLK_F20)
    (cons 'f21 SDLK_F21) (cons 'f22 SDLK_F22)
    (cons 'f23 SDLK_F23) (cons 'f24 SDLK_F24)

    ;; Punctuation
    (cons 'minus SDLK_MINUS)
    (cons 'equals SDLK_EQUALS)
    (cons 'left-bracket SDLK_LEFTBRACKET)
    (cons 'right-bracket SDLK_RIGHTBRACKET)
    (cons 'backslash SDLK_BACKSLASH)
    (cons 'semicolon SDLK_SEMICOLON)
    (cons 'apostrophe SDLK_APOSTROPHE)
    (cons 'grave SDLK_GRAVE)
    (cons 'comma SDLK_COMMA)
    (cons 'period SDLK_PERIOD)
    (cons 'slash SDLK_SLASH)

    ;; Keypad numbers
    (cons 'kp-0 SDLK_KP_0) (cons 'kp-1 SDLK_KP_1)
    (cons 'kp-2 SDLK_KP_2) (cons 'kp-3 SDLK_KP_3)
    (cons 'kp-4 SDLK_KP_4) (cons 'kp-5 SDLK_KP_5)
    (cons 'kp-6 SDLK_KP_6) (cons 'kp-7 SDLK_KP_7)
    (cons 'kp-8 SDLK_KP_8) (cons 'kp-9 SDLK_KP_9)

    ;; Keypad operators
    (cons 'kp-divide SDLK_KP_DIVIDE)
    (cons 'kp-multiply SDLK_KP_MULTIPLY)
    (cons 'kp-minus SDLK_KP_MINUS)
    (cons 'kp-plus SDLK_KP_PLUS)
    (cons 'kp-enter SDLK_KP_ENTER)
    (cons 'kp-period SDLK_KP_PERIOD)
    (cons 'kp-equals SDLK_KP_EQUALS)

    ;; Print/Pause
    (cons 'print-screen SDLK_PRINTSCREEN)
    (cons 'pause SDLK_PAUSE)

    ;; Application/Menu
    (cons 'application SDLK_APPLICATION)
    (cons 'menu SDLK_MENU)

    ;; Editing keys
    (cons 'undo SDLK_UNDO)
    (cons 'cut SDLK_CUT)
    (cons 'copy SDLK_COPY)
    (cons 'paste SDLK_PASTE)
    (cons 'find SDLK_FIND)

    ;; Media keys
    (cons 'mute SDLK_MUTE)
    (cons 'volume-up SDLK_VOLUMEUP)
    (cons 'volume-down SDLK_VOLUMEDOWN))))

;; Reverse mapping: keycode -> symbol
(define keycode->symbol-table
  (let ([ht (make-hasheqv)])
    (for ([(sym kc) (in-hash symbol->keycode-table)])
      ;; Don't overwrite if already present (handles aliases like enter/return)
      (unless (hash-has-key? ht kc)
        (hash-set! ht kc sym)))
    ht))

;; Convert a symbol to its corresponding keycode
;; Returns #f if the symbol is not recognized
(define (symbol->keycode sym)
  (hash-ref symbol->keycode-table sym #f))

;; Convert a keycode to its corresponding symbol
;; Returns #f if the keycode has no symbol mapping
(define (keycode->symbol kc)
  (hash-ref keycode->symbol-table kc #f))

;; =========================================================================
;; Keyboard Enumeration
;; =========================================================================

(define (has-keyboard?)
  (SDL-HasKeyboard))

;; Get list of keyboard instance IDs
(define (get-keyboards)
  (define-values (arr count) (SDL-GetKeyboards))
  (if (or (not arr) (zero? count))
      '()
      (begin0
        (for/list ([i (in-range count)])
          (ptr-ref arr _uint32 i))
        (SDL-free arr))))

(define (get-keyboard-count)
  (length (get-keyboards)))

;; Get the name of a keyboard by instance ID
(define (get-keyboard-name-for-id instance-id)
  (SDL-GetKeyboardNameForID instance-id))

;; Get the window that currently has keyboard focus (or #f)
(define (get-keyboard-focus)
  (SDL-GetKeyboardFocus))

;; =========================================================================
;; Keyboard State
;; =========================================================================

;; Internal helper: convert key argument to scancode
;; Accepts symbol or integer scancode
(define (key->scancode key)
  (cond
    [(symbol? key)
     (or (symbol->scancode key)
         (error 'key->scancode "Unknown key symbol: ~a" key))]
    [(exact-nonnegative-integer? key) key]
    [else (error 'key->scancode "Expected symbol or scancode, got: ~a" key)]))

;; Get the keyboard state array and its size
;; Returns a procedure that takes a symbol or scancode and returns whether it's pressed
;; Usage: (define kbd (get-keyboard-state))
;;        (when (kbd 'w) ...)        ; symbol-based (preferred)
;;        (when (kbd SDL_SCANCODE_W) ...) ; scancode (also works)
(define (get-keyboard-state)
  (define-values (state-ptr numkeys) (SDL-GetKeyboardState))
  (lambda (key)
    (define scancode (key->scancode key))
    (and (>= scancode 0)
         (< scancode numkeys)
         ;; SDL3 returns an array of C99 bool (1 byte each)
         ;; Racket's _bool is 4 bytes, so use _uint8 instead
         (not (zero? (ptr-ref state-ptr _uint8 scancode))))))

;; Check if a specific key is pressed
;; Accepts a symbol ('w, 'escape, 'left-shift, etc.) or a scancode integer
;; This is a convenience wrapper that gets the keyboard state each time
;; For game loops, prefer using get-keyboard-state once per frame
;;
;; Examples:
;;   (key-pressed? 'escape)
;;   (key-pressed? 'w)
;;   (key-pressed? 'left-shift)
;;   (key-pressed? SDL_SCANCODE_W)  ; also works
(define (key-pressed? key)
  (define scancode (key->scancode key))
  (define-values (state-ptr numkeys) (SDL-GetKeyboardState))
  (and (>= scancode 0)
       (< scancode numkeys)
       (not (zero? (ptr-ref state-ptr _uint8 scancode)))))

;; =========================================================================
;; Modifier State
;; =========================================================================

;; Get the current modifier key state
;; Returns a bitmask of SDL_KMOD_* values
(define (get-mod-state)
  (SDL-GetModState))

;; Check if a specific modifier is active
;; mod-flag should be an SDL_KMOD_* constant
(define (mod-state-has? mod-flag)
  (not (zero? (bitwise-and (SDL-GetModState) mod-flag))))

;; =========================================================================
;; Scancode/Keycode Utilities
;; =========================================================================

;; Get the name of a scancode
(define (scancode-name scancode)
  (SDL-GetScancodeName scancode))

;; Get a scancode from its name
;; Returns SDL_SCANCODE_UNKNOWN (0) if not found
(define (scancode-from-name name)
  (SDL-GetScancodeFromName name))

;; Get a keycode from its name
;; Returns SDLK_UNKNOWN (0) if not found
(define (key-from-name name)
  (SDL-GetKeyFromName name))

;; Get the keycode for a scancode according to current keyboard layout
;; mod: modifier state (use SDL_KMOD_NONE for no modifiers)
;; key-event?: if true, returns keycode as it would appear in key events
(define (key-from-scancode scancode [mod SDL_KMOD_NONE] [key-event? #t])
  (SDL-GetKeyFromScancode scancode mod key-event?))

;; Get the scancode for a keycode
;; Returns: (values scancode modstate)
;; modstate indicates which modifiers would be used to generate this keycode
(define (scancode-from-key keycode)
  (define mod-ptr (malloc _uint16 'atomic-interior))
  (define sc (SDL-GetScancodeFromKey keycode mod-ptr))
  (values sc (ptr-ref mod-ptr _uint16)))

;; =========================================================================
;; Keyboard Control
;; =========================================================================

;; Clear the keyboard state
;; This generates key up events for all pressed keys
(define (reset-keyboard!)
  (SDL-ResetKeyboard))

;; =========================================================================
;; Text Input
;; =========================================================================

;; Start accepting text input events for a window
;; This enables the text-input-event in the event stream
(define (start-text-input! win)
  (unless (SDL-StartTextInput (window-ptr win))
    (error 'start-text-input! "Failed to start text input: ~a" (SDL-GetError))))

;; Stop accepting text input events for a window
(define (stop-text-input! win)
  (unless (SDL-StopTextInput (window-ptr win))
    (error 'stop-text-input! "Failed to stop text input: ~a" (SDL-GetError))))
