extends Area2D

@export var exp_value: float = 10.0
@export var pickup_range: float = 100.0 # ระยะที่ orb เริ่มลอยเข้าหา player
@export var follow_speed: float = 150.0

var player: CharacterBody2D = null
var is_following: bool = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	# เมื่อ orb ขน player ให้เก็บ exp
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	var dist = global_position.distance_to(player.global_position)
	
	# เช็คระยะทุก frame - ถ้าเข้าใกล้พอให้เริ่ม follow
	if dist <= pickup_range:
		is_following = true
	
	if is_following:
		# เคลื่อนที่เข้าหา player
		var direction = global_position.direction_to(player.global_position)
		position += direction * follow_speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		SoundManager.play("exp_collect", -8.0)
		# บอกให้ player รับ exp - ใช้ signal แทนการเรียกตรง
		body.collect_exp(exp_value)
		queue_free()
		
		
		
		
