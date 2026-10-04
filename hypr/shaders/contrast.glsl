#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    vec3 c = color.rgb;

    // ------------------------------------------------------------
    // Black and white
    // Same luma weights as the other shaders.
    // ------------------------------------------------------------
    float luma = dot(c, vec3(
        0.2126,
        0.7152,
        0.0722
    ));

    c = vec3(luma);

    // ------------------------------------------------------------
    // High contrast
    // Above 1.0 pushes darks darker and lights lighter around mid-gray.
    // Raise it for a harsher look; around 2.0+ most midtones clip.
    // ------------------------------------------------------------
    float contrast = 1.5;
    c = (c - 0.5) * contrast + 0.5;

    // Keep everything inside displayable range.
    c = clamp(c, 0.0, 1.0);

    fragColor = vec4(c, color.a);
}
