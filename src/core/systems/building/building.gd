extends System

@export var towers: Array[TowerData] = []
@export var tower_root: Node2D

var selected_tower: TowerData
var relationship_system: System

@onready var tower_preview: Node2D = $TowerPreview

func _ready() -> void:
	GameManager.register_system(system_name, self)
	
	relationship_system = GameManager.access_system("Relationship")
	if not relationship_system:
		for i in range(3):
			push_warning("No relationship system found, attempt: ", str(i+1))
			relationship_system = GameManager.access_system("relationship")
			
			if not relationship_system:
				await get_tree().create_timer(0.5).timeout
		
		if not relationship_system:
			GameManager.fatal_error("Relationship system not found.")

func tower_selected(tower):
	if selected_tower == tower:
		selected_tower = null
		tower_preview.stop_building()
	else:
		print("selecting tower")
		selected_tower = tower
		print("Selected: ", selected_tower)
		tower_preview.set_tower_data(selected_tower)

func _unhandled_input(event: InputEvent) -> void:
	if selected_tower == null:
		return
	
	if event.is_action_pressed("place"):
		if not tower_preview.can_build:
			return
		
		if not relationship_system.spend_currency(selected_tower.currency_type, selected_tower.cost):
			tower_preview.stop_building()
			selected_tower = null
			return
		
		print("Shits placing")
		var tower_scene: Area2D = selected_tower.scene.instantiate()
		tower_scene.tower = selected_tower
		tower_root.add_child(tower_scene)
		tower_scene.position = get_viewport().get_mouse_position()-get_viewport().get_visible_rect().size/2 + Vector2(0, -8)
		
		if not Input.is_action_pressed("continue_place"):
			tower_preview.stop_building()
			selected_tower = null
