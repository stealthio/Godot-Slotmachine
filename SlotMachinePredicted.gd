extends Control

onready var slotIndex = $SlotIndex
onready var slots = [$Slot, $Slot2, $Slot3]
onready var moneyLabel = $Money
onready var tributeLabel = $Tribute

var money = 100

var slots_vel = [0.0,0.0,0.0]
var slots_active = [false,false,false]
var default_slot_times = [60, 120, 180]
var results = [null, null, null]
var slot_times = [0,0,0]
var rolling = false
var outcomes = [null, null, null]
var tribute = 2
var autoroll = false

var symbols = {
	"Banana" : {
		"Path" : "res://Assets/Banana.png",
		"TopBracked" : 100.0,
		"BotBracked" : 62.65,
		"Payout" : 1.51
	},
	"Bell" : {
		"Path" : "res://Assets/Bell.png",
		"TopBracked" : 62.65,
		"BotBracked" : 33.564,
		"Payout" : 1.948
	},
	"Cherry" : {
		"Path" : "res://Assets/Cherry.png",
		"TopBracked" : 33.564,
		"BotBracked" : 14.439,
		"Payout" : 2.96295
	},
	"Lemon" : {
		"Path" : "res://Assets/Lemon.png",
		"TopBracked" : 14.439,
		"BotBracked" : 2.6938,
		"Payout" : 4.82468
	},
	"Seven" : {
		"Path" : "res://Assets/Seven.png",
		"TopBracked" : 2.6938,
		"BotBracked" : 0,
		"Payout" : 23.70366
	},
	"Gem" : {
		"Path" : "res://Assets/Gem.png",
		"TopBracked" : 5.0,
		"BotBracked" : 0.0,
		"Payout" : 189.6293
	},
}

const SLOT_START_Y = -292
const SLOT_END_Y = 219

func _ready():
	moneyLabel.text = String(money)
	tributeLabel.text = String(tribute)
	randomize()
		
func _process(delta):
	if rolling:
		for i in slot_times.size():
			slot_times[i] += 1
		for i in slots.size():
			if slots_active[i]:
				slots[i].rect_global_position.y += slots_vel[i]
				if slots[i].rect_global_position.y > SLOT_END_Y:
					slots[i].rect_global_position.y = SLOT_START_Y
		
		for i in slots.size():
			if slots_active[i] and slot_times[i] > default_slot_times[i]:
				for node in slots[i].get_children():
					var ty = node.rect_global_position.y
					ty = stepify(ty, 73)
					if ty == slotIndex.rect_global_position.y:
						for symbol in symbols:
							if symbols[symbol] == outcomes[i]:
								if symbols[symbol]["Path"] == node.texture.resource_path:
									slots[i].rect_global_position.y = stepify(slots[i].rect_global_position.y, 73)
									slots_active[i] = false
									results[i] = symbol
		rolling = false
		for act in slots_active:
			if act:
				rolling = true
		if not rolling:
			if results[0] == results[1] && results[1] == results[2]:
				money += ceil(symbols[results[0]]["Payout"] * tribute)
				moneyLabel.text = String(money)
	elif autoroll:
		yield(get_tree().create_timer(1.0), "timeout")
		roll()

func increase_tribute():
	tribute += 1
	tributeLabel.text = String(tribute)

func decrease_tribute():
	if tribute > 1:
		tribute -= 1
		tributeLabel.text = String(tribute)

func roll():
	if money < tribute:
		return
	if rolling == true:
		return
	money -= tribute
	moneyLabel.text = String(money)
	for i in slots_vel.size():
		slots_vel[i] = randf() * 10 + 30
	rolling = true
	slots_active = [true, true, true]
	results = [null, null, null]
	for i in slot_times.size():
			slot_times[i] = 0
	outcomes = [null,null,null]
	# Roll if won
	var luck = randf()
	if luck > 0.75:
		# win
		luck = randf()*100
		var winningSymbol = null
		for symbol in symbols:
			if (luck <= symbols[symbol]["TopBracked"] && luck >= symbols[symbol]["BotBracked"]):
				winningSymbol = symbol
				break
		for i in 3:
			outcomes[i] = symbols[winningSymbol]
	else:
		# lose
		for i in 3:
			outcomes[i] = symbols[symbols.keys()[randi()%symbols.size()]]
		while(outcomes[1] == outcomes[2]):
			outcomes[2] = symbols[symbols.keys()[randi()%symbols.size()]]

func _on_Autoroll_toggled(button_pressed):
	autoroll = button_pressed
