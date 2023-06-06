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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Let's try to connect SC to Reaper (or any DAW) in order to send MIDIOut messages to some sort of virtual synthesizer (VSTi). These instructions apply to Windows.
//I am using LoopMIDI and MIDI-OX (those are free softwares)in order to create virtual MIDI busses which serve as locations for sending and receiving MIDI data. This is the needed configuration to enable the MIDI communication:
/*
1 - Open LoopMIDI and create two ports (below, in "new port-name" and the "+" symbol (I called my new ports "SC out" and "Reaper in").
2 - Open MIDI-OX and go to Options --> MIDI devices: select "Reaper in" as MIDI input and "SC out" as MIDI output, and click on "OK". For a more clear understanding of what is happening, you can open the "Monitor - Output" and "Monitor - Input" as floating windows to see the MIDI data in and out.
3 - Now we can configure Reaper: I was using ASIO driver for the sound, but if using the headphones, I think "Direct sound" shouldn't pose any problem. Then I go to MIDI Devices, in the Audio Preferences in the Options menu (in there, you should be able to see the new MIDI ports created in LoopMIDI): it is necessary to enable the MIDI input devices by right clicking on each device and choosing "enable" (or "enable+control"), then Apply and Ok. Go to Track --> Insert virtual instrument on new track: the recording buttom on the track should be on (on red) and the record monitoring (the little speaker icon) should be ON. Open the "in FX" little menu and choose "Input: MIDI" --> "SC out" --> Channel 1. Last, but not least, we need an FX with a virtual instrument (I have nothing so I will use the default "ReaSynth" from Reaper and I will put some Sawtooth mix just to try).
4 - Let's go to SC now:
*/

//As always, we initialize the MIDI communication: we can see then in the postwindow all MIDI divices, MIDI sources and MIDI destinations:
MIDIClient.init

//We can communicate with a specific MIDI port in two ways:
//Way one is to ask about the MIDI destinations, which are represented in an array. Then all we need to do is to assign the specific index from the array (we need the "Reaper in" port) to a MIDIOut object and to assign the object to a variable:
MIDIClient.destinations
m = MIDIOut(4)

//Way two is to use this other method, which allows us to specify the device name and the name of the port:
m = MIDIOut.newByName("Reaper in", "Reaper in", dieIfNotFound: true)

//We can test the communication with a simple noteOn and noteOff message sent to "m". These methods receive three values: the channel, the note, and the velocity. The channel should be equal to the channel from "SC out" that the track in Reaper is listening to (take into account that channel 0 in SC is channel 1 in Reaper). Then the note and velocity (pitch and amplitude) respond to values from 0 to 127).
m.noteOn(0, 60, 30)
m.noteOff (0, 60) //noteOff needs to address the channel and note number. NoteOff's velocity value will be most likely ignored by most synthesizers, so it does not really matters.
m.latency = 0.2 //This message adds a delay to each sent message. By default, it is 0.2. If set to 0, the messages are sent inmediately. Though take into consideration that some virtual instruments have their own built-in latency.

//An iteration of MIDI notes will bring about a chord:
[35, 49, 56, 63, 66, 73].do({ |note| m.noteOn(0, note, 20) })
[35, 49, 56, 63, 66, 73].do({ |note| m.noteOff(0, note, 20) })

//We can make this happen over time by using a Routine:
(
Routine({
	[35, 49, 56, 63, 66, 73].do({
		|note|
		m.noteOn(0, note, 20);
		0.5.wait
	})
}).play
)

(
Routine({
	[35, 49, 56, 63, 66, 73].reverse.do({ //This, with noteOff, to turn the notes in the reverse order.
		|note|
		m.noteOff(0, note, 20);
		0.5.wait //If no wait time, all notes would be released together.
	})
}).play
)

