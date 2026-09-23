extends Control

# Utility variables
var tower: BaseTower
var upgrade_a: UpgradeData
var upgrade_b: UpgradeData

# Main tower description
@onready var name_label: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/NameLabel
@onready var damage_label: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/DamageLabel
@onready var range_label: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/RangeLabel
@onready var firerate_label: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer/FirerateLabel

# Upgrade path A
@onready var upgrade_a_panel: PanelContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/UpgradeAPanel
@onready var upgrade_a_name: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/UpgradeAPanel/HBoxContainer/VBoxContainer/UpgradeAName
@onready var upgrade_a_buy_button: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/UpgradeAPanel/HBoxContainer/VBoxContainer/UpgradeABuyButton
@onready var upgrade_a_desc: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/UpgradeAPanel/HBoxContainer/UpgradeADesc

# Upgrade path B
@onready var upgrade_b_panel: PanelContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/UpgradeBPanel
@onready var upgrade_b_name: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/UpgradeBPanel/HBoxContainer/VBoxContainer/UpgradeBName
@onready var upgrade_b_buy_button: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/UpgradeBPanel/HBoxContainer/VBoxContainer/UpgradeBBuyButton
@onready var upgrade_b_desc: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/UpgradeBPanel/HBoxContainer/UpgradeBDesc

func show_ui(currenct_tower: BaseTower) -> void:
	tower = currenct_tower
	
	var tower_data: TowerData = tower.tower
	var path_a: Array[UpgradeData] = tower_data.path_a
	var path_b: Array[UpgradeData] = tower_data.path_b
	
	name_label.text = tower_data.display_name
	damage_label.text = "Damage: " + str(tower.damage)
	range_label.text = "Range: " + str(tower.tower_range)
	firerate_label.text = "Fire rate" + str(tower.fire_rate)
	
	_init_path_a(path_a, tower.path_a_tier)
	_init_path_b(path_b, tower.path_b_tier)
	
	visible = true


func hide_ui() -> void:
	visible = false


func _init_path_a(path: Array[UpgradeData], tier: int) -> void:
	var upgrade: UpgradeData = path[tier]
	upgrade_a = upgrade
	
	upgrade_a_name.text = upgrade.upgrade_name
	upgrade_a_desc.text = upgrade.description
	upgrade_a_buy_button.text = str(upgrade.cost)
	upgrade_a_buy_button.icon = upgrade.cost_icon


func _init_path_b(path: Array[UpgradeData], tier: int) -> void:
	var upgrade: UpgradeData = path[tier]
	upgrade_b = upgrade
	
	upgrade_b_name.text = upgrade.upgrade_name
	upgrade_b_desc.text = upgrade.description
	upgrade_b_buy_button.text = str(upgrade.cost)
	upgrade_b_buy_button.icon = upgrade.cost_icon

func _calculate_diffrences(upgrade: UpgradeData) -> Array[int]:
	var damage_difference = int(tower.damage * upgrade.damage_multi + upgrade.damage_add)
	var range_difference = int(tower.tower_range * upgrade.range_multi + upgrade.damage_add)
	var fire_rate_difference = int(tower.fire_rate * upgrade.fire_rate_multi + upgrade.damage_add)
	
	return [damage_difference, range_difference, fire_rate_difference]

func _on_upgrade_a_panel_mouse_entered() -> void:
	pass # Replace with function body.


func _on_upgrade_a_panel_mouse_exited() -> void:
	pass # Replace with function body.


func _on_upgrade_b_panel_mouse_entered() -> void:
	pass # Replace with function body.


func _on_upgrade_b_panel_mouse_exited() -> void:
	pass # Replace with function body.


func _on_upgrade_a_buy_button_pressed() -> void:
	pass # Replace with function body.


func _on_upgrade_b_buy_button_pressed() -> void:
	pass # Replace with function body.
