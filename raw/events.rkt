#lang racket/base

;; SDL3 Event Handling
;;
;; Functions for polling and managing events.

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide SDL-PollEvent
         SDL-WaitEvent
         SDL-WaitEventTimeout
         SDL-PumpEvents)

;; ============================================================================
;; Events
;; ============================================================================

;; SDL_PollEvent: Poll for currently pending events
;; event: Pointer to an SDL_Event structure (at least 128 bytes)
;; Returns: true if there is a pending event, false otherwise
(define-sdl SDL-PollEvent (_fun _pointer -> _sdl-bool)
  #:c-id SDL_PollEvent)

;; SDL_WaitEvent: Wait indefinitely for the next available event
;; event: Pointer to an SDL_Event structure (at least 128 bytes)
;; Returns: true on success, false on error
(define-sdl SDL-WaitEvent (_fun #:blocking? #t _pointer -> _sdl-bool)
  #:c-id SDL_WaitEvent)

;; SDL_WaitEventTimeout: Wait until timeout for the next available event
;; event: Pointer to an SDL_Event structure (at least 128 bytes)
;; timeoutMS: Maximum time to wait in milliseconds (-1 to wait indefinitely)
;; Returns: true if an event is available, false if timed out or error
(define-sdl SDL-WaitEventTimeout (_fun #:blocking? #t _pointer _sint32 -> _sdl-bool)
  #:c-id SDL_WaitEventTimeout)

;; SDL_PumpEvents: Pump the event loop, gathering events from input devices
;; This should be called periodically to update the event queue.
;; Note: SDL_PollEvent and SDL_WaitEvent implicitly call this.
(define-sdl SDL-PumpEvents (_fun -> _void)
  #:c-id SDL_PumpEvents)
