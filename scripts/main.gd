extends Node

const MENU_SCENE := preload("res://scenes/ui/Menu.tscn")
const BUILDER_SCENE := preload("res://scenes/ui/ShipBuilder.tscn")
const GAME_SCENE := preload("res://scenes/Game.tscn")
const GAME_OVER_SCENE := preload("res://scenes/ui/GameOver.tscn")

var current_screen: Node

func _ready() -> void:
    _show_menu()

func _clear_screen() -> void:
    if current_screen:
        current_screen.queue_free()
        current_screen = null

func _show_menu() -> void:
    _clear_screen()
    var menu := MENU_SCENE.instantiate()
    add_child(menu)
    current_screen = menu
    menu.start_game.connect(_start_game)
    menu.open_builder.connect(_open_builder)
    menu.quit_game.connect(_quit_game)

func _open_builder() -> void:
    _clear_screen()
    var builder := BUILDER_SCENE.instantiate()
    add_child(builder)
    current_screen = builder
    builder.back_to_menu.connect(_show_menu)

func _start_game() -> void:
    _clear_screen()
    var game := GAME_SCENE.instantiate()
    add_child(game)
    current_screen = game
    game.game_over.connect(_show_game_over)

func _show_game_over(score: int) -> void:
    _clear_screen()
    var game_over := GAME_OVER_SCENE.instantiate()
    add_child(game_over)
    current_screen = game_over
    game_over.set_score(score)
    game_over.retry.connect(_start_game)
    game_over.quit_to_menu.connect(_show_menu)

func _quit_game() -> void:
    get_tree().quit()
