extends VBoxContainer

const TOWER_INFO_CONTAINER = preload("uid://cp63vx5isj5fb")

var building_system: System

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	building_system = GameManager.access_system("Building")
	
	if not building_system:
		for i in range(3):
			push_warning("No building system found, attempt: ", str(i+1))
			building_system = GameManager.access_system("building")
			
			if not building_system:
				await get_tree().create_timer(0.5).timeout
		
		if not building_system:
			GameManager.fatal_error("Building system not found.")
	
	
	for tower: TowerData in building_system.towers:
		var tower_container = TOWER_INFO_CONTAINER.instantiate()
		tower_container.tower = tower
		tower_container.tower_selected.connect(building_system.tower_selected)
		add_child(tower_container)
