# SDL3 Racket Bindings - Implementation Checklist

This document tracks the implementation status of SDL3, SDL3_image, and SDL3_ttf bindings.

## Currently Implemented

### Idiomatic Wrapper (`safe.rkt` and `safe/`)
A complete idiomatic Racket layer on top of the raw bindings, providing:
- Custodian-managed resources (automatic cleanup)
- Racket structs for events (with `match` support)
- Simpler APIs (fewer pointer manipulations)
- Drawing helpers, texture management, font/text rendering, mouse state

Modules: `safe.rkt`, `safe/window.rkt`, `safe/events.rkt`, `safe/draw.rkt`, `safe/texture.rkt`, `safe/ttf.rkt`, `safe/mouse.rkt`, `safe/clipboard.rkt`, `safe/timer.rkt`, `safe/audio.rkt`, `safe/keyboard.rkt`, `safe/display.rkt`, `safe/dialog.rkt`, `safe/hints.rkt`, `safe/joystick.rkt`, `safe/gamepad.rkt`

### SDL3 Core (`raw.rkt`)
- [x] `SDL_Init`
- [x] `SDL_Quit`
- [x] `SDL_GetError`
- [x] `SDL_CreateWindow`
- [x] `SDL_DestroyWindow`
- [x] `SDL_SetWindowTitle`
- [x] `SDL_GetWindowPixelDensity`
- [x] `SDL_GetWindowSize`
- [x] `SDL_SetWindowSize`
- [x] `SDL_GetWindowPosition`
- [x] `SDL_SetWindowPosition`
- [x] `SDL_GetWindowFlags`
- [x] `SDL_SetWindowFullscreen`
- [x] `SDL_CreateRenderer`
- [x] `SDL_DestroyRenderer`
- [x] `SDL_SetRenderDrawColor`
- [x] `SDL_RenderClear`
- [x] `SDL_RenderPresent`
- [x] `SDL_SetRenderDrawBlendMode`
- [x] `SDL_GetRenderDrawBlendMode`
- [x] `SDL_DestroyTexture`
- [x] `SDL_RenderTexture`
- [x] `SDL_RenderTextureRotated`
- [x] `SDL_GetTextureSize`
- [x] `SDL_CreateTextureFromSurface`
- [x] `SDL_SetTextureBlendMode`
- [x] `SDL_GetTextureBlendMode`
- [x] `SDL_SetTextureColorMod`
- [x] `SDL_GetTextureColorMod`
- [x] `SDL_SetTextureAlphaMod`
- [x] `SDL_GetTextureAlphaMod`
- [x] `SDL_DestroySurface`
- [x] `SDL_PollEvent`
- [x] `SDL_WaitEvent`
- [x] `SDL_WaitEventTimeout`
- [x] `SDL_GetKeyName`
- [x] `SDL_StartTextInput`
- [x] `SDL_StopTextInput`
- [x] `SDL_GetMouseState`
- [x] `SDL_GetRelativeMouseState`
- [x] `SDL_SetWindowRelativeMouseMode`
- [x] `SDL_GetWindowRelativeMouseMode`
- [x] `SDL_CreateSystemCursor`
- [x] `SDL_SetCursor`
- [x] `SDL_GetCursor`
- [x] `SDL_DestroyCursor`
- [x] `SDL_ShowCursor`
- [x] `SDL_HideCursor`
- [x] `SDL_CursorVisible`
- [x] `SDL_GetTicks`
- [x] `SDL_GetTicksNS`
- [x] `SDL_GetPerformanceCounter`
- [x] `SDL_GetPerformanceFrequency`
- [x] `SDL_Delay`
- [x] `SDL_DelayNS`
- [x] `SDL_DelayPrecise`
- [x] `SDL_SetClipboardText`
- [x] `SDL_GetClipboardText`
- [x] `SDL_HasClipboardText`
- [x] `SDL_free`
- [x] `SDL_CreateTexture`
- [x] `SDL_SetRenderTarget`
- [x] `SDL_GetRenderTarget`
- [x] `SDL_SetTextureScaleMode`
- [x] `SDL_GetTextureScaleMode`
- [x] `SDL_RenderReadPixels`
- [x] `SDL_HasRectIntersection`
- [x] `SDL_GetRectIntersection`
- [x] `SDL_HasRectIntersectionFloat`
- [x] `SDL_GetRectIntersectionFloat`
- [x] `SDL_CreateWindowAndRenderer`
- [x] `SDL_GetWindowTitle`
- [x] `SDL_SetWindowIcon`
- [x] `SDL_GetWindowID`
- [x] `SDL_GetWindowFromID`
- [x] `SDL_ShowWindow`
- [x] `SDL_HideWindow`
- [x] `SDL_RaiseWindow`
- [x] `SDL_MaximizeWindow`
- [x] `SDL_MinimizeWindow`
- [x] `SDL_RestoreWindow`
- [x] `SDL_SetWindowMinimumSize`
- [x] `SDL_SetWindowMaximumSize`
- [x] `SDL_GetWindowMinimumSize`
- [x] `SDL_GetWindowMaximumSize`
- [x] `SDL_SetWindowBordered`
- [x] `SDL_SetWindowResizable`
- [x] `SDL_SetWindowOpacity`
- [x] `SDL_GetWindowOpacity`
- [x] `SDL_FlashWindow`
- [x] `SDL_GetWindowSurface`
- [x] `SDL_UpdateWindowSurface`
- [x] `SDL_GetNumRenderDrivers`
- [x] `SDL_GetRenderDriver`
- [x] `SDL_GetRenderer`
- [x] `SDL_GetRenderWindow`
- [x] `SDL_GetRendererName`
- [x] `SDL_GetRenderOutputSize`
- [x] `SDL_GetCurrentRenderOutputSize`
- [x] `SDL_GetRenderDrawColor`
- [x] `SDL_SetRenderDrawColorFloat`
- [x] `SDL_GetRenderDrawColorFloat`
- [x] `SDL_SetRenderVSync`
- [x] `SDL_GetRenderVSync`
- [x] `SDL_SetRenderViewport`
- [x] `SDL_GetRenderViewport`
- [x] `SDL_SetRenderClipRect`
- [x] `SDL_GetRenderClipRect`
- [x] `SDL_RenderClipEnabled`
- [x] `SDL_SetRenderScale`
- [x] `SDL_GetRenderScale`
- [x] `SDL_RenderTextureAffine`
- [x] `SDL_RenderTextureTiled`
- [x] `SDL_RenderTexture9Grid`
- [x] `SDL_RenderGeometry`
- [x] `SDL_RenderDebugText`
- [x] `SDL_GetKeyboardState`
- [x] `SDL_GetModState`
- [x] `SDL_ResetKeyboard`
- [x] `SDL_GetKeyFromScancode`
- [x] `SDL_GetScancodeFromKey`
- [x] `SDL_GetScancodeName`
- [x] `SDL_GetScancodeFromName`
- [x] `SDL_GetKeyFromName`
- [x] `SDL_GetGlobalMouseState`
- [x] `SDL_WarpMouseInWindow`
- [x] `SDL_WarpMouseGlobal`
- [x] `SDL_CaptureMouse`
- [x] `SDL_GetDisplays`
- [x] `SDL_GetPrimaryDisplay`
- [x] `SDL_GetDisplayName`
- [x] `SDL_GetDisplayBounds`
- [x] `SDL_GetDisplayUsableBounds`
- [x] `SDL_GetCurrentDisplayMode`
- [x] `SDL_GetDesktopDisplayMode`
- [x] `SDL_GetFullscreenDisplayModes`
- [x] `SDL_GetDisplayForWindow`
- [x] `SDL_GetDisplayContentScale`
- [x] `SDL_GetWindowDisplayScale`
- [x] `SDL_ShowSimpleMessageBox`
- [x] `SDL_ShowMessageBox`
- [x] `SDL_ShowOpenFileDialog`
- [x] `SDL_ShowSaveFileDialog`
- [x] `SDL_ShowOpenFolderDialog`
- [x] `SDL_PumpEvents`

