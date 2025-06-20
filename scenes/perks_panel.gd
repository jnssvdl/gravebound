extends Control
class_name PerkSelectionUI

class Perk:
	var id: String
	var name: String
	var description: String
	var icon_path: String
	var weight: float
	var effect_type: String
	var effect_value: float
	var effect_value_int: int
	
	func _init(p_id: String, p_name: String, p_desc: String, p_icon: String, p_weight: float, p_type: String, p_value: float = 0.0, p_value_int: int = 0):
		id = p_id
		name = p_name
		description = p_desc
		icon_path = p_icon
		weight = p_weight
		effect_type = p_type
		effect_value = p_value
		effect_value_int = p_value_int

var available_perks: Array[Perk] = []
var selected_perks: Array[Perk] = []

@export var player: Node

@onready var perk1: PerkDisplay = $Perk1
@onready var perk2: PerkDisplay = $Perk2
@onready var perk3: PerkDisplay = $Perk3

@onready var title_label: Label = $TitleLabel
@onready var background: ColorRect = $Background
@onready var close_button: Button = $CloseButton

var perk_displays: Array[PerkDisplay] = []

signal perk_selected(perk: Perk)
signal selection_closed()

# Exported perk properties for inspector customization
@export_group("Damage Bonus Perks")
@export var dmg_bonus_small_weight: float = 25.0
@export var dmg_bonus_small_value: float = 5.0
@export var dmg_bonus_medium_weight: float = 15.0
@export var dmg_bonus_medium_value: float = 10.0
@export var dmg_bonus_large_weight: float = 5.0
@export var dmg_bonus_large_value: float = 20.0

@export_group("Damage Multiplier Perks")
@export var dmg_mult_small_weight: float = 20.0
@export var dmg_mult_small_value: float = 1.1
@export var dmg_mult_medium_weight: float = 10.0
@export var dmg_mult_medium_value: float = 1.25
@export var dmg_mult_large_weight: float = 3.0
@export var dmg_mult_large_value: float = 1.5

@export_group("Speed Bonus Perks")
@export var speed_bonus_small_weight: float = 25.0
@export var speed_bonus_small_value: float = 30.0
@export var speed_bonus_medium_weight: float = 15.0
@export var speed_bonus_medium_value: float = 50.0

@export_group("Speed Multiplier Perks")
@export var speed_mult_small_weight: float = 20.0
@export var speed_mult_small_value: float = 1.15
@export var speed_mult_medium_weight: float = 8.0
@export var speed_mult_medium_value: float = 1.3

@export_group("Health Perks")
@export var health_bonus_small_weight: float = 25.0
@export var health_bonus_small_value: int = 20
@export var health_bonus_medium_weight: float = 15.0
@export var health_bonus_medium_value: int = 50
@export var max_health_bonus_weight: float = 20.0
@export var max_health_bonus_value: int = 30
@export var health_mult_weight: float = 10.0
@export var health_mult_value: float = 1.2

@export_group("Defense Perks")
@export var dmg_reduction_small_weight: float = 20.0
@export var dmg_reduction_small_value: float = 3.0
@export var dmg_reduction_medium_weight: float = 12.0
@export var dmg_reduction_medium_value: float = 7.0
@export var dmg_resistance_small_weight: float = 18.0
@export var dmg_resistance_small_value: float = 0.9
@export var dmg_resistance_medium_weight: float = 8.0
@export var dmg_resistance_medium_value: float = 0.8

@export_group("Special Perks")
@export var lifesteal_small_weight: float = 15.0
@export var lifesteal_small_value: float = 0.1
@export var lifesteal_medium_weight: float = 8.0
@export var lifesteal_medium_value: float = 0.2
@export var dash_bonus_weight: float = 12.0
@export var dash_bonus_value: int = 1
@export var dash_bonus_rare_weight: float = 4.0
@export var dash_bonus_rare_value: int = 2

func get_all_buttons(node: Node) -> Array:
	var buttons = []
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		buttons += get_all_buttons(child)
	return buttons
	
func _ready():
	for button in get_all_buttons(self):
		button.pressed.connect(func(): AudioManager.play_ui_sound("button_click"))
		button.mouse_entered.connect(func(): AudioManager.play_ui_sound("button_hover"))
		
	_initialize_perks()
	_setup_ui()
	hide()

