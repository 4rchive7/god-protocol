extends Area2D
class_name Hitbox

signal hit_confirmed(target)

@export var damage: int = 10
@export var stun_power: float = 0.0
@export var disarm_power: float = 0.0
@export var owner_team: String = "player"

var shape: CollisionShape2D
var base_offset: Vector2 = Vector2.ZERO   # 원본 오프셋 저장

func _ready():
    shape = CollisionShape2D.new()
    add_child(shape)
    monitoring = false
    monitorable = true
    set_collision_layer_value(2, true) # Hitbox:  Layer2
    set_collision_mask_value(3, true)  # Hurtbox: Layer3
    area_entered.connect(_on_area_entered)

func setup_rect(size: Vector2, offset: Vector2) -> void:
    var rect = RectangleShape2D.new()
    rect.size = size
    shape.shape = rect
    base_offset = offset
    shape.position = base_offset

func set_dir(dir: int) -> void:
    # dir: +1(오른쪽 공격), -1(왼쪽 공격)
    if shape:
        shape.position = Vector2(base_offset.x * dir, base_offset.y)

func swing(duration: float) -> void:
    monitoring = true
    await get_tree().create_timer(duration).timeout
    monitoring = false

func _on_area_entered(a: Area2D) -> void:
    if a is Hurtbox:
        var hb = a as Hurtbox
        if hb.team_tag == owner_team:
            return # 아군 무시
        var owner_node = hb.get_parent()
        if owner_node and owner_node.has_method("apply_hit"):
            owner_node.apply_hit(damage, stun_power, disarm_power)
            emit_signal("hit_confirmed", owner_node)
