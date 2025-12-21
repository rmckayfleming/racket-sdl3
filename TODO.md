# SDL3 Racket Bindings - Implementation Checklist

This document tracks the implementation status of SDL3, SDL3_image, and SDL3_ttf bindings.

## Currently Implemented

### Idiomatic Wrapper (`safe.rkt` and `safe/`)
A complete idiomatic Racket layer on top of the raw bindings, providing:
- Custodian-managed resources (automatic cleanup)
- Racket structs for events (with `match` support)
- Simpler APIs (fewer pointer manipulations)
- Drawing helpers, texture management, font/text rendering, mouse state

Modules: `safe/window.rkt`, `safe/events.rkt`, `safe/draw.rkt`, `safe/texture.rkt`, `safe/ttf.rkt`, `safe/mouse.rkt`, `safe/keyboard.rkt`, `safe/clipboard.rkt`, `safe/timer.rkt`, `safe/audio.rkt`, `safe/camera.rkt`, `safe/display.rkt`, `safe/dialog.rkt`, `safe/hints.rkt`, `safe/tray.rkt`, `safe/joystick.rkt`, `safe/gamepad.rkt`, `safe/image.rkt`, `safe/collision.rkt`, `safe/gl.rkt`, `safe/vulkan.rkt`, `safe/gpu.rkt`

### SDL3 Core (`raw/`)

#### Initialization (`raw/init.rkt`)
- [x] `SDL_Init`, `SDL_Quit`, `SDL_GetError`, `SDL_free`
- [x] `SDL_InitSubSystem`, `SDL_QuitSubSystem`, `SDL_WasInit`
- [x] `SDL_SetAppMetadata`, `SDL_SetAppMetadataProperty`, `SDL_GetAppMetadataProperty`

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
- [x] `SDL_GetRectUnion`, `SDL_GetRectUnionFloat`
- [x] `SDL_GetRectEnclosingPoints`, `SDL_GetRectEnclosingPointsFloat`
- [x] `SDL_GetRectAndLineIntersection`, `SDL_GetRectAndLineIntersectionFloat`

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
- [x] `SDL_SetTextureColorModFloat`, `SDL_GetTextureColorModFloat`
- [x] `SDL_SetTextureAlphaModFloat`, `SDL_GetTextureAlphaModFloat`
- [x] `SDL_UpdateTexture`, `SDL_UpdateYUVTexture`, `SDL_UpdateNVTexture`
- [x] `SDL_LockTexture`, `SDL_LockTextureToSurface`, `SDL_UnlockTexture`

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
- [x] `SDL_HasKeyboard`, `SDL_GetKeyboards`, `SDL_GetKeyboardNameForID`
- [x] `SDL_GetKeyboardFocus`

#### Mouse (`raw/mouse.rkt`)
- [x] `SDL_GetMouseState`, `SDL_GetRelativeMouseState`, `SDL_GetGlobalMouseState`
- [x] `SDL_SetWindowRelativeMouseMode`, `SDL_GetWindowRelativeMouseMode`
- [x] `SDL_WarpMouseInWindow`, `SDL_WarpMouseGlobal`
- [x] `SDL_CaptureMouse`
- [x] `SDL_CreateSystemCursor`, `SDL_SetCursor`, `SDL_GetCursor`, `SDL_DestroyCursor`
- [x] `SDL_ShowCursor`, `SDL_HideCursor`, `SDL_CursorVisible`
- [x] `SDL_HasMouse`, `SDL_GetMice`, `SDL_GetMouseNameForID`, `SDL_GetMouseFocus`

#### Timer (`raw/timer.rkt`)
- [x] `SDL_GetTicks`, `SDL_GetTicksNS`
- [x] `SDL_GetPerformanceCounter`, `SDL_GetPerformanceFrequency`
- [x] `SDL_Delay`, `SDL_DelayNS`, `SDL_DelayPrecise`
- [x] `SDL_AddTimer`, `SDL_AddTimerNS`, `SDL_RemoveTimer`

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
- [x] `SDL_GetAudioDeviceFormat`
- [x] `SDL_SetAudioDeviceGain`, `SDL_GetAudioDeviceGain`
- [x] `SDL_OpenAudioDeviceStream`
- [x] `SDL_GetAudioStreamDevice`, `SDL_PauseAudioStreamDevice`, `SDL_ResumeAudioStreamDevice`, `SDL_AudioStreamDevicePaused`
- [x] `SDL_LoadWAV_IO`
- [x] `SDL_MixAudio`, `SDL_ConvertAudioSamples`
- [x] `SDL_GetAudioFormatName`

