#version 330 core

out vec4 f_color;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;


void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;
    st.x *= u_resolution.x/u_resolution.y;

    vec3 color = vec3(0.0);
    color = vec3(st,abs(sin(u_time)));
    if (st.x >= 1.0) {
        color = vec3(0.0,0.0,0.0);
    }
    
    f_color = vec4(color,1.0);
}
