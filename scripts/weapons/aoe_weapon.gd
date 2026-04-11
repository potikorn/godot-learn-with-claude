class_name AOEWeapon
extends WeaponBase

@export var grenade_lifespan: float = 0.8

const GRENADE_SCENE = preload("res://scenes/weapons/grenade.tscn")

func _try_shoot() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	# หา enemy ใกล้สุด - เหมือน single shot
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
	
