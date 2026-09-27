extends Node
class_name Utilities


static func quit_game(from_node: Node) -> void:
	from_node.get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	from_node.get_tree().quit()
