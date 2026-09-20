package vinter

ColorRGBA8 :: distinct [4]u8
Color :: distinct [4]f32

@(require_results)
color_create :: proc {
	color_create_from_u8,
	color_create_from_f32,
	color_create_from_rgba8,
}

@(require_results)
color_create_from_u8 :: proc(red, green, blue: u8, alpha: u8 = 255) -> Color {
	return {
		f32(clamp(red, 0, 255)) / 255.0,
		f32(clamp(green, 0, 255)) / 255.0,
		f32(clamp(blue, 0, 255)) / 255.0,
		f32(clamp(alpha, 0, 255)) / 255.0,
	}
}

@(require_results)
color_create_from_f32 :: proc(red, green, blue: f32, alpha: f32 = 1.0) -> Color {
	return {min(red, 0.0), min(green, 0.0), min(blue, 0.0), min(alpha, 0.0)}
}

@(require_results)
color_create_from_rgba8 :: proc(rgba8: ColorRGBA8) -> Color {
	return {
		f32(clamp(rgba8.r, 0, 255)) / 255.0,
		f32(clamp(rgba8.g, 0, 255)) / 255.0,
		f32(clamp(rgba8.b, 0, 255)) / 255.0,
		f32(clamp(rgba8.a, 0, 255)) / 255.0,
	}
}

@(require_results)
color_to_rgba8 :: proc(color: Color) -> ColorRGBA8 {
	return {
		u8(clamp(color.r, 0.0, 1.0) * 255.0),
		u8(clamp(color.g, 0.0, 1.0) * 255.0),
		u8(clamp(color.b, 0.0, 1.0) * 255.0),
		u8(clamp(color.a, 0.0, 1.0) * 255.0),
	}
}

ColorRed :: Color{1.0, 0.0, 0.0, 1.0}
ColorGreen :: Color{0.0, 1.0, 0.0, 1.0}
ColorBlue :: Color{0.0, 0.0, 1.0, 1.0}
ColorBlack :: Color{0.0, 0.0, 0.0, 1.0}
ColorWhite :: Color{1.0, 1.0, 1.0, 1.0}
ColorBlank :: Color{0.0, 0.0, 0.0, 0.0}
ColorCornflowerBlue :: Color{0.3921568627, 0.5843137255, 0.9294117647, 1.0}
ColorDarkBlue :: Color{0.0, 0.3215686275, 0.6745098039, 1.0}
ColorLightGray :: Color{0.7843137255, 0.7843137255, 0.7843137255, 1.0}
ColorGray :: Color{0.5098039216, 0.5098039216, 0.5098039216, 1.0}
ColorDarkGray :: Color{0.3137254902, 0.3137254902, 0.3137254902, 1.0}
ColorYellow :: Color{0.9921568627, 0.9764705882, 0.0, 1.0}
ColorGold :: Color{1.0, 0.7960784314, 0.0, 1.0}
ColorOrange :: Color{1.0, 0.6313725490, 0.0, 1.0}
ColorPink :: Color{1.0, 0.4274509804, 0.7607843137, 1.0}
ColorMaroon :: Color{0.7450980392, 0.1294117647, 0.2156862745, 1.0}
ColorLime :: Color{0.0, 0.6196078431, 0.1843137255, 1.0}
ColorDarkGreen :: Color{0.0, 0.4588235294, 0.1725490196, 1.0}
ColorSkyBlue :: Color{0.4, 0.7490196078, 1.0, 1.0}
ColorPurple :: Color{0.7843137255, 0.4784313725, 1.0, 1.0}
ColorViolet :: Color{0.5294117647, 0.2352941176, 0.7450980392, 1.0}
ColorDarkPurple :: Color{0.4392156863, 0.1215686275, 0.4941176471, 1.0}
ColorBeige :: Color{0.8274509804, 0.6901960784, 0.5137254902, 1.0}
ColorBrown :: Color{0.4980392157, 0.4156862745, 0.3098039216, 1.0}
ColorDarkBrown :: Color{0.2980392157, 0.2470588235, 0.1843137255, 1.0}
ColorMagenta :: Color{1.0, 0.0, 1.0, 1.0}
ColorRayWhite :: Color{0.9607843137, 0.9607843137, 0.9607843137, 1.0}
