extends Node3D

## AnatomicalObject - Base class for interactive anatomy

@export var anatomy_name: String = "Anatomy"
@export var anatomy_type: String = "organ"
@export var is_selectable: bool = true
@export var is_interactable: bool = true

var is_selected: bool = false
var original_material: StandardMaterial3D = null
var selected_material: StandardMaterial3D = null

func _ready() -> void:
	_setup_materials()
	Events.anatomy_selected.connect(_on_anatomy_selected)
	Events.anatomy_deselected.connect(_on_anatomy_deselected)

func _setup_materials() -> void:
	# Original material
	original_material = StandardMaterial3D.new()
	original_material.albedo_color = Color(0.8, 0.3, 0.3)
	
	# Selected material (highlight)
	selected_material = StandardMaterial3D.new()
	selected_material.albedo_color = Color(1.0, 1.0, 0.3)
	selected_material.emission_enabled = true
	selected_material.emission = Color(1.0, 1.0, 0.3)
	selected_material.emission_energy_multiplier = 0.3

func select() -> void:
	if not is_selectable:
		return
	
	is_selected = true
	_apply_material(selected_material)
	Events.anatomy_selected.emit(anatomy_name)
	Events.log_event("anatomy_selected", {"name": anatomy_name})

func deselect() -> void:
	is_selected = false
	_apply_material(original_material)
	Events.anatomy_deselected.emit()
	Events.log_event("anatomy_deselected", {"name": anatomy_name})

func _apply_material(material: StandardMaterial3D) -> void:
	# Apply material to all mesh children
	for child in get_children():
		if child is MeshInstance3D:
			child.material_override = material

func interact(tool_name: String) -> void:
	if not is_interactable:
		return
	
	Events.log_event("anatomy_interacted", {
		"name": anatomy_name,
		"tool": tool_name
	})

func get_info() -> Dictionary:
	return {
		"name": anatomy_name,
		"type": anatomy_type,
		"is_selectable": is_selectable,
		"is_interactable": is_interactable,
		"is_selected": is_selected
	}

func _on_anatomy_selected(_name: String) -> void:
	if _name != anatomy_name:
		deselect()
