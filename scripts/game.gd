extends Control
var board : Array[int] = []
var second_board : Array[int] = []
@onready var board_grid: GridContainer = $MarginContainer/VBoxContainer/Board/GridContainer
@onready var second_board_grid: GridContainer = $MarginContainer/VBoxContainer/Board2/GridContainer
const board_size := 5 #THIS SHOULD BE 5!
const max_number := 13 #THIS SHOULD BE 13!
var no_of_number_sets := 4 #THIS SHOULD BE 4!
@export var number_sequence : Array[int] = []
@onready var timer: Timer = $Timer
@onready var mode: Label = $MarginContainer/VBoxContainer/Label
@onready var seed_selection: ColorRect = $SeedSelection
@onready var final_score: ColorRect = $FinalScore
var round_no : int = 0
var turn : int = 0
var round_greek : String = "I"
var board_cell := preload("res://scenes/board_cell.tscn")
@export var custom_seed : int
var board_points : int = 0
var second_board_points : int = 0
var points : int = 0
var waiting : bool = 0
var second_board_opened : bool = 0
var old_text := ""

func _ready() -> void:
	seed_selection.visible = 1
	final_score.visible = 0

func _process(_delta: float) -> void:
	mode.text = "seed: %s\n" % custom_seed
	if round_no == 1:
		mode.text += "I: MAXIMUM"
		$MarginContainer/VBoxContainer/Board.visible = 1
		$MarginContainer/VBoxContainer/Board2.visible = 0
	elif round_no == 2:
		mode.text += "II: MINIMUM"
		$MarginContainer/VBoxContainer/Board.visible = 1
		$MarginContainer/VBoxContainer/Board2.visible = 0
	elif round_no == 3 and not second_board_opened:
		mode.text += "IIIa: MAXIMUM"
		$MarginContainer/VBoxContainer/Board.visible = 1
		$MarginContainer/VBoxContainer/Board2.visible = 0
	elif round_no == 3 and second_board_opened:
		mode.text += "IIIb: MINIMUM"
		$MarginContainer/VBoxContainer/Board.visible = 0
		$MarginContainer/VBoxContainer/Board2.visible = 1
	if not seed_selection.visible and turn <= board_size*board_size+1:
		$MarginContainer/VBoxContainer/HUD/HBoxContainer/CurrentNumber.text = str(number_sequence[turn-2])
		$MarginContainer/VBoxContainer/HUD/HBoxContainer/RoundTurn.text = "%s\n%s/%s" % [round_greek, turn, board_size*board_size]
		if round_no == 1:
			$MarginContainer/VBoxContainer/HUD/HBoxContainer/Points.text = "%s+%s" % [points, board_points]
		elif round_no == 2:
			$MarginContainer/VBoxContainer/HUD/HBoxContainer/Points.text = "%s-2*%s" % [points, board_points]
		elif round_no == 3:
			$MarginContainer/VBoxContainer/HUD/HBoxContainer/Points.text = "%s+%s-2*%s" % [points, board_points, second_board_points]
	if turn == board_size*board_size+1:
		turn += 1
		round_over()
	if Input.is_anything_pressed() and waiting:
		waiting = 0
		generate_numbers()
	if Input.is_anything_pressed() and final_score.visible:
		get_tree().reload_current_scene()

func generate_numbers() -> void:
	board = []
	second_board = []
	number_sequence = []
	var amplifier : int = (round_no-1)*10000
	while 1==1:
		if no_of_number_sets*13 >= board_size*board_size:
			break
		print("WARN: Selected number of sets is insufficient for covering the board, adding an extra set...")
		no_of_number_sets += 1
	var number_usage : Array[int] = []
	var overuse_index : int = 1
	print("Generating numbers (1-%s) from %s sets for a %s by %s board using the seed %s..." % [max_number, no_of_number_sets, board_size, board_size, custom_seed])
	for i in max_number:
		number_usage.append(0)
	for i in board_size*board_size:
		seed(custom_seed+i+amplifier)
		board.append(0)
		while 1==1:
			var rand_no := randi_range(1, max_number)
			if number_usage[rand_no-1] < no_of_number_sets:
				number_usage[rand_no-1] += 1
				number_sequence.append(rand_no)
				break
			seed(custom_seed+(board_size*board_size)+overuse_index+amplifier)
			overuse_index += 1
	start_round()

func start_round() -> void:
	board_points = 0
	turn = 1
	round_no += 1
	if round_no <= 1:
		round_greek = "I"
	elif round_no == 2:
		round_greek = "II"
	elif round_no >= 3:
		round_greek = "III"
	if round_no == 3:
		second_board = board.duplicate(true)
	for i in board_grid.get_child_count():
		board_grid.get_child(i).queue_free()
	for i in second_board_grid.get_child_count():
		second_board_grid.get_child(i).queue_free()
	board_grid.columns = board_size
	second_board_grid.columns = board_size
	for i in board_size*board_size:
		var new_cell = board_cell.instantiate()
		board_grid.add_child(new_cell)
		new_cell.name = "Cell " + str(i+1)
		new_cell.board_position = i
	for i in board_size*board_size:
		var new_cell = board_cell.instantiate()
		second_board_grid.add_child(new_cell)
		new_cell.name = "Cell" + str(i+1)
		new_cell.board_position = i
		
