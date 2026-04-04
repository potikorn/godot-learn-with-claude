extends Node2D

@onready var label = $Label

# เรียกตอน spawn เพื่อตั้งค่าตัวเลขและเริ่ม animation
func setup(damage: float) -> void:
	label.text = str(int(damage)) # แปลงตัวเลขเป็น string ไม่มีทศนิยม
	_animate()
	
func _animate() -> void:
	# ใช้ Tween - ระบบ animation ด้วยโค้ดของ Godot
	var tween = create_tween()
	
	# ลอยขึ้น 40 pixels ใน 0.5 วินาที
	tween.tween_property(self, "position:y", position.y - 40, 0.5)
	
	# fade out - modulate คือสี RGBA ของ node
	# modulate:a คือ alpha (ความโปร่งใส) 1 = ทึบ, 0 = โปร่ง
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	
	# พอ animation จบให้ลบตัวเอง
	tween.tween_callback(queue_free)
