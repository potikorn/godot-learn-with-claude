extends Camera2D

# ความแรงและระยะเวลาของการสั่น
@export var shake_strength: float = 2.0
@export var shake_duration: float = 0.2

var shake_timer: float = 0.0
var rng = RandomNumberGenerator.new()

func _physics_process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		# สุ่มตำแหน่ง offset ทุก frame ทำให้ดูสั่น
		offset = Vector2(
			rng.randf_range(-shake_strength, shake_strength),
			rng.randf_range(-shake_strength, shake_strength)
		)
	else:
		# หยุดสั่น reset offset กลับศูนย์
		offset = Vector2.ZERO
		
func shake() -> void:
	shake_timer = shake_duration 
		
