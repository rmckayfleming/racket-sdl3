#lang racket/base

;; Idiomatic keyboard state helpers

(require ffi/unsafe
         "../raw.rkt"
         "../private/enums.rkt")

(provide
 ;; Keyboard state
 get-keyboard-state
 key-pressed?

 ;; Modifier state
 get-mod-state
 mod-state-has?

 ;; Scancode/keycode utilities
 scancode-name
 scancode-from-name
 key-from-name
 key-from-scancode
 scancode-from-key

 ;; Reset keyboard
 reset-keyboard!

 ;; Re-export keycodes, scancodes, and modifiers from enums
 (all-from-out "../private/enums.rkt"))

;; =========================================================================
;; Keyboard State
;; =========================================================================

;; Get the keyboard state array and its size
;; Returns a procedure that takes a scancode and returns whether it's pressed
;; Usage: (define kbd (get-keyboard-state))
;;        (when (kbd SDL_SCANCODE_W) ...)
(define (get-keyboard-state)
  (define-values (state-ptr numkeys) (SDL-GetKeyboardState))
  (lambda (scancode)
    (and (>= scancode 0)
         (< scancode numkeys)
         ;; SDL3 returns an array of C99 bool (1 byte each)
         ;; Racket's _bool is 4 bytes, so use _uint8 instead
         (not (zero? (ptr-ref state-ptr _uint8 scancode))))))

;; Check if a specific key (by scancode) is pressed
;; This is a convenience wrapper that gets the keyboard state each time
;; For game loops, prefer using get-keyboard-state once per frame
(define (key-pressed? scancode)
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
