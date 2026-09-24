extends UpgradeEffect
class_name MultishotEffect

func apply(tower: BaseTower) -> void:
	tower.multishot += 1
