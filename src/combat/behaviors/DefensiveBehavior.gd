extends Behavior
class_name DefensiveBehavior

@export var parry_bias: float = 0.6          # 패링 시도 성향
@export var counter_after_parry: bool = true

func decide(delta, self_stats, enemy_stats, context):
	# 상대가 최근 공격을 시도했다고 컨텍스트가 알려주면 패링/카운터를 노림
	var enemy_recent_attack = context.get("enemy_recent_attack", false)
	if enemy_recent_attack and randf() < parry_bias:
		return { "action":"parry_on", "intent_time": self_stats.parry_window, "stamina_cost": 5.0 }

	# 체력/스태미나 회복을 조금 더 우선
	var need_recover = self_stats.stamina < self_stats.stamina_max * 0.5
	if need_recover:
		return { "action":"guard", "intent_time": 0.5, "stamina_cost": 0.0 }

	# 찬스에 한방(중단/하단 위주)
	# var action = randf() < 0.5 ? "attack_mid" : "attack_down"
	var action = "attack_down" if randf() < 0.5 else "attack_mid"

	return { "action": action, "intent_time": self_stats.attack_cooldown * 1.1, "stamina_cost": 10.0 }
