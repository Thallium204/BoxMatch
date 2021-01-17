extends Node2D
enum ActionType{ATTACK,MOVE}

export(ActionType) var action_type setget set_action_type
var relative_vector:Vector2 = Vector2.ZERO
var player_node

func set_action_type(new_action_type = ActionType.ATTACK) -> void:
	action_type = new_action_type
	update_ui()

func update_ui():
	match action_type:
		ActionType.ATTACK:
			$sprite.modulate = Color.red
		ActionType.MOVE:
			$sprite.modulate = Color.blue

func initialise(new_action_type:int,new_relative_vector:Vector2):
	set_action_type(new_action_type)
	relative_vector = new_relative_vector
	$sprite/line.points = PoolVector2Array([Vector2.ZERO,-relative_vector])
	update_ui()

func _ready():
	player_node = get_parent().get_parent()

func _on_button_pressed():
	player_node.execute_action(action_type,relative_vector)
