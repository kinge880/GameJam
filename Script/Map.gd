extends Node

"""func _ready():
    set_camera_limits()
	
#define um limite maximo para a camera
func set_camera_limits():
    var map_limits = $Ground.get_used_rect()
    var map_cellsize = $Ground.cell_size
    $Player/Camera2D.limit_left = map_limits.position.x * map_cellsize.x
    $Player/Camera2D.limit_right = map_limits.end.x * map_cellsize.x
    $Player/Camera2D.limit_top = map_limits.position.y * map_cellsize.y
    $Player/Camera2D.limit_bottom = map_limits.end.y * map_cellsize.y
"""
#o map em si vai controlar a gerenciar a bala, pq se deixarmos isso sobre o player, bala vai receber o 
#transform do player e se mover no ar quando o player se mover
func _on_Player_shoot(bullet, _position, _direction):
	var b = bullet.instance()
	add_child(b)
	b._start(_position, _direction)

func _on_Player_big_shoot(bullet, _position, _direction):
	var b = bullet.instance()
	add_child(b)
	b._start(_position, _direction)