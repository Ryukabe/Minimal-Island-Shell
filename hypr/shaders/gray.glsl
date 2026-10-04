#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    vec3 c = color.rgb;

    // ------------------------------------------------------------
    // Grayscale
    // Same luma weights as vivid.glsl. 1.0 = fully black and white,
    // lower values let some color back in.
    // ------------------------------------------------------------
    float grayAmount = 1.0;

    float luma = dot(c, vec3(
        0.2126,
        0.7152,
        0.0722
    ));

    c = mix(c, vec3(luma), grayAmount);

    // ------------------------------------------------------------
    // Contrast
    // A little extra contrast keeps text readable once color is gone.
    // ------------------------------------------------------------
    float contrast = 1.05;
    c = (c - 0.5) * contrast + 0.5;

    // Keep everything inside displayable range.
    c = clamp(c, 0.0, 1.0);

    fragColor = vec4(c, color.a);
}
