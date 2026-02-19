extends Marker2D

const jump_thres: float = 15.0
const init_scale: float = 0.6

var is_real_jump: bool = false

func _ready() -> void:
	var tracker_scene: Tracker = load("res://objects/tracker.tscn").instantiate()
	tracker_scene.assign_target(self, 2.0)
	
	self.scale = Vector2.ONE * init_scale
	self.hide()
	
	OrderingHook.assign_order($Sprite as Sprite2D, OrderingHook.LAND_POINT)
	OrderingHook.assign_order($Trajectory as Sprite2D, OrderingHook.LAND_POINT_TRAJ)

func _process(_delta: float) -> void:
	var charged: float = Frog.charge_full - %ChargeTimer.time_left
	var ratio: float = charged / Frog.charge_full
	var target_pos: Vector2 = Vector2.UP * Frog.max_dist * ratio
	var dest: float = target_pos.length()
	
	if not is_real_jump and dest >= jump_thres:
		is_real_jump = true
	self.position = target_pos
	self.scale = Vector2.ONE * ((1.0 - init_scale) * ratio + init_scale)
	
	$Trajectory.region_rect.size.y = dest * 0.92
	
	if is_real_jump and self.visible:
		pass

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			set_process(true)
			is_real_jump = false
		else:
			set_process(false)
			set_deferred(&"position", Vector2.ZERO)
