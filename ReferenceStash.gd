extends Node

var turnManager := TurnManager.new()
var asyncTurnPool := AsyncTurnPool.new()
var elizabethStats : PlayerClassStats = load("res://Class Stats/ElizabethClassStats.tres")
var inventory : Inventory = load("res://Items/Inventory.tres")
var random_encounters := []
var encounter_class : ClassStats
var player: OverworldPlayer
