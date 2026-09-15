extends Node

var entity_root: Node2D

var systems: Dictionary

func _process(delta: float) -> void:
	if entity_root == null:
		print("Ts null")

func access_system(system_name: String, sub_system: String) -> System:
	if not systems.has(system_name):
		push_error("Unknown system: " + system_name)
		return null
	var parent_system: System = systems[system_name]
	if sub_system == "":
		return parent_system
	var child: Node = parent_system.get_node_or_null(sub_system)
	if child == null:
		push_error("Unknown sub system: %s/%s" % [system_name, sub_system])
		return null
	return child as System

func register_system(system_name: String, system: System) -> void:
	if systems.has(system_name):
		push_error("System already registered: " + system_name)
		return
	
	systems[system_name] = system
