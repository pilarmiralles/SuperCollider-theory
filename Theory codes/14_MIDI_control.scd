//14 - MIDI COMMUNICATION
////////////////////////////////////////
//MIDI stands for Musical Instrument Digital Interface. It is a communication protocol for allowing musical devices to talk to each other.
//Some guides in the SC Help: https://doc.sccode.org/Guides/UsingMIDI.html and https://doc.sccode.org/Guides/MIDI.html
//Nice introduction and more in these YT tutorials: https://www.youtube.com/watch?v=Oz4KYZ9KLc0&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=11 (part I) and https://www.youtube.com/watch?v=ih2uqOaqb4c&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=19 (part II).

MIDIClient.init; //Initiates the MIDI communication with your operating system to get its knowledge of available MIDI devices. Retunrs a list of MIDI sources and destinations (should detect connected MIDI interfaces).
MIDIIn.connectAll; //Connects SuperCollider with all available MIDI devices.
//If we needed to connect only a specific device (though MIDIIn.connectAll should work just fine anyway):
MIDIClient.sources //Returns the array of MIDI sources.
MIDIIn.connect(0) //Allows to specify the source via its index in the previous array.

//There are two main classes to interact with MIDI data: MIDIFunc and MIDIDef. MIDI Def is a subclass of MIDIFunc. They both allow us to take a certain action whena certain type of MIDI message is received:
MIDIFunc.trace(true); //Printing the values (to test).
MIDIFunc.trace(false); //Stop printing the values.

//Normally when using, for instance, a keyboard controller, we deal with noteOn and noteOff messages.
//NoteOn and noteOff:
MIDIdef.noteOn(\noteOnTest, {"key down".postln}); //The arguments are the key (a symbol which needs to be different for each action, as they will be saved into a Dictionary through indentity), and the function to perform. This would work with all keys as we are not specifying it.
MIDIdef(\noteOnTest).disable //Frees noteOn from the previous action.
MIDIdef(\noteOnTest).disable //Reactivates the previous action for noteOn.
MIDIdef(\noteOnTest).free //Destroys the action for noteOn.
MIDIdef.freeAll //To empty all the dictionary of keys (if using multiple MIDIdefs). MIDIdef is also "destroyed" by pressing ctrl + period.
MIDIdef.noteOn(\noteOnTest, {"key down".postln}).permanent_(true); //This prevents the ctrl + period command to "destroy" the MIDIdef.
MIDIdef(\noteOnTest).permanent_(false); //Ctrl + period destroys it again.

//We can use MIDIdef to control several MIDI data such as note number, velocity, MIDI channel, etc. In order to do that, we need to declare arguments within MIDIdef's function: the arguments passed in .noteOn, .noteOff and .cc are val, num, chan, src in that order, although they can receive different names (they will mean different things depending on the method: for .noteOn, they will represent, for instance, velocity, note number, MIDI channel and the identifier number associated with the source device):
MIDIdef.noteOn(\noteOnTest, { arg vel, note, chan, src; [vel, note, chan, src].postln }) //Just printing an array of the four values, which we will see in the postwindow (the last number is the source ID, might be useful for differentiating devices sending the same data). Channel will be 0 by default (a MIDI cable in SC represents channels 0-15).

//By default, the output sound will be the SynthDef "\default" from SC, which is the ugly piano sound. But we can use any synth created in SC:
(
MIDIdef.noteOn(\noteOnTest, {
	arg vel, note;
	[vel, note].postln
	{
		var signal, env;
		signal = SinOsc.ar(note.midicps) !2; //Note is applied to the frequency of a sine oscillator. We could use any kind of oscillator or sound generator in here instead of SinOsc.
		env = EnvGen.ar(Env.perc, doneAction: 2); //Using an envelope instead of noteOff messages sothat the synths turn themselves off.
		signal = signal * env * vel.linexp(1, 127, 0.01, 0.3); //Velocity is implemented as amplitude multiplier. As velocity values go from 1 to 127, we need to normalize these values to the 0-1 range (using the linear range to exponential range method). Take care of the upper amp limit when playing several notes at the same time.
	}.play
})
)

