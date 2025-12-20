# SDL3 Racket Bindings - Implementation Checklist

This document tracks the implementation status of SDL3, SDL3_image, and SDL3_ttf bindings.

## Currently Implemented

### Idiomatic Wrapper (`safe.rkt` and `safe/`)
A complete idiomatic Racket layer on top of the raw bindings, providing:
- Custodian-managed resources (automatic cleanup)
- Racket structs for events (with `match` support)
- Simpler APIs (fewer pointer manipulations)
- Drawing helpers, texture management, font/text rendering, mouse state

Modules: `safe/window.rkt`, `safe/events.rkt`, `safe/draw.rkt`, `safe/texture.rkt`, `safe/ttf.rkt`, `safe/mouse.rkt`, `safe/keyboard.rkt`, `safe/clipboard.rkt`, `safe/timer.rkt`, `safe/audio.rkt`, `safe/display.rkt`, `safe/dialog.rkt`, `safe/hints.rkt`, `safe/joystick.rkt`, `safe/gamepad.rkt`, `safe/image.rkt`, `safe/collision.rkt`

### SDL3 Core (`raw/`)

#### Initialization (`raw/init.rkt`)
- [x] `SDL_Init`, `SDL_Quit`, `SDL_GetError`, `SDL_free`

#### Window Management (`raw/window.rkt`)
- [x] `SDL_CreateWindow`, `SDL_CreateWindowAndRenderer`, `SDL_DestroyWindow`
- [x] `SDL_GetWindowTitle`, `SDL_SetWindowTitle`, `SDL_SetWindowIcon`
- [x] `SDL_GetWindowSize`, `SDL_SetWindowSize`, `SDL_GetWindowPosition`, `SDL_SetWindowPosition`
- [x] `SDL_GetWindowFlags`, `SDL_SetWindowFullscreen`, `SDL_GetWindowPixelDensity`
- [x] `SDL_GetWindowID`, `SDL_GetWindowFromID`
- [x] `SDL_ShowWindow`, `SDL_HideWindow`, `SDL_RaiseWindow`
- [x] `SDL_MaximizeWindow`, `SDL_MinimizeWindow`, `SDL_RestoreWindow`
- [x] `SDL_SetWindowMinimumSize`, `SDL_GetWindowMinimumSize`
- [x] `SDL_SetWindowMaximumSize`, `SDL_GetWindowMaximumSize`
- [x] `SDL_SetWindowBordered`, `SDL_SetWindowResizable`
- [x] `SDL_SetWindowOpacity`, `SDL_GetWindowOpacity`
- [x] `SDL_FlashWindow`
- [x] `SDL_GetWindowSurface`, `SDL_UpdateWindowSurface`

#### Renderer (`raw/render.rkt`)
- [x] `SDL_CreateRenderer`, `SDL_DestroyRenderer`
- [x] `SDL_GetNumRenderDrivers`, `SDL_GetRenderDriver`
- [x] `SDL_GetRenderer`, `SDL_GetRenderWindow`, `SDL_GetRendererName`
- [x] `SDL_GetRenderOutputSize`, `SDL_GetCurrentRenderOutputSize`
- [x] `SDL_SetRenderDrawColor`, `SDL_GetRenderDrawColor`
- [x] `SDL_SetRenderDrawColorFloat`, `SDL_GetRenderDrawColorFloat`
- [x] `SDL_RenderClear`, `SDL_RenderPresent`
- [x] `SDL_SetRenderDrawBlendMode`, `SDL_GetRenderDrawBlendMode`
- [x] `SDL_SetRenderVSync`, `SDL_GetRenderVSync`
- [x] `SDL_SetRenderViewport`, `SDL_GetRenderViewport`
- [x] `SDL_SetRenderClipRect`, `SDL_GetRenderClipRect`, `SDL_RenderClipEnabled`
- [x] `SDL_SetRenderScale`, `SDL_GetRenderScale`
- [x] `SDL_RenderPoint`, `SDL_RenderPoints`
- [x] `SDL_RenderLine`, `SDL_RenderLines`
- [x] `SDL_RenderRect`, `SDL_RenderRects`
- [x] `SDL_RenderFillRect`, `SDL_RenderFillRects`
- [x] `SDL_RenderGeometry`
- [x] `SDL_RenderDebugText`
- [x] `SDL_RenderReadPixels`
- [x] `SDL_HasRectIntersection`, `SDL_GetRectIntersection`
- [x] `SDL_HasRectIntersectionFloat`, `SDL_GetRectIntersectionFloat`

