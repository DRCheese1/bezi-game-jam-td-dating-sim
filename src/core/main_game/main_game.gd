extends Node
class_name MainGame


var _current_level = null

# Game World root nodes
@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var effect_root: Node2D = %EffectRoot

# UI Root nodes
@onready var hud_root: Control = %HudRoot
@onready var menu_root: Control = %MenuRoot
@onready var pause_root: Control = %PauseRoot
@onready var transition_root: Control = %TransitionRoot
@onready var debug_root: Control = %DebugRoot

func _ready() -> void:
	
	GameManager.entity_root = entity_root
