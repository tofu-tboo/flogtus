class_name Platform extends RigidBody2D

enum { FLOATING }

signal state_changed() # frog to land
signal collapse() # frog to drown

var has_state: bool = true
var can_collapse: bool = true

func get_space_radius() -> float:
	return 0.0

func landed(_frog: Frog) -> void:
	pass

func takeoff(_frog: Frog) -> void:
	pass

func _enter_tree() -> void:
	OrderingHook.assign_order(self, OrderingHook.PLATFORM)

func assign_size(_size: float) -> void:
	pass
