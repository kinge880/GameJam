extends KinematicBody2D

const Util = preload("res://Script/utils.gd")
const Bullet = preload("res://Bullets/BossBullet.tscn")
const Bullet2 = preload("res://Bullets/Bullet.tscn")

onready var speed = 50
var max_speed = 100
var chase_speed = 0
export var current_life = 10
export var max_life = 10
#export var stamina = 10
#export var max_stamina = 10
export var damage = 1
signal life_changed
signal enemy_shoot
onready var raycast = $RayCast2D3
onready var raycast2 = $RayCast2D2
#instancia do player, começando como null
var player = null
#se o player ta dentro ou não da area limite de movimentos do enemy
var player_inside_area = false
#se o player entrou ou não na area de visão do enemy
var player_is_visible = false
#se o que esta dentro de qualquer uma das outras áreas é um player ou não
var is_player = false
var enemy_original_position
var enemy_position
#var enemy_position_after_folow
onready var path = get_node("../")
onready var navigation = get_node("../../../../Navigation2D")
var state = 2
#var motion = Vector2()
var is_original_position = true
var path_navigation = []

onready var tween = get_node("Tween")
var is_dashing = false
var dash_direction
var dash_duration
var player_in_dash = false
var playback
 
var is_in_action = true
var pre_dash = 1
export var pre_dash_time = 0.8
export var stop_counter = 2
var reload = false
export var dash_distance = 1000
var module_state = Color(1,1,1)
var anim_state = 0
var damage_is_moving = true
var life_percent
var first_encounter = true
var helistart = true
var speak = true
var nosignal = true

func _ready():
	add_to_group("enemy")
	enemy_original_position = global_position
	emit_signal('life_changed', current_life * 100/max_life)
	$AnimationTree.active = true
	playback = $AnimationTree.get("parameters/playback")
	playback.start("idle")
#func control(delta):
#	pass
	
func _process(delta):
	#evitar problemas
	if player == null:
		return
	
	#se o player estiver dentro das duas áreas circulares, ativar
	if player_is_visible and is_player:
		if first_encounter == true:
			$StartAudio.play()
			first_encounter = false
			
		life_percent = current_life * 100/max_life
		is_original_position = false
			
		path_navigation = navigation.get_simple_path(global_position, player.global_position, true)
		update()
		#a posição [0] seria a posição atual do enemy, a posição [1] deveria ser uma posição atualizada com base no melhor caminho
		var nextPos = path_navigation[1]
		#vetor 2 que recebe  a posição do path[1] - do enemy
		var to_player = nextPos - global_position

		stop_counter -= delta
		#vetor 2 que recebe  a posição do player - posição do enemy 
		#var to_player = player.global_position - global_position
		#evitar movimento duplo com o dobro da velocidade
		to_player = to_player.normalized()
		#provavelmente irei mudar depois, aqui é para direcionar ray cast do enemy na direção do player, mas irei mudar quando adicionar os psirtes
		if is_in_action:
			global_rotation = Util.lerp_angle(global_rotation, atan2(to_player.y, to_player.x), 0.1)
		#rotation = Util.lerp_angle(rotation, to_player.angle(), 0.1)
		#faz o movimentos
		if stop_counter <= 0:
			_change_anim()
				
			if life_percent > 75:
				$DashCD.wait_time = 2
				if is_in_action:
					pass
					#modulate = module_state
			elif life_percent > 50:
				#module_state = Color(0, 1, 0.929412)
				#if is_in_action:
					#modulate = module_state
				#tempo de espera entre cada dash
				$DashCD.wait_time = 2
				$ReloadTimer.wait_time = 0.4
				#tempo de espera para iniciar o dash
				pre_dash_time = 0.6
				#distancia do dash
				dash_distance = 1200
				#velocidade do boss
				max_speed = 130
			
			elif life_percent > 25:
				$RobotOneWeapon.hide()
				$RobotTwoWeapon.show()
				#module_state = Color(1, 0.654902, 0)
				#if is_in_action:
					#modulate = module_state
				$DashCD.wait_time = 6
				$ReloadTimer.wait_time = 0.3
				pre_dash_time = 0.4
				dash_distance = 1500
				max_speed = 150
			
			elif life_percent < 25:
				playback.travel("helicopter")
				if helistart == true:
					$Heli.play()
					helistart = false
				$ReloadTimer.wait_time = 0.1
				module_state = Color(1, 0, 0.047059)
				#if is_in_action:
				modulate = module_state
				"""$DashCD.wait_time = 3
				pre_dash_time = 0.2
				dash_distance = 2000
				max_speed = 180
				damage = 2"""
				
		#tween.stop_all()ss
			if not reload:
				reload()
				if is_in_action:
					if life_percent > 50:
						_enemy_shoot()
					else:
						_enemy_dual_shoot()
				
			if !tween.is_active():
				tween.interpolate_property(self, "chase_speed", null, max_speed, 2, Tween.TRANS_QUART, Tween.EASE_IN)
				tween.start()
			
			if life_percent > 25:
				if not is_dashing:
					if player_in_dash && $DashCD.time_left <= 0:
						dash_direction = player.global_position - global_position
						is_dashing = true
						dash_duration = 0.3
						is_in_action = false
						damage = 3
						anim_state = 0
						$dash_impact/CollisionShape2D.disabled = false
						_change_anim()
						if life_percent > 50:
							$RobotOneWeapon.hide()
							$RobotDash.show()
						else:
							$RobotTwoWeapon.hide()
							$RobotDash.show()
		
					else:
						anim_state = 1
						_change_anim()
						if life_percent > 50:
							$RobotOneWeapon.show()
							$RobotDash.hide()
						else:
							$RobotTwoWeapon.show()
							$RobotDash.hide()
						$dash_impact/CollisionShape2D.disabled = true
						damage = 1
						is_in_action = true
						move_and_slide(to_player * chase_speed)
				else:
					pre_dash -= delta
					if pre_dash <= 0:
						move_and_slide(dash_direction.normalized() * dash_distance)
						anim_state = 1
						_change_anim()
						dash_duration -= delta
						if dash_duration <= 0:
							if life_percent > 50:
								$RobotOneWeapon.show()
								$RobotDash.hide()
							else:
								$RobotTwoWeapon.show()
								$RobotDash.hide()
							is_dashing = false
							pre_dash = pre_dash_time
							$DashCD.start()
							$dash_impact/CollisionShape2D.disabled = true
				is_original_position = false	
	else:
		modulate = Color(1, 1, 1)
		stop_counter = 2
		first_encounter = true
		speak = true
		helistart = true
			
	if state == 1:
		if nosignal == true:
			$NoSignal.play()
			nosignal = false
		path_navigation = navigation.get_simple_path(global_position, enemy_position)
		var nextPos = path_navigation[1]
		#igual ao anterior só que pegando a posição inicial do enemy
		var to_origin = nextPos - global_position
		to_origin = to_origin.normalized()
		#global_rotation = atan2(to_origin.y, to_origin.x)
		global_rotation = Util.lerp_angle(global_rotation, atan2(to_origin.y, to_origin.x), 0.1)
		move_and_slide(to_origin * speed)
		#solução parcial, vou melhorar isso ainda
		if int(global_position.x)  == int(enemy_position.x) and int(global_position.y)  == int(enemy_position.y):
			state = 2
			is_original_position = true
	elif state == 2:
		rotation = 0
		path.offset += speed * delta	
	
	#se rayCast colidir ativa a função death do player
	if raycast.is_colliding():
		var collision = raycast.get_collider()
		if collision.name == "Player":
			collision._take_damage(damage)
	elif raycast2.is_colliding():
		var collision = raycast2.get_collider()
		if collision.name == "Player":
			collision._take_damage(damage)
			
