class_name Explosion
extends Area2D

@export var radius: float = 80.0
@export var damage: float = 30.0
@export var duration: float = 0.3  # เวลา animation

func explode() -> void:
	print("explode() running, radius: ", radius)
	# resize ColorRect ให้ครอบคลุม radius
	var size = radius * 2
	$ColorRect.size = Vector2(size, size)
	$ColorRect.position = Vector2(-radius, -radius)
	$ColorRect.color = Color(1.0, 0.4, 0.0, 0.8)  # สีส้ม
	
	# ขยาย collision shape ด้วย
	#$CollisionShape2D.shape.radius = radius
	
	# damage ทุก enemy ในรัศมีทันที
	#var enemies = get_overlapping_bodies()
	#for enemy in enemies:
		#if enemy.is_in_group("enemies"):
			#enemy.take_damage(damage)
	#
	
	# Query collision โดยตรงแทน get_overlapping_bodies
	var space = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	query.shape = circle
	query.transform = Transform2D(0, global_position)
	# เช็คเฉพาะ layer ของ enemy
	query.collision_mask = 2
	
	var results = space.intersect_shape(query)
	print("AOE hit: ", results.size(), " bodies")
	
	for result in results:
		var body = result["collider"]
		if body.is_in_group("enemies"):
			body.take_damage(damage)
	
	SoundManager.play("enemy_died", -3.0)  # ใช้เสียง explosion ชั่วคราว
	
	# animate fade out แล้วหายไป
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 0.0, duration)
	tween.parallel().tween_property(
		$ColorRect, "size",
		Vector2(size * 1.5, size * 1.5), duration
	)
	tween.tween_callback(queue_free)
