extends Area2D

export var speed = 750
export var damage = 10
export var lifetime = 0.8
var velocity = Vector2()

#essa função é chamada assim que a bala é instanciada
func _start(_position, _direction):
	position = _position
	rotation = _direction.angle()
	$Lifetime.wait_time = lifetime
	velocity = _direction * speed

func _process(delta):
	position += velocity * delta

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
