extends Node
class_name BattleManager

var player    # Character
var enemy     # Character

var matchup = {
	"AggressiveBehavior": { "DefensiveBehavior": 0.9, "PowerBehavior": 0.8, "CunningBehavior": 0.7 },
	"DefensiveBehavior": { "AggressiveBehavior": 1.1, "PowerBehavior": 0.9, "CunningBehavior": 0.95 },
	"PowerBehavior":     { "AggressiveBehavior": 1.2, "DefensiveBehavior": 1.1, "CunningBehavior": 0.9 },
	"CunningBehavior":   { "AggressiveBehavior": 1.3, "DefensiveBehavior": 1.05, "PowerBehavior": 1.1 }
}

func set_participants(p, e) -> void:
	player = p
	enemy = e
	if player and enemy:
		player.set_enemy(enemy)
		enemy.set_enemy(player)

func _physics_process(_delta):
	if player == null or enemy == null:
		return

	var p_recent_attack = player.context.get("did_attack", false)
	var e_recent_attack = enemy.context.get("did_attack", false)
	player.context["enemy_recent_attack"] = e_recent_attack
	enemy.context["enemy_recent_attack"] = p_recent_attack
	player.context["did_attack"] = false
	enemy.context["did_attack"] = false

	_apply_matchup_bias(player, enemy)
	_apply_matchup_bias(enemy, player)

	if not is_instance_valid(player) or player.stats.hp <= 0:
		_end_battle("YOU LOSE")
	elif not is_instance_valid(enemy) or enemy.stats.hp <= 0:
		_end_battle("YOU WIN")

func _apply_matchup_bias(src, dst) -> void:
	if src.behavior == null or dst.behavior == null:
		return
	var s = src.behavior.get_class()
	var d = dst.behavior.get_class()
	var bias = 1.0
	if matchup.has(s) and matchup[s].has(d):
		bias = float(matchup[s][d])

	if is_instance_valid(src.hitbox_up):
		src.hitbox_up.damage = int(src.stats.attack_power * bias)
	if is_instance_valid(src.hitbox_mid):
		src.hitbox_mid.damage = int(src.stats.attack_power * bias)
	if is_instance_valid(src.hitbox_down):
		src.hitbox_down.damage = int(src.stats.attack_power * bias)
	if is_instance_valid(src.hitbox_power):
		src.hitbox_power.damage = int(src.stats.attack_power * 1.8 * bias)

func _end_battle(msg: String) -> void:
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.size = Vector2(1280, 720)
	add_child(overlay)

	var label = Label.new()
	label.text = msg + "  (Press Any Key)"
	label.position = Vector2(1280/2 - 120, 720/2 - 12)
	overlay.add_child(label)

	set_process_input(true)
	get_tree().paused = true

func _input(event):
	if get_tree().paused and (event is InputEventKey or event is InputEventMouseButton):
		get_tree().paused = false
		get_tree().reload_current_scene()
