extends Control
var board : Array = []
var second_board : Array = []
@onready var board_grid: GridContainer = $MarginContainer/VBoxContainer/Board/GridContainer
@onready var second_board_grid: GridContainer = $MarginContainer/VBoxContainer/Board2/GridContainer
@onready var tween_rect: ColorRect = $TweenRect
const board_size := 5 #THIS SHOULD BE 5!
const max_number := 13 #THIS SHOULD BE 13!
var no_of_number_sets := 4 #THIS SHOULD BE 4!
@export var number_sequence : Array[int] = []
@onready var timer: Timer = $Timer
@onready var mode: Label = $MarginContainer/VBoxContainer/HUD2/CenterContainer/VBoxContainer/Label2
@onready var seed_display: Label = $MarginContainer/VBoxContainer/HUD2/CenterContainer/VBoxContainer/Label
@onready var seed_selection: ColorRect = $SeedSelection
@onready var final_score: ColorRect = $FinalScore
@onready var personal_best: Label = $FinalScore/CenterContainer/VBoxContainer/MarginContainer2/MarginContainer/Label2
@onready var previous_runs: ColorRect = $SeedSelection/PreviousRuns
@onready var global_run_list: RichTextLabel = $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/RichTextLabel2
@onready var personal_run_list: RichTextLabel = $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/RichTextLabel
@onready var search_by_seed: LineEdit = $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/SearchBySeed
@onready var ongoing_runs: MarginContainer = $SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/OngoingRuns
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
var pointsI : int = 0
var pointsII : int = 0
var pointsIIIa : int = 0
var pointsIIIb : int = 0
var old_second_board : bool = 0
var tried : bool = 0
var leaderboard

func _ready() -> void:
	Saves.load_data()
	seed_selection.visible = 1
	final_score.visible = 0
	timer.stop()
	previous_runs.visible = 0
	$SeedSelection/NewRunSeed.visible = 0
	ongoing_runs.visible = 1; $SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/HSeparator3.visible = 1
	if Saves.ongoing_runs == []: ongoing_runs.visible = 0; $SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/HSeparator3.visible = 0
	$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/NewRun/warning.visible = 0
	leaderboard = await SilentWolf.Scores.get_scores().sw_get_scores_complete
	$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/Username/VBoxContainer/UsernameInputField.text = Saves.username
	