//We can use a SynthDef instead of a function.play as a more efficient synthesis source. In addition, we will use here an envelope adsr so that noteOn can be used to initiate the envelope, and noteOff can be applied to release it.
//In order not to overwrite the Synth with a new note, this guy is using the strategy of creating an empty array of 128 elements, as there are 128 notes in MIDI. Each synth will be stored in its particular place within that array (its index will be equal to the note number). When releasing the note, the Synth should be freed at that index.
//Remember that after pressing ctrl + period, the MIDIdef needs to be evaluated again by default.

//Array of notes and other global variables:
~note = Array.newClear(128) //An empty array with size = 128.
~bend = 8192 //Resting position of the possible bend wheel (might change according to the device, so check it first with MIDIdef.bend).

//SynthDef:
(
SynthDef(\midiSynth, {
	arg freq = 440, amp = 0.3, gate = 0, bend; //Gate = 0 by default.
	var signal, env;

	signal = LDTri.ar(freq * bend.midiratio) !2; //Applying the pitch bend to the frequency and converting semitones into frequency ratio.
	env = EnvGen.ar(Env.adsr, gate, doneAction: 2); //Default adsr envelope.

	signal = signal * env * amp;

	Out.ar(0, signal)
}).add
)

//MIDI control block (noteOn, noteOff, bend...):
(
//MIDIdef for noteOn:
MIDIdef.noteOn(\noteOnTest, {
	arg vel, note;
	[vel, note].postln;

	~note[note.asInteger] = Synth(\midiSynth, //Storing the Synth in the notes array at the index equal to the note number.
		[
			\freq, note.midicps,
			\amp, vel.linexp(1, 127, 0.01, 0.3),
			\gate, 1,
			\bend, ~bend.linlin(0, 16383, -2, 2) //We need to acknowledge the value of the bend wheel in noteOn and apply the current position to the initial frequency so that if we move the wheel and then strike a note, the pitch bend will be applied (same values as in MIDIdef.bend).
		]
	)
});

//MIDIdef for noteOff:
MIDIdef.noteOff(\noteOffTest,{
	arg vel, note;
	[vel, note].postln;

	~note[note].set(\gate, 0); //Addressing the current Synth within its corresponding index in the notes array.
	~note[note] = nil; //Emptying the corresponding index.
});

//Other possible MIDI messages are .bend and .cc. We can create here another MIDIdef for a possible bend wheel in our MIDI device (.bend only passes the arguments val, chan and src). Also, the bend wheel (and whichever MIDI control) can be used for things other than pitch bend: some kind of modulation, frequency or amplitude deviations, etc.
MIDIdef.bend(\bendTest{
	arg val, chan;
	[val, chan].postln;
	~bend = val;  //This is just to keep track on the bend value from the global variable.
	~note.do({ arg synth; synth.set(\bend, val.linlin(0, 16383, -2, 2)) })  //Now, we need to map the value of the bend according to each note. We can iterate this task using .do. The range of the pitch wheel will be from down a whole step to up a whole step of each pitch (-2 to 2, in semitones, then converted in the SynthDef with .midiratio and applied to the freq in Hz). The range of values of the wheel (the input of linlin) might change according to the device (check them first by posting them).
})
)

//In case any of the controls (keys, controls, bend wheel, etc.) send by some reason values through other channels that we don't want, we can use the channel argument of MIDIdef itself, which allows us to take into consideration only the data from the specific channel written in there.

//MIDIdef.cc responds to continuous controller messages such as knobs, buttons, faders, sustain pedals, etc. .cc passes the same four arguments as in noteOn and noteOff.
MIDIdef.cc(\cc16, { arg val, ccnum; ~cc16 = val}, 16); //For MIDI control (.cc): Arguments are key (\symbol), function and control number.

//The second part of the before-mentioned tutorial (https://www.youtube.com/watch?v=ih2uqOaqb4c&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=19) explains how to generate MIDI data in SC and send it out to external devices instead of receiving it in from external devices (which was introduced in this document). Basically, how to connect SC to, for instance a DAW and synthesis plug-ins in order to work with MIDI data. It is usually necessary to have some kind of driver allowing the MIDI communication between both programs (such a driver should be visible when evaluating MIDIClient.init).
