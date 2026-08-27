extends RigidBody3D

@export var SPEED = 100.0

func _ready() -> void:
	set("top_level", true)
	apply_central_impulse(-transform.basis.z * SPEED)

func _on_area_3d_body_entered(_body: Node3D) -> void:
	queue_free()
