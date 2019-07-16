extends KinematicBody2D

const Util = preload("res://Script/utils.gd")

export var speed = 200
var motion = Vector2()
onready var raycast = $RayCast2D

export var acc = 0.1
export var dec = 0.05

func _ready():
	yield(get_tree(), "idle_frame")
	#passa a instancia de player a todos no grupo "enemy" que possuem a função "_set_player"
	get_tree().call_group("enemy", "_set_player", self)
	
func _process(delta):
	var movedir = Vector2()
	
	if Input.is_action_pressed("ui_down"):
		movedir += Vector2(0, 1)
	if Input.is_action_pressed("ui_up"):
		movedir += Vector2(0, -1)
	if Input.is_action_pressed("ui_left"):
		movedir += Vector2(-1, 0)
	if Input.is_action_pressed("ui_right"):
		movedir += Vector2(1, 0)
	
	if movedir != Vector2():
		motion = motion.linear_interpolate(movedir.normalized(), acc)
		rotation = Util.lerp_angle(rotation, motion.angle(), 0.1)
	else:
		motion = motion.linear_interpolate(Vector2(), dec)
	
	move_and_slide(motion * speed)
	
	#atacar, podemos modificar aqui pra fazer do jeito que preferimos, deixei assim de inicio pra ter uma base
	if Input.is_action_pressed("atk"):
		var collision = raycast.get_collider()
		if raycast.is_colliding() and collision.has_method("_kill"):
			collision._kill()

#função para ativar a situação escolhida de "morte"
func _death():
	get_tree().reload_current_scene()