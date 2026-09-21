package vinter

import "core:hash"

// Maps named actions to input devices and queries their state.
//
// The input map allows the registration of logical actions (like "jump", "shoot", "punch"), and
// their binding to one or more physical inputs, such as keyboard keys, mouse buttons, mouse wheel
// directions, or gamepad buttons and axes.
//
// The input map provides:
// - Continuous pressed state queries (`is_action_pressed`).
// - Single-frame events (`is_action_just_pressed`, `is_action_just_released`).
// - Action strength queries (`get_action_strength`) for analog inputs like gamepad axes.
//
// Each binding can be device-agnostic (applies to all connected gamepads) or tied to a specific
// device slot. The input map queries all active devices safely, even if some gamepads are
// disconnected.
@(private = "package")
InputMap :: distinct map[ActionID][dynamic]Binding

input_bind :: proc {
	input_bind_key,
	input_bind_mouse_button,
	input_bind_mouse_wheel,
	input_bind_gamepads_button,
	input_bind_gamepads_axis,
	input_bind_gamepad_button,
	input_bind_gamepad_axis,
}

input_bind_key :: proc(action_name: string, key: Key) {
	append(&app.input[to_action_id(action_name)], Binding{input_method = key})
}

input_bind_mouse_button :: proc(action_name: string, mouse_button: MouseButton) {
	append(&app.input[to_action_id(action_name)], Binding{input_method = mouse_button})
}

input_bind_mouse_wheel :: proc(action_name: string, mouse_wheel: MouseWheelDirection) {
	append(&app.input[to_action_id(action_name)], Binding{input_method = mouse_wheel})
}

input_bind_gamepads_button :: proc(action_name: string, gamepad_button: GamepadButton) {
	append(&app.input[to_action_id(action_name)], Binding{input_method = gamepad_button})
}

input_bind_gamepads_axis :: proc(action_name: string, gamepad_axis: GamepadAxis) {
	append(&app.input[to_action_id(action_name)], Binding{input_method = gamepad_axis})
}

input_bind_gamepad_button :: proc(
	action_name: string,
	gamepad_slot: uint,
	gamepad_button: GamepadButton,
) {
	append(&app.input[to_action_id(action_name)], Binding{gamepad_button, gamepad_slot})
}

input_bind_gamepad_axis :: proc(
	action_name: string,
	gamepad_slot: uint,
	gamepad_axis: GamepadAxis,
) {
	append(&app.input[to_action_id(action_name)], Binding{gamepad_axis, gamepad_slot})
}

input_is_action_pressed :: proc(action_name: string) -> bool {
	return query_action_pressed_state(action_name, .Pressed)
}

input_is_action_just_pressed :: proc(action_name: string) -> bool {
	return query_action_pressed_state(action_name, .JustPressed)
}

input_is_action_just_released :: proc(action_name: string) -> bool {
	return query_action_pressed_state(action_name, .JustReleased)
}

input_get_action_strength :: proc(action_name: string) -> f32 {
	if bindings, ok := app.input[to_action_id(action_name)]; ok {
		max_strength: f32 = 0.0
		for &binding in bindings {
			max_strength = max(max_strength, evaluate_binding_strength(&binding))
		}
		return max_strength
	}
	return 0.0
}


// The unique hashed identifier corresponding to an action name.
@(private = "package")
ActionID :: distinct u64

// The type of device-specific input method to bind to a generic input action.
@(private = "package")
InputMethod :: union {
	Key,
	MouseButton,
	MouseWheelDirection,
	GamepadButton,
	GamepadAxis,
}

// Represents a binding of an input method to an action, optionally for a specific gamepad slot.
//
// If the gamepad slot is nullopt, then it corresponds to either a non-gamepad device, or all
// gamepad slots simultaneously.
@(private = "package")
Binding :: struct {
	input_method:          InputMethod,
	optional_gamepad_slot: Maybe(uint),
}

@(private = "package")
PressedState :: enum {
	Pressed,
	JustPressed,
	JustReleased,
}

@(private = "file")
@(require_results)
query_action_pressed_state :: proc(action_name: string, state: PressedState) -> bool {
	if bindings, ok := app.input[to_action_id(action_name)]; ok {
		for &binding in bindings {
			if evaluate_binding_pressed(&binding, state) do return true
		}
	}
	return false
}

@(private = "file")
@(require_results)
to_action_id :: proc(name: string) -> ActionID {
	byte_buffer := transmute([]u8)name
	hash := hash.fnv64a(byte_buffer)

	return ActionID(hash)
}

@(private = "file")
@(require_results)
evaluate_binding_pressed :: proc(binding: ^Binding, state: PressedState) -> bool {
	switch method in binding.input_method {
	case Key:
		return evaluate_key_pressed_state(method, state)
	case MouseButton:
		return evaluate_mouse_button_pressed_state(method, state)
	case MouseWheelDirection:
		return evaluate_mouse_wheel_pressed_state(method, state)
	case GamepadButton:
		return evaluate_gamepad_button_pressed_state(method, binding.optional_gamepad_slot, state)
	case GamepadAxis:
		return evaluate_gamepad_axis_pressed_state(method, binding.optional_gamepad_slot, state)
	}
	return false
}

