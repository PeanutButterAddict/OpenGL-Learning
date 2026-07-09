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
// The circle dot product function given by Book of Shaders is horrendously wrong.
// Use mine instead.
// Achieved by comparing magnitude square of direction vector
// from center of circle and magnitude of radius square.
// As there is no less than version of step, have to invert the value given by step.
float my_circle(in float _r, in vec2 _offset, in float _ew, in vec2 _st) {
    vec2 dist = _st - _offset;
    float rsq = _r * _r;
    return 1.0 - smoothstep(rsq - _ew, rsq, dot(dist, dist));
}

// NOTE: Bad horrendous inaccurate version by Book of Shaders
// Also the center would have to be adjusted according to pw later
// Comment out pw declaration in main in case to not want to.
// It has to take a radius of 0.9 to compare to my 0.2
// which actually represents a 0.2 circle radius on screen.
float circle(in vec2 _st, in float _radius) {
    vec2 dist = _st - vec2(0.5);
    return 1. - smoothstep(_radius - (_radius * 0.01),
            _radius + (_radius * 0.01),
            dot(dist, dist) * 4.0);
}

// NOTE: pw -> pixel width
void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    // NOTE: Comment out pw to use book of shader's circle or adjust that function to accept pw.
    float pw = u_resolution.x / u_resolution.y;
    // NOTE: Scaled the x axis from 0-1 to 0-pw.
    // The whole window no longer represents 0-1, at least on the x axis.
    // If no changes are made to any positions after this,
    // they all will take place in the space of 0-1
    // which no longer covers the whole window but only the bottom left or left.
    st.x *= pw;
    vec3 color = vec3(my_circle(0.2, npos(vec2(0.5), pw), 0.002, st));

    f_color = vec4(color, 1.0);
}
