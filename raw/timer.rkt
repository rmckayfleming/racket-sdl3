#lang racket/base

;; SDL3 Timer Functions
;;
;; Functions for timing and delays.

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide SDL-GetTicks
         SDL-GetTicksNS
         SDL-GetPerformanceCounter
         SDL-GetPerformanceFrequency
         SDL-Delay
         SDL-DelayNS
         SDL-DelayPrecise
         SDL-AddTimer
         SDL-AddTimerNS
         SDL-RemoveTimer)

;; ============================================================================
;; Timer
;; ============================================================================

;; SDL_GetTicks: Get the number of milliseconds since SDL library initialization
;; Returns: Uint64 milliseconds since SDL_Init was called
(define-sdl SDL-GetTicks (_fun -> _uint64)
  #:c-id SDL_GetTicks)

;; SDL_GetTicksNS: Get the number of nanoseconds since SDL library initialization
;; Returns: Uint64 nanoseconds since SDL_Init was called
(define-sdl SDL-GetTicksNS (_fun -> _uint64)
  #:c-id SDL_GetTicksNS)

;; SDL_GetPerformanceCounter: Get the current value of the high resolution counter
;; Use for profiling. Values are only meaningful relative to each other.
;; Convert differences to time using SDL_GetPerformanceFrequency.
;; Returns: Uint64 current counter value
(define-sdl SDL-GetPerformanceCounter (_fun -> _uint64)
  #:c-id SDL_GetPerformanceCounter)

;; SDL_GetPerformanceFrequency: Get the count per second of the high resolution counter
;; Returns: Uint64 platform-specific counts per second
(define-sdl SDL-GetPerformanceFrequency (_fun -> _uint64)
  #:c-id SDL_GetPerformanceFrequency)

;; SDL_Delay: Wait a specified number of milliseconds before returning
;; ms: The number of milliseconds to delay
(define-sdl SDL-Delay (_fun #:blocking? #t _uint32 -> _void)
  #:c-id SDL_Delay)

;; SDL_DelayNS: Wait a specified number of nanoseconds before returning
;; ns: The number of nanoseconds to delay
(define-sdl SDL-DelayNS (_fun #:blocking? #t _uint64 -> _void)
  #:c-id SDL_DelayNS)

;; SDL_DelayPrecise: Wait a specified number of nanoseconds with busy-waiting
;; More precise than SDL_DelayNS, but uses more CPU. Good for frame timing.
;; ns: The number of nanoseconds to delay
(define-sdl SDL-DelayPrecise (_fun #:blocking? #t _uint64 -> _void)
  #:c-id SDL_DelayPrecise)

;; SDL_AddTimer: Call a callback after a specified delay (milliseconds)
;; interval: delay in milliseconds
;; callback: SDL_TimerCallback
;; userdata: pointer passed to callback (use #f for NULL)
;; Returns: SDL_TimerID or 0 on failure
(define-sdl SDL-AddTimer
  (_fun _uint32 _SDL_TimerCallback _pointer -> _SDL_TimerID)
  #:c-id SDL_AddTimer)

;; SDL_AddTimerNS: Call a callback after a specified delay (nanoseconds)
;; interval: delay in nanoseconds
;; callback: SDL_NSTimerCallback
;; userdata: pointer passed to callback (use #f for NULL)
;; Returns: SDL_TimerID or 0 on failure
(define-sdl SDL-AddTimerNS
  (_fun _uint64 _SDL_NSTimerCallback _pointer -> _SDL_TimerID)
  #:c-id SDL_AddTimerNS)

;; SDL_RemoveTimer: Remove a timer created with SDL_AddTimer/SDL_AddTimerNS
;; id: the timer ID to remove
;; Returns: #t on success, #f on failure
(define-sdl SDL-RemoveTimer
  (_fun _SDL_TimerID -> _sdl-bool)
  #:c-id SDL_RemoveTimer)
