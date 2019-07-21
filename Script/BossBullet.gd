extends Area2D

export var speed = 350
export var damage = 1
var velocity = Vector2()
onready var tween = get_node("Tween")

#essa função é chamada assim que a bala é instanciada
func _start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	velocity = _direction.normalized()
	$Lifetime.start()
	$MiniBallSound.play()
	tween.interpolate_property(self, "speed", speed, 0, 4, Tween.TRANS_QUART, Tween.EASE_IN)
	tween.start()
	modulate = Color.plum

func _process(delta):
	global_position += velocity * delta  * speed

func _dimiss():
	queue_free()

func _on_Bullet_body_entered(body):
	#caso bata em algo ela some (no futuro podemos colcoar mais coisas como uma explosão)
	_dimiss()
	if body.has_method('_take_damage'):
		body._take_damage(damage)

func _on_Lifetime_timeout():
		#caso não bata em nada, ela some apos um tempo igual a lifetime
	_dimiss()
