extends KinematicBody2D

export var speed = 50
onready var raycast = $RayCast2D
var player = null
var player_inside_area = false
var player_is_visible = false
var is_player = false
var enemy_position
func _ready():
	add_to_group("enemy")
	enemy_position = global_position
	
func _process(delta):
	if player == null:
		return
		
	if player_inside_area and player_is_visible and is_player:
		var to_player = player.global_position - global_position
		to_player = to_player.normalized()
		global_rotation = atan2(to_player.y, to_player.x)
		move_and_collide(to_player * speed * delta)
	else:
		var to_origin = enemy_position - global_position
		to_origin = to_origin.normalized()
		global_rotation = atan2(to_origin.y, to_origin.x)
		move_and_collide(to_origin * speed * delta)
		
	if raycast.is_colliding():
		var collision = raycast.get_collider()
		print(collision)
		if collision.name == "Player":
			collision._death()

func _kill():
	queue_free()

func _set_player(body):
	player = body

func _on_AreaMove_body_entered(body):
	if body.name == "Player":
		player_inside_area = true

func _on_AreaMove_body_exited(body):
	if body.name == "Player":
		player_inside_area = false

func _on_Visibility_body_entered(body):
	if body.name == "Player":
		$Sprite.self_modulate.r = 1.0
		player_is_visible = true
		is_player = true

func _on_Visibility_body_exited(body):
	if body.name == "Player":
		$Sprite.self_modulate.r = 0.2
		player_is_visible = false
		is_player = false