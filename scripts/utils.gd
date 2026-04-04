extends Node

const DAMAGE_NUMBER_SCENE = preload("res://scenes/damage_number.tscn")

func spawn_damage_number(amount: float, position: Vector2, parent: Node) -> void:
	var dmg_num: Node2D = DAMAGE_NUMBER_SCENE.instantiate()
	
	# offset เล็กน้อยเพื่อไม่ให้ซ้อนกันพอดีเมื่อโดนยิงหลายลูก
	dmg_num.position = position + Vector2(randf_range(-10, 10), -20)
	
	# เพิ่มใต้ World ไม่ใช่ enemy
	# ถ้าเพิ่มใต้ Enemy พอ Enemy ตาย damage numbr จะหายไปด้วย
	parent.add_child(dmg_num)
	dmg_num.setup(amount)
