extends KinematicBody2D

export var speed = 300
var velocity = Vector2()
onready var raycast = $RayCast2D

func _ready():
	yield(get_tree(), "idle_frame")
	#passa a instancia de player a todos no grupo "enemy" que possuem a função "_set_player"
	get_tree().call_group("enemy", "_set_player", self)
	
func _physics_process(delta):
	velocity = Vector2()
	look_at(get_global_mouse_position())
	#var look_mouse = get_global_mouse_position() - global_position
	
	#Movimentos basicos, fiz 3 deles pq to na duvida de qual fica melhor, escolhemos dps
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
	velocity = move_and_collide(velocity * delta)
	
	#atacar, podemos modificar aqui pra fazer do jeito que preferimos, deixei assim de inicio pra ter uma base
	if Input.is_action_pressed("atk"):
		var collision = raycast.get_collider()
		print(collision)
		if raycast.is_colliding() and collision.has_method("_kill"):
			collision._kill()

#função para ativar a situação escolhida de "morte"
func _death():
	get_tree().reload_current_scene()