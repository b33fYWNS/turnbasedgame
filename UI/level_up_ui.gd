extends TextureRect

@onready var experience_bar = %ExperienceBar

func level_up() -> void:
	show()
	await experience_bar.animate_bar(100,100)
