#lang racket/base

;; SDL3 Properties
;;
;; Functions for creating and manipulating SDL_PropertiesID groups.

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide SDL-CreateProperties
         SDL-DestroyProperties
         SDL-SetPointerProperty
         SDL-SetStringProperty
         SDL-SetNumberProperty
         SDL-SetFloatProperty
         SDL-SetBooleanProperty
         SDL-GetPointerProperty
         SDL-GetStringProperty
         SDL-GetNumberProperty
         SDL-GetFloatProperty
         SDL-GetBooleanProperty)

;; =========================================================================
;; Properties Management
;; =========================================================================

;; SDL_CreateProperties: Create a new group of properties
;; Returns: properties ID, or 0 on failure
(define-sdl SDL-CreateProperties
  (_fun -> _SDL_PropertiesID)
  #:c-id SDL_CreateProperties)

;; SDL_DestroyProperties: Destroy a group of properties
(define-sdl SDL-DestroyProperties
  (_fun _SDL_PropertiesID -> _void)
  #:c-id SDL_DestroyProperties)

;; SDL_SetPointerProperty: Set a pointer property
;; value can be NULL to delete the property
(define-sdl SDL-SetPointerProperty
  (_fun _SDL_PropertiesID _string/utf-8 _pointer -> _sdl-bool)
  #:c-id SDL_SetPointerProperty)

;; SDL_SetStringProperty: Set a string property
(define-sdl SDL-SetStringProperty
  (_fun _SDL_PropertiesID _string/utf-8 _string/utf-8 -> _sdl-bool)
  #:c-id SDL_SetStringProperty)

;; SDL_SetNumberProperty: Set a number property (Sint64)
(define-sdl SDL-SetNumberProperty
  (_fun _SDL_PropertiesID _string/utf-8 _sint64 -> _sdl-bool)
  #:c-id SDL_SetNumberProperty)

;; SDL_SetFloatProperty: Set a float property
(define-sdl SDL-SetFloatProperty
  (_fun _SDL_PropertiesID _string/utf-8 _float -> _sdl-bool)
  #:c-id SDL_SetFloatProperty)

;; SDL_SetBooleanProperty: Set a boolean property
(define-sdl SDL-SetBooleanProperty
  (_fun _SDL_PropertiesID _string/utf-8 _stdbool -> _sdl-bool)
  #:c-id SDL_SetBooleanProperty)

;; SDL_GetPointerProperty: Get a pointer property
(define-sdl SDL-GetPointerProperty
  (_fun _SDL_PropertiesID _string/utf-8 _pointer -> _pointer)
  #:c-id SDL_GetPointerProperty)

;; SDL_GetStringProperty: Get a string property
(define-sdl SDL-GetStringProperty
  (_fun _SDL_PropertiesID _string/utf-8 _string/utf-8 -> _string/utf-8)
  #:c-id SDL_GetStringProperty)

;; SDL_GetNumberProperty: Get a number property (Sint64)
(define-sdl SDL-GetNumberProperty
  (_fun _SDL_PropertiesID _string/utf-8 _sint64 -> _sint64)
  #:c-id SDL_GetNumberProperty)

;; SDL_GetFloatProperty: Get a float property
(define-sdl SDL-GetFloatProperty
  (_fun _SDL_PropertiesID _string/utf-8 _float -> _float)
  #:c-id SDL_GetFloatProperty)

;; SDL_GetBooleanProperty: Get a boolean property
(define-sdl SDL-GetBooleanProperty
  (_fun _SDL_PropertiesID _string/utf-8 _stdbool -> _stdbool)
  #:c-id SDL_GetBooleanProperty)
