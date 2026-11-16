class_name EnnemyAttack
extends BaseState

enum Phase { PREPARATION, FRAPPE, RECUPERATION }

@export var ennemy : Ennemy
@export var attack_damage: int = 10
@export var preparation_delay: float = 0.15
@export var recovery_delay: float = 0.6

var phase: Phase = Phase.PREPARATION
var anim_ennemy : AnimationPlayer
var elapsedTime : float = 0.0

func enter() -> void:
	anim_ennemy = ennemy.get_animation_player()
	ennemy.velocity.x = 0.0

	if not anim_ennemy.animation_finished.is_connected(_on_animation_finished):
		anim_ennemy.animation_finished.connect(_on_animation_finished)

	start_preparation()
	

func _input(event: InputEvent) -> void:
	pass
	

func handle_inputs(input_event: InputEvent) -> void :	
	pass


func physics_update(delta: float) -> void:
	manageState(delta)


func manageState(delta: float) -> void:
	match phase:
		Phase.PREPARATION:
			preparation(delta)

		Phase.FRAPPE:
			frappe()

		Phase.RECUPERATION:
			recuperation(delta)


func start_preparation() -> void:
	phase = Phase.PREPARATION
	elapsedTime = 0.0
	anim_ennemy.play("Idle")


func preparation(delta: float) -> void:
	if not ennemy.can_attack_player():
		Transitioned.emit(self, "EnnemyChase")
		return

	elapsedTime += delta

	if elapsedTime >= preparation_delay:
		phase = Phase.FRAPPE
		frappe()


func frappe() -> void:
	if anim_ennemy.current_animation == &"Attack":
		return

	ennemy.hitbox.start_attack(attack_damage)
	anim_ennemy.play("Attack")


func _on_animation_finished(animation_name: StringName) -> void:
	if phase != Phase.FRAPPE or animation_name != &"Attack":
		return

	ennemy.hitbox.stop_attack()
	phase = Phase.RECUPERATION
	elapsedTime = 0.0
	anim_ennemy.play("Idle")


func recuperation(delta: float) -> void:
	elapsedTime += delta

	if elapsedTime < recovery_delay:
		return

	if ennemy.can_attack_player():
		start_preparation()
	else:
		Transitioned.emit(self, "EnnemyChase")


func exit() -> void:
	ennemy.hitbox.stop_attack()

	if anim_ennemy.animation_finished.is_connected(_on_animation_finished):
		anim_ennemy.animation_finished.disconnect(_on_animation_finished)