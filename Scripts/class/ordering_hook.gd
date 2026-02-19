class_name OrderingHook extends Object

enum { NONE, WAVE, WATER_FALL, PLATFORM, LAND_POINT_TRAJ, LAND_POINT, FROG, FROG_PARTICLE, TRACKER, CNT } # ordering

static func assign_order(target: Node2D, type: int) -> void:
	target.z_index = type
