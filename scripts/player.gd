extends CharacterBody2D

@export var speed: float = 200.0
@export var exp_to_next_level: float = 50.0
@export var max_hp: float = 100.0
@export var invincibility_time: float = 0.5

var current_exp: float = 0.0
var current_level: int = 1
var current_hp: float = max_hp
var is_invincible: bool = false
var is_knocked_back: bool = false

# Global damage multiplier — เริ่มที่ 1.0 (= ไม่มี bonus)
# Bullet ทุกตัวอ่านค่านี้ตอนชน: final_damage = weapon.damage * player.damage_multiplier
var damage_multiplier: float = 1.0

@onready var ui = get_parent().get_node("UI")
@onready var camera = $Camera2D

func _physics_process(delta: float) -> void:
	if not is_knocked_back:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * speed
	move_and_slide()

func _level_up() -> void:
	current_level += 1
	current_exp = 0.0
	exp_to_next_level *= 1.2
	ui.update_exp(current_exp, exp_to_next_level)
	_apply_passive_bonus()
	print("Level ", current_level, " — passive bonus applied")

func _die() -> void:
	ui.show_game_over()
	get_tree().paused = true

func collect_exp(amount: float) -> void:
	current_exp += amount
	ui.update_exp(current_exp, exp_to_next_level)
	if current_exp >= exp_to_next_level:
		_level_up()

func take_damage(amount: float, knockback_source: Vector2 = Vector2.ZERO) -> void:
	if is_invincible:
		return

	current_hp -= amount
	Utils.spawn_damage_number(amount, global_position, get_parent())
	ui.update_hp(current_hp, max_hp)
	camera.shake()

	is_invincible = true

	if knockback_source != Vector2.ZERO:
		var knockback_dir = knockback_source.direction_to(global_position)
		velocity = knockback_dir * 300.0
		is_knocked_back = true
		await get_tree().create_timer(0.15).timeout
		is_knocked_back = false

	await get_tree().create_timer(invincibility_time).timeout
	is_invincible = false

	if current_hp <= 0:
		_die()

func _apply_passive_bonus() -> void:
	# HP เพิ่มทุก level
	max_hp += 5.0
	current_hp = min(current_hp + 5.0, max_hp)
	ui.update_hp(current_hp, max_hp)
	# Damage +5% ทุก level (สะสม: lv5 = ×1.25, lv10 = ×1.50)
	damage_multiplier += 0.05
