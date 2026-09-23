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
@onready var lock_texture_a: TextureRect = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer/LockTextureA

# Upgrade path B
@onready var upgrade_b_panel: PanelContainer = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/UpgradeBPanel
@onready var upgrade_b_name: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/UpgradeBPanel/HBoxContainer/VBoxContainer/UpgradeBName
@onready var upgrade_b_buy_button: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/UpgradeBPanel/HBoxContainer/VBoxContainer/UpgradeBBuyButton
@onready var upgrade_b_desc: Label = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/UpgradeBPanel/HBoxContainer/UpgradeBDesc
@onready var lock_texture_b: TextureRect = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MarginContainer2/LockTextureB

func show_ui(currenct_tower: BaseTower) -> void:
	tower = currenct_tower
	
	var tower_data: TowerData = tower.tower
	var path_a: Array[UpgradeData] = tower_data.path_a
	var path_b: Array[UpgradeData] = tower_data.path_b
	
	_show_info()
	
	_init_path_a(path_a, tower.path_a_tier)
	_init_path_b(path_b, tower.path_b_tier)
	
	visible = true


func hide_ui() -> void:
	visible = false


func _show_info() -> void:
	var tower_data: TowerData = tower.tower
	name_label.text = tower_data.display_name
	damage_label.text = "Damage: " + str(tower.damage)
	range_label.text = "Range: " + str(tower.tower_range)
	firerate_label.text = "Fire rate" + str(tower.fire_rate)


func _init_path_a(path: Array[UpgradeData], tier: int) -> void:
	var upgrade: UpgradeData = path[tier]
	upgrade_a = upgrade
	
	upgrade_a_name.text = upgrade.upgrade_name
	upgrade_a_desc.text = upgrade.description
	upgrade_a_buy_button.text = str(upgrade.cost)
	upgrade_a_buy_button.icon = upgrade.cost_icon
	
	if not tower.can_upgrade_path("a"):
		upgrade_a_panel.modulate = Color(0.5, 0.5, 0.5, 1.0)
		upgrade_a_buy_button.disabled = true
		upgrade_a_buy_button.text = "Locked"
		lock_texture_a.visible = true


func _init_path_b(path: Array[UpgradeData], tier: int) -> void:
	var upgrade: UpgradeData = path[tier]
	upgrade_b = upgrade
	
	upgrade_b_name.text = upgrade.upgrade_name
	upgrade_b_desc.text = upgrade.description
	upgrade_b_buy_button.text = str(upgrade.cost)
	upgrade_b_buy_button.icon = upgrade.cost_icon
	
	if not tower.can_upgrade_path("b"):
		upgrade_b_panel.modulate = Color(0.5, 0.5, 0.5, 1.0)
		upgrade_b_buy_button.disabled = true
		upgrade_b_buy_button.text = "Locked"
		lock_texture_b.visible = true


func _show_differnces(path: String, tier: int) -> void:
	var path_array: Array[UpgradeData]
	if path == "a":
		path_array = tower.tower.path_a
	elif path == "b":
		path_array = tower.tower.path_b
	else:
		return
	
	var upgrade: UpgradeData = path_array[tier]
	
	if upgrade.damage_add > 0 or upgrade.damage_multi != 1.0:
		damage_label.text = damage_label.text + " -> %s" % [tower.damage * upgrade.damage_multi + upgrade.damage_add]
	if upgrade.range_add > 0 or upgrade.range_multi != 1.0:
		range_label.text = range_label.text + " -> %s" % [tower.tower_range * upgrade.range_multi + upgrade.range_add]
	if upgrade.fire_rate_add > 0 or upgrade.fire_rate_multi != 1.0:
		firerate_label.text = firerate_label.text + " -> %s" % [tower.fire_rate * upgrade.fire_rate_multi + upgrade.fire_rate_add]


func _on_upgrade_a_panel_mouse_entered() -> void:
	_show_differnces("a", tower.path_a_tier)


func _on_upgrade_a_panel_mouse_exited() -> void:
	_show_info()


func _on_upgrade_b_panel_mouse_entered() -> void:
	_show_differnces("b", tower.path_b_tier)


func _on_upgrade_b_panel_mouse_exited() -> void:
	_show_info()


func _on_upgrade_a_buy_button_pressed() -> void:
	if tower.purchase_upgrade("a"):
		show_ui(tower)
	else:
		upgrade_a_buy_button.disabled = true
		await get_tree().create_timer(0.5).timeout
		upgrade_a_buy_button.disabled = false


func _on_upgrade_b_buy_button_pressed() -> void:
	if tower.purchase_upgrade("b"):
		show_ui(tower)
	else:
		upgrade_b_buy_button.disabled = true
		await get_tree().create_timer(0.5).timeout
		upgrade_b_buy_button.disabled = false
