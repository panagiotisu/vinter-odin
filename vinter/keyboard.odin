package vinter

import sdl "vendor:sdl3"

Key :: enum {
	// Function keys
	F1,
	F2,
	F3,
	F4,
	F5,
	F6,
	F7,
	F8,
	F9,
	F10,
	F11,
	F12,

	// Number row
	_1,
	_2,
	_3,
	_4,
	_5,
	_6,
	_7,
	_8,
	_9,
	_0,

	// Letters
	Q,
	W,
	E,
	R,
	T,
	Y,
	U,
	I,
	O,
	P,
	A,
	S,
	D,
	F,
	G,
	H,
	J,
	K,
	L,
	Z,
	X,
	C,
	V,
	B,
	N,
	M,

	// Special keys
	Esc,
	Tab,
	CapsLock,
	Space,
	Enter,
	Backspace,
	Insert,
	Delete,
	Home,
	End,
	PageUp,
	PageDown,

	// Arrow keys
	Up,
	Down,
	Left,
	Right,

	// Symbols/Punctuation
	Minus,
	Equals,
	LeftBracket,
	RightBracket,
	Semicolon,
	Apostrophe,
	Grave,
	Backslash,
	Comma,
	Period,
	Slash,

	// Numpad
	Numpad0,
	Numpad1,
	Numpad2,
	Numpad3,
	Numpad4,
	Numpad5,
	Numpad6,
	Numpad7,
	Numpad8,
	Numpad9,
	NumpadMultiply,
	NumpadDivide,
	NumpadPlus,
	NumpadMinus,
	NumpadEnter,
	NumpadPeriod,
	NumLock,

	// Other
	PrintScreen,
	ScrollLock,
	Pause,
}

@(require_results)
keyboard_is_key_pressed :: proc(key: Key) -> bool {
	return input_states_is_pressed(&app.devices.keyboard.keys, uint(to_native_scancode(key)))
}

@(require_results)
keyboard_is_key_just_pressed :: proc(key: Key) -> bool {
	return input_states_is_just_pressed(&app.devices.keyboard.keys, uint(to_native_scancode(key)))
}

@(require_results)
keyboard_is_key_released :: proc(key: Key) -> bool {
	return input_states_is_released(&app.devices.keyboard.keys, uint(to_native_scancode(key)))
}

@(private = "package")
Keyboard :: struct {
	keys:        InputStates(bool, len(sdl.Scancode)),
	native_keys: [^]bool,
}

@(private = "package")
@(require_results)
keyboard_create :: proc() -> Keyboard {
	return {native_keys = sdl.GetKeyboardState(nil)}
}

@(private = "package")
keyboard_update :: proc() {
	input_states_refresh(&app.devices.keyboard.keys)

	// Sync with SDL state.
	for i in 0 ..< len(sdl.Scancode) {
		app.devices.keyboard.keys.current[i] = app.devices.keyboard.native_keys[i]
	}
}

@(private = "package")
keyboard_handle_events :: proc(event: ^sdl.Event) {
}

