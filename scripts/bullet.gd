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
	# ถ้าชน enemy ให้ทำลาย enemy และ bullet
	if body.is_in_group("enemies"):
		var dmg = weapon.damage if weapon else 10.0
		# เรียก method ของ enemy แทนการ queue_free ตรงๆ
		body.take_damage(dmg)
		SoundManager.play("hit")
		queue_free()
