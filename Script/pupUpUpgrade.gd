extends Node2D
func _ready():
	get_tree().paused = true
	global_rotation = 0
	
#pausa o jogo com a tecla esc
func _input(event):
	if Input.is_action_just_released("ui_accept") or Input.is_action_just_released("atk") :
		get_tree().paused = false
		$".".hide()