### SDL3_image (`image.rkt`)
- [x] `IMG_Version`
- [x] `IMG_LoadTexture`
- [x] `IMG_Load`
- [x] `IMG_SavePNG`
- [x] `IMG_SaveJPG`

### SDL3_ttf (`ttf.rkt`)
- [x] `TTF_Init`
- [x] `TTF_Quit`
- [x] `TTF_WasInit`
- [x] `TTF_OpenFont`
- [x] `TTF_CloseFont`
- [x] `TTF_GetFontSize`
- [x] `TTF_GetFontHeight`
- [x] `TTF_GetFontAscent`
- [x] `TTF_GetFontDescent`
- [x] `TTF_RenderText_Solid`
- [x] `TTF_RenderText_Shaded`
- [x] `TTF_RenderText_Blended`
- [x] `TTF_RenderText_Blended_Wrapped`
- [x] `TTF_RenderGlyph_Solid`
- [x] `TTF_RenderGlyph_Blended`
- [x] `TTF_GetStringSize`

### Types & Constants (`private/types.rkt`)
- [x] `_sdl-bool`, `_SDL_InitFlags`, `_SDL_WindowFlags`
- [x] `SDL_INIT_VIDEO`
- [x] `SDL_WINDOW_FULLSCREEN`, `SDL_WINDOW_RESIZABLE`, `SDL_WINDOW_HIGH_PIXEL_DENSITY`
- [x] Pointer types: `_SDL_Window-pointer`, `_SDL_Renderer-pointer`, `_SDL_Texture-pointer`, `_SDL_Surface-pointer`, `_SDL_Cursor-pointer`
- [x] `_SDL_Point` struct, `_SDL_FPoint` struct
- [x] `_SDL_Rect` struct, `_SDL_FRect` struct
- [x] `_SDL_Color` struct
- [x] `_SDL_FColor` struct (float colors for vertices)
- [x] `_SDL_Vertex` struct (for geometry rendering)
- [x] `_SDL_FlashOperation` enum
- [x] Event constants: `SDL_EVENT_QUIT`, window events, keyboard events, mouse events (incl. `SDL_EVENT_MOUSE_WHEEL`), text input
- [x] Event structs: `_SDL_CommonEvent`, `_SDL_KeyboardEvent`, `_SDL_MouseMotionEvent`, `_SDL_MouseButtonEvent`, `_SDL_TextInputEvent`, `_SDL_MouseWheelEvent`
- [x] Keyboard modifier constants: `SDL_KMOD_NONE`, `SDL_KMOD_LSHIFT`, `SDL_KMOD_RSHIFT`, `SDL_KMOD_CTRL`, `SDL_KMOD_ALT`, etc.
- [x] Key constants: `SDLK_ESCAPE`, `SDLK_SPACE`, arrow keys, R/G/B keys, full alphabet, numbers, F-keys
- [x] `_SDL_Keycode`
- [x] `_SDL_BlendMode` and all blend mode constants
- [x] `_SDL_FlipMode` and flip mode constants (`SDL_FLIP_NONE`, `SDL_FLIP_HORIZONTAL`, `SDL_FLIP_VERTICAL`)
- [x] `_SDL_TextureAccess` and constants (`SDL_TEXTUREACCESS_STATIC`, `_STREAMING`, `_TARGET`)
- [x] `_SDL_ScaleMode` and constants (`SDL_SCALEMODE_NEAREST`, `SDL_SCALEMODE_LINEAR`)
- [x] `_SDL_SystemCursor` enum and all 15 cursor type constants
- [x] Mouse button constants (`SDL_BUTTON_LEFT`, `_MIDDLE`, `_RIGHT`, `_X1`, `_X2`)

---

## Not Yet Implemented

### Priority Levels
- **P0**: Essential for basic games/apps
- **P1**: Important for most applications
- **P2**: Useful for specific use cases
- **P3**: Advanced/niche functionality

---

## SDL3 Core

### Initialization (P1)
- [ ] `SDL_InitSubSystem`
- [ ] `SDL_QuitSubSystem`
- [ ] `SDL_WasInit`
- [ ] `SDL_SetAppMetadata`
- [ ] `SDL_SetAppMetadataProperty`
- [ ] `SDL_GetAppMetadataProperty`