@(private = "file")
@(require_results)
to_native_scancode :: proc(key: Key) -> sdl.Scancode {
	switch key {
	case .F1:
		return sdl.Scancode.F1
	case .F2:
		return sdl.Scancode.F2
	case .F3:
		return sdl.Scancode.F3
	case .F4:
		return sdl.Scancode.F4
	case .F5:
		return sdl.Scancode.F5
	case .F6:
		return sdl.Scancode.F6
	case .F7:
		return sdl.Scancode.F7
	case .F8:
		return sdl.Scancode.F8
	case .F9:
		return sdl.Scancode.F9
	case .F10:
		return sdl.Scancode.F10
	case .F11:
		return sdl.Scancode.F11
	case .F12:
		return sdl.Scancode.F12

	case ._1:
		return sdl.Scancode._1
	case ._2:
		return sdl.Scancode._2
	case ._3:
		return sdl.Scancode._3
	case ._4:
		return sdl.Scancode._4
	case ._5:
		return sdl.Scancode._5
	case ._6:
		return sdl.Scancode._6
	case ._7:
		return sdl.Scancode._7
	case ._8:
		return sdl.Scancode._8
	case ._9:
		return sdl.Scancode._9
	case ._0:
		return sdl.Scancode._0

	case .Q:
		return sdl.Scancode.Q
	case .W:
		return sdl.Scancode.W
	case .E:
		return sdl.Scancode.E
	case .R:
		return sdl.Scancode.R
	case .T:
		return sdl.Scancode.T
	case .Y:
		return sdl.Scancode.Y
	case .U:
		return sdl.Scancode.U
	case .I:
		return sdl.Scancode.I
	case .O:
		return sdl.Scancode.O
	case .P:
		return sdl.Scancode.P
	case .A:
		return sdl.Scancode.A
	case .S:
		return sdl.Scancode.S
	case .D:
		return sdl.Scancode.D
	case .F:
		return sdl.Scancode.F
	case .G:
		return sdl.Scancode.G
	case .H:
		return sdl.Scancode.H
	case .J:
		return sdl.Scancode.J
	case .K:
		return sdl.Scancode.K
	case .L:
		return sdl.Scancode.L
	case .Z:
		return sdl.Scancode.Z
	case .X:
		return sdl.Scancode.X
	case .C:
		return sdl.Scancode.C
	case .V:
		return sdl.Scancode.V
	case .B:
		return sdl.Scancode.B
	case .N:
		return sdl.Scancode.N
	case .M:
		return sdl.Scancode.M

	case .Esc:
		return sdl.Scancode.ESCAPE
	case .Tab:
		return sdl.Scancode.TAB
	case .CapsLock:
		return sdl.Scancode.CAPSLOCK
	case .Space:
		return sdl.Scancode.SPACE
	case .Enter:
		return sdl.Scancode.RETURN
	case .Backspace:
		return sdl.Scancode.BACKSPACE
	case .Insert:
		return sdl.Scancode.INSERT
	case .Delete:
		return sdl.Scancode.DELETE
	case .Home:
		return sdl.Scancode.HOME
	case .End:
		return sdl.Scancode.END
	case .PageUp:
		return sdl.Scancode.PAGEUP
	case .PageDown:
		return sdl.Scancode.PAGEDOWN

	case .Up:
		return sdl.Scancode.UP
	case .Down:
		return sdl.Scancode.DOWN
	case .Left:
		return sdl.Scancode.LEFT
	case .Right:
		return sdl.Scancode.RIGHT

	case .Minus:
		return sdl.Scancode.MINUS
	case .Equals:
		return sdl.Scancode.EQUALS
	case .LeftBracket:
		return sdl.Scancode.LEFTBRACKET
	case .RightBracket:
		return sdl.Scancode.RIGHTBRACKET
	case .Semicolon:
		return sdl.Scancode.SEMICOLON
	case .Apostrophe:
		return sdl.Scancode.APOSTROPHE
	case .Grave:
		return sdl.Scancode.GRAVE
	case .Backslash:
		return sdl.Scancode.BACKSLASH
	case .Comma:
		return sdl.Scancode.COMMA
	case .Period:
		return sdl.Scancode.PERIOD
	case .Slash:
		return sdl.Scancode.SLASH

	case .Numpad0:
		return sdl.Scancode.KP_0
	case .Numpad1:
		return sdl.Scancode.KP_1
	case .Numpad2:
		return sdl.Scancode.KP_2
	case .Numpad3:
		return sdl.Scancode.KP_3
	case .Numpad4:
		return sdl.Scancode.KP_4
	case .Numpad5:
		return sdl.Scancode.KP_5
	case .Numpad6:
		return sdl.Scancode.KP_6
	case .Numpad7:
		return sdl.Scancode.KP_7
	case .Numpad8:
		return sdl.Scancode.KP_8
	case .Numpad9:
		return sdl.Scancode.KP_9
	case .NumpadMultiply:
		return sdl.Scancode.KP_MULTIPLY
	case .NumpadDivide:
		return sdl.Scancode.KP_DIVIDE
	case .NumpadPlus:
		return sdl.Scancode.KP_PLUS
	case .NumpadMinus:
		return sdl.Scancode.KP_MINUS
	case .NumpadEnter:
		return sdl.Scancode.KP_ENTER
	case .NumpadPeriod:
		return sdl.Scancode.KP_PERIOD
	case .NumLock:
		return sdl.Scancode.NUMLOCKCLEAR

	case .PrintScreen:
		return sdl.Scancode.PRINTSCREEN
	case .ScrollLock:
		return sdl.Scancode.SCROLLLOCK
	case .Pause:
		return sdl.Scancode.PAUSE

	case:
		return sdl.Scancode.UNKNOWN
	}
}
