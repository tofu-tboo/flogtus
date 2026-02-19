extends Node

func _ready() -> void:
	init(0)

func init(wait: float) -> void:
	await get_tree().create_timer(wait).timeout
	$UI._initialize()
