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
	
	ReferenceStash.turnManager.turn_started.connect(_on_turn_started)
	ReferenceStash.asyncTurnPool.turn_over.connect(_on_async_turn_pool_turn_over)
	player_battle_unit.turn_finished.connect(ReferenceStash.turnManager.start_next_turn)
	enemy_battle_unit.turn_finished.connect(ReferenceStash.turnManager.start_next_turn)
	player_battle_unit.turn_finished.connect(ReferenceStash.turnManager.on_battle_unit_turn_finished.bind(player_battle_unit))
	enemy_battle_unit.turn_finished.connect(ReferenceStash.turnManager.on_battle_unit_turn_finished.bind(enemy_battle_unit))
	
	ReferenceStash.turnManager.add_battle_unit(player_battle_unit)
	ReferenceStash.turnManager.add_battle_unit(enemy_battle_unit)
	
	ReferenceStash.turnManager.start_next_turn()
	
	enemy_battle_unit.enemy_defeated.connect(_on_enemy_defeated)
	
func get_battle_unit_camera_position(battle_unit : BattleUnit) -> Vector2:
	var final_position := Vector2()
	var start = Vector2(battle_unit.global_position.x, center_point.y)
	final_position = start.move_toward(center_point,32)
	return final_position
	
func _on_enemy_defeated() -> void:
	print("Enemy defeated. Calling battle_won().")
	battle_won()

func check_battle_won() -> void:
	print("Checking if battle is won...")
	if not is_instance_valid(enemy_battle_unit):
		print("Enemy battle unit is invalid or queued for deletion. Battle won!")
		battle_won()
	else:
		print("Enemy battle unit is still valid. Battle continues.")
		
func battle_won() -> void:
	print("Battle won! Proceeding with level up and exit battle.")
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
	exit_battle()

func exit_battle()->void:
	MusicPlayer.pop_song()
	timer.start(1)
	await timer.timeout
	if is_instance_valid(enemy_battle_unit):
		enemy_battle_unit.queue_free()
	SceneStack.pop()

func _on_turn_started(active_battle_unit:BattleUnit) -> void:
	print("Turn started for battle unit:", active_battle_unit)
	if not is_instance_valid(active_battle_unit) or active_battle_unit.is_queued_for_deletion():
		ReferenceStash.turnManager.remove_battle_unit(active_battle_unit)
		ReferenceStash.turnManager.start_next_turn()
		return
	if active_battle_unit == player_battle_unit:
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
			turnManager.start_next_turn()
		elif selected_resource.name == "Run":
			animation_player.play("FadeOut")
			exit_battle()
		elif selected_resource is Item:
			#battle_camera.focus_target(player_camera_position, ZOOM_IN)
			player_battle_unit.use_item(player_battle_unit, selected_resource)
	else:
		var battle_action = ai._select_battle_action(enemy_battle_unit.stats)
		if battle_action is MeleeBattleAction:
			battle_camera.focus_target(player_battle_unit, ZOOM_IN)
			active_battle_unit.melee_attack(player_battle_unit, battle_action)
		elif battle_action is EnemyBattleAction:
			active_battle_unit.enemy_attack(player_battle_unit, battle_action)
		elif battle_action is BasicBattleAction:
			active_battle_unit.basic_attack(player_battle_unit, battle_action)
		elif battle_action.name == "Defend":
			Events.emit_signal("request_show_battle_message", "Defend")
			enemy_battle_unit.defend = true
			timer.start(2)
			await timer.timeout
	print("Checking battle won status.")
	check_battle_won()
	
func _on_async_turn_pool_turn_over() -> void:
	await battle_camera.focus_target(center_point, ZOOM_DEFAULT)
	turnManager.start_next_turn()
