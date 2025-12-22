# Documentation TODO

This file tracks which modules need Scribble documentation.

## Documented

- [x] `initialization.scrbl` - SDL init/quit, with-sdl
- [x] `window.scrbl` - Windows, renderers, with-window, with-renderer
- [x] `drawing.scrbl` - Drawing primitives, colors, blend modes, rendering
- [x] `events.scrbl` - Event polling, event structs, in-events
- [x] `keyboard.scrbl` - Keyboard state, modifiers, text input
- [x] `timer.scrbl` - Timing, delays, performance counter
- [x] `mouse.scrbl` - Mouse state, cursor control
- [x] `texture.scrbl` - Texture loading, rendering, render targets
- [x] `ttf.scrbl` - TrueType font rendering
- [x] `audio.scrbl` - Audio playback and streams
- [x] `collision.scrbl` - Rectangle collision detection
- [x] `display.scrbl` - Display/monitor information
- [x] `clipboard.scrbl` - Clipboard access
- [x] `dialog.scrbl` - File dialogs and message boxes
- [x] `image.scrbl` - Image loading/saving (SDL_image)
- [x] `hints.scrbl` - Configuration hints
- [x] `gamepad.scrbl` - Game controller support
- [x] `joystick.scrbl` - Raw joystick access
- [x] `camera.scrbl` - Camera/webcam capture
- [x] `properties.scrbl` - SDL property bags
- [x] `tray.scrbl` - System tray icons

## Not Yet Documented

### Advanced/Optional

- [ ] `gl.scrbl` - OpenGL context management
  - `create-gl-context`, `destroy-gl-context!`
  - `gl-make-current!`, `gl-swap-window!`
  - GL attribute getters/setters

- [ ] `vulkan.scrbl` - Vulkan integration
  - `create-vulkan-surface`, `destroy-vulkan-surface!`
  - Vulkan instance extensions

- [ ] `gpu.scrbl` - SDL GPU API (new in SDL3)
  - Device creation, command buffers
  - Render passes, shaders, pipelines
  - Buffer and texture management
  - This is a large API, may need multiple sections

## Notes

- Run `make check-docs` to verify documented functions match exports
- The raw API (`sdl3/raw`) is not documented - users should refer to SDL3 C documentation
- Constants (SDL_*, SDLK_*, etc.) are re-exported but not individually documented
