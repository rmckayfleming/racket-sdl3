# SDL3 Racket Bindings - Implementation Checklist

This document tracks the implementation status of SDL3, SDL3_image, and SDL3_ttf bindings.

## Currently Implemented

### SDL3 Core (`raw.rkt`)
- [x] `SDL_Init`
- [x] `SDL_Quit`
- [x] `SDL_GetError`
- [x] `SDL_CreateWindow`
- [x] `SDL_DestroyWindow`
- [x] `SDL_SetWindowTitle`
- [x] `SDL_GetWindowPixelDensity`
- [x] `SDL_CreateRenderer`
- [x] `SDL_DestroyRenderer`
- [x] `SDL_SetRenderDrawColor`
- [x] `SDL_RenderClear`
- [x] `SDL_RenderPresent`
- [x] `SDL_DestroyTexture`
- [x] `SDL_RenderTexture`
- [x] `SDL_GetTextureSize`
- [x] `SDL_CreateTextureFromSurface`
- [x] `SDL_DestroySurface`
- [x] `SDL_PollEvent`
- [x] `SDL_GetKeyName`
- [x] `SDL_StartTextInput`
- [x] `SDL_StopTextInput`
- [x] `SDL_Delay`

### SDL3_image (`image.rkt`)
- [x] `IMG_Version`
- [x] `IMG_LoadTexture`

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
- [x] `SDL_WINDOW_RESIZABLE`, `SDL_WINDOW_HIGH_PIXEL_DENSITY`
- [x] Pointer types: `_SDL_Window-pointer`, `_SDL_Renderer-pointer`, `_SDL_Texture-pointer`, `_SDL_Surface-pointer`
- [x] `_SDL_FRect` struct
- [x] `_SDL_Color` struct
- [x] Event constants: `SDL_EVENT_QUIT`, window events, keyboard events, mouse events, text input
- [x] Event structs: `_SDL_CommonEvent`, `_SDL_KeyboardEvent`, `_SDL_MouseMotionEvent`, `_SDL_MouseButtonEvent`, `_SDL_TextInputEvent`
- [x] Key constants: `SDLK_ESCAPE`, `SDLK_SPACE`, arrow keys, R/G/B keys
- [x] `_SDL_Keycode`

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
- [ ] `SDL_CreateWindowAndRenderer`
- [ ] `SDL_GetWindowTitle`
- [ ] `SDL_SetWindowIcon`
- [ ] `SDL_GetWindowSize`
- [ ] `SDL_SetWindowSize`
- [ ] `SDL_GetWindowPosition`
- [ ] `SDL_SetWindowPosition`
- [ ] `SDL_GetWindowFlags`
- [ ] `SDL_ShowWindow`
- [ ] `SDL_HideWindow`
- [ ] `SDL_RaiseWindow`
- [ ] `SDL_MaximizeWindow`
- [ ] `SDL_MinimizeWindow`
- [ ] `SDL_RestoreWindow`
- [ ] `SDL_SetWindowFullscreen`
- [ ] `SDL_SetWindowBordered`
- [ ] `SDL_SetWindowResizable`
- [ ] `SDL_GetWindowSurface`
- [ ] `SDL_UpdateWindowSurface`
- [ ] `SDL_GetWindowID`
- [ ] `SDL_GetWindowFromID`
- [ ] `SDL_SetWindowMinimumSize`
- [ ] `SDL_SetWindowMaximumSize`
- [ ] `SDL_GetWindowMinimumSize`
- [ ] `SDL_GetWindowMaximumSize`
- [ ] `SDL_SetWindowOpacity`
- [ ] `SDL_GetWindowOpacity`
- [ ] `SDL_FlashWindow`

### Display Management (P1)
- [ ] `SDL_GetDisplays`
- [ ] `SDL_GetPrimaryDisplay`
- [ ] `SDL_GetDisplayName`
- [ ] `SDL_GetDisplayBounds`
- [ ] `SDL_GetDisplayUsableBounds`
- [ ] `SDL_GetCurrentDisplayMode`
- [ ] `SDL_GetDesktopDisplayMode`
- [ ] `SDL_GetFullscreenDisplayModes`
- [ ] `SDL_GetDisplayForWindow`
- [ ] `SDL_GetDisplayContentScale`
- [ ] `SDL_GetWindowDisplayScale`

