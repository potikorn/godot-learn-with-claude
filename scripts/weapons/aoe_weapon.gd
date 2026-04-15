class_name AOEWeapon
extends WeaponBase

@export var grenade_lifespan: float = 0.8

# เก็บ radius ไว้ใน weapon แล้วส่งไป grenade → explosion ตอน spawn
# ตั้งค่าเดียวกับ Explosion default (80.0) ให้ baseline เหมือนกัน
var explosion_radius: float = 80.0

const GRENADE_SCENE = preload("res://scenes/weapons/grenade.tscn")

func _try_shoot() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return

	# หา enemy ใกล้สุด
	var nearest: Node2D = enemies[0]
	var nearest_dist = player.global_position.distance_to(nearest.global_position)
	for enemy: Node2D in enemies:
		var dist = player.global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist

	var grenade: Grenade = GRENADE_SCENE.instantiate()
	grenade.direction = player.global_position.direction_to(nearest.global_position)
	grenade.global_position = player.global_position
	grenade.weapon = self
	grenade.lifespan = grenade_lifespan
	get_parent().get_parent().add_child(grenade)

func apply_upgrade(type: String) -> void:
	match type:
		"radius":
			# lv2: explosion_radius จะถูกส่งไป grenade → explosion ตอน _explode()
			explosion_radius += 40.0
		"damage":
			damage += 20.0  # description: "Damage +20"
		_:
			super.apply_upgrade(type)
