# Godot 4.5 / GDScript
# 메인 메뉴: 타이틀 + [게임 시작] 버튼
extends Control
signal request_start_game

var _title: Label
var _start_btn: Button


var _vb

func _init() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0

func _ready() -> void:
	top_level = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	_build_ui()
	_animate_in()

func _build_ui() -> void:
	var center = CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(center)

	var _vb = VBoxContainer.new()
	_vb.alignment = BoxContainer.ALIGNMENT_CENTER
	_vb.add_theme_constant_override("separation", 16)
	_vb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	center.add_child(_vb)

	_title = Label.new()
	_title.text = "MY GODOT GAME"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.add_theme_font_size_override("font_size", 36)
	_vb.add_child(_title)

	_start_btn = Button.new()
	_start_btn.text = "게임 시작"
	_start_btn.custom_minimum_size = Vector2(280, 48)
	_start_btn.pressed.connect(_on_start_pressed)
	_vb.add_child(_start_btn)


func _animate_in() -> void:
	modulate = Color(1, 1, 1, 0)
	var t = create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.25)
func _on_start_pressed() -> void:
	# 안전 가드 + 체이닝 제거(중간 null 방지)
	if is_instance_valid(_vb):
		var t = create_tween()
		t.tween_property(_vb, "scale", Vector2(0.98, 0.98), 0.05)
		t.tween_property(_vb, "scale", Vector2(1, 1), 0.05)
		await t.finished
	request_start_game.emit()
