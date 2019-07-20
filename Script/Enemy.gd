extends KinematicBody2D

const Util = preload("res://Script/utils.gd")

onready var speed = 50
var max_speed = 150
var chase_speed = 0
export var current_life = 2
export var max_life = 2
#export var stamina = 10
#export var max_stamina = 10
export var damage = 1
signal life_changed
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
var stop_counter = 0.5
var is_dashing = false
var dash_direction
var dash_duration
var pre_dash = 0.3
var player_in_dash = false
var playback 

func _ready():
	add_to_group("enemy")
	enemy_original_position = global_position
	emit_signal('life_changed', current_life * 100/max_life)
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
		#verificar para definir um lance na função la de baixo
		is_original_position = false
		#recebo o navigation2D pegando a posição do player e a posição do enemy
		
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
		global_rotation = Util.lerp_angle(global_rotation, atan2(to_player.y, to_player.x), 0.1)
		#rotation = Util.lerp_angle(rotation, to_player.angle(), 0.1)
		#faz o movimentos
		if stop_counter <= 0:
			#tween.stop_all()ss
			if !tween.is_active():
				tween.interpolate_property(self, "chase_speed", null, max_speed, 2, Tween.TRANS_QUART, Tween.EASE_IN)
				tween.start()
			
			if not is_dashing:
				if player_in_dash && $DashCD.time_left <= 0:
					dash_direction = player.global_position - global_position
					modulate = Color.yellow
					is_dashing = true
					dash_duration = 0.3
				else:
					move_and_slide(to_player * chase_speed)
			else:
				pre_dash -= delta
				if pre_dash <= 0:
					move_and_slide(dash_direction.normalized() * 1000)
					dash_duration -= delta
					if dash_duration <= 0:
							is_dashing = false
							modulate = Color.white
							pre_dash = 0.3
							$DashCD.start()
			is_original_position = false
	else:
		stop_counter = 0.5
	
	if state == 1:
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
	current_life -= damage
	_life_changed()
	playback.travel("take_damage")
	$hit.play()
	if current_life <=0:
		playback.travel("death")
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
