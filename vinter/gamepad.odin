package vinter

import "core:c"
import "core:log"
import "core:math"
import "core:strings"
import sdl "vendor:sdl3"

GamepadButton :: enum {
	South,
	East,
	West,
	North,
	Back,
	Guide,
	Start,
	LeftStick,
	RightStick,
	LeftShoulder,
	RightShoulder,
	DpadUp,
	DpadDown,
	DpadLeft,
	DpadRight,
	RightPaddle1,
	LeftPaddle1,
	RightPaddle2,
	LeftPaddle2,
	Touchpad,
	Misc1, /* Additional button (e.g. Xbox Series X share button, PS5 microphone button,
                      Nintendo Switch Pro capture button, Amazon Luna microphone button, Google
                      Stadia capture button). */
	Misc2,
	Misc3, // Additional button (e.g. Nintendo GameCube left trigger click).
	Misc4, // Additional button (e.g. Nintendo GameCube right trigger click).
	Misc5,
	Misc6,
}

GamepadAxis :: enum {
	LeftStickLeft,
	LeftStickRight,
	LeftStickUp,
	LeftStickDown,
	RightStickLeft,
	RightStickRight,
	RightStickUp,
	RightStickDown,
	LeftTrigger,
	RightTrigger,
}

GamepadButtonLabel :: enum {
	Unknown,
	A,
	B,
	X,
	Y,
	Cross,
	Circle,
	Square,
	Triangle,
}

GamepadType :: enum {
	Unknown,
	Standard,
	Xbox360,
	XboxOne,
	Ps3,
	Ps4,
	Ps5,
	Switch,
	JoyconLeft,
	JoyconRight,
	JoyconPair,
	// GameCube,
}

@(require_results)
gamepad_get_id :: proc(gamepad: ^Gamepad) -> uint {
	return uint(sdl.GetGamepadID(gamepad.handle))
}

@(require_results)
gamepad_get_guid_string :: proc(slot: uint) -> string {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return {}
	}
	joy := sdl.GetGamepadJoystick(gamepad.handle)
	if joy == nil {
		return {}
	}

	guid := sdl.GetJoystickGUID(joy)
	buffer: [33]u8 = {}
	sdl.GUIDToString(guid, cast([^]c.char)rawptr(&buffer), len(buffer))

	n := 0
	for n < len(buffer) && buffer[n] != 0 {
		n += 1
	}
	return string(buffer[:n])
}

@(require_results)
gamepad_get_type :: proc(slot: uint) -> GamepadType {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return .Unknown
	}

	native_type := sdl.GetGamepadType(gamepad.handle)
	switch native_type {
	case .STANDARD:
		return .Standard
	case .XBOX360:
		return .Xbox360
	case .XBOXONE:
		return .XboxOne
	case .PS3:
		return .Ps3
	case .PS4:
		return .Ps4
	case .PS5:
		return .Ps5
	case .NINTENDO_SWITCH_PRO:
		return .Switch
	case .NINTENDO_SWITCH_JOYCON_LEFT:
		return .JoyconLeft
	case .NINTENDO_SWITCH_JOYCON_RIGHT:
		return .JoyconRight
	case .NINTENDO_SWITCH_JOYCON_PAIR:
		return .JoyconPair
	case .UNKNOWN:
		return .Unknown
	}
	return .Standard
}

@(require_results)
gamepad_get_button_label :: proc(slot: uint, button: GamepadButton) -> GamepadButtonLabel {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return .Unknown
	}

	native_label := sdl.GetGamepadButtonLabel(gamepad.handle, to_sdl_gamepad_button(button))
	switch native_label {
	case .A:
		return .A
	case .B:
		return .B
	case .X:
		return .X
	case .Y:
		return .Y
	case .CROSS:
		return .Cross
	case .CIRCLE:
		return .Circle
	case .SQUARE:
		return .Square
	case .TRIANGLE:
		return .Triangle
	case .UNKNOWN:
		return .Unknown
	}
	return .Unknown
}

