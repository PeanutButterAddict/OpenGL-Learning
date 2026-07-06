// #version 330 core

// in vec3 v_color;
// in vec2 v_tex_coord;

// out vec4 f_color;

// uniform sampler2D texture_1;
// uniform sampler2D texture_2;

// void main()
// {
//     // f_color = texture(texture_1, v_tex_coord) * vec4(v_color, 1.0f);
//     f_color = mix(texture(texture_1, v_tex_coord), texture(texture_2, v_tex_coord), 0.2);
// }

precision highp float;

out vec4 f_color;

uniform vec2 u_resolution;
uniform float u_time;
uniform vec4 u_mouse;


void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec3 color = vec3(0.0);
    color = vec3(st,abs(sin(u_time)));
    // color = vec3(st,0.0);
    if (st.x >= 1.0) {
        color = vec3(0.0,0.0,0.0);
    }
    
    f_color = vec4(color,1.0);
}
