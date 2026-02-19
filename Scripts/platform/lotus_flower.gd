class_name LotusFlower extends Lotus

const size: int = 15

var unbloom_y: float

func _ready() -> void:
	super()
	assert($Shape.shape is CircleShape2D)

	$Sprite.frame = 0

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	var half_screen: float = Utility.world_y / 2
	unbloom_y = half_screen + half_screen / 2 * randf()
	$Timer.start()

func _on_timer_timeout() -> void:
	if self.position.y > unbloom_y:
		$Sprite.play(&"default")
		$Timer.stop()

func _on_sprite_frame_changed() -> void:
	assert($Shape.shape is CircleShape2D)
	
	if $Sprite.animation == &"default":
		var frame: int = $Sprite.frame
		match frame:
			1:
				$Shape.shape.radius = 12
			2:
				$Shape.shape.radius = 8
			3:
				collapse.emit()
		state_changed.emit()

func get_space_radius() -> float:
	return $Shape.shape.radius