### Renderer (P0)
- [ ] `SDL_GetNumRenderDrivers`
- [ ] `SDL_GetRenderDriver`
- [ ] `SDL_GetRenderer`
- [ ] `SDL_GetRenderWindow`
- [ ] `SDL_GetRendererName`
- [ ] `SDL_GetRenderOutputSize`
- [ ] `SDL_GetCurrentRenderOutputSize`
- [ ] `SDL_SetRenderTarget`
- [ ] `SDL_GetRenderTarget`
- [ ] `SDL_SetRenderViewport`
- [ ] `SDL_GetRenderViewport`
- [ ] `SDL_SetRenderClipRect`
- [ ] `SDL_GetRenderClipRect`
- [ ] `SDL_RenderClipEnabled`
- [ ] `SDL_SetRenderScale`
- [ ] `SDL_GetRenderScale`
- [ ] `SDL_SetRenderDrawColorFloat`
- [ ] `SDL_GetRenderDrawColor`
- [ ] `SDL_GetRenderDrawColorFloat`
- [ ] `SDL_SetRenderDrawBlendMode`
- [ ] `SDL_GetRenderDrawBlendMode`
- [ ] `SDL_SetRenderVSync`
- [ ] `SDL_GetRenderVSync`

### Renderer Drawing (P0)
- [x] `SDL_RenderPoint`
- [x] `SDL_RenderPoints`
- [x] `SDL_RenderLine`
- [x] `SDL_RenderLines`
- [x] `SDL_RenderRect`
- [x] `SDL_RenderRects`
- [x] `SDL_RenderFillRect`
- [x] `SDL_RenderFillRects`
- [ ] `SDL_RenderTextureRotated`
- [ ] `SDL_RenderTextureAffine`
- [ ] `SDL_RenderTextureTiled`
- [ ] `SDL_RenderTexture9Grid`
- [ ] `SDL_RenderGeometry`
- [ ] `SDL_RenderGeometryRaw`
- [ ] `SDL_RenderReadPixels`
- [ ] `SDL_RenderDebugText`
- [ ] `SDL_RenderDebugTextFormat`

### Texture (P1)
- [ ] `SDL_CreateTexture`
- [ ] `SDL_CreateTextureWithProperties`
- [ ] `SDL_GetTextureProperties`
- [ ] `SDL_SetTextureColorMod`
- [ ] `SDL_GetTextureColorMod`
- [ ] `SDL_SetTextureColorModFloat`
- [ ] `SDL_GetTextureColorModFloat`
- [ ] `SDL_SetTextureAlphaMod`
- [ ] `SDL_GetTextureAlphaMod`
- [ ] `SDL_SetTextureAlphaModFloat`
- [ ] `SDL_GetTextureAlphaModFloat`
- [ ] `SDL_SetTextureBlendMode`
- [ ] `SDL_GetTextureBlendMode`
- [ ] `SDL_SetTextureScaleMode`
- [ ] `SDL_GetTextureScaleMode`
- [ ] `SDL_UpdateTexture`
- [ ] `SDL_UpdateYUVTexture`
- [ ] `SDL_UpdateNVTexture`
- [ ] `SDL_LockTexture`
- [ ] `SDL_LockTextureToSurface`
- [ ] `SDL_UnlockTexture`