@(private = "file")
@(require_results)
evaluate_binding_strength :: proc(binding: ^Binding) -> f32 {
	switch method in binding.input_method {
	case Key:
		return 1.0 if keyboard_is_key_pressed(method) else 0.0

	case MouseButton:
		return 1.0 if mouse_is_button_pressed(method) else 0.0

	case MouseWheelDirection:
		return 1.0 if mouse_is_wheel_triggered(method) else 0.0

	case GamepadButton:
		if slot, ok := binding.optional_gamepad_slot.(uint); ok {
			return 1.0 if gamepad_is_button_pressed(slot, method) else 0.0
		}
		max_strength: f32 = 0.0
		for slot in gamepad_get_active_slots() {
			max_strength = max(
				max_strength,
				1.0 if gamepad_is_button_pressed(slot, method) else 0.0,
			)
		}
		return max_strength

	case GamepadAxis:
		if gamepad_slot, ok := binding.optional_gamepad_slot.(uint); ok {
			return gamepad_get_axis_strength(gamepad_slot, method)
		}
		max_strength: f32 = 0.0
		for slot in gamepad_get_active_slots() {
			max_strength = max(max_strength, gamepad_get_axis_strength(slot, method))
		}
		return max_strength
	}
	return 0.0
}

@(private = "file")
@(require_results)
evaluate_key_pressed_state :: proc(key: Key, state: PressedState) -> bool {
	switch state {
	case .Pressed:
		return keyboard_is_key_pressed(key)
	case .JustPressed:
		return keyboard_is_key_just_pressed(key)
	case .JustReleased:
		return keyboard_is_key_released(key)
	}
	return false
}

@(private = "file")
@(require_results)
evaluate_mouse_button_pressed_state :: proc(
	mouse_button: MouseButton,
	state: PressedState,
) -> bool {
	switch state {
	case .Pressed:
		return mouse_is_button_pressed(mouse_button)
	case .JustPressed:
		return mouse_is_button_just_pressed(mouse_button)
	case .JustReleased:
		return mouse_is_button_released(mouse_button)
	}
	return false
}

@(private = "file")
@(require_results)
evaluate_mouse_wheel_pressed_state :: proc(
	mouse_wheel: MouseWheelDirection,
	state: PressedState,
) -> bool {
	switch state {
	case .Pressed:
		return false
	case .JustPressed:
		return mouse_is_wheel_triggered(mouse_wheel)
	case .JustReleased:
		return false
	}
	return false
}

@(private = "file")
@(require_results)
evaluate_gamepad_button_pressed_state :: proc(
	button: GamepadButton,
	optional_gamepad_slot: Maybe(uint),
	state: PressedState,
) -> bool {
	// Check slot specific pressed state.
	if gamepad_slot, ok := optional_gamepad_slot.(uint); ok {
		switch state {
		case .Pressed:
			return gamepad_is_button_pressed(gamepad_slot, button)
		case .JustPressed:
			return gamepad_is_button_just_pressed(gamepad_slot, button)
		case .JustReleased:
			return gamepad_is_button_released(gamepad_slot, button)
		}
	} else  /* Check all gamepads for pressed state. */{
		for gamepad_slot in gamepad_get_active_slots() {
			switch state {
			case .Pressed:
				if gamepad_is_button_pressed(gamepad_slot, button) {
					return true
				}
			case .JustPressed:
				if gamepad_is_button_just_pressed(gamepad_slot, button) {
					return true
				}
			case .JustReleased:
				if gamepad_is_button_released(gamepad_slot, button) {
					return true
				}
			}
		}
	}
	return false
}

@(private = "file")
@(require_results)
evaluate_gamepad_axis_pressed_state :: proc(
	axis: GamepadAxis,
	optional_gamepad_slot: Maybe(uint),
	state: PressedState,
) -> bool {
	// Check slot specific pressed state.
	if gamepad_slot, ok := optional_gamepad_slot.(uint); ok {
		switch state {
		case .Pressed:
			return gamepad_is_axis_pressed(gamepad_slot, axis)
		case .JustPressed:
			return gamepad_is_axis_just_pressed(gamepad_slot, axis)
		case .JustReleased:
			return gamepad_is_axis_released(gamepad_slot, axis)
		}
	} else  /* Check all gamepads for pressed state. */{
		for gamepad_slot in gamepad_get_active_slots() {
			switch state {
			case .Pressed:
				if gamepad_is_axis_pressed(gamepad_slot, axis) {
					return true
				}
			case .JustPressed:
				if gamepad_is_axis_just_pressed(gamepad_slot, axis) {
					return true
				}
			case .JustReleased:
				if gamepad_is_axis_released(gamepad_slot, axis) {
					return true
				}
			}
		}
	}
	return false
}
