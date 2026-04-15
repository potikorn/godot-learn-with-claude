class_name UpgradeData
extends Resource

enum Type {
	# Weapon Unlocks
	UNLOCK_SINGLE_SHOT,
	UNLOCK_ORBIT,
	UNLOCK_SPREAD,
	UNLOCK_COMPANION,
	UNLOCK_AOE,
	UNLOCK_HOMING,
	# Weapon upgrades,
	SINGLE_SHOT_LV2, SINGLE_SHOT_LV3,
	ORBIT_LV2, ORBIT_LV3,
	SPREAD_LV2, SPREAD_LV3,
	COMPANION_LV2, COMPANION_LV3,
	AOE_LV2, AOE_LV3,
	HOMING_LV2, HOMING_LV3
}

@export var type: Type
@export var title: String # ชื่อที่แสดงใน UI
@export var description: String # คำอธิบายสั้นๆ
@export var weapon_scene: PackedScene # สำหรับ unlock เท่านั้น
