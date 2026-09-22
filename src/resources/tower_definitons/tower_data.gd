extends Resource
class_name TowerData

@export var scene: PackedScene
@export var icon: Texture2D
@export var currency_type: String = "charm"
@export var cost: int = 15
@export var display_name: String = "Flirt Tower"

# Stats
@export var damage: int = 1
@export var fire_rate: int = 1
@export var tower_range: int = 75

@export var tower_build_area: float = 10
@export var building_area_offset: Vector2 = Vector2(0, 12)

# Upgrades
@export var path_a: Array[UpgradeData]
@export var path_b: Array[UpgradeData]
