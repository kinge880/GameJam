extends KinematicBody2D

export var speed = 200
var velocity = Vector2()

func _physics_process(delta):
	velocity = Vector2()
	look_at(get_global_mouse_position())
	
	#movimentação de teste 1
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2(0, speed)
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2(0, -speed)
	if Input.is_action_pressed("ui_left"):
		velocity = Vector2(-speed, 0)
	if Input.is_action_pressed("ui_right"):
		velocity = Vector2(speed, 0)
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	else:
		velocity = Vector2(0, 0)
	
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
	velocity = move_and_slide(velocity, Vector2(0,0))