func _initialize_perks():
	# Clear existing perks first
	available_perks.clear()
	
	# Use exported variables for perk initialization
	available_perks.append(Perk.new("dmg_bonus_small", "Minor Damage", "Increases your base damage by a small amount", "res://icons/damage_small.png", dmg_bonus_small_weight, "damage_bonus", dmg_bonus_small_value))
	available_perks.append(Perk.new("dmg_bonus_medium", "Moderate Damage", "Increases your base damage by a moderate amount", "res://icons/damage_medium.png", dmg_bonus_medium_weight, "damage_bonus", dmg_bonus_medium_value))
	available_perks.append(Perk.new("dmg_bonus_large", "Major Damage", "Significantly increases your base damage", "res://icons/damage_large.png", dmg_bonus_large_weight, "damage_bonus", dmg_bonus_large_value))
	
	available_perks.append(Perk.new("dmg_mult_small", "Sharpened Blade", "Your attacks deal more damage", "res://icons/damage_mult_small.png", dmg_mult_small_weight, "damage_multiplier", dmg_mult_small_value))
	available_perks.append(Perk.new("dmg_mult_medium", "Berserker's Fury", "Enter a rage state that amplifies damage", "res://icons/damage_mult_medium.png", dmg_mult_medium_weight, "damage_multiplier", dmg_mult_medium_value))
	available_perks.append(Perk.new("dmg_mult_large", "Divine Strength", "Channel divine power for devastating attacks", "res://icons/damage_mult_large.png", dmg_mult_large_weight, "damage_multiplier", dmg_mult_large_value))
	
	available_perks.append(Perk.new("speed_bonus_small", "Swift Steps", "Move faster across the battlefield", "res://icons/speed_small.png", speed_bonus_small_weight, "speed_bonus", speed_bonus_small_value))
	available_perks.append(Perk.new("speed_bonus_medium", "Wind Walker", "Harness the wind to boost your speed", "res://icons/speed_medium.png", speed_bonus_medium_weight, "speed_bonus", speed_bonus_medium_value))
	available_perks.append(Perk.new("speed_mult_small", "Fleet Footed", "Your natural agility is enhanced", "res://icons/speed_mult_small.png", speed_mult_small_weight, "speed_multiplier", speed_mult_small_value))
	available_perks.append(Perk.new("speed_mult_medium", "Lightning Reflexes", "Move with lightning-like speed", "res://icons/speed_mult_medium.png", speed_mult_medium_weight, "speed_multiplier", speed_mult_medium_value))
	
	available_perks.append(Perk.new("health_bonus_small", "Vitality Boost", "Feel more energized and healthy", "res://icons/health_small.png", health_bonus_small_weight, "health_bonus", 0.0, health_bonus_small_value))
	available_perks.append(Perk.new("health_bonus_medium", "Hardy Constitution", "Your body becomes more resilient", "res://icons/health_medium.png", health_bonus_medium_weight, "health_bonus", 0.0, health_bonus_medium_value))
	available_perks.append(Perk.new("max_health_bonus", "Robust Body", "Permanently increase your maximum health", "res://icons/max_health.png", max_health_bonus_weight, "max_health_bonus", 0.0, max_health_bonus_value))
	available_perks.append(Perk.new("health_mult", "Troll Regeneration", "Your body heals like a mythical troll", "res://icons/health_mult.png", health_mult_weight, "health_multiplier", health_mult_value))
	
	available_perks.append(Perk.new("dmg_reduction_small", "Thick Skin", "Your skin hardens against attacks", "res://icons/defense_small.png", dmg_reduction_small_weight, "damage_reduction", dmg_reduction_small_value))
	available_perks.append(Perk.new("dmg_reduction_medium", "Iron Hide", "Your body becomes as tough as iron", "res://icons/defense_medium.png", dmg_reduction_medium_weight, "damage_reduction", dmg_reduction_medium_value))
	available_perks.append(Perk.new("dmg_resistance_small", "Armor Training", "Learn to deflect incoming attacks", "res://icons/resistance_small.png", dmg_resistance_small_weight, "damage_resistance", dmg_resistance_small_value))
	available_perks.append(Perk.new("dmg_resistance_medium", "Defensive Mastery", "Master the art of damage mitigation", "res://icons/resistance_medium.png", dmg_resistance_medium_weight, "damage_resistance", dmg_resistance_medium_value))
	
	available_perks.append(Perk.new("lifesteal_small", "Vampiric Touch", "Drain life from your enemies", "res://icons/lifesteal_small.png", lifesteal_small_weight, "lifesteal", lifesteal_small_value))
	available_perks.append(Perk.new("lifesteal_medium", "Blood Drinker", "Feast on the life force of your foes", "res://icons/lifesteal_medium.png", lifesteal_medium_weight, "lifesteal", lifesteal_medium_value))
	available_perks.append(Perk.new("dash_bonus", "Extra Dash", "Gain an additional dash charge", "res://icons/dash_bonus.png", dash_bonus_weight, "dash_bonus", 0.0, dash_bonus_value))
	available_perks.append(Perk.new("dash_bonus_rare", "Dash Master", "Master of evasive maneuvers", "res://icons/dash_bonus_rare.png", dash_bonus_rare_weight, "dash_bonus", 0.0, dash_bonus_rare_value))

