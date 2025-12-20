# SDL_ttf Complete Implementation Plan

This document outlines the plan to implement the remaining SDL_ttf bindings for racket-sdl3.

## Current State

**Already Implemented (16 raw bindings, 4 safe wrappers):**

### Raw Layer (`raw/ttf.rkt`)
- `TTF-Init`, `TTF-Quit`, `TTF-WasInit` (initialization)
- `TTF-OpenFont`, `TTF-CloseFont` (font loading)
- `TTF-GetFontSize`, `TTF-GetFontHeight`, `TTF-GetFontAscent`, `TTF-GetFontDescent` (font metrics)
- `TTF-RenderText-Solid`, `TTF-RenderText-Shaded`, `TTF-RenderText-Blended`, `TTF-RenderText-Blended-Wrapped` (text rendering)
- `TTF-RenderGlyph-Solid`, `TTF-RenderGlyph-Blended` (glyph rendering)
- `TTF-GetStringSize` (text measurement)

### Safe Layer (`safe/ttf.rkt`)
- `open-font` - Load a font file with custodian cleanup
- `close-font!` / `font-destroy!` - Close a font
- `render-text` - Render text to a texture (supports 'solid and 'blended modes)
- `draw-text!` - Convenience function to render and draw text immediately

## Implementation Phases

### Phase 1: Constants & Enums
**File:** `private/constants.rkt`

Add the following constants:

```racket
;; Font style flags (can be OR'd together)
(define TTF_STYLE_NORMAL        #x00)
(define TTF_STYLE_BOLD          #x01)
(define TTF_STYLE_ITALIC        #x02)
(define TTF_STYLE_UNDERLINE     #x04)
(define TTF_STYLE_STRIKETHROUGH #x08)

;; Font hinting modes
(define TTF_HINTING_INVALID        -1)
(define TTF_HINTING_NORMAL          0)
(define TTF_HINTING_LIGHT           1)
(define TTF_HINTING_MONO            2)
(define TTF_HINTING_NONE            3)
(define TTF_HINTING_LIGHT_SUBPIXEL  4)

;; Horizontal alignment for wrapped text
(define TTF_HORIZONTAL_ALIGN_INVALID -1)
(define TTF_HORIZONTAL_ALIGN_LEFT     0)
(define TTF_HORIZONTAL_ALIGN_CENTER   1)
(define TTF_HORIZONTAL_ALIGN_RIGHT    2)

;; Text direction (values match HarfBuzz)
(define TTF_DIRECTION_INVALID 0)
(define TTF_DIRECTION_LTR     4)  ; Left to Right
(define TTF_DIRECTION_RTL     5)  ; Right to Left
(define TTF_DIRECTION_TTB     6)  ; Top to Bottom
(define TTF_DIRECTION_BTT     7)  ; Bottom to Top

;; Glyph image types
(define TTF_IMAGE_INVALID 0)
(define TTF_IMAGE_ALPHA   1)  ; Color channels are white, alpha has data
(define TTF_IMAGE_COLOR   2)  ; All color channels have data
(define TTF_IMAGE_SDF     3)  ; Alpha has signed distance field

;; Font weight constants
(define TTF_FONT_WEIGHT_THIN        100)
(define TTF_FONT_WEIGHT_EXTRA_LIGHT 200)
(define TTF_FONT_WEIGHT_LIGHT       300)
(define TTF_FONT_WEIGHT_NORMAL      400)
(define TTF_FONT_WEIGHT_MEDIUM      500)
(define TTF_FONT_WEIGHT_SEMI_BOLD   600)
(define TTF_FONT_WEIGHT_BOLD        700)
(define TTF_FONT_WEIGHT_EXTRA_BOLD  800)
(define TTF_FONT_WEIGHT_BLACK       900)
(define TTF_FONT_WEIGHT_EXTRA_BLACK 950)
```

Also define FFI enum types in `raw/ttf.rkt`:
```racket
(define _TTF_HintingFlags _int)
(define _TTF_HorizontalAlignment _int)
(define _TTF_Direction _int)
(define _TTF_ImageType _int)
(define _TTF_FontStyleFlags _uint32)
```

---

### Phase 2: Types
**File:** `raw/ttf.rkt` (already has `_TTF_Font-pointer`)