//REMEMBER: All tranformations of the sound itself need to be carried out in Reaper, in the virtual instrument itself (and according to its own control possibilities, which normally include at least envelope and timbre qualities). SC's audio server is not even booted as the sound synthesis is happening in  Reaper.
//Also remember that anything played from SC in Reaper can be recorded as the values are being sent (the recording process happens in Reaper instead of SC).

//New Routine, now turning on and off each note before the next comes, and looping the entire thing:
(
r = Routine({
	inf.do({ //inf.do could be replaced by "loop"{}
		[35, 49, 56, 63, 66, 73].do({
			|note|
			m.noteOn(0, note, 20);
			0.1.wait;
			m.noteOff(0, note, 20);
			0.2.wait //0.2 seconds of silence between each note (try 0.1).
		})
	})
}).play
)

//The r.stop does not work if a note hasn't been turned off before executing it, and comand period does not affect as the synthesis is happening in Reaper. We can use instead this message:
m.allNotesOff(0) //With this specific synthesizer, it works, but the guy in the tutorial said that it does not always works as not all synthesizers understand this message.
//So, a better solution for this is to iterate the message .noteOff for all 128 possible note values at once:
(0..127).do({ |note| m.noteOff(0, note) }) //This should do it.

//A recommendation from the tutorial: midi.org --> Specs --> MIDI Reference Tables --> Summary of MIDI messages: you can find there, for example, the message "allNotesOff" (it is not a SC specific method, but it is comming from MIDI protocol).


//Now moving on to .cc messages (normally triggered by a knob, a fader, etc., for general purpose controls, normally continuous ones). See in the same web page, midi.org, some specific channels for controlling specific values, which could be automatically used as a convention by some synthesizers. For example:
m.noteOn(0, 60, 20) //We create a note.
m.control(0, 7, 60) //Arguments are channel, control number and value. Supposedly, control number 7 should address the amplitude, but in this case, it is not being recognized by the synthesizer I am using.
//Anyway, not all possible controls are predefined in the MIDI specifications, so we can use any of the "undefined" control number to be assigned to those parameters (for example, 20, 21, or 22 are undefined). For example, in order to control the "Sawtooth mix" fader, we can select that fader, go to "param", choose "learn", send the control message from SC and change around the fader in Reaper so they are somehow associated.
m.control(0, 20, 64) //Yes, it worked, and it is already mapped so that 0-127 turns into 0-1 ratios in the Sawtooth mix bar.
m.control(0, 21, 64) //This one is now linked to the "Extra sine mix".
//Of course, this is different in every MIDI instrument, but they all normally feature the learn option.

//Let's try this within the routine:
(
Routine({
	inf.do({
		var note = rrand(28, 40); //Choosing a random pitch (can replace this by another .do sent to a specific sequence of notes within an array.

		m.noteOn(0, note, 20); //Random pitch.

		(30, 40..100).do({ //Iterating over multiples of ten from 30 to 100.
			|val|
			m.control(0, 20, val); //Iterating different values of Sawtooth mix.
			0.15.wait
		});
		m.noteOff(0, note); //Turning off each note with every iteration of the infinite loop.
	})
}).play
)

m.allNotesOff(0)


