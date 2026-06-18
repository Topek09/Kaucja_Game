# InventoryUI.gd
extends Control

@onready var inventory_grid = $VBoxContainer/GridContainer
@onready var item_details = $VBoxContainer/ItemDetails

var inventory_manager: InventoryManager
var item_scene = preload("res://scenes/InventorySlot.tscn")
var items_data: Dictionary = {}  # Store item resources by ID

func _ready():
	inventory_manager = get_tree().get_first_node_in_group("inventory")
	if inventory_manager:
		inventory_manager.inventory_changed.connect(_on_inventory_changed)
	
	# Load all item resources (you can organize these however you want)
	load_items_database()
	update_inventory_display()

func load_items_database():
	# Example: Load items from a directory or hardcode them
	var bottle = Item.new("bottle", "Bottle", "A mysterious bottle", null, 10)
	items_data["bottle"] = bottle

func _on_inventory_changed():
	update_inventory_display()

func update_inventory_display():
	# Clear existing slots
	for child in inventory_grid.get_children():
		child.queue_free()
	
	# Create slots for each item in inventory
	for item_id in inventory_manager.get_all_items():
		var quantity = inventory_manager.get_item_quantity(item_id)
		var item = items_data.get(item_id)
		
		if item:
			var slot = item_scene.instantiate()
			slot.setup(item, quantity)
			slot.clicked.connect(_on_slot_clicked.bindv([item_id]))
			inventory_grid.add_child(slot)

func _on_slot_clicked(item_id: String):
	var item = items_data.get(item_id)
	if item:
		show_item_details(item)

func show_item_details(item: Item):
	item_details.text = "%s\n\n%s" % [item.name, item.description]
