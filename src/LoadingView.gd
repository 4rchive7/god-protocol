# Godot 4.5 / GDScript
# 로딩 화면: ProgressBar + 텍스트, 로딩 완료 시 'loaded' 신호 발신
extends Control
signal loaded

var _progress_bar: ProgressBar
var _label: Label
var _tween: Tween
var _progress: float = 0.0
var _is_running: bool = false

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
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_level = true
	set_anchors_preset(Control.PRESET_FULL_RECT)
	size = get_viewport_rect().size
	_build_ui()

func _build_ui() -> void:
	var center = CenterContainer.new()
	center.top_level = false
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(center)

	var vb = VBoxContainer.new()
	vb.alignment = BoxContainer.ALIGNMENT_CENTER
	vb.add_theme_constant_override("separation", 12)
	vb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	vb.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	center.add_child(vb)

	_label = Label.new()
	_label.text = "로딩 중..."
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(_label)

	_progress_bar = ProgressBar.new()
	_progress_bar.min_value = 0
	_progress_bar.max_value = 100
	_progress_bar.value = 0
	_progress_bar.custom_minimum_size = Vector2(360, 24)
	vb.add_child(_progress_bar)



func start() -> void:
	if _is_running:
		return
	_is_running = true
	_tween = create_tween()
	_tween.tween_method(_set_progress, 0.0, 100.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_tween.finished.connect(_on_tween_done)

func _set_progress(v: float) -> void:
	_progress = v
	if is_instance_valid(_progress_bar):
		_progress_bar.value = v
	if is_instance_valid(_label):
		_label.text = "로딩 중... %d%%" % int(v)

func _on_tween_done() -> void:
	_label.text = "완료!"
	await get_tree().create_timer(0.2).timeout
	loaded.emit()
