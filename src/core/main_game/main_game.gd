extends Node
class_name MainGame


var _current_level = null

# Game World root nodes
@onready var level_root: Node2D = $World/LevelRoot
@onready var entity_root: Node2D = $World/EntityRoot
@onready var effect_root: Node2D = $World/EffectRoot

# UI Root nodes
@onready var hud_root: Control = $HudLayer/HudRoot
@onready var pause_root: Control = $PauseLayer/PauseRoot
@onready var transition_root: Control = $TransitionLayer/TransitionRoot
@onready var debug_root: Control = $DebugLayer/DebugRoot
