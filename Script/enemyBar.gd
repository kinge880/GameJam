extends Node2D

func _ready():
	pass

func _update_lifeBar(life):
	print(life)
	$EnemyLifeBar.value = life
	#$LifeBarTween.interpolate_property($EnemyLifeBar,'value', $EnemyLifeBar.value, life, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#$LifeBarTween.start()
	#$AnimationPlayer.play("lifeBar_flash")
	
	"""
	if life < 40:
		$Margin/Recipe/LifeBar.tint_progress = Color(1, 0, 0)
	else:
		$Margin/Recipe/LifeBar.tint_progress = Color(0, 0.039216, 1)
	"""

func _process(delta):
    global_rotation = 0


func _on_Enemy_life_changed(life):
	_update_lifeBar(life)
