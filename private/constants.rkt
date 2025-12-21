#lang racket/base

;; SDL3 Constants and Flags
;; This module contains constant values, flags, and enumerations (excluding keycodes/scancodes).
;; For type definitions (structs, cpointer types), see types.rkt.
;; For keycodes and scancodes, see enums.rkt.

(require ffi/unsafe)

(provide
 ;; Init flags
 SDL_INIT_AUDIO
 SDL_INIT_VIDEO
 SDL_INIT_JOYSTICK
 SDL_INIT_GAMEPAD
 SDL_INIT_EVENTS
 SDL_INIT_CAMERA
 ;; Window flags
 SDL_WINDOW_FULLSCREEN
 SDL_WINDOW_RESIZABLE
 SDL_WINDOW_HIGH_PIXEL_DENSITY
 SDL_WINDOW_OPENGL
 ;; Event constants
 SDL_EVENT_QUIT
 ;; Window events
 SDL_EVENT_WINDOW_SHOWN
 SDL_EVENT_WINDOW_HIDDEN
 SDL_EVENT_WINDOW_EXPOSED
 SDL_EVENT_WINDOW_MOVED
 SDL_EVENT_WINDOW_RESIZED
 SDL_EVENT_WINDOW_FOCUS_GAINED
 SDL_EVENT_WINDOW_FOCUS_LOST
 SDL_EVENT_WINDOW_CLOSE_REQUESTED
 ;; Keyboard events
 SDL_EVENT_KEY_DOWN
 SDL_EVENT_KEY_UP
 ;; Text input
 SDL_EVENT_TEXT_INPUT
 ;; Mouse events
 SDL_EVENT_MOUSE_MOTION
 SDL_EVENT_MOUSE_BUTTON_DOWN
 SDL_EVENT_MOUSE_BUTTON_UP
 SDL_EVENT_MOUSE_WHEEL
 ;; Clipboard events
 SDL_EVENT_CLIPBOARD_UPDATE
 ;; Drop events
 SDL_EVENT_DROP_FILE
 SDL_EVENT_DROP_TEXT
 SDL_EVENT_DROP_BEGIN
 SDL_EVENT_DROP_COMPLETE
 SDL_EVENT_DROP_POSITION
 ;; Audio device events
 SDL_EVENT_AUDIO_DEVICE_ADDED
 SDL_EVENT_AUDIO_DEVICE_REMOVED
 SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED
 ;; Camera device events
 SDL_EVENT_CAMERA_DEVICE_ADDED
 SDL_EVENT_CAMERA_DEVICE_REMOVED
 SDL_EVENT_CAMERA_DEVICE_APPROVED
 SDL_EVENT_CAMERA_DEVICE_DENIED
 ;; Tray entry flags
 SDL_TRAYENTRY_BUTTON
 SDL_TRAYENTRY_CHECKBOX
 SDL_TRAYENTRY_SUBMENU
 SDL_TRAYENTRY_DISABLED
 SDL_TRAYENTRY_CHECKED
 ;; Camera positions
 SDL_CAMERA_POSITION_UNKNOWN
 SDL_CAMERA_POSITION_FRONT_FACING
 SDL_CAMERA_POSITION_BACK_FACING
 ;; Mouse wheel direction
 SDL_MOUSEWHEEL_NORMAL
 SDL_MOUSEWHEEL_FLIPPED
 ;; Mouse button constants
 SDL_BUTTON_LEFT
 SDL_BUTTON_MIDDLE
 SDL_BUTTON_RIGHT
 SDL_BUTTON_X1
 SDL_BUTTON_X2
 SDL_BUTTON_LMASK
 SDL_BUTTON_MMASK
 SDL_BUTTON_RMASK
 SDL_BUTTON_X1MASK
 SDL_BUTTON_X2MASK
 ;; Event union size
 SDL_EVENT_SIZE
 ;; Blend mode constants
 SDL_BLENDMODE_NONE
 SDL_BLENDMODE_BLEND
 SDL_BLENDMODE_BLEND_PREMULTIPLIED
 SDL_BLENDMODE_ADD
 SDL_BLENDMODE_ADD_PREMULTIPLIED
 SDL_BLENDMODE_MOD
 SDL_BLENDMODE_MUL
 SDL_BLENDMODE_INVALID
 ;; Flip mode constants
 SDL_FLIP_NONE
 SDL_FLIP_HORIZONTAL
 SDL_FLIP_VERTICAL
 ;; Texture access constants
 SDL_TEXTUREACCESS_STATIC
 SDL_TEXTUREACCESS_STREAMING
 SDL_TEXTUREACCESS_TARGET
 ;; Scale mode constants
 SDL_SCALEMODE_INVALID
 SDL_SCALEMODE_NEAREST
 SDL_SCALEMODE_LINEAR
 ;; Pixel format constants
 SDL_PIXELFORMAT_UNKNOWN
 SDL_PIXELFORMAT_RGBA8888
 SDL_PIXELFORMAT_ARGB8888
 SDL_PIXELFORMAT_ABGR8888
 SDL_PIXELFORMAT_BGRA8888
 SDL_PIXELFORMAT_RGB24
 SDL_PIXELFORMAT_RGBA32
 ;; System cursor constants
 SDL_SYSTEM_CURSOR_DEFAULT
 SDL_SYSTEM_CURSOR_TEXT
 SDL_SYSTEM_CURSOR_WAIT
 SDL_SYSTEM_CURSOR_CROSSHAIR
 SDL_SYSTEM_CURSOR_PROGRESS
 SDL_SYSTEM_CURSOR_NWSE_RESIZE
 SDL_SYSTEM_CURSOR_NESW_RESIZE
 SDL_SYSTEM_CURSOR_EW_RESIZE
 SDL_SYSTEM_CURSOR_NS_RESIZE
 SDL_SYSTEM_CURSOR_MOVE
 SDL_SYSTEM_CURSOR_NOT_ALLOWED
 SDL_SYSTEM_CURSOR_POINTER
 SDL_SYSTEM_CURSOR_NW_RESIZE
 SDL_SYSTEM_CURSOR_N_RESIZE
 SDL_SYSTEM_CURSOR_NE_RESIZE
 SDL_SYSTEM_CURSOR_E_RESIZE
 SDL_SYSTEM_CURSOR_SE_RESIZE
 SDL_SYSTEM_CURSOR_S_RESIZE
 SDL_SYSTEM_CURSOR_SW_RESIZE
 SDL_SYSTEM_CURSOR_W_RESIZE
 SDL_SYSTEM_CURSOR_COUNT
 ;; App metadata properties
 SDL_PROP_APP_METADATA_NAME_STRING
 SDL_PROP_APP_METADATA_VERSION_STRING
 SDL_PROP_APP_METADATA_IDENTIFIER_STRING
 SDL_PROP_APP_METADATA_CREATOR_STRING
 SDL_PROP_APP_METADATA_COPYRIGHT_STRING
 SDL_PROP_APP_METADATA_URL_STRING
 SDL_PROP_APP_METADATA_TYPE_STRING
 ;; Audio constants
 SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK
 SDL_AUDIO_DEVICE_DEFAULT_RECORDING
 SDL_AUDIO_UNKNOWN
 SDL_AUDIO_U8
 SDL_AUDIO_S8
 SDL_AUDIO_S16LE
 SDL_AUDIO_S16BE
 SDL_AUDIO_S32LE
 SDL_AUDIO_S32BE
 SDL_AUDIO_F32LE
 SDL_AUDIO_F32BE
 SDL_AUDIO_S16
 SDL_AUDIO_S32
 SDL_AUDIO_F32
 ;; Flash operation constants
 SDL_FLASH_CANCEL
 SDL_FLASH_BRIEFLY
 SDL_FLASH_UNTIL_FOCUSED
 ;; Message box constants
 SDL_MESSAGEBOX_ERROR
 SDL_MESSAGEBOX_WARNING
 SDL_MESSAGEBOX_INFORMATION
 SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT
 SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT
 SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT
 SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT
 ;; Hint priority
 SDL_HINT_DEFAULT
 SDL_HINT_NORMAL
 SDL_HINT_OVERRIDE
 ;; Common hint names
 SDL_HINT_APP_NAME
 SDL_HINT_APP_ID
 SDL_HINT_RENDER_DRIVER
 SDL_HINT_RENDER_VSYNC
 SDL_HINT_VIDEO_ALLOW_SCREENSAVER
 SDL_HINT_FRAMEBUFFER_ACCELERATION
 SDL_HINT_MOUSE_RELATIVE_MODE_WARP
 ;; Joystick event constants
 SDL_EVENT_JOYSTICK_AXIS_MOTION
 SDL_EVENT_JOYSTICK_BALL_MOTION
 SDL_EVENT_JOYSTICK_HAT_MOTION
 SDL_EVENT_JOYSTICK_BUTTON_DOWN
 SDL_EVENT_JOYSTICK_BUTTON_UP
 SDL_EVENT_JOYSTICK_ADDED
 SDL_EVENT_JOYSTICK_REMOVED
 SDL_EVENT_JOYSTICK_BATTERY_UPDATED
 SDL_EVENT_JOYSTICK_UPDATE_COMPLETE
 ;; Gamepad event constants
 SDL_EVENT_GAMEPAD_AXIS_MOTION
 SDL_EVENT_GAMEPAD_BUTTON_DOWN
 SDL_EVENT_GAMEPAD_BUTTON_UP
 SDL_EVENT_GAMEPAD_ADDED
 SDL_EVENT_GAMEPAD_REMOVED
 SDL_EVENT_GAMEPAD_REMAPPED
 SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN
 SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION
 SDL_EVENT_GAMEPAD_TOUCHPAD_UP
 SDL_EVENT_GAMEPAD_SENSOR_UPDATE
 SDL_EVENT_GAMEPAD_UPDATE_COMPLETE
 SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED
 ;; Joystick hat constants
 SDL_HAT_CENTERED
 SDL_HAT_UP
 SDL_HAT_RIGHT
 SDL_HAT_DOWN
 SDL_HAT_LEFT
 SDL_HAT_RIGHTUP
 SDL_HAT_RIGHTDOWN
 SDL_HAT_LEFTUP
 SDL_HAT_LEFTDOWN
 ;; Joystick type constants
 SDL_JOYSTICK_TYPE_UNKNOWN
 SDL_JOYSTICK_TYPE_GAMEPAD
 SDL_JOYSTICK_TYPE_WHEEL
 SDL_JOYSTICK_TYPE_ARCADE_STICK
 SDL_JOYSTICK_TYPE_FLIGHT_STICK
 SDL_JOYSTICK_TYPE_DANCE_PAD
 SDL_JOYSTICK_TYPE_GUITAR
 SDL_JOYSTICK_TYPE_DRUM_KIT
 SDL_JOYSTICK_TYPE_ARCADE_PAD
 SDL_JOYSTICK_TYPE_THROTTLE
 ;; Joystick connection state
 SDL_JOYSTICK_CONNECTION_INVALID
 SDL_JOYSTICK_CONNECTION_UNKNOWN
 SDL_JOYSTICK_CONNECTION_WIRED
 SDL_JOYSTICK_CONNECTION_WIRELESS
 ;; Power state
 SDL_POWERSTATE_ERROR
 SDL_POWERSTATE_UNKNOWN
 SDL_POWERSTATE_ON_BATTERY
 SDL_POWERSTATE_NO_BATTERY
 SDL_POWERSTATE_CHARGING
 SDL_POWERSTATE_CHARGED
 ;; Gamepad type constants
 SDL_GAMEPAD_TYPE_UNKNOWN
 SDL_GAMEPAD_TYPE_STANDARD
 SDL_GAMEPAD_TYPE_XBOX360
 SDL_GAMEPAD_TYPE_XBOXONE
 SDL_GAMEPAD_TYPE_PS3
 SDL_GAMEPAD_TYPE_PS4
 SDL_GAMEPAD_TYPE_PS5
 SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO
 SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT
 SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT
 SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR
 ;; Gamepad button constants
 SDL_GAMEPAD_BUTTON_INVALID
 SDL_GAMEPAD_BUTTON_SOUTH
 SDL_GAMEPAD_BUTTON_EAST
 SDL_GAMEPAD_BUTTON_WEST
 SDL_GAMEPAD_BUTTON_NORTH
 SDL_GAMEPAD_BUTTON_BACK
 SDL_GAMEPAD_BUTTON_GUIDE
 SDL_GAMEPAD_BUTTON_START
 SDL_GAMEPAD_BUTTON_LEFT_STICK
 SDL_GAMEPAD_BUTTON_RIGHT_STICK
 SDL_GAMEPAD_BUTTON_LEFT_SHOULDER
 SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER
 SDL_GAMEPAD_BUTTON_DPAD_UP
 SDL_GAMEPAD_BUTTON_DPAD_DOWN
 SDL_GAMEPAD_BUTTON_DPAD_LEFT
 SDL_GAMEPAD_BUTTON_DPAD_RIGHT
 SDL_GAMEPAD_BUTTON_MISC1
 SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1
 SDL_GAMEPAD_BUTTON_LEFT_PADDLE1
 SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2
 SDL_GAMEPAD_BUTTON_LEFT_PADDLE2
 SDL_GAMEPAD_BUTTON_TOUCHPAD
 SDL_GAMEPAD_BUTTON_MISC2
 SDL_GAMEPAD_BUTTON_MISC3
 SDL_GAMEPAD_BUTTON_MISC4
 SDL_GAMEPAD_BUTTON_MISC5
 SDL_GAMEPAD_BUTTON_MISC6
 SDL_GAMEPAD_BUTTON_COUNT
 ;; Gamepad axis constants
 SDL_GAMEPAD_AXIS_INVALID
 SDL_GAMEPAD_AXIS_LEFTX
 SDL_GAMEPAD_AXIS_LEFTY
 SDL_GAMEPAD_AXIS_RIGHTX
 SDL_GAMEPAD_AXIS_RIGHTY
 SDL_GAMEPAD_AXIS_LEFT_TRIGGER
 SDL_GAMEPAD_AXIS_RIGHT_TRIGGER
 SDL_GAMEPAD_AXIS_COUNT
 ;; Gamepad button label constants
 SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN
 SDL_GAMEPAD_BUTTON_LABEL_A
 SDL_GAMEPAD_BUTTON_LABEL_B
 SDL_GAMEPAD_BUTTON_LABEL_X
 SDL_GAMEPAD_BUTTON_LABEL_Y
 SDL_GAMEPAD_BUTTON_LABEL_CROSS
 SDL_GAMEPAD_BUTTON_LABEL_CIRCLE
 SDL_GAMEPAD_BUTTON_LABEL_SQUARE
 SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE
 ;; Touch event constants
 SDL_EVENT_FINGER_DOWN
 SDL_EVENT_FINGER_UP
 SDL_EVENT_FINGER_MOTION
 SDL_EVENT_FINGER_CANCELED
 ;; Pen event constants
 SDL_EVENT_PEN_PROXIMITY_IN
 SDL_EVENT_PEN_PROXIMITY_OUT
 SDL_EVENT_PEN_DOWN
 SDL_EVENT_PEN_UP
 SDL_EVENT_PEN_BUTTON_DOWN
 SDL_EVENT_PEN_BUTTON_UP
 SDL_EVENT_PEN_MOTION
 SDL_EVENT_PEN_AXIS
 ;; Pen input flags
 SDL_PEN_INPUT_DOWN
 SDL_PEN_INPUT_BUTTON_1
 SDL_PEN_INPUT_BUTTON_2
 SDL_PEN_INPUT_BUTTON_3
 SDL_PEN_INPUT_BUTTON_4
 SDL_PEN_INPUT_BUTTON_5
 SDL_PEN_INPUT_ERASER_TIP
 ;; Pen axis constants
 SDL_PEN_AXIS_PRESSURE
 SDL_PEN_AXIS_XTILT
 SDL_PEN_AXIS_YTILT
 SDL_PEN_AXIS_DISTANCE
 SDL_PEN_AXIS_ROTATION
 SDL_PEN_AXIS_SLIDER
 SDL_PEN_AXIS_TANGENTIAL_PRESSURE
 SDL_PEN_AXIS_COUNT
 ;; Touch device types
 SDL_TOUCH_DEVICE_INVALID
 SDL_TOUCH_DEVICE_DIRECT
 SDL_TOUCH_DEVICE_INDIRECT_ABSOLUTE
 SDL_TOUCH_DEVICE_INDIRECT_RELATIVE
 ;; TTF font style flags
 TTF_STYLE_NORMAL
 TTF_STYLE_BOLD
 TTF_STYLE_ITALIC
 TTF_STYLE_UNDERLINE
 TTF_STYLE_STRIKETHROUGH
 ;; TTF font hinting modes
 TTF_HINTING_INVALID
 TTF_HINTING_NORMAL
 TTF_HINTING_LIGHT
 TTF_HINTING_MONO
 TTF_HINTING_NONE
 TTF_HINTING_LIGHT_SUBPIXEL
 ;; TTF horizontal alignment
 TTF_HORIZONTAL_ALIGN_INVALID
 TTF_HORIZONTAL_ALIGN_LEFT
 TTF_HORIZONTAL_ALIGN_CENTER
 TTF_HORIZONTAL_ALIGN_RIGHT
 ;; TTF text direction
 TTF_DIRECTION_INVALID
 TTF_DIRECTION_LTR
 TTF_DIRECTION_RTL
 TTF_DIRECTION_TTB
 TTF_DIRECTION_BTT
 ;; TTF glyph image types
 TTF_IMAGE_INVALID
 TTF_IMAGE_ALPHA
 TTF_IMAGE_COLOR
 TTF_IMAGE_SDF
 ;; TTF font weight constants
 TTF_FONT_WEIGHT_THIN
 TTF_FONT_WEIGHT_EXTRA_LIGHT
 TTF_FONT_WEIGHT_LIGHT
 TTF_FONT_WEIGHT_NORMAL
 TTF_FONT_WEIGHT_MEDIUM
 TTF_FONT_WEIGHT_SEMI_BOLD
 TTF_FONT_WEIGHT_BOLD
 TTF_FONT_WEIGHT_EXTRA_BOLD
 TTF_FONT_WEIGHT_BLACK
 TTF_FONT_WEIGHT_EXTRA_BLACK
 ;; TTF properties (font and text engines)
 TTF_PROP_FONT_CREATE_FILENAME_STRING
 TTF_PROP_FONT_CREATE_IOSTREAM_POINTER
 TTF_PROP_FONT_CREATE_IOSTREAM_OFFSET_NUMBER
 TTF_PROP_FONT_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN
 TTF_PROP_FONT_CREATE_SIZE_FLOAT
 TTF_PROP_FONT_CREATE_FACE_NUMBER
 TTF_PROP_FONT_CREATE_HORIZONTAL_DPI_NUMBER
 TTF_PROP_FONT_CREATE_VERTICAL_DPI_NUMBER
 TTF_PROP_FONT_CREATE_EXISTING_FONT
 TTF_PROP_FONT_OUTLINE_LINE_CAP_NUMBER
 TTF_PROP_FONT_OUTLINE_LINE_JOIN_NUMBER
 TTF_PROP_FONT_OUTLINE_MITER_LIMIT_NUMBER
 TTF_PROP_RENDERER_TEXT_ENGINE_RENDERER
 TTF_PROP_RENDERER_TEXT_ENGINE_ATLAS_TEXTURE_SIZE
 TTF_PROP_GPU_TEXT_ENGINE_DEVICE
 TTF_PROP_GPU_TEXT_ENGINE_ATLAS_TEXTURE_SIZE
 ;; TTF substring flags
 TTF_SUBSTRING_DIRECTION_MASK
 TTF_SUBSTRING_TEXT_START
 TTF_SUBSTRING_LINE_START
 TTF_SUBSTRING_LINE_END
 TTF_SUBSTRING_TEXT_END
 ;; TTF GPU text engine winding
 TTF_GPU_TEXTENGINE_WINDING_INVALID
 TTF_GPU_TEXTENGINE_WINDING_CLOCKWISE
 TTF_GPU_TEXTENGINE_WINDING_COUNTER_CLOCKWISE
 ;; OpenGL attributes
 SDL_GL_RED_SIZE
 SDL_GL_GREEN_SIZE
 SDL_GL_BLUE_SIZE
 SDL_GL_ALPHA_SIZE
 SDL_GL_BUFFER_SIZE
 SDL_GL_DOUBLEBUFFER
 SDL_GL_DEPTH_SIZE
 SDL_GL_STENCIL_SIZE
 SDL_GL_ACCUM_RED_SIZE
 SDL_GL_ACCUM_GREEN_SIZE
 SDL_GL_ACCUM_BLUE_SIZE
 SDL_GL_ACCUM_ALPHA_SIZE
 SDL_GL_STEREO
 SDL_GL_MULTISAMPLEBUFFERS
 SDL_GL_MULTISAMPLESAMPLES
 SDL_GL_ACCELERATED_VISUAL
 SDL_GL_RETAINED_BACKING
 SDL_GL_CONTEXT_MAJOR_VERSION
 SDL_GL_CONTEXT_MINOR_VERSION
 SDL_GL_CONTEXT_FLAGS
 SDL_GL_CONTEXT_PROFILE_MASK
 SDL_GL_SHARE_WITH_CURRENT_CONTEXT
 SDL_GL_FRAMEBUFFER_SRGB_CAPABLE
 SDL_GL_CONTEXT_RELEASE_BEHAVIOR
 SDL_GL_CONTEXT_RESET_NOTIFICATION
 SDL_GL_CONTEXT_NO_ERROR
 SDL_GL_FLOATBUFFERS
 SDL_GL_EGL_PLATFORM
 ;; OpenGL context profiles
 SDL_GL_CONTEXT_PROFILE_CORE
 SDL_GL_CONTEXT_PROFILE_COMPATIBILITY
 SDL_GL_CONTEXT_PROFILE_ES
 ;; OpenGL context flags
 SDL_GL_CONTEXT_DEBUG_FLAG
 SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG
 SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG
 SDL_GL_CONTEXT_RESET_ISOLATION_FLAG
 ;; GPU primitive types
 SDL_GPU_PRIMITIVETYPE_TRIANGLELIST
 SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP
 SDL_GPU_PRIMITIVETYPE_LINELIST
 SDL_GPU_PRIMITIVETYPE_LINESTRIP
 SDL_GPU_PRIMITIVETYPE_POINTLIST
 ;; GPU load operations
 SDL_GPU_LOADOP_LOAD
 SDL_GPU_LOADOP_CLEAR
 SDL_GPU_LOADOP_DONT_CARE
 ;; GPU store operations
 SDL_GPU_STOREOP_STORE
 SDL_GPU_STOREOP_DONT_CARE
 SDL_GPU_STOREOP_RESOLVE
 SDL_GPU_STOREOP_RESOLVE_AND_STORE
 ;; GPU index element size
 SDL_GPU_INDEXELEMENTSIZE_16BIT
 SDL_GPU_INDEXELEMENTSIZE_32BIT
 ;; GPU texture formats
 SDL_GPU_TEXTUREFORMAT_INVALID
 SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM
 SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM
 SDL_GPU_TEXTUREFORMAT_R8_UNORM
 SDL_GPU_TEXTUREFORMAT_R8G8_UNORM
 SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT
 SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT
 SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB
 SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB
 SDL_GPU_TEXTUREFORMAT_D16_UNORM
 SDL_GPU_TEXTUREFORMAT_D24_UNORM
 SDL_GPU_TEXTUREFORMAT_D32_FLOAT
 SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT
 SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT
 ;; GPU texture usage flags
 SDL_GPU_TEXTUREUSAGE_SAMPLER
 SDL_GPU_TEXTUREUSAGE_COLOR_TARGET
 SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET
 SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ
 SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ
 SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE
 SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE
 ;; GPU texture types
 SDL_GPU_TEXTURETYPE_2D
 SDL_GPU_TEXTURETYPE_2D_ARRAY
 SDL_GPU_TEXTURETYPE_3D
 SDL_GPU_TEXTURETYPE_CUBE
 SDL_GPU_TEXTURETYPE_CUBE_ARRAY
 ;; GPU sample count
 SDL_GPU_SAMPLECOUNT_1
 SDL_GPU_SAMPLECOUNT_2
 SDL_GPU_SAMPLECOUNT_4
 SDL_GPU_SAMPLECOUNT_8
 ;; GPU buffer usage flags
 SDL_GPU_BUFFERUSAGE_VERTEX
 SDL_GPU_BUFFERUSAGE_INDEX
 SDL_GPU_BUFFERUSAGE_INDIRECT
 SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ
 SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ
 SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE
 ;; GPU transfer buffer usage
 SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD
 SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD
 ;; GPU shader stage
 SDL_GPU_SHADERSTAGE_VERTEX
 SDL_GPU_SHADERSTAGE_FRAGMENT
 ;; GPU shader format
 SDL_GPU_SHADERFORMAT_INVALID
 SDL_GPU_SHADERFORMAT_PRIVATE
 SDL_GPU_SHADERFORMAT_SPIRV
 SDL_GPU_SHADERFORMAT_DXBC
 SDL_GPU_SHADERFORMAT_DXIL
 SDL_GPU_SHADERFORMAT_MSL
 SDL_GPU_SHADERFORMAT_METALLIB
 ;; GPU vertex element formats
 SDL_GPU_VERTEXELEMENTFORMAT_INVALID
 SDL_GPU_VERTEXELEMENTFORMAT_INT
 SDL_GPU_VERTEXELEMENTFORMAT_INT2
 SDL_GPU_VERTEXELEMENTFORMAT_INT3
 SDL_GPU_VERTEXELEMENTFORMAT_INT4
 SDL_GPU_VERTEXELEMENTFORMAT_UINT
 SDL_GPU_VERTEXELEMENTFORMAT_UINT2
 SDL_GPU_VERTEXELEMENTFORMAT_UINT3
 SDL_GPU_VERTEXELEMENTFORMAT_UINT4
 SDL_GPU_VERTEXELEMENTFORMAT_FLOAT
 SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2
 SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3
 SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4
 SDL_GPU_VERTEXELEMENTFORMAT_BYTE2
 SDL_GPU_VERTEXELEMENTFORMAT_BYTE4
 SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2
 SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4
 SDL_GPU_VERTEXELEMENTFORMAT_BYTE2_NORM
 SDL_GPU_VERTEXELEMENTFORMAT_BYTE4_NORM
 SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM
 SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM
 SDL_GPU_VERTEXELEMENTFORMAT_SHORT2
 SDL_GPU_VERTEXELEMENTFORMAT_SHORT4
 SDL_GPU_VERTEXELEMENTFORMAT_USHORT2
 SDL_GPU_VERTEXELEMENTFORMAT_USHORT4
 SDL_GPU_VERTEXELEMENTFORMAT_SHORT2_NORM
 SDL_GPU_VERTEXELEMENTFORMAT_SHORT4_NORM
 SDL_GPU_VERTEXELEMENTFORMAT_USHORT2_NORM
 SDL_GPU_VERTEXELEMENTFORMAT_USHORT4_NORM
 SDL_GPU_VERTEXELEMENTFORMAT_HALF2
 SDL_GPU_VERTEXELEMENTFORMAT_HALF4
 ;; GPU vertex input rate
 SDL_GPU_VERTEXINPUTRATE_VERTEX
 SDL_GPU_VERTEXINPUTRATE_INSTANCE
 ;; GPU fill mode
 SDL_GPU_FILLMODE_FILL
 SDL_GPU_FILLMODE_LINE
 ;; GPU cull mode
 SDL_GPU_CULLMODE_NONE
 SDL_GPU_CULLMODE_FRONT
 SDL_GPU_CULLMODE_BACK
 ;; GPU front face
 SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE
 SDL_GPU_FRONTFACE_CLOCKWISE
 ;; GPU compare op
 SDL_GPU_COMPAREOP_INVALID
 SDL_GPU_COMPAREOP_NEVER
 SDL_GPU_COMPAREOP_LESS
 SDL_GPU_COMPAREOP_EQUAL
 SDL_GPU_COMPAREOP_LESS_OR_EQUAL
 SDL_GPU_COMPAREOP_GREATER
 SDL_GPU_COMPAREOP_NOT_EQUAL
 SDL_GPU_COMPAREOP_GREATER_OR_EQUAL
 SDL_GPU_COMPAREOP_ALWAYS
 ;; GPU stencil op
 SDL_GPU_STENCILOP_INVALID
 SDL_GPU_STENCILOP_KEEP
 SDL_GPU_STENCILOP_ZERO
 SDL_GPU_STENCILOP_REPLACE
 SDL_GPU_STENCILOP_INCREMENT_AND_CLAMP
 SDL_GPU_STENCILOP_DECREMENT_AND_CLAMP
 SDL_GPU_STENCILOP_INVERT
 SDL_GPU_STENCILOP_INCREMENT_AND_WRAP
 SDL_GPU_STENCILOP_DECREMENT_AND_WRAP
 ;; GPU blend op
 SDL_GPU_BLENDOP_INVALID
 SDL_GPU_BLENDOP_ADD
 SDL_GPU_BLENDOP_SUBTRACT
 SDL_GPU_BLENDOP_REVERSE_SUBTRACT
 SDL_GPU_BLENDOP_MIN
 SDL_GPU_BLENDOP_MAX
 ;; GPU blend factor
 SDL_GPU_BLENDFACTOR_INVALID
 SDL_GPU_BLENDFACTOR_ZERO
 SDL_GPU_BLENDFACTOR_ONE
 SDL_GPU_BLENDFACTOR_SRC_COLOR
 SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR
 SDL_GPU_BLENDFACTOR_DST_COLOR
 SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR
 SDL_GPU_BLENDFACTOR_SRC_ALPHA
 SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA
 SDL_GPU_BLENDFACTOR_DST_ALPHA
 SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA
 SDL_GPU_BLENDFACTOR_CONSTANT_COLOR
 SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR
 SDL_GPU_BLENDFACTOR_SRC_ALPHA_SATURATE
 ;; GPU color component flags
 SDL_GPU_COLORCOMPONENT_R
 SDL_GPU_COLORCOMPONENT_G
 SDL_GPU_COLORCOMPONENT_B
 SDL_GPU_COLORCOMPONENT_A
 ;; GPU filter
 SDL_GPU_FILTER_NEAREST
 SDL_GPU_FILTER_LINEAR
 ;; GPU sampler mipmap mode
 SDL_GPU_SAMPLERMIPMAPMODE_NEAREST
 SDL_GPU_SAMPLERMIPMAPMODE_LINEAR
 ;; GPU sampler address mode
 SDL_GPU_SAMPLERADDRESSMODE_REPEAT
 SDL_GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT
 SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE
 ;; GPU present mode
 SDL_GPU_PRESENTMODE_VSYNC
 SDL_GPU_PRESENTMODE_IMMEDIATE
 SDL_GPU_PRESENTMODE_MAILBOX
 ;; GPU swapchain composition
 SDL_GPU_SWAPCHAINCOMPOSITION_SDR
 SDL_GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR
 SDL_GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR
 SDL_GPU_SWAPCHAINCOMPOSITION_HDR10_ST2084)

