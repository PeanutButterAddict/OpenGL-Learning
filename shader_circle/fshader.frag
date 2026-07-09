#version 330 core

#define TAU 6.2831853071
#define PI 3.14159265359
#define HALF_PI 1.5707963267948966

out vec4 f_color;

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

// NOTE: New position after scaling with pixel width
vec2 npos(in vec2 pos, in float _pw) {
    return vec2(pos.x * _pw, pos.y);
}

// NOTE: _r -> radius, rsq -> radius square, _ew -> edge width
float my_circle(in float _r, in vec2 _offset, in float _ew, in vec2 _st) {
    vec2 dist = _st - _offset;
    float rsq = _r * _r;
    return 1.0 - smoothstep(rsq - _ew, rsq, dot(dist, dist));
}

// NOTE: pw -> pixel width
void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    float pw = u_resolution.x / u_resolution.y;
    st.x *= pw;
    vec3 color = vec3(my_circle(0.2, npos(vec2(0.5), pw), 0.002, st));

    f_color = vec4(color, 1.0);
}
