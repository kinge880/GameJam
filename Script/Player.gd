extends KinematicBody2D

const Util = preload("res://Script/utils.gd")

export var speed = 200
export var dash_speed = 800
export var walk_speed = 200
var motion = Vector2()
onready var raycast = $RayCast2D
export (PackedScene) var Bullet
signal shoot
var can_shoot = true
export var acc = 0.5
export var dec = 0.1

func _ready():
	yield(get_tree(), "idle_frame")
	#passa a instancia de player a todos no grupo "enemy" que possuem a função "_set_player"
	get_tree().call_group("enemy", "_set_player", self)
	
func _process(delta):
	var movedir = Vector2()
	$weapon.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("dash"):
		_dash()
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
		_shoot()
		#var collision = raycast.get_collider()
		#if raycast.is_colliding() and collision.has_method("_kill"):
			#collision._kill()
func _dash():
	$CollisionShape2D.disabled = true
	speed = dash_speed
	$DashTimer.start()
#função para ativar a situação escolhida de "morte"
func _death():
	get_tree().reload_current_scene()

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight

func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func _shoot():
	#a bala ta feia e simples ainda, quando formos atras do sprite dele a gente organiza bonitinho
	if can_shoot:
		#can_shoot = false
		#esse global_rotation no futuro vai ser substituido por $weapon.global_rotation, pois vamos criar esferas ou uma linha como arma ne
		#dai eu acredito que ela pdoe rotacionar na direção do mouse e a bala sair dela, dai já preparei tudo pra isso
		var dir = Vector2(1, 0).rotated($weapon.global_rotation)
		#emito um sinal com a bala,posição do player(no futuro vai ser do portal) e a direção que no futuro vai ser dir
		emit_signal('shoot', Bullet, $weapon.global_position, dir)


func _on_Timer_timeout():
	$CollisionShape2D.disabled = false
	speed = walk_speed
