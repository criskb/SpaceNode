extends Control

signal back_to_menu

const HULL_STYLES := ["A", "B", "C"]

@onready var weapon_value: Label = $Panel/VBox/WeaponControls/WeaponValue
@onready var wing_value: Label = $Panel/VBox/WingControls/WingValue
@onready var hull_value: Label = $Panel/VBox/HullControls/HullValue

@onready var weapon_minus: Button = $Panel/VBox/WeaponControls/WeaponMinus
@onready var weapon_plus: Button = $Panel/VBox/WeaponControls/WeaponPlus
@onready var wing_minus: Button = $Panel/VBox/WingControls/WingMinus
@onready var wing_plus: Button = $Panel/VBox/WingControls/WingPlus
@onready var hull_prev: Button = $Panel/VBox/HullControls/HullPrev
@onready var hull_next: Button = $Panel/VBox/HullControls/HullNext
@onready var confirm_button: Button = $Panel/VBox/ConfirmButton
@onready var back_button: Button = $BackButton

var weapon_level := 1
var wing_level := 1
var hull_index := 0
var preview_time := 0.0

func _ready() -> void:
    weapon_level = SaveData.weapon_level
    wing_level = SaveData.wing_level
    hull_index = SaveData.hull_index
    _refresh_labels()
    set_process(true)
    queue_redraw()

    weapon_minus.pressed.connect(func(): _change_level("weapon", -1))
    weapon_plus.pressed.connect(func(): _change_level("weapon", 1))
    wing_minus.pressed.connect(func(): _change_level("wing", -1))
    wing_plus.pressed.connect(func(): _change_level("wing", 1))
    hull_prev.pressed.connect(func(): _change_hull(-1))
    hull_next.pressed.connect(func(): _change_hull(1))
    confirm_button.pressed.connect(_confirm)
    back_button.pressed.connect(func(): back_to_menu.emit())

func _process(delta: float) -> void:
    preview_time += delta
    queue_redraw()

func _change_level(kind: String, delta: int) -> void:
    if kind == "weapon":
        weapon_level = clamp(weapon_level + delta, 1, 5)
    elif kind == "wing":
        wing_level = clamp(wing_level + delta, 1, 5)
    _refresh_labels()

func _change_hull(delta: int) -> void:
    hull_index = wrapi(hull_index + delta, 0, HULL_STYLES.size())
    _refresh_labels()

func _refresh_labels() -> void:
    weapon_value.text = str(weapon_level)
    wing_value.text = str(wing_level)
    hull_value.text = HULL_STYLES[hull_index]
    queue_redraw()

func _confirm() -> void:
    SaveData.weapon_level = weapon_level
    SaveData.wing_level = wing_level
    SaveData.hull_index = hull_index
    SaveData.save_data()
    back_to_menu.emit()

func _draw() -> void:
    var color_palette: Array[Color] = [
        Color(0.2, 0.7, 1.0),
        Color(0.6, 0.4, 1.0),
        Color(0.2, 1.0, 0.6)
    ]
    var base_color: Color = color_palette[hull_index % color_palette.size()]
    var wing_color: Color = base_color.lightened(0.2)
    var preview_origin := Vector2(size.x * 0.2, size.y * 0.55)
    var scale_factor := 2.2
    var hull_points := PackedVector2Array([
        Vector2(0, -20),
        Vector2(14, 16),
        Vector2(0, 8),
        Vector2(-14, 16)
    ])
    for i in range(hull_points.size()):
        hull_points[i] = preview_origin + hull_points[i] * scale_factor
    draw_polygon(
        hull_points,
        PackedColorArray([base_color, base_color, base_color, base_color])
    )
    draw_line(
        preview_origin + Vector2(-16, 8) * scale_factor,
        preview_origin + Vector2(-32, 20) * scale_factor,
        wing_color,
        4
    )
    draw_line(
        preview_origin + Vector2(16, 8) * scale_factor,
        preview_origin + Vector2(32, 20) * scale_factor,
        wing_color,
        4
    )
    var flame := 1.0 + sin(preview_time * 10.0) * 0.2
    draw_polygon(
        PackedVector2Array([
            preview_origin + Vector2(-6, 18) * scale_factor,
            preview_origin + Vector2(0, 32 * flame) * scale_factor,
            preview_origin + Vector2(6, 18) * scale_factor
        ]),
        PackedColorArray([Color(1.0, 0.6, 0.2), Color(1.0, 0.9, 0.5), Color(1.0, 0.6, 0.2)])
    )
