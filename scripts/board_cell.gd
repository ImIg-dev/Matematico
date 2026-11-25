extends Button
@export var board_position : int = 0
@onready var label: Label = $Label

func _ready() -> void:
	label.text = ""
	disabled = 0

func _process(_delta: float) -> void:
	pass

func _on_self_button_up() -> void:
	if not label.text == "":
		return
	disabled = 1
	get_parent().get_parent().get_parent().get_parent().get_parent().cell_pressed(board_position)
	#label.text = str(get_parent().get_parent().get_parent().get_parent().get_parent().number_sequence[get_parent().get_parent().get_parent().get_parent().get_parent().turn-3])
func write_number(second : bool) -> void:
	if not second:
		if get_parent().get_parent().get_parent().get_parent().get_parent().board[board_position] == 0:
			return
		label.text = str(get_parent().get_parent().get_parent().get_parent().get_parent().board[board_position])
	else:
		if get_parent().get_parent().get_parent().get_parent().get_parent().second_board[board_position] == 0:
			return
		label.text = str(get_parent().get_parent().get_parent().get_parent().get_parent().second_board[board_position])
	disabled = 1

func write_number_definite(input) -> void:
	label.text = str(input)
