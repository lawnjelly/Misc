shader_type spatial;
//render_mode blend_mix;
render_mode unshaded;
//,depth_draw_opaque,cull_back;
//,diffuse_burley,specular_schlick_ggx;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_lightmap : hint_albedo;
uniform float emission;
uniform vec4 emission_color : hint_color;
/*

uniform vec3 light_pos;
uniform vec4 light_color;

varying float SPEC;
void vertex() {
	// get view pos from camera matrix
	vec4 view_pos = vec4(0);
	view_pos = CAMERA_MATRIX * view_pos;
	
	// view direction
	vec3 vdir = VERTEX - view_pos.xyz;
	vdir = normalize(vdir);
	
	// test light pos
	vec3 lp = light_pos;
	
	vec3 ldir = lp - VERTEX;

	ldir.x = sin(TIME);
	ldir.z = cos(TIME);
	ldir.y = 0.5;

	
	float dist = length(ldir);
	ldir *= (1.0 / dist);
	//offset = normalize(offset);
	
	float d = dot(NORMAL, ldir);
	
	// use dot product to calculate reflection vector
	vec3 rdir = ldir - (d * 2.0 * NORMAL);
	
	// specular light depends on dot reflection to view dir
	float dot_refl = -dot(vdir, rdir);
	float spec = max(0.0, dot_refl);
	
	spec = pow(spec, 4);
	SPEC = spec;
	//COLOR = vec4(vec3(spec), 1);
	
}
*/
void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	vec4 lightmap_tex = texture(texture_lightmap,UV2);//2
	
	float mult = 2.0;
	//mult *= abs(sin(TIME * 0.01) + sin(TIME * 0.43));
	//mult *= SPEC;
	
	//mult *= 0.2 + (SPEC * albedo_tex.b * 3.0);
	
	vec3 alb = albedo_tex.rgb * (lightmap_tex.rgb * mult);// + vec3(0.01);
	
	//alb += albedo_tex.rgb * SPEC;
//	vec3 alb = albedo_tex.rgb * lightmap_tex.rgb * mult;// + vec3(0.01);
	
	// soft knee
//	float mx = max(alb.r, alb.g);
//	mx = max(mx, alb.b);
//	mx -= 1.0;
//	mx = clamp(mx, 0.0, 1.0);
//	alb = mix(alb, vec3(1, 1, 1), mx);


	ALBEDO = alb;// + vec3(0.01);

	// return 6.0 * rgbm.rgb * rgbm.a;
//	vec3 light = 16.0 * lightmap_tex.rgb * lightmap_tex.a;
//	vec3 light = vec3(16.0 * lightmap_tex.a);
//	ALBEDO = albedo_tex.rgb * light;// + vec3(0.01);
}

