extends Area2D

@export var tower: TowerData

var fire_rate: int
var damage: int
var tower_range: int

var targets: Array[Area2D] = []
var can_attack: bool = true

@onready var attack_timer: Timer = $AttackTimer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var building_area: Area2D = $BuildingArea
@onready var building_collision_shape: CollisionShape2D = $BuildingArea/CollisionShape2D


func _ready() -> void:
	fire_rate = tower.fire_rate
	damage = tower.damage
	tower_range = tower.tower_range
	
	attack_timer.wait_time = fire_rate
	collision_shape_2d.shape.radius = tower_range
	
	building_area.position = tower.building_area_offset
	building_collision_shape.shape.radius = tower.tower_build_area

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		targets.append(area)
		if can_attack:
			_attack()

func _on_area_exited(area: Area2D) -> void:
	targets.erase(area)

func _on_attack_timer_timeout() -> void:
	can_attack = true
	_attack()

func _attack():
	targets = targets.filter(func(t): return is_instance_valid(t))
	
	if targets.is_empty():
		return
	
	var target: Area2D = choose_target()
	if target.has_method("take_damage"):
		target.take_damage(damage)
	
	can_attack = false
	attack_timer.start()

func choose_target() -> Area2D:
	var best = targets[0]
	for t in targets:
		if t.distance > best.distance:
			best = t
	return best
