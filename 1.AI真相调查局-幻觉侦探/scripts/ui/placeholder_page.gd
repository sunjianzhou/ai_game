extends Control
# 占位页统一返回逻辑：BackButton → GameFlow.back()（previous_page 非法时降级回主菜单）。


func _ready() -> void:
	$CenterContainer/VBoxContainer/BackButton.pressed.connect(_on_back_pressed)


func _on_back_pressed() -> void:
	GameFlow.back()
