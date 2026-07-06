package translation

import "core:c"
import "core:fmt"
import "core:image"
import "core:image/jpeg"
import "core:image/png"
import "core:reflect"

import "vendor:OpenGL"
import "vendor:glfw"

Triangle :: [3]u32

Vertex :: struct {
	pos:       [3]f32,
	color:     [3]f32,
	tex_coord: [2]f32,
}

vshader_source_path :: "vshader.vert"
fshader_source_path :: "fshader.frag"
texture_1_source_path :: "../images/container.jpg"
texture_2_source_path :: "../images/awesomeface.png"

// NOTE: To do a vertical flip, flip the y in tex coords from 0 -> 1, 1 -> 0
// To do a horizontal flip, flip the x.
vertices := [?]Vertex {
	{pos = {0.5, 0.5, 0}, color = {1, 0, 0}, tex_coord = {1, 0}}, // Top Right
	{pos = {0.5, -0.5, 0}, color = {0, 1, 0}, tex_coord = {1, 1}}, // Bottom Right
	{pos = {-0.5, -0.5, 0}, color = {0, 0, 1}, tex_coord = {0, 1}}, // Bottom Left
	{pos = {-0.5, 0.5, 0}, color = {1, 1, 0}, tex_coord = {0, 0}}, // Top Left
}
indices := [?]Triangle{{0, 1, 2}, {0, 2, 3}}

