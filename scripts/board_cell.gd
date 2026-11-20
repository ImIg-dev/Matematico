extends TextureButton
@export var board_position : int = 0
@onready var label: Label = $Label

func _ready() -> void:
	label.text = ""

func _process(_delta: float) -> void:
	pass

func _on_self_pressed() -> void:
	print(get_parent().get_parent().get_parent().get_parent().get_parent().second_board_opened)
	if not label.text == "":
		return
	label.text = str(get_parent().get_parent().get_parent().get_parent().get_parent().number_sequence[get_parent().get_parent().get_parent().get_parent().get_parent().turn-2])
	if not get_parent().get_parent().get_parent().get_parent().get_parent().second_board_opened:
		get_parent().get_parent().get_parent().get_parent().get_parent().board[board_position] = get_parent().get_parent().get_parent().get_parent().get_parent().number_sequence[get_parent().get_parent().get_parent().get_parent().get_parent().turn-2]
		get_parent().get_parent().get_parent().get_parent().get_parent().count_points()
		if get_parent().get_parent().get_parent().get_parent().get_parent().round_no == 3:
			get_parent().get_parent().get_parent().get_parent().get_parent().second_board_opened = 1
		else:
			get_parent().get_parent().get_parent().get_parent().get_parent().turn += 1
		return
	else:
		get_parent().get_parent().get_parent().get_parent().get_parent().second_board[board_position] = get_parent().get_parent().get_parent().get_parent().get_parent().number_sequence[get_parent().get_parent().get_parent().get_parent().get_parent().turn-2]
		get_parent().get_parent().get_parent().get_parent().get_parent().turn += 1
		get_parent().get_parent().get_parent().get_parent().get_parent().count_points_second()
		get_parent().get_parent().get_parent().get_parent().get_parent().second_board_opened = 0
		return
