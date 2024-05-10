//5 - ENVELOPES, TRIGGER AND GATE

/////////////////////////////////////////////////////////////////////
//ENVELOPES

//Envelopes describe events over time. An envelope is usually defined by a series of segments or lines from one point to another in a specific amount of time. The shape of this line can vary (it can be linear, exponential, sinusoidal, etc.): the way in which the envelope moves from one point (value) to another is called interpolation or curve. In SuperCollider, two classes are needed to create an envelope: EnvGen is the Unit Generator of envelopes, and Env is used to create an envelope specification (to specify the value of the levels, times and curves of a default envelope, or, when sent a class method different from .new ("envelope creation methods"), to create different types of envelopes):
EnvGen.ar(Env(levels, times, curves), gate) //We will focus on this syntax and arguments for now: The arguments of Env.new are levels (an array of values in the "y" axis, defining frequencies, amplitudes or any kind of parameter the envelope is applied to), times (an array of times in seconds to go from one level to another, meaning that there will always be one less value of times than the number of level values), and curve (an array of symbols or numbers indicating the way the envelope moves from one value to the next).

//Let's study some options for the curve argument of the envelop:

//Linear curve:
Env([0, 0.5, 0.1, 0.5, 0], 1, \linear).plot //Graphical representation (straight lines).

( //Sonic result (applied to the amplitude of a sine oscillator):
{ var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, \linear); //The time from one level to the next will always be 1 in here.
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen //In order to apply the envelope to the amplitude of a signal, we simply multiply the signal by the envelope.
}.play
)
s.plotTree //When the envelope is done, the signal does not go away but just holds the last value given in the levels array. Here the last value is 0, so we cannot hear the sine wave anymore, but the synth is still running until we free it (see in the node tree). We will cover later some possible solutions for this in case we need the synth to behave in a different way when the envelope is done.

//Exponential curve:
Env([0.001, 0.5, 0.1, 0.5, 0.001], [1, 4, 6, 2], \exponential).plot //Graphical representation (curved lines). An exponential curve cannot touch nor cross 0.