#### Camera (`raw/camera.rkt`)
- [x] `SDL_GetNumCameraDrivers`, `SDL_GetCameraDriver`, `SDL_GetCurrentCameraDriver`
- [x] `SDL_GetCameras`, `SDL_GetCameraSupportedFormats`
- [x] `SDL_GetCameraName`, `SDL_GetCameraPosition`
- [x] `SDL_OpenCamera`, `SDL_CloseCamera`
- [x] `SDL_GetCameraPermissionState`, `SDL_GetCameraID`, `SDL_GetCameraProperties`, `SDL_GetCameraFormat`
- [x] `SDL_AcquireCameraFrame`, `SDL_ReleaseCameraFrame`

#### System Tray (`raw/tray.rkt`)
- [x] `SDL_CreateTray`, `SDL_DestroyTray`
- [x] `SDL_SetTrayIcon`, `SDL_SetTrayTooltip`
- [x] `SDL_CreateTrayMenu`, `SDL_CreateTraySubmenu`
- [x] `SDL_GetTrayMenu`, `SDL_GetTraySubmenu`
- [x] `SDL_GetTrayEntries`, `SDL_InsertTrayEntryAt`, `SDL_RemoveTrayEntry`
- [x] `SDL_SetTrayEntryLabel`, `SDL_GetTrayEntryLabel`
- [x] `SDL_SetTrayEntryChecked`, `SDL_GetTrayEntryChecked`
- [x] `SDL_SetTrayEntryEnabled`, `SDL_GetTrayEntryEnabled`
- [x] `SDL_SetTrayEntryCallback`, `SDL_ClickTrayEntry`
- [x] `SDL_GetTrayEntryParent`, `SDL_GetTrayMenuParentEntry`, `SDL_GetTrayMenuParentTray`
- [x] `SDL_UpdateTrays`

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
- [x] `SDL_SendJoystickEffect`, `SDL_SendJoystickVirtualSensorData`

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
- [x] `SDL_SendGamepadEffect`
- [x] `SDL_AddGamepadMapping`, `SDL_SetGamepadMapping`, `SDL_GetGamepadMappingForGUID`
- [x] `SDL_GetGamepadMappings`, `SDL_AddGamepadMappingsFromIO`, `SDL_AddGamepadMappingsFromFile`
- [x] `SDL_ReloadGamepadMappings`

#### IOStream (`raw/iostream.rkt`)
- [x] `SDL_IOFromFile`, `SDL_IOFromMem`, `SDL_IOFromConstMem`, `SDL_CloseIO`

#### Properties (`raw/properties.rkt`)
- [x] `SDL_CreateProperties`, `SDL_DestroyProperties`
- [x] `SDL_SetPointerProperty`, `SDL_SetStringProperty`, `SDL_SetNumberProperty`, `SDL_SetFloatProperty`, `SDL_SetBooleanProperty`
- [x] `SDL_GetPointerProperty`, `SDL_GetStringProperty`, `SDL_GetNumberProperty`, `SDL_GetFloatProperty`, `SDL_GetBooleanProperty`

#### OpenGL Support (`raw/gl.rkt`)
- [x] `SDL_GL_LoadLibrary`, `SDL_GL_GetProcAddress`, `SDL_GL_UnloadLibrary`
- [x] `SDL_GL_ExtensionSupported`
- [x] `SDL_GL_SetAttribute`, `SDL_GL_GetAttribute`
- [x] `SDL_GL_CreateContext`, `SDL_GL_MakeCurrent`
- [x] `SDL_GL_GetCurrentContext`, `SDL_GL_GetCurrentWindow`
- [x] `SDL_GL_SetSwapInterval`, `SDL_GL_GetSwapInterval`
- [x] `SDL_GL_SwapWindow`, `SDL_GL_DestroyContext`
- [x] `SDL_GL_ResetAttributes`

#### Vulkan Support (`raw/vulkan.rkt`)
- [x] `SDL_Vulkan_LoadLibrary`, `SDL_Vulkan_GetVkGetInstanceProcAddr`, `SDL_Vulkan_UnloadLibrary`
- [x] `SDL_Vulkan_GetInstanceExtensions`
- [x] `SDL_Vulkan_CreateSurface`, `SDL_Vulkan_DestroySurface`
- [x] `SDL_Vulkan_GetPresentationSupport`

