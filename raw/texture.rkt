#lang racket/base

;; SDL3 Texture Management
;;
;; Functions for creating, manipulating, and rendering textures.

(require ffi/unsafe
         "../private/lib.rkt"
         "../private/types.rkt")

(provide SDL-CreateTexture
         SDL-DestroyTexture
         SDL-RenderTexture
         SDL-RenderTextureRotated
         SDL-RenderTextureAffine
         SDL-RenderTextureTiled
         SDL-RenderTexture9Grid
         SDL-GetTextureSize
         SDL-CreateTextureFromSurface
         ;; Render targets
         SDL-SetRenderTarget
         SDL-GetRenderTarget
         ;; Texture scale mode
         SDL-SetTextureScaleMode
         SDL-GetTextureScaleMode
         ;; Texture blend mode
         SDL-SetTextureBlendMode
         SDL-GetTextureBlendMode
         ;; Texture color/alpha modulation
         SDL-SetTextureColorMod
         SDL-GetTextureColorMod
         SDL-SetTextureAlphaMod
         SDL-GetTextureAlphaMod
         SDL-SetTextureColorModFloat
         SDL-GetTextureColorModFloat
         SDL-SetTextureAlphaModFloat
         SDL-GetTextureAlphaModFloat
         ;; Texture updates and locking
         SDL-UpdateTexture
         SDL-UpdateYUVTexture
         SDL-UpdateNVTexture
         SDL-LockTexture
         SDL-LockTextureToSurface
         SDL-UnlockTexture)

;; ============================================================================
;; Texture Creation/Destruction
;; ============================================================================

;; SDL_CreateTexture: Create a texture for a renderer
;; renderer: the rendering context
;; format: the pixel format (SDL_PixelFormat)
;; access: the access pattern (SDL_TextureAccess)
;; w, h: the width and height of the texture in pixels
;; Returns: pointer to the texture, or NULL on failure
(define-sdl SDL-CreateTexture
  (_fun _SDL_Renderer-pointer _SDL_PixelFormat _SDL_TextureAccess _int _int
        -> _SDL_Texture-pointer/null)
  #:c-id SDL_CreateTexture)

;; SDL_DestroyTexture: Destroy a texture
(define-sdl SDL-DestroyTexture (_fun _SDL_Texture-pointer -> _void)
  #:c-id SDL_DestroyTexture)

;; SDL_CreateTextureFromSurface: Create a texture from an existing surface
;; renderer: the renderer to use
;; surface: the surface to convert to a texture
;; Returns: pointer to the texture, or NULL on failure
(define-sdl SDL-CreateTextureFromSurface
  (_fun _SDL_Renderer-pointer _SDL_Surface-pointer -> _SDL_Texture-pointer/null)
  #:c-id SDL_CreateTextureFromSurface)

;; SDL_GetTextureSize: Query texture dimensions
;; texture: the texture to query
;; w, h: pointers to receive width and height (can be NULL)
;; Returns: true on success, false on failure
(define-sdl SDL-GetTextureSize
  (_fun _SDL_Texture-pointer _pointer _pointer -> _sdl-bool)
  #:c-id SDL_GetTextureSize)

;; ============================================================================
;; Texture Rendering
;; ============================================================================

;; SDL_RenderTexture: Copy texture to renderer at destination rectangle
;; srcrect: portion of texture (NULL for whole texture)
;; dstrect: destination rectangle (NULL for whole renderer)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTexture
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _SDL_FRect-pointer/null
        -> _sdl-bool)
  #:c-id SDL_RenderTexture)

;; SDL_RenderTextureRotated: Copy texture with rotation and flipping
;; renderer: the renderer
;; texture: the source texture
;; srcrect: portion of texture (NULL for whole texture)
;; dstrect: destination rectangle (NULL for whole renderer)
;; angle: rotation angle in degrees (clockwise)
;; center: point around which to rotate (NULL for center of dstrect)
;; flip: SDL_FlipMode value for flipping
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTextureRotated
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _SDL_FRect-pointer/null
        _double
        _SDL_FPoint-pointer/null
        _SDL_FlipMode
        -> _sdl-bool)
  #:c-id SDL_RenderTextureRotated)

;; SDL_RenderTextureAffine: Copy texture with affine transform
;; renderer: the renderer
;; texture: the source texture
;; srcrect: portion of texture (NULL for whole texture)
;; origin: the point in the destination where the top-left corner of srcrect appears
;; right: the point in the destination where the top-right corner of srcrect appears
;; down: the point in the destination where the bottom-left corner of srcrect appears
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTextureAffine
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _SDL_FPoint-pointer/null
        _SDL_FPoint-pointer/null
        _SDL_FPoint-pointer/null
        -> _sdl-bool)
  #:c-id SDL_RenderTextureAffine)

;; SDL_RenderTextureTiled: Tile a texture to fill a destination rectangle
;; renderer: the renderer
;; texture: the source texture
;; srcrect: portion of texture to tile (NULL for whole texture)
;; scale: scale factor for the source rectangle (e.g., 2 makes 32x32 tile fill 64x64)
;; dstrect: destination rectangle to fill (NULL for whole renderer)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTextureTiled
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _float
        _SDL_FRect-pointer/null
        -> _sdl-bool)
  #:c-id SDL_RenderTextureTiled)

