extends Node3D

var spawner = load("res://spawner.tscn")

func on_ray_hit():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		print("I've been hit")
		queue_free()
