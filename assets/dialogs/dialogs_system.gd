extends MarginContainer

@onready var subtitles: RichTextLabel = $Subtitles

var speechers: Dictionary

func register(speecher: Speecher):
	speechers[speecher.author] = speecher

func play(line: SpeechLine):
	subtitles.text = "[center][b]%s[/b]\n%s[/center]" % [line.author, line.line]
	await speechers[line.author].speech(line)
	subtitles.text = ""
