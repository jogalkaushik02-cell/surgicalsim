extends Node

## SyncManager - Synchronizes game state across network

var is_active: bool = false
var sync_interval: float = 0.1  # 100ms
var sync_timer: float = 0.0

# State to sync
var synced_state: Dictionary = {
	"surgical_step": 0,
	"patient_vitals": {},
	"bleeding": {},
	"score": 0,
	"interactions": []
}

signal state_synced(state: Dictionary)
signal interaction_synced(data: Dictionary)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if is_active and WebRTCMultiplayer.is_online():
		sync_timer += delta
		if sync_timer >= sync_interval:
			sync_timer = 0.0
			_sync_state()

func start_sync() -> void:
	is_active = true
	sync_timer = 0.0

func stop_sync() -> void:
	is_active = false

func _sync_state() -> void:
	if not WebRTCMultiplayer.is_host:
		return
	
	# Gather current state
	var state_machine = get_node_or_null("/root/MainScene/AppendicectomyStateMachine")
	if state_machine:
		synced_state["surgical_step"] = state_machine.current_step
	synced_state["patient_vitals"] = SimulationManager.patient_vitals
	synced_state["bleeding"] = BleedingSimulation.get_status()
	synced_state["score"] = SimulationManager.score
	
	# Send to all peers
	WebRTCMultiplayer.send_game_data({
		"type": "state_sync",
		"state": synced_state
	})

# ==================== SYNC HANDLERS ====================

func sync_interaction(data: Dictionary) -> void:
	var instrument = data.get("instrument", "")
	var target = data.get("target", "")
	var is_valid = data.get("is_valid", false)
	var sender = data.get("from_peer", 0)
	
	SimulationManager.register_interaction(instrument, target, is_valid)
	interaction_synced.emit(data)

func sync_vitals(data: Dictionary) -> void:
	var vitals = data.get("vitals", {})
	SimulationManager.patient_vitals = vitals
	Events.patient_vitals_changed.emit(vitals)

func sync_role_assign(data: Dictionary) -> void:
	var peer_id = data.get("peer_id", 0)
	var role = data.get("role", 0)
	RoleSystem.assign_role(peer_id, role)

func sync_surgical_step(step: int) -> void:
	WebRTCMultiplayer.send_game_data({
		"type": "surgical_step",
		"step": step
	})

func sync_bleeding(bleeding_data: Dictionary) -> void:
	WebRTCMultiplayer.send_game_data({
		"type": "bleeding",
		"data": bleeding_data
	})

func sync_score(score: int) -> void:
	WebRTCMultiplayer.send_game_data({
		"type": "score",
		"score": score
	})

# ==================== RPC-LIKE FUNCTIONS ====================

func rpc_select_instrument(instrument_name: String) -> void:
	WebRTCMultiplayer.send_game_data({
		"type": "rpc",
		"function": "select_instrument",
		"args": [instrument_name]
	})

func rpc_use_instrument(instrument: String, target: String) -> void:
	WebRTCMultiplayer.send_game_data({
		"type": "rpc",
		"function": "use_instrument",
		"args": [instrument, target]
	})

func rpc_chat_message(text: String, sender_name: String) -> void:
	WebRTCMultiplayer.send_game_data({
		"type": "rpc",
		"function": "chat_message",
		"args": [text, sender_name]
	})
