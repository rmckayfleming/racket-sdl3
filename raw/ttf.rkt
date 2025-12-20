#lang racket/base

;; SDL3_ttf bindings - TrueType Font rendering for SDL3
;;
;; This module provides bindings to SDL3_ttf functions for loading
;; and rendering TrueType fonts.

(require ffi/unsafe
         ffi/unsafe/define
         "../private/lib.rkt"
         "../private/types.rkt"
         "../private/syntax.rkt")

(provide (all-defined-out))

;; ============================================================================
;; Library Loading
;; ============================================================================

(define sdl3-ttf-lib (load-sdl-library "SDL3_ttf"))

(define-ffi-definer define-ttf sdl3-ttf-lib
  #:make-c-id convention:hyphen->underscore
  #:default-make-fail make-not-available)

;; ============================================================================
;; Font Pointer Type
;; ============================================================================

(define-cpointer-type _TTF_Font-pointer)

;; ============================================================================
;; FFI Enum Type Aliases
;; ============================================================================

;; Font style flags (bitmask)
(define _TTF_FontStyleFlags _uint32)

;; Hinting modes
(define _TTF_HintingFlags _int)

;; Horizontal alignment for wrapped text
(define _TTF_HorizontalAlignment _int)

;; Text direction (for HarfBuzz)
(define _TTF_Direction _int)

;; Glyph image type
(define _TTF_ImageType _int)

;; ============================================================================
;; Initialization
;; ============================================================================

;; TTF_Init: Initialize the TTF library
;; Returns: true on success, false on failure
(define-ttf TTF-Init (_fun -> _bool)
  #:c-id TTF_Init)

;; TTF_Quit: Clean up the TTF library
(define-ttf TTF-Quit (_fun -> _void)
  #:c-id TTF_Quit)

;; TTF_WasInit: Check if TTF library was initialized
;; Returns: non-zero if initialized, 0 otherwise
(define-ttf TTF-WasInit (_fun -> _int)
  #:c-id TTF_WasInit)

;; ============================================================================
;; Font Loading
;; ============================================================================

;; TTF_OpenFont: Load a font from a file at a specific point size
;; file: path to font file
;; ptsize: point size (float in SDL3_ttf 3.x)
;; Returns: pointer to font, or NULL on failure
(define-ttf TTF-OpenFont (_fun _string _float -> _TTF_Font-pointer/null)
  #:c-id TTF_OpenFont)

;; TTF_CloseFont: Close a font and free resources
;; font: the font to close
(define-ttf TTF-CloseFont (_fun _TTF_Font-pointer -> _void)
  #:c-id TTF_CloseFont)

;; ============================================================================
;; Font Properties
;; ============================================================================

;; TTF_GetFontSize: Get the size of a font
;; font: the font to query
;; Returns: point size as float, or 0.0 on failure
(define-ttf TTF-GetFontSize (_fun _TTF_Font-pointer -> _float)
  #:c-id TTF_GetFontSize)

;; TTF_GetFontHeight: Get the total height of a font
;; font: the font to query
;; Returns: height in pixels
(define-ttf TTF-GetFontHeight (_fun _TTF_Font-pointer -> _int)
  #:c-id TTF_GetFontHeight)

;; TTF_GetFontAscent: Get the offset from baseline to top
;; font: the font to query
;; Returns: ascent in pixels (positive value)
(define-ttf TTF-GetFontAscent (_fun _TTF_Font-pointer -> _int)
  #:c-id TTF_GetFontAscent)

;; TTF_GetFontDescent: Get the offset from baseline to bottom
;; font: the font to query
;; Returns: descent in pixels (negative value)
(define-ttf TTF-GetFontDescent (_fun _TTF_Font-pointer -> _int)
  #:c-id TTF_GetFontDescent)

;; ============================================================================
;; Text Rendering
;; ============================================================================

;; TTF_RenderText_Solid: Render text at fast quality to a surface
;; font: the font to use
;; text: UTF-8 text to render
;; length: length in bytes, or 0 for null-terminated
;; fg: foreground color (passed by value)
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderText-Solid
  (_fun _TTF_Font-pointer _string _size _SDL_Color -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderText_Solid)

;; TTF_RenderText_Shaded: Render text at high quality to a surface
;; font: the font to use
;; text: UTF-8 text to render
;; length: length in bytes, or 0 for null-terminated
;; fg: foreground color (passed by value)
;; bg: background color (passed by value)
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderText-Shaded
  (_fun _TTF_Font-pointer _string _size _SDL_Color _SDL_Color -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderText_Shaded)

;; TTF_RenderText_Blended: Render text with antialiasing to a surface
;; font: the font to use
;; text: UTF-8 text to render
;; length: length in bytes, or 0 for null-terminated
;; fg: foreground color (passed by value)
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderText-Blended
  (_fun _TTF_Font-pointer _string _size _SDL_Color -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderText_Blended)

;; TTF_RenderText_Blended_Wrapped: Render word-wrapped text with antialiasing
;; font: the font to use
;; text: UTF-8 text to render
;; length: length in bytes, or 0 for null-terminated
;; fg: foreground color (passed by value)
;; wrap_width: maximum line width in pixels
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderText-Blended-Wrapped
  (_fun _TTF_Font-pointer _string _size _SDL_Color _int -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderText_Blended_Wrapped)

;; ============================================================================
;; Single Glyph Rendering
;; ============================================================================

;; TTF_RenderGlyph_Solid: Render a single glyph at fast quality
;; font: the font to use
;; ch: Unicode codepoint
;; fg: foreground color (passed by value)
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderGlyph-Solid
  (_fun _TTF_Font-pointer _uint32 _SDL_Color -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderGlyph_Solid)

;; TTF_RenderGlyph_Blended: Render a single glyph with antialiasing
;; font: the font to use
;; ch: Unicode codepoint
;; fg: foreground color (passed by value)
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderGlyph-Blended
  (_fun _TTF_Font-pointer _uint32 _SDL_Color -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderGlyph_Blended)

;; ============================================================================
;; Text Measurement
;; ============================================================================

;; TTF_GetStringSize: Get the size of a string when rendered
;; font: the font to use
;; text: UTF-8 text to measure
;; length: length in bytes, or 0 for null-terminated
;; w: pointer to store width (can be NULL)
;; h: pointer to store height (can be NULL)
;; Returns: true on success, false on failure
(define-ttf TTF-GetStringSize
  (_fun _TTF_Font-pointer _string _size _pointer _pointer -> _bool)
  #:c-id TTF_GetStringSize)