#### GPU API (`raw/gpu.rkt`) - *New in SDL3*
- [x] Device management: `SDL_CreateGPUDevice`, `SDL_DestroyGPUDevice`, `SDL_GetGPUDeviceDriver`, `SDL_GetGPUShaderFormats`
- [x] Swapchain: `SDL_ClaimWindowForGPUDevice`, `SDL_ReleaseWindowFromGPUDevice`, `SDL_AcquireGPUSwapchainTexture`, etc.
- [x] Command buffers: `SDL_AcquireGPUCommandBuffer`, `SDL_SubmitGPUCommandBuffer`, `SDL_CancelGPUCommandBuffer`
- [x] Render pass: `SDL_BeginGPURenderPass`, `SDL_EndGPURenderPass`
- [x] Graphics pipeline: `SDL_CreateGPUGraphicsPipeline`, `SDL_ReleaseGPUGraphicsPipeline`, `SDL_BindGPUGraphicsPipeline`
- [x] Shaders: `SDL_CreateGPUShader`, `SDL_ReleaseGPUShader`
- [x] Buffers: `SDL_CreateGPUBuffer`, `SDL_CreateGPUTransferBuffer`, `SDL_MapGPUTransferBuffer`, etc.
- [x] Copy pass: `SDL_BeginGPUCopyPass`, `SDL_UploadToGPUBuffer`, `SDL_UploadToGPUTexture`, etc.
- [x] Textures: `SDL_CreateGPUTexture`, `SDL_ReleaseGPUTexture`
- [x] Samplers: `SDL_CreateGPUSampler`, `SDL_ReleaseGPUSampler`
- [x] Drawing: `SDL_BindGPUVertexBuffers`, `SDL_DrawGPUPrimitives`, `SDL_DrawGPUIndexedPrimitives`, etc.
- [x] Compute pipeline: `SDL_CreateGPUComputePipeline`, `SDL_BeginGPUComputePass`, `SDL_DispatchGPUCompute`
- [x] Fences: `SDL_QueryGPUFence`, `SDL_ReleaseGPUFence`, `SDL_WaitForGPUFences`
- [x] Blit: `SDL_BlitGPUTexture`
- [x] Examples: `examples/graphics/gpu-info.rkt`, `examples/graphics/gpu-triangle.rkt`, `examples/graphics/gpu-cube.rkt`

### SDL3_image (`raw/image.rkt`)
- [x] `IMG_Version`
- [x] `IMG_LoadTexture`, `IMG_Load`
- [x] `IMG_SavePNG`, `IMG_SaveJPG`
- [x] `IMG_Load_IO`, `IMG_LoadTyped_IO`
- [x] `IMG_LoadTexture_IO`, `IMG_LoadTextureTyped_IO`
- [x] `IMG_isAVIF`, `IMG_isBMP`, `IMG_isGIF`, `IMG_isJPG`, `IMG_isJXL`, `IMG_isLBM`, `IMG_isPCX`, `IMG_isPNG`, `IMG_isPNM`, `IMG_isSVG`, `IMG_isTIF`, `IMG_isWEBP`, `IMG_isXPM`

### SDL3_ttf (`raw/ttf.rkt`)

#### Initialization
- [x] `TTF_Init`, `TTF_Quit`, `TTF_WasInit`

#### Font Loading
- [x] `TTF_OpenFont`, `TTF_CloseFont`, `TTF_CopyFont`
- [x] `TTF_AddFallbackFont`, `TTF_RemoveFallbackFont`, `TTF_ClearFallbackFonts`
- [x] `TTF_OpenFontIO`, `TTF_OpenFontWithProperties`
- [x] `TTF_GetFontProperties`, `TTF_GetFontGeneration`

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
- [x] `TTF_CreateRendererTextEngineWithProperties`
- [x] `TTF_CreateGPUTextEngine`, `TTF_CreateGPUTextEngineWithProperties`
- [x] `TTF_GetGPUTextDrawData`, `TTF_DestroyGPUTextEngine`
- [x] `TTF_SetGPUTextEngineWinding`, `TTF_GetGPUTextEngineWinding`
- [x] `TTF_GetTextProperties`
- [x] `TTF_SetTextEngine`, `TTF_GetTextEngine`
- [x] `TTF_SetTextFont`, `TTF_GetTextFont`
- [x] `TTF_SetTextDirection`, `TTF_GetTextDirection`
- [x] `TTF_SetTextScript`, `TTF_GetTextScript`
- [x] `TTF_SetTextColorFloat`, `TTF_GetTextColorFloat`
- [x] `TTF_SetTextWrapWhitespaceVisible`, `TTF_TextWrapWhitespaceVisible`
- [x] `TTF_GetTextSubString`, `TTF_GetTextSubStringForLine`
- [x] `TTF_GetTextSubStringsForRange`, `TTF_GetTextSubStringForPoint`
- [x] `TTF_GetPreviousTextSubString`, `TTF_GetNextTextSubString`

