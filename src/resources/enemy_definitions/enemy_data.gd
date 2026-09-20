# EnemyData.gd
extends Resource
class_name EnemyData

@export var scene: PackedScene
@export var cost: int = 10
@export var speed: int = 50
@export var health: int = 100
@export var damage: int = 15
@export var base_weight: float = 1.0
@export var min_wave: int = 1
@export var min_group_size: int = 2
@export var max_group_size: int = 5
@export var currency_type: Array[String] = ["charm"]
@export var currency_weights: Array[float] = [1]
@export var currency_amount: int

var _base_stats: Dictionary = {}
var _stats_captured: bool = false

func capture_base_stats() -> void:
	if _stats_captured:
		return
	_base_stats = {
		"min_group_size": min_group_size,
		"max_group_size": max_group_size,
		"currency_amount": currency_amount,
		"health": health,
	}
	_stats_captured = true

func reset_stats() -> void:
	if not _stats_captured:
		return
	min_group_size = _base_stats["min_group_size"]
	max_group_size = _base_stats["max_group_size"]
	currency_amount = _base_stats["currency_amount"]
	health = _base_stats["health"]
