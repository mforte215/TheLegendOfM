extends Resource
class_name ItemData

enum ItemType { USABLE, EQUIPMENT, KEY_ITEM, CONSUMABLE }
@export var id: String = ""
@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var item_type: ItemType = ItemType.USABLE
@export var effect_value: int = 0
@export var use_effect: String = ""
@export var stackable: bool = true
@export var max_stack: int = 99

@export_group("Equipment")
@export var attack_bonus: int = 0
@export var defense_bonus: int = 0
@export var equip_slot: String = ""
@export var attack_anim: String = ""
