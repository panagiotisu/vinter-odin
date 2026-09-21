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

Red :: Color{1.0, 0.0, 0.0, 1.0}
Green :: Color{0.0, 1.0, 0.0, 1.0}
Blue :: Color{0.0, 0.0, 1.0, 1.0}
Black :: Color{0.0, 0.0, 0.0, 1.0}
White :: Color{1.0, 1.0, 1.0, 1.0}
Blank :: Color{0.0, 0.0, 0.0, 0.0}
CornflowerBlue :: Color{0.3921568627, 0.5843137255, 0.9294117647, 1.0}
DarkBlue :: Color{0.0, 0.3215686275, 0.6745098039, 1.0}
LightGray :: Color{0.7843137255, 0.7843137255, 0.7843137255, 1.0}
Gray :: Color{0.5098039216, 0.5098039216, 0.5098039216, 1.0}
DarkGray :: Color{0.3137254902, 0.3137254902, 0.3137254902, 1.0}
Yellow :: Color{0.9921568627, 0.9764705882, 0.0, 1.0}
Gold :: Color{1.0, 0.7960784314, 0.0, 1.0}
Orange :: Color{1.0, 0.6313725490, 0.0, 1.0}
Pink :: Color{1.0, 0.4274509804, 0.7607843137, 1.0}
Maroon :: Color{0.7450980392, 0.1294117647, 0.2156862745, 1.0}
Lime :: Color{0.0, 0.6196078431, 0.1843137255, 1.0}
DarkGreen :: Color{0.0, 0.4588235294, 0.1725490196, 1.0}
SkyBlue :: Color{0.4, 0.7490196078, 1.0, 1.0}
Purple :: Color{0.7843137255, 0.4784313725, 1.0, 1.0}
Violet :: Color{0.5294117647, 0.2352941176, 0.7450980392, 1.0}
DarkPurple :: Color{0.4392156863, 0.1215686275, 0.4941176471, 1.0}
Beige :: Color{0.8274509804, 0.6901960784, 0.5137254902, 1.0}
Brown :: Color{0.4980392157, 0.4156862745, 0.3098039216, 1.0}
DarkBrown :: Color{0.2980392157, 0.2470588235, 0.1843137255, 1.0}
Magenta :: Color{1.0, 0.0, 1.0, 1.0}
RayWhite :: Color{0.9607843137, 0.9607843137, 0.9607843137, 1.0}
