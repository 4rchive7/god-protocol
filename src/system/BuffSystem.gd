# Godot 4.5 / GDScript
extends Node
class_name BuffManager

static func apply_temporary_multiplier(ch, conf: Dictionary, duration: float) -> void:
    # conf 예: {"attack_cooldown":0.7, "speed":1.25, "parry_window_add":0.15}
    if ch == null or ch.stats == null:
        return
    var s = ch.stats

    # 백업
    var backup = {
        "attack_cooldown": s.attack_cooldown,
        "speed": s.speed,
        "parry_window": s.parry_window
    }

    # 적용
    if conf.has("attack_cooldown"):
        s.attack_cooldown = max(0.1, s.attack_cooldown * float(conf["attack_cooldown"]))
    if conf.has("speed"):
        s.speed = s.speed * float(conf["speed"])
    if conf.has("parry_window_add"):
        s.parry_window = s.parry_window + float(conf["parry_window_add"])

    # 타이머로 복원
    var timer = ch.get_tree().create_timer(duration)
    timer.timeout.connect(func():
        s.attack_cooldown = backup["attack_cooldown"]
        s.speed = backup["speed"]
        s.parry_window = backup["parry_window"]
    )
