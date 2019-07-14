extends KinematicBody2D

export var speed = 200
var velocity = Vector2()

func _physics_process(delta):
	look_at(get_global_mouse_position())
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2(-speed, 0).rotated(rotation)
	elif Input.is_action_pressed("ui_up"):
		velocity = Vector2(speed, 0).rotated(rotation)
	else:
		velocity = Vector2(0, 0)
	velocity = velocity.normalized() * speed
	velocity = move_and_slide(velocity, Vector2(0,0))