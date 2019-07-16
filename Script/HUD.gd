extends CanvasLayer

func _update_lifeBar(life):
	$Margin/Recipe/LifeBar/Tween.interpolate_property($Margin/Recipe/LifeBar,'value', $Margin/Recipe/LifeBar.value, life, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Margin/Recipe/LifeBar/Tween.start()
	$AnimationPlayer.play("lifeBar_flash")
	
	"""
	if life < 40:
		$Margin/Recipe/LifeBar.tint_progress = Color(1, 0, 0)
	else:
		$Margin/Recipe/LifeBar.tint_progress = Color(0, 0.039216, 1)
	"""
func _update_staminaBar(stamina):
	$Margin/Recipe/StaminaBar/Tween.interpolate_property($Margin/Recipe/StaminaBar,'value', $Margin/Recipe/StaminaBar.value, stamina, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Margin/Recipe/StaminaBar/Tween.start()
	"""if stamina < 30:
		$Margin/Recipe/StaminaBar.tint_progress = Color(0.54902, 0.54902, 0.545098)
	else:
		$Margin/Recipe/StaminaBar.tint_progress = Color(Color(0, 1, 0.039063))
	"""
func _on_Player_life_changed(life):
	_update_lifeBar(life)

func _on_Player_stamina_changed(stamina):
	_update_staminaBar(stamina)


func _on_AnimationPlayer_animation_finished(anim_name):
	  if anim_name == 'lifeBar_flash':
        $Margin/Recipe/LifeBar.tint_progress = Color(1, 0, 0)
