extends System

signal next_wave()

@export var entity_root: Node2D
@export var enemy_pool: Array[EnemyData] = []
@export var base_budget: int = 20
@export var wave_growth_rate: float = 1.25  # tune this - 25% harder each day, compounding	

var path_2d: Path2D
var weight_modifiers: Dictionary = {}
var wave_count: int = 0
var day_count: int = 1
var enemy_count: int = 0:
	set(value):
		enemy_count = value
		print("Enemies: ", value)
		
		if enemy_count == 0:
			next_wave.emit()

func test_wave():
	wave_count += 1
	
	_spawn_wave(wave_count)

func next_wave_sequence():
	await get_tree().create_timer(5.0).timeout
	
	for i in range(3):
		wave_count += 1
		_spawn_wave(wave_count)
		await next_wave
	
	day_count += 1
	GameManager.start_dialauge("day%s-timeline" % day_count)

func _spawn_wave(current_wave: int):
	if path_2d == null:
		push_error("Path_2d is null")
		return
	
	var budget = base_budget * pow(wave_growth_rate, wave_count)
	print("Budget: ", budget)
	
	var wave: Array[Array] = _generate_wave(budget, current_wave)
	
	for group in wave:
		for enemy_data in group:
			var enemy = enemy_data.scene.instantiate()
			enemy.enemy_data = enemy_data
			enemy.path_2d = path_2d
			entity_root.add_child.call_deferred(enemy)
			enemy_count += 1
			await get_tree().create_timer(0.4).timeout
		
		await get_tree().create_timer(1).timeout

func _generate_wave(budget: float, current_wave: int) -> Array[Array]:
	var wave: Array[Array]
	var remaining := budget
	var available := _get_available_enemies(current_wave)
	
	while remaining > 0:
		var enemy_type := _weighted_pick(available)
		var max_affordable := int(clamp(enemy_type.cost * enemy_type.max_group_size, 0, remaining) / enemy_type.cost)
		
		if max_affordable < enemy_type.min_group_size:
			break  # can't afford even the minimum group of this type
		
		var group_size := randi_range(enemy_type.min_group_size, max_affordable)
		var group_cost := enemy_type.cost * group_size
		
		if group_cost > remaining:
			continue
		
		var group: Array[EnemyData] = []
		for i in group_size:
			group.append(enemy_type)
		
		wave.append(group)
		
		remaining -= group_cost
	
	return _sort_groups_by_difficulty(wave)

func _get_available_enemies(current_wave: int) -> Array[EnemyData]:
	return enemy_pool.filter(func(e): return e.min_wave <= current_wave)

func _weighted_pick(enemies: Array[EnemyData]) -> EnemyData:
	var total_weight := 0.0
	for enemy in enemies:
		total_weight += _get_effective_weight(enemy)
	
	var roll = randf() * total_weight
	var cumulative := 0.0
	for enemy in enemies:
		cumulative += _get_effective_weight(enemy)
		if roll <= cumulative:
			return enemy
	return enemies[-1]

func _get_effective_weight(enemy: EnemyData) -> float:
	var modifier: float = weight_modifiers.get(enemy.resource_path, 1.0)
	return enemy.base_weight * modifier

func _sort_groups_by_difficulty(wave: Array[Array]) -> Array[Array]:
	wave.sort_custom(func(a, b):
		var a_cost := 0.0
		var b_cost := 0.0
		 
		for enemy in a:
			a_cost += enemy.cost
		for enemy in b:
			b_cost += enemy.cost
		
		return a_cost < b_cost)
	return wave