@(require_results)
gamepad_is_button_pressed :: proc(slot: uint, button: GamepadButton) -> bool {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return false
	}
	return input_states_is_pressed(&gamepad.buttons, uint(to_sdl_gamepad_button(button)))
}

@(require_results)
gamepad_is_button_just_pressed :: proc(slot: uint, button: GamepadButton) -> bool {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return false
	}
	return input_states_is_just_pressed(&gamepad.buttons, uint(to_sdl_gamepad_button(button)))
}

@(require_results)
gamepad_is_button_released :: proc(slot: uint, button: GamepadButton) -> bool {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return false
	}
	return input_states_is_released(&gamepad.buttons, uint(to_sdl_gamepad_button(button)))
}

@(require_results)
gamepad_is_axis_pressed :: proc(slot: uint, axis: GamepadAxis) -> bool {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return false
	}
	return input_states_is_pressed(&gamepad.axes, uint(axis))
}

@(require_results)
gamepad_is_axis_just_pressed :: proc(slot: uint, axis: GamepadAxis) -> bool {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return false
	}
	return input_states_is_just_pressed(&gamepad.axes, uint(axis))
}

@(require_results)
gamepad_is_axis_released :: proc(slot: uint, axis: GamepadAxis) -> bool {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return false
	}
	return input_states_is_released(&gamepad.axes, uint(axis))
}

@(require_results)
gamepad_get_axis_strength :: proc(slot: uint, axis: GamepadAxis) -> f32 {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return 0.0
	}
	return gamepad.axes.current[uint(axis)]
}

@(require_results)
gamepad_get_name :: proc(slot: uint) -> string {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return {}
	}
	name := sdl.GetGamepadName(gamepad.handle)
	if name == nil {
		return {}
	}
	return strings.clone_from_cstring(name)
}

gamepad_begin_vibrate :: proc(
	slot: uint,
	weak_percent_magnitude: f32,
	strong_percent_magnitude: f32,
	duration_sec: f32,
) {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return
	}

	MaxMotorMagnitude: u16 : 0xFFFF
	weak_magnitude := u16(clamp(weak_percent_magnitude, 0.0, 1.0)) * MaxMotorMagnitude
	strong_magnitude := u16(clamp(strong_percent_magnitude, 0.0, 1.0)) * MaxMotorMagnitude
	duration_ms := u32(duration_sec * 1000)

	sdl.RumbleGamepad(gamepad.handle, weak_magnitude, strong_magnitude, duration_ms)
}

gamepad_stop_vibrate :: proc(slot: uint) {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return
	}

	sdl.RumbleGamepad(gamepad.handle, 0, 0, 0)
}

gamepad_set_led_color :: proc(slot: uint, color: Color) {
	gamepad := gamepad_get_by_slot(slot)
	if gamepad == nil {
		return
	}

	rgba8 := color_to_rgba8(color)
	sdl.SetGamepadLED(gamepad.handle, rgba8.r, rgba8.g, rgba8.b)
}

@(private = "package")
Gamepad :: struct {
	handle:           ^sdl.Gamepad,
	buttons:          InputStates(bool, len(sdl.GamepadButton)),
	axes:             InputStates(f32, len(GamepadAxis)),
	native_axes:      InputStates(f32, len(sdl.GamepadAxis)),
	stick_deadzone:   f32,
	trigger_deadzone: f32,
}

@(private = "package")
@(require_results)
gamepad_create :: proc(id: uint) -> Gamepad {
	gamepad := Gamepad {
		handle           = sdl.OpenGamepad(sdl.JoystickID(id)),
		// TODO: Make deadzones configurable through settings.
		stick_deadzone   = 0.1,
		trigger_deadzone = 0.05,
	}
	log.assertf(gamepad.handle != nil, "Failed to open SDL gamepad with id %v", id)
	return gamepad
}

@(private = "package")
gamepad_destroy :: proc(gamepad: Gamepad) {
	if gamepad.handle != nil {
		sdl.CloseGamepad(gamepad.handle)
	}
}

