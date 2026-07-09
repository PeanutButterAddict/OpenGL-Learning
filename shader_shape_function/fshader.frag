#version 330 core

#define TAU 6.2831853071
#define PI 3.14159265359
#define HALF_PI 1.5707963267948966

out vec4 f_color;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// NOTE: If in curve, will be 1, if not will be 0 for step().
// Smooth step is step but just interpolates to the edge width.
// pct stands for percentage,
// This function says
// "For a fragment what percentage to return?
// if the normalised y coordinate of the fragment is st.y,
// percent result y for st.x is pct
// and the width is w"
float plot(vec2 st, float pct, float w) {
    return smoothstep(pct - w, pct, st.y) - smoothstep(pct, pct + w, st.y);
}

void main() {
    // NOTE: Normalised coordinates
    vec2 st = gl_FragCoord.xy / u_resolution;
    // NOTE: Shape Function
    // float y = (sin(PI * (st.x - 0.5)) * 0.5) + 0.5;
    float y = sin(st.x) * HALF_PI;
    // NOTE: The curve shows value of y with respective to x.
    // pct stands for percentage, it is the percentage of colors to mix together.
    float pct = plot(st, y, 0.02);
    // NOTE: bg_color shows how the function affects colors
    // by setting all 3 rgb with the same values.
    vec3 bg_color = vec3(y);
    vec3 curve_color = vec3(0.0, 1.0, 0.0);
    // NOTE: (1.0 - in_curve) * bg_color keeps bg_color in bg with keeping the curve clear.
    // + in_curve * curve_color adds the curve with the new color.
    vec3 color = (1.0 - pct) * bg_color + pct * curve_color;
    f_color = vec4(color, 1.0);
}
