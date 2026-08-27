extends Node

## WebRTCMultiplayer - Online multiplayer via WebRTC (free, P2P)

var is_host: bool = false
var is_connected: bool = false
var peer_id: int = 0
var room_code: String = ""
var players: Dictionary = {}

# WebRTC peers
var rtc_peer: WebRTCMultiplayerPeer = null
var signaling_client: WebSocketPeer = null

# Signaling server (loaded from config)
var signaling_url: String = "wss://surgicalsimsignaling.onrender.com"
var stun_servers: Array = [
	"stun:stun.l.google.com:19302",
	"stun:stun1.l.google.com:19302"
]

# Config file path
const CONFIG_PATH = "res://config/server_config.json"

signal connected_to_server()
signal disconnected_from_server()
signal room_joined(room_code: String)
signal player_joined(peer_id: int, info: Dictionary)
signal player_left(peer_id: int)
signal connection_failed()

func _ready() -> void:
	_load_config()

func _load_config() -> void:
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		file.close()
		
		if error == OK:
			var config = json.data
			signaling_url = config.get("signaling_url", signaling_url)
			stun_servers = config.get("stun_servers", stun_servers)
			print("Loaded server config: ", signaling_url)
	else:

func _process(_delta: float) -> void:
	if signaling_client:
		_signaling_process()

# ==================== CONNECTION ====================

func connect_to_signaling() -> void:
	signaling_client = WebSocketPeer.new()
	var error = signaling_client.connect_to_url(signaling_url)
	
	if error == OK:
		print("Connecting to signaling server...")
	else:
		print("Failed to connect to signaling server")
		connection_failed.emit()

func disconnect_from_signaling() -> void:
	if signaling_client:
		signaling_client.close()
		signaling_client = null

func _signaling_process() -> void:
	signaling_client.poll()
	
	var state = signaling_client.get_ready_state()
	
	match state:
		WebSocketPeer.STATE_OPEN:
			while signaling_client.get_available_packet_count():
				var packet = signaling_client.get_packet().get_string_from_utf8()
				_handle_signaling_message(packet)
		
		WebSocketPeer.STATE_CLOSED:
			var code = signaling_client.get_close_code()
			var reason = signaling_client.get_close_reason()
			push_warning("Signaling closed: ", code, " - ", reason)
			disconnected_from_server.emit()

func _handle_signaling_message(message: String) -> void:
	var json = JSON.new()
	var error = json.parse(message)
	if error != OK:
		return
	
	var data = json.data
	var msg_type = data.get("type", "")
	
	match msg_type:
		"welcome":
			peer_id = data.get("peer_id", 0)
			is_connected = true
			connected_to_server.emit()
			print("Connected to signaling, peer_id: ", peer_id)
		
		"room_joined":
			room_code = data.get("room_code", "")
			room_joined.emit(room_code)
			print("Joined room: ", room_code)
		
		"player_joined":
			var new_peer_id = data.get("peer_id", 0)
			var info = data.get("info", {})
			players[new_peer_id] = info
			player_joined.emit(new_peer_id, info)
			_establish_peer_connection(new_peer_id)
		
		"player_left":
			var left_peer_id = data.get("peer_id", 0)
			players.erase(left_peer_id)
			player_left.emit(left_peer_id)
		
		"offer", "answer", "ice_candidate":
			_handle_web_rtc_signaling(data)

func _send_signaling_message(message: Dictionary) -> void:
	if signaling_client and signaling_client.get_ready_state() == WebSocketPeer.STATE_OPEN:
		signaling_client.send_text(JSON.stringify(message))

# ==================== ROOM MANAGEMENT ====================

func create_room() -> String:
	room_code = _generate_room_code()
	_send_signaling_message({
		"type": "create_room",
		"room_code": room_code
	})
	is_host = true
	return room_code

func join_room(code: String) -> void:
	room_code = code
	_send_signaling_message({
		"type": "join_room",
		"room_code": code
	})

func leave_room() -> void:
	_send_signaling_message({
		"type": "leave_room"
	})
	room_code = ""
	players.clear()
	is_host = false

func _generate_room_code() -> String:
	var chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var code = ""
	for i in range(6):
		code += chars[randi() % chars.length()]
	return code

