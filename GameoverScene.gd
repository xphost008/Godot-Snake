extends Node2D

func _ready() -> void:
	var b = $OverScore
	# 获取Global.score，并赋值为分数
	b.text = "分数：" + str(Global.score)
	# 将score重新赋值为0
	Global.score = 0
	# 将speed重新赋值为4
	Global.speed = 4
	# 将scene重新赋值为1
	Global.scene = 1

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainScene.tscn")
	
func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://DifficultyScene.tscn")
