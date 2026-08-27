extends Node3D

## OperatingTable - Simple operating table

func _ready() -> void:
	_create_table()

func _create_table() -> void:
	# Table top
	var table_top = MeshInstance3D.new()
	var top_mesh = BoxMesh.new()
	top_mesh.size = Vector3(2.0, 0.1, 1.0)
	table_top.mesh = top_mesh
	table_top.position = Vector3(0, 0.8, 0)
	table_top.name = "TableTop"
	add_child(table_top)
	
	# Create table material
	var table_material = StandardMaterial3D.new()
	table_material.albedo_color = Color(0.6, 0.6, 0.65)
	table_material.metallic = 0.3
	table_material.roughness = 0.7
	table_top.material_override = table_material
	
	# Table legs
	var leg_positions = [
		Vector3(-0.85, 0, -0.4),
		Vector3(0.85, 0, -0.4),
		Vector3(-0.85, 0, 0.4),
		Vector3(0.85, 0, 0.4)
	]
	
	for pos in leg_positions:
		var leg = MeshInstance3D.new()
		var leg_mesh = BoxMesh.new()
		leg_mesh.size = Vector3(0.08, 0.8, 0.08)
		leg.mesh = leg_mesh
		leg.position = pos
		leg.name = "Leg"
		add_child(leg)
		leg.material_override = table_material
	
	# Add table padding (thin mattress)
	var padding = MeshInstance3D.new()
	var padding_mesh = BoxMesh.new()
	padding_mesh.size = Vector3(1.8, 0.05, 0.8)
	padding.mesh = padding_mesh
	padding.position = Vector3(0, 0.875, 0)
	padding.name = "Padding"
	add_child(padding)
	
	# Create padding material
	var padding_material = StandardMaterial3D.new()
	padding_material.albedo_color = Color(0.2, 0.3, 0.4)
	padding.material_override = padding_material
