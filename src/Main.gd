# Godot 4.5 / GDScript
extends Node2D

const RES_W = 1280
const RES_H = 720

var battle_manager
var player
var enemy
var hud

func _ready():
	if Engine.is_editor_hint() == false:
		DisplayServer.window_set_size(Vector2i(RES_W, RES_H))

	_build_background()

	var PlayerScene = load("res://src/combat/Player.gd")
	var EnemyScene  = load("res://src/combat/Enemy.gd")
	var StatBlock = load("res://src/combat/StatBlock.gd")
	var AggressiveBehavior = load("res://src/combat/behaviors/AggressiveBehavior.gd")
	var CunningBehavior = load("res://src/combat/behaviors/CunningBehavior.gd")

	player = PlayerScene.new()
	enemy = EnemyScene.new()

	# 플레이어 스탯/성향
	player.stats = StatBlock.new()
	player.stats.max_hp = 120
	player.stats.hp = 120
	player.stats.speed = 180.0
	player.stats.attack_power = 12
	player.stats.attack_cooldown = 0.9
	player.stats.poise = 60.0
	player.stats.disarm_power = 6.0
	player.behavior = AggressiveBehavior.new()

	# 적 스탯/성향
	enemy.stats = StatBlock.new()
	enemy.stats.max_hp = 140
	enemy.stats.hp = 140
	enemy.stats.speed = 150.0
	enemy.stats.attack_power = 14
	enemy.stats.attack_cooldown = 1.1
	enemy.stats.poise = 70.0
	enemy.stats.disarm_power = 12.0
	enemy.behavior = CunningBehavior.new()

	add_child(player)
	add_child(enemy)

	# 가까운 시작 위치
	player.position = Vector2(RES_W * 0.42, RES_H * 0.62)
	enemy.position  = Vector2(RES_W * 0.58, RES_H * 0.62)

	_add_name_label(player, "PLAYER")
	_add_name_label(enemy, "ENEMY")

	battle_manager = load("res://src/combat/BattleManager.gd").new()
	add_child(battle_manager)
	battle_manager.set_participants(player, enemy)

	hud = load("res://src/ui/GameHUD.gd").new()
	add_child(hud)
	hud.set_targets(player, enemy)

	set_process_input(true)

func _add_name_label(f, text):
	var lbl = Label.new()
	lbl.text = text
	lbl.position = Vector2(-24, -110)
	lbl.modulate = Color(0.7, 0.9, 1.0) if f.team_tag == "player" else Color(1.0, 0.8, 0.6)
	f.add_child(lbl)

func _build_background():
	var sky = ColorRect.new()
	sky.color = Color(0.12, 0.14, 0.18)
	sky.size = Vector2(RES_W, RES_H)
	add_child(sky)
	sky.z_index = -10

	var floor = ColorRect.new()
	floor.color = Color(0.08, 0.09, 0.11)
	floor.size = Vector2(RES_W, 140)
	floor.position = Vector2(0, RES_H - 140)
	add_child(floor)
	floor.z_index = -5

func _input(event):
	if event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
		BuffManager.apply_temporary_multiplier(player, {
			"attack_cooldown": 0.7,
			"speed": 1.25,
			"parry_window_add": 0.15
		}, 3.0)
		hud.flash_msg("Boost: SPD/AS ↑ for 3s")

	if event is InputEventKey and event.pressed:
		var DefensiveBehavior = load("res://src/combat/behaviors/DefensiveBehavior.gd")
		var PowerBehavior = load("res://src/combat/behaviors/PowerBehavior.gd")
		var CunningBehavior = load("res://src/combat/behaviors/CunningBehavior.gd")
		match event.keycode:
			KEY_B:
				enemy.behavior = DefensiveBehavior.new()
				hud.flash_msg("Enemy → Defensive")
			KEY_N:
				enemy.behavior = PowerBehavior.new()
				hud.flash_msg("Enemy → Power")
			KEY_M:
				enemy.behavior = CunningBehavior.new()
				hud.flash_msg("Enemy → Cunning")
