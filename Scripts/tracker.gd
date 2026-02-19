class_name Tracker extends Sprite2D

var target: Node2D
var padding: float = 0.0

func _init() -> void:
	set_process(false)

func assign_target(parent: Node2D, new_padding: float = 0.0, texture_source: String = "") -> void:
	if texture_source != "":
		self.texture = load(texture_source)
	
	parent.visibility_changed.connect(_track)
	parent.add_child(self)

	target = parent
	padding = new_padding

	set_process(true)

func _track() -> void:
	if target.visible:
		set_process(true)
	else:
		set_process(false)

func _process(_delta: float) -> void:
	if not Utility.world_rect.intersects(Rect2(target.global_position - Vector2.ONE * padding / 2, Vector2.ONE * padding)):
		self.position = target.global_position.clamp(Utility.world_rect.position, Utility.world_rect.size)
		if self.global_position.x <= 0:
			self.rotation = 0
		elif target.global_position.x >= Utility.world_x:
			self.rotation = PI
		
		if target.global_position.y <= 0:
			self.rotation = PI / 2
		elif target.global_position.y >= Utility.world_y:
			self.rotation = -PI / 2
		
		self.show()
	else:
		self.hide()
