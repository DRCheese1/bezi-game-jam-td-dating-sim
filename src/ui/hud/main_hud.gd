extends Control

const TOWER_INFO_CONTAINER = preload("uid://cp63vx5isj5fb")

var building_system: System
var relationship_system: System

@onready var tower_container: VBoxContainer = $HBoxContainer/TowerContainer
@onready var charm_amount: Label = $HBoxContainer/VBoxContainer/CurrenciesContainer/CharmContainer/CharmAmount
@onready var trust_amount: Label = $HBoxContainer/VBoxContainer/CurrenciesContainer/TrustContainer/TrustAmount
@onready var wit_amount: Label = $HBoxContainer/VBoxContainer/CurrenciesContainer/WitContainer/WitAmount
@onready var vuln_amount: Label = $HBoxContainer/VBoxContainer/CurrenciesContainer/VulnContainer/VulnAmount

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	building_system = GameManager.access_system("Building")
	relationship_system = GameManager.access_system("Relationship")
	
	if not building_system:
		for i in range(3):
			push_warning("No building system found, attempt: ", str(i+1))
			building_system = GameManager.access_system("building")
			
			if not building_system:
				await get_tree().create_timer(0.5).timeout
		
		if not building_system:
			GameManager.fatal_error("Building system not found.")
	
	relationship_system.currency_changed.connect(update_currency)
	
	_init_tower_container()

func update_currency(type: String, amount: int):
	print("Currency updating")
	match type:
		"charm":
			charm_amount.text = "Charm: " + str(amount)
		"trust":
			trust_amount.text = "Trust: " + str(amount)
		"wit":
			wit_amount.text = "Wit: " + str(amount)
		"vulnerability":
			vuln_amount.text = "Vulnerability: " + str(amount)

func _init_tower_container():
	for tower: TowerData in building_system.towers:
		var tower_build_container = TOWER_INFO_CONTAINER.instantiate()
		tower_build_container.tower = tower
		tower_build_container.tower_selected.connect(building_system.tower_selected)
		tower_container.add_child(tower_build_container)
