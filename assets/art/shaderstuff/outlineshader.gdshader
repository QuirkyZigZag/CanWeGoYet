shader_type spatial;
render_mode unshaded, depth_draw_opaque, depth_prepass_alpha, fog_disabled;

///////////////////////////////////////////////////////
// UNIFORMS
///////////////////////////////////////////////////////

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;
uniform sampler2D distance_curve;

uniform vec3 shadow_color : source_color = vec3(0.0);
uniform float shadow_thickness = 2.0;
uniform float aberration_strength : hint_range(0.0, 1.0) = 0.05;

///////////////////////////////////////////////////////
// DEPTH HELPER
///////////////////////////////////////////////////////

vec2 getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_projection_matrix){
    float raw_depth = texture(depth_texture, screen_uv)[0];
    vec3 ndc = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(ndc, 1.0);
    view_space.xyz /= view_space.w;
    return vec2(-view_space.z, raw_depth);
}

///////////////////////////////////////////////////////
// FRAGMENT
///////////////////////////////////////////////////////

void fragment() {
    vec2 e = vec2(1.0 / VIEWPORT_SIZE.xy);

    // Read base depth
    vec2 depth_data = getDepth(SCREEN_UV, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
    float depth = depth_data.x;

    vec3 normal = texture(NORMAL_TEXTURE, SCREEN_UV).rgb * 2.0 - 1.0;
    vec3 c = vec3(0.0);
    vec2 min_depth_data = depth_data;
    float min_depth = 1e20;
    float depth_diff = 0.0;

    // SCREEN-SPACE SHADOW / OUTLINE
    for (float x = -shadow_thickness; x <= shadow_thickness; x += 1.0){
        for (float y = -shadow_thickness; y <= shadow_thickness; y += 1.0){
            if ((x == 0.0 && y == 0.0) || (shadow_thickness*shadow_thickness < (x*x + y*y))){
                continue;
            }

            vec2 du_data = getDepth(SCREEN_UV + vec2(x, y) * e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
            vec2 dd_data = getDepth(SCREEN_UV + 0.5 * vec2(x, y) * e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);

            float du = du_data.x;
            float dd = dd_data.x;

            float dd_diff = clamp(abs((depth - dd) - (dd - du)), 0.0, 1.0);
            float val = clamp(abs(depth - du), 0.0, 1.0) / (x*x + y*y) * dd_diff * dd_diff * 5000.0;
            val = clamp(val, 0.0, 1.0);
            depth_diff += val;

            if (du < min_depth){
                min_depth = du;
                min_depth_data = du_data;
                c = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(x, y) * e).rgb;
                c *= clamp(0.5 + 0.5 * dot(normalize(vec2(x, y)), vec2(0.0, 1.0)), 0.0, 1.0);
            }

            vec3 nu = texture(NORMAL_TEXTURE, SCREEN_UV + vec2(x, y) * e).rgb * 2.0 - 1.0;
            depth_diff += (1.0 - abs(dot(nu, normal))) / max(min(dd, depth), 2.0);
        }
    }

    depth_diff = smoothstep(0.2, 0.3, depth_diff);

    // Shadowed color
    vec3 shadowed_color = c * shadow_color;

    // Slight lift to make aberration visible even in low saturation
    shadowed_color = mix(shadowed_color, vec3(0.5), 0.2);

    ///////////////////////////////////////////////////////
    // CHROMATIC ABERRATION
    ///////////////////////////////////////////////////////

    vec2 dir = SCREEN_UV - vec2(0.5);
    float dist = length(dir);
    float curve_intensity = texture(distance_curve, vec2(dist, 0.0)).r;
    vec2 offset = dir * aberration_strength * curve_intensity;

    float red   = texture(SCREEN_TEXTURE, SCREEN_UV - offset * 0.5).r;
    float green = shadowed_color.g;
    float blue  = texture(SCREEN_TEXTURE, SCREEN_UV - offset).b;

    vec3 final_color = vec3(red, green, blue);

    ALBEDO = final_color;

    // Alpha & Depth
    float alpha_mask = depth_diff;
    ALPHA = clamp(alpha_mask * 0.8 + 0.2, 0.0, 1.0);
    DEPTH = min_depth_data.y * alpha_mask + depth_data.y * (1.0 - alpha_mask);
}
