package shader_distance_field

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "core:reflect"
import "vendor:OpenGL"
import "vendor:glfw"

Triangle :: [3]u32

Vertex :: struct {
	pos: [3]f32,
}

vshader_source_path :: "vshader.vert"
fshader_source_path :: "fshader.frag"

resolution := [2]f32{800, 600}
// NOTE: To do a vertical flip, flip the y in tex coords from 0 -> 1, 1 -> 0
// To do a horizontal flip, flip the x.
vertices := [?]Vertex {
	{pos = {1, 1, 0}}, // Top Right
	{pos = {1, -1, 0}}, // Bottom Right
	{pos = {-1, -1, 0}}, // Bottom Left
	{pos = {-1, 1, 0}}, // Top Left
}
indices := [?]Triangle{{0, 1, 2}, {0, 2, 3}}

main :: proc() {
	glfw.SetErrorCallback(error_callback)

	if !glfw.Init() do panic("Exit Failure")
	defer glfw.Terminate()

	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	window := glfw.CreateWindow(
		cast(c.int)resolution.x,
		cast(c.int)resolution.y,
		"Shader Shape Function Test",
		nil,
		nil,
	)
	if window == nil do panic("Exit Failure")
	defer glfw.DestroyWindow(window)
	glfw.MakeContextCurrent(window)
	glfw.SetFramebufferSizeCallback(window, set_frame_buffer_size_callback)
	OpenGL.load_up_to(3, 3, glfw.gl_set_proc_address)

	vshader := OpenGL.CreateShader(OpenGL.VERTEX_SHADER)
	defer OpenGL.DeleteShader(vshader)
	vshader_source_cstring := get_source_cstring(vshader_source_path)
	OpenGL.ShaderSource(vshader, 1, &vshader_source_cstring, nil)
	OpenGL.CompileShader(vshader)
	check_shaderiv(vshader)

	fshader := OpenGL.CreateShader(OpenGL.FRAGMENT_SHADER)
	defer OpenGL.DeleteShader(fshader)
	fshader_source_cstring := get_source_cstring(fshader_source_path)
	OpenGL.ShaderSource(fshader, 1, &fshader_source_cstring, nil)
	OpenGL.CompileShader(fshader)
	check_shaderiv(fshader)

	shader_program := OpenGL.CreateProgram()
	OpenGL.AttachShader(shader_program, vshader)
	OpenGL.AttachShader(shader_program, fshader)
	OpenGL.BindFragDataLocation(shader_program, 0, "f_color")
	OpenGL.LinkProgram(shader_program)
	check_programiv(shader_program)

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
		OpenGL.EnableVertexAttribArray(0)
	}

	OpenGL.UseProgram(shader_program)
	u_resolution := OpenGL.GetUniformLocation(shader_program, "u_resolution")
	u_time := OpenGL.GetUniformLocation(shader_program, "u_time")
	u_mouse := OpenGL.GetUniformLocation(shader_program, "u_mouse")
	OpenGL.Uniform2f(u_resolution, resolution.x, resolution.y)
	OpenGL.Uniform1f(u_time, cast(f32)glfw.GetTime())
	mouse_pos_x, mouse_pos_y := glfw.GetCursorPos(window)
	OpenGL.Uniform2f(u_mouse, cast(f32)mouse_pos_x, cast(f32)mouse_pos_y)

	// OpenGL.PolygonMode(OpenGL.FRONT_AND_BACK, OpenGL.LINE)

	for !glfw.WindowShouldClose(window) {
		process_input(window)

		OpenGL.ClearColor(0.2, 0.3, 0.3, 1)
		OpenGL.Clear(OpenGL.COLOR_BUFFER_BIT)

		OpenGL.UseProgram(shader_program)
		OpenGL.Uniform2f(u_resolution, resolution.x, resolution.y)
		OpenGL.Uniform1f(u_time, cast(f32)glfw.GetTime())
		mouse_pos_x, mouse_pos_y := glfw.GetCursorPos(window)
		OpenGL.Uniform2f(u_mouse, cast(f32)mouse_pos_x, cast(f32)mouse_pos_y)
		OpenGL.BindVertexArray(vao)
		defer OpenGL.BindVertexArray(0)

		OpenGL.DrawElements(
			OpenGL.TRIANGLES,
			len(indices) * len(indices[0]),
			OpenGL.UNSIGNED_INT,
			transmute(rawptr)cast(uintptr)0,
		)

		glfw.SwapBuffers(window)
		glfw.PollEvents()
	}
}

process_input :: proc(window: glfw.WindowHandle) {
	if glfw.GetKey(window, glfw.KEY_ESCAPE) == glfw.PRESS {
		glfw.SetWindowShouldClose(window, true)
	}
}


set_frame_buffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: c.int) {
	OpenGL.Viewport(0, 0, width, height)
	resolution = {cast(f32)width, cast(f32)height}
}

delete_shader_program :: proc(shader_program: u32) {
	OpenGL.DeleteProgram(shader_program)
}

check_shaderiv :: proc(shader: u32) {
	status: i32
	info_log: [512]u8
	OpenGL.GetShaderiv(shader, OpenGL.COMPILE_STATUS, &status)
	if status == 0 {
		OpenGL.GetShaderInfoLog(shader, 512, nil, transmute([^]u8)&info_log)
		fmt.eprintln("ERROR::SHADER::COMPILATION_FAILED\n", transmute(cstring)&info_log)
		panic("")
	}
}

check_programiv :: proc(program: u32) {
	status: i32
	info_log: [512]u8
	OpenGL.GetProgramiv(program, OpenGL.LINK_STATUS, &status)
	if status == 0 {
		OpenGL.GetProgramInfoLog(program, 512, nil, transmute([^]u8)&info_log)
		fmt.eprintln("ERROR::PROGRAM::LINK_FAIL\n", transmute(cstring)&info_log)
		panic("")
	}
}

get_source_cstring :: proc(source_path: string) -> (source_cstring: cstring) {
	source :=
		os.read_entire_file(source_path, runtime.default_allocator()) or_else panic(
			"failed to read source file",
		)
	source_cstring = transmute(cstring)raw_data(source)
	return source_cstring
}

error_callback :: proc "c" (code: i32, desc: cstring) {
	context = runtime.default_context()
	fmt.println(desc, code)
}

