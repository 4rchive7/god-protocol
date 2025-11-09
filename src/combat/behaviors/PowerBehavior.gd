extends Behavior
class_name PowerBehavior

@export var windup_time: float = 0.6
@export var heavy_stamina_cost: float = 22.0

func decide(delta, self_stats, enemy_stats, context):
    # 힘 중심: 강공격 위주(기절/무기탈취 확률↑), 빈도는 낮지만 치명적
    # 스태미나 부족 시 방어로 여유를 확보

    if self_stats.stamina < heavy_stamina_cost:
        return { "action":"guard", "intent_time": 0.6, "stamina_cost": 0.0 }

    return { "action":"power_attack", "intent_time": windup_time, "stamina_cost": heavy_stamina_cost }
