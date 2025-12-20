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
;; Font Style & Appearance
;; ============================================================================

;; TTF_SetFontStyle: Set the style of a font
;; font: the font to modify
;; style: OR'd combination of TTF_STYLE_* flags
(define-ttf TTF-SetFontStyle (_fun _TTF_Font-pointer _TTF_FontStyleFlags -> _void)
  #:c-id TTF_SetFontStyle)

;; TTF_GetFontStyle: Get the current style of a font
;; font: the font to query
;; Returns: OR'd combination of TTF_STYLE_* flags
(define-ttf TTF-GetFontStyle (_fun _TTF_Font-pointer -> _TTF_FontStyleFlags)
  #:c-id TTF_GetFontStyle)

;; TTF_SetFontOutline: Set the outline thickness of a font
;; font: the font to modify
;; outline: outline thickness in pixels (0 for no outline)
;; Returns: true on success, false on failure
(define-ttf TTF-SetFontOutline (_fun _TTF_Font-pointer _int -> _bool)
  #:c-id TTF_SetFontOutline)

;; TTF_GetFontOutline: Get the outline thickness of a font
;; font: the font to query
;; Returns: outline thickness in pixels
(define-ttf TTF-GetFontOutline (_fun _TTF_Font-pointer -> _int)
  #:c-id TTF_GetFontOutline)

;; TTF_SetFontHinting: Set the hinting mode of a font
;; font: the font to modify
;; hinting: one of TTF_HINTING_* constants
(define-ttf TTF-SetFontHinting (_fun _TTF_Font-pointer _TTF_HintingFlags -> _void)
  #:c-id TTF_SetFontHinting)

;; TTF_GetFontHinting: Get the hinting mode of a font
;; font: the font to query
;; Returns: one of TTF_HINTING_* constants
(define-ttf TTF-GetFontHinting (_fun _TTF_Font-pointer -> _TTF_HintingFlags)
  #:c-id TTF_GetFontHinting)

;; TTF_SetFontSDF: Enable or disable Signed Distance Field rendering
;; font: the font to modify
;; enabled: true to enable SDF, false to disable
;; Returns: true on success, false on failure
(define-ttf TTF-SetFontSDF (_fun _TTF_Font-pointer _bool -> _bool)
  #:c-id TTF_SetFontSDF)

;; TTF_GetFontSDF: Check if SDF rendering is enabled
;; font: the font to query
;; Returns: true if SDF is enabled, false otherwise
(define-ttf TTF-GetFontSDF (_fun _TTF_Font-pointer -> _bool)
  #:c-id TTF_GetFontSDF)

;; ============================================================================
;; Font Size & Spacing
;; ============================================================================

;; TTF_SetFontSize: Set the size of a font
;; font: the font to modify
;; ptsize: point size as float
;; Returns: true on success, false on failure
(define-ttf TTF-SetFontSize (_fun _TTF_Font-pointer _float -> _bool)
  #:c-id TTF_SetFontSize)

;; TTF_SetFontSizeDPI: Set the size of a font with specific DPI
;; font: the font to modify
;; ptsize: point size as float
;; hdpi: horizontal DPI
;; vdpi: vertical DPI
;; Returns: true on success, false on failure
(define-ttf TTF-SetFontSizeDPI (_fun _TTF_Font-pointer _float _int _int -> _bool)
  #:c-id TTF_SetFontSizeDPI)

;; TTF_GetFontDPI: Get the DPI of a font
;; font: the font to query
;; hdpi: pointer to store horizontal DPI (can be NULL)
;; vdpi: pointer to store vertical DPI (can be NULL)
;; Returns: true on success, false on failure
(define-ttf TTF-GetFontDPI (_fun _TTF_Font-pointer _pointer _pointer -> _bool)
  #:c-id TTF_GetFontDPI)

;; TTF_SetFontLineSkip: Set the line skip (line spacing) of a font
;; font: the font to modify
;; lineskip: line spacing in pixels
(define-ttf TTF-SetFontLineSkip (_fun _TTF_Font-pointer _int -> _void)
  #:c-id TTF_SetFontLineSkip)

;; TTF_GetFontLineSkip: Get the line skip (line spacing) of a font
;; font: the font to query
;; Returns: line spacing in pixels
(define-ttf TTF-GetFontLineSkip (_fun _TTF_Font-pointer -> _int)
  #:c-id TTF_GetFontLineSkip)

;; TTF_SetFontKerning: Enable or disable kerning for a font
;; font: the font to modify
;; enabled: true to enable kerning, false to disable
(define-ttf TTF-SetFontKerning (_fun _TTF_Font-pointer _bool -> _void)
  #:c-id TTF_SetFontKerning)

;; TTF_GetFontKerning: Check if kerning is enabled for a font
;; font: the font to query
;; Returns: true if kerning is enabled, false otherwise
(define-ttf TTF-GetFontKerning (_fun _TTF_Font-pointer -> _bool)
  #:c-id TTF_GetFontKerning)

;; ============================================================================
;; Font Metadata
;; ============================================================================

;; TTF_GetFontWeight: Get the weight of a font
;; font: the font to query
;; Returns: weight value (100-950)
(define-ttf TTF-GetFontWeight (_fun _TTF_Font-pointer -> _int)
  #:c-id TTF_GetFontWeight)

;; TTF_GetFontFamilyName: Get the family name of a font
;; font: the font to query
;; Returns: family name string (internal storage, do not free)
(define-ttf TTF-GetFontFamilyName (_fun _TTF_Font-pointer -> _string/utf-8)
  #:c-id TTF_GetFontFamilyName)

;; TTF_GetFontStyleName: Get the style name of a font
;; font: the font to query
;; Returns: style name string (internal storage, do not free)
(define-ttf TTF-GetFontStyleName (_fun _TTF_Font-pointer -> _string/utf-8)
  #:c-id TTF_GetFontStyleName)

;; TTF_GetNumFontFaces: Get the number of faces in a font file
;; font: the font to query
;; Returns: number of faces
(define-ttf TTF-GetNumFontFaces (_fun _TTF_Font-pointer -> _int)
  #:c-id TTF_GetNumFontFaces)

;; TTF_FontIsFixedWidth: Check if a font is fixed-width (monospace)
;; font: the font to query
;; Returns: true if fixed-width, false otherwise
(define-ttf TTF-FontIsFixedWidth (_fun _TTF_Font-pointer -> _bool)
  #:c-id TTF_FontIsFixedWidth)

;; TTF_FontIsScalable: Check if a font is scalable (TrueType/OpenType)
;; font: the font to query
;; Returns: true if scalable, false otherwise
(define-ttf TTF-FontIsScalable (_fun _TTF_Font-pointer -> _bool)
  #:c-id TTF_FontIsScalable)

;; ============================================================================
;; Wrap Alignment
;; ============================================================================

;; TTF_SetFontWrapAlignment: Set the alignment for wrapped text
;; font: the font to modify
;; align: one of TTF_HORIZONTAL_ALIGN_* constants
(define-ttf TTF-SetFontWrapAlignment (_fun _TTF_Font-pointer _TTF_HorizontalAlignment -> _void)
  #:c-id TTF_SetFontWrapAlignment)

;; TTF_GetFontWrapAlignment: Get the alignment for wrapped text
;; font: the font to query
;; Returns: one of TTF_HORIZONTAL_ALIGN_* constants
(define-ttf TTF-GetFontWrapAlignment (_fun _TTF_Font-pointer -> _TTF_HorizontalAlignment)
  #:c-id TTF_GetFontWrapAlignment)

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

;; TTF_RenderText_Solid_Wrapped: Render word-wrapped text at fast quality
;; font: the font to use
;; text: UTF-8 text to render
;; length: length in bytes, or 0 for null-terminated
;; fg: foreground color (passed by value)
;; wrap_width: maximum line width in pixels
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderText-Solid-Wrapped
  (_fun _TTF_Font-pointer _string _size _SDL_Color _int -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderText_Solid_Wrapped)

;; TTF_RenderText_Shaded_Wrapped: Render word-wrapped text at high quality
;; font: the font to use
;; text: UTF-8 text to render
;; length: length in bytes, or 0 for null-terminated
;; fg: foreground color (passed by value)
;; bg: background color (passed by value)
;; wrap_width: maximum line width in pixels
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderText-Shaded-Wrapped
  (_fun _TTF_Font-pointer _string _size _SDL_Color _SDL_Color _int -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderText_Shaded_Wrapped)

;; TTF_RenderText_LCD: Render text with LCD subpixel rendering
;; font: the font to use
;; text: UTF-8 text to render
;; length: length in bytes, or 0 for null-terminated
;; fg: foreground color (passed by value)
;; bg: background color (passed by value)
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderText-LCD
  (_fun _TTF_Font-pointer _string _size _SDL_Color _SDL_Color -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderText_LCD)

;; TTF_RenderText_LCD_Wrapped: Render word-wrapped text with LCD subpixel rendering
;; font: the font to use
;; text: UTF-8 text to render
;; length: length in bytes, or 0 for null-terminated
;; fg: foreground color (passed by value)
;; bg: background color (passed by value)
;; wrap_width: maximum line width in pixels
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderText-LCD-Wrapped
  (_fun _TTF_Font-pointer _string _size _SDL_Color _SDL_Color _int -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderText_LCD_Wrapped)

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

;; TTF_RenderGlyph_Shaded: Render a single glyph at high quality
;; font: the font to use
;; ch: Unicode codepoint
;; fg: foreground color (passed by value)
;; bg: background color (passed by value)
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderGlyph-Shaded
  (_fun _TTF_Font-pointer _uint32 _SDL_Color _SDL_Color -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderGlyph_Shaded)

;; TTF_RenderGlyph_LCD: Render a single glyph with LCD subpixel rendering
;; font: the font to use
;; ch: Unicode codepoint
;; fg: foreground color (passed by value)
;; bg: background color (passed by value)
;; Returns: pointer to surface, or NULL on failure
(define-ttf TTF-RenderGlyph-LCD
  (_fun _TTF_Font-pointer _uint32 _SDL_Color _SDL_Color -> _SDL_Surface-pointer/null)
  #:c-id TTF_RenderGlyph_LCD)

;; ============================================================================
;; Glyph Operations
;; ============================================================================

;; TTF_FontHasGlyph: Check if a font has a glyph for a codepoint
;; font: the font to query
;; ch: Unicode codepoint
;; Returns: true if the font has the glyph, false otherwise
(define-ttf TTF-FontHasGlyph (_fun _TTF_Font-pointer _uint32 -> _bool)
  #:c-id TTF_FontHasGlyph)

;; TTF_GetGlyphImage: Get the glyph image for a codepoint
;; font: the font to use
;; ch: Unicode codepoint
;; image_type: pointer to store the image type (can be NULL)
;; Returns: surface containing the glyph, or NULL on failure
(define-ttf TTF-GetGlyphImage
  (_fun _TTF_Font-pointer _uint32 _pointer -> _SDL_Surface-pointer/null)
  #:c-id TTF_GetGlyphImage)

;; TTF_GetGlyphImageForIndex: Get the glyph image for a glyph index
;; font: the font to use
;; glyph_index: glyph index in the font
;; image_type: pointer to store the image type (can be NULL)
;; Returns: surface containing the glyph, or NULL on failure
(define-ttf TTF-GetGlyphImageForIndex
  (_fun _TTF_Font-pointer _uint32 _pointer -> _SDL_Surface-pointer/null)
  #:c-id TTF_GetGlyphImageForIndex)

;; TTF_GetGlyphMetrics: Get metrics for a glyph
;; font: the font to use
;; ch: Unicode codepoint
;; minx: pointer to store minimum x (can be NULL)
;; maxx: pointer to store maximum x (can be NULL)
;; miny: pointer to store minimum y (can be NULL)
;; maxy: pointer to store maximum y (can be NULL)
;; advance: pointer to store advance width (can be NULL)
;; Returns: true on success, false on failure
(define-ttf TTF-GetGlyphMetrics
  (_fun _TTF_Font-pointer _uint32 _pointer _pointer _pointer _pointer _pointer -> _bool)
  #:c-id TTF_GetGlyphMetrics)

;; TTF_GetGlyphKerning: Get kerning between two glyphs
;; font: the font to use
;; prev_ch: previous character codepoint
;; ch: current character codepoint
;; kerning: pointer to store kerning value
;; Returns: true on success, false on failure
(define-ttf TTF-GetGlyphKerning
  (_fun _TTF_Font-pointer _uint32 _uint32 _pointer -> _bool)
  #:c-id TTF_GetGlyphKerning)

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

;; TTF_GetStringSizeWrapped: Get the size of wrapped text when rendered
;; font: the font to use
;; text: UTF-8 text to measure
;; length: length in bytes, or 0 for null-terminated
;; wrap_width: maximum line width in pixels (0 for no wrapping)
;; w: pointer to store width (can be NULL)
;; h: pointer to store height (can be NULL)
;; Returns: true on success, false on failure
(define-ttf TTF-GetStringSizeWrapped
  (_fun _TTF_Font-pointer _string _size _int _pointer _pointer -> _bool)
  #:c-id TTF_GetStringSizeWrapped)

;; TTF_MeasureString: Measure how much of a string fits within a width
;; font: the font to use
;; text: UTF-8 text to measure
;; length: length in bytes, or 0 for null-terminated
;; max_width: maximum width in pixels
;; measured_width: pointer to store actual width used (can be NULL)
;; measured_length: pointer to store bytes that fit (can be NULL)
;; Returns: true on success, false on failure
(define-ttf TTF-MeasureString
  (_fun _TTF_Font-pointer _string _size _int _pointer _pointer -> _bool)
  #:c-id TTF_MeasureString)

;; ============================================================================
;; Text Shaping (HarfBuzz)
;; ============================================================================

;; TTF_SetFontDirection: Set the text direction for a font
;; font: the font to modify
;; direction: one of TTF_DIRECTION_* constants
;; Returns: true on success, false if HarfBuzz support is not available
(define-ttf TTF-SetFontDirection (_fun _TTF_Font-pointer _TTF_Direction -> _bool)
  #:c-id TTF_SetFontDirection)

;; TTF_GetFontDirection: Get the text direction of a font
;; font: the font to query
;; Returns: one of TTF_DIRECTION_* constants
(define-ttf TTF-GetFontDirection (_fun _TTF_Font-pointer -> _TTF_Direction)
  #:c-id TTF_GetFontDirection)

;; TTF_SetFontScript: Set the script for a font (ISO 15924 code)
;; font: the font to modify
;; script: 4-character script tag as uint32
;; Returns: true on success, false if HarfBuzz support is not available
(define-ttf TTF-SetFontScript (_fun _TTF_Font-pointer _uint32 -> _bool)
  #:c-id TTF_SetFontScript)

;; TTF_GetFontScript: Get the script of a font
;; font: the font to query
;; Returns: script tag as uint32
(define-ttf TTF-GetFontScript (_fun _TTF_Font-pointer -> _uint32)
  #:c-id TTF_GetFontScript)

;; TTF_SetFontLanguage: Set the language for a font (BCP47 code)
;; font: the font to modify
;; language: BCP47 language tag string (e.g., "en", "ar", "zh-Hans")
;; Returns: true on success, false if HarfBuzz support is not available
(define-ttf TTF-SetFontLanguage (_fun _TTF_Font-pointer _string -> _bool)
  #:c-id TTF_SetFontLanguage)

;; TTF_StringToTag: Convert a 4-character string to a tag
;; string: 4-character string
;; Returns: tag as uint32
(define-ttf TTF-StringToTag (_fun _string -> _uint32)
  #:c-id TTF_StringToTag)

;; TTF_TagToString: Convert a tag to a 4-character string
;; tag: tag value
;; string: buffer to store result (at least 5 bytes)
;; size: size of buffer
(define-ttf TTF-TagToString (_fun _uint32 _pointer _size -> _void)
  #:c-id TTF_TagToString)

;; TTF_GetGlyphScript: Get the script for a Unicode codepoint
;; ch: Unicode codepoint
;; Returns: script tag as uint32
(define-ttf TTF-GetGlyphScript (_fun _uint32 -> _uint32)
  #:c-id TTF_GetGlyphScript)
