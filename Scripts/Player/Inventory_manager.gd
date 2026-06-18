# InventoryManager.gd
extends Node
class_name InventoryManager

signal item_added(item: Item, quantity: int)
signal item_removed(item: Item, quantity: int)
signal inventory_changed

var inventory: Dictionary = {}  # {item_id: quantity}
var max_slots: int = 20

func _ready():
	add_to_group("inventory")

func add_item(item: Item, quantity: int = 1) -> bool:
	if inventory.size() >= max_slots and item.id not in inventory:
		print("Inventory full!")
		return false
	
	if item.id not in inventory:
		inventory[item.id] = 0
	
	inventory[item.id] += quantity
	item_added.emit(item, quantity)
	inventory_changed.emit()
	return true

func remove_item(item_id: String, quantity: int = 1) -> bool:
	if item_id not in inventory:
		return false
	
	inventory[item_id] -= quantity
	
	if inventory[item_id] <= 0:
		inventory.erase(item_id)
	
	inventory_changed.emit()
	return true

func get_item_quantity(item_id: String) -> int:
	return inventory.get(item_id, 0)

func has_item(item_id: String, quantity: int = 1) -> bool:
	return get_item_quantity(item_id) >= quantity

func clear_inventory():
	inventory.clear()
	inventory_changed.emit()

func get_all_items() -> Dictionary:
	return inventory.duplicate()
func use_item(item_id: String):
	if has_item(item_id):
		var item = items_data.get(item_id)
		if item:
			print("Using: ", item.name)
			# Call item-specific logic here
			remove_item(item_id, 1)
			return true
	return false