func _setup_ui():
	perk_displays = [perk1, perk2, perk3]
	
	for i in range(perk_displays.size()):
		var perk_display = perk_displays[i]
		if perk_display:
			perk_display.perk_clicked.connect(_on_perk_selected)
	
	if title_label:
		title_label.text = "Choose Your Perk"
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if background:
		background.color = Color(0, 0, 0, 0.8)

func show_perk_selection(p_player: Node):
	# Reinitialize perks to use current exported values
	_initialize_perks()
	
	player = p_player
	selected_perks = _select_random_perks(3)
	_update_perk_displays()
	show()
	
func _close_selection():
	hide()
	selection_closed.emit()
	# Only call SceneManager if it exists and is valid
	if is_instance_valid(SceneManager) and SceneManager.has_method("transition_to_state"):
		SceneManager.transition_to_state(GameData.GameState.PLAYING)

func _select_random_perks(count: int) -> Array[Perk]:
	var result: Array[Perk] = []
	var weighted_pool: Array[Perk] = []
	
	# Validate we have perks
	if available_perks.is_empty():
		return result
	
	for perk in available_perks:
		var weight_count = int(perk.weight)
		for i in range(weight_count):
			weighted_pool.append(perk)
	
	if weighted_pool.is_empty():
		return result
	
	var used_perks: Array[String] = []
	while result.size() < count and weighted_pool.size() > 0:
		var random_index = randi() % weighted_pool.size()
		var selected_perk = weighted_pool[random_index]
		
		if not used_perks.has(selected_perk.id):
			result.append(selected_perk)
			used_perks.append(selected_perk.id)
		
		weighted_pool = weighted_pool.filter(func(p): return p.id != selected_perk.id)
	
	return result

func _update_perk_displays():
	for i in range(min(selected_perks.size(), perk_displays.size())):
		var perk = selected_perks[i]
		var display = perk_displays[i]
		
		if display and display.has_method("setup_perk"):
			display.setup_perk(perk, i)
			display.set_interactable(true)
			display.show()
	
	for i in range(selected_perks.size(), perk_displays.size()):
		if perk_displays[i]:
			perk_displays[i].hide()

func _on_perk_selected(perk_index: int):
	if perk_index >= selected_perks.size():
		return
	
	var selected_perk = selected_perks[perk_index]
	_apply_perk_to_player(selected_perk)
	
	for display in perk_displays:
		if display and display.has_method("set_interactable"):
			display.set_interactable(false)
	
	perk_selected.emit(selected_perk)
	
	# Short delay then close - use safer timer approach
	await _safe_timer(0.3)
	_close_selection()

func _safe_timer(duration: float):
	# Create a safe timer that handles tree being null
	var tree = get_tree()
	if tree:
		await tree.create_timer(duration).timeout
	else:
		# Fallback if tree is null - just wait a frame
		await get_tree().process_frame

func _apply_perk_to_player(perk: Perk):
	if not player or not is_instance_valid(player):
		return
	
	match perk.effect_type:
		"damage_bonus":
			if player.has_method("add_damage_bonus"):
				player.add_damage_bonus(perk.effect_value)
		"damage_multiplier":
			if player.has_method("add_damage_multiplier"):
				player.add_damage_multiplier(perk.effect_value)
		"speed_bonus":
			if player.has_method("add_speed_bonus"):
				player.add_speed_bonus(perk.effect_value)
		"speed_multiplier":
			if player.has_method("add_movement_speed_multiplier"):
				player.add_movement_speed_multiplier(perk.effect_value)
		"health_bonus":
			if player.has_method("add_health_bonus"):
				player.add_health_bonus(perk.effect_value_int)
		"max_health_bonus":
			if player.has_method("add_max_health_bonus"):
				player.add_max_health_bonus(perk.effect_value_int)
		"health_multiplier":
			if player.has_method("add_health_multiplier"):
				player.add_health_multiplier(perk.effect_value)
		"damage_reduction":
			if player.has_method("add_damage_reduction"):
				player.add_damage_reduction(perk.effect_value)
		"damage_resistance":
			if player.has_method("add_damage_resistance"):
				player.add_damage_resistance(perk.effect_value)
		"lifesteal":
			if player.has_method("add_lifesteal"):
				player.add_lifesteal(perk.effect_value)
		"dash_bonus":
			if player.has_method("add_dash_count_bonus"):
				player.add_dash_count_bonus(perk.effect_value_int)

func hide_perk_selection():
	_close_selection()

func add_custom_perk(id: String, name: String, description: String, icon_path: String, weight: float, effect_type: String, effect_value: float = 0.0, effect_value_int: int = 0):
	var new_perk = Perk.new(id, name, description, icon_path, weight, effect_type, effect_value, effect_value_int)
	available_perks.append(new_perk)

func set_perk_weight(perk_id: String, new_weight: float):
	for perk in available_perks:
		if perk.id == perk_id:
			perk.weight = new_weight
			break

# Helper function to refresh perks with current exported values (useful for runtime changes)
func refresh_perk_values():
	_initialize_perks()
