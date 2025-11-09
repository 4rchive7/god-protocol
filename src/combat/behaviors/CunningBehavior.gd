
extends Behavior
class_name CunningBehavior

@export var feint_ratio: float = 0.5
@export var bait_parry_then_punish: bool = true

func decide(delta, self_stats, enemy_stats, context):
    # 영리한 타입: 페인트로 패링 유도 → 패널티 타이밍에 맞춰 카운터
    var enemy_is_parrying = context.get("enemy_parry_state", false)
    if bait_parry_then_punish and enemy_is_parrying:
        # 패링 끝나는 타이밍쯤 카운터
        return { "action":"attack_mid", "intent_time": 0.15, "stamina_cost": 9.0 }

    if randf() < feint_ratio:
        return { "action":"feint", "intent_time": 0.25, "stamina_cost": 3.0 }

    # 라인 랜덤으로 얕은 찌르기 → 틈 보이면 연속
    var lanes = ["attack_up","attack_mid","attack_down"]
    var action = lanes[randi() % lanes.size()]
    return { "action": action, "intent_time": 0.35, "stamina_cost": 7.0 }