# ==================== WebRTC ====================

func _establish_peer_connection(remote_peer_id: int) -> void:
	var peer = WebRTCPeerConnection.new()
	
	# Configure ICE servers from config
	var ice_servers = []
	for server in stun_servers:
		ice_servers.append({"urls": server})
	peer.initialize({"ice_servers": ice_servers})
	
	# Create data channel for game data
	peer.create_data_channel("game", {"negotiated": true, "id": 1})
	
	# Connect signals
	peer.session_description_created.connect(_on_session_description_created.bind(remote_peer_id))
	peer.ice_candidate.connect(_on_ice_candidate.bind(remote_peer_id))
	peer.connected.connect(_on_peer_connected.bind(remote_peer_id))
	peer.disconnected.connect(_on_peer_disconnected.bind(remote_peer_id))
	peer.data_channel_received.connect(_on_data_channel_received.bind(remote_peer_id))
	
	# Store peer
	if not rtc_peer:
		rtc_peer = WebRTCMultiplayerPeer.new()
	
	rtc_peer.add_peer(peer, remote_peer_id)
	
	# Create offer if we're the first to connect
	if is_host:
		peer.create_offer()

func _on_session_description_created(session_description: Dictionary, type: String, remote_peer_id: int) -> void:
	_send_signaling_message({
		"type": type,
		"session_description": session_description,
		"target_peer": remote_peer_id
	})

func _on_ice_candidate(media: String, index: int, candidate_name: String, remote_peer_id: int) -> void:
	_send_signaling_message({
		"type": "ice_candidate",
		"media": media,
		"index": index,
		"candidate_name": candidate_name,
		"target_peer": remote_peer_id
	})

func _on_peer_connected(remote_peer_id: int) -> void:

func _on_peer_disconnected(remote_peer_id: int) -> void:
	players.erase(remote_peer_id)
	player_left.emit(remote_peer_id)

func _on_data_channel_received(channel: WebRTCDataChannel, remote_peer_id: int) -> void:
	while channel.get_available_packet_count():
		var packet = channel.get_packet().get_string_from_utf8()
		_handle_game_data(packet, remote_peer_id)

func _handle_web_rtc_signaling(data: Dictionary) -> void:
	var type = data.get("type", "")
	var remote_peer_id = data.get("from_peer", 0)
	var session_description = data.get("session_description", {})
	
	if not rtc_peer:
		return
	
	var peer = rtc_peer.get_peer(remote_peer_id)
	if not peer:
		return
	
	match type:
		"offer":
			peer.set_remote_description(session_description)
		"answer":
			peer.set_remote_description(session_description)
		"ice_candidate":
			peer.add_ice_candidate(
				data.get("media", ""),
				data.get("index", 0),
				data.get("candidate_name", "")
			)

# ==================== GAME DATA ====================

func send_game_data(data: Dictionary) -> void:
	if not rtc_peer:
		return
	
	var message = JSON.stringify(data)
	
	for remote_peer_id in players:
		var peer = rtc_peer.get_peer(remote_peer_id)
		if peer and peer.get_connection_state() == WebRTCPeerConnection.STATE_CONNECTED:
			var channel = peer.get_data_channel("game")
			if channel and channel.get_ready_state() == WebRTCDataChannel.STATE_OPEN:
				channel.put_packet(message.to_utf8_buffer())

func _handle_game_data(message: String, from_peer: int) -> void:
	var json = JSON.new()
	var error = json.parse(message)
	if error != OK:
		return
	
	var data = json.data
	data["from_peer"] = from_peer
	
	# Forward to appropriate handler
	var msg_type = data.get("type", "")
	match msg_type:
		"interaction":
			SyncManager.sync_interaction(data)
		"vitals":
			SyncManager.sync_vitals(data)
		"role_assign":
			SyncManager.sync_role_assign(data)

# ==================== UTILITY ====================

func get_peer_id() -> int:
	return peer_id

func get_room_code() -> String:
	return room_code

func get_players() -> Dictionary:
	return players

func is_online() -> bool:
	return is_connected and signaling_client != null

func get_player_count() -> int:
	return players.size() + 1
