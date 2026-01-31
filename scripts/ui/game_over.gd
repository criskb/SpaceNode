extends Control

signal retry
signal quit_to_menu

@onready var score_label: Label = $Center/VBox/ScoreLabel
@onready var retry_button: Button = $Center/VBox/RetryButton
@onready var quit_button: Button = $Center/VBox/QuitButton

func _ready() -> void:
    retry_button.pressed.connect(func(): retry.emit())
    quit_button.pressed.connect(func(): quit_to_menu.emit())

func set_score(score: int) -> void:
    score_label.text = "Score: %s" % score
