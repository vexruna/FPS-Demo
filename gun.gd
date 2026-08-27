extends StaticBody3D
var tracer = preload("res://tracer.tscn")
var sfx_emptyclick = preload("res://assets/empty-click.tres")
var sfx_pistolfire = preload("res://assets/pistol-fire.tres")
var sfx_reloadstart = preload("res://assets/reload-start.wav")
var sfx_reloadend = preload("res://assets/reload-end.wav")
@onready var player = $"../.."
@onready var anim = $AnimationPlayer
@onready var s_gunfire = $GunFire
@onready var s_gunclick = $GunClick
@onready var MuzzleFlash = $Pos/Model/MuzzlePoint/MuzzleFlash
@onready var MuzzleSmoke = $Pos/Model/MuzzlePoint/MuzzleSmoke
@onready var SmokeTimer = $Pos/Model/MuzzlePoint/SmokeTimer
@onready var LightTimer = $Pos/Model/MuzzlePoint/LightTimer
@onready var MuzzleLight = $Pos/Model/MuzzlePoint/SpotLight3D

@onready var shapecast = $ShapeCast3D
@onready var model = $Pos/Model
@onready var ammo_ui_path: NodePath = "../../CanvasLayer/SubViewportContainer/SubViewport/GunCamera/Ammo"
var target_z:=0.0
var target_x:=0.0
@onready var original_pos = model.position

@export var pistol_reserve: int
@export var pistol_mag_size: int
@export var ammo_loaded: int
var reloading : bool = false

func _physics_process(_delta: float) -> void:
	ammo_counter()
	shoot()
	reload()
	prevent_clipping(_delta)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"fire":
			anim.play("idle")
		"reload":
			s_gunclick.set("stream", sfx_reloadend)
			s_gunclick.play()
			anim.play("idle")
			if ammo_loaded == 0:
				ammo_loaded = pistol_mag_size
				pistol_reserve -= 1
			else:
				ammo_loaded = pistol_mag_size + 1
				pistol_reserve -= 1
			reloading = false
			get_node(str(ammo_ui_path) + "/bg/Reloading").visible = false

func _on_smoke_timer_timeout() -> void:
	MuzzleSmoke.set("emitting", false)


func _on_light_timer_timeout() -> void:
	MuzzleLight.set("visible", false)

func shoot():
	if player.paused == false:
		if Input.is_action_just_pressed("fire"):
			if ammo_loaded > 0 and not reloading:
				player._raycast()
				anim.stop()
				anim.play("fire")
				s_gunfire.play()
				MuzzleFlash.restart()
				SmokeTimer.start()
				MuzzleSmoke.set("emitting", true)
				MuzzleLight.set("visible", true)
				LightTimer.start()
				var fired = tracer.instantiate()
				$Pos/Model/MuzzlePoint.add_child(fired)
				ammo_loaded -= 1
			elif not reloading:
				s_gunclick.set("stream", sfx_emptyclick)
				s_gunclick.play()

func ammo_counter():
	get_node(str(ammo_ui_path) + "/bg/number").text = str(ammo_loaded) + "/" + str(pistol_mag_size) + \
	"\n" + "--" + str(pistol_reserve) + "--"

func prevent_clipping(_delta):
	if shapecast.is_colliding():
		var distance = shapecast.global_position.distance_to(shapecast.get_collision_point(0))
		target_z = min(distance - 0.6, original_pos.x)
		target_x = min(distance - 0.6, original_pos.z)
	else:
		target_z = original_pos.x
		target_x = original_pos.z
	$Pos.position.x = lerp($Pos.position.x, -target_z, 10.0 * _delta)
	$Pos.position.z = lerp($Pos.position.z, -target_x, 10.0 * _delta)

func reload(): # Making sure there is an extra bullet in the chamber if reloading prematurely
	if Input.is_action_just_pressed("reload"):
		if pistol_reserve > 0:
			if ammo_loaded < pistol_mag_size:
				get_node(str(ammo_ui_path) + "/bg/Reloading").visible = true
				s_gunclick.set("stream", sfx_reloadstart)
				s_gunclick.play()
				reloading =  true
				anim.play("reload")
