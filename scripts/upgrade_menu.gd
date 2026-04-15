extends Node

# เก็บ weapon scenes — ทุกตัวต้องชี้ไป .tscn ไม่ใช่ .gd
# เพราะ instantiate() ใช้ได้กับ PackedScene เท่านั้น
const WEAPON_SCENES = {
	"single_shot": preload("res://scenes/weapons/single_shot.tscn"),
	"orbit":       preload("res://scenes/weapons/orbit_weapon.tscn"),
	"spread":      preload("res://scenes/weapons/spread_shot.tscn"),
	"companion":   preload("res://scenes/weapons/companion_weapon.tscn"),
	"aoe":         preload("res://scenes/weapons/aoe_weapon.tscn"),
	"homing":      preload("res://scenes/weapons/HomingWeapon.tscn"),
}

# เก็บ state ของรันปัจจุบัน
var unlocked_weapons: Array[String] = []
var weapon_levels: Dictionary = {}  # {"single_shot": 1, "orbit": 2, ...}

func reset() -> void:
	unlocked_weapons.clear()
	weapon_levels.clear()

# Public: คืน 3 ตัวเลือกสุ่มที่ยังทำได้ (เรียกจาก UI)
func get_random_upgrades() -> Array[Dictionary]:
	var available = _get_available_upgrades()
	available.shuffle()
	var count = min(3, available.size())
	return available.slice(0, count)

func _get_available_upgrades() -> Array[Dictionary]:
	var pool: Array[Dictionary] = []

	for weapon_key in WEAPON_SCENES.keys():
		var level = weapon_levels.get(weapon_key, 0)

		if level == 0:
			# ยังไม่มี → เสนอ unlock
			pool.append({
				"weapon_key": weapon_key,
				"level": 1,
				"title": _get_upgrade_title(weapon_key, 1),
				"description": _get_upgrade_description(weapon_key, 1),
			})
		elif level < 3:
			# มีแล้วแต่ยังไม่ max → เสนอ upgrade
			pool.append({
				"weapon_key": weapon_key,
				"level": level + 1,
				"title": _get_upgrade_title(weapon_key, level + 1),
				"description": _get_upgrade_description(weapon_key, level + 1),
			})
		# level 3 = max แล้ว ไม่เสนออีก

	return pool

func apply_upgrade(upgrade: Dictionary) -> void:
	var key = upgrade["weapon_key"]
	var level = upgrade["level"]
	weapon_levels[key] = level

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	if level == 1:
		# Unlock — spawn weapon ใหม่ใต้ player
		var weapon = WEAPON_SCENES[key].instantiate()
		player.add_child(weapon)
		unlocked_weapons.append(key)
	else:
		# Upgrade — หา weapon ที่มีอยู่แล้ว แล้ว apply
		var weapon = _find_weapon(player, key)
		if weapon:
			weapon.apply_upgrade(_get_upgrade_type(key, level))

# แก้แล้ว: ลด indent ให้ถูกต้อง (เดิม indent เกิน 1 ระดับทำให้ parse error)
func _find_weapon(player: Node, key: String) -> Node:
	for child in player.get_children():
		match key:
			"single_shot":
				if child is SingleShotWeapon: return child
			"orbit":
				if child is OrbitWeapon: return child
			"spread":
				if child is SpreadShotWeapon: return child
			"companion":
				if child is CompanionWeapon: return child
			"aoe":
				if child is AOEWeapon: return child
			"homing":
				if child is HomingWeapon: return child
	return null

func _get_upgrade_title(key: String, level: int) -> String:
	match key:
		"single_shot":
			match level:
				1: return "Single Shot"
				2: return "Single Shot Lv2\nFire Rate UP"
				3: return "Single Shot Lv3\nDamage UP"
		"orbit":
			match level:
				1: return "Orbit"
				2: return "Orbit Lv2\n+1 Bullet"
				3: return "Orbit Lv3\nRadius UP"
		"spread":
			match level:
				1: return "Spread Shot"
				2: return "Spread Lv2\n+2 Bullets"
				3: return "Spread Lv3\nDamage UP"
		"companion":
			match level:
				1: return "Companion"
				2: return "Companion Lv2\n+1 Companion"
				3: return "Companion Lv3\nFire Rate UP"
		"aoe":
			match level:
				1: return "AOE Grenade"
				2: return "AOE Lv2\nRadius UP"
				3: return "AOE Lv3\nDamage UP"
		"homing":
			match level:
				1: return "Homing"
				2: return "Homing Lv2\n+1 Bullet"
				3: return "Homing Lv3\nTurn Speed UP"
	return "Unknown"

func _get_upgrade_description(key: String, level: int) -> String:
	match key:
		"single_shot":
			match level:
				1: return "ยิงกระสุนหา enemy ใกล้สุด"
				2: return "Fire Rate +0.5"
				3: return "Damage +10"
		"orbit":
			match level:
				1: return "กระสุนวนรอบตัว"
				2: return "เพิ่มกระสุน 1 ลูก"
				3: return "Radius +30"
		"spread":
			match level:
				1: return "ยิง 3 ทิศพร้อมกัน"
				2: return "เพิ่มกระสุน 2 ลูก"
				3: return "Damage +8"
		"companion":
			match level:
				1: return "ตัวช่วยลอยตามและยิง"
				2: return "เพิ่ม companion 1 ตัว"
				3: return "Fire Rate +0.5"
		"aoe":
			match level:
				1: return "กระสุนระเบิด AOE"
				2: return "Radius +40"
				3: return "Damage +20"
		"homing":
			match level:
				1: return "กระสุนล็อคเป้า enemy"
				2: return "ยิง 2 ลูกพร้อมกัน"
				3: return "Turn Speed +3"
	return ""

func _get_upgrade_type(key: String, level: int) -> String:
	match key:
		"single_shot":
			match level:
				2: return "fire_rate"
				3: return "damage"
		"orbit":
			match level:
				# แก้แล้ว: เดิมคืน "add_bullet" แต่ orbit_weapon ฟัง "add_bullet" เหมือนกัน
				# ใช้ "add_bullet" ให้ consistent กับ spread
				2: return "add_bullet"
				3: return "radius"
		"spread":
			match level:
				2: return "add_bullet"
				3: return "damage"
		"companion":
			match level:
				2: return "add_companion"
				3: return "fire_rate"
		"aoe":
			match level:
				2: return "radius"
				3: return "damage"
		"homing":
			match level:
				2: return "add_bullet"
				3: return "turn_speed"
	return ""
