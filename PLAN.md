# SDL3 Remaining Work Plan (No OpenGL/Vulkan)

Focus on demoable, user-visible work first, with small smoke examples per
subsystem for items that are hard to show on screen. Each phase adds raw
bindings, safe wrappers, constants/types, and example coverage.

## Requirements
- Keep safe wrappers as the default API surface.
- Provide a demo or a subsystem-specific smoke example for each phase.
- Keep constants/types/enums aligned with SDL3 headers.
- Update re-exports and README where new APIs should be visible.

## Scope
- In: All items in `TODO.md` except OpenGL and Vulkan support.
- Out: OpenGL/Vulkan bindings and examples.

## Files and entry points
- `private/types.rkt`
- `private/constants.rkt`
- `private/enums.rkt`
- `raw/*.rkt`
- `safe/*.rkt`
- `raw.rkt`
- `safe.rkt`
- `examples/`
- `README.md` (as needed)

## Phased plan
[x] Phase 1: Drop + clipboard events
    - Add event constants and structs for drop + clipboard events.
    - Parse events in `safe/events.rkt`.
    - Add `examples/input/drop-events.rkt` and `examples/input/clipboard-events.rkt`.

[x] Phase 2: Audio device events + app metadata
    - Add audio device event struct + constants.
    - Add raw bindings for app metadata (init subsystem helpers if needed).
    - Add `examples/audio/device-events.rkt` and `examples/advanced/app-metadata.rkt`.

[x] Phase 3: Texture streaming + float color/alpha mods
    - Add raw texture update/lock APIs and float mod APIs.
    - Add safe helpers for streaming textures.
    - Add `examples/textures/streaming-texture.rkt`.

[x] Phase 4: Timer callbacks
    - Add `SDL_AddTimer`, `SDL_AddTimerNS`, `SDL_RemoveTimer`.
    - Add safe wrapper with explicit lifetime management.
    - Add `examples/animation/timer-callbacks.rkt`.

[x] Phase 5: SDL_image IOStream + format detection
    - Add IOStream load/save APIs and format checks.
    - Add safe wrappers that accept ports/bytes.
    - Add `examples/textures/image-io.rkt`.

[x] Phase 6: Input enumeration + rect utilities
    - Add keyboard/mouse enumeration APIs.
    - Add rectangle union/intersection helpers.
    - Add `examples/input/device-enumeration.rkt` and `examples/advanced/rect-utils.rkt`.

[x] Phase 7: Audio advanced
    - Add device format/gain, stream open, mix/convert, format name.
    - Add `examples/audio/advanced-audio.rkt`.

[ ] Phase 8: Joystick + gamepad advanced
    - Add send effect + mapping APIs.
    - Add `examples/input/gamepad-mapping.rkt`.

[ ] Phase 9: Touch + pen events
    - Add touch/pen event structs and constants.
    - Add parsing in `safe/events.rkt`.
    - Add `examples/input/touch-pen-events.rkt`.

[x] Phase 10: SDL_ttf advanced
    - Add remaining TTF IO and text engine APIs.
    - Add `examples/text/ttf-advanced.rkt`.

## Testing and validation
- Use `PLTCOLLECTS="$PWD:"` with examples for each phase.
- `PLTCOLLECTS="$PWD:" /opt/homebrew/bin/raco make safe.rkt` after each phase.

## Risks and edge cases
- Event struct sizes/alignment must match SDL3 headers.
- Timer callbacks require GC-safe lifetime management.
- IOStream bindings need clear ownership rules to avoid leaks or double free.
- Some APIs are platform-dependent; examples should handle missing features.
