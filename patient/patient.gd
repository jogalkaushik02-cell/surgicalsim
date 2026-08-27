extends Node3D

## Patient - Placeholder patient model with proper proportions

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
	var skin_material = StandardMaterial3D.new()
	skin_material.albedo_color = Color(0.85, 0.72, 0.65)
	skin_material.roughness = 0.8

	var gown_material = StandardMaterial3D.new()
	gown_material.albedo_color = Color(0.4, 0.55, 0.7)
	gown_material.roughness = 0.9

	# Torso (main body) - lying flat, wider for surgery area
	var torso = MeshInstance3D.new()
	var torso_mesh = BoxMesh.new()
	torso_mesh.size = Vector3(0.5, 0.25, 1.0)
	torso.mesh = torso_mesh
	torso.position = Vector3(0, 0, 0)
	torso.name = "Torso"
	torso.material_override = gown_material
	add_child(torso)

	# Head
	var head = MeshInstance3D.new()
	var head_mesh = SphereMesh.new()
	head_mesh.radius = 0.12
	head.mesh = head_mesh
	head.position = Vector3(0, 0.08, -0.6)
	head.name = "Head"
	head.material_override = skin_material
	add_child(head)

	# Neck
	var neck = MeshInstance3D.new()
	var neck_mesh = CylinderMesh.new()
	neck_mesh.top_radius = 0.06
	neck_mesh.bottom_radius = 0.07
	neck_mesh.height = 0.1
	neck.mesh = neck_mesh
	neck.position = Vector3(0, 0.05, -0.48)
	neck.name = "Neck"
	neck.material_override = skin_material
	add_child(neck)

	# Left arm
	var left_arm = MeshInstance3D.new()
	var arm_mesh = BoxMesh.new()
	arm_mesh.size = Vector3(0.1, 0.1, 0.55)
	left_arm.mesh = arm_mesh
	left_arm.position = Vector3(-0.35, 0, -0.05)
	left_arm.name = "LeftArm"
	left_arm.material_override = gown_material
	add_child(left_arm)

	# Left hand
	var left_hand = MeshInstance3D.new()
	var hand_mesh = SphereMesh.new()
	hand_mesh.radius = 0.05
	left_hand.mesh = hand_mesh
	left_hand.position = Vector3(-0.35, 0, -0.35)
	left_hand.name = "LeftHand"
	left_hand.material_override = skin_material
	add_child(left_hand)

	# Right arm
	var right_arm = MeshInstance3D.new()
	right_arm.mesh = arm_mesh
	right_arm.position = Vector3(0.35, 0, -0.05)
	right_arm.name = "RightArm"
	right_arm.material_override = gown_material
	add_child(right_arm)

	# Right hand
	var right_hand = MeshInstance3D.new()
	right_hand.mesh = hand_mesh
	right_hand.position = Vector3(0.35, 0, -0.35)
	right_hand.name = "RightHand"
	right_hand.material_override = skin_material
	add_child(right_hand)

	# Left leg
	var left_leg = MeshInstance3D.new()
	var leg_mesh = BoxMesh.new()
	leg_mesh.size = Vector3(0.12, 0.12, 0.65)
	left_leg.mesh = leg_mesh
	left_leg.position = Vector3(-0.1, 0, 0.55)
	left_leg.name = "LeftLeg"
	left_leg.material_override = gown_material
	add_child(left_leg)

	# Left foot
	var left_foot = MeshInstance3D.new()
	var foot_mesh = BoxMesh.new()
	foot_mesh.size = Vector3(0.08, 0.06, 0.12)
	left_foot.mesh = foot_mesh
	left_foot.position = Vector3(-0.1, 0, 0.92)
	left_foot.name = "LeftFoot"
	left_foot.material_override = skin_material
	add_child(left_foot)

	# Right leg
	var right_leg = MeshInstance3D.new()
	right_leg.mesh = leg_mesh
	right_leg.position = Vector3(0.1, 0, 0.55)
	right_leg.name = "RightLeg"
	right_leg.material_override = gown_material
	add_child(right_leg)

	# Right foot
	var right_foot = MeshInstance3D.new()
	right_foot.mesh = foot_mesh
	right_foot.position = Vector3(0.1, 0, 0.92)
	right_foot.name = "RightFoot"
	right_foot.material_override = skin_material
	add_child(right_foot)

	# Surgery area - exposed abdomen (darker skin)
	var surgery_area = MeshInstance3D.new()
	var area_mesh = BoxMesh.new()
	area_mesh.size = Vector3(0.35, 0.02, 0.3)
	surgery_area.mesh = area_mesh
	surgery_area.position = Vector3(0, 0.14, 0.05)
	surgery_area.name = "SurgeryArea"

	var exposed_skin = StandardMaterial3D.new()
	exposed_skin.albedo_color = Color(0.9, 0.78, 0.7)
	surgery_area.material_override = exposed_skin
	add_child(surgery_area)

	# Surgical drape (blue/green cloth around surgery area)
	var drape = MeshInstance3D.new()
	var drape_mesh = BoxMesh.new()
	drape_mesh.size = Vector3(0.55, 0.01, 0.8)
	drape.mesh = drape_mesh
	drape.position = Vector3(0, 0.135, 0.05)
	drape.name = "Drape"

	var drape_material = StandardMaterial3D.new()
	drape_material.albedo_color = Color(0.2, 0.45, 0.5)
	drape_material.roughness = 0.95
	drape.material_override = drape_material
	add_child(drape)

	# Incision line indicator
	var incision = MeshInstance3D.new()
	var incision_mesh = BoxMesh.new()
	incision_mesh.size = Vector3(0.005, 0.025, 0.15)
	incision.mesh = incision_mesh
	incision.position = Vector3(0, 0.155, 0.05)
	incision.name = "IncisionLine"

	var incision_material = StandardMaterial3D.new()
	incision_material.albedo_color = Color(0.7, 0.2, 0.2)
	incision.material_override = incision_material
	add_child(incision)

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
