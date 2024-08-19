extends MarginContainer

class_name DialogSystem

@onready var subtitles: RichTextLabel = $Subtitles

var speechers: Dictionary

func register(speecher: Speecher):
	speechers[speecher.author] = speecher

func play(line: SpeechLine):
	var speecher := speechers.get(line.author) as Speecher
	if !speecher:
		push_warning("Not found speecher %s" % line.author)
		speecher = speechers["DEFAULT"]
	if !is_instance_valid(speecher) || speecher.is_queued_for_deletion() || speecher.dying:
		return
	subtitles.text = "[center][b]%s[/b]\n%s[/center]" % [line.author, line.line]
	await speecher.speech(line)
	subtitles.text = ""

func play_dialog(dialog: Dialog):
	for line in dialog.lines:
		await play(line)
