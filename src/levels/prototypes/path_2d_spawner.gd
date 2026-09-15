extends Path2D

const DOUBT_ENEMY = preload("uid://cjc4qsiu5lnpy")

var entity_root: Node2D

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("testspawn"):
		if entity_root == null:
			entity_root = GameManager.entity_root
		
		var enemy = DOUBT_ENEMY.instantiate()
		enemy.path_2d = self
		entity_root.add_child(enemy)