### Window Management (P0)
- [x] `SDL_CreateWindowAndRenderer`
- [x] `SDL_GetWindowTitle`
- [x] `SDL_SetWindowIcon`
- [x] `SDL_GetWindowSize`
- [x] `SDL_SetWindowSize`
- [x] `SDL_GetWindowPosition`
- [x] `SDL_SetWindowPosition`
- [x] `SDL_GetWindowFlags`
- [x] `SDL_ShowWindow`
- [x] `SDL_HideWindow`
- [x] `SDL_RaiseWindow`
- [x] `SDL_MaximizeWindow`
- [x] `SDL_MinimizeWindow`
- [x] `SDL_RestoreWindow`
- [x] `SDL_SetWindowFullscreen`
- [x] `SDL_SetWindowBordered`
- [x] `SDL_SetWindowResizable`
- [x] `SDL_GetWindowSurface`
- [x] `SDL_UpdateWindowSurface`
- [x] `SDL_GetWindowID`
- [x] `SDL_GetWindowFromID`
- [x] `SDL_SetWindowMinimumSize`
- [x] `SDL_SetWindowMaximumSize`
- [x] `SDL_GetWindowMinimumSize`
- [x] `SDL_GetWindowMaximumSize`
- [x] `SDL_SetWindowOpacity`
- [x] `SDL_GetWindowOpacity`
- [x] `SDL_FlashWindow`

### Display Management (P1)
- [x] `SDL_GetDisplays`
- [x] `SDL_GetPrimaryDisplay`
- [x] `SDL_GetDisplayName`
- [x] `SDL_GetDisplayBounds`
- [x] `SDL_GetDisplayUsableBounds`
- [x] `SDL_GetCurrentDisplayMode`
- [x] `SDL_GetDesktopDisplayMode`
- [x] `SDL_GetFullscreenDisplayModes`
- [x] `SDL_GetDisplayForWindow`
- [x] `SDL_GetDisplayContentScale`
- [x] `SDL_GetWindowDisplayScale`

### Renderer (P0)
- [x] `SDL_GetNumRenderDrivers`
- [x] `SDL_GetRenderDriver`
- [x] `SDL_GetRenderer`
- [x] `SDL_GetRenderWindow`
- [x] `SDL_GetRendererName`
- [x] `SDL_GetRenderOutputSize`
- [x] `SDL_GetCurrentRenderOutputSize`
- [x] `SDL_SetRenderTarget`
- [x] `SDL_GetRenderTarget`
- [x] `SDL_SetRenderViewport`
- [x] `SDL_GetRenderViewport`
- [x] `SDL_SetRenderClipRect`
- [x] `SDL_GetRenderClipRect`
- [x] `SDL_RenderClipEnabled`
- [x] `SDL_SetRenderScale`
- [x] `SDL_GetRenderScale`
- [x] `SDL_SetRenderDrawColorFloat`
- [x] `SDL_GetRenderDrawColor`
- [x] `SDL_GetRenderDrawColorFloat`
- [x] `SDL_SetRenderDrawBlendMode`
- [x] `SDL_GetRenderDrawBlendMode`
- [x] `SDL_SetRenderVSync`
- [x] `SDL_GetRenderVSync`

### Renderer Drawing (P0)
- [x] `SDL_RenderPoint`
- [x] `SDL_RenderPoints`
- [x] `SDL_RenderLine`
- [x] `SDL_RenderLines`
- [x] `SDL_RenderRect`
- [x] `SDL_RenderRects`
- [x] `SDL_RenderFillRect`
- [x] `SDL_RenderFillRects`
- [x] `SDL_RenderTextureRotated`
- [x] `SDL_RenderTextureAffine`
- [x] `SDL_RenderTextureTiled`
- [x] `SDL_RenderTexture9Grid`
- [x] `SDL_RenderGeometry`
- [ ] `SDL_RenderGeometryRaw`
- [x] `SDL_RenderReadPixels`
- [x] `SDL_RenderDebugText`
- [ ] `SDL_RenderDebugTextFormat`

### Texture (P1)
- [x] `SDL_CreateTexture`
- [ ] `SDL_CreateTextureWithProperties`
- [ ] `SDL_GetTextureProperties`
- [x] `SDL_SetTextureColorMod`
- [x] `SDL_GetTextureColorMod`
- [ ] `SDL_SetTextureColorModFloat`
- [ ] `SDL_GetTextureColorModFloat`
- [x] `SDL_SetTextureAlphaMod`
- [x] `SDL_GetTextureAlphaMod`
- [ ] `SDL_SetTextureAlphaModFloat`
- [ ] `SDL_GetTextureAlphaModFloat`
- [x] `SDL_SetTextureBlendMode`
- [x] `SDL_GetTextureBlendMode`
- [x] `SDL_SetTextureScaleMode`
- [x] `SDL_GetTextureScaleMode`
- [ ] `SDL_UpdateTexture`
- [ ] `SDL_UpdateYUVTexture`
- [ ] `SDL_UpdateNVTexture`
- [ ] `SDL_LockTexture`
- [ ] `SDL_LockTextureToSurface`
- [ ] `SDL_UnlockTexture`

### Surface Operations (P1)
- [x] `SDL_CreateSurface`
- [x] `SDL_CreateSurfaceFrom`
- [ ] `SDL_GetSurfaceProperties`
- [x] `SDL_LockSurface`
- [x] `SDL_UnlockSurface`
- [x] `SDL_LoadBMP`
- [ ] `SDL_LoadBMP_IO`
- [x] `SDL_SaveBMP`
- [ ] `SDL_SaveBMP_IO`
- [x] `SDL_BlitSurface`
- [x] `SDL_BlitSurfaceScaled`
- [ ] `SDL_BlitSurfaceUnchecked`
- [ ] `SDL_BlitSurfaceUncheckedScaled`
- [ ] `SDL_BlitSurfaceTiled`
- [ ] `SDL_BlitSurface9Grid`
- [x] `SDL_FillSurfaceRect`
- [x] `SDL_FillSurfaceRects`
- [x] `SDL_ConvertSurface`
- [ ] `SDL_ConvertSurfaceAndColorspace`
- [x] `SDL_DuplicateSurface`
- [x] `SDL_ScaleSurface`
- [x] `SDL_FlipSurface`
- [x] `SDL_ClearSurface`
- [x] `SDL_SetSurfaceColorKey`
- [x] `SDL_GetSurfaceColorKey`
- [x] `SDL_SurfaceHasColorKey`
- [x] `SDL_SetSurfaceAlphaMod`
- [x] `SDL_GetSurfaceAlphaMod`
- [x] `SDL_SetSurfaceColorMod`
- [x] `SDL_GetSurfaceColorMod`
- [x] `SDL_SetSurfaceBlendMode`
- [x] `SDL_GetSurfaceBlendMode`
- [x] `SDL_SetSurfaceClipRect`
- [x] `SDL_GetSurfaceClipRect`
- [x] `SDL_SetSurfaceRLE`
- [x] `SDL_SurfaceHasRLE`
- [x] `SDL_MapSurfaceRGB`
- [x] `SDL_MapSurfaceRGBA`
- [x] `SDL_ReadSurfacePixel`
- [x] `SDL_WriteSurfacePixel`
- [x] `SDL_ReadSurfacePixelFloat`
- [x] `SDL_WriteSurfacePixelFloat`

