package translation

import "base:runtime"
import "core:fmt"
import "core:os"
import "vendor:OpenGL"


make_shader_program :: proc(
	vshader_source_path, fshader_source_path: string,
) -> (
	shader_program: u32,
) {

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

	shader_program = OpenGL.CreateProgram()
	OpenGL.AttachShader(shader_program, vshader)
	OpenGL.AttachShader(shader_program, fshader)
	OpenGL.BindFragDataLocation(shader_program, 0, "frag_color")
	OpenGL.LinkProgram(shader_program)
	check_programiv(shader_program)

	return shader_program
}

delete_shader_program :: proc(shader_program: u32) {
	OpenGL.DeleteProgram(shader_program)
}

get_source_cstring :: proc(source_path: string) -> (source_cstring: cstring) {
	source :=
		os.read_entire_file(source_path, runtime.default_allocator()) or_else panic(
			"failed to read source file",
		)
	source_cstring = transmute(cstring)raw_data(source)
	return source_cstring
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

