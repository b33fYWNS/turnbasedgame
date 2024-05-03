extends Node2D
class_name BattleUnit

const ATTACK_OFFSET = 48
const KNOCKBACK_AMOUNT = 24

var defend : bool = false : set = set_defend
var damage_number_scene = preload("res://UI/damage_number_display.tscn")

@export var stats : ClassStats : set = set_stats


@onready var battle_animations : BattleAnimations
@onready var root_position := global_position
@onready var battle_shield = $BattleShield
@onready var hit_sfx = $HitSFX
@onready var defend_sfx = $DefendSFX
@onready var healing_sfx = $HealingSFX

signal critical_hit
signal normal_hit
signal weakness_hit()
signal turn_finished
signal enemy_defeated

func set_stats(value : ClassStats) -> void:
	stats = value
	if not stats is ClassStats: return
	if battle_animations is BattleAnimations: battle_animations.queue_free()
	battle_animations = stats.BattleAnimations.instantiate()
	add_child(battle_animations)
	
func set_defend(value : bool) -> void:
	defend = value
	battle_shield.visible = defend
	if defend == true:
		defend_sfx.play()
		
func take_turn() -> void:
	#print("BattleUnit: take_turn() called for", self)
	if is_player_controlled():
		var selected_action = await ReferenceStash.battle_menu_manager.show_battle_menu()
		perform_action(selected_action)
	else:
		var battle_action = ReferenceStash.ai._select_battle_action(stats)
		perform_action(battle_action)
	emit_signal("turn_finished")
	#print("BattleUnit: turn_finished signal emitted for", self)
	
func is_player_controlled() -> bool:
	return true
	
func perform_action(action) -> void:
	var target = BattleUnit
	if action is RangedBattleAction:
		ranged_attack(target, action)
	elif action is EnemyBattleAction:
		enemy_attack(target, action)
	elif action is BasicBattleAction:
		basic_attack(target, action)
	elif action is Item:
		use_item(target, action)
	await get_tree().create_timer(3.0).timeout
	
func ranged_attack(target : BattleUnit, battle_action : RangedBattleAction) -> void:
	
	battle_animations.play("RangedAnticipation")
	await battle_animations.animation_finished
	
	battle_animations.play("RangedRelease")
	await battle_animations.animation_finished
	var projectile = battle_action.projectile.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = battle_animations.get_emission_position()
	projectile.move_to(target)
	
	await projectile.contact
	
	deal_damage(target, battle_action)
	target.take_hit(self)
	battle_animations.play("Idle")
	
	
func enemy_attack(target : BattleUnit, battle_action : EnemyBattleAction) -> void:
	battle_animations.play("Attack_Anticipation")
	await battle_animations.animation_finished
	
	battle_animations.play("Attack")
	var projectile = battle_action.projectile.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = battle_animations.get_emission_position()
	projectile.move_to(target)
	await projectile.contact
	
	deal_damage(target, battle_action)
	target.take_hit(self)
	
	await battle_animations.animation_finished
	battle_animations.play("Idle")
	
	
func basic_attack(target : BattleUnit, battle_action : BasicBattleAction) -> void:
	
	battle_animations.play("Attack_Anticipation")
	await battle_animations.animation_finished
	
	battle_animations.play("Attack")
	var stationaryattack = battle_action.stationaryattack.instantiate()
	get_tree().current_scene.add_child(stationaryattack)
	stationaryattack.global_position = target.global_position
	#await stationaryattack.contact
	
	deal_damage(target, battle_action)
	target.take_hit(self)
	
	await battle_animations.animation_finished
	battle_animations.play("Idle")
	
	
func use_item(target: BattleUnit, item : Item) -> void:
	
	battle_animations.play("Attack")
	await battle_animations.animation_finished
	stats.health += item.heal_amount
	healing_sfx.play()
	#battle_animations.play("Idle")
	#await battle_animations.animation_finished
	battle_animations.play("Idle")
	emit_signal("turn_finished")
	
	
func deal_damage(target: BattleUnit, battle_action : DamageBattleAction) -> void:
	#print("Attacker's Stats:")
	#print("Attack: ", stats.attack)
	#print("Crit Chance: ", stats.crit_chance)
	
	#print("Defender's Stats:")
	#print("Defense: ", target.stats.defense)
	#print("Weaknesses: ", target.stats.weaknesses)
	
	var base_damage = (((stats.attack*1.1 - (target.stats.defense * 1.1))*battle_action.damage/2))
	#print("Base Damage: ", base_damage)
	var is_weak = target.stats.weaknesses.has(battle_action.element)
	#print("Is Weak: ", is_weak)
	var damage = base_damage
	if is_weak:
		damage *= 2
		#print("Weakness Multiplier Applied")
		weakness_hit.emit()
	var is_critical = randf() < stats.crit_chance
	if is_critical:
		damage *= 2
		#print("Critical Hit Multiplier Applied")
	#print("Final Damage: ", damage)

	var damage_number = damage_number_scene.instantiate()
	add_child(damage_number)
	damage_number.global_position = target.global_position + Vector2(0,-90)
	if is_critical:
		damage_number.set_critical_damage_number(damage, is_weak)
	else:
		damage_number.set_damage_number(damage, is_weak)
	target.stats.health -= damage
	#print("Defender's Health: ", target.stats.health)
	#emit_signal("turn_finished")
func take_hit(attacker: BattleUnit) -> void:
	hit_sfx.play()
	
	var knockback_position := global_position.move_toward(attacker.global_position, -KNOCKBACK_AMOUNT)
	interpolate_position(global_position, knockback_position, .2, Tween.TRANS_CIRC, Tween.EASE_OUT)
	
	if stats.health == 0:
		
		battle_animations.play("Death")
		await battle_animations.animation_finished
		ReferenceStash.turnManager.remove_battle_unit(self)
		emit_signal("enemy_defeated")
		queue_free()
		emit_signal("turn_finished")
		return
	else:
		battle_animations.play("Hit")
		await battle_animations.animation_finished
		battle_animations.play("Idle")
		
	interpolate_position(global_position, root_position, .2, Tween.TRANS_CIRC)
	print("Emitting turn_finished signal.")
	emit_signal("turn_finished")
	
func interpolate_position(start: Vector2, end : Vector2, duration : float, trans : int = Tween.TRANS_LINEAR, easing : int = Tween.EASE_IN_OUT) -> void:
	var tween = create_tween().set_trans(trans).set_ease(easing)
	tween.tween_property(self, "global_position", end, duration).from(start)
	await tween.finished
