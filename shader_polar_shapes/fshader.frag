#version 330 core

#define TAU 6.2831853071
#define PI 3.14159265359
#define HALF_PI 1.5707963267948966

out vec4 f_color;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// NOTE: Tweak and play to learn the Polar Shapes technique.

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    vec3 color = vec3(0.0);

    vec2 pos = vec2(0.5) - st;

    // NOTE: r -> radius, a -> angle,
    //  f -> float / y given by shape function
    float r = length(pos) * 2.0;
    float a = atan(pos.y, pos.x);

    float f = cos(a * 3.);
    // f = abs(cos(a*3.));
    // f = abs(cos(a*2.5))*.5+.3;
    // f = abs(cos(a*12.)*sin(a*3.))*.8+.1;
    // f = smoothstep(-.5,1., cos(a*10.))*0.2+0.5;

    color = vec3(1. - smoothstep(f, f + 0.02, r));

    f_color = vec4(color, 1.0);
}
