class_name WeaponBase
extends Node2D

# ค่า base ที่ weapon ทุกแบบมีเหมือนกัน
@export var fire_rate: float = 1.0 # ยิงกี่ครั้งต่อวินาที
@export var damage: float = 10.0
@export var auto_shoot: bool = true

var fire_timer: float = 0.0
var player: CharacterBody2D = null

func _ready() -> void:
	# หา player จาก parent โดยตรง ไม่ต้องใช้ group
	player = get_parent()
	
func _physics_process(delta: float) -> void:
	if not auto_shoot:
		return
	fire_timer -= delta
	if fire_timer <= 0:
		fire_timer = 1.0 / fire_rate
		_try_shoot()

func _try_shoot() -> void:
	pass

func apply_upgrade(type: String) -> void:
	match type:
		"damage":
			damage += 5.0
		"fire_rate":
			fire_rate += 0.5
