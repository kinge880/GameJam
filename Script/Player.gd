extends KinematicBody2D

export var speed = 200
var motion = Vector2()
onready var raycast = $RayCast2D

func _ready():
	yield(get_tree(), "idle_frame")
	#passa a instancia de player a todos no grupo "enemy" que possuem a função "_set_player"
	get_tree().call_group("enemy", "_set_player", self)
	
func _process(delta):
	motion = Vector2()
	look_at(get_global_mouse_position())
	#var look_mouse = get_global_mouse_position() - global_position
	
	#Movimentos basicos, fiz 3 deles pq to na duvida de qual fica melhor, escolhemos dps
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
		motion = Vector2(-speed, 0).rotated(rotation)
	if Input.is_action_pressed("ui_up"):
		motion = Vector2(speed, 0).rotated(rotation)
	if motion.length() > 0:
		motion = motion.normalized() * speed
	else:
		motion = Vector2(0, 0)
	"""
	"""
	#movimentação de teste 3
	if Input.is_action_pressed("ui_down"):
		motion.y += speed
	if Input.is_action_pressed("ui_up"):
		motion.y -= speed
	if Input.is_action_pressed("ui_left"):
		motion.x -= speed
	if Input.is_action_pressed("ui_right"):
		motion.x += speed
	if motion.length() > 0:
		motion = motion.normalized() * speed
	else:
		motion.x = 0
		motion.y = 0
		"""
	#motion = move_and_collide(motion * delta)
	motion = move_and_slide(motion)
		
	#atacar, podemos modificar aqui pra fazer do jeito que preferimos, deixei assim de inicio pra ter uma base
	if Input.is_action_pressed("atk"):
		var collision = raycast.get_collider()
		print(collision)
		if raycast.is_colliding() and collision.has_method("_kill"):
			collision._kill()

#função para ativar a situação escolhida de "morte"
func _death():
	get_tree().reload_current_scene()

#talvez iremos usar no futuro, essa função vai manter a camera fixa nos limites de um comodo
func set_camera_limits():
	#essa conexão vai ter que mduar dps
    var map_limits = $TileMap.get_used_rect()
    var map_cellsize = $TileMap.cell_size
    $Player/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
    $Player/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
    $Player/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
    $Player/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y