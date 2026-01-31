extends Control

signal start_game
signal open_builder
signal quit_game

@onready var play_button: Button = $Center/VBox/PlayButton
@onready var builder_button: Button = $Center/VBox/BuilderButton
@onready var quit_button: Button = $Center/VBox/QuitButton

func _ready() -> void:
    play_button.pressed.connect(func(): start_game.emit())
    builder_button.pressed.connect(func(): open_builder.emit())
    quit_button.pressed.connect(func(): quit_game.emit())