;; SDL_RenderTexture9Grid: Render texture using 9-grid (9-slice) algorithm
;; renderer: the renderer
;; texture: the source texture
;; srcrect: source rectangle for the 9-grid (NULL for whole texture)
;; left_width: width of left corners in source pixels
;; right_width: width of right corners in source pixels
;; top_height: height of top corners in source pixels
;; bottom_height: height of bottom corners in source pixels
;; scale: scale factor for corners
;; dstrect: destination rectangle (NULL for whole renderer)
;; Returns: true on success, false on failure
(define-sdl SDL-RenderTexture9Grid
  (_fun _SDL_Renderer-pointer
        _SDL_Texture-pointer
        _SDL_FRect-pointer/null
        _float _float _float _float  ; left_width, right_width, top_height, bottom_height
        _float                        ; scale
        _SDL_FRect-pointer/null
        -> _sdl-bool)
  #:c-id SDL_RenderTexture9Grid)

;; ============================================================================
;; Render Targets
;; ============================================================================

;; SDL_SetRenderTarget: Set a texture as the current rendering target
;; renderer: the rendering context
;; texture: the texture to use as render target, or NULL to render to the window
;; Returns: true on success, false on failure
(define-sdl SDL-SetRenderTarget
  (_fun _SDL_Renderer-pointer _SDL_Texture-pointer/null -> _sdl-bool)
  #:c-id SDL_SetRenderTarget)

;; SDL_GetRenderTarget: Get the current render target
;; renderer: the rendering context
;; Returns: the current render target, or NULL for the default (window)
(define-sdl SDL-GetRenderTarget
  (_fun _SDL_Renderer-pointer -> _SDL_Texture-pointer/null)
  #:c-id SDL_GetRenderTarget)

;; ============================================================================
;; Texture Scale Mode
;; ============================================================================

;; SDL_SetTextureScaleMode: Set the scale mode used for texture scale operations
;; texture: the texture to update
;; scaleMode: the scale mode to use
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureScaleMode
  (_fun _SDL_Texture-pointer _SDL_ScaleMode -> _sdl-bool)
  #:c-id SDL_SetTextureScaleMode)

;; SDL_GetTextureScaleMode: Get the scale mode used for texture scale operations
;; texture: the texture to query
;; Returns: (values success? scaleMode)
(define-sdl SDL-GetTextureScaleMode
  (_fun _SDL_Texture-pointer (scaleMode : (_ptr o _SDL_ScaleMode))
        -> (result : _sdl-bool)
        -> (values result scaleMode))
  #:c-id SDL_GetTextureScaleMode)

;; ============================================================================
;; Texture Blend Mode
;; ============================================================================

;; SDL_SetTextureBlendMode: Set the blend mode for a texture
;; texture: the texture to modify
;; blendMode: the blend mode to use
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureBlendMode
  (_fun _SDL_Texture-pointer _SDL_BlendMode -> _sdl-bool)
  #:c-id SDL_SetTextureBlendMode)

;; SDL_GetTextureBlendMode: Get the blend mode for a texture
;; texture: the texture to query
;; blendMode: pointer to receive the current blend mode
;; Returns: true on success, false on failure
(define-sdl SDL-GetTextureBlendMode
  (_fun _SDL_Texture-pointer (blendMode : (_ptr o _SDL_BlendMode))
        -> (result : _sdl-bool)
        -> (values result blendMode))
  #:c-id SDL_GetTextureBlendMode)

;; ============================================================================
;; Texture Color/Alpha Modulation
;; ============================================================================

;; SDL_SetTextureColorMod: Set an additional color value multiplied into render copy operations
;; texture: the texture to modify
;; r, g, b: the color modulation values (0-255)
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureColorMod
  (_fun _SDL_Texture-pointer _uint8 _uint8 _uint8 -> _sdl-bool)
  #:c-id SDL_SetTextureColorMod)

;; SDL_GetTextureColorMod: Get the additional color value multiplied into render copy operations
;; texture: the texture to query
;; Returns: (values success? r g b)
(define-sdl SDL-GetTextureColorMod
  (_fun _SDL_Texture-pointer
        (r : (_ptr o _uint8))
        (g : (_ptr o _uint8))
        (b : (_ptr o _uint8))
        -> (result : _sdl-bool)
        -> (values result r g b))
  #:c-id SDL_GetTextureColorMod)

;; SDL_SetTextureAlphaMod: Set an additional alpha value multiplied into render copy operations
;; texture: the texture to modify
;; alpha: the alpha modulation value (0-255)
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureAlphaMod
  (_fun _SDL_Texture-pointer _uint8 -> _sdl-bool)
  #:c-id SDL_SetTextureAlphaMod)

;; SDL_GetTextureAlphaMod: Get the additional alpha value multiplied into render copy operations
;; texture: the texture to query
;; Returns: (values success? alpha)
(define-sdl SDL-GetTextureAlphaMod
  (_fun _SDL_Texture-pointer
        (alpha : (_ptr o _uint8))
        -> (result : _sdl-bool)
        -> (values result alpha))
  #:c-id SDL_GetTextureAlphaMod)

;; ============================================================================
;; Texture Color/Alpha Modulation (Float)
;; ============================================================================

;; SDL_SetTextureColorModFloat: Set color modulation using float values
;; r, g, b: modulation values (usually 0.0-1.0)
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureColorModFloat
  (_fun _SDL_Texture-pointer _float _float _float -> _sdl-bool)
  #:c-id SDL_SetTextureColorModFloat)

;; SDL_GetTextureColorModFloat: Get color modulation as float values
;; Returns: (values success? r g b)
(define-sdl SDL-GetTextureColorModFloat
  (_fun _SDL_Texture-pointer
        (r : (_ptr o _float))
        (g : (_ptr o _float))
        (b : (_ptr o _float))
        -> (result : _sdl-bool)
        -> (values result r g b))
  #:c-id SDL_GetTextureColorModFloat)

;; SDL_SetTextureAlphaModFloat: Set alpha modulation using float value
;; alpha: modulation value (usually 0.0-1.0)
;; Returns: true on success, false on failure
(define-sdl SDL-SetTextureAlphaModFloat
  (_fun _SDL_Texture-pointer _float -> _sdl-bool)
  #:c-id SDL_SetTextureAlphaModFloat)

;; SDL_GetTextureAlphaModFloat: Get alpha modulation as float value
;; Returns: (values success? alpha)
(define-sdl SDL-GetTextureAlphaModFloat
  (_fun _SDL_Texture-pointer
        (alpha : (_ptr o _float))
        -> (result : _sdl-bool)
        -> (values result alpha))
  #:c-id SDL_GetTextureAlphaModFloat)

;; ============================================================================
;; Texture Updates and Locking
;; ============================================================================

;; SDL_UpdateTexture: Update a texture with new pixel data
;; rect: SDL_Rect pointer or NULL to update entire texture
;; pixels: pointer to pixel data
;; pitch: bytes per row
;; Returns: true on success, false on failure
(define-sdl SDL-UpdateTexture
  (_fun _SDL_Texture-pointer _SDL_Rect-pointer/null _pointer _int -> _sdl-bool)
  #:c-id SDL_UpdateTexture)

;; SDL_UpdateYUVTexture: Update a planar YUV texture
;; rect: SDL_Rect pointer or NULL to update entire texture
;; planes: pointers to Y, U, V planes and pitches
;; Returns: true on success, false on failure
(define-sdl SDL-UpdateYUVTexture
  (_fun _SDL_Texture-pointer
        _SDL_Rect-pointer/null
        _pointer _int
        _pointer _int
        _pointer _int
        -> _sdl-bool)
  #:c-id SDL_UpdateYUVTexture)

;; SDL_UpdateNVTexture: Update a planar NV12/NV21 texture
;; rect: SDL_Rect pointer or NULL to update entire texture
;; planes: pointers to Y and UV planes and pitches
;; Returns: true on success, false on failure
(define-sdl SDL-UpdateNVTexture
  (_fun _SDL_Texture-pointer
        _SDL_Rect-pointer/null
        _pointer _int
        _pointer _int
        -> _sdl-bool)
  #:c-id SDL_UpdateNVTexture)

;; SDL_LockTexture: Lock a streaming texture for write access
;; rect: SDL_Rect pointer or NULL to lock entire texture
;; Returns: (values success? pixels pitch)
(define-sdl SDL-LockTexture
  (_fun _SDL_Texture-pointer
        _SDL_Rect-pointer/null
        (pixels : (_ptr o _pointer))
        (pitch : (_ptr o _int))
        -> (result : _sdl-bool)
        -> (values result pixels pitch))
  #:c-id SDL_LockTexture)

;; SDL_LockTextureToSurface: Lock a streaming texture and expose as surface
;; Returns: (values success? surface)
(define-sdl SDL-LockTextureToSurface
  (_fun _SDL_Texture-pointer
        _SDL_Rect-pointer/null
        (surface : (_ptr o _SDL_Surface-pointer))
        -> (result : _sdl-bool)
        -> (values result surface))
  #:c-id SDL_LockTextureToSurface)

;; SDL_UnlockTexture: Unlock a streaming texture
(define-sdl SDL-UnlockTexture
  (_fun _SDL_Texture-pointer -> _void)
  #:c-id SDL_UnlockTexture)
