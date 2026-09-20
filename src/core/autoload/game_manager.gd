extends Node

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

func start_dialauge(timeline_name: String):
	hud_root.visible = false
	print("Dialauge started")
	Dialogic.start(timeline_name)

func end_dialauge():
	hud_root.visible = true
	var wave_system: System = access_system("WaveSpawner")
	wave_system.next_wave_sequence()
