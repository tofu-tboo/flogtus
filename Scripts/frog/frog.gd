class_name Frog extends Area2D

enum STATE { NONE = -1, LANDED, WALKED, JUMPED, DROWNED, CNT }
var state: STATE = STATE.NONE

const max_dist: float = 100.0
const charge_full: float = 1.0

const over_air_coef: float = 0.4 # 채공시간 계수

var platform: Platform = null

var is_ready: bool = false

static var instance: Frog = null # singleton

func _state(value: STATE) -> void:
	match value:
		STATE.WALKED:
			if state != STATE.NONE and state != STATE.LANDED and state != STATE.WALKED and state != STATE.JUMPED:
				return
			
			$Sprite.animate("walk")
		STATE.LANDED:
			'''물리 위치 변경'''
			if state != STATE.JUMPED and state != STATE.LANDED and state != STATE.NONE:
				return
			else:
				var local_pos: Vector2 = platform.to_local(self.global_position)
				var glob_rot: float = self.global_rotation
				self.reparent(platform, false)
				self.position = local_pos
				self.global_rotation = glob_rot
				
				$Sprite.animate("land")
				
				self.monitoring = true
		STATE.JUMPED:
			'''점프 애니메이션 설정'''
			if state != STATE.LANDED and state != STATE.WALKED and not is_ready:
				return
			var charged: float = charge_full - $ChargeTimer.time_left
			var pos_tween: Tween = create_tween()
			var szup_tween: Tween = create_tween()
			var tween_time: float = charged * over_air_coef
			
			# 이동
			pos_tween.parallel().tween_property(self, ^"global_position", $LandPoint.global_position, tween_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			pos_tween.tween_callback(step)
			#szup_tween.tween_property(self, ^"scale", Vector2.ONE * 2, tween_time / 2).set_trans(Tween.TRANS_CIRC)
			#szup_tween.tween_callback(
				#func():
					#var szdown_tween: Tween = create_tween()
					#szdown_tween.tween_property(self, ^"scale", Vector2.ONE, tween_time / 2)
			#)
			
			$Sprite.animate("jump", 0.6 / tween_time)
			
			
			self.monitoring = false
		STATE.DROWNED:
			if state != STATE.LANDED and state != STATE.WALKED and state != STATE.JUMPED:
				return
			self.reparent(get_tree().current_scene)
			
			$LandPoint.hide()
			$Sprite.animate("drown")
			
			game_over()
		STATE.CNT, STATE.NONE:
			return
	state = value

func _ready() -> void:
	var tracker_scene: Tracker = load("res://objects/tracker.tscn").instantiate()
	tracker_scene.assign_target(self, 6.0, "res://textures/ui/frog_tracker.png")
	
	$ChargeTimer.wait_time = charge_full
	LeapServer.connect_frog(self)
	
	OrderingHook.assign_order(self, OrderingHook.FROG)
	
	if instance != null:
		queue_free()
	else:
		instance = self
	
	await get_tree().physics_frame
	step()
	_state(STATE.LANDED)

func _input(_event: InputEvent) -> void:
	if state != STATE.LANDED and state != STATE.WALKED:
		return
	elif Input.is_action_just_pressed(&"Jump"):
		'''점프 타이머 & 착지 지점 설정'''
		$ChargeTimer.start()
		$LandPoint.show()
		
		is_ready = true
		
		await get_tree().create_timer(0.1).timeout
		if is_ready:
			$Sprite.animate("ready")
	elif Input.is_action_just_released(&"Jump"):
		is_ready = false
		
		$LandPoint.hide()
		
		_state(STATE.JUMPED)
		

func step() -> void: # TODO: 리팩토링
	var pad: Platform = _check_floor()
	if pad == null:
		drown.call_deferred()
		return
	if not %LandPoint.is_real_jump:
		_state(STATE.WALKED)
	else:
		if self.platform != pad:
			self.platform = pad
			Data.earn_score(pad)
		_state(STATE.LANDED)

func drown() -> void:
	_state(STATE.DROWNED)

func wake_up() -> void:
	_state(STATE.LANDED)

func _check_floor() -> Platform: # TODO: 리팩토링
	var dss: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var qp: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	qp.shape = $Shape.shape
	qp.transform = self.global_transform
	qp.collision_mask = self.collision_mask
	var hits: Array[Dictionary] = dss.intersect_shape(qp)
	
	if hits.size() > 0:
		return hits[0].collider
	else:
		return null

func game_over() -> void:
	$Wave.splash()
	#Data.frog_die()

func make_controllable() -> void:
	$CanvasLayer/TouchControl.show()
