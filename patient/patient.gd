extends Node3D

## Patient - Placeholder patient model

@export var patient_name: String = "Patient_001"
@export var age: int = 35
@export var gender: String = "Male"

var vitals: Dictionary = {
	"heart_rate": 72,
	"systolic_bp": 120,
	"diastolic_bp": 80,
	"spo2": 98,
	"respiratory_rate": 16,
	"temperature": 36.8
}

var condition: String = "Stable"
var is_anesthetized: bool = false

func _ready() -> void:
	_create_patient_body()
	Events.patient_vitals_changed.connect(_on_vitals_changed)

func _create_patient_body() -> void:
	# Create simple placeholder body using primitives
	
	# Torso (main body)
	var torso = MeshInstance3D.new()
	var torso_mesh = BoxMesh.new()
	torso_mesh.size = Vector3(0.6, 0.8, 0.3)
	torso.mesh = torso_mesh
	torso.position = Vector3(0, 0, 0)
	torso.name = "Torso"
	add_child(torso)
	
	# Head
	var head = MeshInstance3D.new()
	var head_mesh = SphereMesh.new()
	head_mesh.radius = 0.15
	head.mesh = head_mesh
	head.position = Vector3(0, 0.55, 0)
	head.name = "Head"
	add_child(head)
	
	# Left arm
	var left_arm = MeshInstance3D.new()
	var arm_mesh = BoxMesh.new()
	arm_mesh.size = Vector3(0.12, 0.6, 0.12)
	left_arm.mesh = arm_mesh
	left_arm.position = Vector3(-0.45, 0, 0)
	left_arm.name = "LeftArm"
	add_child(left_arm)
	
	# Right arm
	var right_arm = MeshInstance3D.new()
	right_arm.mesh = arm_mesh
	right_arm.position = Vector3(0.45, 0, 0)
	right_arm.name = "RightArm"
	add_child(right_arm)
	
	# Left leg
	var left_leg = MeshInstance3D.new()
	var leg_mesh = BoxMesh.new()
	leg_mesh.size = Vector3(0.15, 0.7, 0.15)
	left_leg.mesh = leg_mesh
	left_leg.position = Vector3(-0.15, -0.75, 0)
	left_leg.name = "LeftLeg"
	add_child(left_leg)
	
	# Right leg
	var right_leg = MeshInstance3D.new()
	right_leg.mesh = leg_mesh
	right_leg.position = Vector3(0.15, -0.75, 0)
	right_leg.name = "RightLeg"
	add_child(right_leg)
	
	# Surgery area indicator (abdomen)
	var surgery_area = MeshInstance3D.new()
	var area_mesh = BoxMesh.new()
	area_mesh.size = Vector3(0.4, 0.3, 0.05)
	surgery_area.mesh = area_mesh
	surgery_area.position = Vector3(0, -0.1, 0.18)
	surgery_area.name = "SurgeryArea"
	
	# Create material for surgery area
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.9, 0.8, 0.7)
	surgery_area.material_override = material
	
	add_child(surgery_area)

func _on_vitals_changed(new_vitals: Dictionary) -> void:
	vitals = new_vitals

func set_condition(new_condition: String) -> void:
	condition = new_condition
	Events.patient_condition_changed.emit(condition)
	Events.log_event("patient_condition_changed", {"condition": condition})

func get_info() -> Dictionary:
	return {
		"name": patient_name,
		"age": age,
		"gender": gender,
		"condition": condition,
		"vitals": vitals
	}
