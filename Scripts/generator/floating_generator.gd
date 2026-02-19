class_name FloatingGenerator extends Generator

var min_gap: float = 20.0:
	set(v):
		min_gap = v
		max_gap = Frog.max_dist - v * 2
		max_cnt = floor(0.91 * Utility.world_area / (PI * ((10 + 0.5 * min_gap) ** 2))) + 1
var max_gap: float = Frog.max_dist - min_gap * 2:
	set(v):
		if v < min_gap:
			return
		max_gap = v
		default_region_y = 2 * max_cnt * (10 + 0.5 * v)

@export var max_cnt: int = floor(0.91 * Utility.world_area / (PI * ((10 + 0.5 * min_gap) ** 2))) + 1: # 지속적인 소환으로 느껴질 수 있는 개수여야 함.
	set(v):
		if v <= 0:
			return
		max_cnt = v
		default_region_y = 2 * v * (10 + 0.5 * max_gap)
@export var _cnt_per_tick: int = 4 # 이번 틱의 앵커가 두 틱 전의 앵커와 충돌하지 않을 정도의 개수를 소환해야 함. 단, 적절히 restrait 되는 개수로 설정해야 함.
@export var _ratio: Array[float] = [0.95, 0.05]

const _30_deg: float = PI / 6
const _floating_scenes: Array[PackedScene] = [
	preload("res://objects/lotus_leaf.tscn"),
	preload("res://objects/lotus_flower.tscn")
]
var _lowest_dock: Dock = Dock.new(Vector2.DOWN * Utility.world_y, 0.0, null)

var default_region_y: float = 2 * max_cnt * (10 + 0.5 * max_gap)

var mutant_rate: float = 0.1 # 난이도 param

var _gen_prob: Array[float] = []
var _seeds: Array[Dock] = []

func _ready() -> void:
	SingletonHook.sure_only_one_load(self)

	for i in _ratio.size(): # 누적 확률
		_gen_prob.append(_ratio[i] + (_gen_prob[i - 1] if i > 0 else 0.0))
	
	Data.add_listener(&"init", _initialize)
	_initialize() # 보류

func _initialize() -> void:
	_lowest_dock = Dock.new(Vector2.DOWN * Utility.world_y, 0.0, null)
	_seeds.clear()
	$Tick.stop()
	
func start_generation() -> void:
	$Tick.start()
func stop_generation() -> void:
	$Tick.stop()

func generate(hard_seeds: Array[Dock] = [], restrains: Array[Dock] = [], explode: bool = false, constraint: Rect2 = Rect2(0, -default_region_y, Utility.world_x, default_region_y)) -> void:
	#var test_msec = Time.get_ticks_msec()
	if Counter.how_many(&"Floating") >= max_cnt:
		return
		
	if len(hard_seeds) > 0:
		_seeds = hard_seeds
	
	if _seeds.is_empty():
		_seeds.append(Dock.new(Vector2(randf() * Utility.world_x, -screen_padding), 0, null))
	else:
		_update_seeds()
	var active_list: Array[Dock] = [_seeds[0]] # 생성 기준점이 될 수 있는 앵커 집합, 처음에는 가장 상위의 앵커만
	var restrain_list: Array[Dock] = _seeds.duplicate() # 거리 조건 검사를 위한 앵커 집합
	var highest_dock: Dock = _lowest_dock
	
	restrain_list.append_array(restrains)
	active_list.append_array(restrains)

	_seeds.clear()
	for _i in _cnt_per_tick if not explode else max_cnt: # 한 틱에 생성 개수 고정
		var new_floating: Floating = _gen_floating()
		var new_size: float = new_floating.get_space_radius()
		if new_floating == null:
			continue
		
		while true: # 위치 탐색
			var norm: Dock = active_list.pick_random()
			var dir: Vector2 = _get_dir()
			var candidate_pos: Vector2 = norm.disk.pos + dir * (norm.disk.radius + new_size + randf_range(min_gap, max_gap))
			var is_valid: bool = true
			var candidate_disk: Disk = Disk.new(candidate_pos, new_size) # 거리 비교 위한 디스크 생성
			
			if _constraint_test(candidate_disk, constraint):
				continue # 화면 안쪽 또는 화면 가로 밖이면 다시 시도

			for dock: Dock in restrain_list:
				if Disk.gap(candidate_disk, dock.disk) < min_gap:
					is_valid = false
					continue
			
			if is_valid:
				var new_dock: Dock = Dock.new(candidate_pos, new_size, new_floating)
				active_list.append(new_dock)
				restrain_list.append(new_dock)
				
				if highest_dock.disk.pos.y - highest_dock.disk.radius > new_dock.disk.pos.y - new_dock.disk.radius:
					highest_dock = new_dock
					_seeds.push_front(new_dock) # 결국 가장 위에 있는 앵커가 0 index임.
				else:
					_seeds.push_back(new_dock)

				# floating 활성화
				new_floating.position = candidate_pos
				new_floating.show()
				
				break
	
	if _seeds.size() > _cnt_per_tick:
		_seeds.slice(0, _cnt_per_tick)
	#prints("msec", Time.get_ticks_msec() - test_msec)

func generate_one_with_frog_centered(type: int = -1, size: float = -1.0, pre_pos: Vector2 = Vector2.ONE * INF, pre_rot: float = INF) -> Floating:
	var floating: Floating = _floating_scenes[type if type >= 0 else _rand_type()].instantiate()
	var frog: Frog = Frog.instance
	if frog == null:
		frog = preload("res://objects/frog.tscn").instantiate()
	
	floating.no_slosh = true
	
	await get_tree().process_frame
	
	# tree
	get_tree().current_scene.add_child(floating)
	floating.add_child(frog) # 임시
	
	# transform
	frog.position = Vector2.ZERO
	floating.rotation = pre_rot if pre_rot != INF else randf_range(0, PI * 2)
	floating.global_position = pre_pos if pre_pos != Vector2.ONE * INF else Vector2.ZERO
	
	# physics
	if size > 0.0:
		floating.assign_size(size)
	
	return floating

func _rand_type() -> int:
	var r: float = randf()
	for i in _gen_prob.size():
		if r < _gen_prob[i]:
			return i
	return _gen_prob.size() - 1

func _gen_floating() -> Floating:
	var type: int = _rand_type()
	var floating: Floating = _floating_scenes[type].instantiate() as Floating

	floating.hide()
	get_tree().current_scene.add_child(floating)

	# 씬에 추가만 한 뒤 반환, 위치 확정 이후 활성화
	return floating

func _update_seeds() -> void:
	for dock in _seeds:
		dock.update()

func _get_dir() -> Vector2:
	if randf() < mutant_rate:
		return Vector2.RIGHT.rotated(randf_range(PI, PI * 2))
	return Vector2.RIGHT.rotated(randf_range(-_30_deg, 0) + (_30_deg + PI) * (randi() % 2))

func _constraint_test(disk: Disk, constraint: Rect2) -> bool:
	if constraint.grow(-disk.radius).has_point(disk.pos):
		return false
	return true
