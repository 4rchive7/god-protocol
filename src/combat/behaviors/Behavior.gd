# 전략(성향) 인터페이스
extends Resource
class_name Behavior

# 행동 결과 구조체 비슷한 딕셔너리 반환
# { action: "wait"|"attack_up"|"attack_mid"|"attack_down"|"feint"|"guard"|"power_attack"|"parry_on"
#   intent_time: float,   # 다음 행동까지 대기/준비 시간
#   stamina_cost: float }
func decide(delta: float, self_stats: StatBlock, enemy_stats: StatBlock, context: Dictionary) -> Dictionary:
    return { "action":"wait", "intent_time": 0.2, "stamina_cost": 0.0 }
