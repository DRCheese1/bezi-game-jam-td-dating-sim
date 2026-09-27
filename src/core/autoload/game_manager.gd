extends Node

signal show_death_ui()

var tower_root: Node2D
var entity_root: Node2D

var hud_root: Control

var systems: Dictionary

func access_system(system_name: String, sub_system: String = "") -> System:
	if not systems.has(system_name):
		push_warning("Unknown system: " + system_name)
		return null
	var parent_system: System = systems[system_name]
	if sub_system == "":
		return parent_system
	var child: Node = parent_system.get_node_or_null(sub_system)
	if child == null:
		push_warning("Unknown sub system: %s/%s" % [system_name, sub_system])
		return null
	return child as System

## Like access_system, but waits if the system hasn't registered yet.
## Use this from _ready() where autoload/scene ordering means the system
## you need might not exist for the first frame or two. Waits one frame
## at a time (not a fixed sleep) so it grabs the system the instant it's
## ready, and calls fatal_error if it never shows up within timeout_seconds.
func access_system_when_ready(system_name: String, timeout_seconds: float = 3.0) -> System:
	var elapsed := 0.0
	while not systems.has(system_name) and elapsed < timeout_seconds:
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	
	if not systems.has(system_name):
		fatal_error("%s system not found." % system_name, "Timed out waiting for system: " + system_name)
		return null
	
	return systems[system_name]

func register_system(system_name: String, system: System) -> void:
	if systems.has(system_name):
		push_error("System already registered: " + system_name)
		return
	
	systems[system_name] = system

func fatal_error(message: String, debug_message: String = ""):
	if debug_message != "":
		push_error("FATAL: " + debug_message)
	
	OS.alert(message, "Fatal Error")
	
	get_tree().quit(1)

func start_dialogue(timeline_name: String):
	hud_root.visible = false
	print("Dialogue started")
	Dialogic.start(timeline_name)

func end_dialogue():
	hud_root.visible = true
	var wave_system: System = access_system(SystemNames.WAVE_SPAWNER)
	wave_system.next_wave_sequence()

func apply_vulnerability_risk(amount: float, success_chance: float) -> void:
	var relationship = access_system(SystemNames.RELATIONSHIP)
	relationship.apply_vulnerability_risk(amount, success_chance)

func reset_gamemanager() -> void:
	tower_root = null
	entity_root = null
	hud_root = null
	systems = {}

func on_relationship_failed() -> void:
	Dialogic.end_timeline(true)
	await get_tree().process_frame
	show_death_ui.emit()
	await get_tree().process_frame
	get_tree().paused = true
