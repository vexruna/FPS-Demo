extends Node3D
var vase = preload("res://vase.tscn")

func _ready() -> void:
	spawn_vase()
	
func _physics_process(_delta: float):
	debug()
	
func debug():
	$Debug.text = "Timer: " + str($SpawnTimer.time_left)

func spawn_vase():
	var child = vase.instantiate()
	$Slot.add_child(child)

func _on_spawn_timer_timeout() -> void:
	spawn_vase()

func _on_slot_child_exiting_tree(_node: Node) -> void:
	$SpawnTimer.start()
