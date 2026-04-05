class_name OrbitWeapon
extends WeaponBase

@export var orbit_radius: float = 80.0
@export var orbit_speed: float = 0.5
@export var bullet_count: int = 1

const ORBIT_BULLET_SCENE = preload("res://scenes/weapons/bullets/orbit_bullet.tscn")

var bullets: Array = []
var current_angle: float = 0.0

func _ready() -> void:
	super._ready() # เรียก _ready() ของ WeaponBase ด้วย
	_spawn_bullets.call_deferred()

func _physics_process(delta: float) -> void:
	# หมุนมุมตามเวลา
	# TAU * orbit_speed * delta = องศาที่หมุนต่อ frame
	current_angle += TAU * orbit_speed * delta
	_update_bullet_positions()

# Override _try_shoot() ไม่จำเป็น orbit ไม่มีการ "ยิง"
# แต่ต้อง override เพื่อไม่ให้ WeaponBase timer ทำงาน
func _try_shoot() -> void:
	pass
	
func _spawn_bullets() -> void:
	for i in bullet_count:
		_spawn_one_bullet()
	
func _update_bullet_positions() -> void:
	for i in bullets.size():
		if not is_instance_valid(bullets[i]):
			continue
		
		# คำนวณตำแหน่งของแต่ละลูกบนวงกลม
		# แบ่งมุมเท่าๆ กัน เช่น 3 ลูก = 0°, 120°, 240°
		var angle_offset = (TAU / bullet_count) * i
		var angle = current_angle + angle_offset
		
		var offset = Vector2(
			cos(angle) * orbit_radius,
			sin(angle) * orbit_radius
		)
		bullets[i].global_position = player.global_position + offset
		
func _spawn_one_bullet() -> void:
	var bullet = ORBIT_BULLET_SCENE.instantiate()
	bullet.weapon = self
	get_parent().get_parent().add_child(bullet)
	bullets.append(bullet)
	
func add_bullet() -> void:
	bullet_count += 1
	_spawn_one_bullet()
	
func apply_upgrade(type: String) -> void:
	match type:
		"damage":
			damage += 1.0
		"add_orbit_bullet":
			add_bullet()
		_:
			super.apply_upgrade(type)
