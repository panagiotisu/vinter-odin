package vinter

import "core:log"

ProjectSettings :: struct {
	window: WindowSettings,
	logger: LoggerSettings,
}

WindowSettings :: struct {
	title:        string,
	initial_size: [2]u32,
	flags:        WindowFlags,
}
WindowFlags :: struct {
	fullscreen,
	resizeable,
	maximized,
	minimized,
	hidden,
	borderless,
	always_on_top,
	mouse_captured,
	mouse_grabbed,
	mouse_focus,
	mouse_relative_mode,
	keyboard_grabbed,
	high_pixel_density: bool,
}

LoggerSettings :: struct {
	log_level: log.Level,
}