#### Texture (`raw/texture.rkt`)
- [x] `SDL_CreateTexture`, `SDL_CreateTextureFromSurface`, `SDL_DestroyTexture`
- [x] `SDL_GetTextureSize`
- [x] `SDL_RenderTexture`, `SDL_RenderTextureRotated`
- [x] `SDL_RenderTextureAffine`, `SDL_RenderTextureTiled`, `SDL_RenderTexture9Grid`
- [x] `SDL_SetRenderTarget`, `SDL_GetRenderTarget`
- [x] `SDL_SetTextureScaleMode`, `SDL_GetTextureScaleMode`
- [x] `SDL_SetTextureBlendMode`, `SDL_GetTextureBlendMode`
- [x] `SDL_SetTextureColorMod`, `SDL_GetTextureColorMod`
- [x] `SDL_SetTextureAlphaMod`, `SDL_GetTextureAlphaMod`

#### Surface (`raw/surface.rkt`)
- [x] `SDL_CreateSurface`, `SDL_CreateSurfaceFrom`, `SDL_DestroySurface`
- [x] `SDL_DuplicateSurface`, `SDL_ConvertSurface`
- [x] `SDL_LockSurface`, `SDL_UnlockSurface`
- [x] `SDL_SetSurfaceRLE`, `SDL_SurfaceHasRLE`
- [x] `SDL_ReadSurfacePixel`, `SDL_WriteSurfacePixel`
- [x] `SDL_ReadSurfacePixelFloat`, `SDL_WriteSurfacePixelFloat`
- [x] `SDL_MapSurfaceRGB`, `SDL_MapSurfaceRGBA`
- [x] `SDL_BlitSurface`, `SDL_BlitSurfaceScaled`
- [x] `SDL_FillSurfaceRect`, `SDL_FillSurfaceRects`, `SDL_ClearSurface`
- [x] `SDL_FlipSurface`, `SDL_ScaleSurface`
- [x] `SDL_LoadBMP`, `SDL_SaveBMP`
- [x] `SDL_SetSurfaceColorKey`, `SDL_GetSurfaceColorKey`, `SDL_SurfaceHasColorKey`
- [x] `SDL_SetSurfaceColorMod`, `SDL_GetSurfaceColorMod`
- [x] `SDL_SetSurfaceAlphaMod`, `SDL_GetSurfaceAlphaMod`
- [x] `SDL_SetSurfaceBlendMode`, `SDL_GetSurfaceBlendMode`
- [x] `SDL_SetSurfaceClipRect`, `SDL_GetSurfaceClipRect`

#### Events (`raw/events.rkt`)
- [x] `SDL_PollEvent`, `SDL_WaitEvent`, `SDL_WaitEventTimeout`, `SDL_PumpEvents`

#### Keyboard (`raw/keyboard.rkt`)
- [x] `SDL_GetKeyboardState`, `SDL_GetModState`, `SDL_ResetKeyboard`
- [x] `SDL_GetKeyFromScancode`, `SDL_GetScancodeFromKey`
- [x] `SDL_GetScancodeName`, `SDL_GetScancodeFromName`
- [x] `SDL_GetKeyName`, `SDL_GetKeyFromName`
- [x] `SDL_StartTextInput`, `SDL_StopTextInput`

#### Mouse (`raw/mouse.rkt`)
- [x] `SDL_GetMouseState`, `SDL_GetRelativeMouseState`, `SDL_GetGlobalMouseState`
- [x] `SDL_SetWindowRelativeMouseMode`, `SDL_GetWindowRelativeMouseMode`
- [x] `SDL_WarpMouseInWindow`, `SDL_WarpMouseGlobal`
- [x] `SDL_CaptureMouse`
- [x] `SDL_CreateSystemCursor`, `SDL_SetCursor`, `SDL_GetCursor`, `SDL_DestroyCursor`
- [x] `SDL_ShowCursor`, `SDL_HideCursor`, `SDL_CursorVisible`

