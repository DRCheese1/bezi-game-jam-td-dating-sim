extends Area2D
class_name BaseTower

@export var tower: TowerData

const UPGRADE_THRESHOLD: int = 2

# Stats
var fire_rate: float
var damage: int
var tower_range: int

# Attack variables
var targets: Array[BaseEnemy] = []
var can_attack: bool = true

# Upgrade variables
var path_a_tier: int = 0
var path_b_tier: int = 0

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

# ---- Attack logic ----

func _on_area_entered(area: Area2D) -> void:
	if area is BaseEnemy:
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
	
	var target: BaseEnemy = _choose_target()
	if target.has_method("take_damage"):
		target.take_damage(damage)
	
	can_attack = false
	attack_timer.start()

func _choose_target() -> BaseEnemy:
	var best = targets[0]
	for t in targets:
		if t.distance > best.distance:
			best = t
	return best

# -<>- Attack Logic -<>-

# ---- Upgrade Logic ----

func purchase_upgrade(path: String) -> void:
	if not can_upgrade_path(path):
		return
	
	var upgrade: UpgradeData
	if path == "a":
		upgrade = tower.path_a[path_a_tier]
		path_a_tier += 1
	elif path == "b":
		upgrade = tower.path_b[path_b_tier]
		path_b_tier += 1
	else:
		return
	
	_apply_upgrade(upgrade)

func _apply_upgrade(upgrade: UpgradeData) -> void:
	tower_range = int(tower_range * upgrade.range_multi + upgrade.range_add )
	damage = int(damage * upgrade.damage_multi + upgrade.damage_add )
	fire_rate = (fire_rate * upgrade.fire_rate_multi + upgrade.fire_rate_add)
	
	if upgrade.custom_effect:
		upgrade.custom_effect.apply(self)

func can_upgrade_path(path: String) -> bool:
	var this_tier: int
	var other_tier: int
	var max_tier: int
	
	if path == "a":
		this_tier = path_a_tier
		other_tier = path_b_tier
		max_tier = tower.path_a.size()
	elif path == "b":
		this_tier = path_b_tier
		other_tier = path_a_tier
		max_tier = tower.path_b.size()
	else:
		return false
	
	if this_tier >= max_tier:
		return false
	
	if other_tier > UPGRADE_THRESHOLD and this_tier >= UPGRADE_THRESHOLD:
		return false
	
	return true


# -<>- Upgrade Logic -<>-
