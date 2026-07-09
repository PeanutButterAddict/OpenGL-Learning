#version 330 core

#define TAU 6.2831853071
#define PI 3.14159265359
#define HALF_PI 1.5707963267948966

out vec4 f_color;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec2 npos(in vec2 pos, in float _pw) {
    return vec2(pos.x * _pw, pos.y);
}

// NOTE: This technique is pretty cracked!
// Practice and play around with it to get better insight.

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    float pw = u_resolution.x / u_resolution.y;
    st.x *= u_resolution.x / u_resolution.y;
    vec3 color = vec3(0.0);
    float d = 0.0;

    // Remap the space to -1. to 1.
    st = st * 2.0 - 1.0;

    // Make the distance field
    d = length(abs(st) - 0.3);
    d = length(min(abs(st) - 0.3, 0.));
    d = length(max(abs(st) - 0.3, 0.));

    // Visualize the distance field
    gl_FragColor = vec4(vec3(fract(d * 10.0)), 1.0);

    // Drawing with the distance field
    gl_FragColor = vec4(vec3(step(0.3, d)), 1.0);
    gl_FragColor = vec4(vec3(step(0.3, d) * step(d, 0.4)), 1.0);
    gl_FragColor = vec4(vec3(smoothstep(0.3, 0.4, d) * smoothstep(0.6, 0.5, d)), 1.0);

    // NOTE: I figured a way to color extra fragments
    gl_FragColor = vec4(vec3(smoothstep(0.3, 0.4, d) * smoothstep(0.6, 0.5, d))
                + (step(1.0, st.x) + step(1.0, st.y)) * vec3(0.0, 1.0, 1.0), 1.0);
    // NOTE: And to color those pixels black by masking
    gl_FragColor = vec4(vec3(smoothstep(0.3, 0.4, d) * smoothstep(0.6, 0.5, d))
                * (1.0 - (step(1.0, st.x) * step(1.0, st.y))), 1.0);
}
