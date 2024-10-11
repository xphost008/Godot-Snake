extends Node2D

# 赋值~
func _on_ract_button_pressed() -> void:
	$CurrentScene.text = "当前选中：" + $RactButton.text
	Global.scene = 1


func _on_circle_button_pressed() -> void:
	$CurrentScene.text = "当前选中：" + $CircleButton.text
	Global.scene = 2


func _on_bridge_button_pressed() -> void:
	$CurrentScene.text = "当前选中：" + $BridgeButton.text
	Global.scene = 3


func _on_windmill_button_pressed() -> void:
	$CurrentScene.text = "当前选中：" + $WindmillButton.text
	Global.scene = 4


func _on_start_game_pressed() -> void:
	# 开始游戏的书写
	var current_speed = str($SpeedEdit.text)
	var speed_int = current_speed.to_int()
	# 如果输入的值等于纯数字，并且大于0小于20，则赋值正确，否则按照默认值4判断。
	if str(speed_int) == current_speed and speed_int > 0 and speed_int <= 20:
		Global.speed = speed_int
	get_tree().change_scene_to_file("res://GameScene.tscn")