func _process(_delta: float) -> void:
	if Saves.ongoing_runs != [] and seed_selection.visible:
		var rounds_greek_temporary : String = "I"
		match Saves.ongoing_runs[11]:
			1:
				rounds_greek_temporary = "I"
			2:
				rounds_greek_temporary = "II"
			3:
				rounds_greek_temporary = "III"
			_:
				rounds_greek_temporary = "I"
		$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/OngoingRuns/Run1/CenterContainer/info.text = "%s | %s | %s/%s" % [Saves.ongoing_runs[0], Saves.ongoing_runs[7], rounds_greek_temporary, Saves.ongoing_runs[10]]
	$SeedSelection/Parallax2D/Sprite2D.global_position.y = get_viewport_rect().size.y-34.5
	$SeedSelection/PreviousRuns/Parallax2D2/Sprite2D.global_position.y = get_viewport_rect().size.y-34.5
	$FinalScore/CenterContainer/Parallax2D2/Sprite2D.global_position.y = get_viewport_rect().size.y-34.5
	$SeedSelection/NewRunSeed/Parallax2D/Sprite2D.global_position.y = get_viewport_rect().size.y-34.5
	$SeedSelection/Sprite2D2.global_position.y = get_viewport_rect().size.y-69-26
	$SeedSelection/PreviousRuns/Sprite2D3.global_position.y = get_viewport_rect().size.y-69-26
	$SeedSelection/NewRunSeed/Sprite2D2.global_position.y = get_viewport_rect().size.y-69-26
	$FinalScore/CenterContainer/Sprite2D3.global_position.y = get_viewport_rect().size.y-69-26
	if tried:
		$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/NewRun/warning.visible = 1
	if not Saves.timed_moves:
		$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/TimedMoves/HBoxContainer/Panel.visible = 1
		$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/TimedMoves/HBoxContainer/Panel2.visible = 0
	else:
		$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/TimedMoves/HBoxContainer/Panel.visible = 0
		$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/TimedMoves/HBoxContainer/Panel2.visible = 1
	seed_display.text = "seed: %s" % custom_seed
	if round_no == 1:
		mode.text = "I: MAXIMUM"
		$MarginContainer/VBoxContainer/Board.visible = 1
		$MarginContainer/VBoxContainer/Board2.visible = 0
	elif round_no == 2:
		mode.text = "II: MINIMUM"
		$MarginContainer/VBoxContainer/Board.visible = 1
		$MarginContainer/VBoxContainer/Board2.visible = 0
	elif round_no == 3 and not second_board_opened:
		mode.text = "IIIa: MAXIMUM"
	elif round_no == 3 and second_board_opened:
		mode.text = "IIIb: MINIMUM"
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
		Saves.ongoing_runs = [custom_seed, board, second_board, pointsI, pointsII, pointsIIIa, pointsIIIb, points, board_points, second_board_points, turn, round_no, second_board_opened, waiting]
		waiting = 0
		tween_rect.color.a = 0; tween_rect.visible = 1; tween_rect.mouse_filter = Control.MOUSE_FILTER_STOP
		var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
		tween.tween_property(tween_rect, "color:a", 1, 1)
		await tween.finished
		generate_numbers()
		tween_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tween_rect.color.a = 1
		var tween_2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
		tween_2.tween_property(tween_rect, "color:a", 0, 1)
		await tween_2.finished
		tween_rect.visible = 0
	if previous_runs.visible:
		personal_run_list.text = ""
		personal_run_list.visible = 1; $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Label.visible = 1
		global_run_list.visible = 1; $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Label2.visible = 1
		global_run_list.text = ""
		if search_by_seed.text != "":
			global_run_list.visible = 1; $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Label2.visible = 1
			for i in leaderboard.scores:
				if i.metadata.seed == int(search_by_seed.text):
					global_run_list.text += "[font=res://assets/fonts/Anonymous_Pro_B.ttf]%s | %s | %s[/font]\n" % [i.player_name, int(i.metadata.seed), int(i.score)]
			for i in Saves.seeds.size():
				if Saves.seeds[i] == int(search_by_seed.text):
					personal_run_list.text = "[font=res://assets/fonts/Anonymous_Pro_B.ttf]%s[/font]|%s|%s|%s|%s|[font=res://assets/fonts/Anonymous_Pro_B.ttf]%s[/font]\n" % [Saves.seeds[i], Saves.points_I[i], -2*Saves.points_II[i], Saves.points_IIIa[i], -2*Saves.points_IIIb[i], Saves.points[i]] + personal_run_list.text
			if global_run_list.text == "": global_run_list.visible = 0; $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Label2.visible = 0
			if personal_run_list.text == "": personal_run_list.text = "[font_size=25]No records of you playing with this seed.[/font_size]"
		else:
			if global_run_list.text == "":
				var j : int = 0
				for i in leaderboard.scores:
					if j > leaderboard.scores.size():
						break
					global_run_list.text += "[font=res://assets/fonts/Anonymous_Pro_B.ttf]%s | %s | %s[/font]\n" % [i.player_name, int(i.metadata.seed), int(i.score)]
					j += 1
					if j >= 20:
						break
			if global_run_list.text == "": global_run_list.visible = 0; $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Label2.visible = 0
			for i in Saves.seeds.size():
				personal_run_list.text = "[font=res://assets/fonts/Anonymous_Pro_B.ttf]%s[/font]|%s|%s|%s|%s|[font=res://assets/fonts/Anonymous_Pro_B.ttf]%s[/font]\n" % [Saves.seeds[i], Saves.points_I[i], -2*Saves.points_II[i], Saves.points_IIIa[i], -2*Saves.points_IIIb[i], Saves.points[i]] + personal_run_list.text
		if personal_run_list.text == "":
			personal_run_list.visible = 0; $SeedSelection/PreviousRuns/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/VBoxContainer/Label.visible = 0
	if not old_second_board and second_board_opened:
		$MarginContainer/VBoxContainer/Board.visible = 0
		$MarginContainer/VBoxContainer/Board2.visible = 1
	elif old_second_board and not second_board_opened:
		$MarginContainer/VBoxContainer/Board.visible = 1
		$MarginContainer/VBoxContainer/Board2.visible = 0
	old_second_board = second_board_opened

