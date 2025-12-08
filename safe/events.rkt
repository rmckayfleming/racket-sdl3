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

 unknown-event unknown-event? unknown-event-type

 ;; Polling functions
 poll-event
 in-events

 ;; Re-export key constants for convenience
 SDLK_ESCAPE SDLK_SPACE
 SDLK_r SDLK_g SDLK_b
 SDLK_R SDLK_G SDLK_B
 SDLK_UP SDLK_DOWN SDLK_LEFT SDLK_RIGHT)

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
;; button is SDL_BUTTON_LEFT, SDL_BUTTON_RIGHT, etc.
;; x, y are position (floats)
;; clicks is click count (1 for single, 2 for double, etc.)

;; Text input (actual characters, handles shift/caps)
(struct text-input-event sdl-event (text) #:transparent)
;; text is a string

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
                (not (zero? (SDL_KeyboardEvent-repeat kb))))]

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
                         (SDL_MouseButtonEvent-button mb)
                         (SDL_MouseButtonEvent-x mb)
                         (SDL_MouseButtonEvent-y mb)
                         (SDL_MouseButtonEvent-clicks mb))]

    ;; Text input
    [(= type SDL_EVENT_TEXT_INPUT)
     (define ti (event->text-input buf))
     (define text-ptr (SDL_TextInputEvent-text ti))
     (define text (cast text-ptr _pointer _string/utf-8))
     (text-input-event text)]

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
