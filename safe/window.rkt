#lang racket/base

;; Idiomatic window and renderer management with custodian-based cleanup

(require ffi/unsafe
         ffi/unsafe/custodian
         "../raw.rkt"
         "../private/safe-syntax.rkt")

(provide
 ;; Initialization
 sdl-init!
 sdl-init-subsystem!
 sdl-quit!
 sdl-quit-subsystem!
 sdl-was-init
 set-app-metadata!
 set-app-metadata-property!
 get-app-metadata-property

 ;; Window management
 make-window
 window?
 window-ptr
 window-destroy!
 window-set-title!
 window-title
 window-pixel-density
 window-size
 window-set-size!
 window-position
 window-set-position!
 window-fullscreen?
 window-set-fullscreen!

 ;; Window visibility
 show-window!
 hide-window!
 raise-window!

 ;; Window state
 maximize-window!
 minimize-window!
 restore-window!

 ;; Window properties
 window-id
 window-from-id
 set-window-icon!

 ;; Size constraints
 set-window-minimum-size!
 set-window-maximum-size!
 window-minimum-size
 window-maximum-size

 ;; Decoration
 set-window-bordered!
 set-window-resizable!

 ;; Effects
 window-opacity
 set-window-opacity!
 flash-window!

 ;; Renderer management
 make-renderer
 renderer?
 renderer-ptr
 renderer-destroy!

 ;; Convenience
 make-window+renderer

 ;; Re-export window flags
 SDL_WINDOW_FULLSCREEN
 SDL_WINDOW_RESIZABLE
 SDL_WINDOW_HIGH_PIXEL_DENSITY

 ;; Re-export flash operations
 SDL_FLASH_CANCEL
 SDL_FLASH_BRIEFLY
 SDL_FLASH_UNTIL_FOCUSED

 ;; Re-export init flags
 SDL_INIT_VIDEO
 SDL_INIT_AUDIO
 SDL_INIT_EVENTS
 SDL_INIT_JOYSTICK
 SDL_INIT_GAMEPAD

 ;; Re-export app metadata property names
 SDL_PROP_APP_METADATA_NAME_STRING
 SDL_PROP_APP_METADATA_VERSION_STRING
 SDL_PROP_APP_METADATA_IDENTIFIER_STRING
 SDL_PROP_APP_METADATA_CREATOR_STRING
 SDL_PROP_APP_METADATA_COPYRIGHT_STRING
 SDL_PROP_APP_METADATA_URL_STRING
 SDL_PROP_APP_METADATA_TYPE_STRING)

;; ============================================================================
;; Resource wrapper structs
;; ============================================================================

(define-sdl-resource window SDL-DestroyWindow)
(define-sdl-resource renderer SDL-DestroyRenderer)

;; ============================================================================
;; Initialization
;; ============================================================================

