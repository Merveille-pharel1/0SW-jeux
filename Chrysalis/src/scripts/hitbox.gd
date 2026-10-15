class_name Hitbox
extends Area2D

var already_hit: Array[Hurtbox] = []
var damage: int


func _ready() -> void:
    monitoring = false
    area_entered.connect(_on_area_entered)
    

func start_attack(attack_damage: int) -> void:
    damage = attack_damage
    already_hit.clear()
    monitoring = true


func stop_attack() -> void:
    monitoring = false


func _on_area_entered(area: Area2D) -> void:
    if not area is Hurtbox:
        return

    var hurtbox := area as Hurtbox

    if hurtbox in already_hit:
        return

    already_hit.append(hurtbox)
    hurtbox.receive_damage(damage)