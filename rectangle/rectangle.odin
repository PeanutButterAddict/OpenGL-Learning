package rectangle

import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "vendor:OpenGL"
import "vendor:glfw"

Vector3 :: [3]f32
Triangle :: [3]u32

vertex_shader_source_path :: "vertex_shader.vert"
fragment_shader_source_path :: "fragment_shader.frag"


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
	glfw.SetFramebufferSizeCallback(window, frame_buffer_size_callback)
	OpenGL.load_up_to(3, 3, proc(p: rawptr, name: cstring) {
		(cast(^rawptr)p)^ = glfw.GetProcAddress(name)
	})

	vertex_shader := OpenGL.CreateShader(OpenGL.VERTEX_SHADER)
	defer OpenGL.DeleteShader(vertex_shader)
	vertex_shader_source_cstring := get_source_cstring(vertex_shader_source_path)
	OpenGL.ShaderSource(vertex_shader, 1, &vertex_shader_source_cstring, nil)
	OpenGL.CompileShader(vertex_shader)
	check_shaderiv(vertex_shader)

	fragment_shader := OpenGL.CreateShader(OpenGL.FRAGMENT_SHADER)
	defer OpenGL.DeleteShader(fragment_shader)
	fragment_shader_source_cstring := get_source_cstring(fragment_shader_source_path)
	OpenGL.ShaderSource(fragment_shader, 1, &fragment_shader_source_cstring, nil)
	OpenGL.CompileShader(fragment_shader)
	check_shaderiv(fragment_shader)

	shader_program := OpenGL.CreateProgram()
	defer OpenGL.DeleteProgram(shader_program)
	OpenGL.AttachShader(shader_program, vertex_shader)
	OpenGL.AttachShader(shader_program, fragment_shader)
	OpenGL.LinkProgram(shader_program)
	check_programiv(shader_program)


	vertices := [?]Vector3{{0.5, 0.5, 0}, {0.5, -0.5, 0}, {-0.5, -0.5, 0}, {-0.5, 0.5, 0}}
	indices := [?]Triangle{{0, 1, 3}, {1, 2, 3}}
	vao, vbo, ebo: u32
	OpenGL.GenVertexArrays(1, &vao)
	defer OpenGL.DeleteVertexArrays(1, &vao)
	OpenGL.GenBuffers(1, &vbo)
	defer OpenGL.DeleteBuffers(1, &vbo)
	OpenGL.GenBuffers(1, &ebo)
	defer OpenGL.DeleteBuffers(1, &ebo)

	{
		// NOTE: Bind the Vertex Array Object first,
		// then bind and set vertex buffer(s),
		// and then configure vertex attributes(s).
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
			3,
			OpenGL.FLOAT,
			OpenGL.FALSE,
			size_of(Vector3),
			cast(uintptr)0,
		)
		OpenGL.EnableVertexAttribArray(0)
	}

	OpenGL.PolygonMode(OpenGL.FRONT_AND_BACK, OpenGL.LINE)

	for !glfw.WindowShouldClose(window) {
		process_input(window)

		OpenGL.ClearColor(0.2, 0.3, 0.3, 1)
		OpenGL.Clear(OpenGL.COLOR_BUFFER_BIT)

		OpenGL.UseProgram(shader_program)
		OpenGL.BindVertexArray(vao)
		defer OpenGL.BindVertexArray(0)
		OpenGL.DrawElements(
			OpenGL.TRIANGLES,
			len(indices) * len(Triangle),
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

check_shaderiv :: proc(shader: u32) {
	success: i32
	info_log: [512]u8
	OpenGL.GetShaderiv(shader, OpenGL.COMPILE_STATUS, &success)
	if success == 0 {
		OpenGL.GetShaderInfoLog(shader, 512, nil, transmute([^]u8)&info_log)
		fmt.eprintln("ERROR::SHADER::COMPILATION_FAILED\n", transmute(cstring)&info_log)
		panic("")
	}
}

check_programiv :: proc(program: u32) {
	success: i32
	info_log: [512]u8
	OpenGL.GetProgramiv(program, OpenGL.LINK_STATUS, &success)
	if success == 0 {
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

frame_buffer_size_callback :: proc "c" (window: glfw.WindowHandle, width, height: c.int) {
	OpenGL.Viewport(0, 0, width, height)
}

