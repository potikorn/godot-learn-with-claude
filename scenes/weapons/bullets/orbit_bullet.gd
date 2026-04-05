class_name OrbitBullet
extends Area2D

#@export var damage: float = 5.0

# cooldown ป้องกันการ deal demage ซ้ำรัว
var hit_cooldown: float = 0.5
var hit_timer: float = 0.0
var weapon: WeaponBase = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
func _physics_process(delta: float) -> void:
	if hit_timer > 0:
		hit_timer -= delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies") and hit_timer <= 0:
		var dmg = weapon.damage if weapon else 10.0
		body.take_damage(dmg)
		SoundManager.play("hit")
		hit_timer = hit_cooldown # รอก่อนจะ hit ได้อีก
		# ไม่ queue_free() — orbit bullet ไม่หายไป!
