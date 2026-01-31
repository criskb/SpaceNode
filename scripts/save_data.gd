extends Node

const SAVE_PATH := "user://save.json"

var weapon_level := 1
var wing_level := 1
var hull_index := 0
var high_score := 0

func _ready() -> void:
    load_data()

func load_data() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        save_data()
        return

    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return

    var content := file.get_as_text()
    file.close()
    var parsed := JSON.parse_string(content)
    if typeof(parsed) != TYPE_DICTIONARY:
        return

    weapon_level = int(parsed.get("weapon_level", weapon_level))
    wing_level = int(parsed.get("wing_level", wing_level))
    hull_index = int(parsed.get("hull_index", hull_index))
    high_score = int(parsed.get("high_score", high_score))

func save_data() -> void:
    var data := {
        "weapon_level": weapon_level,
        "wing_level": wing_level,
        "hull_index": hull_index,
        "high_score": high_score,
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(data))
    file.close()
