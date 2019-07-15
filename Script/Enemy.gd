extends KinematicBody2D

export var speed = 50
onready var raycast = $RayCast2D
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
var enemy_position_after_folow
signal kill
onready var path = get_node("../")
var state = 2
var motion = Vector2()
var is_original_position = true

export var acc = 0.1
export var dec = 0.05

func _ready():
	add_to_group("enemy")
	enemy_original_position = global_position
	
func control(delta):
	pass
	
func _process(delta):
	#evitar problemas
	if player == null:
		return
	
	#se o player estiver dentro das duas áreas circulares, ativar
	if player_inside_area and player_is_visible and is_player:
		#vetor 2 que recebe  a posição do player - posição do enemy 
		var to_player = player.global_position - global_position
		#evitar movimento duplo com o dobro da velocidade
		to_player = to_player.normalized()
		#provavelmente irei mudar depois, aqui é para direcionar ray cast do enemy na direção do player, mas irei mudar quando adicionar os psirtes
		global_rotation = atan2(to_player.y, to_player.x)
		move_and_collide(to_player * (speed*2) * delta)
		is_original_position = false
	if state == 1:
		#igual ao anterior só que pegando a posição inicial do enemy
		var to_origin = enemy_position - global_position
		to_origin = to_origin.normalized()
		global_rotation = atan2(to_origin.y, to_origin.x)
		move_and_collide(to_origin * speed * delta)
		#solução parcial, vou melhorar isso ainda
		if int(global_position.x)  == int(enemy_position.x) and int(global_position.y)  == int(enemy_position.y):
			state = 2
			is_original_position = true
	elif state == 2:
		path.offset +=  speed * delta
		
	#se rayCast colidir ativa a função death do player
	if raycast.is_colliding():
		var collision = raycast.get_collider()
		if collision.name == "Player":
			collision._death()

func _kill():
	emit_signal("kill")

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
		$Sprite.self_modulate = Color(1, 0, 0)
		player_is_visible = true
		is_player = true
		state = 0

func _on_Visibility_body_exited(body):
	if body.name == "Player":
		$Sprite.self_modulate = Color(1, 1, 1)
		player_is_visible = false
		is_player = false
		state = 1