func count_points() -> void:
	print(board)
	board_points = 0
	var numbers_to_count : Array[int] = []
	var pairs : int = 0
	var threes : int = 0
	var heatmap : Array[int] = []
	var nos_in_row : int = 0
	for i in board_size+board_size+2:
		pairs = 0; threes = 0; heatmap = []; numbers_to_count = []; nos_in_row = 0
		if i < board_size: #ROWS
			for j in board_size:
				numbers_to_count.append(board[(i*5)+j])
		elif i < 2*board_size: #COLUMNS
			for j in board_size:
				numbers_to_count.append(board[(i-board_size)+j*5])
		elif i == 2*board_size: #TOP-LEFT DIAGONAL
			for j in board_size:
				numbers_to_count.append(board[j*6])
		else: #TOP-RIGHT DIAGONAL
			for j in board_size:
				numbers_to_count.append(board[4+j*4])
		for j in max_number+1:
			heatmap.append(0)
		for cell in numbers_to_count.size():
			heatmap[numbers_to_count[cell]] += 1
		for number in heatmap.size():
			if number == 0:
				nos_in_row = 0
				continue
			if heatmap[number] > 0:
				nos_in_row += 1
			elif nos_in_row == 3:
				board_points += 1
				nos_in_row = 0
			elif nos_in_row == 4:
				board_points += 3
				nos_in_row = 0
			elif nos_in_row >= 5:
				board_points += 6
				nos_in_row = 0
			else:
				nos_in_row = 0
			if heatmap[number] == 2:
				pairs += 1
			if heatmap[number] == 3:
				threes += 1
			if heatmap[number] >= 4:
				board_points += 5
		if pairs == 1 and threes == 1:
			board_points += 4
		elif threes == 1:
			board_points += 2
		elif pairs == 2:
			board_points += 3
		elif pairs == 1:
			board_points += 1
		if nos_in_row == 3:
			board_points += 1
		elif nos_in_row == 4:
			board_points += 3
		elif nos_in_row >= 5:
			board_points += 6

func count_points_second() -> void:
	print(second_board)
	second_board_points = 0
	var numbers_to_count : Array[int] = []
	var pairs : int = 0
	var threes : int = 0
	var heatmap : Array[int] = []
	var nos_in_row : int = 0
	for i in board_size+board_size+2:
		pairs = 0; threes = 0; heatmap = []; numbers_to_count = []; nos_in_row = 0
		if i < board_size: #ROWS
			for j in board_size:
				numbers_to_count.append(second_board[(i*5)+j])
		elif i < 2*board_size: #COLUMNS
			for j in board_size:
				numbers_to_count.append(second_board[(i-board_size)+j*5])
		elif i == 2*board_size: #TOP-LEFT DIAGONAL
			for j in board_size:
				numbers_to_count.append(second_board[j*6])
		else: #TOP-RIGHT DIAGONAL
			for j in board_size:
				numbers_to_count.append(second_board[4+j*4])
		for j in max_number+1:
			heatmap.append(0)
		for cell in numbers_to_count.size():
			heatmap[numbers_to_count[cell]] += 1
		for number in heatmap.size():
			if number == 0:
				nos_in_row = 0
				continue
			if heatmap[number] > 0:
				nos_in_row += 1
			elif nos_in_row == 3:
				second_board_points += 1
				nos_in_row = 0
			elif nos_in_row == 4:
				second_board_points += 3
				nos_in_row = 0
			elif nos_in_row >= 5:
				second_board_points += 6
				nos_in_row = 0
			else:
				nos_in_row = 0
			if heatmap[number] == 2:
				pairs += 1
			if heatmap[number] == 3:
				threes += 1
			if heatmap[number] >= 4:
				second_board_points += 5
		if pairs == 1 and threes == 1:
			second_board_points += 4
		elif threes == 1:
			second_board_points += 2
		elif pairs == 2:
			second_board_points += 3
		elif pairs == 1:
			second_board_points += 1
		if nos_in_row == 3:
			second_board_points += 1
		elif nos_in_row == 4:
			second_board_points += 3
		elif nos_in_row >= 5:
			second_board_points += 6

func round_over() -> void:
	count_points()
	if round_no == 1:
		points += board_points
	elif round_no == 2:
		points -= 2*board_points
	else:
		points += board_points
		points -= 2*second_board_points
		final_score.visible = 1
		$FinalScore/VBoxContainerLabel.text = str(points)
		$FinalScore/VBoxContainer/Label2.text = " seed: %s" % custom_seed
	$MarginContainer/VBoxContainer/HUD/HBoxContainer/CurrentNumber.text = str(points)
	$MarginContainer/VBoxContainer/HUD/HBoxContainer/Points.text = str(board_points)
	$MarginContainer/VBoxContainer/HUD/HBoxContainer/RoundTurn.text = str(round_greek)
	waiting = 1


func _on_submit_pressed() -> void:
	custom_seed = int($SeedSelection/MarginContainer/VBoxContainer/SeedInputField.text)
	seed_selection.visible = 0
	generate_numbers()

func _on_seed_input_field_text_changed(new_text: String) -> void:
	if not new_text.is_valid_int():
		$SeedSelection/MarginContainer/VBoxContainer/SeedInputField.text = old_text
	else:
		old_text = new_text

func _on_random_pressed() -> void:
	custom_seed = randi_range(0, 99999)
	seed_selection.visible = 0
	generate_numbers()
