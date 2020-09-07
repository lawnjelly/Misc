shader_type spatial;
//render_mode blend_mix;
render_mode unshaded;
//,depth_draw_opaque,cull_back;
//,diffuse_burley,specular_schlick_ggx;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_lightmap : hint_albedo;
uniform float emission;
uniform vec4 emission_color : hint_color;



void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	vec4 lightmap_tex = texture(texture_lightmap,UV2);//2
	
	float mult = 2.0;
	//mult *= abs(sin(TIME * 0.1) + sin(TIME * 4.43));
	vec3 alb = albedo_tex.rgb * lightmap_tex.rgb * mult;// + vec3(0.01);
	
	// soft knee
//	float mx = max(alb.r, alb.g);
//	mx = max(mx, alb.b);
//	mx -= 1.0;
//	mx = clamp(mx, 0.0, 1.0);
//	alb = mix(alb, vec3(1, 1, 1), mx);


	ALBEDO = alb;// + vec3(0.01);
	ALPHA = albedo_tex.a;

	// return 6.0 * rgbm.rgb * rgbm.a;
//	vec3 light = 16.0 * lightmap_tex.rgb * lightmap_tex.a;
//	vec3 light = vec3(16.0 * lightmap_tex.a);
//	ALBEDO = albedo_tex.rgb * light;// + vec3(0.01);
}