#### Timer (`raw/timer.rkt`)
- [x] `SDL_GetTicks`, `SDL_GetTicksNS`
- [x] `SDL_GetPerformanceCounter`, `SDL_GetPerformanceFrequency`
- [x] `SDL_Delay`, `SDL_DelayNS`, `SDL_DelayPrecise`

#### Clipboard (`raw/clipboard.rkt`)
- [x] `SDL_SetClipboardText`, `SDL_GetClipboardText`, `SDL_HasClipboardText`

#### Display (`raw/display.rkt`)
- [x] `SDL_GetDisplays`, `SDL_GetPrimaryDisplay`, `SDL_GetDisplayName`
- [x] `SDL_GetDisplayBounds`, `SDL_GetDisplayUsableBounds`
- [x] `SDL_GetCurrentDisplayMode`, `SDL_GetDesktopDisplayMode`
- [x] `SDL_GetFullscreenDisplayModes`
- [x] `SDL_GetDisplayForWindow`
- [x] `SDL_GetDisplayContentScale`, `SDL_GetWindowDisplayScale`

#### Dialog (`raw/dialog.rkt`)
- [x] `SDL_ShowSimpleMessageBox`, `SDL_ShowMessageBox`
- [x] `SDL_ShowOpenFileDialog`, `SDL_ShowSaveFileDialog`, `SDL_ShowOpenFolderDialog`

#### Hints (`raw/hints.rkt`)
- [x] `SDL_SetHint`, `SDL_SetHintWithPriority`
- [x] `SDL_GetHint`, `SDL_GetHintBoolean`
- [x] `SDL_ResetHint`, `SDL_ResetHints`

#### Audio (`raw/audio.rkt`)
- [x] `SDL_GetNumAudioDrivers`, `SDL_GetAudioDriver`, `SDL_GetCurrentAudioDriver`
- [x] `SDL_GetAudioPlaybackDevices`, `SDL_GetAudioRecordingDevices`
- [x] `SDL_GetAudioDeviceName`
- [x] `SDL_OpenAudioDevice`, `SDL_CloseAudioDevice`
- [x] `SDL_PauseAudioDevice`, `SDL_ResumeAudioDevice`, `SDL_AudioDevicePaused`
- [x] `SDL_CreateAudioStream`, `SDL_DestroyAudioStream`
- [x] `SDL_GetAudioStreamFormat`, `SDL_SetAudioStreamFormat`
- [x] `SDL_PutAudioStreamData`, `SDL_GetAudioStreamData`, `SDL_GetAudioStreamAvailable`
- [x] `SDL_FlushAudioStream`, `SDL_ClearAudioStream`
- [x] `SDL_BindAudioStream`, `SDL_UnbindAudioStream`
- [x] `SDL_LoadWAV`

#### Joystick (`raw/joystick.rkt`)
- [x] `SDL_HasJoystick`, `SDL_GetJoysticks`
- [x] `SDL_OpenJoystick`, `SDL_CloseJoystick`, `SDL_JoystickConnected`
- [x] `SDL_GetJoystickFromID`
- [x] `SDL_GetJoystickName`, `SDL_GetJoystickNameForID`
- [x] `SDL_GetJoystickPath`, `SDL_GetJoystickPathForID`
- [x] `SDL_GetJoystickID`, `SDL_GetJoystickType`, `SDL_GetJoystickTypeForID`
- [x] `SDL_GetJoystickGUID`, `SDL_GetJoystickGUIDForID`
- [x] `SDL_GetJoystickVendor`, `SDL_GetJoystickVendorForID`
- [x] `SDL_GetJoystickProduct`, `SDL_GetJoystickProductForID`
- [x] `SDL_GetJoystickProductVersion`, `SDL_GetJoystickProductVersionForID`
- [x] `SDL_GetJoystickSerial`
- [x] `SDL_GetNumJoystickAxes`, `SDL_GetNumJoystickBalls`, `SDL_GetNumJoystickButtons`, `SDL_GetNumJoystickHats`
- [x] `SDL_GetJoystickAxis`, `SDL_GetJoystickAxisInitialState`
- [x] `SDL_GetJoystickBall`, `SDL_GetJoystickButton`, `SDL_GetJoystickHat`
- [x] `SDL_GetJoystickPlayerIndex`, `SDL_SetJoystickPlayerIndex`, `SDL_GetJoystickPlayerIndexForID`
- [x] `SDL_RumbleJoystick`, `SDL_RumbleJoystickTriggers`
- [x] `SDL_SetJoystickLED`
- [x] `SDL_GetJoystickPowerInfo`, `SDL_GetJoystickConnectionState`
- [x] `SDL_SetJoystickEventsEnabled`, `SDL_JoystickEventsEnabled`
- [x] `SDL_UpdateJoysticks`
- [x] `SDL_LockJoysticks`, `SDL_UnlockJoysticks`