Add if needed for Text Engine support (Phase 10):
```racket
(define-cpointer-type _TTF_TextEngine-pointer)
(define-cpointer-type _TTF_Text-pointer)
```

---

### Phase 3: Core Font Properties
**File:** `raw/ttf.rkt`

#### Font Style & Appearance
| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-SetFontStyle` | `(font, style) -> void` | style is OR'd flags |
| `TTF-GetFontStyle` | `(font) -> uint32` | |
| `TTF-SetFontOutline` | `(font, outline) -> bool` | outline in pixels |
| `TTF-GetFontOutline` | `(font) -> int` | |
| `TTF-SetFontHinting` | `(font, hinting) -> void` | |
| `TTF-GetFontHinting` | `(font) -> int` | returns TTF_HINTING_* |
| `TTF-SetFontSDF` | `(font, enabled) -> bool` | Signed Distance Field |
| `TTF-GetFontSDF` | `(font) -> bool` | |

#### Font Size & Spacing
| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-SetFontSize` | `(font, ptsize) -> bool` | ptsize is float |
| `TTF-SetFontSizeDPI` | `(font, ptsize, hdpi, vdpi) -> bool` | |
| `TTF-GetFontDPI` | `(font, hdpi*, vdpi*) -> bool` | output params |
| `TTF-SetFontLineSkip` | `(font, lineskip) -> void` | |
| `TTF-GetFontLineSkip` | `(font) -> int` | |
| `TTF-SetFontKerning` | `(font, enabled) -> void` | |
| `TTF-GetFontKerning` | `(font) -> bool` | |

#### Font Metadata
| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-GetFontWeight` | `(font) -> int` | 100-950 range |
| `TTF-GetFontFamilyName` | `(font) -> string` | internal storage, don't free |
| `TTF-GetFontStyleName` | `(font) -> string` | internal storage, don't free |
| `TTF-GetNumFontFaces` | `(font) -> int` | |
| `TTF-FontIsFixedWidth` | `(font) -> bool` | monospace check |
| `TTF-FontIsScalable` | `(font) -> bool` | |

#### Wrap Alignment
| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-SetFontWrapAlignment` | `(font, align) -> void` | |
| `TTF-GetFontWrapAlignment` | `(font) -> int` | |

---

### Phase 4: Text Shaping (HarfBuzz)
**File:** `raw/ttf.rkt`

| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-SetFontDirection` | `(font, direction) -> bool` | Returns false if no HarfBuzz |
| `TTF-GetFontDirection` | `(font) -> int` | |
| `TTF-SetFontScript` | `(font, script) -> bool` | ISO 15924 code as uint32 |
| `TTF-GetFontScript` | `(font) -> uint32` | |
| `TTF-SetFontLanguage` | `(font, language) -> bool` | BCP47 string |
| `TTF-StringToTag` | `(string) -> uint32` | 4-char string to tag |
| `TTF-TagToString` | `(tag, string, size) -> void` | tag to 4-char string |
| `TTF-GetGlyphScript` | `(ch) -> uint32` | script for codepoint |

---

### Phase 5: Glyph Operations
**File:** `raw/ttf.rkt`

| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-FontHasGlyph` | `(font, ch) -> bool` | ch is Unicode codepoint |
| `TTF-GetGlyphImage` | `(font, ch, image_type*) -> surface` | |
| `TTF-GetGlyphImageForIndex` | `(font, glyph_index, image_type*) -> surface` | |
| `TTF-GetGlyphMetrics` | `(font, ch, minx*, maxx*, miny*, maxy*, advance*) -> bool` | 5 output params |
| `TTF-GetGlyphKerning` | `(font, prev_ch, ch, kerning*) -> bool` | |

---

### Phase 6: Text Measurement
**File:** `raw/ttf.rkt`

| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-GetStringSizeWrapped` | `(font, text, length, wrap_width, w*, h*) -> bool` | |
| `TTF-MeasureString` | `(font, text, length, max_width, measured_width*, measured_length*) -> bool` | How much fits in width |

---

### Phase 7: Additional Rendering
**File:** `raw/ttf.rkt`

| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-RenderText-Solid-Wrapped` | `(font, text, length, fg, wrapLength) -> surface` | |
| `TTF-RenderText-Shaded-Wrapped` | `(font, text, length, fg, bg, wrap_width) -> surface` | |
| `TTF-RenderGlyph-Shaded` | `(font, ch, fg, bg) -> surface` | |
| `TTF-RenderText-LCD` | `(font, text, length, fg, bg) -> surface` | Subpixel rendering |
| `TTF-RenderText-LCD-Wrapped` | `(font, text, length, fg, bg, wrap_width) -> surface` | |
| `TTF-RenderGlyph-LCD` | `(font, ch, fg, bg) -> surface` | |

---

### Phase 8: Font Loading Extras
**File:** `raw/ttf.rkt`

| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-CopyFont` | `(existing_font) -> font` | Clone a font |
| `TTF-AddFallbackFont` | `(font, fallback) -> bool` | For missing glyphs |
| `TTF-RemoveFallbackFont` | `(font, fallback) -> void` | |
| `TTF-ClearFallbackFonts` | `(font) -> void` | |

---

### Phase 9: Version & Info
**File:** `raw/ttf.rkt`

| Function | Signature | Notes |
|----------|-----------|-------|
| `TTF-Version` | `() -> int` | SDL_ttf version |
| `TTF-GetFreeTypeVersion` | `(major*, minor*, patch*) -> void` | |
| `TTF-GetHarfBuzzVersion` | `(major*, minor*, patch*) -> void` | 0.0.0 if not available |

---

### Phase 10: Text Engine API (Advanced)
**File:** `raw/ttf.rkt`

This is a more advanced API for efficient text rendering with caching. Lower priority.

#### Renderer Text Engine
| Function | Signature |
|----------|-----------|
| `TTF-CreateRendererTextEngine` | `(renderer) -> text_engine` |
| `TTF-DestroyRendererTextEngine` | `(engine) -> void` |
| `TTF-DrawRendererText` | `(text, x, y) -> bool` |

#### Text Objects
| Function | Signature |
|----------|-----------|
| `TTF-CreateText` | `(engine, font, text, length) -> ttf_text` |
| `TTF-DestroyText` | `(text) -> void` |
| `TTF-SetTextString` | `(text, string, length) -> bool` |
| `TTF-AppendTextString` | `(text, string, length) -> bool` |
| `TTF-InsertTextString` | `(text, offset, string, length) -> bool` |
| `TTF-DeleteTextString` | `(text, offset, length) -> bool` |
| `TTF-GetTextSize` | `(text, w*, h*) -> bool` |
| `TTF-SetTextColor` | `(text, r, g, b, a) -> bool` |
| `TTF-GetTextColor` | `(text, r*, g*, b*, a*) -> bool` |
| `TTF-SetTextPosition` | `(text, x, y) -> bool` |
| `TTF-GetTextPosition` | `(text, x*, y*) -> bool` |
| `TTF-SetTextWrapWidth` | `(text, wrap_width) -> bool` |
| `TTF-GetTextWrapWidth` | `(text, wrap_width*) -> bool` |
| `TTF-UpdateText` | `(text) -> bool` |

#### Surface Text Engine (similar pattern)
| Function | Signature |
|----------|-----------|
| `TTF-CreateSurfaceTextEngine` | `() -> text_engine` |
| `TTF-DestroySurfaceTextEngine` | `(engine) -> void` |
| `TTF-DrawSurfaceText` | `(text, x, y, surface) -> bool` |

---

### Phase 11: Safe Wrappers
**File:** `safe/ttf.rkt`

#### Font Properties (Phases 3-4)
```racket
;; Getters - return values directly
(font-style font) -> symbol or list of symbols ('normal, 'bold, 'italic, etc.)
(font-outline font) -> integer
(font-hinting font) -> symbol ('normal, 'light, 'mono, 'none, 'light-subpixel)
(font-line-skip font) -> integer
(font-kerning? font) -> boolean
(font-fixed-width? font) -> boolean
(font-scalable? font) -> boolean
(font-family-name font) -> string
(font-style-name font) -> string
(font-weight font) -> integer
(font-sdf? font) -> boolean
(font-direction font) -> symbol ('ltr, 'rtl, 'ttb, 'btt)
(font-wrap-alignment font) -> symbol ('left, 'center, 'right)

;; Setters - mutate the font
(set-font-style! font style ...) -> void  ; accepts symbols
(set-font-outline! font pixels) -> void
(set-font-hinting! font mode) -> void     ; accepts symbol
(set-font-size! font size [hdpi vdpi]) -> void
(set-font-line-skip! font skip) -> void
(set-font-kerning! font enabled?) -> void
(set-font-sdf! font enabled?) -> void
(set-font-direction! font direction) -> void
(set-font-wrap-alignment! font alignment) -> void
```

#### Text Measurement (Phase 6)
```racket
(text-size font text) -> (values width height)
(text-size-wrapped font text wrap-width) -> (values width height)
(measure-text font text max-width) -> (values fitted-width fitted-length)
```

#### Glyph Operations (Phase 5)
```racket
(font-has-glyph? font char-or-codepoint) -> boolean
(glyph-metrics font char) -> (values minx maxx miny maxy advance)
(glyph-kerning font prev-char char) -> integer
```

#### Enhanced Rendering
Extend `render-text` to support all modes:
```racket
(render-text font text color
             #:renderer renderer
             #:mode mode           ; 'solid, 'shaded, 'blended, 'lcd
             #:background bg-color ; for 'shaded and 'lcd modes
             #:wrap-width width    ; optional wrapping
             #:custodian cust)
```

#### Fallback Fonts (Phase 8)
```racket
(add-fallback-font! font fallback-font) -> void
(remove-fallback-font! font fallback-font) -> void
(clear-fallback-fonts! font) -> void
(copy-font font #:custodian cust) -> font
```

#### Version Info (Phase 9)
```racket
(ttf-version) -> (values major minor patch)
(freetype-version) -> (values major minor patch)
(harfbuzz-version) -> (values major minor patch) or #f
```

---

## Implementation Notes for Developers

### FFI Patterns Used in This Codebase

1. **Library loading:** Uses `load-sdl-library` from `private/lib.rkt`
2. **Function binding:** Uses `define-ttf` with `#:c-id` for C name mapping
3. **Pointer types:** Use `define-cpointer-type` for opaque handles
4. **Color passing:** `_SDL_Color` is passed by value, not pointer
5. **Output parameters:** Use `_pointer` and allocate with `(malloc _int)` etc.

### Safe Wrapper Patterns

1. **Resource management:** Use `define-sdl-resource` macro from `private/safe-syntax.rkt`
2. **Custodian cleanup:** Register with `register-custodian-shutdown`
3. **Error handling:** Check return values, call `SDL-GetError` on failure
4. **Destroyed check:** Wrapped resources have `*-destroyed?` predicate

### Testing Approach

Run examples to verify bindings work:
```bash
PLTCOLLECTS="$PWD:" /opt/homebrew/bin/racket examples/text/text.rkt
```

Create a new example `examples/text/font-properties.rkt` to test new bindings.

### Key Header Reference

The authoritative source is:
```
/opt/homebrew/include/SDL3_ttf/SDL_ttf.h
```

### Dependencies

- Phase 1-9 have no external dependencies beyond what's already implemented
- Phase 10 (Text Engine) requires `_SDL_Renderer-pointer` which exists in `raw/render.rkt`

---

## Recommended Implementation Order

1. **Phase 1**: Constants - foundation for everything else
2. **Phase 3**: Core font properties - most commonly needed features
3. **Phase 6**: Text measurement - essential for layout
4. **Phase 5**: Glyph operations - useful for custom rendering
5. **Phase 7**: Additional rendering modes - completes rendering API
6. **Phase 4**: Text shaping - for international text support
7. **Phase 8**: Font loading extras - fallback fonts are useful
8. **Phase 9**: Version info - nice to have
9. **Phase 10**: Text Engine - advanced, can be deferred
10. **Phase 11**: Safe wrappers - build alongside each phase

---

## Estimated Scope

| Category | Count |
|----------|-------|
| New constants/enums | ~50 |
| New raw bindings | ~65 |
| New safe wrappers | ~25 |
| New examples | 1-2 |

Total: Roughly 140 new definitions across all phases.
