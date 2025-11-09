# Godot 4.5 / GDScript
extends CanvasLayer
class_name GameHUD

var player_ref
var enemy_ref

var lbl_title
var lbl_player
var lbl_enemy
var lbl_tip
var msg_timer = 0.0
var msg_text = ""

func _ready():
    # 간단 텍스트 HUD
    lbl_title = Label.new()
    lbl_title.position = Vector2(24, 16)
    lbl_title.text = "Auto Duel (Cards/Dice → Buff)"
    lbl_title.label_settings = LabelSettings.new()
    add_child(lbl_title)

    lbl_player = Label.new()
    lbl_player.position = Vector2(24, 48)
    add_child(lbl_player)

    lbl_enemy = Label.new()
    lbl_enemy.position = Vector2(24, 72)
    add_child(lbl_enemy)

    lbl_tip = Label.new()
    lbl_tip.position = Vector2(24, 100)
    lbl_tip.text = "SPACE: Player Boost | B/N/M: Enemy Behavior"
    add_child(lbl_tip)

    set_process(true)

func set_targets(p, e):
    player_ref = p
    enemy_ref = e

func flash_msg(t: String):
    msg_text = t
    msg_timer = 1.8

func _process(delta):
    if player_ref and enemy_ref:
        lbl_player.text = "Player HP: %d / %d   Stamina: %.0f" % [player_ref.stats.hp, player_ref.stats.max_hp, player_ref.stats.stamina]
        lbl_enemy.text = "Enemy  HP: %d / %d   Stamina: %.0f" % [enemy_ref.stats.hp, enemy_ref.stats.max_hp, enemy_ref.stats.stamina]

    if msg_timer > 0.0:
        msg_timer -= delta
        lbl_title.text = msg_text
        if msg_timer <= 0.0:
            lbl_title.text = "Auto Duel (Cards/Dice → Buff)"