#### Gamepad (`raw/gamepad.rkt`)
- [x] `SDL_HasGamepad`, `SDL_GetGamepads`, `SDL_IsGamepad`
- [x] `SDL_OpenGamepad`, `SDL_CloseGamepad`, `SDL_GamepadConnected`
- [x] `SDL_GetGamepadFromID`, `SDL_GetGamepadFromPlayerIndex`
- [x] `SDL_GetGamepadName`, `SDL_GetGamepadNameForID`
- [x] `SDL_GetGamepadPath`, `SDL_GetGamepadPathForID`
- [x] `SDL_GetGamepadID`, `SDL_GetGamepadType`, `SDL_GetGamepadTypeForID`
- [x] `SDL_GetRealGamepadType`
- [x] `SDL_GetGamepadVendor`, `SDL_GetGamepadVendorForID`
- [x] `SDL_GetGamepadProduct`, `SDL_GetGamepadProductForID`
- [x] `SDL_GetGamepadProductVersion`, `SDL_GetGamepadProductVersionForID`
- [x] `SDL_GetGamepadSerial`
- [x] `SDL_GetGamepadGUIDForID`
- [x] `SDL_GetGamepadJoystick`
- [x] `SDL_GetGamepadPlayerIndex`, `SDL_SetGamepadPlayerIndex`, `SDL_GetGamepadPlayerIndexForID`
- [x] `SDL_GetGamepadButton`, `SDL_GamepadHasButton`
- [x] `SDL_GetGamepadAxis`, `SDL_GamepadHasAxis`
- [x] `SDL_GetGamepadButtonLabel`, `SDL_GetGamepadButtonLabelForType`
- [x] `SDL_GetGamepadStringForButton`, `SDL_GetGamepadButtonFromString`
- [x] `SDL_GetGamepadStringForAxis`, `SDL_GetGamepadAxisFromString`
- [x] `SDL_GetGamepadStringForType`, `SDL_GetGamepadTypeFromString`
- [x] `SDL_RumbleGamepad`, `SDL_RumbleGamepadTriggers`
- [x] `SDL_SetGamepadLED`
- [x] `SDL_GetGamepadPowerInfo`, `SDL_GetGamepadConnectionState`
- [x] `SDL_GetNumGamepadTouchpads`, `SDL_GetNumGamepadTouchpadFingers`, `SDL_GetGamepadTouchpadFinger`
- [x] `SDL_GamepadHasSensor`, `SDL_SetGamepadSensorEnabled`, `SDL_GamepadSensorEnabled`
- [x] `SDL_GetGamepadSensorData`, `SDL_GetGamepadSensorDataRate`
- [x] `SDL_SetGamepadEventsEnabled`, `SDL_GamepadEventsEnabled`
- [x] `SDL_UpdateGamepads`
- [x] `SDL_GetGamepadMapping`, `SDL_GetGamepadMappingForID`

### SDL3_image (`raw/image.rkt`)
- [x] `IMG_Version`
- [x] `IMG_LoadTexture`, `IMG_Load`
- [x] `IMG_SavePNG`, `IMG_SaveJPG`

### SDL3_ttf (`raw/ttf.rkt`)

#### Initialization
- [x] `TTF_Init`, `TTF_Quit`, `TTF_WasInit`

#### Font Loading
- [x] `TTF_OpenFont`, `TTF_CloseFont`, `TTF_CopyFont`
- [x] `TTF_AddFallbackFont`, `TTF_RemoveFallbackFont`, `TTF_ClearFallbackFonts`

