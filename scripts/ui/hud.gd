extends CanvasLayer
class_name Hud

@onready var health_bar: ProgressBar = $HealthBar
@onready var score_label: Label = $ScoreLabel
@onready var dialog_label: RichTextLabel = $DialogPanel/DialogLabel

func set_health(value: int, max_value: int) -> void:
    health_bar.max_value = max_value
    health_bar.value = value

func set_score(score: int) -> void:
    score_label.text = "Score: %s" % score

func show_dialog(text: String) -> void:
    dialog_label.text = text

func clear_dialog() -> void:
    dialog_label.text = ""
