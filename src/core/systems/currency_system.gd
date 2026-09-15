extends System

signal currency_changed(currency_type: String, new_amount: float)
signal relationship_changed(new_value: float)
signal day_advanced(day_number: int)

var currencies: Dictionary = {
	"charm": 0.0,
	"trust": 0.0,
	"wit": 0.0,
	"vulnerability": 0.0,
}

var relationship_health: float = 50.0  # 0-100, drives difficulty/enemy waves
var current_day: int = 1
var current_character: String = ""

func add_currency(currency_type: String, amount: float) -> void:
	if not currencies.has(currency_type):
		push_warning("Unknown currency type: %s" % currency_type)
		return
	currencies[currency_type] += amount
	currency_changed.emit(currency_type, currencies[currency_type])

func can_afford(currency_type: String, cost: float) -> bool:
	return currencies.get(currency_type, 0.0) >= cost

func spend_currency(currency_type: String, cost: float) -> bool:
	if not can_afford(currency_type, cost):
		return false
	currencies[currency_type] -= cost
	currency_changed.emit(currency_type, currencies[currency_type])
	return true

func apply_vulnerability_risk(amount: float, success_chance: float) -> void:
	# High-risk currency: can backfire if relationship isn't ready
	if randf() < success_chance:
		add_currency("vulnerability", amount * 2.0)  # payoff
	else:
		modify_relationship(-amount * 0.5)  # backfire hurts relationship instead

func modify_relationship(delta: float) -> void:
	relationship_health = clampf(relationship_health + delta, 0.0, 100.0)
	relationship_changed.emit(relationship_health)

func advance_day() -> void:
	current_day += 1
	day_advanced.emit(current_day)
	# Optional: decay unspent currency so hoarding isn't optimal
	for key in currencies:
		currencies[key] *= 0.5

func reset_for_character(character_name: String) -> void:
	current_character = character_name
	current_day = 1
	relationship_health = 50.0
	for key in currencies:
		currencies[key] = 0.0
