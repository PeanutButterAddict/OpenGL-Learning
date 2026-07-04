package practice

import "core:c"
import "core:reflect"

import "vendor:OpenGL"
import "vendor:glfw"

Triangle :: [3]u32
Vector3 :: distinct [3]f32
Color :: distinct [3]f32
Vertex :: struct {
	pos:   Vector3,
	color: Color,
}

vshader_source_path :: "vshader.vert"
fshader_source_path :: "fshader.frag"

vertices := [?]Vertex {
	{pos = {0.5, -0.5, 0}, color = {1, 0, 0}},
	{pos = {-0.5, -0.5, 0}, color = {0, 1, 0}},
	{pos = {0, 0.5, 0}, color = {0, 0, 1}},
}

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

	vao, vbo: u32
	OpenGL.GenVertexArrays(1, &vao)
	defer OpenGL.DeleteVertexArrays(1, &vao)
	OpenGL.GenBuffers(1, &vbo)
	defer OpenGL.DeleteBuffers(1, &vbo)

	{
		OpenGL.BindVertexArray(vao)
		defer OpenGL.BindVertexArray(0)
		OpenGL.BindBuffer(OpenGL.ARRAY_BUFFER, vbo)
		OpenGL.BufferData(OpenGL.ARRAY_BUFFER, size_of(vertices), &vertices, OpenGL.STATIC_DRAW)
		OpenGL.VertexAttribPointer(
			0,
			len(vertices[0].pos),
			OpenGL.FLOAT,
			OpenGL.FALSE,
			size_of(Vertex),
			reflect.struct_field_at(Vertex, 0).offset,
		)
		OpenGL.EnableVertexAttribArray(0)
		OpenGL.VertexAttribPointer(
			1,
			len(vertices[0].color),
			OpenGL.FLOAT,
			OpenGL.FALSE,
			size_of(Vertex),
			reflect.struct_field_at(Vertex, 1).offset,
		)
		OpenGL.EnableVertexAttribArray(1)
	}

	// OpenGL.PolygonMode(OpenGL.FRONT_AND_BACK, OpenGL.LINE)

	for !glfw.WindowShouldClose(window) {
		process_input(window)

		OpenGL.ClearColor(0.2, 0.3, 0.3, 1)
		OpenGL.Clear(OpenGL.COLOR_BUFFER_BIT)

		OpenGL.UseProgram(shader_program)
		OpenGL.BindVertexArray(vao)
		defer OpenGL.BindVertexArray(0)


		OpenGL.DrawArrays(OpenGL.TRIANGLES, 0, len(vertices))

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

