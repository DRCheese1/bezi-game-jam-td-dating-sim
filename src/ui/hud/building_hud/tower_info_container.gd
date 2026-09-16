extends MarginContainer

signal tower_selected(selected_tower: TowerData)

@export var tower: TowerData

@onready var tower_icon: TextureRect = $PanelContainer/VBoxContainer/PanelContainer/TowerIcon
@onready var cost_label: Label = $PanelContainer/VBoxContainer/CostLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tower_icon.texture = tower.icon
	cost_label.text = str(tower.cost)
	

func _on_select_button_pressed() -> void:
	tower_selected.emit(tower)
