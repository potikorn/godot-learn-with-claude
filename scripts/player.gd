extends CharacterBody2D

# ความเร็วตัวละคร (pixels ต่อวินาที)
# export ทำให้แก้ค่าได้จาก Inspector โดยไม่ต้องแตะโค้ด
@export var speed: float = 200.0
@export var fire_rate: float = 1.0 # ยิงกี่ครั้งต่อวินาที
@export var exp_to_next_level: float = 50.0 # exp ที่ต้องการต่อเลเวล
@export var max_hp: float = 100.0
@export var invincibility_time: float = 0.5 # วินาทีที่โดนแล้วยังโดนซ้ำไม่ได้
@export var auto_shoot: bool = true
@export var bullet_damage: float = 10.0

# preload บอกว่า "โหลด scene นี้พร้อมไว้เลย"
# ใช้ดีกว่า load() ตอน runtime เพราะโหลดตอน complie time
const BULLET_SCENE = preload("res://scenes/bullet.tscn")
const DAMANGE_NUMBER_SCENE = preload("res://scenes/damage_number.tscn")

var fire_timer: float = 0.0
var current_exp: float = 0.0
var current_level: int = 1
var current_hp: float = max_hp
var is_invincible: bool = false
var is_knocked_back: bool = false

@onready var ui = get_parent().get_node("UI")
@onready var camera = $Camera2D

func _physics_process(delta: float) -> void:
	# === Movement ===
	# รับ input แล้วแปลงเป็น direction vector
	# get_vector คืนค่า Vector2 ที่ normalize แล้วในตัว
	if not is_knocked_back:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
		# คำนวณ velocity จาก direction × speed
		velocity = direction * speed
	
	# สั่งให้ CharacterBody2D เคลื่อนที่จริงๆ
	# move_and_slide จัดการชนกำแพง/พื้นให้อัตโนมัติ
	move_and_slide()
	
	# === Auto Attack ===
	if not auto_shoot:
		return
	fire_timer -= delta
	if fire_timer <= 0:
		fire_timer = 1.0 / fire_rate
		_try_shoot()
		
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
	bullet.damage = bullet_damage
	
	# เพิ่ม bullet เข้า World ไม่ใช่ Player
	# ถ้าเพิ่มใต้ Player กระสุนจะขยับตามตัวละครด้วย
	get_parent().add_child(bullet)
		
func _level_up() -> void:
	current_level += 1
	current_exp = 0.0
	# แต่ละ level ต้องการ exp มากขึ้น 20%
	exp_to_next_level *= 1.2
	ui.update_exp(current_exp, exp_to_next_level)
	# Level Up แบบเงียบๆ — แค่ +stat ไม่ pause เกม
	_apply_passive_bonus()
	print("Level ", current_level, " — passive bonus applied")
	
func _die() -> void:
	ui.show_game_over()
	get_tree().paused = true

# method นี้ถูกเรียกจาก ExpOrb
func collect_exp(amount: float) -> void:
	current_exp += amount
	ui.update_exp(current_exp, exp_to_next_level) # <- อัปเดต bar
	print("EXP: ", current_exp, " / ", exp_to_next_level)
	
	if current_exp >= exp_to_next_level:
		_level_up()
		
func take_damage(amount: float, knockback_source: Vector2 = Vector2.ZERO) -> void:
	if is_invincible:
		return
	
	current_hp -= amount
	_spawn_damage_number(amount)
	ui.update_hp(current_hp, max_hp) # <- อัปเดต bar
	camera.shake()
	print("HP: ", current_hp, " / ", max_hp)
	
	# ตั้ง invincible ก่อนเลย ก่อน await ใดๆ ทั้งนั้น
	is_invincible = true
	
	# knockback - ดันออกจากทิศที่โดนชน
	if knockback_source != Vector2.ZERO:
		var knockback_dir = knockback_source.direction_to(global_position)
		velocity = knockback_dir * 300.0
		is_knocked_back = true
		# หลัง 0.15 วินาที ให้ควบคุมได้ปกติ
		await get_tree().create_timer(0.15).timeout
		is_knocked_back = false
	
	# หลัง invincibility_time วินาที ให้โดนดาเมจได้อีก
	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false
	
	if current_hp <= 0:
		_die()
		
func apply_upgrade(type: String) -> void:
	match type:
		"speed":
			speed += 50.0
			print("Speed Up -> ", speed)
		"damage":
			bullet_damage += 5.0
			print("Damage UP")
		"fire_rate":
			fire_rate += 0.5
			print("Fire Rate Up -> ", fire_rate)
	
	
func _spawn_damage_number(amount: float) -> void:
	var dmg_num: Node2D = DAMANGE_NUMBER_SCENE.instantiate()
	
	# make offset
	dmg_num.position = global_position + Vector2(randf_range(-10, 10), -20)
	
	get_parent().add_child(dmg_num)
	dmg_num.setup(amount)
	
func _apply_passive_bonus() -> void:
	# stat เล็กน้อยทุก level
	max_hp += 5.0
	current_hp = min(current_hp + 5.0, max_hp)
	ui.update_hp(current_hp, max_hp)
	bullet_damage += 1.0
	
	
	
	
