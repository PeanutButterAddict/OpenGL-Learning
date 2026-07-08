#version 330 core

#define TAU 6.2831853071
#define PI 3.14159265359
#define HALF_PI 1.5707963267948966

out vec4 f_color;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// NOTE: nst -> new st, lb -> left bottom, rt -> right top
void rect(in float width, in float height, in float edge_width, in vec2 offset, in vec2 st, out vec3 color) {
    vec2 nst = st - offset;
    vec2 lb_edge = (1.0 - vec2(width, height)) * 0.5;
    vec2 lb_pct = smoothstep(lb_edge - edge_width, lb_edge, nst);
    vec2 rt_pct = smoothstep(lb_edge, lb_edge + edge_width, 1.0 - nst);
    float pct = lb_pct.x * lb_pct.y * rt_pct.x * rt_pct.y;
    color = vec3(pct);
}

// NOTE: or -> outer rectangle, ir -> inner rectangle
void rect_outline(in float width, in float height, in float outline_width, in float edge_width, in vec2 offset, in vec2 st, out vec3 color) {
    vec3 or = vec3(0.0);
    rect(width, height, edge_width, offset, st, or);
    vec3 ir = vec3(0.0);
    rect(width - outline_width, height - outline_width, edge_width, offset, st, ir);
    color = or - ir;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution;
    vec3 color = vec3(0.0);
    rect_outline(0.4, 0.3, 0.01, 0.002, vec2(0.1, 0.2), st, color);
    f_color = vec4(color, 1.0);
}
