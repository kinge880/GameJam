extends KinematicBody2D

export var speed = 300
var motion = Vector2()
onready var raycast = $RayCast2D

func _ready():
	yield(get_tree(), "idle_frame")
	get_tree().call_group("enemy", "_set_player", self)
	
func _process(delta):
	motion = Vector2()
	look_at(get_global_mouse_position())
	#var look_mouse = get_global_mouse_position() - global_position
	
	#Movimentos basicos
	#movimentação de teste 1
	if Input.is_action_pressed("ui_down"):
		motion += Vector2(0, 1)
	if Input.is_action_pressed("ui_up"):
		motion += Vector2(0, -1)
	if Input.is_action_pressed("ui_left"):
		motion += Vector2(-1, 0)
	if Input.is_action_pressed("ui_right"):
		motion += Vector2(1, 0)
	
	motion = motion.normalized() * speed
	
	
	"""
	 #movimentação de teste 2
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2(-speed, 0).rotated(rotation)
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2(speed, 0).rotated(rotation)
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	else:
		velocity = Vector2(0, 0)
	"""
	"""
	#movimentação de teste 3
	if Input.is_action_pressed("ui_down"):
		velocity.y += speed
	if Input.is_action_pressed("ui_up"):
		velocity.y -= speed
	if Input.is_action_pressed("ui_left"):
		velocity.x -= speed
	if Input.is_action_pressed("ui_right"):
		velocity.x += speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	else:
		velocity.x = 0
		velocity.y = 0
		"""
	#move_and_collide(motion * delta)
	move_and_slide(motion)
	
	#atk
	if Input.is_action_pressed("atk"):
		var collision = raycast.get_collider()
		print(collision)
		if raycast.is_colliding() and collision.has_method("_kill"):
			collision._kill()

func _death():
	get_tree().reload_current_scene()