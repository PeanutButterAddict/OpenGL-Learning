#version 330 core

#define PI 3.14159265359

out vec4 f_color;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// NOTE: If in curve, will be 1, if not will be 0 for step().
// Smooth step is step but just interpolates to the edge width.
float plot(vec2 st, float y, float width) {
    return smoothstep(y - width, y, st.y) - smoothstep(y, y + width, st.y);
}

void main() {
    // NOTE: Normalised coordinates
    vec2 st = gl_FragCoord.xy / u_resolution;
    // NOTE: Shape Function
    float y = pow(st.x, 5.0);
    // NOTE: The curve shows value of y with respective to x.
    float in_curve = plot(st, y, 0.02);
    // NOTE: bg_color shows how the function affects colors
    // by setting all 3 rgb with the same values.
    vec3 bg_color = vec3(y);
    // NOTE: (1.0 - in_curve) * bg_color keeps bg_color in bg with keeping the curve clear.
    // + in_curve * curve_color adds the curve with the new color.
    vec3 curve_color = vec3(0.0, 1.0, 0.0);
    vec3 color = (1.0 - in_curve) * bg_color + in_curve * curve_color;
    f_color = vec4(color, 1.0);
}
