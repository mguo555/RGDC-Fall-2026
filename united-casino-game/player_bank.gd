extends RefCounted

static var money = 0

static func pay(amount):
	money -= amount

static func add(amount):
	money += amount