---

## Not Yet Implemented (Comprehensive List)

### SDL3 Core Subsystems

#### Window Management (Advanced)
- [ ] `SDL_CreateWindowWithProperties`, `SDL_CreatePopupWindow`
- [ ] `SDL_GetWindowProperties`, `SDL_GetWindowParent`, `SDL_SetWindowParent`
- [ ] `SDL_GetWindowPixelFormat`, `SDL_GetWindows`, `SDL_GetWindowICCProfile`
- [ ] `SDL_SetWindowAspectRatio`, `SDL_GetWindowAspectRatio`
- [ ] `SDL_GetWindowSafeArea`, `SDL_GetWindowBordersSize`, `SDL_GetWindowSizeInPixels`
- [ ] `SDL_SetWindowAlwaysOnTop`, `SDL_SyncWindow`, `SDL_WindowHasSurface`
- [ ] `SDL_SetWindowSurfaceVSync`, `SDL_GetWindowSurfaceVSync`, `SDL_UpdateWindowSurfaceRects`, `SDL_DestroyWindowSurface`
- [ ] `SDL_SetWindowKeyboardGrab`, `SDL_SetWindowMouseGrab`, `SDL_GetWindowKeyboardGrab`, `SDL_GetWindowMouseGrab`, `SDL_GetGrabbedWindow`
- [ ] `SDL_SetWindowMouseRect`, `SDL_GetWindowMouseRect`, `SDL_SetWindowModal`, `SDL_SetWindowFocusable`
- [ ] `SDL_ShowWindowSystemMenu`, `SDL_SetWindowHitTest`, `SDL_SetWindowShape`
- [ ] `SDL_GetNumVideoDrivers`, `SDL_GetVideoDriver`, `SDL_GetCurrentVideoDriver`, `SDL_GetSystemTheme`
- [ ] `SDL_GetDisplayProperties`, `SDL_GetNaturalDisplayOrientation`, `SDL_GetCurrentDisplayOrientation`, `SDL_GetClosestFullscreenDisplayMode`
- [ ] `SDL_ScreenSaverEnabled`, `SDL_EnableScreenSaver`, `SDL_DisableScreenSaver`

#### Renderer (Advanced)
- [ ] `SDL_CreateRendererWithProperties`, `SDL_CreateSoftwareRenderer`, `SDL_GetRendererProperties`
- [ ] `SDL_SetRenderLogicalPresentation`, `SDL_GetRenderLogicalPresentation`, `SDL_GetRenderLogicalPresentationRect`
- [ ] `SDL_RenderCoordinatesFromWindow`, `SDL_RenderCoordinatesToWindow`, `SDL_ConvertEventToRenderCoordinates`
- [ ] `SDL_RenderViewportSet`, `SDL_GetRenderSafeArea`, `SDL_SetRenderColorScale`, `SDL_GetRenderColorScale`
- [ ] `SDL_FlushRenderer`, `SDL_RenderGeometryRaw`, `SDL_RenderDebugTextFormat`
- [ ] `SDL_GetRenderMetalLayer`, `SDL_GetRenderMetalCommandEncoder`, `SDL_AddVulkanRenderSemaphores`

#### Texture & Surface (Advanced)
- [ ] `SDL_CreateTextureWithProperties`, `SDL_GetTextureProperties`, `SDL_GetRendererFromTexture`
- [ ] `SDL_GetSurfaceProperties`, `SDL_ConvertSurfaceAndColorspace`
- [ ] `SDL_LoadBMP_IO`, `SDL_SaveBMP_IO`, `SDL_BlitSurfaceUnchecked`, `SDL_BlitSurfaceUncheckedScaled`, `SDL_BlitSurfaceTiled`, `SDL_BlitSurface9Grid`

#### GPU API (`SDL_gpu.h`) - *New in SDL3* [MOSTLY DONE]
Core GPU bindings are implemented in `raw/gpu.rkt` and `safe/gpu.rkt`.
Advanced features that may still be needed:
- [ ] GPU debug label functions (`SDL_InsertGPUDebugLabel`, etc.)
- [ ] Additional texture format queries

#### Filesystem & IO (`SDL_filesystem.h`, `SDL_asyncio.h`)
- [ ] `SDL_GetBasePath`, `SDL_GetPrefPath`, `SDL_GetUserFolder`
- [ ] `SDL_GlobDirectory`, `SDL_GetCurrentDirectory`
- [ ] Async I/O: `SDL_AsyncIOFromFile`, `SDL_ReadAsyncIO`, `SDL_WriteAsyncIO`, `SDL_CreateAsyncIOQueue`

