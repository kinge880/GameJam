extends Node2D
var count = 0

func _ready():
	$AnimationPlayer.play("entry")
	
func _on_NewGame_pressed():
	get_tree().change_scene("res://Word.tscn")

func _on_Exit_pressed():
	get_tree().quit()
	
func _on_Keys_pressed():
	$MapKey.show()

func _on_Return_pressed():
	$MapKey.hide()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		get_tree().paused = false
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		get_tree().paused = true
