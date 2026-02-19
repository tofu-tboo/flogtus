class_name LotusLeaf extends Lotus
	
enum SIZE { TINI = 10, SMALL = 15, MEDIUM = 20, BIG = 25, LARGE = 30 }
@export var auto_sizing: bool = true

func _ready() -> void:
	super()
	
	assert($Shape.shape is CircleShape2D)
	
	has_state = false
	can_collapse = false
	
	if not auto_sizing:
		return
	
	var size: int = _rand_size()
	assign_size(size)

static func _rand_size() -> SIZE:
	var ratio: float = randf()
	
	if ratio > 0.65: # 35%
		return SIZE.LARGE
	elif ratio > 0.35: # 30%
		return SIZE.BIG
	elif ratio > 0.15: # 20%
		return SIZE.MEDIUM
	elif ratio > 0.05: # 10%
		return SIZE.SMALL
	else: # 5%
		return SIZE.TINI
	
func get_space_radius() -> float:
	return $Shape.shape.radius

func assign_size(size: float) -> void:
	$Shape.shape.radius = floor(size)
	
	match int(size):
		SIZE.TINI:
			$Sprite.texture = load("res://textures/platforms/floatings/lotus_leaf_tini.png")
		SIZE.SMALL:
			$Sprite.texture = load("res://textures/platforms/floatings/lotus_leaf_small.png")
		SIZE.MEDIUM:
			$Sprite.texture = load("res://textures/platforms/floatings/lotus_leaf_medium.png")
		SIZE.BIG:
			$Sprite.texture = load("res://textures/platforms/floatings/lotus_leaf_big.png")
		SIZE.LARGE:
			$Sprite.texture = load("res://textures/platforms/floatings/lotus_leaf_large.png")