(define (sdl-init! [flags SDL_INIT_VIDEO])
  (unless (SDL-Init flags)
    (error 'sdl-init! "Failed to initialize SDL: ~a" (SDL-GetError))))

(define (sdl-init-subsystem! flags)
  (unless (SDL-InitSubSystem flags)
    (error 'sdl-init-subsystem! "Failed to initialize subsystem: ~a" (SDL-GetError))))

(define (sdl-quit!)
  (SDL-Quit))

(define (sdl-quit-subsystem! flags)
  (SDL-QuitSubSystem flags))

(define (sdl-was-init [flags 0])
  (SDL-WasInit flags))

;; ============================================================================
;; App Metadata
;; ============================================================================

(define (set-app-metadata! name version identifier)
  (unless (SDL-SetAppMetadata name version identifier)
    (error 'set-app-metadata! "Failed to set app metadata: ~a" (SDL-GetError))))

(define (set-app-metadata-property! name value)
  (unless (SDL-SetAppMetadataProperty name value)
    (error 'set-app-metadata-property! "Failed to set app metadata property: ~a" (SDL-GetError))))

(define (get-app-metadata-property name)
  (SDL-GetAppMetadataProperty name))

;; ============================================================================
;; Window Management
;; ============================================================================

(define (make-window title width height
                     #:flags [flags 0]
                     #:custodian [cust (current-custodian)])
  (define ptr (SDL-CreateWindow title width height flags))
  (unless ptr
    (error 'make-window "Failed to create window: ~a" (SDL-GetError)))
  (wrap-window ptr #:custodian cust))

(define (window-set-title! win title)
  (SDL-SetWindowTitle (window-ptr win) title))

(define (window-pixel-density win)
  (SDL-GetWindowPixelDensity (window-ptr win)))

;; Get the size of a window's client area
;; Returns: (values width height)
(define (window-size win)
  (define-values (success w h) (SDL-GetWindowSize (window-ptr win)))
  (unless success
    (error 'window-size "Failed to get window size: ~a" (SDL-GetError)))
  (values w h))

;; Set the size of a window's client area
(define (window-set-size! win w h)
  (unless (SDL-SetWindowSize (window-ptr win) w h)
    (error 'window-set-size! "Failed to set window size: ~a" (SDL-GetError))))

;; Get the position of a window
;; Returns: (values x y)
(define (window-position win)
  (define-values (success x y) (SDL-GetWindowPosition (window-ptr win)))
  (unless success
    (error 'window-position "Failed to get window position: ~a" (SDL-GetError)))
  (values x y))

;; Set the position of a window
(define (window-set-position! win x y)
  (unless (SDL-SetWindowPosition (window-ptr win) x y)
    (error 'window-set-position! "Failed to set window position: ~a" (SDL-GetError))))

;; Check if window is fullscreen
(define (window-fullscreen? win)
  (not (zero? (bitwise-and (SDL-GetWindowFlags (window-ptr win))
                           SDL_WINDOW_FULLSCREEN))))

;; Set window fullscreen mode
(define (window-set-fullscreen! win fullscreen?)
  (unless (SDL-SetWindowFullscreen (window-ptr win) fullscreen?)
    (error 'window-set-fullscreen! "Failed to set fullscreen: ~a" (SDL-GetError))))

;; Get the title of a window
(define (window-title win)
  (SDL-GetWindowTitle (window-ptr win)))

;; ============================================================================
;; Window Visibility
;; ============================================================================

;; Show a window
(define (show-window! win)
  (unless (SDL-ShowWindow (window-ptr win))
    (error 'show-window! "Failed to show window: ~a" (SDL-GetError))))

;; Hide a window
(define (hide-window! win)
  (unless (SDL-HideWindow (window-ptr win))
    (error 'hide-window! "Failed to hide window: ~a" (SDL-GetError))))

;; Raise a window above other windows and set input focus
(define (raise-window! win)
  (unless (SDL-RaiseWindow (window-ptr win))
    (error 'raise-window! "Failed to raise window: ~a" (SDL-GetError))))

;; ============================================================================
;; Window State
;; ============================================================================

;; Maximize a window
(define (maximize-window! win)
  (unless (SDL-MaximizeWindow (window-ptr win))
    (error 'maximize-window! "Failed to maximize window: ~a" (SDL-GetError))))

;; Minimize a window
(define (minimize-window! win)
  (unless (SDL-MinimizeWindow (window-ptr win))
    (error 'minimize-window! "Failed to minimize window: ~a" (SDL-GetError))))

;; Restore a minimized or maximized window
(define (restore-window! win)
  (unless (SDL-RestoreWindow (window-ptr win))
    (error 'restore-window! "Failed to restore window: ~a" (SDL-GetError))))

;; ============================================================================
;; Window Properties
;; ============================================================================

;; Get the numeric ID of a window
(define (window-id win)
  (SDL-GetWindowID (window-ptr win)))

;; Get a window from an ID
;; Returns #f if not found
(define (window-from-id id)
  (SDL-GetWindowFromID id))

;; Set the icon for a window
(define (set-window-icon! win surface)
  (unless (SDL-SetWindowIcon (window-ptr win) surface)
    (error 'set-window-icon! "Failed to set window icon: ~a" (SDL-GetError))))

;; ============================================================================
;; Size Constraints
;; ============================================================================

;; Set the minimum size of a window
(define (set-window-minimum-size! win w h)
  (unless (SDL-SetWindowMinimumSize (window-ptr win) w h)
    (error 'set-window-minimum-size! "Failed to set minimum size: ~a" (SDL-GetError))))

;; Set the maximum size of a window
(define (set-window-maximum-size! win w h)
  (unless (SDL-SetWindowMaximumSize (window-ptr win) w h)
    (error 'set-window-maximum-size! "Failed to set maximum size: ~a" (SDL-GetError))))

;; Get the minimum size of a window
;; Returns: (values width height)
(define (window-minimum-size win)
  (define-values (success w h) (SDL-GetWindowMinimumSize (window-ptr win)))
  (unless success
    (error 'window-minimum-size "Failed to get minimum size: ~a" (SDL-GetError)))
  (values w h))

;; Get the maximum size of a window
;; Returns: (values width height)
(define (window-maximum-size win)
  (define-values (success w h) (SDL-GetWindowMaximumSize (window-ptr win)))
  (unless success
    (error 'window-maximum-size "Failed to get maximum size: ~a" (SDL-GetError)))
  (values w h))

;; ============================================================================
;; Decoration
;; ============================================================================

;; Set whether the window has a border
(define (set-window-bordered! win bordered?)
  (unless (SDL-SetWindowBordered (window-ptr win) bordered?)
    (error 'set-window-bordered! "Failed to set bordered: ~a" (SDL-GetError))))

;; Set whether the window is resizable
(define (set-window-resizable! win resizable?)
  (unless (SDL-SetWindowResizable (window-ptr win) resizable?)
    (error 'set-window-resizable! "Failed to set resizable: ~a" (SDL-GetError))))

;; ============================================================================
;; Effects
;; ============================================================================

;; Get the opacity of a window (0.0 to 1.0)
(define (window-opacity win)
  (SDL-GetWindowOpacity (window-ptr win)))

;; Set the opacity of a window (0.0 to 1.0)
(define (set-window-opacity! win opacity)
  (unless (SDL-SetWindowOpacity (window-ptr win) opacity)
    (error 'set-window-opacity! "Failed to set opacity: ~a" (SDL-GetError))))

;; Flash the window to get user attention
;; operation: 'cancel, 'briefly, or 'until-focused (default: 'briefly)
(define (flash-window! win [operation 'briefly])
  (define op (case operation
               [(cancel) SDL_FLASH_CANCEL]
               [(briefly) SDL_FLASH_BRIEFLY]
               [(until-focused) SDL_FLASH_UNTIL_FOCUSED]
               [else (error 'flash-window! "Invalid operation: ~a (expected 'cancel, 'briefly, or 'until-focused)" operation)]))
  (unless (SDL-FlashWindow (window-ptr win) op)
    (error 'flash-window! "Failed to flash window: ~a" (SDL-GetError))))

;; ============================================================================
;; Renderer Management
;; ============================================================================

(define (make-renderer win
                       #:name [name #f]
                       #:custodian [cust (current-custodian)])
  (define ptr (SDL-CreateRenderer (window-ptr win) name))
  (unless ptr
    (error 'make-renderer "Failed to create renderer: ~a" (SDL-GetError)))
  (wrap-renderer ptr #:custodian cust))

;; ============================================================================
;; Convenience Functions
;; ============================================================================

(define (make-window+renderer title width height
                              #:window-flags [window-flags 0]
                              #:renderer-name [renderer-name #f]
                              #:custodian [cust (current-custodian)])
  (define win (make-window title width height
                           #:flags window-flags
                           #:custodian cust))
  (define rend (make-renderer win
                              #:name renderer-name
                              #:custodian cust))
  (values win rend))
