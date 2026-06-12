extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 4.5
@export var mouse_sensitivity = 0.002

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var interact_ray = $Head/Camera3D/InteractRay
@onready var drunk_overlay = $CanvasLayer/DrunkOverlay

var drunk_intensity = 0.0
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

func _process(delta):
	# Gradually fade out the effect over time
	if drunk_intensity > 0:
		drunk_intensity -= 0.1 * delta
		drunk_overlay.material.set_shader_parameter("intensity", drunk_intensity)

func _input(event):
	if event.is_action_pressed("interact"): # You need to add "interact" (E) to Input Map
		check_interaction()

func check_interaction():
	if interact_ray.is_colliding():
		var target = interact_ray.get_collider()
		if target.is_in_group("interactable"):
			drink_bottle(target)

func drink_bottle(bottle):
	print("Drinking from a dumpster bottle... gross.")
	# Increase the "drunk" effect
	drunk_intensity = clamp(drunk_intensity + 0.5, 0.0, 1.0)
	
	# Optional: Play a sound
	# $DrinkSound.play()
	
	# Remove the bottle from the world
	bottle.queue_free()
