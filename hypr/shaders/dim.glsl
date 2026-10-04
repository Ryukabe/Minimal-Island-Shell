#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    vec3 c = color.rgb;

    // ------------------------------------------------------------
    // Soften colors
    // Below 1.0 pulls colors toward gray.
    // ------------------------------------------------------------
    float saturationAmount = 0.90;

    float luma = dot(c, vec3(
        0.2126,
        0.7152,
        0.0722
    ));

    c = mix(vec3(luma), c, saturationAmount);

    // ------------------------------------------------------------
    // Low contrast
    // Below 1.0 lifts the blacks and lowers the whites.
    // ------------------------------------------------------------
    float contrast = 0.88;
    c = (c - 0.5) * contrast + 0.5;

    // ------------------------------------------------------------
    // Dim
    // ------------------------------------------------------------
    float brightness = 0.92;
    c *= brightness;

    // Keep everything inside displayable range.
    c = clamp(c, 0.0, 1.0);

    fragColor = vec4(c, color.a);
}
