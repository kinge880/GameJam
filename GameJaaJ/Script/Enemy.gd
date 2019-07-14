extends KinematicBody2D

export var speed = 200
onready var raycast = $RayCast2D
var player = null

func _ready():
	add_to_group("enemy")
	
func _process(delta):
	if player == null:
		return
		
	var to_player = player.global_position - global_position
	print("oi")
	to_player = to_player.normalized()
	global_rotation = atan2(to_player.y, to_player.x)
	move_and_collide(to_player * speed * delta)
	
	if raycast.is_colliding():
		var collision = raycast.get_collider()
		print(collision)
		if collision.name == "Player":
			collision._death()

func _kill():
	queue_free()

func _set_player(body):
	player = body