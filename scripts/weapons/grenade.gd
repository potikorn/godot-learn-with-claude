class_name Grenade
extends Area2D

@export var speed: float = 250.0
@export var lifespan: float = 0.8  # วินาทีก่อนระเบิด

const EXPLOSION_SCENE = preload("res://scenes/weapons/explosion.tscn")

var direction: Vector2 = Vector2.ZERO
var weapon: WeaponBase = null
var timer: float = 0.0
var has_exploded: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	# บินตรง ๆ
	position += direction * speed * delta
	
	# หมุนตามทิศทางให้ดูมีชีวิตชีวา
	rotation += delta * 5.0
	
	timer += delta
	if timer >= lifespan:
		_explode()
		
func _explode() -> void:
	print("_explode called")
	if has_exploded:
		return
	has_exploded = true

	var explosion: Explosion = EXPLOSION_SCENE.instantiate()
	explosion.global_position = global_position

	if weapon:
		# คำนวณ damage รวม multiplier จาก player ตอนระเบิด
		var mult = weapon.player.damage_multiplier if (weapon.player and "damage_multiplier" in weapon.player) else 1.0
		explosion.damage = weapon.damage * mult
		if "explosion_radius" in weapon:
			explosion.radius = weapon.explosion_radius

	get_parent().add_child(explosion)
	explosion.explode()
	print("explode deferred called")
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		_explode()
	
