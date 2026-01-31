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

func _ready() -> void:
    weapon_level = SaveData.weapon_level
    wing_level = SaveData.wing_level
    hull_index = SaveData.hull_index
    _refresh_labels()

    weapon_minus.pressed.connect(func(): _change_level("weapon", -1))
    weapon_plus.pressed.connect(func(): _change_level("weapon", 1))
    wing_minus.pressed.connect(func(): _change_level("wing", -1))
    wing_plus.pressed.connect(func(): _change_level("wing", 1))
    hull_prev.pressed.connect(func(): _change_hull(-1))
    hull_next.pressed.connect(func(): _change_hull(1))
    confirm_button.pressed.connect(_confirm)
    back_button.pressed.connect(func(): back_to_menu.emit())

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

func _confirm() -> void:
    SaveData.weapon_level = weapon_level
    SaveData.wing_level = wing_level
    SaveData.hull_index = hull_index
    SaveData.save_data()
    back_to_menu.emit()
