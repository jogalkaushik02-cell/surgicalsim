extends Node3D

## OperatingTable - Improved operating table with proper proportions

func _ready() -> void:
	_create_table()

func _create_table() -> void:
	var metal_material = StandardMaterial3D.new()
	metal_material.albedo_color = Color(0.65, 0.65, 0.7)
	metal_material.metallic = 0.4
	metal_material.roughness = 0.5

	var pad_material = StandardMaterial3D.new()
	pad_material.albedo_color = Color(0.15, 0.2, 0.25)
	pad_material.roughness = 0.9

	# Base column (center support)
	var base = MeshInstance3D.new()
	var base_mesh = CylinderMesh.new()
	base_mesh.top_radius = 0.15
	base_mesh.bottom_radius = 0.2
	base_mesh.height = 0.7
	base.mesh = base_mesh
	base.position = Vector3(0, 0.35, 0)
	base.name = "Base"
	base.material_override = metal_material
	add_child(base)

	# Table top frame
	var frame = MeshInstance3D.new()
	var frame_mesh = BoxMesh.new()
	frame_mesh.size = Vector3(2.2, 0.06, 1.0)
	frame.mesh = frame_mesh
	frame.position = Vector3(0, 0.75, 0)
	frame.name = "Frame"
	frame.material_override = metal_material
	add_child(frame)

	# Table top surface (padded)
	var top = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(2.0, 0.08, 0.9)
	top.mesh = top_mesh
	top.position = Vector3(0, 0.82, 0)
	top.name = "TableTop"
	top.material_override = pad_material
	add_child(top)

	# Head rest (raised section)
	var head_rest = MeshInstance3D.new()
	var head_mesh = BoxMesh.new()
	head_mesh.size = Vector3(0.3, 0.06, 0.3)
	head_rest.mesh = head_mesh
	head_rest.position = Vector3(0, 0.87, -0.45)
	head_rest.name = "HeadRest"
	head_rest.material_override = pad_material
	add_child(head_rest)

	# Side rails (left)
	var rail_left = MeshInstance3D.new()
	var rail_mesh = BoxMesh.new()
	rail_mesh.size = Vector3(0.03, 0.12, 1.8)
	rail_left.mesh = rail_mesh
	rail_left.position = Vector3(-1.1, 0.88, 0)
	rail_left.name = "RailLeft"
	rail_left.material_override = metal_material
	add_child(rail_left)

	# Side rails (right)
	var rail_right = MeshInstance3D.new()
	rail_right.mesh = rail_mesh
	rail_right.position = Vector3(1.1, 0.88, 0)
	rail_right.name = "RailRight"
	rail_right.material_override = metal_material
	add_child(rail_right)

	# Legs (4 casters)
	var leg_positions = [
		Vector3(-0.8, 0, -0.35),
		Vector3(0.8, 0, -0.35),
		Vector3(-0.8, 0, 0.35),
		Vector3(0.8, 0, 0.35)
	]

	for pos in leg_positions:
		var leg = MeshInstance3D.new()
		var leg_mesh = CylinderMesh.new()
		leg_mesh.top_radius = 0.03
		leg_mesh.bottom_radius = 0.03
		leg_mesh.height = 0.7
		leg.mesh = leg_mesh
		leg.position = pos + Vector3(0, 0.35, 0)
		leg.name = "Leg"
		leg.material_override = metal_material
		add_child(leg)

		# Caster wheel
		var wheel = MeshInstance3D.new()
		var wheel_mesh = SphereMesh.new()
		wheel_mesh.radius = 0.04
		wheel.mesh = wheel_mesh
		wheel.position = pos + Vector3(0, 0.02, 0)
		wheel.name = "Wheel"
		wheel.material_override = metal_material
		add_child(wheel)

	# Instrument tray (side table)
	var tray = MeshInstance3D.new()
	var tray_mesh = BoxMesh.new()
	tray_mesh.size = Vector3(0.5, 0.02, 0.35)
	tray.mesh = tray_mesh
	tray.position = Vector3(1.5, 0.85, 0)
	tray.name = "InstrumentTray"
	tray.material_override = metal_material
	add_child(tray)

	# Tray leg
	var tray_leg = MeshInstance3D.new()
	var tray_leg_mesh = CylinderMesh.new()
	tray_leg_mesh.top_radius = 0.03
	tray_leg_mesh.bottom_radius = 0.03
	tray_leg_mesh.height = 0.7
	tray_leg.mesh = tray_leg_mesh
	tray_leg.position = Vector3(1.5, 0.45, 0)
	tray_leg.name = "TrayLeg"
	tray_leg.material_override = metal_material
	add_child(tray_leg)
