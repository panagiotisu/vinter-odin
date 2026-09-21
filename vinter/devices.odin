package vinter

import sdl "vendor:sdl3"

MaxGamepadCount: uint : 8

@(private = "package")
Devices :: struct {
	keyboard:      Keyboard,
	mouse:         Mouse,
	gamepads:      map[uint]Gamepad,
	gamepad_slots: [MaxGamepadCount]Maybe(uint),
}

@(private = "package")
devices_create :: proc() -> Devices {
	devices := Devices {
		keyboard = keyboard_create(),
		mouse    = mouse_create(),
	}

	// Scan existing gamepads on startup.
	joystick_count: i32 = 0
	joystick_ids := sdl.GetJoysticks(&joystick_count)
	for i in 0 ..< joystick_count {
		handle_gamepad_added(&devices, uint(joystick_ids[i]))
	}
	sdl.free(joystick_ids)

	return devices
}

@(private = "package")
devices_handle_events :: proc(event: ^sdl.Event) {
	keyboard_handle_events(event)
	mouse_handle_events(event)

	#partial switch event.type {
	case .GAMEPAD_ADDED:
		handle_gamepad_added(&app.devices, uint(event.gdevice.which))

	case .GAMEPAD_REMOVED:
		handle_gamepad_removed(&app.devices, uint(event.gdevice.which))
	}

	for _, &gamepad in app.devices.gamepads {
		gamepad_handle_events(&gamepad, event)
	}
}

@(private = "package")
devices_update :: proc() {
	keyboard_update()
	mouse_update()
	for _, &gamepad in app.devices.gamepads {
		gamepad_update(&gamepad)
	}
}

@(private = "file")
handle_gamepad_added :: proc(devices: ^Devices, id: uint) {
	if !sdl.IsGamepad(sdl.JoystickID(id)) do return

	_, ok := devices.gamepads[id]
	if ok do return

	// Find a free slot before creating the gamepad.
	for &slot in devices.gamepad_slots {
		if slot == nil {
			slot = id
			devices.gamepads[id] = gamepad_create(id)
			return
		}
	}
}

@(private = "file")
handle_gamepad_removed :: proc(devices: ^Devices, id: uint) {
	_, ok := devices.gamepads[id]
	if !ok do return

	delete_key(&devices.gamepads, id)

	for &slot in devices.gamepad_slots {
		if slot != nil && slot.(uint) == id {
			slot = nil
			break
		}
	}
}
