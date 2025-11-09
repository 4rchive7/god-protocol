extends Area2D
class_name Hurtbox

@export var team_tag: String = "player"

func _ready():
    monitoring = true
    monitorable = true
    # Hurtbox는 레이어 3, 마스크 2 (Hitbox가 레이어2이므로 서로 감지)
    set_collision_layer_value(3, true)
    set_collision_mask_value(2, true)
