#lang racket/base

;; Idiomatic camera access with custodian-managed cleanup

(require ffi/unsafe
         "../raw.rkt"
         "../private/safe-syntax.rkt"
         "texture.rkt"
         "window.rkt")

(provide
 ;; Camera resource
 camera?
 camera-ptr
 camera-destroy!

 ;; Camera specs
 (struct-out camera-spec)
 make-camera-spec

 ;; Driver/device enumeration
 camera-driver-count
 camera-driver-name
 current-camera-driver
 get-cameras
 camera-name
 camera-position
 camera-supported-formats

 ;; Open/close and info
 open-camera
 camera-permission-state
 camera-id
 camera-properties
 camera-format

 ;; Frames
 camera-frame?
 camera-frame-surface
 camera-frame-timestamp-ns
 camera-acquire-frame
 camera-frame-release!
 camera-frame->texture
 camera-frame-width
 camera-frame-height
 camera-frame-pitch
 camera-frame-format)

;; ============================================================================
;; Camera Resource
;; ============================================================================

(define-sdl-resource camera SDL-CloseCamera)

;; ============================================================================
;; Camera Spec Helpers
;; ============================================================================

(struct camera-spec (format colorspace width height framerate-numerator framerate-denominator)
  #:transparent)

(define (make-camera-spec format width height
                          #:colorspace [colorspace 0]
                          #:framerate-numerator [num 0]
                          #:framerate-denominator [den 0])
  (camera-spec format colorspace width height num den))

(define (camera-spec->sdl spec)
  (make-SDL_CameraSpec (camera-spec-format spec)
                       (camera-spec-colorspace spec)
                       (camera-spec-width spec)
                       (camera-spec-height spec)
                       (camera-spec-framerate-numerator spec)
                       (camera-spec-framerate-denominator spec)))

(define (camera-spec-from-ptr spec)
  (camera-spec (SDL_CameraSpec-format spec)
               (SDL_CameraSpec-colorspace spec)
               (SDL_CameraSpec-width spec)
               (SDL_CameraSpec-height spec)
               (SDL_CameraSpec-framerate_numerator spec)
               (SDL_CameraSpec-framerate_denominator spec)))

;; ============================================================================
;; Driver/Device Enumeration
;; ============================================================================

(define (camera-driver-count)
  (SDL-GetNumCameraDrivers))

(define (camera-driver-name index)
  (SDL-GetCameraDriver index))

(define (current-camera-driver)
  (SDL-GetCurrentCameraDriver))

(define (get-cameras)
  (define-values (arr count) (SDL-GetCameras))
  (cond
    [(not arr) '()]
    [else
     (define ids
       (for/list ([i (in-range count)])
         (ptr-ref arr _uint32 i)))
     (SDL-free arr)
     ids]))

(define (camera-name instance-id)
  (SDL-GetCameraName instance-id))

(define (camera-position->symbol pos)
  (cond
    [(= pos SDL_CAMERA_POSITION_FRONT_FACING) 'front-facing]
    [(= pos SDL_CAMERA_POSITION_BACK_FACING) 'back-facing]
    [else 'unknown]))

(define (camera-position instance-id)
  (camera-position->symbol (SDL-GetCameraPosition instance-id)))

(define (camera-supported-formats instance-id)
  (define-values (ptr count) (SDL-GetCameraSupportedFormats instance-id))
  (cond
    [(not ptr) '()]
    [else
     (define specs
       (for/list ([i (in-range count)]
                  #:when (ptr-ref ptr _pointer i))
         (define spec-ptr (cast (ptr-ref ptr _pointer i) _pointer _SDL_CameraSpec-pointer))
         (camera-spec-from-ptr spec-ptr)))
     (SDL-free ptr)
     specs]))

;; ============================================================================
;; Open/Close and Info
;; ============================================================================

(define (open-camera instance-id
                     #:spec [spec #f]
                     #:custodian [cust (current-custodian)])
  (define spec-ptr (and spec (camera-spec->sdl spec)))
  (define ptr (SDL-OpenCamera instance-id spec-ptr))
  (unless ptr
    (error 'open-camera "failed to open camera ~a: ~a"
           instance-id (SDL-GetError)))
  (wrap-camera ptr #:custodian cust))

(define (camera-permission-state cam)
  (define state (SDL-GetCameraPermissionState (camera-ptr cam)))
  (cond
    [(= state 1) 'approved]
    [(= state -1) 'denied]
    [else 'pending]))

(define (camera-id cam)
  (SDL-GetCameraID (camera-ptr cam)))

(define (camera-properties cam)
  (define props (SDL-GetCameraProperties (camera-ptr cam)))
  (when (zero? props)
    (error 'camera-properties "failed to get camera properties: ~a" (SDL-GetError)))
  props)

(define (camera-format cam)
  (define spec (make-SDL_CameraSpec 0 0 0 0 0 0))
  (if (SDL-GetCameraFormat (camera-ptr cam) spec)
      (camera-spec-from-ptr spec)
      #f))

;; ============================================================================
;; Frame Capture
;; ============================================================================

(struct camera-frame (camera surface timestamp-ns [released? #:mutable])
  #:property prop:cpointer (λ (frame) (camera-frame-surface frame))
  #:transparent)

(define (camera-acquire-frame cam)
  (define-values (frame timestamp) (SDL-AcquireCameraFrame (camera-ptr cam)))
  (if frame
      (camera-frame cam frame timestamp #f)
      #f))

(define (camera-frame-release! frame)
  (unless (camera-frame-released? frame)
    (SDL-ReleaseCameraFrame (camera-ptr (camera-frame-camera frame))
                            (camera-frame-surface frame))
    (set-camera-frame-released?! frame #t)))

(define (camera-frame->texture rend frame #:custodian [cust (current-custodian)])
  (define ptr (SDL-CreateTextureFromSurface (renderer-ptr rend)
                                            (camera-frame-surface frame)))
  (unless ptr
    (error 'camera-frame->texture "failed to create texture: ~a" (SDL-GetError)))
  (texture-from-pointer ptr #:custodian cust))

(define (camera-frame-width frame)
  (SDL_Surface-w (camera-frame-surface frame)))

(define (camera-frame-height frame)
  (SDL_Surface-h (camera-frame-surface frame)))

(define (camera-frame-pitch frame)
  (SDL_Surface-pitch (camera-frame-surface frame)))

(define (camera-frame-format frame)
  (SDL_Surface-format (camera-frame-surface frame)))
