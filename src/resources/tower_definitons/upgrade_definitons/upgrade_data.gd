extends Resource
class_name UpgradeData

@export var upgrade_name: String
@export var description: String
@export var icon: Texture2D
@export var cost: int

# Generic stat changes
@export var range_add: float = 0.0
@export var range_multi: float = 1.0
@export var damage_add: float = 0
@export var damage_multi: float = 1.0
@export var fire_rate_add: float = 0
@export var fire_rate_multi: float = 1.0

# Custom effect for advanced upgrade
@export var custom_effect: UpgradeEffect
