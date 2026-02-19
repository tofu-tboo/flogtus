class_name GameSetManager extends Node2D

signal game_inited()
signal game_started()

var main_floating: Floating

func game_start() -> void:
	#Floating.freeze()
	
	# first floating
	main_floating = await %FloatingGenerator.generate_one_with_frog_centered(Floating.LOTUS_LEAF, LotusLeaf.SIZE.LARGE, Utility.world_center + Utility.world_y * Vector2.UP * 0.64)
	
	#game_inited.emit()
	# other floatings
	var restrain: Array[Dock] = [Dock.make_from(main_floating)]
	%FloatingGenerator.generate([] as Array[Dock], restrain, false, Rect2(0, -%FloatingGenerator.default_region_y, Utility.world_x, Utility.world_y + %FloatingGenerator.default_region_y + 10))
	%FloatingGenerator.start_generation()
