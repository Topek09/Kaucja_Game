# PickupItem.gd
extends Area3D

@export var item: Item
@export var quantity: int = 1

@onready var mesh = $MeshInstance3D
@onready var collision = $CollisionShape3D

func _ready():
	add_to_group("pickups")
	if item:
		update_visuals()

func update_visuals():
	# Set mesh material color based on item rarity (optional)
	if mesh:
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.WHITE
		mesh.set_surface_override_material(0, material)

func pickup():
	var inventory = get_tree().get_first_node_in_group("inventory")
	if inventory:
		if inventory.add_item(item, quantity):
			print("Picked up: ", item.name)
			queue_free()
		else:
			print("Inventory full!")
	else:
		print("No inventory manager found!")
