#version 330 core

in vec3 color;
in vec3 pos;
out vec3 vertex_color;

void main()
{
    vertex_color = color;
    gl_Position = vec4(pos, 1.0);
}
