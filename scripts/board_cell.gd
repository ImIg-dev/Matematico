extends Button
@export var board_position : int = 0
@export var save_no : int = 0
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
	label.text = str(get_parent().get_parent().get_parent().get_parent().get_parent().number_sequence[get_parent().get_parent().get_parent().get_parent().get_parent().turn-2])
	if not get_parent().get_parent().get_parent().get_parent().get_parent().second_board_opened:
		get_parent().get_parent().get_parent().get_parent().get_parent().board[board_position] = get_parent().get_parent().get_parent().get_parent().get_parent().number_sequence[get_parent().get_parent().get_parent().get_parent().get_parent().turn-2]
		get_parent().get_parent().get_parent().get_parent().get_parent().count_points()
		if get_parent().get_parent().get_parent().get_parent().get_parent().round_no == 3:
			get_parent().get_parent().get_parent().get_parent().get_parent().second_board_opened = 1
		else:
			get_parent().get_parent().get_parent().get_parent().get_parent().turn += 1
	else:
		get_parent().get_parent().get_parent().get_parent().get_parent().second_board[board_position] = get_parent().get_parent().get_parent().get_parent().get_parent().number_sequence[get_parent().get_parent().get_parent().get_parent().get_parent().turn-2]
		get_parent().get_parent().get_parent().get_parent().get_parent().turn += 1
		get_parent().get_parent().get_parent().get_parent().get_parent().count_points_second()
		get_parent().get_parent().get_parent().get_parent().get_parent().second_board_opened = 0
	if Saves.timed_moves:
		get_parent().get_parent().get_parent().get_parent().get_parent().timer.start(15)
	if Saves.ongoing_runs.size() < save_no+1: Saves.ongoing_runs.append([])
	Saves.ongoing_runs[save_no] = [get_parent().get_parent().get_parent().get_parent().get_parent().custom_seed, get_parent().get_parent().get_parent().get_parent().get_parent().board, get_parent().get_parent().get_parent().get_parent().get_parent().second_board, get_parent().get_parent().get_parent().get_parent().get_parent().pointsI, get_parent().get_parent().get_parent().get_parent().get_parent().pointsII, get_parent().get_parent().get_parent().get_parent().get_parent().pointsIIIa, get_parent().get_parent().get_parent().get_parent().get_parent().pointsIIIb, get_parent().get_parent().get_parent().get_parent().get_parent().points, get_parent().get_parent().get_parent().get_parent().get_parent().board_points, get_parent().get_parent().get_parent().get_parent().get_parent().second_board_points, get_parent().get_parent().get_parent().get_parent().get_parent().turn, get_parent().get_parent().get_parent().get_parent().get_parent().round_no, get_parent().get_parent().get_parent().get_parent().get_parent().second_board_opened]
	Saves.save_data()