;; ============================================================================
;; Init Flags (SDL_InitFlags) - used with SDL_Init
;; ============================================================================
(define SDL_INIT_AUDIO    #x00000010)
(define SDL_INIT_VIDEO    #x00000020)
(define SDL_INIT_JOYSTICK #x00000200)
(define SDL_INIT_GAMEPAD  #x00001000)
(define SDL_INIT_EVENTS   #x00004000)
(define SDL_INIT_CAMERA   #x00010000)

;; ============================================================================
;; Window Flags (SDL_WindowFlags) - 64-bit in SDL3
;; ============================================================================
(define SDL_WINDOW_FULLSCREEN          #x0000000000000001)
(define SDL_WINDOW_RESIZABLE           #x0000000000000020)
(define SDL_WINDOW_HIGH_PIXEL_DENSITY  #x0000000000002000)
(define SDL_WINDOW_OPENGL              #x0000000000000002)

;; ============================================================================
;; Event Constants
;; ============================================================================
(define SDL_EVENT_QUIT #x100)
;; Window events
(define SDL_EVENT_WINDOW_SHOWN #x202)
(define SDL_EVENT_WINDOW_HIDDEN #x203)
(define SDL_EVENT_WINDOW_EXPOSED #x204)
(define SDL_EVENT_WINDOW_MOVED #x205)
(define SDL_EVENT_WINDOW_RESIZED #x206)
(define SDL_EVENT_WINDOW_FOCUS_GAINED #x209)
(define SDL_EVENT_WINDOW_FOCUS_LOST #x20A)
(define SDL_EVENT_WINDOW_CLOSE_REQUESTED #x212)
;; Keyboard events
(define SDL_EVENT_KEY_DOWN #x300)
(define SDL_EVENT_KEY_UP #x301)
;; Text input
(define SDL_EVENT_TEXT_INPUT #x303)
;; Mouse events
(define SDL_EVENT_MOUSE_MOTION #x400)
(define SDL_EVENT_MOUSE_BUTTON_DOWN #x401)
(define SDL_EVENT_MOUSE_BUTTON_UP #x402)
(define SDL_EVENT_MOUSE_WHEEL #x403)
;; Clipboard events
(define SDL_EVENT_CLIPBOARD_UPDATE #x900)
;; Drop events
(define SDL_EVENT_DROP_FILE #x1000)
(define SDL_EVENT_DROP_TEXT #x1001)
(define SDL_EVENT_DROP_BEGIN #x1002)
(define SDL_EVENT_DROP_COMPLETE #x1003)
(define SDL_EVENT_DROP_POSITION #x1004)
;; Audio device events
(define SDL_EVENT_AUDIO_DEVICE_ADDED #x1100)
(define SDL_EVENT_AUDIO_DEVICE_REMOVED #x1101)
(define SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED #x1102)
;; Camera device events
(define SDL_EVENT_CAMERA_DEVICE_ADDED #x1400)
(define SDL_EVENT_CAMERA_DEVICE_REMOVED #x1401)
(define SDL_EVENT_CAMERA_DEVICE_APPROVED #x1402)
(define SDL_EVENT_CAMERA_DEVICE_DENIED #x1403)

;; ============================================================================
;; Tray Entry Flags
;; ============================================================================
(define SDL_TRAYENTRY_BUTTON #x00000001)
(define SDL_TRAYENTRY_CHECKBOX #x00000002)
(define SDL_TRAYENTRY_SUBMENU #x00000004)
(define SDL_TRAYENTRY_DISABLED #x80000000)
(define SDL_TRAYENTRY_CHECKED #x40000000)

;; ============================================================================
;; Camera Positions
;; ============================================================================
(define SDL_CAMERA_POSITION_UNKNOWN 0)
(define SDL_CAMERA_POSITION_FRONT_FACING 1)
(define SDL_CAMERA_POSITION_BACK_FACING 2)

;; ============================================================================
;; Mouse Wheel Direction
;; ============================================================================
(define SDL_MOUSEWHEEL_NORMAL 0)
(define SDL_MOUSEWHEEL_FLIPPED 1)

;; ============================================================================
;; Mouse Button Constants
;; ============================================================================
;; Mouse button indices
(define SDL_BUTTON_LEFT 1)
(define SDL_BUTTON_MIDDLE 2)
(define SDL_BUTTON_RIGHT 3)
(define SDL_BUTTON_X1 4)
(define SDL_BUTTON_X2 5)

;; Mouse button masks for SDL_GetMouseState return value
(define (SDL_BUTTON_MASK x) (arithmetic-shift 1 (- x 1)))
(define SDL_BUTTON_LMASK (SDL_BUTTON_MASK SDL_BUTTON_LEFT))    ; 1
(define SDL_BUTTON_MMASK (SDL_BUTTON_MASK SDL_BUTTON_MIDDLE))  ; 2
(define SDL_BUTTON_RMASK (SDL_BUTTON_MASK SDL_BUTTON_RIGHT))   ; 4
(define SDL_BUTTON_X1MASK (SDL_BUTTON_MASK SDL_BUTTON_X1))     ; 8
(define SDL_BUTTON_X2MASK (SDL_BUTTON_MASK SDL_BUTTON_X2))     ; 16

;; SDL_Event union size (128 bytes in SDL3)
(define SDL_EVENT_SIZE 128)

;; ============================================================================
;; Blend Modes
;; ============================================================================
(define SDL_BLENDMODE_NONE                #x00000000)  ; no blending
(define SDL_BLENDMODE_BLEND               #x00000001)  ; alpha blending
(define SDL_BLENDMODE_BLEND_PREMULTIPLIED #x00000010)  ; pre-multiplied alpha
(define SDL_BLENDMODE_ADD                 #x00000002)  ; additive blending
(define SDL_BLENDMODE_ADD_PREMULTIPLIED   #x00000020)  ; pre-multiplied additive
(define SDL_BLENDMODE_MOD                 #x00000004)  ; color modulate
(define SDL_BLENDMODE_MUL                 #x00000008)  ; color multiply
(define SDL_BLENDMODE_INVALID             #x7FFFFFFF)

;; ============================================================================
;; Flip Modes
;; ============================================================================
(define SDL_FLIP_NONE       0)  ; no flipping
(define SDL_FLIP_HORIZONTAL 1)  ; flip horizontally
(define SDL_FLIP_VERTICAL   2)  ; flip vertically

;; ============================================================================
;; Texture Access Modes
;; ============================================================================
(define SDL_TEXTUREACCESS_STATIC    0)  ; changes rarely, not lockable
(define SDL_TEXTUREACCESS_STREAMING 1)  ; changes frequently, lockable
(define SDL_TEXTUREACCESS_TARGET    2)  ; can be used as render target

;; ============================================================================
;; Scale Modes
;; ============================================================================
(define SDL_SCALEMODE_INVALID -1)
(define SDL_SCALEMODE_NEAREST  0)  ; nearest pixel sampling (pixelated)
(define SDL_SCALEMODE_LINEAR   1)  ; linear filtering (smooth)

;; ============================================================================
;; Pixel Formats
;; ============================================================================
(define SDL_PIXELFORMAT_UNKNOWN   #x00000000)
(define SDL_PIXELFORMAT_RGBA8888  #x16462004)
(define SDL_PIXELFORMAT_ARGB8888  #x16362004)
(define SDL_PIXELFORMAT_ABGR8888  #x16762004)
(define SDL_PIXELFORMAT_BGRA8888  #x16862004)
(define SDL_PIXELFORMAT_RGB24     #x17101803)

;; SDL_PIXELFORMAT_RGBA32 is an alias that depends on system endianness
;; On little-endian (macOS ARM/x86, Windows, Linux x86): ABGR8888
;; On big-endian: RGBA8888
;; Most modern systems are little-endian
(define SDL_PIXELFORMAT_RGBA32    SDL_PIXELFORMAT_ABGR8888)

;; ============================================================================
;; System Cursor Types
;; ============================================================================
(define SDL_SYSTEM_CURSOR_DEFAULT      0)   ; Default cursor (usually an arrow)
(define SDL_SYSTEM_CURSOR_TEXT         1)   ; Text selection (usually an I-beam)
(define SDL_SYSTEM_CURSOR_WAIT         2)   ; Wait (hourglass or spinning ball)
(define SDL_SYSTEM_CURSOR_CROSSHAIR    3)   ; Crosshair
(define SDL_SYSTEM_CURSOR_PROGRESS     4)   ; Program busy but interactive
(define SDL_SYSTEM_CURSOR_NWSE_RESIZE  5)   ; Double arrow NW-SE
(define SDL_SYSTEM_CURSOR_NESW_RESIZE  6)   ; Double arrow NE-SW
(define SDL_SYSTEM_CURSOR_EW_RESIZE    7)   ; Double arrow E-W
(define SDL_SYSTEM_CURSOR_NS_RESIZE    8)   ; Double arrow N-S
(define SDL_SYSTEM_CURSOR_MOVE         9)   ; Four-pointed arrow (move)
(define SDL_SYSTEM_CURSOR_NOT_ALLOWED  10)  ; Not permitted (slashed circle)
(define SDL_SYSTEM_CURSOR_POINTER      11)  ; Pointer/link (pointing hand)
(define SDL_SYSTEM_CURSOR_NW_RESIZE    12)  ; Window resize top-left
(define SDL_SYSTEM_CURSOR_N_RESIZE     13)  ; Window resize top
(define SDL_SYSTEM_CURSOR_NE_RESIZE    14)  ; Window resize top-right
(define SDL_SYSTEM_CURSOR_E_RESIZE     15)  ; Window resize right
(define SDL_SYSTEM_CURSOR_SE_RESIZE    16)  ; Window resize bottom-right
(define SDL_SYSTEM_CURSOR_S_RESIZE     17)  ; Window resize bottom
(define SDL_SYSTEM_CURSOR_SW_RESIZE    18)  ; Window resize bottom-left
(define SDL_SYSTEM_CURSOR_W_RESIZE     19)  ; Window resize left
(define SDL_SYSTEM_CURSOR_COUNT        20)  ; Number of system cursors

;; ============================================================================
;; Audio Constants
;; ============================================================================
;; Default device constants
(define SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK   #xFFFFFFFF)
(define SDL_AUDIO_DEVICE_DEFAULT_RECORDING  #xFFFFFFFE)

;; Audio format constants
(define SDL_AUDIO_UNKNOWN  #x0000)  ; Unspecified audio format
(define SDL_AUDIO_U8       #x0008)  ; Unsigned 8-bit samples
(define SDL_AUDIO_S8       #x8008)  ; Signed 8-bit samples
(define SDL_AUDIO_S16LE    #x8010)  ; Signed 16-bit samples (little-endian)
(define SDL_AUDIO_S16BE    #x9010)  ; Signed 16-bit samples (big-endian)
(define SDL_AUDIO_S32LE    #x8020)  ; 32-bit integer samples (little-endian)
(define SDL_AUDIO_S32BE    #x9020)  ; 32-bit integer samples (big-endian)
(define SDL_AUDIO_F32LE    #x8120)  ; 32-bit floating point samples (little-endian)
(define SDL_AUDIO_F32BE    #x9120)  ; 32-bit floating point samples (big-endian)

;; Native byte order aliases (little-endian on macOS/x86/ARM)
(define SDL_AUDIO_S16 SDL_AUDIO_S16LE)
(define SDL_AUDIO_S32 SDL_AUDIO_S32LE)
(define SDL_AUDIO_F32 SDL_AUDIO_F32LE)

;; ============================================================================
;; Flash Operation
;; ============================================================================
(define SDL_FLASH_CANCEL        0)  ; Cancel any window flash state
(define SDL_FLASH_BRIEFLY       1)  ; Flash the window briefly to get attention
(define SDL_FLASH_UNTIL_FOCUSED 2)  ; Flash the window until it gets focus

;; ============================================================================
;; Message Box Constants
;; ============================================================================
;; SDL_MessageBoxFlags - flags for message box display
(define SDL_MESSAGEBOX_ERROR                    #x00000010)  ; error dialog
(define SDL_MESSAGEBOX_WARNING                  #x00000020)  ; warning dialog
(define SDL_MESSAGEBOX_INFORMATION              #x00000040)  ; informational dialog
(define SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT    #x00000080)  ; buttons placed left to right
(define SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT    #x00000100)  ; buttons placed right to left

;; SDL_MessageBoxButtonFlags - flags for individual buttons
(define SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT #x00000001)  ; default button when return is hit
(define SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT #x00000002)  ; default button when escape is hit

;; ============================================================================
;; Hint Priority
;; ============================================================================
(define SDL_HINT_DEFAULT  0)  ; low priority, used for default values
(define SDL_HINT_NORMAL   1)  ; medium priority
(define SDL_HINT_OVERRIDE 2)  ; high priority

;; ============================================================================
;; Common Hint Names
;; ============================================================================
(define SDL_HINT_APP_NAME "SDL_APP_NAME")
(define SDL_HINT_APP_ID "SDL_APP_ID")
(define SDL_HINT_RENDER_DRIVER "SDL_RENDER_DRIVER")
(define SDL_HINT_RENDER_VSYNC "SDL_RENDER_VSYNC")
(define SDL_HINT_VIDEO_ALLOW_SCREENSAVER "SDL_VIDEO_ALLOW_SCREENSAVER")
(define SDL_HINT_FRAMEBUFFER_ACCELERATION "SDL_FRAMEBUFFER_ACCELERATION")
(define SDL_HINT_MOUSE_RELATIVE_MODE_WARP "SDL_MOUSE_RELATIVE_MODE_WARP")

;; ============================================================================
;; App Metadata Properties
;; ============================================================================
(define SDL_PROP_APP_METADATA_NAME_STRING "SDL.app.metadata.name")
(define SDL_PROP_APP_METADATA_VERSION_STRING "SDL.app.metadata.version")
(define SDL_PROP_APP_METADATA_IDENTIFIER_STRING "SDL.app.metadata.identifier")
(define SDL_PROP_APP_METADATA_CREATOR_STRING "SDL.app.metadata.creator")
(define SDL_PROP_APP_METADATA_COPYRIGHT_STRING "SDL.app.metadata.copyright")
(define SDL_PROP_APP_METADATA_URL_STRING "SDL.app.metadata.url")
(define SDL_PROP_APP_METADATA_TYPE_STRING "SDL.app.metadata.type")

;; ============================================================================
;; Joystick Event Constants
;; ============================================================================
(define SDL_EVENT_JOYSTICK_AXIS_MOTION     #x600)
(define SDL_EVENT_JOYSTICK_BALL_MOTION     #x601)
(define SDL_EVENT_JOYSTICK_HAT_MOTION      #x602)
(define SDL_EVENT_JOYSTICK_BUTTON_DOWN     #x603)
(define SDL_EVENT_JOYSTICK_BUTTON_UP       #x604)
(define SDL_EVENT_JOYSTICK_ADDED           #x605)
(define SDL_EVENT_JOYSTICK_REMOVED         #x606)
(define SDL_EVENT_JOYSTICK_BATTERY_UPDATED #x607)
(define SDL_EVENT_JOYSTICK_UPDATE_COMPLETE #x608)

;; ============================================================================
;; Gamepad Event Constants
;; ============================================================================
(define SDL_EVENT_GAMEPAD_AXIS_MOTION          #x650)
(define SDL_EVENT_GAMEPAD_BUTTON_DOWN          #x651)
(define SDL_EVENT_GAMEPAD_BUTTON_UP            #x652)
(define SDL_EVENT_GAMEPAD_ADDED                #x653)
(define SDL_EVENT_GAMEPAD_REMOVED              #x654)
(define SDL_EVENT_GAMEPAD_REMAPPED             #x655)
(define SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN        #x656)
(define SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION      #x657)
(define SDL_EVENT_GAMEPAD_TOUCHPAD_UP          #x658)
(define SDL_EVENT_GAMEPAD_SENSOR_UPDATE        #x659)
(define SDL_EVENT_GAMEPAD_UPDATE_COMPLETE      #x65A)
(define SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED #x65B)

;; ============================================================================
;; Joystick Hat Constants
;; ============================================================================
(define SDL_HAT_CENTERED  #x00)
(define SDL_HAT_UP        #x01)
(define SDL_HAT_RIGHT     #x02)
(define SDL_HAT_DOWN      #x04)
(define SDL_HAT_LEFT      #x08)
(define SDL_HAT_RIGHTUP   (bitwise-ior SDL_HAT_RIGHT SDL_HAT_UP))    ; #x03
(define SDL_HAT_RIGHTDOWN (bitwise-ior SDL_HAT_RIGHT SDL_HAT_DOWN))  ; #x06
(define SDL_HAT_LEFTUP    (bitwise-ior SDL_HAT_LEFT SDL_HAT_UP))     ; #x09
(define SDL_HAT_LEFTDOWN  (bitwise-ior SDL_HAT_LEFT SDL_HAT_DOWN))   ; #x0C

;; ============================================================================
;; Joystick Type Constants
;; ============================================================================
(define SDL_JOYSTICK_TYPE_UNKNOWN      0)
(define SDL_JOYSTICK_TYPE_GAMEPAD      1)
(define SDL_JOYSTICK_TYPE_WHEEL        2)
(define SDL_JOYSTICK_TYPE_ARCADE_STICK 3)
(define SDL_JOYSTICK_TYPE_FLIGHT_STICK 4)
(define SDL_JOYSTICK_TYPE_DANCE_PAD    5)
(define SDL_JOYSTICK_TYPE_GUITAR       6)
(define SDL_JOYSTICK_TYPE_DRUM_KIT     7)
(define SDL_JOYSTICK_TYPE_ARCADE_PAD   8)
(define SDL_JOYSTICK_TYPE_THROTTLE     9)

;; ============================================================================
;; Joystick Connection State Constants
;; ============================================================================
(define SDL_JOYSTICK_CONNECTION_INVALID  -1)
(define SDL_JOYSTICK_CONNECTION_UNKNOWN   0)
(define SDL_JOYSTICK_CONNECTION_WIRED     1)
(define SDL_JOYSTICK_CONNECTION_WIRELESS  2)

;; ============================================================================
;; Power State Constants
;; ============================================================================
(define SDL_POWERSTATE_ERROR      -1)
(define SDL_POWERSTATE_UNKNOWN     0)
(define SDL_POWERSTATE_ON_BATTERY  1)
(define SDL_POWERSTATE_NO_BATTERY  2)
(define SDL_POWERSTATE_CHARGING    3)
(define SDL_POWERSTATE_CHARGED     4)

;; ============================================================================
;; Gamepad Type Constants
;; ============================================================================
(define SDL_GAMEPAD_TYPE_UNKNOWN                   0)
(define SDL_GAMEPAD_TYPE_STANDARD                  1)
(define SDL_GAMEPAD_TYPE_XBOX360                   2)
(define SDL_GAMEPAD_TYPE_XBOXONE                   3)
(define SDL_GAMEPAD_TYPE_PS3                       4)
(define SDL_GAMEPAD_TYPE_PS4                       5)
(define SDL_GAMEPAD_TYPE_PS5                       6)
(define SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO       7)
(define SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT  8)
(define SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT 9)
(define SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR  10)

;; ============================================================================
;; Gamepad Button Constants
;; ============================================================================
(define SDL_GAMEPAD_BUTTON_INVALID        -1)
(define SDL_GAMEPAD_BUTTON_SOUTH           0)  ; Bottom face button (A on Xbox, Cross on PlayStation)
(define SDL_GAMEPAD_BUTTON_EAST            1)  ; Right face button (B on Xbox, Circle on PlayStation)
(define SDL_GAMEPAD_BUTTON_WEST            2)  ; Left face button (X on Xbox, Square on PlayStation)
(define SDL_GAMEPAD_BUTTON_NORTH           3)  ; Top face button (Y on Xbox, Triangle on PlayStation)
(define SDL_GAMEPAD_BUTTON_BACK            4)  ; Back button
(define SDL_GAMEPAD_BUTTON_GUIDE           5)  ; Guide button (Xbox logo, PS button)
(define SDL_GAMEPAD_BUTTON_START           6)  ; Start button
(define SDL_GAMEPAD_BUTTON_LEFT_STICK      7)  ; Left stick click
(define SDL_GAMEPAD_BUTTON_RIGHT_STICK     8)  ; Right stick click
(define SDL_GAMEPAD_BUTTON_LEFT_SHOULDER   9)  ; Left bumper/shoulder
(define SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER 10)  ; Right bumper/shoulder
(define SDL_GAMEPAD_BUTTON_DPAD_UP        11)
(define SDL_GAMEPAD_BUTTON_DPAD_DOWN      12)
(define SDL_GAMEPAD_BUTTON_DPAD_LEFT      13)
(define SDL_GAMEPAD_BUTTON_DPAD_RIGHT     14)
(define SDL_GAMEPAD_BUTTON_MISC1          15)  ; Xbox Series X share button, PS5 microphone button
(define SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1  16)  ; Xbox Elite paddle P1 (upper right)
(define SDL_GAMEPAD_BUTTON_LEFT_PADDLE1   17)  ; Xbox Elite paddle P3 (upper left)
(define SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2  18)  ; Xbox Elite paddle P2 (lower right)
(define SDL_GAMEPAD_BUTTON_LEFT_PADDLE2   19)  ; Xbox Elite paddle P4 (lower left)
(define SDL_GAMEPAD_BUTTON_TOUCHPAD       20)  ; PlayStation touchpad button
(define SDL_GAMEPAD_BUTTON_MISC2          21)  ; Additional misc button
(define SDL_GAMEPAD_BUTTON_MISC3          22)  ; Additional misc button
(define SDL_GAMEPAD_BUTTON_MISC4          23)  ; Additional misc button
(define SDL_GAMEPAD_BUTTON_MISC5          24)  ; Additional misc button
(define SDL_GAMEPAD_BUTTON_MISC6          25)  ; Additional misc button
(define SDL_GAMEPAD_BUTTON_COUNT          26)

;; ============================================================================
;; Gamepad Axis Constants
;; ============================================================================
(define SDL_GAMEPAD_AXIS_INVALID       -1)
(define SDL_GAMEPAD_AXIS_LEFTX          0)  ; Left stick X axis
(define SDL_GAMEPAD_AXIS_LEFTY          1)  ; Left stick Y axis
(define SDL_GAMEPAD_AXIS_RIGHTX         2)  ; Right stick X axis
(define SDL_GAMEPAD_AXIS_RIGHTY         3)  ; Right stick Y axis
(define SDL_GAMEPAD_AXIS_LEFT_TRIGGER   4)  ; Left trigger (0 to 32767)
(define SDL_GAMEPAD_AXIS_RIGHT_TRIGGER  5)  ; Right trigger (0 to 32767)
(define SDL_GAMEPAD_AXIS_COUNT          6)

;; ============================================================================
;; Gamepad Button Label Constants
;; ============================================================================
(define SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN  0)
(define SDL_GAMEPAD_BUTTON_LABEL_A        1)  ; Xbox A, Nintendo B
(define SDL_GAMEPAD_BUTTON_LABEL_B        2)  ; Xbox B, Nintendo A
(define SDL_GAMEPAD_BUTTON_LABEL_X        3)  ; Xbox X, Nintendo Y
(define SDL_GAMEPAD_BUTTON_LABEL_Y        4)  ; Xbox Y, Nintendo X
(define SDL_GAMEPAD_BUTTON_LABEL_CROSS    5)  ; PlayStation Cross
(define SDL_GAMEPAD_BUTTON_LABEL_CIRCLE   6)  ; PlayStation Circle
(define SDL_GAMEPAD_BUTTON_LABEL_SQUARE   7)  ; PlayStation Square
(define SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE 8)  ; PlayStation Triangle

;; ============================================================================
;; SDL_ttf Font Style Flags (can be OR'd together)
;; ============================================================================
(define TTF_STYLE_NORMAL        #x00)
(define TTF_STYLE_BOLD          #x01)
(define TTF_STYLE_ITALIC        #x02)
(define TTF_STYLE_UNDERLINE     #x04)
(define TTF_STYLE_STRIKETHROUGH #x08)

;; ============================================================================
;; SDL_ttf Font Hinting Modes
;; ============================================================================
(define TTF_HINTING_INVALID        -1)
(define TTF_HINTING_NORMAL          0)
(define TTF_HINTING_LIGHT           1)
(define TTF_HINTING_MONO            2)
(define TTF_HINTING_NONE            3)
(define TTF_HINTING_LIGHT_SUBPIXEL  4)

;; ============================================================================
;; SDL_ttf Horizontal Alignment for Wrapped Text
;; ============================================================================
(define TTF_HORIZONTAL_ALIGN_INVALID -1)
(define TTF_HORIZONTAL_ALIGN_LEFT     0)
(define TTF_HORIZONTAL_ALIGN_CENTER   1)
(define TTF_HORIZONTAL_ALIGN_RIGHT    2)

;; ============================================================================
;; SDL_ttf Text Direction (values match HarfBuzz)
;; ============================================================================
(define TTF_DIRECTION_INVALID 0)
(define TTF_DIRECTION_LTR     4)  ; Left to Right
(define TTF_DIRECTION_RTL     5)  ; Right to Left
(define TTF_DIRECTION_TTB     6)  ; Top to Bottom
(define TTF_DIRECTION_BTT     7)  ; Bottom to Top

;; ============================================================================
;; SDL_ttf Glyph Image Types
;; ============================================================================
(define TTF_IMAGE_INVALID 0)
(define TTF_IMAGE_ALPHA   1)  ; Color channels are white, alpha has data
(define TTF_IMAGE_COLOR   2)  ; All color channels have data
(define TTF_IMAGE_SDF     3)  ; Alpha has signed distance field

;; ============================================================================
;; SDL_ttf Font Weight Constants
;; ============================================================================
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

;; ============================================================================
;; SDL_ttf Property Names
;; ============================================================================
(define TTF_PROP_FONT_CREATE_FILENAME_STRING            "SDL_ttf.font.create.filename")
(define TTF_PROP_FONT_CREATE_IOSTREAM_POINTER           "SDL_ttf.font.create.iostream")
(define TTF_PROP_FONT_CREATE_IOSTREAM_OFFSET_NUMBER     "SDL_ttf.font.create.iostream.offset")
(define TTF_PROP_FONT_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN "SDL_ttf.font.create.iostream.autoclose")
(define TTF_PROP_FONT_CREATE_SIZE_FLOAT                 "SDL_ttf.font.create.size")
(define TTF_PROP_FONT_CREATE_FACE_NUMBER                "SDL_ttf.font.create.face")
(define TTF_PROP_FONT_CREATE_HORIZONTAL_DPI_NUMBER      "SDL_ttf.font.create.hdpi")
(define TTF_PROP_FONT_CREATE_VERTICAL_DPI_NUMBER        "SDL_ttf.font.create.vdpi")
(define TTF_PROP_FONT_CREATE_EXISTING_FONT              "SDL_ttf.font.create.existing_font")

(define TTF_PROP_FONT_OUTLINE_LINE_CAP_NUMBER           "SDL_ttf.font.outline.line_cap")
(define TTF_PROP_FONT_OUTLINE_LINE_JOIN_NUMBER          "SDL_ttf.font.outline.line_join")
(define TTF_PROP_FONT_OUTLINE_MITER_LIMIT_NUMBER        "SDL_ttf.font.outline.miter_limit")

(define TTF_PROP_RENDERER_TEXT_ENGINE_RENDERER           "SDL_ttf.renderer_text_engine.create.renderer")
(define TTF_PROP_RENDERER_TEXT_ENGINE_ATLAS_TEXTURE_SIZE "SDL_ttf.renderer_text_engine.create.atlas_texture_size")

(define TTF_PROP_GPU_TEXT_ENGINE_DEVICE             "SDL_ttf.gpu_text_engine.create.device")
(define TTF_PROP_GPU_TEXT_ENGINE_ATLAS_TEXTURE_SIZE "SDL_ttf.gpu_text_engine.create.atlas_texture_size")

;; ============================================================================
;; SDL_ttf Substring Flags
;; ============================================================================
(define TTF_SUBSTRING_DIRECTION_MASK #x000000FF)
(define TTF_SUBSTRING_TEXT_START     #x00000100)
(define TTF_SUBSTRING_LINE_START     #x00000200)
(define TTF_SUBSTRING_LINE_END       #x00000400)
(define TTF_SUBSTRING_TEXT_END       #x00000800)

;; ============================================================================
;; SDL_ttf GPU Text Engine Winding
;; ============================================================================
(define TTF_GPU_TEXTENGINE_WINDING_INVALID          -1)
(define TTF_GPU_TEXTENGINE_WINDING_CLOCKWISE         0)
(define TTF_GPU_TEXTENGINE_WINDING_COUNTER_CLOCKWISE 1)

;; ============================================================================
;; Touch Event Constants
;; ============================================================================
(define SDL_EVENT_FINGER_DOWN     #x700)
(define SDL_EVENT_FINGER_UP       #x701)
(define SDL_EVENT_FINGER_MOTION   #x702)
(define SDL_EVENT_FINGER_CANCELED #x703)

;; ============================================================================
;; Pen Event Constants
;; ============================================================================
(define SDL_EVENT_PEN_PROXIMITY_IN  #x1300)
(define SDL_EVENT_PEN_PROXIMITY_OUT #x1301)
(define SDL_EVENT_PEN_DOWN          #x1302)
(define SDL_EVENT_PEN_UP            #x1303)
(define SDL_EVENT_PEN_BUTTON_DOWN   #x1304)
(define SDL_EVENT_PEN_BUTTON_UP     #x1305)
(define SDL_EVENT_PEN_MOTION        #x1306)
(define SDL_EVENT_PEN_AXIS          #x1307)

;; ============================================================================
;; Pen Input Flags (SDL_PenInputFlags)
;; ============================================================================
(define SDL_PEN_INPUT_DOWN       (arithmetic-shift 1 0))  ; pen is pressed down
(define SDL_PEN_INPUT_BUTTON_1   (arithmetic-shift 1 1))  ; button 1 is pressed
(define SDL_PEN_INPUT_BUTTON_2   (arithmetic-shift 1 2))  ; button 2 is pressed
(define SDL_PEN_INPUT_BUTTON_3   (arithmetic-shift 1 3))  ; button 3 is pressed
(define SDL_PEN_INPUT_BUTTON_4   (arithmetic-shift 1 4))  ; button 4 is pressed
(define SDL_PEN_INPUT_BUTTON_5   (arithmetic-shift 1 5))  ; button 5 is pressed
(define SDL_PEN_INPUT_ERASER_TIP (arithmetic-shift 1 30)) ; eraser tip is used

;; ============================================================================
;; Pen Axis Constants (SDL_PenAxis)
;; ============================================================================
(define SDL_PEN_AXIS_PRESSURE             0)  ; Pen pressure (0 to 1.0)
(define SDL_PEN_AXIS_XTILT                1)  ; Horizontal tilt angle (-90 to 90 degrees)
(define SDL_PEN_AXIS_YTILT                2)  ; Vertical tilt angle (-90 to 90 degrees)
(define SDL_PEN_AXIS_DISTANCE             3)  ; Distance to surface (0 to 1.0)
(define SDL_PEN_AXIS_ROTATION             4)  ; Barrel rotation (-180 to 179.9 degrees)
(define SDL_PEN_AXIS_SLIDER               5)  ; Finger wheel/slider (0 to 1.0)
(define SDL_PEN_AXIS_TANGENTIAL_PRESSURE  6)  ; Barrel pressure (squeeze)
(define SDL_PEN_AXIS_COUNT                7)  ; Number of known axis types

;; ============================================================================
;; Touch Device Type Constants
;; ============================================================================
(define SDL_TOUCH_DEVICE_INVALID          -1)
(define SDL_TOUCH_DEVICE_DIRECT            0)  ; touch screen with window-relative coords
(define SDL_TOUCH_DEVICE_INDIRECT_ABSOLUTE 1)  ; trackpad with absolute device coords
(define SDL_TOUCH_DEVICE_INDIRECT_RELATIVE 2)  ; trackpad with screen cursor-relative coords

;; ============================================================================
;; OpenGL Attributes (SDL_GLAttr)
;; ============================================================================
(define SDL_GL_RED_SIZE                    0)
(define SDL_GL_GREEN_SIZE                  1)
(define SDL_GL_BLUE_SIZE                   2)
(define SDL_GL_ALPHA_SIZE                  3)
(define SDL_GL_BUFFER_SIZE                 4)
(define SDL_GL_DOUBLEBUFFER                5)
(define SDL_GL_DEPTH_SIZE                  6)
(define SDL_GL_STENCIL_SIZE                7)
(define SDL_GL_ACCUM_RED_SIZE              8)
(define SDL_GL_ACCUM_GREEN_SIZE            9)
(define SDL_GL_ACCUM_BLUE_SIZE             10)
(define SDL_GL_ACCUM_ALPHA_SIZE            11)
(define SDL_GL_STEREO                      12)
(define SDL_GL_MULTISAMPLEBUFFERS          13)
(define SDL_GL_MULTISAMPLESAMPLES          14)
(define SDL_GL_ACCELERATED_VISUAL          15)
(define SDL_GL_RETAINED_BACKING            16)
(define SDL_GL_CONTEXT_MAJOR_VERSION       17)
(define SDL_GL_CONTEXT_MINOR_VERSION       18)
(define SDL_GL_CONTEXT_FLAGS               19)
(define SDL_GL_CONTEXT_PROFILE_MASK        20)
(define SDL_GL_SHARE_WITH_CURRENT_CONTEXT  21)
(define SDL_GL_FRAMEBUFFER_SRGB_CAPABLE    22)
(define SDL_GL_CONTEXT_RELEASE_BEHAVIOR    23)
(define SDL_GL_CONTEXT_RESET_NOTIFICATION  24)
(define SDL_GL_CONTEXT_NO_ERROR            25)
(define SDL_GL_FLOATBUFFERS                26)
(define SDL_GL_EGL_PLATFORM                27)

;; ============================================================================
;; OpenGL Context Profile Flags (SDL_GLprofile)
;; ============================================================================
(define SDL_GL_CONTEXT_PROFILE_CORE           #x0001)
(define SDL_GL_CONTEXT_PROFILE_COMPATIBILITY  #x0002)
(define SDL_GL_CONTEXT_PROFILE_ES             #x0004)

;; ============================================================================
;; OpenGL Context Flags (SDL_GLcontextFlag)
;; ============================================================================
(define SDL_GL_CONTEXT_DEBUG_FLAG              #x0001)
(define SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG #x0002)
(define SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG      #x0004)
(define SDL_GL_CONTEXT_RESET_ISOLATION_FLAG    #x0008)

;; ============================================================================
;; GPU Primitive Types
;; ============================================================================
(define SDL_GPU_PRIMITIVETYPE_TRIANGLELIST  0)
(define SDL_GPU_PRIMITIVETYPE_TRIANGLESTRIP 1)
(define SDL_GPU_PRIMITIVETYPE_LINELIST      2)
(define SDL_GPU_PRIMITIVETYPE_LINESTRIP     3)
(define SDL_GPU_PRIMITIVETYPE_POINTLIST     4)

;; ============================================================================
;; GPU Load Operations
;; ============================================================================
(define SDL_GPU_LOADOP_LOAD      0)
(define SDL_GPU_LOADOP_CLEAR     1)
(define SDL_GPU_LOADOP_DONT_CARE 2)

;; ============================================================================
;; GPU Store Operations
;; ============================================================================
(define SDL_GPU_STOREOP_STORE             0)
(define SDL_GPU_STOREOP_DONT_CARE         1)
(define SDL_GPU_STOREOP_RESOLVE           2)
(define SDL_GPU_STOREOP_RESOLVE_AND_STORE 3)

;; ============================================================================
;; GPU Index Element Size
;; ============================================================================
(define SDL_GPU_INDEXELEMENTSIZE_16BIT 0)
(define SDL_GPU_INDEXELEMENTSIZE_32BIT 1)

;; ============================================================================
;; GPU Texture Formats (subset of most commonly used)
;; ============================================================================
(define SDL_GPU_TEXTUREFORMAT_INVALID               0)
(define SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM        4)
(define SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM       12)
(define SDL_GPU_TEXTUREFORMAT_R8_UNORM              2)
(define SDL_GPU_TEXTUREFORMAT_R8G8_UNORM            3)
(define SDL_GPU_TEXTUREFORMAT_R16G16B16A16_FLOAT   29)
(define SDL_GPU_TEXTUREFORMAT_R32G32B32A32_FLOAT   32)
(define SDL_GPU_TEXTUREFORMAT_R8G8B8A8_UNORM_SRGB  51)
(define SDL_GPU_TEXTUREFORMAT_B8G8R8A8_UNORM_SRGB  52)
(define SDL_GPU_TEXTUREFORMAT_D16_UNORM            59)
(define SDL_GPU_TEXTUREFORMAT_D24_UNORM            60)
(define SDL_GPU_TEXTUREFORMAT_D32_FLOAT            61)
(define SDL_GPU_TEXTUREFORMAT_D24_UNORM_S8_UINT    62)
(define SDL_GPU_TEXTUREFORMAT_D32_FLOAT_S8_UINT    63)

;; ============================================================================
;; GPU Texture Usage Flags
;; ============================================================================
(define SDL_GPU_TEXTUREUSAGE_SAMPLER                                  (arithmetic-shift 1 0))
(define SDL_GPU_TEXTUREUSAGE_COLOR_TARGET                             (arithmetic-shift 1 1))
(define SDL_GPU_TEXTUREUSAGE_DEPTH_STENCIL_TARGET                     (arithmetic-shift 1 2))
(define SDL_GPU_TEXTUREUSAGE_GRAPHICS_STORAGE_READ                    (arithmetic-shift 1 3))
(define SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_READ                     (arithmetic-shift 1 4))
(define SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_WRITE                    (arithmetic-shift 1 5))
(define SDL_GPU_TEXTUREUSAGE_COMPUTE_STORAGE_SIMULTANEOUS_READ_WRITE  (arithmetic-shift 1 6))

;; ============================================================================
;; GPU Texture Types
;; ============================================================================
(define SDL_GPU_TEXTURETYPE_2D         0)
(define SDL_GPU_TEXTURETYPE_2D_ARRAY   1)
(define SDL_GPU_TEXTURETYPE_3D         2)
(define SDL_GPU_TEXTURETYPE_CUBE       3)
(define SDL_GPU_TEXTURETYPE_CUBE_ARRAY 4)

;; ============================================================================
;; GPU Sample Count
;; ============================================================================
(define SDL_GPU_SAMPLECOUNT_1 0)
(define SDL_GPU_SAMPLECOUNT_2 1)
(define SDL_GPU_SAMPLECOUNT_4 2)
(define SDL_GPU_SAMPLECOUNT_8 3)

;; ============================================================================
;; GPU Buffer Usage Flags
;; ============================================================================
(define SDL_GPU_BUFFERUSAGE_VERTEX                (arithmetic-shift 1 0))
(define SDL_GPU_BUFFERUSAGE_INDEX                 (arithmetic-shift 1 1))
(define SDL_GPU_BUFFERUSAGE_INDIRECT              (arithmetic-shift 1 2))
(define SDL_GPU_BUFFERUSAGE_GRAPHICS_STORAGE_READ (arithmetic-shift 1 3))
(define SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_READ  (arithmetic-shift 1 4))
(define SDL_GPU_BUFFERUSAGE_COMPUTE_STORAGE_WRITE (arithmetic-shift 1 5))

;; ============================================================================
;; GPU Transfer Buffer Usage
;; ============================================================================
(define SDL_GPU_TRANSFERBUFFERUSAGE_UPLOAD   0)
(define SDL_GPU_TRANSFERBUFFERUSAGE_DOWNLOAD 1)

;; ============================================================================
;; GPU Shader Stage
;; ============================================================================
(define SDL_GPU_SHADERSTAGE_VERTEX   0)
(define SDL_GPU_SHADERSTAGE_FRAGMENT 1)

;; ============================================================================
;; GPU Shader Format
;; ============================================================================
(define SDL_GPU_SHADERFORMAT_INVALID  0)
(define SDL_GPU_SHADERFORMAT_PRIVATE  (arithmetic-shift 1 0))
(define SDL_GPU_SHADERFORMAT_SPIRV    (arithmetic-shift 1 1))
(define SDL_GPU_SHADERFORMAT_DXBC     (arithmetic-shift 1 2))
(define SDL_GPU_SHADERFORMAT_DXIL     (arithmetic-shift 1 3))
(define SDL_GPU_SHADERFORMAT_MSL      (arithmetic-shift 1 4))
(define SDL_GPU_SHADERFORMAT_METALLIB (arithmetic-shift 1 5))

;; ============================================================================
;; GPU Vertex Element Formats
;; ============================================================================
(define SDL_GPU_VERTEXELEMENTFORMAT_INVALID       0)
(define SDL_GPU_VERTEXELEMENTFORMAT_INT           1)
(define SDL_GPU_VERTEXELEMENTFORMAT_INT2          2)
(define SDL_GPU_VERTEXELEMENTFORMAT_INT3          3)
(define SDL_GPU_VERTEXELEMENTFORMAT_INT4          4)
(define SDL_GPU_VERTEXELEMENTFORMAT_UINT          5)
(define SDL_GPU_VERTEXELEMENTFORMAT_UINT2         6)
(define SDL_GPU_VERTEXELEMENTFORMAT_UINT3         7)
(define SDL_GPU_VERTEXELEMENTFORMAT_UINT4         8)
(define SDL_GPU_VERTEXELEMENTFORMAT_FLOAT         9)
(define SDL_GPU_VERTEXELEMENTFORMAT_FLOAT2       10)
(define SDL_GPU_VERTEXELEMENTFORMAT_FLOAT3       11)
(define SDL_GPU_VERTEXELEMENTFORMAT_FLOAT4       12)
(define SDL_GPU_VERTEXELEMENTFORMAT_BYTE2        13)
(define SDL_GPU_VERTEXELEMENTFORMAT_BYTE4        14)
(define SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2       15)
(define SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4       16)
(define SDL_GPU_VERTEXELEMENTFORMAT_BYTE2_NORM   17)
(define SDL_GPU_VERTEXELEMENTFORMAT_BYTE4_NORM   18)
(define SDL_GPU_VERTEXELEMENTFORMAT_UBYTE2_NORM  19)
(define SDL_GPU_VERTEXELEMENTFORMAT_UBYTE4_NORM  20)
(define SDL_GPU_VERTEXELEMENTFORMAT_SHORT2       21)
(define SDL_GPU_VERTEXELEMENTFORMAT_SHORT4       22)
(define SDL_GPU_VERTEXELEMENTFORMAT_USHORT2      23)
(define SDL_GPU_VERTEXELEMENTFORMAT_USHORT4      24)
(define SDL_GPU_VERTEXELEMENTFORMAT_SHORT2_NORM  25)
(define SDL_GPU_VERTEXELEMENTFORMAT_SHORT4_NORM  26)
(define SDL_GPU_VERTEXELEMENTFORMAT_USHORT2_NORM 27)
(define SDL_GPU_VERTEXELEMENTFORMAT_USHORT4_NORM 28)
(define SDL_GPU_VERTEXELEMENTFORMAT_HALF2        29)
(define SDL_GPU_VERTEXELEMENTFORMAT_HALF4        30)

;; ============================================================================
;; GPU Vertex Input Rate
;; ============================================================================
(define SDL_GPU_VERTEXINPUTRATE_VERTEX   0)
(define SDL_GPU_VERTEXINPUTRATE_INSTANCE 1)

;; ============================================================================
;; GPU Fill Mode
;; ============================================================================
(define SDL_GPU_FILLMODE_FILL 0)
(define SDL_GPU_FILLMODE_LINE 1)

;; ============================================================================
;; GPU Cull Mode
;; ============================================================================
(define SDL_GPU_CULLMODE_NONE  0)
(define SDL_GPU_CULLMODE_FRONT 1)
(define SDL_GPU_CULLMODE_BACK  2)

;; ============================================================================
;; GPU Front Face
;; ============================================================================
(define SDL_GPU_FRONTFACE_COUNTER_CLOCKWISE 0)
(define SDL_GPU_FRONTFACE_CLOCKWISE         1)

;; ============================================================================
;; GPU Compare Op
;; ============================================================================
(define SDL_GPU_COMPAREOP_INVALID          0)
(define SDL_GPU_COMPAREOP_NEVER            1)
(define SDL_GPU_COMPAREOP_LESS             2)
(define SDL_GPU_COMPAREOP_EQUAL            3)
(define SDL_GPU_COMPAREOP_LESS_OR_EQUAL    4)
(define SDL_GPU_COMPAREOP_GREATER          5)
(define SDL_GPU_COMPAREOP_NOT_EQUAL        6)
(define SDL_GPU_COMPAREOP_GREATER_OR_EQUAL 7)
(define SDL_GPU_COMPAREOP_ALWAYS           8)

;; ============================================================================
;; GPU Stencil Op
;; ============================================================================
(define SDL_GPU_STENCILOP_INVALID             0)
(define SDL_GPU_STENCILOP_KEEP                1)
(define SDL_GPU_STENCILOP_ZERO                2)
(define SDL_GPU_STENCILOP_REPLACE             3)
(define SDL_GPU_STENCILOP_INCREMENT_AND_CLAMP 4)
(define SDL_GPU_STENCILOP_DECREMENT_AND_CLAMP 5)
(define SDL_GPU_STENCILOP_INVERT              6)
(define SDL_GPU_STENCILOP_INCREMENT_AND_WRAP  7)
(define SDL_GPU_STENCILOP_DECREMENT_AND_WRAP  8)

;; ============================================================================
;; GPU Blend Op
;; ============================================================================
(define SDL_GPU_BLENDOP_INVALID          0)
(define SDL_GPU_BLENDOP_ADD              1)
(define SDL_GPU_BLENDOP_SUBTRACT         2)
(define SDL_GPU_BLENDOP_REVERSE_SUBTRACT 3)
(define SDL_GPU_BLENDOP_MIN              4)
(define SDL_GPU_BLENDOP_MAX              5)

;; ============================================================================
;; GPU Blend Factor
;; ============================================================================
(define SDL_GPU_BLENDFACTOR_INVALID                  0)
(define SDL_GPU_BLENDFACTOR_ZERO                     1)
(define SDL_GPU_BLENDFACTOR_ONE                      2)
(define SDL_GPU_BLENDFACTOR_SRC_COLOR                3)
(define SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_COLOR      4)
(define SDL_GPU_BLENDFACTOR_DST_COLOR                5)
(define SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_COLOR      6)
(define SDL_GPU_BLENDFACTOR_SRC_ALPHA                7)
(define SDL_GPU_BLENDFACTOR_ONE_MINUS_SRC_ALPHA      8)
(define SDL_GPU_BLENDFACTOR_DST_ALPHA                9)
(define SDL_GPU_BLENDFACTOR_ONE_MINUS_DST_ALPHA     10)
(define SDL_GPU_BLENDFACTOR_CONSTANT_COLOR          11)
(define SDL_GPU_BLENDFACTOR_ONE_MINUS_CONSTANT_COLOR 12)
(define SDL_GPU_BLENDFACTOR_SRC_ALPHA_SATURATE      13)

;; ============================================================================
;; GPU Color Component Flags
;; ============================================================================
(define SDL_GPU_COLORCOMPONENT_R (arithmetic-shift 1 0))
(define SDL_GPU_COLORCOMPONENT_G (arithmetic-shift 1 1))
(define SDL_GPU_COLORCOMPONENT_B (arithmetic-shift 1 2))
(define SDL_GPU_COLORCOMPONENT_A (arithmetic-shift 1 3))

;; ============================================================================
;; GPU Filter
;; ============================================================================
(define SDL_GPU_FILTER_NEAREST 0)
(define SDL_GPU_FILTER_LINEAR  1)

;; ============================================================================
;; GPU Sampler Mipmap Mode
;; ============================================================================
(define SDL_GPU_SAMPLERMIPMAPMODE_NEAREST 0)
(define SDL_GPU_SAMPLERMIPMAPMODE_LINEAR  1)

;; ============================================================================
;; GPU Sampler Address Mode
;; ============================================================================
(define SDL_GPU_SAMPLERADDRESSMODE_REPEAT          0)
(define SDL_GPU_SAMPLERADDRESSMODE_MIRRORED_REPEAT 1)
(define SDL_GPU_SAMPLERADDRESSMODE_CLAMP_TO_EDGE   2)

;; ============================================================================
;; GPU Present Mode
;; ============================================================================
(define SDL_GPU_PRESENTMODE_VSYNC     0)
(define SDL_GPU_PRESENTMODE_IMMEDIATE 1)
(define SDL_GPU_PRESENTMODE_MAILBOX   2)

;; ============================================================================
;; GPU Swapchain Composition
;; ============================================================================
(define SDL_GPU_SWAPCHAINCOMPOSITION_SDR                 0)
(define SDL_GPU_SWAPCHAINCOMPOSITION_SDR_LINEAR          1)
(define SDL_GPU_SWAPCHAINCOMPOSITION_HDR_EXTENDED_LINEAR 2)
(define SDL_GPU_SWAPCHAINCOMPOSITION_HDR10_ST2084        3)
