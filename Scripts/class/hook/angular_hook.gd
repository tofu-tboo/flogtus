class_name AngularHook extends Object

const avel_default: float = 1.5
static var avel: float = avel_default

static func update_avel(value: float) -> void:
	avel = value # 다음 소환되는 물체부터 적용

static func assign_avel(target: RigidBody2D) -> void:
	if randi() & 2:
		target.angular_velocity = avel
	else:
		target.angular_velocity = -avel

static func initialize() -> void:
	avel = avel_default
