extends Behavior
class_name AggressiveBehavior

@export var chain_until_low_stamina: bool = true
@export var prefer_high_line_ratio: float = 0.34
@export var prefer_mid_line_ratio: float = 0.33
@export var prefer_low_line_ratio: float = 0.33

func decide(delta, self_stats, enemy_stats, context):
    var stamina_low = self_stats.stamina < self_stats.stamina_max * 0.15
    if stamina_low and chain_until_low_stamina:
        return { "action":"guard", "intent_time": 0.35, "stamina_cost": 0.0 }

    # 공격 위주: 쿨이 되면 바로 공격, 라인은 가중 랜덤
    var r = randf()
    var action = "attack_up"
    if r < prefer_high_line_ratio:
        action = "attack_up"
    elif r < prefer_high_line_ratio + prefer_mid_line_ratio:
        action = "attack_mid"
    else:
        action = "attack_down"

    return {
        "action": action,
        "intent_time": max(0.05, self_stats.attack_cooldown * (1.0 - self_stats.speed / 600.0)),
        "stamina_cost": 12.0
    }
