package vinter

import "core:log"
import "core:strings"
import sdl "vendor:sdl3"

@(require_results)
window_size :: proc() -> [2]u32 {
	return app.window.size
}

@(require_results)
window_width :: proc() -> u32 {
	return app.window.size.x
}

@(require_results)
window_height :: proc() -> u32 {
	return app.window.size.y
}

@(private = "package")
Window :: struct {
	title:   string,
	backend: ^sdl.Window,
	size:    [2]u32,
}

@(private = "package")
window_create :: proc(settings: ^WindowSettings) -> Window {
	window := Window {
		backend = sdl.CreateWindow(
			strings.clone_to_cstring(settings.title),
			i32(settings.initial_size.x),
			i32(settings.initial_size.y),
			to_sdl_window_flags(&settings.flags),
		),
		size    = settings.initial_size,
	}
	log.assertf(window.backend != nil, "Failed to create Window: ", sdl.GetError())
	log.info("Window context created.")

	return window
}

@(private = "package")
window_destroy :: proc() {
	log.info("Destroying Window context...")
	if app.window.backend != nil {
		sdl.DestroyWindow(app.window.backend)
	}
	log.info("Window context destroyed.")
}

@(private = "package")
window_handle_events :: proc(event: ^sdl.Event) {
	if event.type == .WINDOW_RESIZED {
		app.window.size = {u32(event.window.data1), u32(event.window.data2)}
	}
}

@(private = "file")
to_sdl_window_flags :: proc(flags: ^WindowFlags) -> sdl.WindowFlags {
	sdl_window_flags: sdl.WindowFlags = {}

	if flags.fullscreen do sdl_window_flags |= sdl.WINDOW_FULLSCREEN
	if flags.resizeable do sdl_window_flags |= sdl.WINDOW_RESIZABLE
	if flags.maximized do sdl_window_flags |= sdl.WINDOW_MAXIMIZED
	if flags.minimized do sdl_window_flags |= sdl.WINDOW_MINIMIZED
	if flags.hidden do sdl_window_flags |= sdl.WINDOW_HIDDEN
	if flags.borderless do sdl_window_flags |= sdl.WINDOW_BORDERLESS
	if flags.always_on_top do sdl_window_flags |= sdl.WINDOW_ALWAYS_ON_TOP
	if flags.mouse_captured do sdl_window_flags |= sdl.WINDOW_MOUSE_CAPTURE
	if flags.mouse_grabbed do sdl_window_flags |= sdl.WINDOW_MOUSE_GRABBED
	if flags.mouse_focus do sdl_window_flags |= sdl.WINDOW_MOUSE_FOCUS
	if flags.mouse_relative_mode do sdl_window_flags |= sdl.WINDOW_MOUSE_RELATIVE_MODE
	if flags.keyboard_grabbed do sdl_window_flags |= sdl.WINDOW_KEYBOARD_GRABBED

	return sdl_window_flags
}
