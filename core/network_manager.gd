extends Node

## NetworkManager - Handles multiplayer networking

var is_host: bool = false
var is_connected: bool = false
var player_name: String = "Player"
var players: Dictionary = {}  # peer_id -> player_info
var port: int = 7777
var max_players: int = 4

# Player info structure
var local_player_info: Dictionary = {
	"id": 1,
	"name": "Player",
	"role": 0,  # Role enum
	"is_ready": false
}

signal player_connected(peer_id: int, player_info: Dictionary)
signal player_disconnected(peer_id: int)
signal server_connected()
signal server_disconnected()
signal connection_failed()
signal game_starting()
signal role_assigned_by_host(peer_id: int, role: int)

func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func host_game(host_port: int = 7777) -> Error:
	port = host_port
	is_host = true
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, max_players)
	if error != OK:
		push_error("Failed to create server: ", error)
		return error
	
	multiplayer.multiplayer_peer = peer
	is_connected = true
	
	# Add self to players
	local_player_info["id"] = 1
	local_player_info["name"] = player_name
	players[1] = local_player_info
	
	Events.log_event("game_hosted", {"port": port, "max_players": max_players})
	return OK

func join_game(address: String, join_port: int = 7777) -> Error:
	port = join_port
	is_host = false
	
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		push_error("Failed to connect: ", error)
		return error
	
	multiplayer.multiplayer_peer = peer
	Events.log_event("game_joining", {"address": address, "port": port})
	return OK

func disconnect_game() -> void:
	multiplayer.multiplayer_peer = null
	is_connected = false
	is_host = false
	players.clear()
	Events.log_event("game_disconnected")

func _on_peer_connected(id: int) -> void:
	# Send our info to the new peer
	_send_player_info.rpc_id(id, local_player_info)

func _on_peer_disconnected(id: int) -> void:
	players.erase(id)
	player_disconnected.emit(id)
	Events.log_event("player_disconnected", {"peer_id": id})

func _on_connected_to_server() -> void:
	is_connected = true
	local_player_info["id"] = multiplayer.get_unique_id()
	server_connected.emit()
	Events.log_event("connected_to_server")

func _on_connection_failed() -> void:
	is_connected = false
	connection_failed.emit()
	Events.log_event("connection_failed")

func _on_server_disconnected() -> void:
	is_connected = false
	players.clear()
	server_disconnected.emit()
	Events.log_event("server_disconnected")

@rpc("any_peer", "reliable")
func _send_player_info(info: Dictionary) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	info["id"] = sender_id
	players[sender_id] = info
	player_connected.emit(sender_id, info)
	Events.log_event("player_info_received", {"peer_id": sender_id, "name": info.get("name", "Unknown")})

@rpc("authority", "reliable")
func assign_role(peer_id: int, role: int) -> void:
	if players.has(peer_id):
		players[peer_id]["role"] = role
		role_assigned_by_host.emit(peer_id, role)
		Events.log_event("role_assigned_network", {"peer_id": peer_id, "role": role})
		print("Role assigned to peer ", peer_id, ": ", role)

@rpc("any_peer", "reliable")
func sync_interaction(instrument: String, target: String, is_valid: bool) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	SimulationManager.register_interaction(instrument, target, is_valid)
	Events.log_event("interaction_synced", {"instrument": instrument, "target": target, "valid": is_valid, "sender": sender_id})

@rpc("any_peer", "reliable")
func sync_vitals(vitals: Dictionary) -> void:
	SimulationManager.patient_vitals = vitals
	Events.patient_vitals_changed.emit(vitals)

@rpc("any_peer", "reliable")
func sync_bleeding(is_bleeding: bool, severity: int, blood_loss: float) -> void:
	var bleeding_sim = get_node_or_null("/root/MainScene/BleedingSimulation")
	if bleeding_sim:
		bleeding_sim.is_bleeding = is_bleeding
		bleeding_sim.bleeding_severity = severity
		bleeding_sim.blood_loss = blood_loss

@rpc("authority", "reliable")
func start_game() -> void:
	game_starting.emit()
	Events.log_event("game_starting")

@rpc("any_peer", "reliable")
func sync_surgical_step(step: int) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	Events.log_event("surgical_step_synced", {"step": step, "sender": sender_id})

func get_player_list() -> Array[Dictionary]:
	return players.values()

func get_player_count() -> int:
	return players.size()

func get_player_info(peer_id: int) -> Dictionary:
	return players.get(peer_id, {})

func set_player_name(new_name: String) -> void:
	player_name = new_name
	local_player_info["name"] = new_name

func is_multiplayer_active() -> bool:
	return is_connected and multiplayer.multiplayer_peer != null

func get_peer_id() -> int:
	if is_multiplayer_active():
		return multiplayer.get_unique_id()
	return 1
