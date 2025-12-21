#lang racket/base

;; SDL3 System Tray
;;
;; Low-level tray icon and menu management.

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide
 ;; Tray creation/destruction
 SDL-CreateTray
 SDL-DestroyTray
 SDL-SetTrayIcon
 SDL-SetTrayTooltip

 ;; Menus and submenus
 SDL-CreateTrayMenu
 SDL-CreateTraySubmenu
 SDL-GetTrayMenu
 SDL-GetTraySubmenu
 SDL-GetTrayEntries
 SDL-GetTrayMenuParentEntry
 SDL-GetTrayMenuParentTray
 SDL-GetTrayEntryParent

 ;; Entries
 SDL-InsertTrayEntryAt
 SDL-RemoveTrayEntry
 SDL-SetTrayEntryLabel
 SDL-GetTrayEntryLabel
 SDL-SetTrayEntryChecked
 SDL-GetTrayEntryChecked
 SDL-SetTrayEntryEnabled
 SDL-GetTrayEntryEnabled
 SDL-SetTrayEntryCallback
 SDL-ClickTrayEntry

 ;; Updates
 SDL-UpdateTrays)

;; ============================================================================
;; Tray Creation/Destruction
;; ============================================================================

;; SDL_CreateTray: Create a tray icon with optional icon and tooltip
(define-sdl SDL-CreateTray
  (_fun _SDL_Surface-pointer/null _string/utf-8 -> _SDL_Tray-pointer/null)
  #:c-id SDL_CreateTray)

;; SDL_SetTrayIcon: Update the tray icon image
(define-sdl SDL-SetTrayIcon
  (_fun _SDL_Tray-pointer _SDL_Surface-pointer/null -> _void)
  #:c-id SDL_SetTrayIcon)

;; SDL_SetTrayTooltip: Update the tray tooltip text
(define-sdl SDL-SetTrayTooltip
  (_fun _SDL_Tray-pointer _string/utf-8 -> _void)
  #:c-id SDL_SetTrayTooltip)

;; SDL_DestroyTray: Destroy the tray icon and associated menus
(define-sdl SDL-DestroyTray
  (_fun _SDL_Tray-pointer -> _void)
  #:c-id SDL_DestroyTray)

;; ============================================================================
;; Menus and Submenus
;; ============================================================================

;; SDL_CreateTrayMenu: Create a top-level tray menu
(define-sdl SDL-CreateTrayMenu
  (_fun _SDL_Tray-pointer -> _SDL_TrayMenu-pointer/null)
  #:c-id SDL_CreateTrayMenu)

;; SDL_CreateTraySubmenu: Create a submenu for a tray entry
(define-sdl SDL-CreateTraySubmenu
  (_fun _SDL_TrayEntry-pointer -> _SDL_TrayMenu-pointer/null)
  #:c-id SDL_CreateTraySubmenu)

;; SDL_GetTrayMenu: Get a previously created tray menu
(define-sdl SDL-GetTrayMenu
  (_fun _SDL_Tray-pointer -> _SDL_TrayMenu-pointer/null)
  #:c-id SDL_GetTrayMenu)

;; SDL_GetTraySubmenu: Get a previously created submenu
(define-sdl SDL-GetTraySubmenu
  (_fun _SDL_TrayEntry-pointer -> _SDL_TrayMenu-pointer/null)
  #:c-id SDL_GetTraySubmenu)

;; SDL_GetTrayEntries: Get entries from a tray menu
;; Returns: array of SDL_TrayEntry pointers (NULL-terminated; pointer invalid after edits)
(define-sdl SDL-GetTrayEntries
  (_fun _SDL_TrayMenu-pointer (count : (_ptr o _int)) -> (arr : _pointer)
        -> (values arr count))
  #:c-id SDL_GetTrayEntries)

;; SDL_GetTrayMenuParentEntry: Get the parent entry for a submenu
(define-sdl SDL-GetTrayMenuParentEntry
  (_fun _SDL_TrayMenu-pointer -> _SDL_TrayEntry-pointer/null)
  #:c-id SDL_GetTrayMenuParentEntry)

;; SDL_GetTrayMenuParentTray: Get the parent tray for a top-level menu
(define-sdl SDL-GetTrayMenuParentTray
  (_fun _SDL_TrayMenu-pointer -> _SDL_Tray-pointer/null)
  #:c-id SDL_GetTrayMenuParentTray)

;; SDL_GetTrayEntryParent: Get the parent menu of an entry
(define-sdl SDL-GetTrayEntryParent
  (_fun _SDL_TrayEntry-pointer -> _SDL_TrayMenu-pointer/null)
  #:c-id SDL_GetTrayEntryParent)

;; ============================================================================
;; Entries
;; ============================================================================

;; SDL_InsertTrayEntryAt: Insert an entry at a given position
(define-sdl SDL-InsertTrayEntryAt
  (_fun _SDL_TrayMenu-pointer _int _string/utf-8 _SDL_TrayEntryFlags -> _SDL_TrayEntry-pointer/null)
  #:c-id SDL_InsertTrayEntryAt)

;; SDL_RemoveTrayEntry: Remove an entry from a tray menu
(define-sdl SDL-RemoveTrayEntry
  (_fun _SDL_TrayEntry-pointer -> _void)
  #:c-id SDL_RemoveTrayEntry)

;; SDL_SetTrayEntryLabel: Update the entry label
(define-sdl SDL-SetTrayEntryLabel
  (_fun _SDL_TrayEntry-pointer _string/utf-8 -> _void)
  #:c-id SDL_SetTrayEntryLabel)

;; SDL_GetTrayEntryLabel: Get the entry label
(define-sdl SDL-GetTrayEntryLabel
  (_fun _SDL_TrayEntry-pointer -> _string/utf-8)
  #:c-id SDL_GetTrayEntryLabel)

;; SDL_SetTrayEntryChecked: Set checkbox state for an entry
(define-sdl SDL-SetTrayEntryChecked
  (_fun _SDL_TrayEntry-pointer _stdbool -> _void)
  #:c-id SDL_SetTrayEntryChecked)

;; SDL_GetTrayEntryChecked: Get checkbox state for an entry
(define-sdl SDL-GetTrayEntryChecked
  (_fun _SDL_TrayEntry-pointer -> _stdbool)
  #:c-id SDL_GetTrayEntryChecked)

;; SDL_SetTrayEntryEnabled: Enable or disable an entry
(define-sdl SDL-SetTrayEntryEnabled
  (_fun _SDL_TrayEntry-pointer _stdbool -> _void)
  #:c-id SDL_SetTrayEntryEnabled)

;; SDL_GetTrayEntryEnabled: Query entry enabled state
(define-sdl SDL-GetTrayEntryEnabled
  (_fun _SDL_TrayEntry-pointer -> _stdbool)
  #:c-id SDL_GetTrayEntryEnabled)

;; SDL_SetTrayEntryCallback: Set entry selection callback
(define-sdl SDL-SetTrayEntryCallback
  (_fun _SDL_TrayEntry-pointer _SDL_TrayCallback _pointer -> _void)
  #:c-id SDL_SetTrayEntryCallback)

;; SDL_ClickTrayEntry: Simulate a click on an entry
(define-sdl SDL-ClickTrayEntry
  (_fun _SDL_TrayEntry-pointer -> _void)
  #:c-id SDL_ClickTrayEntry)

;; ============================================================================
;; Updates
;; ============================================================================

;; SDL_UpdateTrays: Update trays if events aren't being pumped
(define-sdl SDL-UpdateTrays
  (_fun -> _void)
  #:c-id SDL_UpdateTrays)
