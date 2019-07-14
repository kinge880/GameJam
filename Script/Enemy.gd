extends KinematicBody2D

export var speed = 100
onready var raycast = $RayCast2D
#instancia do player, começando como null
var player = null
#se o player ta dentro ou não da area limite de movimentos do enemy
var player_inside_area = false
#se o player entrou ou não na area de visão do enemy
var player_is_visible = false
#se o que esta dentro de qualquer uma das outras áreas é um player ou não
var is_player = false
var enemy_position

func _ready():
	add_to_group("enemy")
	enemy_position = global_position
	
func _physics_process(delta):
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
		move_and_collide(to_player * speed * delta)
	else:
		#igual ao anterior só que pegando a posição inicial do enemy
		var to_origin = enemy_position - global_position
		to_origin = to_origin.normalized()
		global_rotation = atan2(to_origin.y, to_origin.x)
		move_and_slide(to_origin * speed * delta)
	
	#se rayCast colidir ativa a função death do player
	if raycast.is_colliding():
		var collision = raycast.get_collider()
		if collision.name == "Player":
			collision._death()

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
		$Sprite.self_modulate = Color(1, 0, 0)
		player_is_visible = true
		is_player = true

func _on_Visibility_body_exited(body):
	if body.name == "Player":
		$Sprite.self_modulate = Color(1, 1, 1)
		player_is_visible = false
		is_player = false