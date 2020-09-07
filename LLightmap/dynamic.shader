shader_type spatial;
render_mode unshaded;
//render_mode world_vertex_coords;
//render_mode skip_vertex_transform;

uniform sampler2D texture_albedo : hint_albedo;
uniform vec3 light_pos;
uniform vec4 light_color;
uniform vec4 light_indirect;
//uniform vec3 view_posu;

varying vec3 v_specular;

void vertex() {
	// get view pos from camera matrix
	
	//vec4 view_pos = vec4(view_posu, 1.0);
	
//	if (sin(TIME * 6.0) < 0.0)
//	{
	vec4 view_pos = vec4(0, 0, 0, 1);
	view_pos = CAMERA_MATRIX * view_pos;
//	}
	
	// absolute pain but there's a bug in the core shaders .. if skinning is applied
	// then using world_vertex_coords breaks the skinning. So we have to do the world
	// transform TWICE!! Once here, and once in the core shader.
	vec4 vert_world = WORLD_MATRIX * vec4(VERTEX, 1.0);
	
	// view direction
	vec3 vdir = vert_world.xyz - view_pos.xyz;
	vdir = normalize(vdir);
	
	vec3 ldir = (light_pos) - vert_world.xyz;
	
	float dist = length(ldir);
	ldir *= (1.0 / dist);
	//offset = normalize(offset);
	
	vec3 normal = normalize((WORLD_MATRIX * vec4(NORMAL, 0.0)).xyz);
	
	float d = dot(normal, ldir);
	
	// use dot product to calculate reflection vector
	vec3 rdir = ldir - (d * 2.0 * normal);
	
	// specular light depends on dot reflection to view dir
	float dot_refl = dot(vdir, rdir);
	float spec = max(0.0, dot_refl);
	
	//spec = pow(spec, 4);
	
	// apply light color power to spec
	//spec *= (light_color.r + light_color.g + light_color.b) * 0.333;
	
	// diffuse light, should be none from behind the surface
	d = max(0.0, d);
	
	// magic falloff, prevents divide by zero and more linear that just inverse square
	dist += 10.0;
	float falloff = 1.0 / (0.01 * (dist * dist));
	falloff = max (0.0, falloff);
	
	d *= falloff;
	spec *= falloff;
	
	// scale diffuse
	d *= 0.8;
	
	// test
	// d = 0.0;
	// spec = 0.0f;
	
	
	//COLOR = vec4((light_color.rgb * (d + spec)) + light_indirect.rgb, 1);
	//COLOR = vec4(((light_color.rgb + light_indirect.rgb) * (d + spec)) + light_indirect.rgb, 1);
	//COLOR = vec4(vec3(spec), 1);
	COLOR = vec4(((light_color.rgb + light_indirect.rgb) * d) + light_indirect.rgb, 1);
	v_specular = spec * light_color.rgb;
	
	// test
	//COLOR = vec4(abs(rdir.xyz), 1.0);
}

void fragment() {
	vec4 albedo_tex = texture(texture_albedo,UV);
	
	vec3 spec = v_specular * (1.0 - albedo_tex.b);
	
	
	//ALBEDO = (COLOR.rgb + vec3(r)) * albedo_tex.rgb;
	ALBEDO = (COLOR.rgb + spec) * albedo_tex.rgb;
	//ALBEDO = COLOR.rgb * albedo_tex.rgb;


//	ALBEDO = (spec) * albedo_tex.rgb;

	//ALBEDO = COLOR.rgb;
}