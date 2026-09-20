extends Area2D
class_name BaseEnemy

@export var distance: float = 0
@export var enemy_data: EnemyData
@export var path_2d: Path2D

var path_length: float = 0.0
var flash_tween: Tween
var relationship_system: System
var health: int

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	visible = false
	relationship_system = GameManager.access_system("Relationship")
	
	progress_bar.max_value = enemy_data.health
	progress_bar.value = enemy_data.health
	health = enemy_data.health
	
	if path_2d:
		path_length = path_2d.curve.get_baked_length()
	
	await get_tree().process_frame
	
	visible = true


func _process(delta: float) -> void:
	distance += enemy_data.speed * delta
	
	if distance >= path_length:
		_reached_end()
		return
	
	# Calculating position based on distance travelled
	var local_point: Vector2 = path_2d.curve.sample_baked(distance)
	global_position = path_2d.to_global(local_point)


func take_damage(amount: int):
	health -= amount
	progress_bar.value = health
	_flash_hit()
	
	if health <= 0:
		_die()

func _flash_hit() -> void:
	if flash_tween:
		flash_tween.kill()  # stop any in-progress flash so hits don't stack weirdly

	sprite_2d.modulate = Color(2, 2, 2)  # overshoot brighter than white for a punchier flash

	flash_tween = create_tween()
	flash_tween.tween_property(sprite_2d, "modulate", Color(1, 1, 1), 0.15)

func _die():
	var wave_system = GameManager.access_system("WaveSpawner")
	_add_currency()
	wave_system.enemy_count -= 1
	queue_free()

func _add_currency():
	var total_weight := 0.0
	for weight in enemy_data.currency_weights:
		total_weight += weight
	
	for i in range(enemy_data.currency_amount):
		relationship_system.add_currency(_weighted_pick_from_arrays(enemy_data.currency_type, enemy_data.currency_weights, total_weight), 1)

func _weighted_pick_from_arrays(items: Array[String], weights: Array[float], total_weight: float) -> String:
	var roll := randf() * total_weight
	var cumulative := 0.0
	
	for i in items.size():
		cumulative += weights[i]
		if roll <= cumulative:
			return items[i]
	
	return items[-1]

func _reached_end() -> void:
	print("Reached end")
	relationship_system.modify_relationship(-enemy_data.damage)
	queue_free()
