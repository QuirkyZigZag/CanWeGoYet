shader_type canvas_item;

uniform float size = 0.4;
uniform float intensity = 0.7;
uniform float frame_time = 0.17;

uniform vec2 light_direction = vec2(-0.483, 0.866); // 2D light direction
uniform sampler2D hatch;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float hatch_size = 1.0;

void fragment() {
    // Snap time to frame_time
    float rounded_time = round(TIME / frame_time) * frame_time;

    // Simulate a "height" distortion in 2D
    float heightX = pow(abs(cos(UV.y * size + rounded_time * 10.0)), 0.5) * intensity
                  - pow(abs(cos(UV.x * size * 0.7 + rounded_time * 5.0)), 0.5) * intensity * 1.3;
    float heightY = pow(abs(cos(UV.x * size + rounded_time * 15.0)), 0.5) * intensity
                  - pow(abs(cos(UV.y * size * 0.7 + rounded_time * 10.0)), 0.5) * intensity * 1.3;

    // Combine into a mask
    float NdotL = dot(normalize(vec2(heightX, heightY)), normalize(light_direction));

    float mask = 1.0;

    if (NdotL < 0.5) {
        mask *= texture(hatch, UV * hatch_size + rounded_time).r * 2.0 - 1.0;
        mask = clamp(mask, 0.0, 1.0);
    }
    if (NdotL < 0.1) {
        mask *= texture(hatch, vec2(UV.x, 1.0 - UV.y) * hatch_size + rounded_time).r * 2.0 - 1.0;
        mask = clamp(mask, 0.0, 1.0);
    }

    COLOR = mix(vec4(0.0), color, mask);
}
