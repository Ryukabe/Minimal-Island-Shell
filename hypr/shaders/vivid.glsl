#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    vec3 c = color.rgb;

    // ------------------------------------------------------------
    // Vibrance
    // Boost weaker colors more than already-saturated colors.
    // ------------------------------------------------------------
    float maxC = max(c.r, max(c.g, c.b));
    float minC = min(c.r, min(c.g, c.b));
    float saturation = maxC - minC;

    float vibrance = 0.18;
    float vibranceBoost = (1.0 - saturation) * vibrance;

    float luma = dot(c, vec3(
        0.2126,
        0.7152,
        0.0722
    ));

    c = mix(vec3(luma), c, 1.0 + vibranceBoost);

    // ------------------------------------------------------------
    // Saturation
    // ------------------------------------------------------------
    float saturationBoost = 1.12;

    luma = dot(c, vec3(
        0.2126,
        0.7152,
        0.0722
    ));

    c = mix(vec3(luma), c, saturationBoost);

    // ------------------------------------------------------------
    // Contrast
    // ------------------------------------------------------------
    float contrast = 1.06;
    c = (c - 0.5) * contrast + 0.5;

    // ------------------------------------------------------------
    // Slight brightness lift
    // ------------------------------------------------------------
    c *= 1.015;

    // Keep everything inside displayable range.
    c = clamp(c, 0.0, 1.0);

    fragColor = vec4(c, color.a);
}