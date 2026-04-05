class_name Companion
extends Area2D

@export var follow_speed: float = 5.0
@export var offset: Vector2 = Vector2(60, 0)

var player: CharacterBody2D = null
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta: float) -> void:
	if player == null:
		return
		
	# target คือตำแหน่งควรอยู่ข้าง ๆ player
	target_position = player.global_position + offset
	
	# lerp ทำให้การเคลื่อนที่ smooth - ไม่กระตุกตาม player ทันที
	global_position = global_position.lerp(target_position, follow_speed * delta)
