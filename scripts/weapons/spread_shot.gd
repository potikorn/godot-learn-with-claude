class_name SpreadShotWeapon
extends WeaponBase

@export var spread_angle: float = 20.0 # องศาที่เบี่ยงซ้าย ขวา
@export var bullet_count: int = 3

const BULLET_SCENE = preload("res://scenes/bullet.tscn")

func _try_shoot() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
		
	# หา enemy ใกล้สุด - เหมือน single shot เลย
	var nearest: CharacterBody2D = enemies[0]
	var nearest_dist = player.global_position.distance_to(nearest.global_position)
	for enemy in enemies:
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	
	# ทิศทางหลักไปหา enemy
	var base_direction = player.global_position.direction_to(nearest.global_position)
	
	# ยิงหลายลูก แต่ละลูกเบี่ยงมุมต่างกัน
	for i in bullet_count:
		# คำนวณมุมเบี่ยงของแต่ละลูก
		# bullet_count = 3 -> offset = -20, 0, 20
		var offset_index = i - (bullet_count / 2)
		var angle_offset = deg_to_rad(spread_angle * offset_index)
		
		# หมุน base_direaction ตาม angle_offset
		var direction = base_direction.rotated(angle_offset)
		
		var bullet: Area2D = BULLET_SCENE.instantiate()
		bullet.direction = direction
		bullet.global_position = player.global_position
		bullet.weapon = self
		get_parent().get_parent().add_child(bullet)
	
	SoundManager.play("shoot", -10.0)
		
func apply_upgrade(type: String) -> void:
	match type:
		"damage":
			damage += 8.0  # description: "Damage +8"
		"fire_rate":
			fire_rate += 0.25
		"add_bullet":
			bullet_count += 2
		_:
			super.apply_upgrade(type)
	
	
	
	
	
	
