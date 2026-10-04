#version 300 es

precision mediump float;

in vec2 v_texcoord;
layout(location = 0) out vec4 fragColor;

uniform sampler2D tex;

void main() {
    vec4 color = texture(tex, v_texcoord);
    vec3 c = color.rgb;

    // ------------------------------------------------------------
    // Brightness
    // Same luma weights as vivid.glsl and gray.glsl.
    // ------------------------------------------------------------
    float luma = dot(c, vec3(
        0.2126,
        0.7152,
        0.0722
    ));

    // ------------------------------------------------------------
    // Paper tint
    // Black stays black, white becomes warm cream.
    // 1.0 = fully sepia, lower values let some color back in.
    // ------------------------------------------------------------
    vec3 paperTone = vec3(1.0, 0.94, 0.82);
    float sepiaAmount = 1.0;

    c = mix(c, luma * paperTone, sepiaAmount);

    // Keep everything inside displayable range.
    c = clamp(c, 0.0, 1.0);

    fragColor = vec4(c, color.a);
}
