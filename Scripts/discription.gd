extends Label

const msgs: Array[String] = ["This is your score -croak!", "Why did you leave me to die?", "Blub... blub...", "Well, good job.", "I don't like to dive\ninto a waterfall.", "Stop admiring and save me!", "Please regret that jump the most.", "You killed one of the many me.", "'WASTED'", "That’s ok.\nIt was cool.", "Pro tip: Don’t do what you just did.", "Wow, the snake swims underwa...", "I forgot how to breathe.", "You should have read the tutorial.", "I’m alive!\nBut where am I?", "My legs\nbetrayed me.", "Do you hear my friends laughing?", "Turns out\nI can’t swim.","Note: water is\nnot a floor.", "My jump button\nis cursed.", "RIP-ibit.", "Who put water everywhere?!", "So slippery...\nso doomed.", "The water hugs too hard.", "Respawn?\nYes, please.", "I think you’ve got only 3 fingers.", "My babies jump better than you.", "Who taught you\nto jump?", "Even the flies\nmock you.", "Next time, try to aim leaves.", "Bravo, you\ninvented sinking.", "You don’t like\n a circle?", "Your species are 'AMAZING'.", "Try closing your eyes next time.", "I’ve seen rocks jump better.", "Maybe the water likes me too much.", "Gravity: 1, You: 0.", "The leaf was right there.", "You're very good at killing frogs.", "Did you just grow legs today?"]

func _ready() -> void:
	Data.add_listener(&"game_set", _set_rand_msg)

func _set_rand_msg() -> void:
	self.text = msgs.pick_random()
