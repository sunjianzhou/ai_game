shader_type canvas_item;

// 档案室氛围背景：深蓝灰渐变 + 左上暖色台灯微光 + 缓慢呼吸漂移
uniform float time_scale = 0.08;

void fragment() {
	vec2 p = UV;
	float drift = sin(TIME * time_scale) * 0.03;
	p.x += drift;

	// 垂直渐变：上深下略浅
	vec3 top = vec3(0.078, 0.094, 0.129);      // #141821
	vec3 bottom = vec3(0.110, 0.129, 0.165);   // 略浅的冷蓝灰
	vec3 color = mix(top, bottom, p.y);

	// 左上角暖色台灯微光（缓慢呼吸）
	float breathe = 0.5 + 0.5 * sin(TIME * 0.4);
	float d = distance(p, vec2(0.12, 0.08));
	float glow = smoothstep(0.55, 0.0, d) * 0.07 * (0.8 + 0.2 * breathe);
	color += vec3(0.91, 0.87, 0.78) * glow;

	// 极淡的扫描线纹理（纸张感，几乎不可见）
	float scan = 0.985 + 0.015 * sin(UV.y * 400.0);
	color *= scan;

	COLOR = vec4(color, 1.0);
}