### Events (P0)
- [x] `SDL_WaitEvent`
- [x] `SDL_WaitEventTimeout`
- [ ] `SDL_PushEvent`
- [x] `SDL_PumpEvents`
- [ ] `SDL_PeepEvents`
- [ ] `SDL_HasEvent`
- [ ] `SDL_HasEvents`
- [ ] `SDL_FlushEvent`
- [ ] `SDL_FlushEvents`
- [ ] `SDL_RegisterEvents`
- [ ] `SDL_SetEventFilter`
- [ ] `SDL_GetEventFilter`
- [ ] `SDL_AddEventWatch`
- [ ] `SDL_RemoveEventWatch`
- [ ] `SDL_FilterEvents`
- [ ] `SDL_SetEventEnabled`
- [ ] `SDL_EventEnabled`
- [ ] `SDL_GetWindowFromEvent`

### Keyboard (P1)
- [ ] `SDL_HasKeyboard`
- [ ] `SDL_GetKeyboards`
- [ ] `SDL_GetKeyboardNameForID`
- [ ] `SDL_GetKeyboardFocus`
- [x] `SDL_GetKeyboardState`
- [x] `SDL_ResetKeyboard`
- [x] `SDL_GetModState`
- [ ] `SDL_SetModState`
- [x] `SDL_GetKeyFromScancode`
- [x] `SDL_GetScancodeFromKey`
- [ ] `SDL_SetScancodeName`
- [x] `SDL_GetScancodeName`
- [x] `SDL_GetScancodeFromName`
- [x] `SDL_GetKeyFromName`
- [ ] `SDL_StartTextInputWithProperties`
- [ ] `SDL_TextInputActive`
- [ ] `SDL_ClearComposition`
- [ ] `SDL_SetTextInputArea`
- [ ] `SDL_GetTextInputArea`
- [ ] `SDL_HasScreenKeyboardSupport`
- [ ] `SDL_ScreenKeyboardShown`

### Mouse (P0)
- [ ] `SDL_HasMouse`
- [ ] `SDL_GetMice`
- [ ] `SDL_GetMouseNameForID`
- [ ] `SDL_GetMouseFocus`
- [x] `SDL_GetMouseState`
- [x] `SDL_GetGlobalMouseState`
- [x] `SDL_GetRelativeMouseState`
- [x] `SDL_WarpMouseInWindow`
- [x] `SDL_WarpMouseGlobal`
- [x] `SDL_SetWindowRelativeMouseMode`
- [x] `SDL_GetWindowRelativeMouseMode`
- [x] `SDL_CaptureMouse`
- [ ] `SDL_CreateCursor`
- [ ] `SDL_CreateColorCursor`
- [x] `SDL_CreateSystemCursor`
- [x] `SDL_SetCursor`
- [x] `SDL_GetCursor`
- [ ] `SDL_GetDefaultCursor`
- [x] `SDL_DestroyCursor`
- [x] `SDL_ShowCursor`
- [x] `SDL_HideCursor`
- [x] `SDL_CursorVisible`

### Timer (P2)
- [x] `SDL_GetTicks`
- [x] `SDL_GetTicksNS`
- [x] `SDL_GetPerformanceCounter`
- [x] `SDL_GetPerformanceFrequency`
- [x] `SDL_DelayNS`
- [x] `SDL_DelayPrecise`
- [ ] `SDL_AddTimer`
- [ ] `SDL_AddTimerNS`
- [ ] `SDL_RemoveTimer`

### Audio (P2)
- [x] `SDL_GetNumAudioDrivers`
- [x] `SDL_GetAudioDriver`
- [x] `SDL_GetCurrentAudioDriver`
- [x] `SDL_GetAudioPlaybackDevices`
- [x] `SDL_GetAudioRecordingDevices`
- [x] `SDL_GetAudioDeviceName`
- [ ] `SDL_GetAudioDeviceFormat`
- [x] `SDL_OpenAudioDevice`
- [x] `SDL_CloseAudioDevice`
- [x] `SDL_PauseAudioDevice`
- [x] `SDL_ResumeAudioDevice`
- [x] `SDL_AudioDevicePaused`
- [ ] `SDL_SetAudioDeviceGain`
- [ ] `SDL_GetAudioDeviceGain`
- [x] `SDL_CreateAudioStream`
- [x] `SDL_DestroyAudioStream`
- [x] `SDL_GetAudioStreamFormat`
- [x] `SDL_SetAudioStreamFormat`
- [x] `SDL_PutAudioStreamData`
- [x] `SDL_GetAudioStreamData`
- [x] `SDL_GetAudioStreamAvailable`
- [x] `SDL_FlushAudioStream`
- [x] `SDL_ClearAudioStream`
- [x] `SDL_BindAudioStream`
- [x] `SDL_UnbindAudioStream`
- [ ] `SDL_OpenAudioDeviceStream`
- [x] `SDL_LoadWAV`
- [ ] `SDL_LoadWAV_IO`
- [ ] `SDL_MixAudio`
- [ ] `SDL_ConvertAudioSamples`
- [ ] `SDL_GetAudioFormatName`

### Rectangle Utilities (P1)
- [x] `SDL_HasRectIntersection`
- [x] `SDL_GetRectIntersection`
- [ ] `SDL_GetRectUnion`
- [ ] `SDL_GetRectEnclosingPoints`
- [ ] `SDL_GetRectAndLineIntersection`
- [x] `SDL_HasRectIntersectionFloat`
- [x] `SDL_GetRectIntersectionFloat`
- [ ] `SDL_GetRectUnionFloat`
- [ ] `SDL_GetRectEnclosingPointsFloat`
- [ ] `SDL_GetRectAndLineIntersectionFloat`