### Surface Operations (P1)
- [ ] `SDL_CreateSurface`
- [ ] `SDL_CreateSurfaceFrom`
- [ ] `SDL_GetSurfaceProperties`
- [ ] `SDL_LockSurface`
- [ ] `SDL_UnlockSurface`
- [ ] `SDL_LoadBMP`
- [ ] `SDL_LoadBMP_IO`
- [ ] `SDL_SaveBMP`
- [ ] `SDL_SaveBMP_IO`
- [ ] `SDL_BlitSurface`
- [ ] `SDL_BlitSurfaceScaled`
- [ ] `SDL_BlitSurfaceUnchecked`
- [ ] `SDL_BlitSurfaceUncheckedScaled`
- [ ] `SDL_BlitSurfaceTiled`
- [ ] `SDL_BlitSurface9Grid`
- [ ] `SDL_FillSurfaceRect`
- [ ] `SDL_FillSurfaceRects`
- [ ] `SDL_ConvertSurface`
- [ ] `SDL_ConvertSurfaceAndColorspace`
- [ ] `SDL_DuplicateSurface`
- [ ] `SDL_ScaleSurface`
- [ ] `SDL_FlipSurface`
- [ ] `SDL_SetSurfaceColorKey`
- [ ] `SDL_GetSurfaceColorKey`
- [ ] `SDL_SurfaceHasColorKey`
- [ ] `SDL_SetSurfaceAlphaMod`
- [ ] `SDL_GetSurfaceAlphaMod`
- [ ] `SDL_SetSurfaceColorMod`
- [ ] `SDL_GetSurfaceColorMod`
- [ ] `SDL_SetSurfaceBlendMode`
- [ ] `SDL_GetSurfaceBlendMode`
- [ ] `SDL_SetSurfaceClipRect`
- [ ] `SDL_GetSurfaceClipRect`
- [ ] `SDL_SetSurfaceRLE`
- [ ] `SDL_SurfaceHasRLE`
- [ ] `SDL_MapSurfaceRGB`
- [ ] `SDL_MapSurfaceRGBA`
- [ ] `SDL_ReadSurfacePixel`
- [ ] `SDL_WriteSurfacePixel`

### Events (P0)
- [ ] `SDL_WaitEvent`
- [ ] `SDL_WaitEventTimeout`
- [ ] `SDL_PushEvent`
- [ ] `SDL_PumpEvents`
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
- [ ] `SDL_GetKeyboardState`
- [ ] `SDL_ResetKeyboard`
- [ ] `SDL_GetModState`
- [ ] `SDL_SetModState`
- [ ] `SDL_GetKeyFromScancode`
- [ ] `SDL_GetScancodeFromKey`
- [ ] `SDL_SetScancodeName`
- [ ] `SDL_GetScancodeName`
- [ ] `SDL_GetScancodeFromName`
- [ ] `SDL_GetKeyFromName`
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
- [ ] `SDL_GetMouseState`
- [ ] `SDL_GetGlobalMouseState`
- [ ] `SDL_GetRelativeMouseState`
- [ ] `SDL_WarpMouseInWindow`
- [ ] `SDL_WarpMouseGlobal`
- [ ] `SDL_SetWindowRelativeMouseMode`
- [ ] `SDL_GetWindowRelativeMouseMode`
- [ ] `SDL_CaptureMouse`
- [ ] `SDL_CreateCursor`
- [ ] `SDL_CreateColorCursor`
- [ ] `SDL_CreateSystemCursor`
- [ ] `SDL_SetCursor`
- [ ] `SDL_GetCursor`
- [ ] `SDL_GetDefaultCursor`
- [ ] `SDL_DestroyCursor`
- [ ] `SDL_ShowCursor`
- [ ] `SDL_HideCursor`
- [ ] `SDL_CursorVisible`

### Timer (P2)
- [x] `SDL_GetTicks`
- [ ] `SDL_GetTicksNS`
- [ ] `SDL_GetPerformanceCounter`
- [ ] `SDL_GetPerformanceFrequency`
- [ ] `SDL_DelayNS`
- [ ] `SDL_DelayPrecise`
- [ ] `SDL_AddTimer`
- [ ] `SDL_AddTimerNS`
- [ ] `SDL_RemoveTimer`