#### Time & Locale (`SDL_time.h`, `SDL_locale.h`)
- [ ] `SDL_GetCurrentTime`, `SDL_TimeToDateTime`, `SDL_DateTimeToTime`
- [ ] `SDL_GetDateTimeLocalePreferences`, `SDL_GetDaysInMonth`, `SDL_GetDayOfWeek`
- [ ] `SDL_GetPreferredLocales`

#### Haptic & Sensors (`SDL_haptic.h`, `SDL_sensor.h`)
- [ ] Full haptic/force-feedback subsystem
- [ ] Standalone sensor management (accelerometers, gyroscopes)

#### Miscellaneous
- [ ] `SDL_OpenURL`, `SDL_GetPlatform`, `SDL_GetVersion`, `SDL_GetRevision`
- [ ] `SDL_GetPixelFormatName`, `SDL_GetPixelFormatDetails`, `SDL_CreatePalette`, `SDL_GetRGB`, `SDL_GetRGBA`
- [ ] `SDL_SetModState`, `SDL_SetScancodeName`, `SDL_StartTextInputWithProperties`, `SDL_ClearComposition`
- [ ] `SDL_CreateCursor`, `SDL_CreateColorCursor`, `SDL_GetDefaultCursor`
- [ ] `SDL_SetPrimarySelectionText`, `SDL_GetPrimarySelectionText`
- [ ] `SDL_PushEvent`, `SDL_PeepEvents`, `SDL_SetEventFilter`, etc.

### SDL3_image
- [ ] Animation API: `IMG_LoadAnimation`, `IMG_FreeAnimation`, etc.
- [ ] Advanced saving: `IMG_SavePNG_IO`, `IMG_SaveJPG_IO`, `IMG_SaveAVIF`
- [ ] Special loaders: `IMG_LoadSizedSVG_IO`, `IMG_ReadXPMFromArray`

### SDL3_ttf
- [ ] Note: Basic and TextEngine APIs are largely complete (~100% of standard usage).

---

## Redundant / Will Not Implement

These subsystems are intentionally skipped because Racket provides superior, safer, or more idiomatic native alternatives.

### Threading & Synchronization (`SDL_thread.h`, `SDL_mutex.h`, `SDL_atomic.h`)
- **Reason:** Racket has a sophisticated concurrency model (green threads, places, futures). Using C threads breaks the Racket runtime's memory management and safety guarantees.
- **Alternative:** Use `racket/thread`, `racket/place`, and `racket/future`.

### Process Management (`SDL_process.h`)
- **Reason:** Racket has a comprehensive system API for spawning and managing subprocesses.
- **Alternative:** Use `racket/system`, `process`, or `process*`.

### Shared Object Loading (`SDL_loadso.h`)
- **Reason:** Racket's `ffi/unsafe` already handles dynamic library loading.
- **Alternative:** Use `ffi-lib`.

### Basic Filesystem (`SDL_filesystem.h` subset)
- **Reason:** Standard file operations (`SDL_CopyFile`, `SDL_RemovePath`, etc.) are covered by Racket's standard library.
- **Alternative:** Use `racket/file` (`copy-file`, `delete-file`, `directory-list`).
- **Note:** `SDL_GetBasePath` and `SDL_GetPrefPath` *are* implemented as they provide valuable cross-platform path logic.

### Storage API (`SDL_storage.h`)
- **Reason:** Racket applications run primarily on desktop platforms where direct filesystem access is available and simpler.
- **Alternative:** Use `racket/file`, `racket/path`, and `racket/system` for storage needs.

### Logging (`SDL_log.h`)
- **Reason:** Racket has a built-in logging facility.
- **Alternative:** Use `racket/logging`.

### Standard Library Wrappers (`SDL_stdinc.h`)
- **Reason:** Functions like `SDL_malloc`, `SDL_memcpy`, `SDL_snprintf` are for C environments lacking a standard library. Racket handles memory and strings automatically.

### Assertions & Main (`SDL_assert.h`, `SDL_main.h`)
- **Reason:** Racket controls the entry point and has its own error/contract system.

---

## Implementation Statistics

| Library | Functions Implemented | Estimated Total | Coverage |
|---------|----------------------|-----------------|----------|
| SDL3 Core | ~350 | ~650 | ~54% |
| SDL3_image | ~45 | ~80 | ~56% |
| SDL3_ttf | ~110 | ~120 | ~92% |

**Note:** While many advanced/new subsystems are not yet implemented, all core functionality required for traditional 2D games (Window, Render, Surface, Events, Input, Audio, Texture) is 100% or nearly 100% complete.
