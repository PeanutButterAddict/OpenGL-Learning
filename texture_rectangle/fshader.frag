#version 330 core

in vec3 v_color;
in vec2 v_tex_coord;

out vec4 f_color;

uniform sampler2D texture_1;
uniform sampler2D texture_2;

void main()
{
    // f_color = texture(texture_1, v_tex_coord) * vec4(v_color, 1.0f);
    f_color = mix(texture(texture_1, v_tex_coord), texture(texture_2, v_tex_coord), 0.2);
}
