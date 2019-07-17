extends KinematicBody2D

const Util = preload("res://Script/utils.gd")
const Bullet = preload("res://Bullets/Bullet.tscn")

export var speed = 200
export var dash_speed = 1000
export var walk_speed = 200
export var dash_time = 0.2
export var pos_dash_recovery_stamina_time = 5
export var current_life = 5
export var max_life = 5
export var current_stamina = 6
export var max_stamina = 6
export var stamina_cost = 3
var motion = Vector2()
signal shoot
signal life_changed
signal stamina_changed
#var can_shoot = true
onready var acc = 0.5
onready var dec = 0.1
var last_shot_time = 0
var shoot_cd = 250

var magazine = 3
var reloading = false

func _ready():
	yield(get_tree(), "idle_frame")
	#passa a instancia de player a todos no grupo "enemy" que possuem a função "_set_player"
	get_tree().call_group("enemy", "_set_player", self)
	emit_signal('life_changed', current_life * (100/max_life))

func _process(delta):
	
	var movedir = Vector2()
	$barrier.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("dash") and current_stamina > stamina_cost:
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
		$PlayerSprite.rotation = Util.lerp_angle($PlayerSprite.rotation, motion.angle(), 0.1)
		$CollisionShape2D.rotation = Util.lerp_angle($CollisionShape2D.rotation, motion.angle(), 0.1)
	else:
		motion = motion.linear_interpolate(Vector2(), dec)
	
	move_and_slide(motion * speed)
	
	#atacar, podemos modificar aqui pra fazer do jeito que preferimos, deixei assim de inicio pra ter uma base
	if Input.is_action_pressed("atk"):
		if !reloading:
			var now = OS.get_ticks_msec()
			if now - last_shot_time > shoot_cd:
				last_shot_time = now
				_shoot()

func _dash():
	current_stamina -= stamina_cost
	_stamine_changed()
	$StaminaRecoveryTime.stop()
	$wait_stamina_time.wait_time = pos_dash_recovery_stamina_time
	$wait_stamina_time.start()
	$DashTimer.wait_time = dash_time
	$DashTimer.start()
	speed = dash_speed
	
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
	if magazine < 1:
		pass
	else:
		var mspos = get_global_mouse_position()
		emit_signal('shoot', Bullet, global_position, mspos - global_position)
		magazine -= 1
		if magazine == 0:
			reload()
	#can_shoot = false
	#esse global_rotation no futuro vai ser substituido por $weapon.global_rotation, pois vamos criar esferas ou uma linha como arma ne
	#dai eu acredito que ela pdoe rotacionar na direção do mouse e a bala sair dela, dai já preparei tudo pra isso
	#var dir = Vector2(1, 0).rotated($weapon.global_rotation)
	#emito um sinal com a bala,posição do player(no futuro vai ser do portal) e a direção que no futuro vai ser dir

func reload():
	reloading = true
	
	for i in range(3):
		$RldTimer.start()
		yield($RldTimer, "timeout")
		magazine = i + 1
	
	reloading = false

func _on_DashTimer_timeout():
	speed = walk_speed

func _life_changed():
	emit_signal('life_changed', current_life * 100/max_life)

func _stamine_changed():
	emit_signal('stamina_changed', current_stamina * 100/max_stamina)
	
func _take_damage(damage):
	current_life -= damage
	_life_changed()
	if current_life <=0:
		_death()

func _on_StaminaRecoveryTime_timeout():
	if current_stamina < max_stamina:
		current_stamina += 1
		_stamine_changed()

func _on_wait_stamina_time_timeout():
	$StaminaRecoveryTime.start()
