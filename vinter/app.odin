package vinter

import "core:log"
import sdl "vendor:sdl3"

run :: proc(project_settings: ^ProjectSettings, hooks: ^RuntimeHooks) {
	context.logger = log.create_console_logger()
	context.logger.lowest_level = project_settings.logger.log_level
	defer log.destroy_console_logger(context.logger)

	init(project_settings, hooks)
	defer destroy()

	log.info("Loading assets...")
	app.hooks.load()
	log.info("Assets loaded.")

	log.info("Starting engine loop...")
	for app.is_running {
		event: sdl.Event
		for sdl.PollEvent(&event) {
			if event.type == .QUIT do app.is_running = false
			window_handle_events(&event)
		}

		app.hooks.update()

		renderer_begin_frame()
		app.hooks.render()
		renderer_end_frame()
	}
}

ProjectSettings :: struct {
	window:   WindowSettings,
	renderer: RendererSettings,
	logger:   LoggerSettings,
}

LoggerSettings :: struct {
	log_level: log.Level,
}

RuntimeHooks :: struct {
	load:   proc(),
	update: proc(),
	render: proc(),
}

@(private = "package")
App :: struct {
	window:     Window,
	renderer:   Renderer,
	hooks:      RuntimeHooks,
	is_running: bool,
}

@(private = "package")
app: App

@(private = "file")
init :: proc(project_settings: ^ProjectSettings, hooks: ^RuntimeHooks) {
	log.infof("Launching %s", project_settings.window.title)

	sdl_init()
	app.window = window_create(&project_settings.window)
	app.renderer = renderer_create(&project_settings.renderer)
	app.hooks = hooks^
	app.is_running = true
}

@(private = "file")
destroy :: proc() {
	renderer_destroy()
	window_destroy()

	log.info("Destroying SDL Context...")
	sdl.Quit()
	log.info("SDL Context destroyed.")
	log.info("Shutting down...")
}

@(private = "file")
sdl_init :: proc() {
	log.info("Initializing SDL...")
	if (!sdl.Init(
			   sdl.INIT_VIDEO |
			   sdl.INIT_AUDIO |
			   sdl.INIT_EVENTS |
			   sdl.INIT_GAMEPAD |
			   sdl.INIT_JOYSTICK,
		   )) {
		log.fatalf("Failed to initialize SDL: %s", sdl.GetError())
	}
	log.info("SDL initialized.")
}
