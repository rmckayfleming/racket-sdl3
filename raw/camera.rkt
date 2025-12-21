#lang racket/base

;; SDL3 Camera API
;;
;; Low-level camera access (enumeration, open/close, frame capture).

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide
 ;; Driver enumeration
 SDL-GetNumCameraDrivers
 SDL-GetCameraDriver
 SDL-GetCurrentCameraDriver

 ;; Device enumeration
 SDL-GetCameras
 SDL-GetCameraSupportedFormats
 SDL-GetCameraName
 SDL-GetCameraPosition

 ;; Open/Close
 SDL-OpenCamera
 SDL-CloseCamera

 ;; Camera info
 SDL-GetCameraPermissionState
 SDL-GetCameraID
 SDL-GetCameraProperties
 SDL-GetCameraFormat

 ;; Frames
 SDL-AcquireCameraFrame
 SDL-ReleaseCameraFrame)

;; ============================================================================
;; Driver Enumeration
;; ============================================================================

;; SDL_GetNumCameraDrivers: Get the number of camera drivers
(define-sdl SDL-GetNumCameraDrivers
  (_fun -> _int)
  #:c-id SDL_GetNumCameraDrivers)

;; SDL_GetCameraDriver: Get the name of a camera driver by index
(define-sdl SDL-GetCameraDriver
  (_fun _int -> _string/utf-8)
  #:c-id SDL_GetCameraDriver)

;; SDL_GetCurrentCameraDriver: Get the current camera driver name
(define-sdl SDL-GetCurrentCameraDriver
  (_fun -> _string/utf-8)
  #:c-id SDL_GetCurrentCameraDriver)

;; ============================================================================
;; Device Enumeration
;; ============================================================================

;; SDL_GetCameras: Get a list of connected camera instance IDs
;; Returns: array of SDL_CameraID values (must be freed with SDL_free)
(define-sdl SDL-GetCameras
  (_fun (count : (_ptr o _int)) -> (arr : _pointer)
        -> (values arr count))
  #:c-id SDL_GetCameras)

;; SDL_GetCameraSupportedFormats: Get supported formats for a camera
;; Returns: array of SDL_CameraSpec pointers (must be freed with SDL_free)
(define-sdl SDL-GetCameraSupportedFormats
  (_fun _SDL_CameraID (count : (_ptr o _int)) -> (arr : _pointer)
        -> (values arr count))
  #:c-id SDL_GetCameraSupportedFormats)

;; SDL_GetCameraName: Get the human-readable name of a camera device
(define-sdl SDL-GetCameraName
  (_fun _SDL_CameraID -> _string/utf-8)
  #:c-id SDL_GetCameraName)

;; SDL_GetCameraPosition: Get the position of a camera (front/back/unknown)
(define-sdl SDL-GetCameraPosition
  (_fun _SDL_CameraID -> _SDL_CameraPosition)
  #:c-id SDL_GetCameraPosition)

;; ============================================================================
;; Open/Close
;; ============================================================================

;; SDL_OpenCamera: Open a camera by instance ID
(define-sdl SDL-OpenCamera
  (_fun _SDL_CameraID _SDL_CameraSpec-pointer/null -> _SDL_Camera-pointer/null)
  #:c-id SDL_OpenCamera)

;; SDL_CloseCamera: Close an opened camera
(define-sdl SDL-CloseCamera
  (_fun _SDL_Camera-pointer -> _void)
  #:c-id SDL_CloseCamera)

;; ============================================================================
;; Camera Info
;; ============================================================================

;; SDL_GetCameraPermissionState: Get camera permission status
;; Returns: -1 denied, 0 pending, 1 approved
(define-sdl SDL-GetCameraPermissionState
  (_fun _SDL_Camera-pointer -> _int)
  #:c-id SDL_GetCameraPermissionState)

;; SDL_GetCameraID: Get the instance ID of an opened camera
(define-sdl SDL-GetCameraID
  (_fun _SDL_Camera-pointer -> _SDL_CameraID)
  #:c-id SDL_GetCameraID)

;; SDL_GetCameraProperties: Get properties for an opened camera
(define-sdl SDL-GetCameraProperties
  (_fun _SDL_Camera-pointer -> _SDL_PropertiesID)
  #:c-id SDL_GetCameraProperties)

;; SDL_GetCameraFormat: Get the format of the opened camera
(define-sdl SDL-GetCameraFormat
  (_fun _SDL_Camera-pointer _SDL_CameraSpec-pointer -> _sdl-bool)
  #:c-id SDL_GetCameraFormat)

;; ============================================================================
;; Frame Capture
;; ============================================================================

;; SDL_AcquireCameraFrame: Acquire a new camera frame (if available)
;; Returns: (values surface-ptr timestamp-ns)
(define-sdl SDL-AcquireCameraFrame
  (_fun _SDL_Camera-pointer
        (timestamp : (_ptr o _uint64))
        -> (frame : _SDL_Surface-pointer/null)
        -> (values frame timestamp))
  #:c-id SDL_AcquireCameraFrame)

;; SDL_ReleaseCameraFrame: Release a previously acquired frame
(define-sdl SDL-ReleaseCameraFrame
  (_fun _SDL_Camera-pointer _SDL_Surface-pointer -> _void)
  #:c-id SDL_ReleaseCameraFrame)
