class_name SingleShotWeapon
extends WeaponBase

const BULLET_SCENE = preload("res://scenes/bullet.tscn")

func apply_upgrade(type: String) -> void:
	match type:
		"damage":
			damage += 10.0  # description: "Damage +10"
		_:
			super.apply_upgrade(type)

func _try_shoot() -> void:
	# หาศัตรูทั้งหมดใน scene
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
		
	# หาศัตรูที่ใกล้ที่สุด
	var nearest: CharacterBody2D = enemies[0]
	var nearest_dist = global_position.distance_to(nearest.global_position)
	
	for enemy: CharacterBody2D in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	
	# Spawn bullet
	var bullet: Area2D = BULLET_SCENE.instantiate()
	bullet.direction = global_position.direction_to(nearest.global_position)
	bullet.global_position = global_position
	bullet.weapon = self
	# เพิ่ม bullet เข้า World ไม่ใช่ Player
	# ถ้าเพิ่มใต้ Player กระสุนจะขยับตามตัวละครด้วย
	get_parent().get_parent().add_child(bullet)
	SoundManager.play("shoot", -10.0)
