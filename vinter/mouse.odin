package vinter

import sdl "vendor:sdl3"

MouseButton :: enum {
	Left,
	Right,
	Middle,
	X1,
	X2,
}

MouseWheelDirection :: enum {
	Up,
	Down,
	Left,
	Right,
}

@(require_results)
mouse_is_button_pressed :: proc(button: MouseButton) -> bool {
	return input_states_is_pressed(&app.devices.mouse.buttons, to_native_mouse_button(button))
}

@(require_results)
mouse_is_button_just_pressed :: proc(button: MouseButton) -> bool {
	return input_states_is_just_pressed(&app.devices.mouse.buttons, to_native_mouse_button(button))
}

@(require_results)
mouse_is_button_released :: proc(button: MouseButton) -> bool {
	return input_states_is_released(&app.devices.mouse.buttons, to_native_mouse_button(button))
}

@(require_results)
mouse_is_wheel_triggered :: proc(wheel_direction: MouseWheelDirection) -> bool {
	switch wheel_direction {
	case .Up:
		return app.devices.mouse.scroll.y > 0
	case .Down:
		return app.devices.mouse.scroll.y < 0
	case .Right:
		return app.devices.mouse.scroll.x > 0
	case .Left:
		return app.devices.mouse.scroll.x < 0
	}
	return false
}

@(require_results)
mouse_get_position :: proc() -> [2]f32 {
	return app.devices.mouse.position
}

@(require_results)
mouse_get_delta :: proc() -> [2]f32 {
	return app.devices.mouse.position - app.devices.mouse.position_previous
}

@(require_results)
mouse_get_scroll :: proc() -> [2]f32 {
	return app.devices.mouse.scroll
}

@(require_results)
mouse_get_scroll_horizontal :: proc() -> f32 {
	return app.devices.mouse.scroll.x
}

@(require_results)
mouse_get_scroll_vertical :: proc() -> f32 {
	return app.devices.mouse.scroll.y
}

@(require_results)
mouse_is_cursor_visible :: proc() -> bool {
	return sdl.CursorVisible()
}

mouse_set_cursor_visible :: proc(visible: bool) {
	if visible do _ = sdl.ShowCursor()
	else do _ = sdl.HideCursor()
}

@(private = "package")
Mouse :: struct {
	buttons:           InputStates(bool, len(MouseButton)),
	position:          [2]f32,
	position_previous: [2]f32,
	scroll:            [2]f32,
}

@(require_results)
@(private = "package")
mouse_create :: proc() -> Mouse {
	return {}
}

@(private = "package")
mouse_handle_events :: proc(event: ^sdl.Event) {
	if event.type == .MOUSE_WHEEL {
		app.devices.mouse.scroll += {event.wheel.x, event.wheel.y}
	}
}

@(private = "package")
mouse_update :: proc() {
	input_states_refresh(&app.devices.mouse.buttons)
	app.devices.mouse.position_previous = app.devices.mouse.position
	app.devices.mouse.scroll = {0.0, 0.0}

	// Sync with SDL state.
	native_buttons := sdl.GetMouseState(
		&app.devices.mouse.position.x,
		&app.devices.mouse.position.y,
	)

	app.devices.mouse.buttons.current[0] = (native_buttons & sdl.BUTTON_LMASK) != {}
	app.devices.mouse.buttons.current[1] = (native_buttons & sdl.BUTTON_RMASK) != {}
	app.devices.mouse.buttons.current[2] = (native_buttons & sdl.BUTTON_MMASK) != {}
	app.devices.mouse.buttons.current[3] = (native_buttons & sdl.BUTTON_X1MASK) != {}
	app.devices.mouse.buttons.current[4] = (native_buttons & sdl.BUTTON_X2MASK) != {}
}

@(private = "file")
@(require_results)
to_native_mouse_button :: proc(button: MouseButton) -> uint {
	return uint(button)
}