#### Font Properties
- [x] `TTF_GetFontSize`, `TTF_SetFontSize`, `TTF_SetFontSizeDPI`, `TTF_GetFontDPI`
- [x] `TTF_GetFontHeight`, `TTF_GetFontAscent`, `TTF_GetFontDescent`
- [x] `TTF_SetFontStyle`, `TTF_GetFontStyle`
- [x] `TTF_SetFontOutline`, `TTF_GetFontOutline`
- [x] `TTF_SetFontHinting`, `TTF_GetFontHinting`
- [x] `TTF_SetFontSDF`, `TTF_GetFontSDF`
- [x] `TTF_SetFontLineSkip`, `TTF_GetFontLineSkip`
- [x] `TTF_SetFontKerning`, `TTF_GetFontKerning`
- [x] `TTF_GetFontWeight`
- [x] `TTF_GetFontFamilyName`, `TTF_GetFontStyleName`
- [x] `TTF_GetNumFontFaces`
- [x] `TTF_FontIsFixedWidth`, `TTF_FontIsScalable`
- [x] `TTF_SetFontWrapAlignment`, `TTF_GetFontWrapAlignment`

#### Text Rendering
- [x] `TTF_RenderText_Solid`, `TTF_RenderText_Solid_Wrapped`
- [x] `TTF_RenderText_Shaded`, `TTF_RenderText_Shaded_Wrapped`
- [x] `TTF_RenderText_Blended`, `TTF_RenderText_Blended_Wrapped`
- [x] `TTF_RenderText_LCD`, `TTF_RenderText_LCD_Wrapped`
- [x] `TTF_RenderGlyph_Solid`, `TTF_RenderGlyph_Shaded`, `TTF_RenderGlyph_Blended`, `TTF_RenderGlyph_LCD`

#### Glyph Operations
- [x] `TTF_FontHasGlyph`
- [x] `TTF_GetGlyphImage`, `TTF_GetGlyphImageForIndex`
- [x] `TTF_GetGlyphMetrics`, `TTF_GetGlyphKerning`

#### Text Measurement
- [x] `TTF_GetStringSize`, `TTF_GetStringSizeWrapped`
- [x] `TTF_MeasureString`

#### Text Direction/Script (HarfBuzz)
- [x] `TTF_SetFontDirection`, `TTF_GetFontDirection`
- [x] `TTF_SetFontScript`, `TTF_GetFontScript`
- [x] `TTF_SetFontLanguage`
- [x] `TTF_StringToTag`, `TTF_TagToString`
- [x] `TTF_GetGlyphScript`

#### Version Info
- [x] `TTF_Version`
- [x] `TTF_GetFreeTypeVersion`, `TTF_GetHarfBuzzVersion`

#### Text Engine API
- [x] `TTF_CreateRendererTextEngine`, `TTF_DestroyRendererTextEngine`, `TTF_DrawRendererText`
- [x] `TTF_CreateSurfaceTextEngine`, `TTF_DestroySurfaceTextEngine`, `TTF_DrawSurfaceText`
- [x] `TTF_CreateText`, `TTF_DestroyText`
- [x] `TTF_SetTextString`, `TTF_AppendTextString`, `TTF_InsertTextString`, `TTF_DeleteTextString`
- [x] `TTF_GetTextSize`
- [x] `TTF_SetTextColor`, `TTF_GetTextColor`
- [x] `TTF_SetTextPosition`, `TTF_GetTextPosition`
- [x] `TTF_SetTextWrapWidth`, `TTF_GetTextWrapWidth`
- [x] `TTF_UpdateText`

### Types & Constants (`private/`)

#### Init Flags
- [x] `SDL_INIT_AUDIO`, `SDL_INIT_VIDEO`, `SDL_INIT_JOYSTICK`, `SDL_INIT_GAMEPAD`, `SDL_INIT_EVENTS`

#### Window Flags
- [x] `SDL_WINDOW_FULLSCREEN`, `SDL_WINDOW_RESIZABLE`, `SDL_WINDOW_HIGH_PIXEL_DENSITY`

#### Event Types & Structs
- [x] All core events: quit, window, keyboard, mouse (motion, button, wheel), text input
- [x] Joystick events: axis, ball, hat, button, added/removed
- [x] Gamepad events: axis, button, added/removed/remapped, touchpad, sensor

