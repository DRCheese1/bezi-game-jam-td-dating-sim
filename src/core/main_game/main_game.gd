extends Node
class_name MainGame


var _current_level = null
var spawn_system: System

# Game World root nodes
@onready var level_root: Node2D = %LevelRoot
@onready var tower_root: Node2D = %TowerRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var effect_root: Node2D = %EffectRoot

# UI Root nodes
@onready var hud_root: Control = %HudRoot
@onready var menu_root: Control = %MenuRoot
@onready var pause_root: Control = %PauseRoot
@onready var transition_root: Control = %TransitionRoot
@onready var debug_root: Control = %DebugRoot

func quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()


func _ready() -> void:
	GameManager.tower_root = tower_root
	GameManager.entity_root = entity_root
	GameManager.access_system("Relationship").relationship_failed.connect(_on_relationship_failed)
	spawn_system = GameManager.access_system("WaveSpawner")
	GameManager.start_dialauge("main-timeline")
	GameManager.hud_root = hud_root


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	
	if event.is_action_pressed(&"debug"):
		debug_root.toggle_debug_layer()
	
	if event.is_action_pressed(&"debug_quit"):
		quit_game()
	
	if event.is_action_pressed("testspawn"):
		spawn_system.test_wave()


func _on_relationship_failed():
	print("ded")
	get_tree().paused = true
