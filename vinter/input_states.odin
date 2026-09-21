package vinter

// Represents boolean button states or float axis states.
@(private = "package")
InputStates :: struct(T: typeid, N: uint) {
	current, previous: [N]T,
}

@(private = "package")
input_states_refresh :: proc(input_states: ^InputStates($T, $N)) {
	input_states.previous = input_states.current
}

@(private = "package")
@(require_results)
input_states_is_pressed :: proc(input_states: ^InputStates($T, $N), input_index: uint) -> bool {
	return input_state_is_active(input_states.current[input_index])
}

@(private = "package")
@(require_results)
input_states_is_just_pressed :: proc(
	input_states: ^InputStates($T, $N),
	input_index: uint,
) -> bool {
	return(
		input_state_is_active(input_states.current[input_index]) &&
		!input_state_is_active(input_states.previous[input_index]) \
	)
}

@(private = "package")
@(require_results)
input_states_is_released :: proc(input_states: ^InputStates($T, $N), input_index: uint) -> bool {
	return(
		!input_state_is_active(input_states.current[input_index]) &&
		input_state_is_active(input_states.previous[input_index]) \
	)
}

@(private = "file")
@(require_results)
input_state_is_active :: proc {
	button_state_is_active,
	axis_state_is_active,
}

@(private = "file")
@(require_results)
button_state_is_active :: proc(button: bool) -> bool {
	return button
}

@(private = "file")
@(require_results)
axis_state_is_active :: proc(axis: f32) -> bool {
	return axis > 0
}
