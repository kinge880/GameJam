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
#export (PackedScene) var Bullet
signal shoot
signal life_changed
signal stamina_changed
var can_shoot = true
export var acc = 0.5
export var dec = 0.1
var last_shot_time = 0
var shoot_cd = 250

var RotateSpeed = 3
var Radius = 40
var _centre
var _angle = [ 0, deg2rad(120), deg2rad(240) ]
var bullets = []
var magazine = 3

func _ready():
	yield(get_tree(), "idle_frame")
	#passa a instancia de player a todos no grupo "enemy" que possuem a função "_set_player"
	get_tree().call_group("enemy", "_set_player", self)
	emit_signal('life_changed', current_life * (100/max_life))
	#$Bullet.position = Vector2(0, 40)
	for i in range(3):
		bullets.append(Bullet.instance())
		add_child(bullets[i])
		#bullets[i].connect("body_entered", self, "_on_Bullet_body_entered")
	_centre = bullets[0].position

func _process(delta):
	var j = 0
	for i in range(magazine):
		if is_instance_valid(bullets[i]):
			_angle[i] += RotateSpeed * delta;
			var offset = Vector2(sin(_angle[i]), cos(_angle[i])) * (Radius + randf() * 10);
			var pos = _centre + offset
			bullets[i].position = pos
			if i == magazine -1:
				bullets[i].modulate = Color.yellow
		else:
			j += 1
	if j == 3:
		reload()
	
	var movedir = Vector2()
	$weapon.look_at(get_global_mouse_position())
	
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
		var now = OS.get_ticks_msec()
		if now - last_shot_time > shoot_cd:
			last_shot_time = now
			_shoot()

func _dash():
	current_stamina -= stamina_cost
	_stamine_changed()
	$StaminaRecoveryTime.wait_time = pos_dash_recovery_stamina_time
	$DashTimer.wait_time = dash_time
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
	if magazine < 1:
		pass
	else:
		var bltpos = bullets[magazine -1].global_position
		var mspos = get_global_mouse_position()
		#bullets[magazine -1]._fire(mspos - bltpos)
		bullets[magazine -1].queue_free()
		bullets.remove(magazine -1)
		emit_signal('shoot', Bullet, bltpos, mspos - bltpos)
		magazine -= 1
		if magazine == 0:
			reload()
	#can_shoot = false
	#esse global_rotation no futuro vai ser substituido por $weapon.global_rotation, pois vamos criar esferas ou uma linha como arma ne
	#dai eu acredito que ela pdoe rotacionar na direção do mouse e a bala sair dela, dai já preparei tudo pra isso
	#var dir = Vector2(1, 0).rotated($weapon.global_rotation)
	#emito um sinal com a bala,posição do player(no futuro vai ser do portal) e a direção que no futuro vai ser dir

func reload():
	_angle = [ 0, deg2rad(120), deg2rad(240) ]
	
	for i in range(3):
		bullets.append(Bullet.instance())
		add_child(bullets[i])
	magazine = 3
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
	$StaminaRecoveryTime.wait_time = 0.5
	if current_stamina < max_stamina:
		current_stamina += 1
		_stamine_changed()

func _on_Bullet_body_entered(body):
	for i in range(3):
		pass
	magazine -= 1
	pass