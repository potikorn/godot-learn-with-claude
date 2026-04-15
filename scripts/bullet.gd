extends Area2D

@export var speed: float = 400.0

var direction: Vector2 = Vector2.ZERO
var weapon: WeaponBase = null

func _ready() -> void:
	# เชื่อม signal - เมื่อ bullet ชน body อะไรก็ตาม
	body_entered.connect(_on_body_entered)
	
	# ทำลายตัวเองถ้าออกนอกจอนานเกิน (ป้องกัน memory leak)
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		var dmg = _calc_damage()
		body.take_damage(dmg)
		SoundManager.play("hit")
		queue_free()

func _calc_damage() -> float:
	if not weapon:
		return 10.0
	# ใช้ duck typing เพราะ weapon.player อาจเป็น Companion ไม่ใช่ Player
	# (companion's weapon มี parent เป็น Companion node ไม่ใช่ตัว Player จริงๆ)
	var mult = weapon.player.damage_multiplier if (weapon.player and "damage_multiplier" in weapon.player) else 1.0
	return weapon.damage * mult
