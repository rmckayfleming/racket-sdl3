#lang racket/base

;; Idiomatic mouse helpers

(require ffi/unsafe
         "../raw.rkt"
         "../private/constants.rkt"
         "window.rkt")

(provide
 ;; Mouse state
 get-mouse-state
 get-relative-mouse-state
 get-global-mouse-state
 mouse-button-pressed?

 ;; Mouse warping
 warp-mouse!
 warp-mouse-global!

 ;; Mouse capture
 capture-mouse!

 ;; Relative mouse mode (FPS-style)
 set-relative-mouse-mode!
 relative-mouse-mode?

 ;; Cursor visibility
 show-cursor!
 hide-cursor!
 cursor-visible?

 ;; System cursors
 with-system-cursor
 create-system-cursor
 set-cursor!
 destroy-cursor!

 ;; Cursor type symbols
 symbol->system-cursor
 system-cursor->symbol

 ;; Re-export mouse button constants
 SDL_BUTTON_LEFT
 SDL_BUTTON_MIDDLE
 SDL_BUTTON_RIGHT
 SDL_BUTTON_X1
 SDL_BUTTON_X2
 SDL_BUTTON_LMASK
 SDL_BUTTON_MMASK
 SDL_BUTTON_RMASK
 SDL_BUTTON_X1MASK
 SDL_BUTTON_X2MASK)

;; =========================================================================
;; Mouse State
;; =========================================================================

