//14 - MIDI COMMUNICATION
////////////////////////////////////////
//See all details in the help document:

MIDIClient.init; //Initiates the MIDI communication.
MIDIIn.connectAll; //Detects all connected MIDI devices.

MIDIFunc.trace(true); //Printing the values (to test).
MIDIFunc.trace(false); //Stop printing the values.

//MIDI control:
MIDIdef.cc(\cc16, { arg val, ccnum; ~cc16 = val}, 16); //Arguments are key (\symbol), function and control number within MIDIdef.cc.

//NoteOn and noteOff:
MIDIdef.noteOn(\qn1, {arg...args; args.postln}); //\qn (the key) needs to be different in each instance, that is to say, for each action - .noteOn / .noteOff - (as it is saved into a Dictionary through identity).
MIDIdef.noteOff(\qn2, { arg vel, note; ~note = note});
MIDIdef.freeAll //To empty the dictionary of keys.

//Next step: press and release:

x = Task{inf.do{ arg i; i.postln; 0.1.wait}; //Task: needs to be .reset because it cannot .resume due to the lack of memory about the point at which it was.

//No conditional:
MIDIdef.noteOn(\qn1, {arg vel, note, ch, src; x.play}, 112, 0); //At the end: note and channel.
MIDIdef.noteOff(\qn2, { arg vel, note, ch, src; x.stop; x.reset}, 112, 0);

//Using the conditional (so the note is within the function):
MIDIdef.noteOn(\qn1, {arg vel, note, ch, src; if(note == 112, {x.play})});
MIDIdef.noteOff(\qn2, { arg vel, note, ch, src; if(note == 112, {x.stop; x.reset})});

//Example using three routines:

x = Task{inf.do{ arg i; i.postln; 0.1.wait};
z = Task{inf.do{ arg i; (i + 100).postln; 0.1.wait};
w = Task{inf.do{ arg i; (i + 1000).postln; 0.1.wait};

//Ctrl + . --> empties everything:
(
	MIDIdef.noteOn(\qn1, { arg vel, note, ch, src;
		case
		{note == 113} {x.play; w.stop; w.reset; z.stop; z.reset}
		{note == 114} {w.play; z.stop; z.reset; x.stop; x.reset}
		{note == 115} {z.play; w.stop; w.reset; x.stop; x.reset}
		{note == 112} {w.stop; w.reset; x.stop; x.reset; z.stop; z.reset;} //A key to empty everything.
	});
)
