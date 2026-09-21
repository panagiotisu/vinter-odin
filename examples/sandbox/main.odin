package sandbox

import vn "../../vinter"

main :: proc() {
	sandbox_settings: vn.ProjectSettings = {
		window = {
			title = "sandbox",
			initial_size = {1280, 720},
			flags = {resizeable = true, mouse_captured = true},
		},
		renderer = {default_background_color = vn.DarkBlue},
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
	if vn.mouse_is_button_just_pressed(.Middle) {
		vn.renderer_set_clear_color(vn.Gold)
	}

}

sandbox_render :: proc() {

}
