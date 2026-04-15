class_name HomingWeapon
extends WeaponBase

const HOMING_BULLET_SCENE = preload("res://scenes/weapons/bullets/homing_bullet.tscn")

# State ที่เพิ่มมาสำหรับ upgrade
var bullets_per_shot: int = 1       # lv2: ยิงพร้อมกัน 2 ลูก
var turn_speed_bonus: float = 0.0   # lv3: เพิ่ม turn_speed ให้แต่ละ bullet

func _try_shoot() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return

	# หา enemy ใกล้สุด
	var nearest = enemies[0]
	var nearest_dist = player.global_position.distance_to(nearest.global_position)
	for enemy in enemies:
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist

	# ยิง bullets_per_shot ลูก (lv1 = 1 ลูก, lv2 = 2 ลูก)
	for i in bullets_per_shot:
		var bullet = HOMING_BULLET_SCENE.instantiate()
		bullet.current_direction = player.global_position.direction_to(nearest.global_position)
		bullet.global_position = player.global_position
		bullet.target = nearest
		bullet.weapon = self
		# ส่ง turn_speed_bonus เพิ่มบน turn_speed เดิมของ bullet
		bullet.turn_speed += turn_speed_bonus
		get_parent().get_parent().add_child(bullet)

	SoundManager.play("shoot", -5.0)

func apply_upgrade(type: String) -> void:
	match type:
		"add_bullet":
			# lv2: ยิงพร้อมกัน +1 ลูก
			bullets_per_shot += 1
		"turn_speed":
			# lv3: bullet หันหาเป้าได้เร็วขึ้น
			# bonus นี้จะถูกส่งให้ bullet ตอน spawn (ดูใน _try_shoot)
			turn_speed_bonus += 3.0
		_:
			super.apply_upgrade(type)
