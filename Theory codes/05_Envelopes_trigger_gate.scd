//5 - ENVELOPES, TRIGGER AND GATE
////////////////////////////////////////////////

//ENVELOPES:
//Envelopes describe events that change over time. Two classes are needed to create an envelope: EnvGen, the Unit Generator of envelopes, and Env, which allows us to specify the characteristics of the envelope that EnvGen will create.

Env.new(levels, times, cirve) //we will use these three first argument in Env (it is not necessary to specify the method .new, as it happens with Mix.new and many other UGens). Imagining an envelope as a waveshape: "Levels": points at the "y" axis within an array (for example, [0, 1, 1, 0], which can be defining frequencies, amplitudes, etc.)/ "Times": how many time does it takes for going from one of the level points to the next, written in seconds within an array --> there will be always one less value than in the array of levels, because the time points are "in between" the level points / "Curve": how do we move from one value to the next, what is called "interpolation" (for instance, \linear (by default), \exponential, \sine, \step (no interpolation, so it goes from one value to the next directly). It does not matter how you go between two levels that are equal. Those names were premade curves, but in this argument it can also be used a positive or negative float (value of the curve of the segments), or an array mixing any of the former options (for example, the curve [-4, 4] is quite close to an exponential).

//LINEAR:

Env(curve: \linear)

(
Env(
	[0, 0.5, 0.1, 0.5, 0], //Levels.
	[1, 1, 1, 1], //Durations in seconds (can be summarized in just a 1, because it will be cyclically distributed among the levels array).
	\linear
).plot //Graphical representation.
)

