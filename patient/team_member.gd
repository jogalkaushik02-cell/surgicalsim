extends Node3D

## TeamMember - Placeholder team member character around the operating table

@export var member_role: String = "Assistant Surgeon"
@export var member_color: Color = Color(0.3, 0.5, 0.7)

var label_3d: Label3D = null

func _ready() -> void:
	_create_character()

func _create_character() -> void:
	var uniform_material = StandardMaterial3D.new()
	uniform_material.albedo_color = member_color
	uniform_material.roughness = 0.85

	var skin_material = StandardMaterial3D.new()
	skin_material.albedo_color = Color(0.82, 0.7, 0.62)
	skin_material.roughness = 0.8

	# Body (scrubs)
	var body = MeshInstance3D.new()
	var body_mesh = CapsuleMesh.new()
	body_mesh.radius = 0.18
	body_mesh.height = 0.7
	body.mesh = body_mesh
	body.position = Vector3(0, 0.55, 0)
	body.name = "Body"
	body.material_override = uniform_material
	add_child(body)

	# Head
	var head = MeshInstance3D.new()
	var head_mesh = SphereMesh.new()
	head_mesh.radius = 0.12
	head.mesh = head_mesh
	head.position = Vector3(0, 1.05, 0)
	head.name = "Head"
	head.material_override = skin_material
	add_child(head)

	# Surgical cap
	var cap = MeshInstance3D.new()
	var cap_mesh = SphereMesh.new()
	cap_mesh.radius = 0.13
	cap.mesh = cap_mesh
	cap.position = Vector3(0, 1.08, 0)
	cap.name = "Cap"

	var cap_material = StandardMaterial3D.new()
	cap_material.albedo_color = Color(0.2, 0.45, 0.5)
	cap.material_override = cap_material
	add_child(cap)

	# Mask
	var mask = MeshInstance3D.new()
	var mask_mesh = BoxMesh.new()
	mask_mesh.size = Vector3(0.1, 0.06, 0.04)
	mask.mesh = mask_mesh
	mask.position = Vector3(0, 1.0, 0.1)
	mask.name = "Mask"

	var mask_material = StandardMaterial3D.new()
	mask_material.albedo_color = Color(0.6, 0.8, 0.85)
	mask.material_override = mask_material
	add_child(mask)

	# Left arm
	var left_arm = MeshInstance3D.new()
	var arm_mesh = CapsuleMesh.new()
	arm_mesh.radius = 0.06
	arm_mesh.height = 0.45
	left_arm.mesh = arm_mesh
	left_arm.position = Vector3(-0.28, 0.55, 0)
	left_arm.name = "LeftArm"
	left_arm.material_override = uniform_material
	add_child(left_arm)

	# Right arm
	var right_arm = MeshInstance3D.new()
	right_arm.mesh = arm_mesh
	right_arm.position = Vector3(0.28, 0.55, 0)
	right_arm.name = "RightArm"
	right_arm.material_override = uniform_material
	add_child(right_arm)

	# Legs
	var leg_mesh = CapsuleMesh.new()
	leg_mesh.radius = 0.07
	leg_mesh.height = 0.5

	var left_leg = MeshInstance3D.new()
	left_leg.mesh = leg_mesh
	left_leg.position = Vector3(-0.1, 0.05, 0)
	left_leg.name = "LeftLeg"
	left_leg.material_override = uniform_material
	add_child(left_leg)

	var right_leg = MeshInstance3D.new()
	right_leg.mesh = leg_mesh
	right_leg.position = Vector3(0.1, 0.05, 0)
	right_leg.name = "RightLeg"
	right_leg.material_override = uniform_material
	add_child(right_leg)

	# Role label floating above head
	label_3d = Label3D.new()
	label_3d.text = member_role
	label_3d.font_size = 20
	label_3d.pixel_size = 0.005
	label_3d.position = Vector3(0, 1.35, 0)
	label_3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_3d.no_depth_test = true
	label_3d.modulate = Color(1, 1, 1, 0.85)
	add_child(label_3d)
