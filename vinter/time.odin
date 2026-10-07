package vinter

import "core:time"

time_set_scale :: proc(scale: f32) {
	app.time.scale = max(0, scale)
}

time_pause :: proc() {
	app.time.paused = true
}

time_unpause :: proc() {
	app.time.paused = false
}

time_toggle_pause :: proc() {
	if app.time.paused do time_unpause()
	else do time_pause()
}

time_reset :: proc() {
	app.time.last = time.tick_now()
	app.time.delta = 0
	app.time.elapsed = 0
	app.time.unscaled_delta = 0
	app.time.unscaled_elapsed = 0
	app.time.wall = 0
	ema_reset(&app.time.frame_time_filter)
}

time_delta :: proc() -> f32 {
	return app.time.delta
}

time_unscaled_delta :: proc() -> f32 {
	return app.time.unscaled_delta
}

time_elapsed :: proc() -> f32 {
	return app.time.elapsed
}

time_unscaled_elapsed :: proc() -> f32 {
	return app.time.unscaled_elapsed
}

time_wall :: proc() -> f32 {
	return app.time.wall
}

time_scale :: proc() -> f32 {
	return app.time.scale
}

time_is_paused :: proc() -> bool {
	return app.time.paused
}

time_fps :: proc() -> f32 {
	avg_frame_time := ema_value(&app.time.frame_time_filter)
	if avg_frame_time <= 0 do return 0
	return 1.0 / avg_frame_time
}

time_instant_fps :: proc() -> f32 {
	if app.time.unscaled_delta <= 0 do return 0
	return 1.0 / app.time.unscaled_delta
}

time_set_fps_smooth_factor :: proc(smooth_factor: f32) {
	ema_set_smooth_factor(&app.time.frame_time_filter, smooth_factor)
}

time_set_max_delta :: proc(max_delta: f32) {
	assert(max_delta > 0)
	app.time.max_delta = max_delta
}

TimeSettings :: struct {
	max_delta:         f32,
	fps_smooth_factor: f32,
}

@(private = "package")
Time :: struct {
	frame_time_filter: EMAFilter,
	last:              time.Tick,
	delta:             f32,
	unscaled_delta:    f32,
	max_delta:         f32,
	elapsed:           f32,
	unscaled_elapsed:  f32,
	wall:              f32,
	scale:             f32,
	paused:            bool,
}


@(private = "package")
time_create :: proc(settings: ^TimeSettings) -> Time {
	return {
		last = time.tick_now(),
		scale = 1.0,
		max_delta = settings.max_delta,
		frame_time_filter = ema_create(settings.fps_smooth_factor),
	}
}

@(private = "package")
time_update :: proc() {
	now := time.tick_now()

	raw_delta := f32(time.duration_seconds(time.tick_diff(app.time.last, now)))
	app.time.unscaled_delta = clamp(raw_delta, 0, app.time.max_delta)

	app.time.last = now

	if app.time.paused {
		app.time.delta = 0
	} else {
		app.time.delta = app.time.unscaled_delta * app.time.scale

		app.time.unscaled_elapsed += app.time.unscaled_delta
		app.time.elapsed += app.time.delta
	}
	app.time.wall += app.time.unscaled_delta

	ema_add_sample(&app.time.frame_time_filter, app.time.unscaled_delta)
}
