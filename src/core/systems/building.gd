extends System

@export var towers: Array[TowerData] = []
@export var tower_root: Node2D

var selected_tower: TowerData
var placing: bool = false
var relationship_system: System
var can_build: bool = true
var in_area: Array[Area2D] = []

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var building_area: Area2D = $Sprite2D/BuildingArea
@onready var collision_shape_2d: CollisionShape2D = $Sprite2D/BuildingArea/CollisionShape2D

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
		building_area.position = selected_tower.building_area_offset
		collision_shape_2d.shape.radius = selected_tower.tower_build_area

func _process(delta: float) -> void:
	if placing == false:
		sprite_2d.visible = false
	elif placing == true:
		if in_area.size() == 0:
			can_build = true
		else:
			can_build = false
		
		if can_build:
			sprite_2d.modulate = Color(0.0, 1.0, 0.0, 0.686)
		else:
			sprite_2d.modulate = Color(1.0, 0.0, 0.0, 0.686)
		
		sprite_2d.visible = true
		sprite_2d.texture = selected_tower.icon
		
		sprite_2d.position = get_viewport().get_mouse_position()-get_viewport().get_visible_rect().size/2 + Vector2(0, -8)

func _unhandled_input(event: InputEvent) -> void:
	if placing == false:
		return
	
	if event.is_action_pressed("place"):
		if not relationship_system.spend_currency(selected_tower.currency_type, selected_tower.cost):
			placing = false
			selected_tower = null
			return
		
		if not can_build:
			return
		
		var tower_scene: Area2D = selected_tower.scene.instantiate()
		tower_scene.tower = selected_tower
		tower_root.add_child(tower_scene)
		tower_scene.position = get_viewport().get_mouse_position()-get_viewport().get_visible_rect().size/2 + Vector2(0, -8)
		
		if not Input.is_action_pressed("continue_place"):
			placing = false
			selected_tower = null


func _on_building_area_area_entered(area: Area2D) -> void:
	in_area.append(area)


func _on_building_area_area_exited(area: Area2D) -> void:
	in_area.erase(area)
