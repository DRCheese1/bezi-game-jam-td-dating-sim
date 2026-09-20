extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var building_area: Area2D = $BuildingArea
@onready var collision_shape_2d: CollisionShape2D = $BuildingArea/CollisionShape2D

var tower_range: int
var building_range: float
var can_build: bool
var in_area: Array[Area2D]

func _draw() -> void:
	draw_circle(Vector2.ZERO, tower_range, Color(0.098, 1.0, 0.694, 0.259))
	draw_arc(Vector2.ZERO, tower_range, 0, TAU, 64, Color(0.0, 0.639, 0.627, 0.318), 2.0)

func _process(_delta: float) -> void:
	if visible:
		sprite_2d.material.set_shader_parameter(
			"sprite_tint",
			Color(1.0, 0.0, 0.0, 0.686) if not can_build else Color.WHITE
		)
		
		position = get_viewport().get_mouse_position()-get_viewport().get_visible_rect().size/2 + Vector2(0, -8)

func set_tower_data(tower: TowerData):
	tower_range = tower.tower_range
	building_range = tower.tower_build_area
	
	building_area.position = tower.building_area_offset
	collision_shape_2d.shape.radius = building_range
	sprite_2d.texture = tower.icon
	
	queue_redraw()
	visible = true

func stop_building():
	visible = false

func _on_building_area_area_entered(area: Area2D) -> void:
	in_area.append(area)
	can_build = false

func _on_building_area_area_exited(area: Area2D) -> void:
	in_area.erase(area)
	if in_area.size() == 0:
		can_build = true
