extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	
	if event is InputEventMouseMotion:
		
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		# Smooth deceleration
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
