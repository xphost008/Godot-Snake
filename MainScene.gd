extends Node2D

# 开始游戏按钮点击
func _on_main_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://DifficultyScene.tscn")

# 帮助按钮点击
func _on_main_help_button_pressed() -> void:
	get_tree().change_scene_to_file("res://HelpScene.tscn")