( //Sonic result:
{ var signal, env, envGen;

	env = Env([0.001, 0.5, 0.1, 0.5, 0.001], 1, \exponential);
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//Step curve:
Env([0, 0.5, 0.1, 0.5, 0], 1, \step).plot //Graphical representation (leaps). Notice that the first level is "lost" as the first step is to directly jump to the second level. When working with, for example, frequencies, it would make sense to repeat the first frequency in order to hear it (see also the possible use of \hold instead of \step).

( //Sonic result:
{ var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, \step);
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//Curve defined by floats:
Env([0, 0.5, 0.1, 0.5, 0], 1, 8).plot //Graphical representation: 0 = linear, 4 = sort of exponential, 8 = closer to step, and upwards every time sharper, although it also depends on the speed of the segment (the corresponding value from the times array). Negative and positive values change the side from which the curve is "pulled" (positive = pulled towards the right; negative = pulled towards the left).

( //Sonic result (for instance):
{ var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, [4, -4]); //Almost equivalent to \exponential, but we can touch or cross 0.
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

Env([0, 0.5, 0.1, 0.5, 0], 1, [4, -4]).plot //Visualization of the previous envelope.

//Array of different curves:
Env([0, 0.5, 0.1, 0.5, 0], 1, [8, -4, \step, 0]).plot //Graphical representation, one kind of curve for each segment (also one less value than in the levels array).

( //Sonic result:
{ var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, [8, -4, \step, 0]);
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//See the help file of Env for a complete list of possible curves. Some of the ones we haven't touched yet are:
Env([0, 0.5, 0.1, 0.5, 0], 1, \hold).plot //Hold: just like \step, but it actually holds the first value, although not the last one. Compare again:
Env([0, 0.5, 0.1, 0.5, 0], 1, \step).plot
Env([0, 0.5, 0.1, 0.5, 0], 1, \sin).plot //Sinusoidal: "S" shaped segments.
Env([0, 0.5, 0.1, 0.5, 0], 1, \welch).plot //Welch: like sinusoidal, but the intersections are not rounded.
Env([0, 0.5, 0.1, 0.5, 0], 1, \sqr).plot //Squared segments.
Env([0, 0.5, 0.1, 0.5, 0], 1, \cub).plot //Cubed segments.


//Envelope of frequencies: we can apply envelopes to parameters other than the amplitude, such as the frequency:
(
{ var freq;

	freq = EnvGen.ar(Env([39, 61, 50] + 24, 2, \linear)).midicps; //Linear distribution among MIDI values, then conversion to Hz (if the conversion happens before, an exponential distribution would be more convenient to work with Hz).

	SinOsc.ar(freq, 0, 0.2) //The envelope is placed in the frequency argument of the signal. When the envelope is done, the signal holds its last level as frequency value.
}.play
)

//Method .circle and randomness. We can "loop" the envelope by applying the method .circle to the Env class, although it just jumps to the first value from the last one (no interpolation between last and first value). In addition to this, the possible randomly chosen values will be maintained instead of being refreshed:
(
{ var freq;

	freq = EnvGen.ar(
		Env(
			Array.fill(5, { rrand (60, 104) }),
			Array.fill(4, { rrand(0.2, 1) }),
			\linear
		).circle //Method .circle applied to Env.
	).midicps;

	SinOsc.ar(freq, 0, 0.1)
}.play
)

//Last example: filter bank (envelope applied to the grow argument) and possible trick for .circle:
(
{ var grow, freq;

	grow = EnvGen.ar(Env([2/1, 3/2, 7/4, 2/1], [2, 3, 2], \exponential).circle); //If the envelope finishes in the same value as it starts, the method .circle will seem to include an interpolation between both values (possible trick for now).

	freq = Array.geom(10, 35, grow);

	{ Mix(
		BPF.ar(
			PinkNoise.ar,
			freq,
			0.01,
			1
		)
	) } !2
}.play
)


//"Standard shape envelope creation methods" (these are also class methods): we can use different methods to create specific envelope shapes such as:
//Triangle envelope:
Env.triangle(1, 0.3).plot //Graphical representation.
{ SinOsc.ar * EnvGen.ar(Env.triangle(1, 0.3).circle) }.play //Sonic result.

//Sine envelope (usually used for granular synthesis, for instance):
Env.sine(1, 0.3).plot
{ SinOsc.ar * EnvGen.ar(Env.sine(1, 0.3).circle) }.play

//Percussive envelope:
Env.perc(0.01, 0.25, 0.3, -4).plot //The curve of a percussive envelope cannot be exponential because it will always touch 0.
{ SinOsc.ar * EnvGen.ar(Env.perc(0.01, 0.5, 0.3, -4).circle) }.play

//Trapezoidal envelope:
Env.linen(0.01, 1, 0.3, 1, \linear).plot //Includes an attack, sustain and release time, and the curve can be modified as well.
{ SinOsc.ar * EnvGen.ar(Env.linen(0.01, 1, 0.5, 0.3, \linear).circle) }.play

//Example:
//Nice "punchy" bass XD (only for good loudspeakers): a very sharp envelope is applied to the frequency, and a percussive envelope is applied to the amplitude:
{ SinOsc.ar(EnvGen.ar(Env([400, 40], 0.05)), 0, EnvGen.ar(Env.perc(0, 4))).dup(2) * 0.2 }.play

//Some other Env instance methods (apart from .circle and .plot, already studied):
e = Env([0, 0.5, 0.1, 0.5, 0], [1, 4, 6, 2], \linear)
e.duration //Returns the total duration of the envelope (the sum of the times array).
e.duration = 15 //Sets a new total duration of the times array by stretching them.

a = Env.adsr; //We will study this kind of envelope later (sustained envelope creation methods), but used here as an example.
a.levels; //Shows the current levels of the Env in "a".
a.range(42, 45).levels; //Returns a copy of the Env whose levels have been mapped onto the given linear, exponential or curve range:
a.exprange(42, 45).levels;
a.curverange(42, 45, -4).levels;

{ SinOsc.ar(EnvGen.ar(Env.perc(0.01, 0.7).exprange(80, 10000), doneAction: Done.freeSelf).poll(30)) * 0.1 }.play// Mapping an Env to an exponential frequency range (possible use of the previous methods). We will talk about the argument doneAction later on.
{ EnvGen.ar(Env.perc(0.01, 0.7).exprange(80, 10000)) }.plot(0.5) //Visualization of the previous envelope.


/////////////////////////////////////////////////////////////////////
//TRIGGER

//The second argument of EnvGen is "gate". Gate is 1 by default as, as far as it is 1, it will trigger the envelope and hold it open. Though in order to use the argument gate as a real gate we need a different kind of envelope that can be sustained. Gate can be used as a trigger for those envelopes that cannot be sustained in order to "reboot" the envelope every certain amount of time (this is equivalent to the method .circle, but now we don't depend on the duration of the envelope but on the frequency of the trigger):
(
{ var trigger, signal, env;

	trigger = Impulse.ar(1); //Impulse will trigger the envelope 1 time per second (try with freq of 2 and with Dust).
	signal = SinOsc.ar;
	env = EnvGen.ar(Env.perc(0.01, 0.5, 0.3), trigger); //If the release of .perc is longer than the frequency of the impulse, we will never hear silence between the envelopes (try with release = 2).

	signal * env
}.play
)

//A trigger is anything that causes a reaction. In SC, a trigger is produced when zero is crossed in the input of the trigger. This is why we usually use Impulse (or Dust) or a Pulse oscillator for this.

//Randomness: same random values (times and freqs) will be kept every time the envelope is retriggered:
(
{ var freq, trigger, time, signal;

	trigger = Impulse.ar(1/4); //It does not matter if the envelope is completed: every four seconds it is rebooted (if longer than 4 seconds, it is cut, and if shorter than 4 seconds, last value is sustained until next trigger).
	time = [rrand(0.5, 3)]; //Random time chosen between 0.5 and 3 seconds. If the random choice was made directly into the expanded envelope, each envelope would feature a different time value. This will also happens if the rrand is sent within a function (between curly brackets), as several instances of the function will be executed (instead of duplicating the same array).

	//Array of five envelopes (each envelope features five random levels used as frequencies in the SinOsc), bringing about five sine oscillators. A further note about Env multichannel expansion: in here we are directly creating an array of EnvGen, but another option is to simply assign an array to one of the values in any argument of Env, as the Help file explains: "If one of the values within either levels, times, or curves is itself an array, the envelope expands to multiple channels wherever appropriate. This means that when such an envelope is passed to an EnvGen, this EnvGen will expand":
	freq = Array.fill(5, {
		EnvGen.ar(Env(Array.fill(5, { exprand(60, 78).midicps }), time, \step), trigger) //Because of the step curve, we only hear four frequencies (if the trigger allows them to be heard before rebooting).
	});

	signal = Mix.ar(
		SinOsc.ar(
			freq,
			0,
			0.1
		)
	) !2;

	signal * 0.3

}.play
)

//Next example uses the SoundIn signal from the mic as a trigger (including a threshold of amplitude, here 0.05). Try clapping or speaking close to the computer's mic:
(
{ var trigger = SoundIn.ar(0) > 0.05; //Amplitude coming through the mic has to be over 0.05 (change this threshold as needed).

	SinOsc.ar(
		//TChoose.ar(trigger, K2A.ar(Scale.minor.ratios * 72.midicps)), //Another possibility (using K2A to turn control to audio signals, as the postwindow tells us that the "Select input was not audio rate". TChoose expects an array of signals, that is why it complains when receiving numbers. There is also A2K object). Using random frequencies from a minor scale within the octave of C5.
		TRand.ar(262, 1200, trigger), //Random frequency produced by TRand every time it receives a trigger.
		0,
		EnvGen.ar(Env.perc(0.01, 1), trigger) //Percussive envelope sharing the same trigger as the random frequency choice.
	).dup(2) * 0.3 //Multichannel expansion and amplitude balance.

}.play
)


/////////////////////////////////////////////////////////////////////
//GATE

//In order to use the argument gate as a real gate, we need an envelope with sustain time, that is to say, any of the so-called sustained envelope creation methods (.adsr, .asr, .dadsr, etc., see the help file of Env for more). When gate receives a 1, the attack (and possible decay) of the envelope is triggered and the envelope hold at its sustain level, and when gate receives a 0, the release segment of the envelope is triggered.

//Basic syntax of method .adsr:
Env.adsr(attackTime, decayTime, sustainLevel, releaseTime, peakLevel, curve) //Arguments are the attack time (from silence to peak level), decay time (from peak level to sustain level), sustain level (ratio of level depending on the peak level: if sustain level = 1, then it will be equal to the peak level and the decay segment won't be heard, if sustain level = 0.5, it will be half of the peak level), release time (from sustain level to silence), peak level (maximum amplitude peak), and curve (excluding exponential as it will touch 0, but which can be imitated with floats [4, -4], for example).

//Graphical representation:
{ EnvGen.ar(Env.adsr, LFPulse.ar(1)) }.plot(1) //When LFPulse's width = 0.5, and freq = 1, the envelope will feature 0.5 seconds of ads and 0.5 seconds of release (and possible silence depending on the release time).
{ EnvGen.ar(Env.asr, LFPulse.ar(1)) }.plot(1) //Same here (using method .asr), although there is no decay time.
//Other sustained envelope creation methods simply feature a different arrangement of segments.

//Applying gate:
(
a = { |gate = 1| //Default value (envelope is immediately triggered by default when executing the function).
	var env;

	env = EnvGen.ar(Env.adsr(0.1, 0.2, 0.5, 1, 0.2, -4), gate);

	SinOsc.ar !2 * env
}.play
)

//We can use the method .set to change the arguments of a signal running in the server (the arguments are called through symbols):
a.set(\gate, 0) //Gate = 0 triggers the release of the envelope.
a.set(\gate, 1) //Gate = 1 triggers a new attack, decay and sustain of the envelope.
a.set(\gate, -1) //Gate = -1 cuts the envelope (if open) with no release time (produces a click).
//Meanwhile, the envelope continues running in the server even when there is no sound (see node tree). The synth is the same, gate = 1 does not produce a new instance of the envelope, it just retriggers the one already running in the server.

//Other examples:
//Using a pulse oscillator to automatize opening and closing the envelope (as it sends 1 and 0 to the gate periodically). As mentioned before, the width argument in LFPulse can be used to change the ratio between the time the gate is open and closed (here, when using 0.5 of width, as the pulse's trigger happens every 5 seconds, there is 2.5 seconds of open gate and 2.5 of closed gate).
(
{ var gate, signal, env;

	gate = LFPulse.ar(0.2, 0, 0.5);

	signal = SinOsc.ar;

	env = EnvGen.ar(
		Env.adsr(0.01, 0.1, 0.3, 1, 0.3),
		gate
	);

	signal * env
}.play
)

//We can also use MouseButton to open and close the envelope: when clicking, the gate will receive 1 and the envelope will be triggered. The sustain level will be sustained as far as we hold the button pressed. Then, when the button is released, the release segment is triggered.
(
{ var gate, signal, env;

	gate = MouseButton.kr(0, 1);

	signal = SinOsc.ar;

	env = EnvGen.ar(
		Env.adsr(0.01, 0.1, 0.3, 1, 0.3), //The release time is quite long, 1 second (if we don't wait that time before clicking again, the sound won't stop).
		gate
	);

	signal * env
}.play
)


/////////////////////////////////////////////////////////////////////
//DONE ACTION

//doneAction is the last argument of EnvGen (see in the help file of EnvGen, information about the argument doneAction: open the documentation about Done. At the end of that document, https://doc.sccode.org/Classes/Done.html, there is a list of actions that can be implemented with doneAction). doneAction = 0 means "do nothing when the UGen is finished" (by default, what happens in our envelopes), and doneAction = 2 means "free the enclosing synth" (meaning that the synth will stop running in the server, and disappear from the node tree). The class Done itself can be used as well when applied methods such as Done.freeSelf (as seen in a previous example in this document), which would fulfill the same function as number 2 in doneAction.

(
a = { |gate = 1|
	var env;

	env = EnvGen.ar(Env.adsr(0.1, 0.2, 0.5, 1, 0.6, -4), gate, doneAction: 2); //Usually applied using keyword assignment as it is the last argument.

	SinOsc.ar !2 * env * 0.3
}.play
)

a.set(\gate, 0) //When sending 0 to the gate, the envelope is finished and doneAction 2 frees the synth in the server (check the node tree: the synth is gone).
a.set(\gate, 1) //Sending 1 to the gate again is no longer possible because the synth does not exist anymore.
//This will be beneficial when creating several instances of a SynthDef (synth definition) later on, so that those instances do not silently accumulate in the server and consume CPU power.


/////////////////////////////////////////////////////////////////////
//ADDITIONAL ENVELOPE RESOURCES

//Line generators:
//Line and XLine are line generators (similar result in the following two examples). The arguments are the starting value, end value and time in seconds:
{ SinOsc.ar(Line.ar(60, 84, 2).midicps, 0, 0.1 !2) }.play //Linear line generator (if applied to frequency, works better with MIDI values).
{ SinOsc.ar(XLine.ar(260, 1046, 2), 0, 0.1 !2) }.play //Exponential line generator (if applied to frequency, works better with Hz).

{ LPF.ar(LFSaw.ar(40), XLine.ar(600, 40, 2)).dup(2) * 0.1 }.play //Example: nice bass beat, but the sound does not go at the end (Line holds the last value, just like any other envelope).
{ LPF.ar(LFSaw.ar(40), XLine.ar(600, 40, 2, doneAction: 2)).dup(2) * 0.1 }.play //Now the signal is gone after the line, but causing a click. Solution:
{ LPF.ar(LFSaw.ar(40), XLine.ar(600, 40, 2, doneAction: 0)).dup(2) * Line.ar(0.2, 0, 2, doneAction: 2) }.play //Another line is applied to the amplitude and doneAction is applied to the amplitude envelope to cut the filter properly with no clicks.


//##############################################################
//Advanced example (for SynthDefs):

//The Env class method .newClear creates an "empty" envelope with a specific number of segments and channels, so that it can be filled in later:
Env.newClear(numSegments: 8, numChannels: 1) //Arguments.

//According to the Env help file, "this can be useful when passing Env parameters as args to a Synth. Note that the maximum number of segments is fixed and cannot be changed once embedded in a SynthDef" (once the SynthDef is compiled). Example from the help file:
(
SynthDef(\help_Env_newClear, {
	|out = 0, gate = 1|
    var env, envctl;

    //Empty 4-segment envelope:
    env = Env.newClear(4);

	//Control argument array (see .kr as an instance method of Env in the Help file):
    envctl = \env.kr(env.asArray); //.asArray converts the Env to an Array in a specially ordered format. This allows for Env parameters to be settable arguments in a SynthDef.

    Out.ar(out, SinOsc.ar(EnvGen.kr(envctl, gate)) * -12.dbamp) //Balancing the amplitude.
}).add
)

Synth(\help_Env_newClear, [\env, Env([700, 900, 900, 800], [1, 1, 1], \exp)]); //Remember, the number of levels is fixed in the SynthDef.

Synth(\help_Env_newClear, [\env, Env({ rrand(60, 70).midicps } !4, [1, 1, 1], \exp)]); //Random levels.​
//#####################################################
