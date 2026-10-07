package sandbox

import vn "../../vinter"
import "core:fmt"

main :: proc() {
	sandbox_settings: vn.ProjectSettings = {
		window = {
			title = "Sandbox",
			initial_size = {1280, 720},
			flags = {resizeable = true, mouse_captured = true},
		},
		renderer = {default_background_color = vn.DarkBlue},
		time = {fps_smooth_factor = 0.2, max_delta = 0.25},
		logger = {log_level = .Debug},
	}

	sandbox_hooks: vn.RuntimeHooks = {
		load   = sandbox_load,
		update = sandbox_update,
		render = sandbox_render,
	}

	vn.run(&sandbox_settings, &sandbox_hooks)
}

sandbox_load :: proc() {

}

sandbox_update :: proc() {
	vn.window_set_title(fmt.tprintf("Sandbox | FPS: %.f", vn.time_fps()))

	if vn.mouse_is_button_just_pressed(.Middle) {
		vn.renderer_set_clear_color(vn.Gold)
	}

	if vn.keyboard_is_key_just_pressed(.Space) {
		vn.time_pause()
	}

}

sandbox_render :: proc() {

}
