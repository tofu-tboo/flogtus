class_name River extends Node

const min_flow_speed: float = 12.0
const max_flow_speed: float = 20.0

static var flow_speed: float = min_flow_speed

static func init_game() -> void:
	flow_speed = min_flow_speed

static func speed_up(value: float = 0.1) -> void:
	flow_speed = clampf(flow_speed + value, min_flow_speed, max_flow_speed)
