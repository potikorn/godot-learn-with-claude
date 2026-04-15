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
		var dmg = _calc_damage()
		body.take_damage(dmg)
		SoundManager.play("hit")
		hit_timer = hit_cooldown
		# ไม่ queue_free() — orbit bullet ไม่หายไป!

func _calc_damage() -> float:
	if not weapon:
		return 10.0
	var mult = weapon.player.damage_multiplier if (weapon.player and "damage_multiplier" in weapon.player) else 1.0
	return weapon.damage * mult