@(private = "package")
gamepad_handle_events :: proc(gamepad: ^Gamepad, event: ^sdl.Event) {
}

@(private = "package")
gamepad_update :: proc(gamepad: ^Gamepad) {
	input_states_refresh(&gamepad.buttons)
	input_states_refresh(&gamepad.axes)
	input_states_refresh(&gamepad.native_axes)

	// Synchronize buttons with SDL buttons.
	for i in 0 ..< len(sdl.GamepadButton) {
		gamepad.buttons.current[i] = sdl.GetGamepadButton(gamepad.handle, sdl.GamepadButton(i))
	}

	// Normalize and store SDL axes.
	for i in 0 ..< len(sdl.GamepadAxis) {
		gamepad.native_axes.current[i] = normalize_axis(
			f32(sdl.GetGamepadAxis(gamepad.handle, sdl.GamepadAxis(i))),
		)
	}

	// Deadzone SDL axes.
	gamepad.native_axes.current[sdl.GamepadAxis.LEFTX], gamepad.native_axes.current[sdl.GamepadAxis.LEFTY] =
		deadzone_stick(
			gamepad.native_axes.current[sdl.GamepadAxis.LEFTX],
			gamepad.native_axes.current[sdl.GamepadAxis.LEFTY],
			gamepad.stick_deadzone,
		)
	gamepad.native_axes.current[sdl.GamepadAxis.RIGHTX], gamepad.native_axes.current[sdl.GamepadAxis.RIGHTY] =
		deadzone_stick(
			gamepad.native_axes.current[sdl.GamepadAxis.RIGHTX],
			gamepad.native_axes.current[sdl.GamepadAxis.RIGHTY],
			gamepad.stick_deadzone,
		)
	gamepad.native_axes.current[sdl.GamepadAxis.LEFT_TRIGGER] = deadzone_trigger(
		gamepad.native_axes.current[sdl.GamepadAxis.LEFT_TRIGGER],
		gamepad.trigger_deadzone,
	)
	gamepad.native_axes.current[sdl.GamepadAxis.RIGHT_TRIGGER] = deadzone_trigger(
		gamepad.native_axes.current[sdl.GamepadAxis.RIGHT_TRIGGER],
		gamepad.trigger_deadzone,
	)

	remap_sdl_to_gamepad_axes(gamepad)
}

@(private = "package")
@(require_results)
gamepad_get_by_id :: proc(id: uint) -> ^Gamepad {
	gamepad, ok := &app.devices.gamepads[id]
	if (!ok) {
		return nil
	}
	return gamepad
}

@(private = "package")
@(require_results)
gamepad_get_by_slot :: proc(slot: uint) -> ^Gamepad {
	log.assertf(
		slot < MaxGamepadCount,
		"Requested out of range gamepad slot %v / %v",
		slot,
		MaxGamepadCount,
	)

	optional_id := app.devices.gamepad_slots[slot]
	if optional_id == nil {
		return nil
	}
	return gamepad_get_by_id(optional_id.(uint))
}

@(private = "package")
@(require_results)
gamepad_get_active_slots :: proc() -> [dynamic]uint {
	result: [dynamic]uint
	reserve(&result, MaxGamepadCount)

	for id in app.devices.gamepad_slots {
		if id != nil {
			append(&result, id.(uint))
		}
	}

	return result
}

@(private = "file")
@(require_results)
normalize_axis :: proc(axis: f32) -> f32 {
	if axis < 0 {
		return -axis / sdl.JOYSTICK_AXIS_MIN
	}
	return axis / sdl.JOYSTICK_AXIS_MAX
}

@(private = "file")
@(require_results)
deadzone_trigger :: proc(trigger: f32, deadzone: f32) -> f32 {
	if trigger < deadzone {
		return 0.0
	}
	return (trigger - deadzone) / (1.0 - deadzone)
}

