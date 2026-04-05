extends CharacterBody2D

# ความเร็วตัวละคร (pixels ต่อวินาที)
# export ทำให้แก้ค่าได้จาก Inspector โดยไม่ต้องแตะโค้ด
@export var speed: float = 200.0
@export var fire_rate: float = 1.0 # ยิงกี่ครั้งต่อวินาที
@export var exp_to_next_level: float = 50.0 # exp ที่ต้องการต่อเลเวล
@export var max_hp: float = 100.0
@export var invincibility_time: float = 0.5 # วินาทีที่โดนแล้วยังโดนซ้ำไม่ได้

# preload บอกว่า "โหลด scene นี้พร้อมไว้เลย"
# ใช้ดีกว่า load() ตอน runtime เพราะโหลดตอน complie time
#const BULLET_SCENE = preload("res://scenes/bullet.tscn")

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
	Utils.spawn_damage_number(amount, global_position, get_parent())
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
		_:
			for child in get_children():
				if child.has_method("apply_upgrade"):
					child.apply_upgrade(type)
	
func _apply_passive_bonus() -> void:
	# stat เล็กน้อยทุก level
	max_hp += 5.0
	current_hp = min(current_hp + 5.0, max_hp)
	ui.update_hp(current_hp, max_hp)	
	
	
	