### Clipboard (P2)
- [x] `SDL_SetClipboardText`
- [x] `SDL_GetClipboardText`
- [x] `SDL_HasClipboardText`
- [ ] `SDL_SetPrimarySelectionText`
- [ ] `SDL_GetPrimarySelectionText`
- [ ] `SDL_HasPrimarySelectionText`

### Joystick (P2)
- [x] `SDL_HasJoystick`
- [x] `SDL_GetJoysticks`
- [x] `SDL_OpenJoystick`
- [x] `SDL_CloseJoystick`
- [x] `SDL_JoystickConnected`
- [x] `SDL_GetJoystickName`
- [x] `SDL_GetJoystickNameForID`
- [x] `SDL_GetJoystickPath`
- [x] `SDL_GetJoystickID`
- [x] `SDL_GetJoystickType`
- [x] `SDL_GetJoystickTypeForID`
- [x] `SDL_GetJoystickVendor`
- [x] `SDL_GetJoystickProduct`
- [x] `SDL_GetJoystickSerial`
- [x] `SDL_GetNumJoystickAxes`
- [x] `SDL_GetNumJoystickButtons`
- [x] `SDL_GetNumJoystickHats`
- [x] `SDL_GetNumJoystickBalls`
- [x] `SDL_GetJoystickAxis`
- [x] `SDL_GetJoystickButton`
- [x] `SDL_GetJoystickHat`
- [x] `SDL_GetJoystickBall`
- [x] `SDL_GetJoystickPlayerIndex`
- [x] `SDL_SetJoystickPlayerIndex`
- [x] `SDL_RumbleJoystick`
- [x] `SDL_RumbleJoystickTriggers`
- [x] `SDL_SetJoystickLED`
- [x] `SDL_GetJoystickPowerInfo`
- [x] `SDL_GetJoystickConnectionState`
- [ ] `SDL_SendJoystickEffect`
- [ ] `SDL_SendJoystickVirtualSensorData`
- [ ] `SDL_GetJoystickGUID`
- [ ] `SDL_GetJoystickGUIDForID`

### Gamepad (P2)
- [x] `SDL_HasGamepad`
- [x] `SDL_GetGamepads`
- [x] `SDL_IsGamepad`
- [x] `SDL_OpenGamepad`
- [x] `SDL_CloseGamepad`
- [x] `SDL_GamepadConnected`
- [x] `SDL_GetGamepadName`
- [x] `SDL_GetGamepadNameForID`
- [x] `SDL_GetGamepadPath`
- [x] `SDL_GetGamepadID`
- [x] `SDL_GetGamepadType`
- [x] `SDL_GetGamepadTypeForID`
- [x] `SDL_GetRealGamepadType`
- [x] `SDL_GetGamepadVendor`
- [x] `SDL_GetGamepadProduct`
- [x] `SDL_GetGamepadSerial`
- [x] `SDL_GetGamepadPlayerIndex`
- [x] `SDL_SetGamepadPlayerIndex`
- [x] `SDL_GetGamepadAxis`
- [x] `SDL_GamepadHasAxis`
- [x] `SDL_GetGamepadButton`
- [x] `SDL_GamepadHasButton`
- [x] `SDL_GetGamepadButtonLabel`
- [x] `SDL_GetGamepadButtonLabelForType`
- [x] `SDL_RumbleGamepad`
- [x] `SDL_RumbleGamepadTriggers`
- [x] `SDL_SetGamepadLED`
- [x] `SDL_GetGamepadPowerInfo`
- [x] `SDL_GetGamepadConnectionState`
- [ ] `SDL_SendGamepadEffect`
- [ ] `SDL_GetGamepadJoystick`
- [ ] `SDL_GetGamepadMapping`
- [ ] `SDL_SetGamepadMapping`
- [ ] `SDL_AddGamepadMapping`
- [ ] `SDL_GetGamepadMappingForGUID`

### Haptic/Force Feedback (P3)
- [ ] Full haptic subsystem

### OpenGL Support (P2)
- [ ] `SDL_GL_LoadLibrary`
- [ ] `SDL_GL_GetProcAddress`
- [ ] `SDL_GL_UnloadLibrary`
- [ ] `SDL_GL_ExtensionSupported`
- [ ] `SDL_GL_SetAttribute`
- [ ] `SDL_GL_GetAttribute`
- [ ] `SDL_GL_CreateContext`
- [ ] `SDL_GL_MakeCurrent`
- [ ] `SDL_GL_GetCurrentContext`
- [ ] `SDL_GL_GetCurrentWindow`
- [ ] `SDL_GL_SetSwapInterval`
- [ ] `SDL_GL_GetSwapInterval`
- [ ] `SDL_GL_SwapWindow`
- [ ] `SDL_GL_DestroyContext`

### Vulkan Support (P3)
- [ ] `SDL_Vulkan_LoadLibrary`
- [ ] `SDL_Vulkan_GetVkGetInstanceProcAddr`
- [ ] `SDL_Vulkan_UnloadLibrary`
- [ ] `SDL_Vulkan_GetInstanceExtensions`
- [ ] `SDL_Vulkan_CreateSurface`
- [ ] `SDL_Vulkan_GetPresentationSupport`

### File Dialog (P2)
- [x] `SDL_ShowOpenFileDialog`
- [x] `SDL_ShowSaveFileDialog`
- [x] `SDL_ShowOpenFolderDialog`

### Message Box (P1)
- [x] `SDL_ShowSimpleMessageBox`
- [x] `SDL_ShowMessageBox`

### Hints (P2)
- [x] `SDL_SetHint`
- [x] `SDL_SetHintWithPriority`
- [x] `SDL_GetHint`
- [x] `SDL_GetHintBoolean`
- [x] `SDL_ResetHint`
- [x] `SDL_ResetHints`

### Miscellaneous (P2)
- [ ] `SDL_OpenURL`
- [ ] `SDL_GetPlatform`
- [ ] `SDL_GetVersion`
- [ ] `SDL_GetRevision`

---

## SDL3_image

### Loading - File (P0)
- [x] `IMG_Load` (load to surface from file)

### Loading - IOStream (P1)
- [ ] `IMG_Load_IO`
- [ ] `IMG_LoadTyped_IO`
- [ ] `IMG_LoadTexture_IO`
- [ ] `IMG_LoadTextureTyped_IO`

