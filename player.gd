extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const mouse_sensitivity = 0.002
@export var raycast : RayCast3D
@export var paused : bool
@export var GunCamera : Camera3D
@export var UI : Control

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Camera3D.make_current()


func _physics_process(delta: float) -> void:
	movement(delta)
	move_and_slide()
	pause()
	GunCamera.global_transform = $Camera3D.global_transform

func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	mouse_lock(event)

func movement(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir := Input.get_vector("a", "d", "w", "s")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func mouse_lock(event):
	if not paused:
		if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotate_y(-event.relative.x * mouse_sensitivity)
			$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)
			$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _raycast():
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider != null and collider.has_method("on_ray_hit"):
			collider.on_ray_hit()

func pause():
	if Input.is_action_just_pressed("pause"):
		match paused:
			false:
				paused = true
				$UI.get_node("Pause").set("visible", true)
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			true:
				paused = false
				$UI.get_node("Pause").set("visible", false)
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
