package vinter

import "core:log"
import "core:strings"
import sdl "vendor:sdl3"

renderer_set_clear_color :: proc(color: Color) {
	app.renderer.clear_color = color
	rgba := color_to_rgba8(color)
	log.infof("Changed clear color to RGBA: (%d, %d, %d, %d)", rgba.r, rgba.g, rgba.b, rgba.a)
}

@(require_results)
renderer_vsync_enabled :: proc() -> bool {
	return app.renderer.vsync_enabled
}

renderer_set_vsync :: proc(enabled: bool) {
	app.renderer.vsync_enabled = false
	present_mode := sdl.GPUPresentMode.IMMEDIATE

	supports_mailbox: bool = sdl.WindowSupportsGPUPresentMode(
		app.renderer.device,
		app.window.backend,
		.MAILBOX,
	)

	if (enabled) {
		present_mode = supports_mailbox ? .MAILBOX : .VSYNC
		app.renderer.vsync_enabled = true
	}

	if (!sdl.SetGPUSwapchainParameters(
			   app.renderer.device,
			   app.window.backend,
			   .SDR,
			   present_mode,
		   )) {
		log.panicf("Failed setting up GPU swapchain parameters: %s", sdl.GetError())
	}

	switch (present_mode) {
	case .IMMEDIATE:
		log.info("VSync disabled.")
	case .VSYNC:
		log.info("Vsync enabled.")
	case .MAILBOX:
		log.info("Vsync enabled (Mailbox).")
	}
}

RendererSettings :: struct {
	backend:                  RendererBackend,
	vsync_enabled:            bool,
	default_background_color: Color,
}

RendererBackend :: enum {
	Vulkan,
	Direct3D12,
	Metal,
	Automatic,
}

@(private = "package")
renderer_begin_frame :: proc() {
	app.renderer.cmd_buffer = sdl.AcquireGPUCommandBuffer(app.renderer.device)
	log.assertf(
		app.renderer.cmd_buffer != nil,
		"Error acquiring GPU command buffer: %s",
		sdl.GetError(),
	)

	swapchain_texture: ^sdl.GPUTexture
	acquired_swapchain_texture := sdl.WaitAndAcquireGPUSwapchainTexture(
		app.renderer.cmd_buffer,
		app.window.backend,
		&swapchain_texture,
		nil,
		nil,
	)
	log.assertf(
		acquired_swapchain_texture && swapchain_texture != nil,
		"Error acquiring GPU swapchain texture: %s",
		sdl.GetError(),
	)

	color_target := sdl.GPUColorTargetInfo {
		texture     = swapchain_texture,
		clear_color = sdl.FColor(app.renderer.clear_color),
		load_op     = .CLEAR,
		store_op    = .STORE,
	}
	app.renderer.render_pass = sdl.BeginGPURenderPass(
		app.renderer.cmd_buffer,
		&color_target,
		1,
		nil,
	)
}

@(private = "package")
renderer_end_frame :: proc() {
	sdl.EndGPURenderPass(app.renderer.render_pass)

	if (!sdl.SubmitGPUCommandBuffer(app.renderer.cmd_buffer)) {
		log.panicf("Error submitting GPU command buffer: %s", sdl.GetError())
	}
}

@(private = "package")
Renderer :: struct {
	device:        ^sdl.GPUDevice,
	cmd_buffer:    ^sdl.GPUCommandBuffer,
	render_pass:   ^sdl.GPURenderPass,
	clear_color:   Color,
	vsync_enabled: bool,
}

@(private = "package")
@(require_results)
renderer_create :: proc(settings: ^RendererSettings) -> Renderer {
	log.info("Creating Renderer...")

	renderer := Renderer {
		device      = sdl.CreateGPUDevice(
			to_sdl_gpu_shader_format(settings.backend),
			true,
			to_sdl_gpu_driver_name(settings.backend),
		),
		clear_color = settings.default_background_color,
	}

	log.assertf(renderer.device != nil, "Failed creating GPU Device: %s", sdl.GetError())
	log.infof(
		"GPU Device created successfully: %s",
		sdl.GetStringProperty(
			sdl.GetGPUDeviceProperties(renderer.device),
			sdl.PROP_GPU_DEVICE_NAME_STRING,
			"Unknown GPU",
		),
	)
	log.infof(
		"Selected GPU Backend: %s",
		to_gpu_backend_name(sdl.GetGPUDeviceDriver(renderer.device)),
	)

	if (!sdl.ClaimWindowForGPUDevice(renderer.device, app.window.backend)) {
		log.panicf("Failed claiming window for GPU Device: %s", sdl.GetError())
	}
	sdl.ShowWindow(app.window.backend) // Show window now that renderer setup has finished.
	log.info("Window context claimed for GPU Device.")
	log.info("Renderer created.")

	return renderer
}

@(private = "package")
renderer_destroy :: proc() {
	log.info("Destroying Renderer...")
	if (app.renderer.device != nil) {
		if (app.window.backend != nil) {
			sdl.ReleaseWindowFromGPUDevice(app.renderer.device, app.window.backend)
			log.info("Window released from GPU Device.")
		}
		sdl.DestroyGPUDevice(app.renderer.device)
		log.info("GPU Device destroyed.")
	}
	log.info("Renderer destroyed.")
}


@(private = "file")
to_sdl_gpu_shader_format :: proc(backend: RendererBackend) -> sdl.GPUShaderFormat {
	sdl_gpu_shader_format := sdl.GPUShaderFormat{}

	switch backend {
	case .Vulkan:
		sdl_gpu_shader_format |= {.SPIRV}
	case .Direct3D12:
		sdl_gpu_shader_format |= {.SPIRV} | {.DXIL} | {.DXBC}
	case .Metal:
		sdl_gpu_shader_format |= {.MSL} | {.METALLIB}
	case .Automatic:
		sdl_gpu_shader_format |= {.SPIRV} | {.DXIL} | {.DXBC} | {.MSL} | {.METALLIB}
	}
	return sdl_gpu_shader_format
}

@(private = "file")
to_sdl_gpu_driver_name :: proc(backend: RendererBackend) -> cstring {
	switch backend {
	case .Vulkan:
		return "vulkan"
	case .Direct3D12:
		return "direct3d12"
	case .Metal:
		return "metal"
	case .Automatic:
		return nil
	}
	return nil
}

@(private = "file")
to_gpu_backend_name :: proc(sdl_gpu_driver_name: cstring) -> string {
	if strings.compare(strings.clone_from_cstring(sdl_gpu_driver_name), "vulkan") == 0 {
		return "Vulkan"
	}
	if strings.compare(strings.clone_from_cstring(sdl_gpu_driver_name), "direct3d12") == 0 {
		return "Direct3D12"
	}
	if strings.compare(strings.clone_from_cstring(sdl_gpu_driver_name), "metal") == 0 {
		return "Metal"
	}
	return ""
}
