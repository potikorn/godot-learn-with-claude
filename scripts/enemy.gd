class_name Enemy
extends CharacterBody2D

enum Type {
	NORMAL,
	FAST,
	TANK
}

@export var type: Type = Type.NORMAL

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
	_setup_type()
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
	
func _setup_type() -> void:
	match type:
		Type.NORMAL:
			$ColorRect.color = Color.RED
		Type.FAST:
			max_hp *= 0.5       # HP น้อยกว่า
			speed *= 2.0        # เร็วกว่า 2 เท่า
			damage *= 0.75      # damage น้อยกว่านิดนึง
			$ColorRect.color = Color.ORANGE
		Type.TANK:
			max_hp *= 3.0       # HP เยอะกว่า 3 เท่า
			speed *= 0.5        # ช้ากว่า
			damage *= 2.0       # damage มากกว่า
			$ColorRect.color = Color.DARK_RED
			# scale ใหญ่ขึ้นด้วยเพื่อให้เห็นชัด
			# scale ColorRect โดยตรงแทน node แม่
			$ColorRect.size = Vector2(60, 60)       # ขยายจาก 40x40
			$ColorRect.position = Vector2(-30, -30) # offset ใหม่ให้อยู่กลาง
			# ขยาย collision ด้วย
			$CollisionShape2D.shape.size = Vector2(60, 60)
	current_hp = max_hp  # set หลัง modify แล้ว
	
	
