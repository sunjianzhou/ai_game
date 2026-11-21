class_name BackgroundUtil
# 给页面加"档案室"氛围动态背景（纯 shader，无贴图）


static func add_animated_background(parent: Control) -> void:
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/shaders/animated_background.gdshader")
	rect.material = mat
	parent.add_child(rect)
	parent.move_child(rect, 0)
