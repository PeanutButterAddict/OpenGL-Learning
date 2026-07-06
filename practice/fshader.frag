#version 330 core

#define PI 3.14159265359

out vec4 f_color;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

float plot(vec2 st, float y, float width) {
    return smoothstep(y - width, y, st.y) - smoothstep(y, y + width, st.y);
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    float y = pow(st.x, 5.0);
    float in_curve = plot(st, y, 0.02);
    vec3 bg_color = vec3(y);
    vec3 curve_color = vec3(0.0, 1.0, 0.0);
    vec3 color = (1.0 - in_curve) * bg_color + in_curve * curve_color;
    f_color = vec4(color, 1.0);
}