### Format-specific Loaders (P3)
- [ ] `IMG_LoadAVIF_IO`
- [ ] `IMG_LoadBMP_IO`
- [ ] `IMG_LoadCUR_IO`
- [ ] `IMG_LoadGIF_IO`
- [ ] `IMG_LoadICO_IO`
- [ ] `IMG_LoadJPG_IO`
- [ ] `IMG_LoadJXL_IO`
- [ ] `IMG_LoadLBM_IO`
- [ ] `IMG_LoadPCX_IO`
- [ ] `IMG_LoadPNG_IO`
- [ ] `IMG_LoadPNM_IO`
- [ ] `IMG_LoadQOI_IO`
- [ ] `IMG_LoadSVG_IO`
- [ ] `IMG_LoadTGA_IO`
- [ ] `IMG_LoadTIF_IO`
- [ ] `IMG_LoadWEBP_IO`
- [ ] `IMG_LoadXCF_IO`
- [ ] `IMG_LoadXPM_IO`
- [ ] `IMG_LoadXV_IO`

### Format Detection (P3)
- [ ] `IMG_isAVIF`
- [ ] `IMG_isBMP`
- [ ] `IMG_isCUR`
- [ ] `IMG_isGIF`
- [ ] `IMG_isICO`
- [ ] `IMG_isJPG`
- [ ] `IMG_isJXL`
- [ ] `IMG_isLBM`
- [ ] `IMG_isPCX`
- [ ] `IMG_isPNG`
- [ ] `IMG_isPNM`
- [ ] `IMG_isQOI`
- [ ] `IMG_isSVG`
- [ ] `IMG_isTIF`
- [ ] `IMG_isWEBP`
- [ ] `IMG_isXCF`
- [ ] `IMG_isXPM`
- [ ] `IMG_isXV`

### Saving (P1)
- [x] `IMG_SavePNG`
- [ ] `IMG_SavePNG_IO`
- [x] `IMG_SaveJPG`
- [ ] `IMG_SaveJPG_IO`
- [ ] `IMG_SaveAVIF`
- [ ] `IMG_SaveAVIF_IO`

### Animation (P2)
- [ ] `IMG_LoadAnimation`
- [ ] `IMG_LoadAnimation_IO`
- [ ] `IMG_LoadAnimationTyped_IO`
- [ ] `IMG_FreeAnimation`
- [ ] `IMG_LoadGIFAnimation_IO`
- [ ] `IMG_LoadWEBPAnimation_IO`

### SVG Special (P2)
- [ ] `IMG_LoadSizedSVG_IO`

### XPM Special (P3)
- [ ] `IMG_ReadXPMFromArray`
- [ ] `IMG_ReadXPMFromArrayToRGB888`

---

## SDL3_ttf

### Version/Info (P2)
- [ ] `TTF_Version`
- [ ] `TTF_GetFreeTypeVersion`
- [ ] `TTF_GetHarfBuzzVersion`

### Font Loading (P1)
- [ ] `TTF_OpenFontIO`
- [ ] `TTF_OpenFontWithProperties`
- [ ] `TTF_CopyFont`

### Font Properties (P1)
- [ ] `TTF_GetFontProperties`
- [ ] `TTF_GetFontGeneration`
- [ ] `TTF_SetFontSize`
- [ ] `TTF_SetFontSizeDPI`
- [ ] `TTF_GetFontDPI`
- [ ] `TTF_SetFontStyle`
- [ ] `TTF_GetFontStyle`
- [ ] `TTF_SetFontOutline`
- [ ] `TTF_GetFontOutline`
- [ ] `TTF_SetFontHinting`
- [ ] `TTF_GetFontHinting`
- [ ] `TTF_GetNumFontFaces`
- [ ] `TTF_SetFontSDF`
- [ ] `TTF_GetFontSDF`
- [ ] `TTF_GetFontWeight`
- [ ] `TTF_SetFontLineSkip`
- [ ] `TTF_GetFontLineSkip`
- [ ] `TTF_SetFontKerning`
- [ ] `TTF_GetFontKerning`
- [ ] `TTF_FontIsFixedWidth`
- [ ] `TTF_FontIsScalable`
- [ ] `TTF_GetFontFamilyName`
- [ ] `TTF_GetFontStyleName`

### Text Direction/Script (P2)
- [ ] `TTF_SetFontDirection`
- [ ] `TTF_GetFontDirection`
- [ ] `TTF_SetFontScript`
- [ ] `TTF_GetFontScript`
- [ ] `TTF_GetGlyphScript`
- [ ] `TTF_SetFontLanguage`
- [ ] `TTF_StringToTag`
- [ ] `TTF_TagToString`

### Fallback Fonts (P2)
- [ ] `TTF_AddFallbackFont`
- [ ] `TTF_RemoveFallbackFont`
- [ ] `TTF_ClearFallbackFonts`

### Glyph Operations (P1)
- [ ] `TTF_FontHasGlyph`
- [ ] `TTF_GetGlyphImage`
- [ ] `TTF_GetGlyphImageForIndex`
- [ ] `TTF_GetGlyphMetrics`
- [ ] `TTF_GetGlyphKerning`

### Text Measurement (P1)
- [ ] `TTF_GetStringSizeWrapped`
- [ ] `TTF_MeasureString`

### Additional Rendering (P1)
- [ ] `TTF_RenderText_Solid_Wrapped`
- [ ] `TTF_RenderText_Shaded_Wrapped`
- [ ] `TTF_RenderGlyph_Shaded`

### LCD Rendering (P2)
- [ ] `TTF_RenderText_LCD`
- [ ] `TTF_RenderText_LCD_Wrapped`
- [ ] `TTF_RenderGlyph_LCD`

### Font Wrap Alignment (P2)
- [ ] `TTF_SetFontWrapAlignment`
- [ ] `TTF_GetFontWrapAlignment`

