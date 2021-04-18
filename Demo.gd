extends Node


var SMF = preload("res://addons/midi/SMF.gd").new( )

export(String, FILE, "*.sf2") var soundfont


func _ready():
	$MidiPlayer.soundfont = soundfont


func create_smf( ) -> Dictionary:
	var timebase:int = 48   # Quarter note = 48
	var events:Array = []

	# added program change / $03 Honky Tonk Piano
	events.append( SMF.MIDIEventChunk.new( 0, 0, SMF.MIDIEventProgramChange.new( 3 ) ) )

	# cdefgab
	var note_number:int = 60;
	var time:int = 48
	for add in [0,2,2,1,2,2,2]:
		note_number += add
		# note on
		events.append( SMF.MIDIEventChunk.new( time, 0, SMF.MIDIEventNoteOn.new( note_number, 127 ) ) )
		time += 48
		# note off (not support "note on with velocity 0 as note off" on Godot MIDI Player. It was converted on SMF.gd when *.mid read.)
		events.append( SMF.MIDIEventChunk.new( time, 0, SMF.MIDIEventNoteOff.new( note_number, 0 ) ) )

	# if you generate *.mid using SMF.gd write function, needs End of Track.
	# but if only play on Godot MIDI Player, not needs End of Track.
	var eot = SMF.MIDIEventSystemEvent.new( { "type": SMF.MIDISystemEventType.end_of_track } )
	events.append( SMF.MIDIEventChunk.new( time, 0, eot ) )

	return SMF.SMFData.new( 0, 1, timebase, [SMF.MIDITrack.new( 0, events )] )


func play( ):
	$MidiPlayer.smf_data = create_smf( )
	$MidiPlayer.play( )
