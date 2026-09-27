extends BaseTower

var multishot: int = 1

func _choose_targets() -> Array[BaseEnemy]:
	var sorted_targets: Array[BaseEnemy] = targets.duplicate()
	sorted_targets.sort_custom(func(a, b): return a.distance > b.distance)
	
	var chosen: Array[BaseEnemy] = []
	var count: int = min(multishot, sorted_targets.size())
	
	for i in range(count):
		chosen.append(sorted_targets[i])
	
	return chosen
