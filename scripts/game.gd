extends Node2D

signal game_over(score: int)

const PLAYER_SCENE := preload("res://scenes/entities/Player.tscn")
const BULLET_SCENE := preload("res://scenes/entities/Bullet.tscn")
const ENEMY_SCENE := preload("res://scenes/entities/Enemy.tscn")
const ASTEROID_SCENE := preload("res://scenes/entities/Asteroid.tscn")
const BOSS_SCENE := preload("res://scenes/entities/Boss.tscn")
const POWER_UP_SCENE := preload("res://scenes/entities/PowerUp.tscn")
const HEALTH_ITEM_SCENE := preload("res://scenes/entities/HealthItem.tscn")

@onready var hud: Hud = $Hud

var player: Player
var score := 0
var level := 1
var boss_spawned := false

var enemy_timer := Timer.new()
var asteroid_timer := Timer.new()
var powerup_timer := Timer.new()

var dialog_queue: Array[String] = []
var dialog_timer := 0.0
var dialog_clear_timer := 0.0

func _ready() -> void:
    randomize()
    _setup_player()
    _setup_timers()
    _queue_dialog("Incoming transmission... Stay sharp, pilot.")

func _setup_player() -> void:
    player = PLAYER_SCENE.instantiate() as Player
    if player == null:
        push_error("Player scene failed to instantiate.")
        return
    add_child(player)
    var viewport_size := get_viewport_rect().size
    player.global_position = Vector2(viewport_size.x * 0.5, viewport_size.y - 120)
    player.weapon_level = SaveData.weapon_level
    player.wing_level = SaveData.wing_level
    player.hull_index = SaveData.hull_index
    player.max_health = 100 + player.hull_index * 20
    player.health = player.max_health
    player.fired.connect(_spawn_bullet)
    player.died.connect(_handle_game_over)
    player.took_damage.connect(_on_player_damage)
    hud.set_health(player.health, player.max_health)
    hud.set_score(score)

func _setup_timers() -> void:
    enemy_timer.wait_time = 1.1
    enemy_timer.one_shot = false
    enemy_timer.timeout.connect(_spawn_enemy)
    add_child(enemy_timer)
    enemy_timer.start()

    asteroid_timer.wait_time = 2.4
    asteroid_timer.one_shot = false
    asteroid_timer.timeout.connect(_spawn_asteroid)
    add_child(asteroid_timer)
    asteroid_timer.start()

    powerup_timer.wait_time = 8.0
    powerup_timer.one_shot = false
    powerup_timer.timeout.connect(_spawn_powerup)
    add_child(powerup_timer)
    powerup_timer.start()

func _process(delta: float) -> void:
    _update_dialog(delta)

func _update_dialog(delta: float) -> void:
    if dialog_queue.is_empty():
        if dialog_clear_timer > 0.0:
            dialog_clear_timer -= delta
            if dialog_clear_timer <= 0.0:
                hud.clear_dialog()
        return
    dialog_timer -= delta
    if dialog_timer <= 0.0:
        var text := dialog_queue.pop_front()
        hud.show_dialog(text)
        dialog_timer = 3.0
        dialog_clear_timer = 3.0

func _queue_dialog(message: String) -> void:
    dialog_queue.append(message)
    if dialog_timer <= 0.0:
        dialog_timer = 0.1

func _spawn_enemy() -> void:
    var enemy := ENEMY_SCENE.instantiate()
    add_child(enemy)
    var viewport_size := get_viewport_rect().size
    enemy.global_position = Vector2(randf_range(40, viewport_size.x - 40), -30)
    enemy.speed = randf_range(120, 200) + (level * 5)
    enemy.destroyed.connect(_on_enemy_destroyed)

func _spawn_asteroid() -> void:
    var asteroid := ASTEROID_SCENE.instantiate()
    add_child(asteroid)
    var viewport_size := get_viewport_rect().size
    asteroid.global_position = Vector2(randf_range(40, viewport_size.x - 40), -40)
    asteroid.speed = randf_range(90, 160) + (level * 4)
    asteroid.destroyed.connect(_on_enemy_destroyed)

func _spawn_powerup() -> void:
    var pickup_scene := randf() < 0.6 ? POWER_UP_SCENE : HEALTH_ITEM_SCENE
    var pickup := pickup_scene.instantiate()
    add_child(pickup)
    var viewport_size := get_viewport_rect().size
    pickup.global_position = Vector2(randf_range(40, viewport_size.x - 40), -20)
    pickup.collected.connect(_on_pickup_collected)

func _spawn_boss() -> void:
    var boss := BOSS_SCENE.instantiate()
    add_child(boss)
    var viewport_size := get_viewport_rect().size
    boss.global_position = Vector2(viewport_size.x * 0.5, -80)
    boss.destroyed.connect(_on_boss_destroyed)
    boss_spawned = true
    _queue_dialog("Warning: Heavy target inbound!")

func _spawn_bullet(origin: Vector2, direction: Vector2, damage: int) -> void:
    var bullet := BULLET_SCENE.instantiate()
    add_child(bullet)
    bullet.global_position = origin
    bullet.velocity = direction.normalized() * bullet.speed
    bullet.damage = damage

func _on_enemy_destroyed(points: int) -> void:
    score += points
    hud.set_score(score)
    _update_level()

func _on_boss_destroyed(points: int) -> void:
    score += points
    hud.set_score(score)
    boss_spawned = false
    _queue_dialog("Boss neutralized. Keep going!")

func _on_pickup_collected(pickup_type: String) -> void:
    if pickup_type == "power":
        player.apply_power_up()
        _queue_dialog("Weapon systems upgraded.")
    elif pickup_type == "health":
        player.heal(25)
        _queue_dialog("Hull integrity restored.")
    hud.set_health(player.health, player.max_health)

func _on_player_damage() -> void:
    hud.set_health(player.health, player.max_health)

func _update_level() -> void:
    var new_level := int(score / 500) + 1
    if new_level > level:
        level = new_level
        enemy_timer.wait_time = max(0.6, enemy_timer.wait_time - 0.05)
        asteroid_timer.wait_time = max(1.2, asteroid_timer.wait_time - 0.1)
        _queue_dialog("Level %d reached." % level)

    if level >= 5 and not boss_spawned:
        _spawn_boss()

func _handle_game_over() -> void:
    enemy_timer.stop()
    asteroid_timer.stop()
    powerup_timer.stop()

    if score > SaveData.high_score:
        SaveData.high_score = score
        SaveData.save_data()

    await get_tree().create_timer(1.0).timeout
    game_over.emit(score)
