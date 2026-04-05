extends CharacterBody2D

@export var speed: float = 80.0
@export var max_hp: float = 30.0
@export var damage: float = 10.0

const EXP_ORB_SCENE = preload("res://scenes/exp_orb.tscn")

const MAX_CHASE_DISTANCE = 1500.0
const RESPAWN_DISTANCE = 800.0 # Spawn ห่างจาก player

# ตัวแปรเก็บ reference ของ Player
var player: CharacterBody2D = null
var current_hp: float = max_hp

func _ready() -> void:
	current_hp = max_hp
	# หา player ใน scene โดยใช้ group
	# อธิบายเพิ่มเติมด้านล่าง
	player = get_tree().get_first_node_in_group("player")
	_spawn_animation()
	
func _physics_process(delta: float) -> void:
	if player == null:
		return
		
	if global_position.distance_to(player.global_position) > MAX_CHASE_DISTANCE:
		_respawn_near_player()
		return
		
	# คำนวณทิศทางจาก enemy ไปหา player
	var direction = global_position.direction_to(player.global_position)
	
	velocity = direction * speed
	move_and_slide()
	
	# เช็คว่าขน player ไหมหลัง move
	# get_slide_collision_count() คืนจำนวนการชนใน frame นี้
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("player"):
			collider.take_damage(damage, global_position)
	
func take_damage(amount: float) -> void:
	current_hp -= amount
	Utils.spawn_damage_number(amount, global_position, get_parent())
	_flash()
	
	if current_hp <= 0:
		_die.call_deferred()
		
func _respawn_near_player() -> void:
	# สุ่มมุม 0-360 องศา แล้ว spawn ห่างออกไป
	var angle = randf() * TAU # TAU = 2*PI = 360 องศาในหน่วย radian
	var offset = Vector2(cos(angle), sin(angle)) * RESPAWN_DISTANCE
	global_position = player.global_position + offset
		
func _die() -> void:
	SoundManager.play("enemy_died", -3.0)
	# แจ้ง UI ให้อัปเดต enemy count
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.notify_enemy_died()
	
	# Spawn exp orb ก่อน queue_free
	var orb: Area2D = EXP_ORB_SCENE.instantiate()
	orb.global_position = global_position
	get_parent().add_child(orb)
	queue_free()
	
func _flash() -> void:
	var tween = create_tween()
	# เปลี่ยนเป็นสีแดงทันที
	tween.tween_property(self, "modulate", Color.RED, 0.0)
	# รอ 0.1 วินาทีแล้วกลับสีเดิม
	tween.tween_interval(0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
func _spawn_animation() -> void:
	# เริ่มจากเล็กและโปร่งใส
	scale = Vector2.ZERO
	modulate.a = 0.0
	
	var tween = create_tween()
	# ขยายและ fade in พร้อมกัน
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.2)
	
	
	
