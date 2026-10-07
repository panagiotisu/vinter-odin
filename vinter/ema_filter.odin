package vinter

EMAFilter :: struct {
	value:       f32,
	alpha:       f32,
	initialized: bool,
}

ema_create :: proc(smooth_factor: f32) -> EMAFilter {
	ema: EMAFilter
	ema_set_smooth_factor(&ema, smooth_factor)
	return ema
}

ema_set_smooth_factor :: proc(ema: ^EMAFilter, smooth_factor: f32) {
	assert(smooth_factor > 0 && smooth_factor <= 1)
	ema.alpha = smooth_factor
}

ema_add_sample :: proc(ema: ^EMAFilter, sample: f32) {
	if !ema.initialized {
		ema.value = sample
		ema.initialized = true
		return
	}
	ema.value = ema.alpha * sample + (1 - ema.alpha) * ema.value
}

@(require_results)
ema_value :: #force_inline proc(ema: ^EMAFilter) -> f32 {
	return ema.value
}

ema_reset :: proc(ema: ^EMAFilter) {
	ema.value = 0
	ema.initialized = false
}