### Audio (P2)
- [ ] `SDL_GetNumAudioDrivers`
- [ ] `SDL_GetAudioDriver`
- [ ] `SDL_GetCurrentAudioDriver`
- [ ] `SDL_GetAudioPlaybackDevices`
- [ ] `SDL_GetAudioRecordingDevices`
- [ ] `SDL_GetAudioDeviceName`
- [ ] `SDL_GetAudioDeviceFormat`
- [ ] `SDL_OpenAudioDevice`
- [ ] `SDL_CloseAudioDevice`
- [ ] `SDL_PauseAudioDevice`
- [ ] `SDL_ResumeAudioDevice`
- [ ] `SDL_AudioDevicePaused`
- [ ] `SDL_SetAudioDeviceGain`
- [ ] `SDL_GetAudioDeviceGain`
- [ ] `SDL_CreateAudioStream`
- [ ] `SDL_DestroyAudioStream`
- [ ] `SDL_GetAudioStreamFormat`
- [ ] `SDL_SetAudioStreamFormat`
- [ ] `SDL_PutAudioStreamData`
- [ ] `SDL_GetAudioStreamData`
- [ ] `SDL_GetAudioStreamAvailable`
- [ ] `SDL_FlushAudioStream`
- [ ] `SDL_ClearAudioStream`
- [ ] `SDL_BindAudioStream`
- [ ] `SDL_UnbindAudioStream`
- [ ] `SDL_OpenAudioDeviceStream`
- [ ] `SDL_LoadWAV`
- [ ] `SDL_LoadWAV_IO`
- [ ] `SDL_MixAudio`
- [ ] `SDL_ConvertAudioSamples`
- [ ] `SDL_GetAudioFormatName`

### Rectangle Utilities (P1)
- [ ] `SDL_HasRectIntersection`
- [ ] `SDL_GetRectIntersection`
- [ ] `SDL_GetRectUnion`
- [ ] `SDL_GetRectEnclosingPoints`
- [ ] `SDL_GetRectAndLineIntersection`
- [ ] `SDL_HasRectIntersectionFloat`
- [ ] `SDL_GetRectIntersectionFloat`
- [ ] `SDL_GetRectUnionFloat`
- [ ] `SDL_GetRectEnclosingPointsFloat`
- [ ] `SDL_GetRectAndLineIntersectionFloat`

### Clipboard (P2)
- [ ] `SDL_SetClipboardText`
- [ ] `SDL_GetClipboardText`
- [ ] `SDL_HasClipboardText`
- [ ] `SDL_SetPrimarySelectionText`
- [ ] `SDL_GetPrimarySelectionText`
- [ ] `SDL_HasPrimarySelectionText`

### Joystick (P2)
- [ ] `SDL_GetJoysticks`
- [ ] `SDL_OpenJoystick`
- [ ] `SDL_CloseJoystick`
- [ ] `SDL_GetJoystickName`
- [ ] `SDL_GetJoystickAxis`
- [ ] `SDL_GetJoystickButton`
- [ ] `SDL_GetJoystickHat`
- [ ] `SDL_GetNumJoystickAxes`
- [ ] `SDL_GetNumJoystickButtons`
- [ ] `SDL_GetNumJoystickHats`
- [ ] ... (many more)

### Gamepad (P2)
- [ ] `SDL_GetGamepads`
- [ ] `SDL_OpenGamepad`
- [ ] `SDL_CloseGamepad`
- [ ] `SDL_GetGamepadName`
- [ ] `SDL_GetGamepadAxis`
- [ ] `SDL_GetGamepadButton`
- [ ] `SDL_GamepadConnected`
- [ ] ... (many more)

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
- [ ] `SDL_ShowOpenFileDialog`
- [ ] `SDL_ShowSaveFileDialog`
- [ ] `SDL_ShowOpenFolderDialog`

### Message Box (P1)
- [ ] `SDL_ShowSimpleMessageBox`
- [ ] `SDL_ShowMessageBox`

### Miscellaneous (P2)
- [ ] `SDL_OpenURL`
- [ ] `SDL_GetPlatform`
- [ ] `SDL_GetVersion`
- [ ] `SDL_GetRevision`

---

## SDL3_image

