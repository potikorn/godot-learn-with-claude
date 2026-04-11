class_name HomingWeapon
extends WeaponBase

const HOMING_BULLET_SCENE = preload("res://scenes/weapons/bullets/homing_bullet.tscn")

func _try_shoot() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	# หา enemy ใกล้สุดเป็น initial target
	var nearest = enemies[0]
	var nearest_dist = player.global_position.distance_to(nearest.global_position)
	for enemy in enemies:
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
			
	var bullet = HOMING_BULLET_SCENE.instantiate()
	bullet.current_direction = player.global_position.direction_to(nearest.global_position)
	bullet.global_position = player.global_position
	bullet.target = nearest
	bullet.weapon = self
	get_parent().get_parent().add_child(bullet)
	
	SoundManager.play("shoot", -5.0)
