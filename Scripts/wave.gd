extends Node2D

@onready var sprite_radius: float = $Sprite.texture.get_size().x / 2
@onready var mat: ShaderMaterial = $Sprite.material
const wave_speed: float = 50.0
static var screen_diag: float = sqrt(Utility.world_x ** 2 + Utility.world_y ** 2)

var win_size: Vector2i
var r_px: float = 0.0

func _ready() -> void:
	set_process(false)
	self.hide()
	mat.set_shader_parameter(&"outer_r_px", 0.0)
	
	OrderingHook.assign_order(self, OrderingHook.WAVE)

func _process(delta: float) -> void:
	r_px += delta * wave_speed
	
	if r_px - 20.0 > screen_diag: # padding = 20
		queue_free()
	
	mat.set_shader_parameter(&"outer_r_px", r_px * win_size.x / Utility.world_x)

func _draw() -> void:
	set_process(true)

func splash() -> void:
	reparent(get_tree().current_scene)
	self.show()
	$SplashSound.play()
	
	win_size = DisplayServer.window_get_size()
	mat.set_shader_parameter(&"center_px", self.global_position / (Utility.world_size as Vector2) * (win_size as Vector2))