#### Input Constants
- [x] Full scancode enum (`SDL_SCANCODE_*`)
- [x] Full keycode constants (`SDLK_*`)
- [x] Modifier key constants (`SDL_KMOD_*`)
- [x] Mouse button constants (`SDL_BUTTON_*`)
- [x] System cursor types (all 20)
- [x] Joystick hat constants, type constants, connection states
- [x] Gamepad type, button, axis, and label constants

#### Graphics Constants
- [x] Blend modes (none, blend, add, mod, mul, premultiplied variants)
- [x] Flip modes (none, horizontal, vertical)
- [x] Texture access modes (static, streaming, target)
- [x] Scale modes (nearest, linear)
- [x] Common pixel formats (RGBA8888, ARGB8888, ABGR8888, BGRA8888, RGB24, RGBA32)

#### Audio Constants
- [x] Audio formats (U8, S8, S16, S32, F32, with endian variants)
- [x] Default device constants

#### TTF Constants
- [x] Font style flags (normal, bold, italic, underline, strikethrough)
- [x] Hinting modes (normal, light, mono, none, light_subpixel)
- [x] Horizontal alignment (left, center, right)
- [x] Text direction (LTR, RTL, TTB, BTT)
- [x] Glyph image types (alpha, color, SDF)
- [x] Font weight constants (thin through extra-black)

---

## Not Yet Implemented

### SDL3 Core

#### Initialization
- [x] `SDL_InitSubSystem`, `SDL_QuitSubSystem`, `SDL_WasInit`
- [x] `SDL_SetAppMetadata`, `SDL_SetAppMetadataProperty`, `SDL_GetAppMetadataProperty`

#### Texture (Advanced)
- [ ] `SDL_CreateTextureWithProperties`, `SDL_GetTextureProperties`
- [x] `SDL_SetTextureColorModFloat`, `SDL_GetTextureColorModFloat`
- [x] `SDL_SetTextureAlphaModFloat`, `SDL_GetTextureAlphaModFloat`
- [x] `SDL_UpdateTexture`, `SDL_UpdateYUVTexture`, `SDL_UpdateNVTexture`
- [x] `SDL_LockTexture`, `SDL_LockTextureToSurface`, `SDL_UnlockTexture`

#### Surface (Advanced)
- [ ] `SDL_GetSurfaceProperties`
- [ ] `SDL_LoadBMP_IO`, `SDL_SaveBMP_IO`
- [ ] `SDL_BlitSurfaceUnchecked`, `SDL_BlitSurfaceUncheckedScaled`
- [ ] `SDL_BlitSurfaceTiled`, `SDL_BlitSurface9Grid`
- [ ] `SDL_ConvertSurfaceAndColorspace`

#### Renderer (Advanced)
- [ ] `SDL_RenderGeometryRaw`
- [ ] `SDL_RenderDebugTextFormat`

#### Events (Advanced)
- [ ] `SDL_PushEvent`, `SDL_PeepEvents`
- [ ] `SDL_HasEvent`, `SDL_HasEvents`
- [ ] `SDL_FlushEvent`, `SDL_FlushEvents`
- [ ] `SDL_RegisterEvents`
- [ ] `SDL_SetEventFilter`, `SDL_GetEventFilter`
- [ ] `SDL_AddEventWatch`, `SDL_RemoveEventWatch`, `SDL_FilterEvents`
- [ ] `SDL_SetEventEnabled`, `SDL_EventEnabled`
- [ ] `SDL_GetWindowFromEvent`

#### Keyboard (Advanced)
- [ ] `SDL_HasKeyboard`, `SDL_GetKeyboards`, `SDL_GetKeyboardNameForID`
- [ ] `SDL_GetKeyboardFocus`
- [ ] `SDL_SetModState`, `SDL_SetScancodeName`
- [ ] `SDL_StartTextInputWithProperties`, `SDL_TextInputActive`
- [ ] `SDL_ClearComposition`, `SDL_SetTextInputArea`, `SDL_GetTextInputArea`
- [ ] `SDL_HasScreenKeyboardSupport`, `SDL_ScreenKeyboardShown`

#### Mouse (Advanced)
- [ ] `SDL_HasMouse`, `SDL_GetMice`, `SDL_GetMouseNameForID`, `SDL_GetMouseFocus`
- [ ] `SDL_CreateCursor`, `SDL_CreateColorCursor`, `SDL_GetDefaultCursor`