### Text Engine API (P3)
- [ ] `TTF_CreateSurfaceTextEngine`
- [ ] `TTF_DrawSurfaceText`
- [ ] `TTF_DestroySurfaceTextEngine`
- [ ] `TTF_CreateRendererTextEngine`
- [ ] `TTF_CreateRendererTextEngineWithProperties`
- [ ] `TTF_DrawRendererText`
- [ ] `TTF_DestroyRendererTextEngine`
- [ ] `TTF_CreateGPUTextEngine`
- [ ] `TTF_CreateGPUTextEngineWithProperties`
- [ ] `TTF_GetGPUTextDrawData`
- [ ] `TTF_DestroyGPUTextEngine`
- [ ] `TTF_SetGPUTextEngineWinding`
- [ ] `TTF_GetGPUTextEngineWinding`
- [ ] `TTF_CreateText`
- [ ] `TTF_GetTextProperties`
- [ ] `TTF_SetTextEngine`
- [ ] `TTF_GetTextEngine`
- [ ] `TTF_SetTextFont`
- [ ] `TTF_GetTextFont`
- [ ] `TTF_SetTextDirection`
- [ ] `TTF_GetTextDirection`
- [ ] `TTF_SetTextScript`
- [ ] `TTF_GetTextScript`
- [ ] `TTF_SetTextColor`
- [ ] `TTF_SetTextColorFloat`
- [ ] `TTF_GetTextColor`
- [ ] `TTF_GetTextColorFloat`
- [ ] `TTF_SetTextPosition`
- [ ] `TTF_GetTextPosition`
- [ ] `TTF_SetTextWrapWidth`
- [ ] `TTF_GetTextWrapWidth`
- [ ] `TTF_SetTextWrapWhitespaceVisible`
- [ ] `TTF_TextWrapWhitespaceVisible`
- [ ] `TTF_SetTextString`
- [ ] `TTF_InsertTextString`
- [ ] `TTF_AppendTextString`
- [ ] `TTF_DeleteTextString`
- [ ] `TTF_GetTextSize`
- [ ] `TTF_GetTextSubString`
- [ ] `TTF_GetTextSubStringForLine`
- [ ] `TTF_GetTextSubStringsForRange`
- [ ] `TTF_GetTextSubStringForPoint`
- [ ] `TTF_GetPreviousTextSubString`
- [ ] `TTF_GetNextTextSubString`
- [ ] `TTF_UpdateText`
- [ ] `TTF_DestroyText`

---

## Types & Constants Still Needed

### Init Flags (P0)
- [x] `SDL_INIT_AUDIO`
- [x] `SDL_INIT_JOYSTICK`
- [ ] `SDL_INIT_HAPTIC`
- [x] `SDL_INIT_GAMEPAD`
- [x] `SDL_INIT_EVENTS`
- [ ] `SDL_INIT_SENSOR`
- [ ] `SDL_INIT_CAMERA`

### Window Flags (P1)
- [x] `SDL_WINDOW_FULLSCREEN`
- [ ] `SDL_WINDOW_OPENGL`
- [ ] `SDL_WINDOW_OCCLUDED`
- [ ] `SDL_WINDOW_HIDDEN`
- [ ] `SDL_WINDOW_BORDERLESS`
- [ ] `SDL_WINDOW_MINIMIZED`
- [ ] `SDL_WINDOW_MAXIMIZED`
- [ ] `SDL_WINDOW_MOUSE_GRABBED`
- [ ] `SDL_WINDOW_INPUT_FOCUS`
- [ ] `SDL_WINDOW_MOUSE_FOCUS`
- [ ] `SDL_WINDOW_EXTERNAL`
- [ ] `SDL_WINDOW_MODAL`
- [ ] `SDL_WINDOW_MOUSE_CAPTURE`
- [ ] `SDL_WINDOW_MOUSE_RELATIVE_MODE`
- [ ] `SDL_WINDOW_ALWAYS_ON_TOP`
- [ ] `SDL_WINDOW_UTILITY`
- [ ] `SDL_WINDOW_TOOLTIP`
- [ ] `SDL_WINDOW_POPUP_MENU`
- [ ] `SDL_WINDOW_KEYBOARD_GRABBED`
- [ ] `SDL_WINDOW_VULKAN`
- [ ] `SDL_WINDOW_METAL`
- [ ] `SDL_WINDOW_TRANSPARENT`
- [ ] `SDL_WINDOW_NOT_FOCUSABLE`

### Event Types (P1)
- [x] `SDL_EVENT_MOUSE_WHEEL`
- [x] `SDL_EVENT_JOYSTICK_AXIS_MOTION`
- [x] `SDL_EVENT_JOYSTICK_BUTTON_DOWN`
- [x] `SDL_EVENT_JOYSTICK_BUTTON_UP`
- [x] `SDL_EVENT_JOYSTICK_HAT_MOTION`
- [x] `SDL_EVENT_JOYSTICK_ADDED`
- [x] `SDL_EVENT_JOYSTICK_REMOVED`
- [x] `SDL_EVENT_GAMEPAD_AXIS_MOTION`
- [x] `SDL_EVENT_GAMEPAD_BUTTON_DOWN`
- [x] `SDL_EVENT_GAMEPAD_BUTTON_UP`
- [x] `SDL_EVENT_GAMEPAD_ADDED`
- [x] `SDL_EVENT_GAMEPAD_REMOVED`
- [x] `SDL_EVENT_GAMEPAD_REMAPPED`
- [ ] `SDL_EVENT_DROP_FILE`
- [ ] `SDL_EVENT_DROP_TEXT`
- [ ] `SDL_EVENT_DROP_BEGIN`
- [ ] `SDL_EVENT_DROP_COMPLETE`
- [ ] `SDL_EVENT_AUDIO_DEVICE_ADDED`
- [ ] `SDL_EVENT_AUDIO_DEVICE_REMOVED`
- [ ] `SDL_EVENT_CLIPBOARD_UPDATE`
- [ ] ... (many more)

### Event Structs (P1)
- [x] `SDL_MouseWheelEvent`
- [x] `SDL_JoyAxisEvent`
- [x] `SDL_JoyButtonEvent`
- [x] `SDL_JoyHatEvent`
- [x] `SDL_JoyDeviceEvent`
- [x] `SDL_GamepadAxisEvent`
- [x] `SDL_GamepadButtonEvent`
- [x] `SDL_GamepadDeviceEvent`
- [ ] `SDL_DropEvent`
- [ ] `SDL_ClipboardEvent`
- [ ] `SDL_WindowEvent` (full struct with all fields)
- [ ] `SDL_TouchFingerEvent`
- [ ] `SDL_PenMotionEvent`
- [ ] `SDL_PenButtonEvent`