@(private = "file")
@(require_results)
deadzone_stick :: proc(stick_x: f32, stick_y: f32, deadzone: f32) -> (f32, f32) {
	magnitude_squared := (stick_x * stick_x) + (stick_y * stick_y)
	if magnitude_squared < deadzone * deadzone {
		return 0.0, 0.0
	}
	magnitude := math.sqrt(magnitude_squared)
	magnitude_scaled := (magnitude - deadzone) / (1.0 - deadzone)

	return stick_x * magnitude_scaled / magnitude, stick_y * magnitude_scaled / magnitude
}

@(private = "file")
@(require_results)
to_sdl_gamepad_button :: proc(button: GamepadButton) -> sdl.GamepadButton {
	switch button {
	case .South:
		return .SOUTH
	case .East:
		return .EAST
	case .West:
		return .WEST
	case .North:
		return .NORTH

	case .Back:
		return .BACK
	case .Guide:
		return .GUIDE
	case .Start:
		return .START

	case .LeftStick:
		return .LEFT_STICK
	case .RightStick:
		return .RIGHT_STICK

	case .LeftShoulder:
		return .LEFT_SHOULDER
	case .RightShoulder:
		return .RIGHT_SHOULDER

	case .DpadUp:
		return .DPAD_UP
	case .DpadDown:
		return .DPAD_DOWN
	case .DpadLeft:
		return .DPAD_LEFT
	case .DpadRight:
		return .DPAD_RIGHT

	case .RightPaddle1:
		return .RIGHT_PADDLE1
	case .LeftPaddle1:
		return .LEFT_PADDLE1
	case .RightPaddle2:
		return .RIGHT_PADDLE2
	case .LeftPaddle2:
		return .LEFT_PADDLE2

	case .Touchpad:
		return .TOUCHPAD

	case .Misc1:
		return .MISC1
	case .Misc2:
		return .MISC2
	case .Misc3:
		return .MISC3
	case .Misc4:
		return .MISC4
	case .Misc5:
		return .MISC5
	case .Misc6:
		return .MISC6
	}

	return .INVALID
}

@(private = "file")
remap_sdl_to_gamepad_axes :: proc(gamepad: ^Gamepad) {
	// Split and remap stick axes so that they are always between [0, 1] instead of [-1, 1].
	gamepad.axes.current[uint(GamepadAxis.LeftStickLeft)] = max(
		0.0,
		-gamepad.native_axes.current[sdl.GamepadAxis.LEFTX],
	)
	gamepad.axes.current[uint(GamepadAxis.LeftStickRight)] = max(
		0.0,
		gamepad.native_axes.current[sdl.GamepadAxis.LEFTX],
	)
	gamepad.axes.current[uint(GamepadAxis.LeftStickUp)] = max(
		0.0,
		-gamepad.native_axes.current[sdl.GamepadAxis.LEFTY],
	)
	gamepad.axes.current[uint(GamepadAxis.LeftStickDown)] = max(
		0.0,
		gamepad.native_axes.current[sdl.GamepadAxis.LEFTY],
	)
	gamepad.axes.current[uint(GamepadAxis.RightStickLeft)] = max(
		0.0,
		-gamepad.native_axes.current[sdl.GamepadAxis.RIGHTX],
	)
	gamepad.axes.current[uint(GamepadAxis.RightStickRight)] = max(
		0.0,
		gamepad.native_axes.current[sdl.GamepadAxis.RIGHTX],
	)
	gamepad.axes.current[uint(GamepadAxis.RightStickUp)] = max(
		0.0,
		-gamepad.native_axes.current[sdl.GamepadAxis.RIGHTY],
	)
	gamepad.axes.current[uint(GamepadAxis.RightStickDown)] = max(
		0.0,
		gamepad.native_axes.current[sdl.GamepadAxis.RIGHTY],
	)

	// Trigger axes do not require remapping since they are already between [0, 1].
	gamepad.axes.current[uint(GamepadAxis.LeftTrigger)] =
		gamepad.native_axes.current[sdl.GamepadAxis.LEFT_TRIGGER]
	gamepad.axes.current[uint(GamepadAxis.RightTrigger)] =
		gamepad.native_axes.current[sdl.GamepadAxis.RIGHT_TRIGGER]
}
