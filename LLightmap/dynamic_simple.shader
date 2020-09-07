shader_type spatial;
render_mode unshaded;
//render_mode world_vertex_coords;

uniform sampler2D texture_albedo : hint_albedo;
uniform vec3 light_pos;
uniform vec4 light_color;
uniform vec4 light_indirect;

varying vec3 v_specular;

void vertex() {
	// get view pos from camera matrix
	vec4 view_pos = vec4(0);
	view_pos = CAMERA_MATRIX * view_pos;
	
	// view direction
	vec3 vdir = VERTEX - view_pos.xyz;
	vdir = normalize(vdir);
	
	vec3 ldir = (light_pos) - VERTEX;
	
	float dist = length(ldir);
	ldir *= (1.0 / dist);
	//offset = normalize(offset);
	
	float d = dot(NORMAL, ldir);
	
	// use dot product to calculate reflection vector
	vec3 rdir = ldir - (d * 2.0 * NORMAL);
	
	// specular light depends on dot reflection to view dir
	float dot_refl = -dot(vdir, rdir);
	float spec = max(0.0, dot_refl);
	
	//spec = pow(spec, 4);
	
	// apply light color power to spec
	//spec *= (light_color.r + light_color.g + light_color.b) * 0.333;
	
	// diffuse light, should be none from behind the surface
	d = max(0.0, d);
	
	// magic falloff, prevents divide by zero and more linear that just inverse square
	dist += 10.0;
	float falloff = 1.0 / (0.01 * (dist * dist));
	
	d *= max (0.0, falloff);
	
	
	//COLOR = vec4((light_color.rgb * (d + spec)) + light_indirect.rgb, 1);
	//COLOR = vec4(((light_color.rgb + light_indirect.rgb) * (d + spec)) + light_indirect.rgb, 1);
	//COLOR = vec4(vec3(spec), 1);
	COLOR = vec4(((light_color.rgb + light_indirect.rgb) * d) + light_indirect.rgb, 1);
	
	v_specular = spec * light_color.rgb;
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	
	vec3 spec = v_specular * (1.0 - albedo_tex.b);
	
	
	//ALBEDO = (COLOR.rgb + vec3(r)) * albedo_tex.rgb;
	ALBEDO = (COLOR.rgb + spec) * albedo_tex.rgb;
	//ALBEDO = COLOR.rgb * albedo_tex.rgb;
}