### Key Constants (P1)
- [x] Full scancode enum (`SDL_SCANCODE_*`) - ~80 constants (letters, numbers, F-keys, navigation, keypad, modifiers, media)
- [x] Core keycode constants (`SDLK_*`) - letters, numbers, F-keys, arrows, modifiers, etc.
- [x] Modifier key constants (`SDL_KMOD_NONE`, `SDL_KMOD_LSHIFT`, `SDL_KMOD_RSHIFT`, `SDL_KMOD_CTRL`, `SDL_KMOD_ALT`, `SDL_KMOD_GUI`, etc.)

### Rect Structs (P0)
- [x] `SDL_Rect` (integer version)
- [x] `SDL_Point`
- [x] `SDL_FPoint`

### Blend Mode (P1)
- [x] `SDL_BlendMode` type
- [x] `SDL_BLENDMODE_NONE`
- [x] `SDL_BLENDMODE_BLEND`
- [x] `SDL_BLENDMODE_BLEND_PREMULTIPLIED`
- [x] `SDL_BLENDMODE_ADD`
- [x] `SDL_BLENDMODE_ADD_PREMULTIPLIED`
- [x] `SDL_BLENDMODE_MOD`
- [x] `SDL_BLENDMODE_MUL`

### Texture Access (P1)
- [x] `SDL_TextureAccess` enum
- [x] `SDL_TEXTUREACCESS_STATIC`
- [x] `SDL_TEXTUREACCESS_STREAMING`
- [x] `SDL_TEXTUREACCESS_TARGET`

### Pixel Formats (P2)
- [ ] `SDL_PixelFormat` enum with common formats
- [x] `SDL_PIXELFORMAT_UNKNOWN`
- [x] `SDL_PIXELFORMAT_RGBA8888`
- [x] `SDL_PIXELFORMAT_ARGB8888`
- [x] `SDL_PIXELFORMAT_ABGR8888`
- [x] `SDL_PIXELFORMAT_BGRA8888`
- [ ] `SDL_PIXELFORMAT_RGB24`
- [ ] `SDL_PIXELFORMAT_BGR24`
- [ ] ... (many more)

### Scale Mode (P1)
- [x] `SDL_ScaleMode` enum
- [x] `SDL_SCALEMODE_NEAREST`
- [x] `SDL_SCALEMODE_LINEAR`

### Flip Mode (P2)
- [x] `SDL_FlipMode` enum
- [x] `SDL_FLIP_NONE`
- [x] `SDL_FLIP_HORIZONTAL`
- [x] `SDL_FLIP_VERTICAL`

### System Cursor (P2)
- [x] `SDL_SystemCursor` enum
- [x] `SDL_SYSTEM_CURSOR_DEFAULT`
- [x] `SDL_SYSTEM_CURSOR_TEXT`
- [x] `SDL_SYSTEM_CURSOR_WAIT`
- [x] `SDL_SYSTEM_CURSOR_CROSSHAIR`
- [x] `SDL_SYSTEM_CURSOR_POINTER`
- [x] All 15 system cursor types implemented

### Mouse Button Constants (P1)
- [x] `SDL_BUTTON_LEFT`
- [x] `SDL_BUTTON_MIDDLE`
- [x] `SDL_BUTTON_RIGHT`
- [x] `SDL_BUTTON_X1`
- [x] `SDL_BUTTON_X2`

### TTF Constants (P1)
- [ ] `TTF_FontStyleFlags` (`TTF_STYLE_NORMAL`, `TTF_STYLE_BOLD`, `TTF_STYLE_ITALIC`, etc.)
- [ ] `TTF_HintingFlags` (`TTF_HINTING_NORMAL`, `TTF_HINTING_LIGHT`, etc.)
- [ ] `TTF_HorizontalAlignment` (`TTF_HORIZONTAL_ALIGN_LEFT`, etc.)
- [ ] `TTF_Direction` (`TTF_DIRECTION_LTR`, `TTF_DIRECTION_RTL`, etc.)

---

## Implementation Statistics

**Currently Implemented:** ~250 functions
**Estimated Total Available:** 500+ functions

### Coverage by Library
| Library | Implemented | Estimated Total | Coverage |
|---------|-------------|-----------------|----------|
| SDL3 Core | ~230 | ~350 | ~66% |
| SDL3_image | 5 | ~60 | ~8% |
| SDL3_ttf | 16 | ~120 | ~13% |

### P0 Features Status
All P0 (essential) features are now complete:
- Window management (create, show/hide, minimize/maximize, opacity, size constraints)
- Renderer queries (driver info, output size, VSync)
- Viewport and clipping (viewport, clip rect, render scale)
- Advanced texture rendering (affine, tiled, 9-grid)
- Geometry rendering (arbitrary triangles with per-vertex colors)
- Debug text rendering (built-in 8x8 bitmap font)
- Keyboard state polling and scancodes
- Mouse warping, global state, and capture
- Display/monitor management (multi-monitor support)
- Message boxes (info, warning, error, custom dialogs)
- File dialogs (open, save, folder selection)

---

## Next Steps (Suggested Order)

1. ~~**P0 - Integer Rect:** `SDL_Rect`, `SDL_Point` types~~ ✓ DONE
2. ~~**P1 - Image Loading:** `IMG_Load` (surface), `IMG_SavePNG`~~ ✓ DONE
3. ~~**P1 - Texture Creation:** `SDL_CreateTexture`, `SDL_SetTextureScaleMode`~~ ✓ DONE
4. ~~**P1 - Scancodes:** Add full scancode enum (`SDL_SCANCODE_*`)~~ ✓ DONE
5. ~~**P1 - Mouse:** `SDL_GetRelativeMouseState`, cursor functions~~ ✓ DONE
6. ~~**P2 - Timer:** `SDL_GetPerformanceCounter`, `SDL_GetPerformanceFrequency`~~ ✓ DONE
7. ~~**P2 - Clipboard:** `SDL_SetClipboardText`, `SDL_GetClipboardText`~~ ✓ DONE
8. ~~**P2 - Audio:** Basic audio playback~~ ✓ DONE
9. ~~**P1 - Message Box:** `SDL_ShowSimpleMessageBox`~~ ✓ DONE
10. ~~**P1 - Display Management:** Multi-monitor support~~ ✓ DONE
11. ~~**P2 - File Dialogs:** Open/save file dialogs~~ ✓ DONE
12. **P1 - Surface Operations:** Create, manipulate, and blit surfaces
13. ~~**P2 - Joystick/Gamepad:** Basic input support~~ ✓ DONE
14. **P2 - OpenGL Support:** GL context creation and management