#### Rectangle Utilities
- [ ] `SDL_GetRectUnion`, `SDL_GetRectUnionFloat`
- [ ] `SDL_GetRectEnclosingPoints`, `SDL_GetRectEnclosingPointsFloat`
- [ ] `SDL_GetRectAndLineIntersection`, `SDL_GetRectAndLineIntersectionFloat`

#### Timer (Advanced)
- [x] `SDL_AddTimer`, `SDL_AddTimerNS`, `SDL_RemoveTimer`

#### Audio (Advanced)
- [ ] `SDL_GetAudioDeviceFormat`
- [ ] `SDL_SetAudioDeviceGain`, `SDL_GetAudioDeviceGain`
- [ ] `SDL_OpenAudioDeviceStream`
- [ ] `SDL_LoadWAV_IO`
- [ ] `SDL_MixAudio`, `SDL_ConvertAudioSamples`
- [ ] `SDL_GetAudioFormatName`

#### Clipboard (Advanced)
- [ ] `SDL_SetPrimarySelectionText`, `SDL_GetPrimarySelectionText`, `SDL_HasPrimarySelectionText`

#### Joystick (Advanced)
- [ ] `SDL_SendJoystickEffect`, `SDL_SendJoystickVirtualSensorData`

#### Gamepad (Advanced)
- [ ] `SDL_SendGamepadEffect`
- [ ] `SDL_AddGamepadMapping`, `SDL_SetGamepadMapping`, `SDL_GetGamepadMappingForGUID`

#### OpenGL Support
- [ ] `SDL_GL_LoadLibrary`, `SDL_GL_GetProcAddress`, `SDL_GL_UnloadLibrary`
- [ ] `SDL_GL_ExtensionSupported`
- [ ] `SDL_GL_SetAttribute`, `SDL_GL_GetAttribute`
- [ ] `SDL_GL_CreateContext`, `SDL_GL_MakeCurrent`
- [ ] `SDL_GL_GetCurrentContext`, `SDL_GL_GetCurrentWindow`
- [ ] `SDL_GL_SetSwapInterval`, `SDL_GL_GetSwapInterval`
- [ ] `SDL_GL_SwapWindow`, `SDL_GL_DestroyContext`

#### Vulkan Support
- [ ] `SDL_Vulkan_LoadLibrary`, `SDL_Vulkan_GetVkGetInstanceProcAddr`, `SDL_Vulkan_UnloadLibrary`
- [ ] `SDL_Vulkan_GetInstanceExtensions`
- [ ] `SDL_Vulkan_CreateSurface`, `SDL_Vulkan_GetPresentationSupport`

#### Haptic/Force Feedback
- [ ] Full haptic subsystem

#### Miscellaneous
- [ ] `SDL_OpenURL`
- [ ] `SDL_GetPlatform`, `SDL_GetVersion`, `SDL_GetRevision`

#### Additional Window Flags
- [ ] `SDL_WINDOW_OPENGL`, `SDL_WINDOW_VULKAN`, `SDL_WINDOW_METAL`
- [ ] `SDL_WINDOW_HIDDEN`, `SDL_WINDOW_BORDERLESS`
- [ ] `SDL_WINDOW_MINIMIZED`, `SDL_WINDOW_MAXIMIZED`
- [ ] `SDL_WINDOW_MOUSE_GRABBED`, `SDL_WINDOW_KEYBOARD_GRABBED`
- [ ] `SDL_WINDOW_INPUT_FOCUS`, `SDL_WINDOW_MOUSE_FOCUS`
- [ ] `SDL_WINDOW_ALWAYS_ON_TOP`, `SDL_WINDOW_TRANSPARENT`
- [ ] `SDL_WINDOW_UTILITY`, `SDL_WINDOW_TOOLTIP`, `SDL_WINDOW_POPUP_MENU`
- [ ] And others...