### Loading - File (P0)
- [ ] `IMG_Load` (load to surface from file)

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
- [ ] `IMG_SavePNG`
- [ ] `IMG_SavePNG_IO`
- [ ] `IMG_SaveJPG`
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
- [ ] `SDL_INIT_AUDIO`
- [ ] `SDL_INIT_JOYSTICK`
- [ ] `SDL_INIT_HAPTIC`
- [ ] `SDL_INIT_GAMEPAD`
- [ ] `SDL_INIT_EVENTS`
- [ ] `SDL_INIT_SENSOR`
- [ ] `SDL_INIT_CAMERA`

### Window Flags (P1)
- [ ] `SDL_WINDOW_FULLSCREEN`
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
- [ ] `SDL_EVENT_MOUSE_WHEEL`
- [ ] `SDL_EVENT_JOYSTICK_AXIS_MOTION`
- [ ] `SDL_EVENT_JOYSTICK_BUTTON_DOWN`
- [ ] `SDL_EVENT_JOYSTICK_BUTTON_UP`
- [ ] `SDL_EVENT_JOYSTICK_HAT_MOTION`
- [ ] `SDL_EVENT_JOYSTICK_ADDED`
- [ ] `SDL_EVENT_JOYSTICK_REMOVED`
- [ ] `SDL_EVENT_GAMEPAD_AXIS_MOTION`
- [ ] `SDL_EVENT_GAMEPAD_BUTTON_DOWN`
- [ ] `SDL_EVENT_GAMEPAD_BUTTON_UP`
- [ ] `SDL_EVENT_GAMEPAD_ADDED`
- [ ] `SDL_EVENT_GAMEPAD_REMOVED`
- [ ] `SDL_EVENT_DROP_FILE`
- [ ] `SDL_EVENT_DROP_TEXT`
- [ ] `SDL_EVENT_DROP_BEGIN`
- [ ] `SDL_EVENT_DROP_COMPLETE`
- [ ] `SDL_EVENT_AUDIO_DEVICE_ADDED`
- [ ] `SDL_EVENT_AUDIO_DEVICE_REMOVED`
- [ ] `SDL_EVENT_CLIPBOARD_UPDATE`
- [ ] ... (many more)

### Event Structs (P1)
- [ ] `SDL_MouseWheelEvent`
- [ ] `SDL_JoyAxisEvent`
- [ ] `SDL_JoyButtonEvent`
- [ ] `SDL_JoyHatEvent`
- [ ] `SDL_JoyDeviceEvent`
- [ ] `SDL_GamepadAxisEvent`
- [ ] `SDL_GamepadButtonEvent`
- [ ] `SDL_GamepadDeviceEvent`
- [ ] `SDL_DropEvent`
- [ ] `SDL_ClipboardEvent`
- [ ] `SDL_WindowEvent` (full struct with all fields)
- [ ] `SDL_TouchFingerEvent`
- [ ] `SDL_PenMotionEvent`
- [ ] `SDL_PenButtonEvent`

### Key Constants (P1)
- [ ] Full scancode enum (`SDL_SCANCODE_*`) - ~200+ constants
- [ ] Full keycode enum (`SDLK_*`) - ~200+ constants
- [ ] Modifier key constants (`SDL_KMOD_NONE`, `SDL_KMOD_LSHIFT`, `SDL_KMOD_RSHIFT`, etc.)

### Rect Structs (P0)
- [ ] `SDL_Rect` (integer version)
- [ ] `SDL_Point`
- [x] `SDL_FPoint`

### Blend Mode (P1)
- [ ] `SDL_BlendMode` type
- [ ] `SDL_BLENDMODE_NONE`
- [ ] `SDL_BLENDMODE_BLEND`
- [ ] `SDL_BLENDMODE_BLEND_PREMULTIPLIED`
- [ ] `SDL_BLENDMODE_ADD`
- [ ] `SDL_BLENDMODE_ADD_PREMULTIPLIED`
- [ ] `SDL_BLENDMODE_MOD`
- [ ] `SDL_BLENDMODE_MUL`

