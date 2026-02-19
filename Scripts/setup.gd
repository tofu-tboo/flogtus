extends Node

func _ready() -> void:
	Data.add_listener(&"score_changed", 
		func(val: int) -> void:
			$UI/Score.text = "{0}".format([val])
	)
	
	Data.add_listener(&"init", _clean_platforms)
	
	Data.init.emit()
	Data.game_set.emit()

func _clean_platforms() -> void:
	var border: Rect2 = Rect2(-Generator.screen_padding, -Generator.screen_padding, Utility.world_x + 2 * Generator.screen_padding, Utility.world_y + 2 * Generator.screen_padding)
	for child: Node in get_tree().current_scene.get_children():
		if child is Platform and not border.has_point(child.position):
			child.queue_free()
	
	%FloatingGenerator.stop_generation()
