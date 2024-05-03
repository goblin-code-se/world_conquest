extends Node

var fake_rolls = false
var ai_sleep_time = 0.2
var turn_time = 5*60+0.5 # Five minutes max for a turn, with small offset to properly start at 5:00 and not 4:59
var state: GameState
var waiting_on_die_roll := false
var attacking_territory
var defender_territory
var adjacent_territories
var moving_from: Territory
var moving_to: Territory
var continent_bonuses: Dictionary
"Mission mode NEEDS to receive a signal from the interface for mission mode to be activated.."
var mission_mode: bool = false
var territory_cards = []
var conquered_one: bool = false
var card_trade_count = 0
var players: TurnTracker
var initial_counter: int = 0
var troops_to_add: int
var skip_lock := false
var troops_awarded: int
var already_traded: bool = false
var board: Board
var defender
var random_opp
var scene_tree
enum GameState {
	SELECT_ATTACKER,
	SELECT_ATTACKED,
	POST_ATTACK,
	ADDING_TROOPS,
	ATTACK,
	MOVING_FROM,
	MOVING_TO,
	INITIAL_STATE,
}

signal change_turn
signal start_ai_turn
signal broadcast(message)

var redis = preload("res://redis.tres")

func _ready():
	scene_tree = get_tree()
	board = $Board
	print("READY (main.gd)")
	print(redis.data)
	
	ai_sleep_time = redis.data["ai_thought_time"]
	fake_rolls = redis.data["fake_rolls"]
	turn_time = redis.data["turn_time"]
	mission_mode = redis.data["mission_mode"]
	
	if fake_rolls:
		$TextureRect.visible = false
	
	# Player initialization
	var arr = []
	for i in range(1, 6):
		var is_ai = redis.data["players"][i]["ai"]
		
		var player
		if is_ai:
			var difficulty = redis.data["players"][i]["ai_difficulty"]
			player = Ai.new(i, 25, difficulty, self)
		else:
			player = Player.new(i, 25)
		player._name = redis.data["players"][i]["name"]
		arr.append(player)
		
	players = TurnTracker.new(arr)
	change_turn.connect(next_turn, CONNECT_DEFERRED)
	$AiTimer.timeout.connect(play_ai, CONNECT_DEFERRED)
	broadcast.connect(broadcast_message, CONNECT_DEFERRED)
	#$BroadcastTimer.timeout.connect(clear_broadcast_message, CONNECT_DEFERRED)
	
	# Card init
	setup_territory_cards()
	#print(territory_cards.size())

	broadcast.emit("Game start!")
	# Setup graph
	continent_bonuses = {"North America": 5, 
						"South America": 2, 
						"Africa": 3, 
						"Europe": 5, 
						"Asia": 7, 
						"Australia": 2}
	
	change_game_state(GameState.INITIAL_STATE)
	
	# Register buttons
	$Ui.end_turn_clicked.connect(next_turn)
	$Ui.skip_stage_clicked.connect(skip_stage)
	$Ui.trade_clicked.connect(func(): _on_trade_clicked())
	
	# Mission mode
	if mission_mode:
		random_opp = players.get_all().pick_random()
		assign_mission_cards_to_players(players)
		print("your opponent is: player ", random_opp.get_id())

	$Ui.update_tallies(players._players, players.peek())
	
	if players.peek() is Ai:
		$AiTimer.start(ai_sleep_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Ui.update_timer($TurnTimer.get_time_left())
	if state == GameState.INITIAL_STATE and Input.is_key_pressed(KEY_S) \
	 and not skip_lock:
		skip_lock = true
		for territory in $Board.graph.get_nodes():
			if not territory.get_troop_number():
				handle_initial_adding(territory)
	
	# Arrow silly rendering
	if players.peek() is Ai:
		if waiting_on_die_roll:
			$MoveLine.visible = true
			$MoveLine.default_color = Color.RED
			$MoveLine.clear_points()
			$MoveLine.add_point(redis.data["ai_draw_line_atk"].position)
			$MoveLine.add_point(redis.data["ai_draw_line_def"].position)
		else:
			$MoveLine.visible = false
		return
	var draw_arrow_states = [GameState.SELECT_ATTACKED, GameState.MOVING_TO, GameState.POST_ATTACK]
	$MoveLine.visible = state in draw_arrow_states
	if state in draw_arrow_states:
		var mouse_pos = get_viewport().get_mouse_position()
		var from_territory
		if state == GameState.SELECT_ATTACKED:
			from_territory = attacking_territory
			$MoveLine.default_color = Color.RED
		elif state == GameState.MOVING_TO or state == GameState.POST_ATTACK:
			from_territory = moving_from
			$MoveLine.default_color = Color.BLUE
		$MoveLine.clear_points()
		if from_territory != null:
			$MoveLine.add_point(from_territory.position)
			$MoveLine.add_point(mouse_pos)

func broadcast_message(message):
	$Broadcast.text += "\n" + message
	# $BroadcastTimer.start(5.0)
	print("BROADCAST: " + message)

func clear_broadcast_message():
	$Broadcast.text = "Broadcasts"
	pass
"""Rick!"""

# Recommendation: In _ready() specify the game state at every state. There should be a general "do nothing" state and be changed for ATTACK when, welp, ATTACKing
# Also, these ATTACKing/defender could be added to the ATTACK() function, and just call it when, WELP, ATTACKing, so it re-starts
#Also, probably a more descriptive name would be populate_adjacent_list or something like that

func attack(attacking_territory: Territory, defender_territory: Territory):
	var attacker_dice_count = min(3, attacking_territory.get_troop_number() - 1)
	var defender_dice_count = min(2, defender_territory.get_troop_number())
	var defender = defender_territory.get_ownership()
	var attacker = players.peek()
	
	waiting_on_die_roll = true
	if not fake_rolls:
		redis.data["ai_draw_line_atk"] = attacking_territory
		redis.data["ai_draw_line_def"] = defender_territory
		roll(attacking_territory, defender_territory, true, min(3, attacking_territory.get_troop_number() - 1))
	else:
		 # old fake dice rolls
		var attack_dice = []
		print("the attacker is ", attacker.get_id())
		print("the defender is ", defender.get_id())
		for i in range(attacker_dice_count):
			attack_dice.append(randi_range(1, 6))
		attack_dice.sort()
		attack_dice.reverse()
		
		var defense_dice = []
		for i in range(defender_dice_count):
			defense_dice.append(randi_range(1, 6))
		defense_dice.sort()
		defense_dice.reverse()
		redis.data["attack_dice"] = attack_dice
		redis.data["defense_dice"] = defense_dice
		attack_pt_2(attacking_territory, defender_territory)

func roll(attacking_territory: Territory, defender_territory: Territory, attacking: bool, count: int):
	
	for connection in $TextureRect/SubViewport/DiceRoll.results.get_connections():
		$TextureRect/SubViewport/DiceRoll.results.disconnect(connection.callable)
	
	$TextureRect.visible = true
	$TextureRect/SubViewport/DiceRoll.reset(attacking, count, broadcast)

	if attacking:
		$TextureRect/SubViewport/DiceRoll.results.connect(func(results):
			redis.data["attack_dice"] = results
			roll(attacking_territory, defender_territory, false, min(2, defender_territory.get_troop_number()))
		, CONNECT_DEFERRED)
	else:
		$TextureRect/SubViewport/DiceRoll.results.connect(func(results):
			redis.data["defense_dice"] = results
			attack_pt_2(attacking_territory, defender_territory)
		, CONNECT_DEFERRED)
	return

func attack_pt_2(attacking_territory: Territory, defender_territory: Territory):
	var attacker_losses = 0
	var defender_losses = 0
	var attack_dice = redis.data["attack_dice"]
	var defense_dice = redis.data["defense_dice"]
	print("attacking continuing")
	var defender = defender_territory.get_ownership()
	var attacker = players.peek()
	
	for i in range(min(attack_dice.size(), defense_dice.size())):
		if attack_dice[i] > defense_dice[i]:
			defender_losses +=1
		else:
			attacker_losses +=1
	print("defender loses ", defender_losses)
	print("attacker loses ", attacker_losses)
	attacking_territory.decrement_troops(attacker_losses)
	defender_territory.decrement_troops(defender_losses)
	#defender.decrement_player_troops(defender_losses)
	#print("troops of the attacker of ID ", attacker_id, " now are ", attacker.get_troops())
	#print("troops of the defender of ID ", defender_id, " now are ", defender.get_troops())
	
	if defender_territory.get_troop_number() <= 0:
		print(defender_territory, "conquered")
		conquered_one = true
		defender_territory.set_ownership(attacking_territory.get_ownership()) # this needs a method to get the conquered territory out of the owned territories of the attacked
		defender.get_out_of_owned(defender_territory)
		change_game_state(GameState.POST_ATTACK)
		# not needed anymore, we don't keep track in player
		#players.peek().add_territory(defender_territory)
		#attacking_territory.decrement_troops(attacker_dice_count)
		#defender_territory.increment_troops(attacker_dice_count)
		move(attacking_territory, defender_territory, min(3, attacking_territory.get_troop_number() - 1))
	else:
		change_game_state(GameState.SELECT_ATTACKER)
	#print(territory_cards.size())
	if not defender.get_troops():
		#print("defender cards: ", defender.get_cards())
		broadcast.emit(defender._name + " eliminated. Cards passing to" + attacker._name)
		#print("attacker cards: ", attacker.get_cards())
		for card in defender.get_cards():
			attacker.add_card(card)
		broadcast.emit("attacker cards now: " + str(attacker.get_cards()))
	if attacker.get_cards().size() >= 5:
		broadcast.emit("You have accumulated 5 or more cards! You must trade now!")
		$TurnTimer.start(turn_time)
		change_game_state(GameState.ADDING_TROOPS)
		$Ui.update_troop_count(troops_to_add)
		$Ui.update_timer_hacky_donotuse(str(troops_to_add))
	"else:
		change_game_state(GameState.SELECT_ATTACKER)"
	waiting_on_die_roll = false
	if players.peek() is Ai:
		start_ai_turn.emit(players.peek())
 

func end_of_turn_draw_card(player):
	if conquered_one:
		var card = draw_territory_card()
		player.add_card(card)
		broadcast.emit("Player " + player._name + " drew a card:" + card.name)
		broadcast.emit("cards of player " + player._name + " are: " + str(player.get_cards()))
		player.reset_conquest()
		conquered_one = false

func setup_territory_cards():
	territory_cards = [
		{"name": "Alaska", "symbol": "infantry"},
		{"name": "Northwest Territory", "symbol": "artillery"},
		{"name": "Greenland", "symbol": "cavalry"},
		{"name": "Alberta", "symbol": "cavalry"},
		{"name": "Ontario", "symbol": "cavalry"},
		{"name": "Eastern Canada", "symbol": "cavalry"},
		{"name": "Western United States", "symbol": "artillery"},
		{"name": "Eastern United States", "symbol": "artillery"},
		{"name": "Central America", "symbol": "artillery"},
		{"name": "Venezuela", "symbol": "infantry"},
		{"name": "Peru", "symbol": "infantry"},
		{"name": "Brazil", "symbol": "artillery"},
		{"name": "Argentina", "symbol": "infantry"},
		{"name": "Iceland", "symbol": "infantry"},
		{"name": "Scandinavia", "symbol": "cavalry"},
		{"name": "Russia", "symbol": "cavalry"},
		{"name": "Great Britain", "symbol": "artillery"},
		{"name": "Northern Europe", "symbol": "artillery"},
		{"name": "Western Europe", "symbol": "artillery"},
		{"name": "Southern Europe", "symbol": "artillery"},
		{"name": "North Africa", "symbol": "cavalry"},
		{"name": "Egypt", "symbol": "infantry"},
		{"name": "East Africa", "symbol": "infantry"},
		{"name": "Central Africa", "symbol": "infantry"},
		{"name": "South Africa", "symbol": "artillery"},
		{"name": "Madagascar", "symbol": "cavalry"},
		{"name": "Ural", "symbol": "cavalry"},
		{"name": "Siberia", "symbol": "cavalry"},
		{"name": "Yakutsk", "symbol": "cavalry"},
		{"name": "Kamchatka", "symbol": "infantry"},
		{"name": "Irkutsk", "symbol": "cavalry"},
		{"name": "Mongolia", "symbol": "infantry"},
		{"name": "Japan", "symbol": "artillery"},
		{"name": "Afghanistan", "symbol": "cavalry"},
		{"name": "China", "symbol": "infantry"},
		{"name": "Middle East", "symbol": "infantry"},
		{"name": "India", "symbol": "cavalry"},
		{"name": "Southeast Asia", "symbol": "infantry"},
		{"name": "Indonesia", "symbol": "artillery"},
		{"name": "New Guinea", "symbol": "infantry"},
		{"name": "Western Australia", "symbol": "artillery"},
		{"name": "Eastern Australia", "symbol": "artillery"},
		{"name": "Wildcard 1", "symbol": "wild"},
		{"name": "Wildcard 2", "symbol": "wild"}
	]
	territory_cards.shuffle()



var mission_cards = [
	{"description": "Capture Europe, Australia and one other continent"},
	{"description": "Capture Europe, South America and one other continent"},
	{"description": "Capture North America and Africa"},
	{"description": "Capture Asia and South America"},
	{"description": "Capture North America and Australia"},
	{"description": "Capture 24 territories"},
	{"description": "Destroy all armies of a named opponent (if yourself, capture 24 territories)"},
	{"description": "Capture 18 territories and occupy each with two troops"}
]

func draw_territory_card():
	if not territory_cards.size():
		broadcast.emit("No more territory cards available")
		#return territory_cards.pop_front()
	else:
		var card = territory_cards.pop_front()
		return card
	
func all_territories_owned():
	return $Board.graph.all_territories_owned()


# Only if mission game mode, lacks the signal.
func assign_mission_cards_to_players(players):
	mission_cards.shuffle()
	for player in players.get_all():
		var mission = mission_cards.pop_front() 
		var idk = "Mission assigned to player" + player._name + ": " + mission.description
		print(idk)
		broadcast.emit(idk)
		player.assign_mission(mission) 


func _on_attack_button_pressed() -> void:
	change_game_state(GameState.SELECT_ATTACKER)

func _on_move_button_pressed() -> void:
	change_game_state(GameState.MOVING_FROM)


func trade_cards(player):
	if player.can_trade():
		troops_awarded = calculate_card_bonus()
		#current_player.increment_troops(troops_awarded)
		card_trade_count += 1
		#current_player.remove_traded_cards()
		broadcast.emit("Player " + player._name + " traded 1 set of cards for " + str(troops_awarded) + " troops")
		player.trading_set_used(territory_cards, $Board)
		#player.reset_traded_cards()
		troops_to_add += troops_awarded
		$Ui.update_troop_count(troops_to_add)
		print(already_traded)
		already_traded = true
		print(already_traded)
	else:
		print("can't trade yet")
		

func calculate_card_bonus() -> int:
	match card_trade_count:
		0:
			return 4
		1:
			return 6
		2:
			return 8
		3:
			return 10
		4:
			return 12
		5:
			return 15
		_:
			return 15 + (card_trade_count - 5)*5

"""
main state machine function, handling clicks based on current game state
"""
func _on_board_territory_clicked(which: Territory) -> void:
	match state:
		GameState.ADDING_TROOPS:
			handle_adding(which)
		GameState.SELECT_ATTACKER:
			handle_selecting_attacker(which)
		GameState.SELECT_ATTACKED:
			handle_select_attacked(which)
		GameState.POST_ATTACK:
			handle_moving_post_attack(which)
		GameState.MOVING_FROM:
			handle_moving_from(which)
		GameState.MOVING_TO:
			handle_moving_to(which)
		GameState.INITIAL_STATE:
			if Input.is_key_pressed(KEY_SHIFT):
				while which.get_ownership() == players.peek():
					handle_initial_adding(which)
			else:
				if players.peek() is Ai:
					players.peek().initial_adding(board)
				else:
					handle_initial_adding(which)

func handle_moving_post_attack(which: Territory):
	moving_from = attacking_territory
	moving_to = which
	if which == defender_territory:
		if moving_from.get_troop_number() > 1:
			move(moving_from, moving_to, 1)
		if moving_from.get_troop_number() == 1:
			change_game_state(GameState.SELECT_ATTACKER)
	else: 
		print("Not the territory you just conquered. Please click on the correct territory: ", defender_territory.get_name())
		change_game_state(GameState.POST_ATTACK)

func calculate_continent_bonus(player):
	var bonus = 0
	for continent_name in continent_bonuses.keys():
		if $Board.player_controls_continent(player, continent_name):
			bonus += continent_bonuses[continent_name]
			broadcast.emit("Player " + player._name + " controls the continent " + continent_name + " thus gets awarded " + str(bonus) + " extra troops.")
	return bonus
	

func check_mission_completion(player) -> bool:
	var mission = player.get_mission() 
	match mission.description:
		"Capture Europe, Australia and one other continent":
			return $Board.player_controls_continent(player, "Europe") and $Board.player_controls_continent(player, "Australia")
		"Capture Europe, South America and one other continent":
			return $Board.player_controls_continent(player, "Europe") and $Board.player_controls_continent(player, "South America")
		"Capture North America and Africa":
			return $Board.player_controls_continent(player, "North America") and $Board.player_controls_continent(player, "Africa")
		"Capture Asia and South America":
			return $Board.player_controls_continent(player, "Asia") and $Board.player_controls_continent(player, "South America")
		"Capture North America and Australia":
			return $Board.player_controls_continent(player, "North America") and $Board.player_controls_continent(player, "Australia")
		"Capture 24 territories":
			return player.get_owned_duplicated($Board).size() >= 24
		"Destroy all armies of a named opponent (if yourself, capture 24 territories)":
			if random_opp == player:
				return player.get_owned_duplicated($Board).size() >= 24
			else:
				return is_opp_eliminated(random_opp, $Board)
		"Capture 18 territories and occupy each with two troops":
			var owned_territories = player.get_owned_duplicated($Board)
			var qualified_territories_count = 0
			for territory in owned_territories:
				if territory.get_troop_number() >= 2:
					qualified_territories_count += 1
			return qualified_territories_count >= 18
		_:
			return false

func is_opp_eliminated(player, _board: Board) -> bool:
	return not player._troops

func _on_trade_clicked():
	if not already_traded:
		trade_cards(players.peek())
	else:
		print("already traded!")

"""John!"""

"""
checks if every node in the board belongs to one player id (game over)
 - returns null if no winner
 - returns player id of winner otherwise
"""

func is_game_over():
	if state == GameState.INITIAL_STATE:
		return null
	if not mission_mode:
		var graph = $Board.graph
		var winner = graph.get_nodes()[0].get_ownership()
		for node in graph.get_nodes():
			if node.get_ownership() != winner:
				return null
		print("The winner is: ", winner.get_id())
		return winner
	else:
		if check_mission_completion(players.peek()):
			var winner = players.peek()
			print("The winner is: ", winner.get_id())
			return winner

"""
returns whether or not a move to and from two territories is valid
"""
func valid_move(moving_from: Territory, moving_to: Territory) -> bool:
	var connected_nodes = $Board.graph.dfs(moving_from)
	
	var owned_by_player = moving_to.get_ownership() == players.peek()
	var connected = moving_to in connected_nodes
	return owned_by_player and connected

"""
moves an amount of troops from one territory to the other
"""
func move(from: Territory, to: Territory, amount: int) -> void:
	from.decrement_troops(amount)
	to.increment_troops(amount)


func handle_initial_adding(territory: Territory) -> void:
	if territory.owner == null:
		add_troop_to_territory(territory)
		#print("player ", players.peek(), " owns ", players.peek().get_owned(board))
		initial_counter += 1
		if initial_counter < 42 or initial_counter in [59, 76, 93, 109]:
			next_turn()
			$Ui.update_tallies(players._players, players.peek())
	
	$Ui.update_timer_hacky_donotuse(str(initial_counter))

	# Switch from initial to main game state
	var arr = players.get_all()
	if initial_counter == 125:
		$TurnTimer.start(turn_time)
		change_game_state(GameState.ADDING_TROOPS)
		next_turn()

"""
checks whether an adding click is valid via:
	- same ownership as current player
	- whether it is a neutral faction (only happens at start)
		- if so changing ownership to that player
	- whether or not a player has more than 0 troops to add
		- if on 0, setting to next state of turn (SELECT_ATTACKER)
if valid deducts 1 from player troop count, and adds 1 troop to territory that was clicked
"""

func handle_adding(territory: Territory) -> void:
	var player = players.peek()
	if player.get_cards().size() >= 5:
		broadcast.emit("You have accumulated 5 or more cards! You must trade now!")
		trade_cards(player)
	$Ui.update_timer_hacky_donotuse(str(troops_to_add))
	if add_troop_to_territory(territory):
		troops_to_add -= 1
		$Ui.update_troop_count(troops_to_add)
	if not troops_to_add:
		#trade_cards(players.peek())
		already_traded = false
		print("now already traded state is: ", already_traded)
		change_game_state(GameState.SELECT_ATTACKER)


func add_troop_to_territory(territory: Territory) -> bool:

	# ok whatever
	if territory == null:
		return false
	
	# Player is not allowed to occupy this territory
	if territory.get_ownership() not in [players.peek(), null]:
		return false

	# Player has no troops
	#if players.peek().get_troops() == 0:
		#return false
	
		# Claim territory
	if territory.get_ownership() == null:
		territory.set_ownership(players.peek())
	
	territory.increment_troops(1) # can add multiple at a time eventually to help with turns of huge amounts of troops
	#players.peek().increment_troops(1)
	#print("player: ", players.peek().get_id(), " has ", players.peek().get_troops(), " troops")
	return true

"""
checks whether it is possible to attack from a territory, valid if:
	- it belongs to player clicking
"""
func handle_selecting_attacker(which: Territory) -> void:
	if which.get_ownership() == players.peek():
		attacking_territory = which
		print("Attacker territory: ", which.get_id())
		change_game_state(GameState.SELECT_ATTACKED)
	else:
		print("not your territory bro")

func change_game_state(game_state: GameState):
	state = game_state
	$Ui.update_game_state(state)

"""
checks whether it is possible to attack a territory from a previous valid attacking territory via:
	- checking adjacency of a defender
	- territory doesn't belong to current player
"""
func handle_select_attacked(which: Territory):
	var adjacent: bool = which.get_id() in $Board.graph.get_adjacent_nodes(attacking_territory.get_id())
	if adjacent and which.get_ownership() != players.peek(): #and which.get_ownership() != attacking_territory.get_ownership():
		defender_territory = which
		#change_game_state(GameState.SELECT_ATTACKED)
		print("defender: ", which.get_id())
		attack(attacking_territory, defender_territory)
	else:
		print("can't attack")
		change_game_state(GameState.SELECT_ATTACKER)

"""
checks whether it is valid to move troops from a territory via:
	- belongs to current player
	- whether a move would leave atleast 1 troop in a territory (risk rules)
if valid, changes state to MOVING TO
"""
func handle_moving_from(which: Territory) -> void:
	if which.get_ownership() == players.peek():
		moving_from = which
		change_game_state(GameState.MOVING_TO)
	else:
		print("not your territory")

"""
checks whether a move is valid via:
	- belongs to current player
	- running valid_move()
if valid:
	- runs move() to and from territories clicked
	- ends turn (risk rules)
if not valid:
	- changes state back to MOVING_FROM to allow for reattempt
"""
func handle_moving_to(which: Territory) -> void:
	if which.get_ownership() == players.peek():
		moving_to = which
		if valid_move(moving_from, moving_to):
			#print("valid movement")
			move(moving_from, moving_to, 1)
			"Following could be changed to a better interaction in UI with the player."
			if moving_from.get_troop_number() == 1:
				next_turn()
		else:
			print("not reachable")
			change_game_state(GameState.MOVING_FROM)
	else:
		print("not your territory")

"""
 - resets turn to adding troops, if not in initial state
"""
func next_turn() -> void:
	end_of_turn_draw_card(players.peek())
	clear_broadcast_message()

	var winner = is_game_over()
	if winner:
		redis.data["winner"] = winner
		#var win = preload("res://scenes/win.tscn").instantiate()
		#win.z_index = 9
		#add_child(win)
		scene_tree.change_scene_to_file("res://scenes/win.tscn")
		return

	if state != GameState.INITIAL_STATE:
		# go to next player until current player has troops
		# while loop is empty as all logic is in condition
		#print(players.next().get_troops())
		while not players.next().get_troops():
			pass
			
		if state != GameState.INITIAL_STATE:
			change_game_state(GameState.ADDING_TROOPS)
			troops_to_add = players.peek().count_bonus_troops($Board) + calculate_continent_bonus(players.peek()) # this calculation should probably be in player.gd
			$Ui.update_troop_count(troops_to_add)
	else:
		players.next()

	$TurnTimer.start(turn_time)
	$Ui.update_tallies(players._players, players.peek())
	$Ui.update_timer_hacky_donotuse(str(troops_to_add))

	broadcast.emit("Territory cards: " + str(players.peek().get_cards().map(func(card): return card["name"])).replace("\"", "").replace("[", "").replace("]", ""))
	if mission_mode:
		broadcast.emit("Mission: " + players.peek().mission.description)
	
	if players.peek() is Ai:
		$AiTimer.start(ai_sleep_time)

func play_ai():
	#print("I am the ai. I am playing my turn.")
	var player = players.peek()
	if not player is Ai:
		return
	while players.peek() == player:
		if waiting_on_die_roll:
			return
		#print("SPECIAL DEBUG " + str(players.peek().get_id()))
		print(state)
		match state:
			GameState.ADDING_TROOPS:
				#print("I am the troop placer. Troopmaxing")
				player.place_troops(board, troops_to_add)
			GameState.SELECT_ATTACKER:
				#print("I am the attacker")
				player.attack(board)
			GameState.POST_ATTACK:
				#print("I am the post attacker")
				player.move_post_attack(board, attacking_territory, defender_territory)
			GameState.MOVING_FROM:
				#print("I am the moving fromer")
				if player.move(board):
					change_turn.emit()
					return
			GameState.INITIAL_STATE:
				#print("I am the initial stater")
				player.initial_adding(board)
			_:
				print("Oh you poor thing.")
				change_turn.emit()
				return

func skip_stage() -> void:
	print("Skipping?")
	print(GameState.keys()[state])
	var skip_to = {
		GameState.ADDING_TROOPS: GameState.SELECT_ATTACKER,
		GameState.SELECT_ATTACKER: GameState.MOVING_FROM,
		GameState.SELECT_ATTACKED: GameState.MOVING_FROM,
		GameState.POST_ATTACK: GameState.SELECT_ATTACKER
	}
	if skip_to.get(state, null) != null:
		change_game_state(skip_to[state])

func _on_turn_timer_timeout():
	next_turn()
