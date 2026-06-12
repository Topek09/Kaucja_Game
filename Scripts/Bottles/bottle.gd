class_name Bottle
extends RigidBody3D

# --- Sygnały ---
signal bottle_broken
signal liquid_changed(new_amount: float)

# --- Właściwości eksportowane (widoczne w Inspektorze) ---
@export var capacity: float = 0.5          # w litrach
@export var liquid_level: float = 0.5      # aktualna ilość (0.0 - 0.5)
@export var liquid_type: String = "water"
@export var break_threshold: float = 10.0  # siła uderzenia do rozbicia
@export var fill_speed: float = 0.2        # l/s przy napełnianiu

# --- Stan prywatny ---
var is_empty: bool = false
var is_broken: bool = false

# --- Węzły potomne ---
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

# =========================================================

func _ready() -> void:
	# Podłącz sygnał fizyczny (wykrywanie uderzenia)
	body_entered.connect(_on_body_entered)
	_update_liquid_visual()

func _process(delta: float) -> void:
	# Opcjonalnie: animacja cieczy w czasie
	pass

# --- Napełnianie butelki ---
func fill(amount: float) -> float:
	if is_broken or is_empty == false and liquid_level >= capacity:
		return 0.0

	var space_left := capacity - liquid_level
	var filled := minf(amount, space_left)
	liquid_level += filled

	is_empty = false
	liquid_changed.emit(liquid_level)
	_update_liquid_visual()
	return filled

# --- Picie / opróżnianie ---
func drink(amount: float) -> float:
	if is_broken or is_empty:
		return 0.0

	var taken := minf(amount, liquid_level)
	liquid_level -= taken

	if liquid_level <= 0.0:
		liquid_level = 0.0
		is_empty = true

	liquid_changed.emit(liquid_level)
	_update_liquid_visual()
	return taken

# --- Rozbicie butelki ---
func break_bottle() -> void:
	if is_broken:
		return

	is_broken = true
	liquid_level = 0.0
	is_empty = true

	if audio:
		audio.play()

	# Tutaj możesz: spawner szkła, cząsteczki, itp.
	bottle_broken.emit()
	queue_free()  # usuń węzeł ze sceny (lub zastąp efektem)

# --- Procent napełnienia (helper) ---
func get_fill_percentage() -> float:
	return (liquid_level / capacity) * 100.0

# --- Aktualizacja wyglądu cieczy ---
func _update_liquid_visual() -> void:
	# Przykład: skalowanie meshu cieczy proporcjonalnie do poziomu
	if mesh:
		var scale_y := liquid_level / capacity
		mesh.scale.y = maxf(scale_y, 0.01)

# --- Detekcja uderzenia (fizyka) ---
func _on_body_entered(body: Node) -> void:
	var impact := linear_velocity.length()
	if impact >= break_threshold:
		break_bottle()