//Though everyone knows already that Routines are not the best option for these kind of algorithmic pattern composition, so let's turn to Pbind. Also, by using Pdef, we will be able to perform some real-time manipulation.
//In the "Pattern Guide 08: Event types and patameters", there is a list of keys related to MIDI output.
//(right now the amplitude values are a bit suspicious, Idk what is the problem, but anyway)...
(
Pdef(\djSession, Pbind(
	\type, \midi, //The "instrument" in this case is the MIDI communication.
	\midicmd, \noteOn,//This allows to apply all sorts of MIDI messages, such as noteOn, noteOff, allNotesOff, etc.
	\midiout, m, //The midiout key needs to point at the MIDIOut object (here, in variable "m", as previously assigned).
	\chan, 0, //The channel.
	\midinote, Pwrand([62, 74, 86, 98], [0.1, 0.8, 0.08, 0.2].normalizeSum, inf), //The MIDI note values (can start applying patterns :3).
	\amp, Pexprand(0.1, 0.8, inf), //amp goes to the velocity control, but in values from 0 to 1! (or can use the same MIDI values like this 63/127, which would be, for example 0.5 amp).
	\sustain, 0.02, //This is really useful: it is the time to wait in seconds after a note on before sending the corresponding note off message. This is one of the many advantages of using Pbind in this situation instead of a Routine.
	//\dur, 1/16 * (120/60)//Time between succesive events. If this is longer than the sustain value, then there will be a silence between each note. Also, can change the tempo like this (16th notes in a 120 bpm tempo here).
	\dur, 1/16, //Alternatively, you can set here the "note value", and use the key stretch to calculate the duration of a 4/4 time at 120 bpm (so that we can apply quantization later to the bar length.
	\stretch, 4 * (60/120)
)).play(quant: 4 * (60/120))
)

(
Pdef(\djSession_cc20, Pbind( //Now this Pbind will control the Sawtooth mix parameter (previously assigned to control 20).
	\type, \midi,
	\midicmd, \control,
	\midiout, m,
	\chan, 0,
	\ctlNum, 20,
	\control, Pexprand(1, 80, inf).round(1), //.round to get rid of the floats produced by Pexprand (so that the sine wave ish sound will be prominent most of the time).
	\dur, 1/16, //Same dur and stretch values, so that this is synchronized to the previous Pbind. You can directly execute them both or first one, then the second.
	\stretch, 4 * (60/120)
)).play
)

//The MIDI channel does not have anything to do with the audio output channels (just make sure that Reaper is sending audio to both channels in the stereo, if using ASIO, set in Preferences --> Audio --> Device. You could create now another Pbind connected to channel 1, then create a different instrument track in Reaper with a different (or the same) synthesizer and create, for example, random chords (expressed as arrays of midi notes, like this, for example, though now I am just sending it to channel 0 again). Anyway, you can use the same synthesizer for both of them, of course...
(
Pdef(\djSession_chords, Pbind(
	\type, \midi,
	\midicmd, \noteOn,
	\midiout, m,
	\chan, 0,
	\midinote, Pxrand([
		[38, 50, 72, 77, 81],
		[43, 55, 70, 77, 79],
		[46, 58, 69, 74, 77, 84] //Idk why in the tutorial the last one has one more notes, but does not matter.
	], inf),
	\amp, Pwhite(0.005, 0.01, inf), //Needs compensation because of the chords?
	\sustain, Pxrand([1, 2, 4], inf), //This is also measured now in "bars"?
	\dur, Pxrand([0.5, 1, 1], inf), //Generating a new chord every 4, 6, or 8 bars (those were the preliminary values).
	\stretch, 4 * (60/120)
)).play(quant: 4 * (60/120)) //Now, if playing alongside the other Pbind, we need to quantize (both of them) in the play method.
)

//Now we could apply some reverb in Reaper and other effects to the track of the instrument (or routing the track to an effects track).
//Also, Pdef will allow us to change any value at running time (with this quantization, changes will apply in the next available downbeat).

//Still, this does not work if I want to stop it while a note is being played:
Pdef(\djSession_cc20).stop
Pdef(\djSession).stop
Pdef(\djSession_chords).stop

m.allNotesOff(0) //Just in case.

//In the synthesizer I am using, the envelope's release time does not really seem to work, but anyway it is clear to me that I would need some more fancy synth if I want using Reaper to be worth while, but anyway, I can open the UI option of the synth for a "better" graphical interface.


//These following lines were shared by Alejandro Olarte, but now I should rearch for a better instrument, program some other cool control parameters, and create my own sequences. A nice addition could be to actually control the control parameters by using an external MIDI device (a MIDI controller).

Scale.directory //All scales here, as a reference if using the class Scale.

