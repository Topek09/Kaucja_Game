# Player.gd - Fixed and optimized version
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
var inventory_manager: InventoryManager  # Reference to your inventory manager

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Get reference to the inventory manager (if it's an autoload or in the scene)
	inventory_manager = get_tree().get_first_node_in_group("inventory")

func _unhandled_input(event):
	# Mouse look
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
	# Release mouse with ESC
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Movement
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
	# Gradually fade out the drunk effect over time
	if drunk_intensity > 0:
		drunk_intensity -= 0.1 * delta
		drunk_overlay.material.set_shader_parameter("intensity", drunk_intensity)

func _input(event):
	# ONLY ONE _input function - handle all interactions here
	if event.is_action_pressed("interact"):
		check_interaction()

func check_interaction():
	"""
	Unified interaction function that handles:
	- Drinking from bottles (interactable group)
	- Picking up items (pickups group)
	"""
	if not interact_ray.is_colliding():
		return
	
	var target = interact_ray.get_collider()
	
	# Check if it's a bottle to drink from
	if target.is_in_group("interactable"):
		drink_bottle(target)
	
	# Check if it's a pickup item for inventory
	elif target.is_in_group("pickups"):
		pickup_item(target)

func drink_bottle(bottle):
	"""Handle drinking from a bottle"""
	print("Drinking from a dumpster bottle... gross.")
	
	# Increase the "drunk" effect
	drunk_intensity = clamp(drunk_intensity + 0.5, 0.0, 1.0)
	
	# Optional: Play a sound effect
	# $DrinkSound.play()
	
	# Optional: Add to inventory before removing
	if inventory_manager and bottle.has_meta("item"):
		var item = bottle.get_meta("item")
		inventory_manager.add_item(item, 1)
	
	# Remove the bottle from the world
	bottle.queue_free()

func pickup_item(pickup_object):
	"""Handle picking up items for inventory"""
	if pickup_object.has_method("pickup"):
		pickup_object.pickup()
	else:
		print("Pickup object doesn't have a pickup() method!")

# Optional: Function to use an item from inventory
func use_item(item_id: String):
	"""Use an item from the inventory"""
	if inventory_manager:
		if inventory_manager.has_item(item_id):
			print("Using item: ", item_id)
			inventory_manager.use_item(item_id)
		else:
			print("Item not in inventory!")
