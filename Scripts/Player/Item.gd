# Item.gd
extends Resource
class_name Item

@export var id: String
@export var name: String
@export var description: String
@export var texture: Texture2D
@export var max_stack: int = 1  # 1 = not stackable, >1 = stackable
@export var weight: float = 0.0

func _init(p_id = "", p_name = "", p_description = "", p_texture = null, p_max_stack = 1):
	id = p_id
	name = p_name
	description = p_description
	texture = p_texture
	max_stack = p_max_stack