(
var tempi = 80;
Pdef(\ch1,
	(Pbind (
		\type, \midi,
		\midicmd, \noteOn,
		\midiout, m,
		//\instrument, "default",
		\chan, 0,
		\scale, Scale.minor,
		//\scale,  Scale.spanish,
		//\scale,  Scale.saba,
		//\scale,  Scale.zamzam,
		\octave, 2,
		//\chan, Pseq((..5),inf),
		//\midinote, Pxrand(#[60, 62, 63, 66, 72],inf),
		\midinote, Pxrand(Array.fib(5,1,2) + 48,inf),
		//
		//\midinote, Pxrand((1..12)+60,inf),
		//\midinote, Pseq((45..36)+12,inf),
		//\midinote, Pseq((30..84),inf),
		//\midinote, Pxrand((0..36)+36,inf),
		//\midinote, Pseq([36,Pxrand([38,39],1),Pxrand([40,41,42],1),Pxrand([45,47],1)],inf)+36,
		//\midinote, Pseq([82,83],inf),
		//\midinote, Pseq([1,3,5,7,9,11]+40,inf),
		//\midinote, Pseq([1,3,5,7,9]+40,inf),
		//\midinote, Pseq([36,37,38,39,40]+12,inf),
		//\midinote, Pseq([[0,2],[4,5,7],[9,10]]+60,inf),
		//\midinote, Prand([[0,2],[4,5,7],[9,10],11,12]+60,inf),
		//\midinote, Pseq([Prand((..12),1),Prand((..12),1)]+60,inf),
		//\midinote, Prand((..12)+60,inf),
		//\midinote, Pseq([Prand((..2)+60,1),Prand((5..12)+60,1)],inf),
		//\midinote, Pseq([Prand((..4)+60,1),Prand((5..12)+60,1)],inf),
		//\midinote, Pseq([60, Prand((..4)+60,1),Prand((5..12)+60,1) ],inf),
		//\midinote, Prand([0,2,3,5,7,8]+48,inf),
		//\midinote, Pseq([40,42,44]+12,inf),
		//\degree, Pseq((0..7) ++ (6..0) ++ [\rest],inf),
		//\degree, Pxrand([0,2,3,5,7,8,9]++ [\rest] ++ [\rest] ++ [\rest] ++ [\rest],inf),
		//\degree, Pseq([3,2,0]++ [\rest] ++ [\rest],inf),
		//\degree,  Prand([Pseq([3,2,0]++ [\rest] ++ [\rest],2),Pseq([7,5,3,2,0]++ [\rest] ++ [\rest],2)],inf),
		//\degree,  Prand([Pseq([3,2,0]++ [\rest] ++ [\rest],1),Pseq([7,5,3,2,0]++ [\rest] ++ [\rest],1), Pseq([\rest],1), Pseq([0,3,2,3],1)],inf),
		//\degree, Prand((0..7) ++ (6..0),inf),
		//\degree, Pseq((0..12) ++ (12..1),inf),
		//\degree, Pxrand((0..12) ++ (12..1),inf),
		//\midinote, Pseq([60,62,63,65,67,68,71,72],inf),
		//\midinote, Pseq([0,2,3,5,7,8,11],inf)+Pseq([60!7,63!7,65!7,67!7,68!7,71!7,72!7].flat,inf),
		\amp, 0.1,
		//\dur, Pxrand([1,3,5,8],inf)
		//\dur, Pxrand([1,0.5,0.25]*0.5,inf)
		//\dur, Pxrand([0.33,0.25,0.1]*0.5,inf)
		//\dur, ((60/tempi)*(1/1))
		\sustain, 0.1,
		\dur, ((60/tempi)*(1/8))
		//\dur, ((60/tempi)*(4))
	).play
	)
)
)

Pdef(\ch1).stop //For some reason, this does not stop the Pdef in this case.
m.allNotesOff(0)
