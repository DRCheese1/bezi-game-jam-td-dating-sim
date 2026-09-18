extends System

@export var towers: Array[TowerData] = []
@export var tower_root: Node2D

var selected_tower: TowerData
var placing: bool = false
var relationship_system: System

@onready var sprite_2d: Sprite2D = $Sprite2D

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
		placing = false
	else:
		selected_tower = tower
		placing = true

func _process(delta: float) -> void:
	if placing == false:
		sprite_2d.visible = false
	elif placing == true:
		sprite_2d.visible = true
		sprite_2d.texture = selected_tower.icon
		
		sprite_2d.position = get_viewport().get_mouse_position()-get_viewport().get_visible_rect().size/2

func _unhandled_input(event: InputEvent) -> void:
	if placing == false:
		return
	
	if event.is_action_pressed("place"):
		if not relationship_system.spend_currency(selected_tower.currency_type, selected_tower.cost):
			placing = false
			selected_tower = null
			return
		
		var tower_scene: Area2D = selected_tower.scene.instantiate()
		tower_scene.tower = selected_tower
		tower_root.add_child(tower_scene)
		tower_scene.position = get_viewport().get_mouse_position()-get_viewport().get_visible_rect().size/2
		
		if not Input.is_action_pressed("continue_place"):
			placing = false
			selected_tower = null


func _placement_allowed(target_position: Vector2) -> bool:
	var space_state = get_viewport().find_world_2d().direct_space_state
	
	var query = PhysicsPointQueryParameters2D.new()
	query.position = target_position
	query.collide_with_areas = true
	query.collide_with_bodies = false
	
	query.collision_mask = 2
	
	var results = space_state.intersect_point(query)
	
	return results.size() > 0
	
	return true
