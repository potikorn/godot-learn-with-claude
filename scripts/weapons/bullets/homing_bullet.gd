class_name HomingBullet
extends Area2D

@export var speed: float = 280.0
@export var turn_speed: float = 4.0  # radian/วินาที
@export var lifespan: float = 3.0    # ป้องกันลอยค้าง

var weapon: WeaponBase = null
var target: Node2D = null
var current_direction: Vector2 = Vector2.RIGHT
var timer: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	timer += delta
	if timer >= lifespan:
		queue_free()
		return
		
	# หา target ใหม่ถ้าไม่มีหรือ target ตายแล้ว
	if not is_instance_valid(target):
		target = _find_nearest_enemy()
		
	# หมุนหา target ถ้ามี
	if is_instance_valid(target):
		var desired_direction = global_position.direction_to(target.global_position)
		# หมุน current_direction เข้าหา desired_direction ทีละนิด
		current_direction = current_direction.rotated(
			_get_turn_angle(current_direction, desired_direction, turn_speed * delta)
		)
	position += current_direction * speed * delta
	# หมุน sprite ตามทิศทาง
	rotation = current_direction.angle()
	
func _get_turn_angle(current: Vector2, desired: Vector2, max_turn: float) -> float:
	# คำนวณมุมที่ต้องหมุน ไม่เกิน max_turn
	var cross = current.cross(desired)  # บวก = หมุนซ้าย, ลบ = หมุนขวา
	var angle = asin(clamp(cross, -1.0, 1.0))
	return clamp(angle, -max_turn, max_turn)

func _find_nearest_enemy() -> Node2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return null
	
	var nearest: Node2D = enemies[0]
	var nearest_dist = global_position.distance_to(nearest.global_position)
	for enemy: Node2D in enemies:
		var dist = global_position.distance_to(enemy.global_position)
		if dist < nearest_dist:
			nearest = enemy
			nearest_dist = dist
	return nearest

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		var dmg = _calc_damage()
		body.take_damage(dmg)
		SoundManager.play("hit")
		queue_free()

func _calc_damage() -> float:
	if not weapon:
		return 10.0
	var mult = weapon.player.damage_multiplier if (weapon.player and "damage_multiplier" in weapon.player) else 1.0
	return weapon.damage * mult
