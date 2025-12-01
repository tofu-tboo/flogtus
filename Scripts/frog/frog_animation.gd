extends AnimatedSprite2D

var walk_frame: int = 0

func _ready() -> void:
	OrderingHook.assign_order($zzz as Node2D, OrderingHook.FROG_PARTICLE)

func _on_frame_changed() -> void:
	if self.animation == &"idle" and self.frame == 4:
		%CroakSound.play()

func _on_animation_finished() -> void:
	match self.animation:
		&"drown":
			Frog.instance.queue_free()
		&"land":
			if self.animation == &"land":
				self.play(&"idle")
		&"walk":
			self.scale.x = 1
			self.play(&"idle")

func animate(type: String, speed: float = 1.0) -> void:
	var do_animate: bool = false
	
	self.speed_scale = speed
	match type:
		"jump":
			if %LandPoint.is_real_jump:
				%JumpSound.play()
				do_animate = true
		"drown":
			get_parent().rotation = 0
			get_parent().z_index = -1
			do_animate = true
		"ready":
			if self.animation == &"idle" or self.animation == &"land":
				do_animate = true
				walk_frame = 0
		
		"walk":
			self.scale.x = 1 if walk_frame % 2 == 0 else -1
			walk_frame += 1
			do_animate = true
		"land":
			do_animate = true
		"sleep":
			do_animate = true
			$zzz.play()
		"wake_up":
			do_animate = true
			$zzz.stop()
	if do_animate:
		self.play(StringName(type))