//Applying the envelope to the amplitude of a signal, for instance (multiplying the envelope by the signal means multiplying the values of the envelope by the amplitude of the signal):
(
{
	var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, \linear); //The time from one level to the next will always be 1 in here.

	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//EXPONENTIAL: an exponential function can never reach the 0, nor cross it. This is why we use here a value close to 0 (0.001, for instance):
Env(curve: \exponential)

(
Env(
	[0.001, 0.5, 0.1, 0.5, 0.001],
	[1, 4, 6, 2],
	\exponential
).plot
)

//Sound result, applied again to the amplitude of a sine wave:
(
{
	var signal, env, envGen;

	env = Env([0.001, 0.5, 0.1, 0.5, 0.001], 1, \exponential);
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//STEP: means that there is no interpolation:
Env(curve: \step)

(
Env(
	[0, 0.5, 0.1, 0.5, 0],
	1,
	\step
).plot //Looks like a square / pulse wave.
)

//Sound result, applied to the amplitude of a sine wave: direct sound, no transition between values. The second value will sound directly because the first "step" is to jump from the first to the second values:
(
{
	var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, \step);
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//USING FLOATS: in order to draw the envelope line ourselves. Negative floats will pull the line to the left / Positive floats will pull the line to the right. The higher the number, either positive or negative, the accute the line, cutting distance with the aspect of the square or pulse wave (just like when using \step):
(
Env(
	[0, 0.5, 0.1, 0.5, 0],
	1,
	4 //Four is a value that works quite well for the curve of the envelope, but any number might be tested.
).plot
)

//Sound result, applying it again to the amplitude of a sine wave:
(
{
	var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, -4);
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//Mixing negative and positive numbers, we can build an envelope pretty close to the premade ones, but we can control all parameters:
(
{
	var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, [4, -4]); //This one is close to an exponential.
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//USING AN ARRAY: mixing different parameters:
(
Env(
	[0, 0.5, 0.1, 0.5, 0],
	1,
	[8, -4, \exponential, 0] //Positive and negative floats and an exponential.
).plot
)

//Sound result:
(
{
	var signal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, [8, -4, \exponential, 0]);
	envGen = EnvGen.ar(env);

	signal = SinOsc.ar;

	signal * envGen
}.play
)

//Controlling the frequency with the envelopes: envelopes can be used to modulate any parameter such as amp / freq / density / etc.
//Using linear here, for instance (no need to write it as it comes by default):
({
	var freq;

	freq = EnvGen.ar(
		Env([39, 61, 50], 2, \linear)
	).midicps;

	SinOsc.ar(freq, 0, 0.5)
}.play
)

//The method .circle creates a loop of the envelope:
({
	var freq;

	freq = EnvGen.ar(
		Env([39, 61, 50], 2, \linear).circle //There is no interpolation from the last value to the first one: it is not a real loop, but a simple repetition.
	).midicps;

	SinOsc.ar(freq, 0, 0.3)
}.play
)

//Mixing here all we studied:
({
	var freq;

	freq = EnvGen.ar(
		Env(Array.fill (5, {rrand (36, 84)}), //Array.fill for aleatoric frequencies.
			LFDNoise3.ar(0.5, 0.5, 0.6), //Random values of duration for each transition.
			\linear
		).circle
	).midicps;

	SinOsc.ar(freq, 0, 0.5)
}.play
)

//Applied to a filter bank: the root of the filter bank is controlled by an envelope. The 10 BPF created by the array of frequencies describe a parallel motion.

(
{
	var root, freq;

	root = EnvGen.ar(
		Env([30, 31, 29.5], [4, 2]).circle
	).midicps;
	freq = Array.geom(10, root.poll(4), 7/4); //.poll show us the value of the root in the postwindow 4 times per second.

{
		Mix(
			BPF.ar(
				PinkNoise.ar,
				freq,
				0.01,
				1
		))
	} !2
}.play
)

//Here, the envelope is controlling the interval of the filter bank (the "grow"):

(
{
	var grow, freq;

	grow = EnvGen.ar(
		Env([2/1, 3/2, 7/4], [8, 4], \exponential).circle //Try using a 1 as duration.
	);
	freq = Array.geom(10, 35, grow);

{
		Mix(
			BPF.ar(
				PinkNoise.ar,
				freq,
				0.01,
				1
		))
	} !2
}.play
)

//Envelope methods (premade envelopes): .TRIANGLE, .SINE, .PERC can be applied to Env.new:

Env.triangle //Arguments: duration and level.
Env.triangle(1, 0.3).plot

{SinOsc.ar * EnvGen.ar(Env.triangle(1, 0.3))}.play
{SinOsc.ar * EnvGen.ar(Env.triangle(1, 0.3).circle)}.play //Using .circle.

Env.sine //Arguments: duration and level. Very useful for future granular synthesis.
Env.sine(1, 0.3).plot

{SinOsc.ar * EnvGen.ar(Env.sine(1, 0.3))}.play

Env.perc //Arguments: attackTime, releaseTime, level and curve (the curve can't be exponential because it has to reach zero due to its percussive utility).
Env.perc(0.01, 0.25, 0.3, -4).plot

{SinOsc.ar * EnvGen.ar(Env.perc(0.01, 0.25, 0.3, -4))}.play

/////////////////////////////////////////////////////////////////////////////
//SECOND ARGUMENT OF EnvGen (the first one was the type of envelope, Env):
//GATE: its value by default is 1 (a single impulse) --> using an Impulse in the argument gate will run again the envelope from its beginning one time per second. If the time of the impulse (or whichever trigger) is less than the total duration of the envelope, the envelope will be impulsed from the beginning from that point (as if we repeated a note on the piano using the sustain pedal at the same time).
//Gate is a signal: when it is higher than zero, EnvGen initiate or reinitiate the envelope.

(
{
	var trigger, signal, env;

	trigger = Impulse.ar(1);
	signal = SinOsc.ar;
	env = EnvGen.ar(Env.perc (0.01, 0.5, 0.3), trigger);
	signal * env
}.play
)

(
{
	var trigger, signal, env;

	trigger = Impulse.ar(2); //The trigger is now shorter than the envelope, so the silence is never reached.
	signal = SinOsc.ar;
	env = EnvGen.ar(Env.perc (0.01, 0.5, 0.3), trigger);
	signal * env
}.play
)

(
{
	var trigger, signal, env;

	trigger = Dust.ar(1); //Using dust: aleatoric trigger.
	signal = SinOsc.ar;
	env = EnvGen.ar(Env.perc (0.01, 0.5, 0.3), trigger);
	signal * env
}.play
)

//Another mixed example:

(
{
	var trigger, signal, env;

	trigger = Dust.ar(5);

	signal = LFPulse.ar(
		100,
		0,
		LFDNoise0.ar(500, 0.3, 0.5),
		0.2 !2
	);

	env = EnvGen.ar(Env.perc(0.05, 0.05, 0.3), trigger);

	signal * env
}.play
)

//Example of the use of randomness for the envelope parameters: compare the two similar codes:

(
{ var freq, trigger, signal;

	trigger = Impulse.ar(1/4);

	freq = Array.fill(5, { //This outer Array.fill duplicates the entire envelope, creating 5 arrays at the same time (thus, an envelope of 5 random chords).
		EnvGen.ar(Env(Array.fill(5, { exprand (60, 78).midicps}), [ rrand(0.5, 3)], \step), trigger)}); //The Array.fill creates an envelope of 5 random notes, one after another. The step provokes that the first frequency is not heard because it jumps directly to the second (it is not a loop, but an envelope triggered each 4 seconds, thus it always misses the first frequency).

	//The times of the envelope are randomly chosen inside the envelope, so the multichannel expansion brings about a different rrand for the times for each of the five envelopes, thus each envelope will change at its own pace.

	signal = {Mix.ar(
		SinOsc.ar(
			freq,
			0,
			0.1)
	)}!2; //We'll obtain five different chords in each side.

	signal * 0.5

}.play
)

(
{ var freq, trigger, times, signal;

	trigger = Impulse.ar(1/4);
	times = [ rrand(0.5, 3)]; //In this second example, the random times of the envelope are placed in a variable outside the array, which will provoke that all 5 created envelopes will change their frequency at the same time.

	freq = Array.fill(5, {
		EnvGen.ar(Env(Array.fill(5, { exprand (60, 78).midicps}), times , \step), trigger)});

	signal = {Mix.ar(
		SinOsc.ar(
			freq,
			0,
			0.1)
	)}!2;

	signal * 0.5

}.play
)

///////////////////////////////////////////////////////////////
//USING GATE AS A GATE AND NOT AS A TRIGGER:
//The difference is that the gate maintains a value until it receives a zero: gate = 1 --> gate open / gate = 0 --> gate closed. In order to use this option, we need an envelope with sustain that will maintain for a certain time, instead of a single action or impulse.


Env.adsr (attackTime, decayTime, sustainLevel, releaseTime, peakLevel, curve) //Arguments of the method .adsr (attack-decay-sustain-release): "attackTime", time taken from silence to the peakLevel (max amplitude) / "decayTime", time taken from the peak level to the sustain level / "sustainLevel", level of the sustain as a ratio compared to the peakLevel (max amplitude): by default, it is half of the peakLevel / "releaseTime", time taken from the sustain level to silence again / "peakLevel", maximum amplitude level / "curve", type of curve, as studied before (do not use \esponential because this envelope will touch the zero, you can imitate the exponential using [4, -4]):

{ EnvGen.ar(Env.adsr, LFPulse.ar(1)) }.plot(2) //Two repetitions of the .adsr envelope using the default values.
{ EnvGen.ar(Env.asr, LFPulse.ar(1)) }.plot(2) //The envelope .asr can be used: the sustain level is the maximum level as there is no peakLevel.

//As mentioned before, gate = 1 (deafult value) will run the envelope directly: plays the attack and decay, and maintains the sustain level. When gate receives a value = 0, the envelope performs the release and turns off. BUT although the gate is turned off, the envelope is still running in the audio server until we stop it using shift + full stop.

(
a = {arg gate = 1;
	var env;

	env = EnvGen.ar(
		Env.adsr(0.1, 0.2, 0.5, 1, 0.6, -4),
		gate
	);
	SinOsc.ar * env
}.scope
)

a.set(\gate, 0) //The method .set allows us to change values of arguments in UGens that are currently running into the server.
a.set(\gate, 1) //If not using "shift + .", then we can turn it on again evaluating this line.

//Using a square wave or Pulse (the non-filtered version, LFPulse) to send 1 and 0 to the gate in order to turn it on and off periodically (using 0.5 in the width for an equal duration of the on and off / frequency of 0.2, meaning that the entire envelope will be 5 seconds long (2.5 on, 2.5 off). The square wave functions as a switch:

(
{
	var gate, signal, env;

	gate = LFPulse.ar(0.2, 0, 0.5);

	signal = SinOsc.ar;

	env = EnvGen.ar(
		Env.adsr(0.01, 0.1, 0.3, 1, 0.3),
		gate
	);

	signal * env
}.play
)

//Controlling the gate using the mouse buttom: gate will be 1 as far as the buttom is pressed. Then it releases as fast as we release the buttom.

(
{
	var gate, signal, env;

	gate = MouseButton.kr(0, 1);

	signal = SinOsc.ar;

	env = EnvGen.ar(
		Env.adsr(0.01, 0.1, 0.3, 1, 0.3), //The release time is quite long, 1 second.
		gate
	);

	signal * env
}.play
)


//IGNORE THIS:
//Bonus code (so GitHub doesn't turn my file into markdown:

(
SynthDef(
	\filters,
	{
		var noise, signal;

		noise = WhiteNoise.ar(0.0001);

		signal = Array.fill(18, { Ringz.ar(noise, ExpRand (100, 3000)) });
		signal = Mix(signal);
		signal = Pan2.ar(signal, 0);

		Out.ar(0, signal)
}).add
)

Synth(\filters)