func generate_numbers() -> void:
	board = []
	second_board = []
	number_sequence = []
	var amplifier : int = (round_no)*10000
	while 1==1:
		if no_of_number_sets*13 >= board_size*board_size:
			break
		no_of_number_sets += 1
	var number_usage : Array[int] = []
	var overuse_index : int = 1
	for i in max_number:
		number_usage.append(0)
	for i in board_size*board_size:
		seed(custom_seed+i+amplifier)
		board.append(0)
		second_board.append(0)
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
	if Saves.timed_moves:
		timer.start(15)
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
		pointsI = board_points
		waiting = 1
	elif round_no == 2:
		points -= 2*board_points
		pointsII = board_points
		waiting = 1
	else:
		points += board_points
		pointsIIIa = board_points
		points -= 2*second_board_points
		pointsIIIb = second_board_points
		final_score.visible = 1
		$FinalScore/CenterContainer/VBoxContainer/MarginContainer/VBoxContainer/Label.text = str(points)
		$FinalScore/CenterContainer/VBoxContainer/MarginContainer/VBoxContainer/RichTextLabel.text = "seed: %s" % custom_seed
		if Saves.best_scores.keys().has(custom_seed):
			if Saves.best_scores[custom_seed] > points:
				personal_best.text = "Your personal best on this seed is: %s" % Saves.best_scores[custom_seed]
			else:
				Saves.best_scores[custom_seed] = points
				personal_best.text = "This is your personal best on this seed!"
		else:
			Saves.best_scores[custom_seed] = points
			personal_best.text = "This is your personal best on this seed!"
		Saves.seeds.append(custom_seed)
		Saves.points.append(points)
		Saves.points_I.append(pointsI)
		Saves.points_II.append(pointsII)
		Saves.points_IIIa.append(pointsIIIa)
		Saves.points_IIIb.append(pointsIIIb)
		Saves.ongoing_runs = []
		Saves.save_data()
		var run_metadata : Dictionary = {
			"seed" : custom_seed,
		}
		var run_username : String = Saves.username
		if Saves.username == "": run_username = "Unknown"
		await SilentWolf.Scores.save_score(run_username, points, "main", run_metadata).sw_save_score_complete
	$MarginContainer/VBoxContainer/HUD/HBoxContainer/CurrentNumber.text = str(points)
	if round_no == 2:
		$MarginContainer/VBoxContainer/HUD/HBoxContainer/Points.text = str(-2*board_points)
	else:
		$MarginContainer/VBoxContainer/HUD/HBoxContainer/Points.text = str(board_points)
	$MarginContainer/VBoxContainer/HUD/HBoxContainer/RoundTurn.text = str(round_greek)

func _on_submit_pressed() -> void:
	tried = false
	$SeedSelection/NewRunSeed/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/SeedInputField/Label.text = ""
	$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/NewRun/warning.visible = 0
	custom_seed = int($SeedSelection/NewRunSeed/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/SeedInputField.text)
	tween_rect.color.a = 0; tween_rect.visible = 1; tween_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_property(tween_rect, "color:a", 1, 1)
	await tween.finished
	seed_selection.visible = 0
	generate_numbers()
	tween_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tween_rect.color.a = 1
	var tween_2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween_2.tween_property(tween_rect, "color:a", 0, 1)
	await tween_2.finished
	tween_rect.visible = 0

func _on_seed_input_field_text_changed(new_text: String) -> void:
	if not new_text.is_valid_int() and not new_text == "":
		$SeedSelection/NewRunSeed/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/SeedInputField.text = old_text
		$SeedSelection/NewRunSeed/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/SeedInputField/Label.text = "SEEDS CONSIST OF NUMBERS ONLY!"
	else:
		old_text = new_text
		$SeedSelection/NewRunSeed/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/SeedInputField/Label.text = ""