main :: proc() {

	if !glfw.Init() do panic("Exit Failure")
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	window := glfw.CreateWindow(800, 600, "learning opengl", nil, nil)
	if window == nil do panic("Exit Failure")
	defer glfw.DestroyWindow(window)
	glfw.MakeContextCurrent(window)
	glfw.SetFramebufferSizeCallback(window, set_frame_buffer_size_callback)
	OpenGL.load_up_to(3, 3, set_proc_address_callback)

	shader_program := make_shader_program(vshader_source_path, fshader_source_path)
	defer delete_shader_program(shader_program)

	vao, vbo, ebo: u32
	OpenGL.GenVertexArrays(1, &vao)
	defer OpenGL.DeleteVertexArrays(1, &vao)
	OpenGL.GenBuffers(1, &vbo)
	defer OpenGL.DeleteBuffers(1, &vbo)
	OpenGL.GenBuffers(1, &ebo)
	defer OpenGL.DeleteBuffers(1, &ebo)

	{
		OpenGL.BindVertexArray(vao)
		defer OpenGL.BindVertexArray(0)
		OpenGL.BindBuffer(OpenGL.ARRAY_BUFFER, vbo)
		OpenGL.BufferData(OpenGL.ARRAY_BUFFER, size_of(vertices), &vertices, OpenGL.STATIC_DRAW)
		OpenGL.BindBuffer(OpenGL.ELEMENT_ARRAY_BUFFER, ebo)
		OpenGL.BufferData(
			OpenGL.ELEMENT_ARRAY_BUFFER,
			size_of(indices),
			&indices,
			OpenGL.STATIC_DRAW,
		)
		OpenGL.VertexAttribPointer(
			0,
			len(vertices[0].pos),
			OpenGL.FLOAT,
			OpenGL.FALSE,
			size_of(Vertex),
			reflect.struct_field_at(Vertex, 0).offset,
		)
		OpenGL.VertexAttribPointer(
			1,
			len(vertices[0].color),
			OpenGL.FLOAT,
			OpenGL.FALSE,
			size_of(Vertex),
			reflect.struct_field_at(Vertex, 1).offset,
		)
		OpenGL.VertexAttribPointer(
			2,
			len(vertices[0].tex_coord),
			OpenGL.FLOAT,
			OpenGL.FALSE,
			size_of(Vertex),
			reflect.struct_field_at(Vertex, 2).offset,
		)
		OpenGL.EnableVertexAttribArray(0)
		OpenGL.EnableVertexAttribArray(1)
		OpenGL.EnableVertexAttribArray(2)
	}


	texture_1, texture_2: u32

	{
		OpenGL.GenTextures(1, &texture_1)
		OpenGL.BindTexture(OpenGL.TEXTURE_2D, texture_1)
		OpenGL.TexParameteri(OpenGL.TEXTURE_2D, OpenGL.TEXTURE_WRAP_S, OpenGL.REPEAT)
		OpenGL.TexParameteri(OpenGL.TEXTURE_2D, OpenGL.TEXTURE_WRAP_T, OpenGL.REPEAT)
		OpenGL.TexParameteri(
			OpenGL.TEXTURE_2D,
			OpenGL.TEXTURE_MIN_FILTER,
			OpenGL.LINEAR_MIPMAP_LINEAR,
		)
		OpenGL.TexParameteri(OpenGL.TEXTURE_2D, OpenGL.TEXTURE_MAG_FILTER, OpenGL.LINEAR)
		texture_1_source := image.load(texture_1_source_path) or_else panic("Fail to load image.")
		defer image.destroy(texture_1_source)

		OpenGL.TexImage2D(
			OpenGL.TEXTURE_2D,
			0,
			OpenGL.RGB,
			cast(i32)texture_1_source.width,
			cast(i32)texture_1_source.height,
			0,
			OpenGL.RGB,
			OpenGL.UNSIGNED_BYTE,
			raw_data(texture_1_source.pixels.buf),
		)
		OpenGL.GenerateMipmap(OpenGL.TEXTURE_2D)
	}

	{
		OpenGL.GenTextures(1, &texture_2)
		OpenGL.BindTexture(OpenGL.TEXTURE_2D, texture_2)
		OpenGL.TexParameteri(OpenGL.TEXTURE_2D, OpenGL.TEXTURE_WRAP_S, OpenGL.REPEAT)
		OpenGL.TexParameteri(OpenGL.TEXTURE_2D, OpenGL.TEXTURE_WRAP_T, OpenGL.REPEAT)
		OpenGL.TexParameteri(
			OpenGL.TEXTURE_2D,
			OpenGL.TEXTURE_MIN_FILTER,
			OpenGL.LINEAR_MIPMAP_LINEAR,
		)
		OpenGL.TexParameteri(OpenGL.TEXTURE_2D, OpenGL.TEXTURE_MAG_FILTER, OpenGL.LINEAR)
		texture_2_source := image.load(texture_2_source_path) or_else panic("Fail to load image.")
		defer image.destroy(texture_2_source)

		OpenGL.TexImage2D(
			OpenGL.TEXTURE_2D,
			0,
			OpenGL.RGB,
			cast(i32)texture_2_source.width,
			cast(i32)texture_2_source.height,
			0,
			OpenGL.RGBA,
			OpenGL.UNSIGNED_BYTE,
			raw_data(texture_2_source.pixels.buf),
		)
		OpenGL.GenerateMipmap(OpenGL.TEXTURE_2D)
	}

	texture_1_uniform := OpenGL.GetUniformLocation(shader_program, "texture_1")
	texture_2_uniform := OpenGL.GetUniformLocation(shader_program, "texture_2")

	OpenGL.UseProgram(shader_program)
	OpenGL.Uniform1i(texture_1_uniform, 0)
	OpenGL.Uniform1i(texture_2_uniform, 1)
	// OpenGL.PolygonMode(OpenGL.FRONT_AND_BACK, OpenGL.LINE)

	for !glfw.WindowShouldClose(window) {
		process_input(window)

		OpenGL.ClearColor(0.2, 0.3, 0.3, 1)
		OpenGL.Clear(OpenGL.COLOR_BUFFER_BIT)

		OpenGL.UseProgram(shader_program)
		OpenGL.BindVertexArray(vao)
		defer OpenGL.BindVertexArray(0)

		OpenGL.ActiveTexture(OpenGL.TEXTURE0)
		OpenGL.BindTexture(OpenGL.TEXTURE_2D, texture_1)
		OpenGL.ActiveTexture(OpenGL.TEXTURE1)
		OpenGL.BindTexture(OpenGL.TEXTURE_2D, texture_2)
		OpenGL.DrawElements(
			OpenGL.TRIANGLES,
			len(indices) * len(indices[0]),
			OpenGL.UNSIGNED_INT,
			transmute(rawptr)cast(uintptr)0,
		)

		glfw.PollEvents()
		glfw.SwapBuffers(window)
	}
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}


set_frame_buffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: c.int) {
	OpenGL.Viewport(0, 0, width, height)
}


set_proc_address_callback :: proc(p: rawptr, name: cstring) {
	(cast(^rawptr)p)^ = glfw.GetProcAddress(name)
}