(define (get-mouse-state)
  (define x-ptr (malloc _float 'atomic-interior))
  (define y-ptr (malloc _float 'atomic-interior))
  (define mask (SDL-GetMouseState x-ptr y-ptr))
  (values (ptr-ref x-ptr _float)
          (ptr-ref y-ptr _float)
          mask))

(define (get-relative-mouse-state)
  (SDL-GetRelativeMouseState))

(define (mouse-button-pressed? mask button)
  (not (zero? (bitwise-and mask button))))

;; Get the mouse state in global screen coordinates
;; Returns: (values x y buttons)
(define (get-global-mouse-state)
  (define-values (buttons x y) (SDL-GetGlobalMouseState))
  (values x y buttons))

;; =========================================================================
;; Mouse Warping
;; =========================================================================

;; Move the mouse cursor to a position within a window
;; win: window struct, or #f to use the currently focused window
;; x, y: coordinates within the window
(define (warp-mouse! win x y)
  (SDL-WarpMouseInWindow (if win (window-ptr win) #f)
                         (exact->inexact x)
                         (exact->inexact y)))

;; Move the mouse cursor to a position in global screen space
;; x, y: screen coordinates
;; Note: May not be supported on all platforms
(define (warp-mouse-global! x y)
  (unless (SDL-WarpMouseGlobal (exact->inexact x) (exact->inexact y))
    (error 'warp-mouse-global! "Failed to warp mouse: ~a" (SDL-GetError))))

;; =========================================================================
;; Mouse Capture
;; =========================================================================

;; Enable or disable mouse capture
;; When enabled, the window receives mouse events even when the cursor
;; is outside the window (useful for drag operations)
(define (capture-mouse! enabled?)
  (unless (SDL-CaptureMouse enabled?)
    (error 'capture-mouse! "Failed to capture mouse: ~a" (SDL-GetError))))

;; =========================================================================
;; Relative Mouse Mode (FPS-style input)
;; =========================================================================

;; Enable/disable relative mouse mode for a window
;; When enabled, the cursor is hidden and mouse motion reports relative deltas
(define (set-relative-mouse-mode! win on?)
  (unless (SDL-SetWindowRelativeMouseMode (window-ptr win) on?)
    (error 'set-relative-mouse-mode! "Failed to set relative mouse mode: ~a"
           (SDL-GetError))))

;; Check if relative mouse mode is enabled for a window
(define (relative-mouse-mode? win)
  (SDL-GetWindowRelativeMouseMode (window-ptr win)))

;; =========================================================================
;; Cursor Visibility
;; =========================================================================

(define (show-cursor!)
  (unless (SDL-ShowCursor)
    (error 'show-cursor! "Failed to show cursor: ~a" (SDL-GetError))))

(define (hide-cursor!)
  (unless (SDL-HideCursor)
    (error 'hide-cursor! "Failed to hide cursor: ~a" (SDL-GetError))))

(define (cursor-visible?)
  (SDL-CursorVisible))

;; =========================================================================
;; System Cursor Type Conversion
;; =========================================================================

(define (symbol->system-cursor sym)
  (case sym
    [(default arrow) SDL_SYSTEM_CURSOR_DEFAULT]
    [(text ibeam) SDL_SYSTEM_CURSOR_TEXT]
    [(wait hourglass) SDL_SYSTEM_CURSOR_WAIT]
    [(crosshair) SDL_SYSTEM_CURSOR_CROSSHAIR]
    [(progress) SDL_SYSTEM_CURSOR_PROGRESS]
    [(nwse-resize) SDL_SYSTEM_CURSOR_NWSE_RESIZE]
    [(nesw-resize) SDL_SYSTEM_CURSOR_NESW_RESIZE]
    [(ew-resize) SDL_SYSTEM_CURSOR_EW_RESIZE]
    [(ns-resize) SDL_SYSTEM_CURSOR_NS_RESIZE]
    [(move) SDL_SYSTEM_CURSOR_MOVE]
    [(not-allowed no) SDL_SYSTEM_CURSOR_NOT_ALLOWED]
    [(pointer hand link) SDL_SYSTEM_CURSOR_POINTER]
    [(nw-resize) SDL_SYSTEM_CURSOR_NW_RESIZE]
    [(n-resize) SDL_SYSTEM_CURSOR_N_RESIZE]
    [(ne-resize) SDL_SYSTEM_CURSOR_NE_RESIZE]
    [(e-resize) SDL_SYSTEM_CURSOR_E_RESIZE]
    [(se-resize) SDL_SYSTEM_CURSOR_SE_RESIZE]
    [(s-resize) SDL_SYSTEM_CURSOR_S_RESIZE]
    [(sw-resize) SDL_SYSTEM_CURSOR_SW_RESIZE]
    [(w-resize) SDL_SYSTEM_CURSOR_W_RESIZE]
    [else (error 'symbol->system-cursor
                 "unknown cursor type: ~a" sym)]))

(define (system-cursor->symbol id)
  (cond
    [(= id SDL_SYSTEM_CURSOR_DEFAULT) 'default]
    [(= id SDL_SYSTEM_CURSOR_TEXT) 'text]
    [(= id SDL_SYSTEM_CURSOR_WAIT) 'wait]
    [(= id SDL_SYSTEM_CURSOR_CROSSHAIR) 'crosshair]
    [(= id SDL_SYSTEM_CURSOR_PROGRESS) 'progress]
    [(= id SDL_SYSTEM_CURSOR_NWSE_RESIZE) 'nwse-resize]
    [(= id SDL_SYSTEM_CURSOR_NESW_RESIZE) 'nesw-resize]
    [(= id SDL_SYSTEM_CURSOR_EW_RESIZE) 'ew-resize]
    [(= id SDL_SYSTEM_CURSOR_NS_RESIZE) 'ns-resize]
    [(= id SDL_SYSTEM_CURSOR_MOVE) 'move]
    [(= id SDL_SYSTEM_CURSOR_NOT_ALLOWED) 'not-allowed]
    [(= id SDL_SYSTEM_CURSOR_POINTER) 'pointer]
    [(= id SDL_SYSTEM_CURSOR_NW_RESIZE) 'nw-resize]
    [(= id SDL_SYSTEM_CURSOR_N_RESIZE) 'n-resize]
    [(= id SDL_SYSTEM_CURSOR_NE_RESIZE) 'ne-resize]
    [(= id SDL_SYSTEM_CURSOR_E_RESIZE) 'e-resize]
    [(= id SDL_SYSTEM_CURSOR_SE_RESIZE) 'se-resize]
    [(= id SDL_SYSTEM_CURSOR_S_RESIZE) 's-resize]
    [(= id SDL_SYSTEM_CURSOR_SW_RESIZE) 'sw-resize]
    [(= id SDL_SYSTEM_CURSOR_W_RESIZE) 'w-resize]
    [else 'unknown]))

;; =========================================================================
;; System Cursors
;; =========================================================================

;; Create a system cursor from a type symbol or SDL constant
(define (create-system-cursor cursor-type)
  (define id (if (symbol? cursor-type)
                 (symbol->system-cursor cursor-type)
                 cursor-type))
  (define ptr (SDL-CreateSystemCursor id))
  (unless ptr
    (error 'create-system-cursor "Failed to create cursor: ~a" (SDL-GetError)))
  ptr)

;; Set the active cursor (can be #f to reset to default)
(define (set-cursor! cursor)
  (unless (SDL-SetCursor cursor)
    (error 'set-cursor! "Failed to set cursor: ~a" (SDL-GetError))))

;; Destroy a cursor (call when done with a created cursor)
(define (destroy-cursor! cursor)
  (SDL-DestroyCursor cursor))

;; Temporarily use a system cursor, then restore the previous one
;; Usage: (with-system-cursor 'crosshair body ...)
(define-syntax-rule (with-system-cursor cursor-type body ...)
  (let ([old-cursor (SDL-GetCursor)]
        [new-cursor (create-system-cursor cursor-type)])
    (dynamic-wind
      (λ () (set-cursor! new-cursor))
      (λ () body ...)
      (λ ()
        (set-cursor! old-cursor)
        (destroy-cursor! new-cursor)))))
