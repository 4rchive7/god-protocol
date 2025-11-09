extends Node2D
class_name HealthBar

@export var target: Node
@export var width: float = 120.0
@export var height: float = 10.0

func _process(_delta):
	queue_redraw()

func _draw():
	if target == null:
		return
	if not is_instance_valid(target):
		return
	if not target.has_method("get"):  # 안전 체크
		return

	var s = target.get("stats") if target.has_method("get") else null
	if s == null:
		return

	var ratio = 0.0
	if s.max_hp > 0:
		ratio = clamp(float(s.hp) / float(s.max_hp), 0.0, 1.0)

	var bg_rect = Rect2(-width/2, -height/2, width, height)
	draw_rect(bg_rect, Color(0,0,0,0.5), true)
	draw_rect(bg_rect, Color(1,1,1,0.8), false, 1.5)

	var fill_w = width * ratio
	var fill_rect = Rect2(-width/2, -height/2, fill_w, height)
	var col = Color(0.35, 0.9, 0.55)
	if target.has_method("get") and target.get("team_tag") == "enemy":
		col = Color(0.95, 0.45, 0.35)
	draw_rect(fill_rect, col, true)
