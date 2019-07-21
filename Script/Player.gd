extends KinematicBody2D

const Util = preload("res://Script/utils.gd")
const Bullet = preload("res://Bullets/Bullet.tscn")
const big_bullet = preload("res://Bullets/BigBullet.tscn")
const lifeUp = preload("res://ui/LifeUpPopUp.tscn")
const staminaUp = preload("res://ui/staminaUpPopUp.tscn")
const book = preload("res://ui/bookObted.tscn")
const bookIgni = preload("res://ui/bookIgniPopUp.tscn")
const bookJarin = preload("res://ui/bookJarinPopUp.tscn")

export var speed = 200
export var dash_speed = 1000
export var walk_speed = 200
export var dash_time = 0.2
export var pos_dash_recovery_stamina_time = 5
export var current_life = 5
export var bookLife = 5
export var bookenergy = 2
export var max_life = 5
export var current_stamina = 2
export var max_stamina = 2
export var stamina_cost = 1

signal shoot
signal big_shoot
signal life_changed
signal stamina_changed

onready var acc = 0.5
onready var dec = 0.1
var motion = Vector2()
var last_shot_time = 0
var shoot_cd = 250
var magazine = 3
var magazine_range = 3
var reloading = false
var big_shoot_cd = 300
var big_magazine = 1
var big_magazine_range = 1
var big_reloading = false
var book_obted = false
var book_big_atk_obted = false
var not_damaged = true
var playback
var event_global

var dead = false

func _ready():
	yield(get_tree(), "idle_frame")
	#passa a instancia de player a todos no grupo "enemy" que possuem a função "_set_player"
	get_tree().call_group("enemy", "_set_player", self)
	emit_signal('life_changed', current_life * (100/max_life))
	playback = $AnimationTree.get("parameters/playback")
	$AnimationTree.active = true
	#$AnimationTree.play("idle")
	playback.start("idle")
	
func _process(delta):
	if dead:
		return
	
	$barrier.look_at(get_global_mouse_position())
	
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
		if Input.is_action_just_pressed("dash") and current_stamina >= stamina_cost:
			_dash()
		playback.travel("walk")
		#$AnimationPlayer.play("walk")
		motion = motion.linear_interpolate(movedir.normalized(), acc)
		$PlayerSprite.rotation = Util.lerp_angle($PlayerSprite.rotation, motion.angle(), 0.1)
		$CollisionShape2D.rotation = Util.lerp_angle($CollisionShape2D.rotation, motion.angle(), 0.1)
	else:
		#$AnimationPlayer.stop()
		motion = motion.linear_interpolate(Vector2(), dec)
		playback.travel("idle")
		#$AnimationPlayer.play("idle")
		$walkAudio.stop()
	
	move_and_slide(motion * speed)
	
	#atacar, podemos modificar aqui pra fazer do jeito que preferimos, deixei assim de inicio pra ter uma base
	if book_obted:
		if Input.is_action_pressed("atk"):
			if !reloading:
				var now = OS.get_ticks_msec()
				if now - last_shot_time > shoot_cd:
					last_shot_time = now
					_shoot()
					
	if book_big_atk_obted:
		if Input.is_action_pressed("big_atk"):
			if !reloading:
				var now = OS.get_ticks_msec()
				if now - last_shot_time > shoot_cd:
					last_shot_time = now
					_big_shoot()

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
	get_tree().change_scene("res://ui/GameOver.tscn")

func _shoot():
	if magazine < 1:
		pass
	else:
		var mspos = get_global_mouse_position()
		emit_signal('shoot', Bullet, global_position, mspos - global_position)
		magazine -= 1
		if magazine == 0:
			reload()
			
func _big_shoot():
	if big_magazine < 1:
		pass
	else:
		var mspos = get_global_mouse_position()
		emit_signal('shoot', big_bullet, global_position, mspos - global_position)
		big_magazine -= 1
		if big_magazine == 0:
			big_reload()
			
func reload():
	reloading = true
	
	for i in range(magazine_range):
		$RldTimer.start()
		yield($RldTimer, "timeout")
		magazine = i + 1
	
	reloading = false
	
func big_reload():
	big_reloading = true
	
	for i in range(big_magazine_range):
		$bigRldTimer.start()
		yield($bigRldTimer, "timeout")
		big_magazine = i + 1
	
	big_reloading = false
	
func _on_DashTimer_timeout():
	speed = walk_speed

func _life_changed():
	emit_signal('life_changed', current_life)

func _stamine_changed():
	emit_signal('stamina_changed', current_stamina)
	
func _take_damage(damage):
	if not_damaged:
		current_life -= damage
		_life_changed()
		not_damaged = false
		$DamageTimer.start()
		$HealDelayTimer.start()
		var movedir = Vector2()
		if event_global:
			if event_global is InputEventKey:
				playback.travel("walk+damage")
			else:
				playback.travel("take_damage")
		#$AnimationPlayer.play("take_damage")
	if current_life <=0:
		playback.travel("death")
		#$AnimationPlayer.play("death")
		$DeathDelayTimer.start()
		dead = true
		yield($DeathDelayTimer, "timeout")
		_death()

func _input(event):
	event_global = event
	
func _on_StaminaRecoveryTime_timeout():
	if current_stamina < max_stamina:
		current_stamina += 1
		_stamine_changed()

func _on_wait_stamina_time_timeout():
	$StaminaRecoveryTime.start()


func _on_bookArea_body_entered(body):
	$PlayerSprite.texture = load("res://Sprites/Player/walkPlayerBook.png")
	book_obted = true
	var b = book.instance()
	add_child(b)

func _on_BookEnergy_body_entered(body):
	max_stamina += bookenergy
	current_stamina = max_stamina
	#$AnimationPlayer.play("vidaUp")
	var s = staminaUp.instance()
	add_child(s)
	
func _on_bookIgni_body_entered(body):
	var bi = bookIgni.instance()
	add_child(bi)
	magazine = 5
	shoot_cd = 150
	magazine_range = 5
	$RldTimer.wait_time = 0.4
	
func _on_bookJarin_body_entered(body):
	book_big_atk_obted = true
	var j = bookJarin.instance()
	add_child(j)

func _on_bookLife_body_entered(body):
	max_life += bookLife
	current_life = max_life
	#$AnimationPlayer.play("staminaUp")
	var l = lifeUp.instance()
	add_child(l)

func _on_DamageTimer_timeout():
	not_damaged = true

func _on_HealDelayTimer_timeout():
	while current_life < max_life:
		current_life += 1
		_life_changed()
		$HealTimer.start()
		yield($HealTimer, "timeout")
