# Godot 4.5 / GDScript
extends Resource
class_name StatBlock

@export var max_hp: int = 100
@export var hp: int = 100
@export var speed: float = 120.0          # 이동/행동 속도 (공격 준비 시간에도 영향)
@export var stamina_max: float = 100.0
@export var stamina: float = 100.0
@export var stamina_recovery: float = 18.0
@export var attack_power: int = 10
@export var attack_cooldown: float = 1.0  # 기본 공격 쿨다운(낮을수록 빠름)
@export var parry_window: float = 0.18    # 패링 가능 시간(히트 시 상태로 판정)
@export var poise: float = 50.0           # 경직/기절 저항
@export var disarm_power: float = 0.0     # 상대 무기탈취 유도력(힘 중심 타입이 높음)

func reset() -> void:
    hp = max_hp
    stamina = stamina_max
