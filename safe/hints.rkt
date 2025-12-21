#lang racket/base

;; Idiomatic wrappers for SDL hints API
;;
;; Hints are configuration variables that affect SDL's behavior.
;; They can be set before or during SDL initialization.
;;
;; Hint names are specified as symbols:
;;   (set-hint! 'render-vsync "1")
;;   (get-hint 'app-name)

(require "../raw/hints.rkt"
         "../private/constants.rkt")

(provide
 ;; Core hint operations
 set-hint!
 get-hint
 get-hint-boolean
 reset-hint!
 reset-all-hints!

 ;; Convenience wrappers for common hints
 set-app-name!
 set-app-id!
 set-render-driver!
 allow-screensaver!)

;; ============================================================================
;; Symbol-based Hint Name Mappings
;; ============================================================================

;; Hint name symbols -> SDL hint strings
;; Usage: (set-hint! 'render-vsync "1") or (get-hint 'app-name)
(define hint-name-table
  (hasheq 'app-name                  SDL_HINT_APP_NAME
          'app-id                    SDL_HINT_APP_ID
          'render-driver             SDL_HINT_RENDER_DRIVER
          'render-vsync              SDL_HINT_RENDER_VSYNC
          'video-allow-screensaver   SDL_HINT_VIDEO_ALLOW_SCREENSAVER
          'framebuffer-acceleration  SDL_HINT_FRAMEBUFFER_ACCELERATION
          'mouse-relative-mode-warp  SDL_HINT_MOUSE_RELATIVE_MODE_WARP))

;; Convert a hint name symbol to string
(define (hint-name->string name)
  (hash-ref hint-name-table name
            (lambda () (error 'hint-name->string
                              "unknown hint name: ~a (expected one of: ~a)"
                              name (hash-keys hint-name-table)))))

;; ============================================================================
;; Core Hint Operations
;; ============================================================================

;; Set a hint value
;; name is a symbol ('render-vsync, 'app-name, etc.)
;; priority can be 'default, 'normal, or 'override
;; Examples:
;;   (set-hint! 'render-vsync "1")
;;   (set-hint! 'app-name "My App" 'override)
(define (set-hint! name value [priority 'normal])
  (define pri (case priority
                [(default) SDL_HINT_DEFAULT]
                [(normal) SDL_HINT_NORMAL]
                [(override) SDL_HINT_OVERRIDE]
                [else (error 'set-hint!
                             "priority must be 'default, 'normal, or 'override; got ~e"
                             priority)]))
  (SDL-SetHintWithPriority (hint-name->string name) value pri))

;; Get a hint value, returns #f if not set
(define (get-hint name)
  (SDL-GetHint (hint-name->string name)))

;; Get a hint as a boolean, with default value
(define (get-hint-boolean name default)
  (SDL-GetHintBoolean (hint-name->string name) default))

;; Reset a hint to its default value
(define (reset-hint! name)
  (SDL-ResetHint (hint-name->string name)))

;; Reset all hints to their default values
(define (reset-all-hints!)
  (SDL-ResetHints))

;; ============================================================================
;; Convenience Wrappers for Common Hints
;; ============================================================================

;; Set the application name (shown in audio controls, taskbar, etc.)
;; Should be called before sdl-init!
(define (set-app-name! name)
  (set-hint! 'app-name name))

;; Set the application ID (used by desktop compositors)
;; Should be called before sdl-init!
(define (set-app-id! id)
  (set-hint! 'app-id id))

;; Set the render driver to use ("opengl", "metal", "vulkan", "software", etc.)
;; Should be called before creating a renderer
(define (set-render-driver! driver)
  (set-hint! 'render-driver driver))

;; Allow or prevent the screensaver from activating
(define (allow-screensaver! enabled?)
  (set-hint! 'video-allow-screensaver (if enabled? "1" "0")))
