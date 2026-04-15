class_name CompanionWeapon
extends WeaponBase

@export var companion_count: int = 1
@export var companion_distance: float = 60.0

const COMPANION_INSTANCE = preload("res://scenes/weapons/companion.tscn")

var companions: Array = []

func _ready() -> void:
	super._ready()
	_spawn_companions.call_deferred()
	
# ไม่ใช้ fire system ของ WeaponBase
# Companion ยิงเองผ่าน SingleShotWeapon ของตัวเอง
func _physics_process(delta: float) -> void:
	pass
	
func _try_shoot() -> void:
	pass
	
func _spawn_companions() -> void:
	for i in companion_count:
		_spawn_one_companions(i)
		
func _spawn_one_companions(index: int) -> void:
	var companion: Area2D = COMPANION_INSTANCE.instantiate()
	
	# จัดตำแหน่ง companion รอบ player
	# ถ้ามีหลายตัว กระจายเป็นวงกลมเหมือน orbit 
	var angle = (TAU / max(companion_count, 1)) * index
	companion.offset = Vector2(
		cos(angle) * companion_distance,
		sin(angle) * companion_distance
	)
	
	get_parent().get_parent().add_child(companion)
	companions.append(companion)

func add_companion() -> void:
	companion_count += 1
	_spawn_one_companions(companions.size())
	
func apply_upgrade(type: String) -> void:
	match type:
		"add_companion":
			add_companion()
		"damage":
			damage += 3.0
			for companion in companions:
				if is_instance_valid(companion):
					var weapon = companion.get_node_or_null("SingleShotWeapon")
					if weapon:
						weapon.damage += 3.0
		"fire_rate":
			# lv3: propagate ไปหา SingleShotWeapon ของทุก companion จริงๆ
			# (CompanionWeapon ตัวเองไม่ได้ยิง companion node เป็นคนยิง)
			for companion in companions:
				if is_instance_valid(companion):
					var weapon = companion.get_node_or_null("SingleShotWeapon")
					if weapon:
						weapon.fire_rate += 0.5
		_:
			super.apply_upgrade(type)