#### Additional Event Types
- [x] `SDL_EVENT_DROP_FILE`, `SDL_EVENT_DROP_TEXT`, `SDL_EVENT_DROP_BEGIN`, `SDL_EVENT_DROP_COMPLETE`, `SDL_EVENT_DROP_POSITION`
- [x] `SDL_EVENT_AUDIO_DEVICE_ADDED`, `SDL_EVENT_AUDIO_DEVICE_REMOVED`, `SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED`
- [x] `SDL_EVENT_CLIPBOARD_UPDATE`
- [ ] Touch/pen events

#### Additional Event Structs
- [x] `SDL_DropEvent`, `SDL_ClipboardEvent`
- [ ] `SDL_TouchFingerEvent`
- [ ] `SDL_PenMotionEvent`, `SDL_PenButtonEvent`

### SDL3_image

#### Loading (IOStream)
- [x] `IMG_Load_IO`, `IMG_LoadTyped_IO`
- [x] `IMG_LoadTexture_IO`, `IMG_LoadTextureTyped_IO`

#### Format-specific Loaders
- [ ] All `IMG_Load*_IO` variants (AVIF, BMP, GIF, JPG, PNG, WebP, etc.)

#### Format Detection
- [x] All `IMG_is*` functions

#### Saving (Advanced)
- [ ] `IMG_SavePNG_IO`, `IMG_SaveJPG_IO`
- [ ] `IMG_SaveAVIF`, `IMG_SaveAVIF_IO`

#### Animation
- [ ] `IMG_LoadAnimation`, `IMG_LoadAnimation_IO`, `IMG_LoadAnimationTyped_IO`
- [ ] `IMG_FreeAnimation`
- [ ] `IMG_LoadGIFAnimation_IO`, `IMG_LoadWEBPAnimation_IO`

#### SVG/XPM Special
- [ ] `IMG_LoadSizedSVG_IO`
- [ ] `IMG_ReadXPMFromArray`, `IMG_ReadXPMFromArrayToRGB888`

### SDL3_ttf

#### Font Loading (Advanced)
- [ ] `TTF_OpenFontIO`, `TTF_OpenFontWithProperties`
- [ ] `TTF_GetFontProperties`, `TTF_GetFontGeneration`

#### Text Engine API (Advanced)
- [ ] `TTF_CreateRendererTextEngineWithProperties`
- [ ] `TTF_CreateGPUTextEngine`, `TTF_CreateGPUTextEngineWithProperties`
- [ ] `TTF_GetGPUTextDrawData`, `TTF_DestroyGPUTextEngine`
- [ ] `TTF_SetGPUTextEngineWinding`, `TTF_GetGPUTextEngineWinding`
- [ ] `TTF_GetTextProperties`
- [ ] `TTF_SetTextEngine`, `TTF_GetTextEngine`
- [ ] `TTF_SetTextFont`, `TTF_GetTextFont`
- [ ] `TTF_SetTextDirection`, `TTF_GetTextDirection`
- [ ] `TTF_SetTextScript`, `TTF_GetTextScript`
- [ ] `TTF_SetTextColorFloat`, `TTF_GetTextColorFloat`
- [ ] `TTF_SetTextWrapWhitespaceVisible`, `TTF_TextWrapWhitespaceVisible`
- [ ] `TTF_GetTextSubString`, `TTF_GetTextSubStringForLine`
- [ ] `TTF_GetTextSubStringsForRange`, `TTF_GetTextSubStringForPoint`
- [ ] `TTF_GetPreviousTextSubString`, `TTF_GetNextTextSubString`

---

## Implementation Statistics

| Library | Functions Implemented | Estimated Total | Coverage |
|---------|----------------------|-----------------|----------|
| SDL3 Core | ~200 | ~350 | ~57% |
| SDL3_image | ~27 | ~60 | ~45% |
| SDL3_ttf | ~70 | ~100 | ~70% |

**Note:** All essential (P0) features for building games and applications are complete. The remaining functions are primarily advanced features, alternative APIs (IOStream variants), and specialized subsystems (OpenGL, Vulkan, haptics).

---

## Suggested Next Steps

1. **Input Enumeration + Rect Utilities** - keyboard/mouse listing and rect helpers
2. **Touch + Pen Events** - touch/pen event structs and parsing
3. **Audio Advanced** - device format/gain, stream open, mix/convert
4. **SDL_ttf Advanced** - remaining TTF IO and text engine APIs
5. **SDL_image Animation** - GIF/WebP animation loading and playback