func _kill():
	queue_free()

#essa função permite mudar a variavel player, pegando a instancia de player
func _set_player(body):
	player = body

#funções caso entre e saia das áreas
func _on_AreaMove_body_entered(body):
	if body.name == "Player":
		player_inside_area = true

func _on_AreaMove_body_exited(body):
	if body.name == "Player":
		player_inside_area = false

func _on_Visibility_body_entered(body):
	if body.name == "Player":
		if is_original_position:
			enemy_position = global_position
		player_is_visible = true
		is_player = true
		state = 0

func _on_Visibility_body_exited(body):
	if body.name == "Player":
		player_is_visible = false
		is_player = false
		state = 1
		
#função pra tomar DANU
func _take_damage(damage):
	print(current_life)
	if anim_state == 1 and life_percent > 25:
		anim_state = 3
		damage_is_moving = true
		_change_anim()
	elif anim_state == 0 and life_percent > 25:
		anim_state = 2
		damage_is_moving = false
		_change_anim()
	current_life -= damage
	_life_changed()
	$hit.play()
	if current_life <=0:
		playback.travel("death")
		$Explosion.emitting = true
		$Body.disabled = true
		$speak.stop()

func _life_changed():
	emit_signal('life_changed', current_life * 100/max_life)

func _on_Dash_body_entered(body):
	if body.name == "Player":
		player_in_dash = true

func _on_Dash_body_exited(body):
	if body.name == "Player":
		player_in_dash = false

func reload():
	reload = true
	$ReloadTimer.start()

func _enemy_shoot():
	emit_signal('enemy_shoot', Bullet, $RobotOneWeapon/weapon_gun.global_position, player.global_position - global_position)

func _enemy_dual_shoot():
	if life_percent > 25:
		emit_signal('enemy_shoot', Bullet,  $RobotTwoWeapon/weapon_gun_down.global_position, player.global_position - global_position)
		emit_signal('enemy_shoot', Bullet, $RobotTwoWeapon/weapon_gun_up.global_position, player.global_position - global_position)
	else:
		#ajustar aqui pro tiro ir em frente e não na direção do player
		emit_signal('enemy_shoot', Bullet,  $RobotTwoWeapon/weapon_gun_down.global_position, $RobotTwoWeapon/weapon_gun_up_direction.global_position - global_position)
		emit_signal('enemy_shoot', Bullet, $RobotTwoWeapon/weapon_gun_up.global_position, $RobotTwoWeapon/weapon_gun_down_direction.global_position - global_position)

func _on_ReloadTimer_timeout():
	reload = false

func _change_anim():
	if anim_state == 0:
		playback.travel("idle")
	elif anim_state == 1:
		playback.travel("walk")
	elif anim_state == 2:
		playback.travel("take_damage")
	elif anim_state == 3:
		playback.travel("take_damage_walk")
	elif anim_state == 4:
		playback.travel("death")
	elif anim_state == 5:
		playback.travel("helicoper")
	elif anim_state == 6:
		playback.travel("helicoper_damage")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "take_damage":
		if damage_is_moving:
			anim_state = 3
		else:
			anim_state = 2
	_change_anim()

func _on_dash_impact_body_entered(body):
	if body.has_method('_take_damage'):
		body._take_damage(damage)