### Texture Access (P1)
- [ ] `SDL_TextureAccess` enum
- [ ] `SDL_TEXTUREACCESS_STATIC`
- [ ] `SDL_TEXTUREACCESS_STREAMING`
- [ ] `SDL_TEXTUREACCESS_TARGET`

### Pixel Formats (P2)
- [ ] `SDL_PixelFormat` enum with common formats
- [ ] `SDL_PIXELFORMAT_RGBA8888`
- [ ] `SDL_PIXELFORMAT_ARGB8888`
- [ ] `SDL_PIXELFORMAT_RGB24`
- [ ] `SDL_PIXELFORMAT_BGR24`
- [ ] ... (many more)

### Scale Mode (P1)
- [ ] `SDL_ScaleMode` enum
- [ ] `SDL_SCALEMODE_NEAREST`
- [ ] `SDL_SCALEMODE_LINEAR`

### Flip Mode (P2)
- [ ] `SDL_FlipMode` enum
- [ ] `SDL_FLIP_NONE`
- [ ] `SDL_FLIP_HORIZONTAL`
- [ ] `SDL_FLIP_VERTICAL`

### System Cursor (P2)
- [ ] `SDL_SystemCursor` enum
- [ ] `SDL_SYSTEM_CURSOR_DEFAULT`
- [ ] `SDL_SYSTEM_CURSOR_TEXT`
- [ ] `SDL_SYSTEM_CURSOR_WAIT`
- [ ] `SDL_SYSTEM_CURSOR_CROSSHAIR`
- [ ] `SDL_SYSTEM_CURSOR_POINTER`
- [ ] ... (more cursor types)

### Mouse Button Constants (P1)
- [ ] `SDL_BUTTON_LEFT`
- [ ] `SDL_BUTTON_MIDDLE`
- [ ] `SDL_BUTTON_RIGHT`
- [ ] `SDL_BUTTON_X1`
- [ ] `SDL_BUTTON_X2`

### TTF Constants (P1)
- [ ] `TTF_FontStyleFlags` (`TTF_STYLE_NORMAL`, `TTF_STYLE_BOLD`, `TTF_STYLE_ITALIC`, etc.)
- [ ] `TTF_HintingFlags` (`TTF_HINTING_NORMAL`, `TTF_HINTING_LIGHT`, etc.)
- [ ] `TTF_HorizontalAlignment` (`TTF_HORIZONTAL_ALIGN_LEFT`, etc.)
- [ ] `TTF_Direction` (`TTF_DIRECTION_LTR`, `TTF_DIRECTION_RTL`, etc.)

---

## Implementation Statistics

**Currently Implemented:** ~40 functions
**Estimated Total Available:** 500+ functions

### Coverage by Library
| Library | Implemented | Estimated Total | Coverage |
|---------|-------------|-----------------|----------|
| SDL3 Core | 22 | ~350 | ~6% |
| SDL3_image | 2 | ~60 | ~3% |
| SDL3_ttf | 16 | ~120 | ~13% |

---

## Next Steps (Suggested Order)

1. **P0 - Essential Drawing:** `SDL_RenderLine`, `SDL_RenderRect`, `SDL_RenderFillRect`, `SDL_RenderPoint`
2. **P0 - Mouse State:** `SDL_GetMouseState`, `SDL_GetRelativeMouseState`
3. **P0 - Blocking Events:** `SDL_WaitEvent`, `SDL_WaitEventTimeout`
4. **P0 - Window Queries:** `SDL_GetWindowSize`, `SDL_GetWindowPosition`, `SDL_GetWindowFlags`
5. **P0 - Integer Rect:** `SDL_Rect`, `SDL_Point` types
6. **P1 - Image Loading:** `IMG_Load` (surface), `IMG_SavePNG`
7. **P1 - Texture Ops:** `SDL_CreateTexture`, `SDL_SetTextureColorMod`, `SDL_SetTextureAlphaMod`
8. **P1 - Blend Modes:** `SDL_BlendMode` type and constants
9. **P1 - More Keys:** Expand keycode and scancode constants
10. **P2 - Timer:** `SDL_GetTicks`, `SDL_GetPerformanceCounter`
