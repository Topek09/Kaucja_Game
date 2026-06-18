# InventorySlot.gd
extends PanelContainer

signal clicked

@onready var texture_rect = $VBoxContainer/TextureRect
@onready var quantity_label = $VBoxContainer/QuantityLabel

var item: Item
var quantity: int

func setup(p_item: Item, p_quantity: int):
	item = p_item
	quantity = p_quantity
	
	if item.texture:
		texture_rect.texture = item.texture
	
	if quantity > 1:
		quantity_label.text = str(quantity)
	else:
		quantity_label.text = ""

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		clicked.emit()
