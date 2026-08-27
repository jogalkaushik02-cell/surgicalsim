extends Node

## RoleSystem - Manages surgical team roles and assignments

enum Role {
	LEAD_SURGEON,
	ASSISTANT_SURGEON,
	SCRUB_NURSE,
	ANESTHESIOLOGIST
}

# Role definitions with capabilities
var role_definitions: Dictionary = {
	Role.LEAD_SURGEON: {
		"name": "Lead Surgeon",
		"description": "Primary surgeon performing the procedure",
		"can_cut": true,
		"can_retract": false,
		"can_grasp": false,
		"can_suture": true,
		"can_select_instruments": false,
		"can_monitor_vitals": false,
		"priority": 1
	},
	Role.ASSISTANT_SURGEON: {
		"name": "Assistant Surgeon",
		"description": "Assists with retraction and grasping",
		"can_cut": false,
		"can_retract": true,
		"can_grasp": true,
		"can_suture": false,
		"can_select_instruments": false,
		"can_monitor_vitals": false,
		"priority": 2
	},
	Role.SCRUB_NURSE: {
		"name": "Scrub Nurse",
		"description": "Manages and passes instruments",
		"can_cut": false,
		"can_retract": false,
		"can_grasp": false,
		"can_suture": false,
		"can_select_instruments": true,
		"can_monitor_vitals": false,
		"priority": 3
	},
	Role.ANESTHESIOLOGIST: {
		"name": "Anesthesiologist",
		"description": "Monitors patient vitals and sedation",
		"can_cut": false,
		"can_retract": false,
		"can_grasp": false,
		"can_suture": false,
		"can_select_instruments": false,
		"can_monitor_vitals": true,
		"priority": 4
	}
}

# Current role assignments: peer_id -> Role
var role_assignments: Dictionary = {}
# Which role the local player has
var local_role: Role = Role.LEAD_SURGEON
# Is this a single player game
var is_single_player: bool = true

signal role_assigned(peer_id: int, role: Role)
signal role_removed(peer_id: int)
signal local_role_changed(old_role: Role, new_role: Role)

func _ready() -> void:
	pass

func assign_role(peer_id: int, role: Role) -> void:
	# Remove any existing assignment for this peer
	for existing_peer in role_assignments:
		if role_assignments[existing_peer] == role:
			role_assignments.erase(existing_peer)
			role_removed.emit(existing_peer)
			break
	
	role_assignments[peer_id] = role
	role_assigned.emit(peer_id, role)
	Events.log_event("role_assigned", {"peer_id": peer_id, "role": role_definitions[role]["name"]})

func remove_role(peer_id: int) -> void:
	if role_assignments.has(peer_id):
		var role = role_assignments[peer_id]
		role_assignments.erase(peer_id)
		role_removed.emit(peer_id)
		Events.log_event("role_removed", {"peer_id": peer_id, "role": role_definitions[role]["name"]})

func set_local_role(role: Role) -> void:
	var old_role = local_role
	local_role = role
	local_role_changed.emit(old_role, role)
	Events.log_event("local_role_changed", {"old_role": role_definitions[old_role]["name"], "new_role": role_definitions[role]["name"]})

func get_role_for_peer(peer_id: int) -> Role:
	return role_assignments.get(peer_id, Role.LEAD_SURGEON)

func get_peer_with_role(role: Role) -> int:
	for peer_id in role_assignments:
		if role_assignments[peer_id] == role:
			return peer_id
	return -1

func get_unassigned_roles() -> Array[Role]:
	var assigned_roles = role_assignments.values()
	var unassigned = []
	for role in role_definitions:
		if role not in assigned_roles:
			unassigned.append(role)
	return unassigned

func get_ai_roles() -> Array[Role]:
	if is_single_player:
		# In single player, all non-lead roles are AI
		return [Role.ASSISTANT_SURGEON, Role.SCRUB_NURSE, Role.ANESTHESIOLOGIST]
	else:
		# In multiplayer, AI takes unassigned roles
		return get_unassigned_roles()

func can_perform_action(peer_id: int, action: String) -> bool:
	var role = get_role_for_peer(peer_id)
	var role_data = role_definitions.get(role, {})
	return role_data.get(action, false)

func can_local_perform_action(action: String) -> bool:
	var role_data = role_definitions.get(local_role, {})
	return role_data.get(action, false)

func get_role_name(role: Role) -> String:
	return role_definitions[role]["name"]

func get_role_description(role: Role) -> String:
	return role_definitions[role]["description"]

func get_all_roles() -> Array[Role]:
	return role_definitions.keys()

func get_assignments() -> Dictionary:
	return role_assignments.duplicate()

func reset() -> void:
	role_assignments.clear()
	local_role = Role.LEAD_SURGEON
	is_single_player = true
