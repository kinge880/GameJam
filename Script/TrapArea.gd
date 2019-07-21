extends Area2D

var player_inside_effect = false
var damage = 5
#var armed = true

func _on_TrapArea_body_entered(body):
	if not body.name == "Player":
		return
	$Polygon2D.visible = true
	$ExplosionTimer.start()
	yield($ExplosionTimer, "timeout")
	$Explosion.emitting = true
	$ParticlesTimer.start()
	yield($ParticlesTimer, "timeout")
	if player_inside_effect:
		body._take_damage(damage)
	monitoring = false

func _on_EffectArea_body_entered(body):
	if body.name == "Player":
		player_inside_effect = true

func _on_EffectArea_body_exited(body):
	if body.name == "Player":
		player_inside_effect = false

#func _on_ExplosionTimer_timeout():
	#pass # Replace with function body.