func _on_random_pressed() -> void:
	tried = false
	$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/NewRun/warning.visible = 0
	custom_seed = randi_range(0, 99999)
	tween_rect.color.a = 0; tween_rect.visible = 1; tween_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_property(tween_rect, "color:a", 1, 1)
	await tween.finished
	seed_selection.visible = 0
	generate_numbers()
	tween_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tween_rect.color.a = 1
	var tween_2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween_2.tween_property(tween_rect, "color:a", 0, 1)
	await tween_2.finished
	tween_rect.visible = 0

func _on_timed_moves_button_up() -> void:
	if Saves.timed_moves:
		Saves.timed_moves = 0
		$SeedSelection/MarginContainer/VBoxContainer/TimedMoves/HBoxContainer/Panel.visible = 1
		$SeedSelection/MarginContainer/VBoxContainer/TimedMoves/HBoxContainer/Panel2.visible = 0
	else:
		Saves.timed_moves = 1
		$SeedSelection/MarginContainer/VBoxContainer/TimedMoves/HBoxContainer/Panel.visible = 0
		$SeedSelection/MarginContainer/VBoxContainer/TimedMoves/HBoxContainer/Panel2.visible = 1
	Saves.save_data()

func _on_timer_timeout() -> void:
	timer.stop()

func _on_button_2_button_up() -> void:
	get_tree().reload_current_scene()


func _on_button_button_up() -> void:
	leaderboard = await SilentWolf.Scores.get_scores(20).sw_get_scores_complete
	previous_runs.visible = 1

func _on_back_to_menu_button_up() -> void:
	previous_runs.visible = 0
	$SeedSelection/NewRunSeed.visible = 0

func _on_username_input_field_text_changed(new_text: String) -> void:
	Saves.username = new_text
	Saves.save_data()

func _on_run_1_button_up() -> void:
	custom_seed = Saves.ongoing_runs[0]
	round_no = Saves.ongoing_runs[11]-1
	tried = false
	$SeedSelection/NewRunSeed/ScrollContainer/MarginContainer/VBoxContainer/MarginContainer/VBoxContainer/SeedInputField/Label.text = ""
	$SeedSelection/ScrollContainer/MarginContainer/VBoxContainer/NewRun/warning.visible = 0
	tween_rect.color.a = 0; tween_rect.visible = 1; tween_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUART)
	tween.tween_property(tween_rect, "color:a", 1, 1)
	await tween.finished
	seed_selection.visible = 0
	generate_numbers()
	board = Saves.ongoing_runs[1]
	second_board = Saves.ongoing_runs[2]
	pointsI = Saves.ongoing_runs[3]
	pointsII = Saves.ongoing_runs[4]
	pointsIIIa = Saves.ongoing_runs[5]
	pointsIIIb = Saves.ongoing_runs[6]
	points = Saves.ongoing_runs[7]
	board_points = Saves.ongoing_runs[8]
	second_board_points = Saves.ongoing_runs[9]
	turn = Saves.ongoing_runs[10]
	second_board_opened = Saves.ongoing_runs[12]
	waiting = Saves.ongoing_runs[13]
	tween_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tween_rect.color.a = 1
	for cell in board_grid.get_children():
		cell.write_number(false)
	for cell in second_board_grid.get_children():
		cell.write_number(true)
	var tween_2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween_2.tween_property(tween_rect, "color:a", 0, 1)
	await tween_2.finished
	tween_rect.visible = 0

func cell_pressed(board_position : int) -> void:
	if not second_board_opened:
		board_grid.get_child(board_position).write_number_definite(number_sequence[turn-2])
		board[board_position] = number_sequence[turn-2]
		count_points()
		if round_no == 3:
			second_board_opened = 1
		else:
			turn += 1
	else:
		second_board_grid.get_child(board_position).write_number_definite(number_sequence[turn-2])
		second_board[board_position] = number_sequence[turn-2]
		turn += 1
		count_points_second()
		second_board_opened = 0
	if Saves.timed_moves:
		timer.start(15)
	Saves.ongoing_runs = [custom_seed, board, second_board, pointsI, pointsII, pointsIIIa, pointsIIIb, points, board_points, second_board_points, turn, round_no, second_board_opened, waiting]
	Saves.save_data()

func _on_new_run_button_up() -> void:
	if not tried and Saves.ongoing_runs != []:
		tried = true
		return
	$SeedSelection/NewRunSeed.visible = 1
