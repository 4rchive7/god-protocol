# Godot 4.5 / GDScript
# 메인: 로딩 → 메뉴 → 게임 전환을 오케스트레이션
extends Node

const LoadingView = preload("res://src/LoadingView.gd")
const MenuView    = preload("res://src/MenuView.gd")
const GameView    = preload("res://src/GameView.gd")

var _current_view: Node = null

func _ready() -> void:
	_show_loading()

func _clear_view() -> void:
	if is_instance_valid(_current_view) and _current_view.get_parent() == self:
		remove_child(_current_view)
	if is_instance_valid(_current_view):
		_current_view.queue_free()
	_current_view = null

func _show_loading() -> void:
	_clear_view()
	var view = LoadingView.new()
	add_child(view)
	_current_view = view
	# 로딩 완료 신호를 받아 메뉴로 전환
	view.loaded.connect(_on_loading_finished)
	view.start()  # 비동기 로딩 시뮬레이션 시작

func _on_loading_finished() -> void:
	_show_menu()

func _show_menu() -> void:
	_clear_view()
	var view = MenuView.new()
	add_child(view)
	_current_view = view
	view.request_start_game.connect(_on_request_start_game)

func _on_request_start_game() -> void:
	_start_game()

func _start_game() -> void:
	_clear_view()
	var view = GameView.new()
	add_child(view)
	_current_view = view
	# 게임에서 메인 메뉴로 돌아가고 싶을 때를 대비해(ESC 등) 신호 연결
	view.request_back_to_menu.connect(_on_request_back_to_menu)

func _on_request_back_to_menu() -> void:
	_show_menu()
