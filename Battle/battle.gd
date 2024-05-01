extends Node2D

const ZOOM_IN = Vector2(1.2,1.2)
const ZOOM_DEFAULT = Vector2.ONE

var turnManager : TurnManager = ReferenceStash.turnManager
var asyncTurnPool : AsyncTurnPool = ReferenceStash.asyncTurnPool

var ai : AI = null

@onready var player_battle_unit = $PlayerPosition/PlayerBattleUnit
@onready var enemy_battle_unit = $EnemyPosition/EnemyBattleUnit
@onready var animation_player = $AnimationPlayer
@onready var timer = $Timer
@onready var enemy_battle_unit_info = $BattleUI/EnemyBattleUnitInfo
@onready var player_battle_unit_info = $BattleUI/PlayerBattleUnitInfo
@onready var level_up_ui = %LevelUpUI
@onready var battle_menu_manager = %BattleMenuManager
@onready var battle_camera = $BattleCamera
@onready var center_point : Vector2 = $CenterRoot/CenterPoint.global_position
@onready var enemy_camera_position : Vector2 = get_battle_unit_camera_position(enemy_battle_unit)
@onready var player_camera_position : Vector2 = get_battle_unit_camera_position(player_battle_unit)
@onready var level_up_sfx = $LevelUpSFX
@onready var battle_start_sfx = $BattleStartSFX



func _ready() -> void:
	MusicPlayer.push_song(MusicPlayer.battle_music)
	battle_start_sfx.play()
	var encounter_class : ClassStats = ReferenceStash.encounter_class
	if encounter_class is ClassStats: 
		enemy_battle_unit.stats = encounter_class.duplicate()
	player_battle_unit_info.stats = player_battle_unit.stats
	
	enemy_battle_unit_info.stats = enemy_battle_unit.stats
	assert(enemy_battle_unit.stats.ai is Script)
	ai = enemy_battle_unit.stats.ai.new()
	add_child(ai)
	
	await animation_player.animation_finished
	turnManager.ally_turn_started.connect(_on_ally_turn_started)
	turnManager.enemy_turn_started.connect(_on_enemy_turn_started)
	turnManager.start()
	asyncTurnPool.turn_over.connect(_on_async_turn_pool_turn_over)
	
func get_battle_unit_camera_position(battle_unit : BattleUnit) -> Vector2:
	var final_position := Vector2()
	var start = Vector2(battle_unit.global_position.x, center_point.y)
	final_position = start.move_toward(center_point,32)
	return final_position
	
		
func battle_won() -> void:
	timer.start(1)
	await timer.timeout
	var previous_level :int= player_battle_unit.stats.level
	player_battle_unit.stats.experience += 105
	if player_battle_unit.stats.level > previous_level:
		level_up_sfx.play()
		await level_up_ui.level_up()
	timer.start(1)
	await timer.timeout
	animation_player.play("FadeOut")

func exit_battle()->void:
	MusicPlayer.pop_song()
	timer.start(1)
	await timer.timeout
	SceneStack.pop()

func _on_ally_turn_started() -> void:
	if not is_instance_valid(player_battle_unit) or player_battle_unit.is_queued_for_deletion():
		timer.start(1)
		await timer.timeout
		get_tree().quit()
		return
	await battle_menu_manager.show_battle_menu()
	var selected_resource : Resource = await battle_menu_manager.battle_menu_resource_selected

	if selected_resource is MeleeBattleAction:
				battle_camera.focus_target(enemy_camera_position, ZOOM_IN)
				#var battle_action = player_battle_unit.stats.battle_actions.front()
				player_battle_unit.melee_attack(enemy_battle_unit, selected_resource)
	elif selected_resource is RangedBattleAction:
				#battle_camera.focus_target(player_camera_position, ZOOM_IN)
				player_battle_unit.ranged_attack(enemy_battle_unit, selected_resource)
	elif selected_resource is BasicBattleAction:
				#battle_camera.focus_target(player_camera_position, ZOOM_IN)
				player_battle_unit.basic_attack(enemy_battle_unit, selected_resource)
	elif selected_resource.name == "Defend":
		Events.emit_signal("request_show_battle_message", "Defend")
		player_battle_unit.defend = true
		timer.start(.5)
		await timer.timeout
		turnManager.advance_turn()
	elif selected_resource.name == "Run":
		var random_number = randi_range(1,5)
		if random_number <= 4:
			animation_player.play("FadeOut")
			exit_battle()
		elif random_number == 5:
			turnManager.advance_turn()
	elif selected_resource is Item:
		battle_camera.focus_target(player_camera_position, ZOOM_IN)
		player_battle_unit.use_item(player_battle_unit, selected_resource)
	
func _on_enemy_turn_started() -> void:
	if not is_instance_valid(enemy_battle_unit)  or enemy_battle_unit.is_queued_for_deletion():
		await battle_won()
		exit_battle()
		return
	var battle_action = ai._select_battle_action(enemy_battle_unit.stats)
	if battle_action is MeleeBattleAction:
		battle_camera.focus_target(player_battle_unit, ZOOM_IN)
		enemy_battle_unit.melee_attack(player_battle_unit, battle_action)
	elif battle_action is EnemyBattleAction:
		enemy_battle_unit.enemy_attack(player_battle_unit, battle_action)
	elif battle_action is BasicBattleAction:
		enemy_battle_unit.basic_attack(player_battle_unit, battle_action)
	elif battle_action.name == "Defend":
		Events.emit_signal("request_show_battle_message", "Defend")
		enemy_battle_unit.defend = true
		timer.start(2)
		await timer.timeout
		turnManager.advance_turn()

	
func _on_async_turn_pool_turn_over() -> void:
	await battle_camera.focus_target(center_point, ZOOM_DEFAULT)
	turnManager.advance_turn()
