//10 - CROSS FADE AND OVERLAP ROUTINES, TDEF and NDEF
/////////////////////////////////////////////////////////

//Creation of continuous textures using routine, which change over time thanks to the concatenation or overlapping of various synths --> Cross-fade routine + Overlap routines.

//CROSS-FADE ROUTINES
//The idea is to create a synthesizer with a fade-in and a fade-out: when the fade-out is initiated, the fade-in from the next synthesizer begins. This way the fade-out from one synth has to feature the same duration as the fade-in of the next synth (transition time = cross-fade). On the other hand, during the sustain time, there will be just one synthesizer at a time. The synth goes out of the server using doneAction = 2. The objective is a continuous sound rather than a sequence of sounds.

Env([ 0, 1, 1, 0 ], 1, \sine).plot //This is the basic envelope normally used for the fades, but the type of envelope can be changed, using an exponential, gaussian, etc. Then, the number in the "times" argument will be replaced by our transition / sustain times.

//Simple example: here the transition times are always the same (periodic routine). We'll try to variate this in the following examples, but this is also a good possibility depending on our necessities:
(
SynthDef(
	\filters,
	{ arg freq1, freq2, freq3, transTime1, sustTime, transTime2;
		var signal, env;

		signal = { //BPF featuring three frequencies, and three different RQs:
			Mix(
				BPF.ar(
					BrownNoise.ar,
					[freq1, freq2, freq3],
					0.5/[freq1, freq2, freq3],
					2
				)
			)
		} !2; //Stereo signal: the BrownNoise will be different on each channel = richer signal.

		env = EnvGen.ar( //The commented envelope:
			Env(
				[0, 1, 1, 0],
				[transTime1, sustTime, transTime2],
				\sine
			),
			doneAction: 2 //doneAction = 2 is essential when working with infinite routines.
		);
		Out.ar(0, signal * env)
}).add
)

(
Routine({ //Periodic times (fixed), hypnotical result:

	inf.do({
		Synth(\filters, [
			\freq1, exprand(100, 1000),
			\freq2, exprand(100, 1000),
			\freq3, exprand(100, 1000),
			\transTime1, 3,
			\sustTime, 3,
			\transTime2, 3
		]);
		(3 + 3).wait //The waiting time is the fade-in + sustain time, because during the fade-out, the new synth is already introduced.
	})

}).play
)

//Introducing arrays are arguments, for example, for the multiple frequency in the former code. This is especially useful when working with a larger number of frequencies (writing three freqs is not that cumbersome). Remember that the size of the array cannot be changed once the SynthDef has been compiled:
(
SynthDef(
	\filters,
	{ arg freqs = #[0, 0, 0], transTime1, sustTime, transTime2; //Using a single argument now for all the frequencies.
		var signal, env;

		signal = {
			Mix(
				BPF.ar(
					BrownNoise.ar,
					freqs,
					0.5/freqs,
					2
				)
			)
		} !2;

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0],
				[transTime1, sustTime, transTime2],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
Routine({

	inf.do({
		Synth(\filters, [
			\freqs, {exprand(100, 1000)} !3, //We need to repeat the function 3 times in order to obtain 3 different freqs (this will create an array automatically, remember that this is equivalent to an Array.fill).
			\transTime1, 3,
			\sustTime, 3,
			\transTime2, 3
		]);
		(3 + 3).wait
	})

}).play
)

//Variation of the former code using frequencies from the natural overtone series:
(
SynthDef(
	\filters,
	{ arg freqs = #[0, 0, 0], transTime1, sustTime, transTime2;
		var signal, env;

		signal = {
			Mix(
				BPF.ar(
					BrownNoise.ar,
					freqs,
					0.5/freqs,
					2
				)
			)
		} !2;

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0],
				[transTime1, sustTime, transTime2],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
Routine({
	var freqs;

	freqs = (27.5 * Array.series(120, 2)); //The fundamental freq is 27.5 Hz. Array.series create a series of 120 harmonics from the harmonic 2 of the series (the overtone 1 is the fundamental freq), up to roughly 3000 Hz (remember that thre freq of the overtone is = to the fundamental freq * no. of the overtone. This is how this code works.

	inf.do({
		Synth(\filters, [
			\freqs, { freqs.choose} !3,
			\transTime1, 3,
			\sustTime, 3,
			\transTime2, 3
		]);
		(3 + 3).wait
	})

}).play
)

//Now we'll variate the transition and sustain time of each synth, so the routine won't be periodic, but flexible. We need to distinguish the transTime1 and transTime2. The synth in fade-out has to pass its fade-out duration to the next synth so it can be used as the new fade-in. Then, the new fade-out will be chosen by change, for example (varying it then).
(
SynthDef( //Same exact synth, just adding the two different transTimes:
	\filters,
	{ arg freqs = #[0, 0, 0], transTime1, sustTime, transTime2;
		var signal, env;

		signal = {
			Mix(
				BPF.ar(
					BrownNoise.ar,
					freqs,
					0.5/freqs,
					2
				)
			)
		} !2;

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0],
				[transTime1, sustTime, transTime2],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
Routine({
	var transTime1, sustTime, transTime2;

	transTime1 = rrand(1.0, 8); //The first transTime (fade-in) is chosen here, outside the loop. After the first iteration, the next fade-in will always depend on the previous fade-out (this avoids that the transTime renews the value with each iteration, so it can depend of the other choice).

	inf.do({

		sustTime = rrand(1.0, 8); //The sustTime is also random here.
		transTime2 = rrand(1.0, 8); //Both random choices need to be inside the loop (.do) so the value is renewed with each iteration.

		Synth(\filters, [
			\freqs, {exprand(100, 1000)} !3,
			\transTime1, transTime1,
			\sustTime, sustTime,
			\transTime2, transTime2
		]);

		[ transTime1, sustTime, transTime2 ].round(0.1).postln; //Here the three times are posted in the postwindow just to visualize (delete this line in order to save CPU percentage), only with one decimal (thanks to round 0.1).

		(transTime1 + sustTime).wait; //Same system for the wait time, only adding the fade-in (transTime1) time and the sustTime.

		transTime1 = transTime2; //The secret of the code is here when the variable of the fade-in is reassigned to the fade-out.

	})
}).play
)

//Another example using other kind of synths: here Klank:
(
SynthDef(
\klanks,
	{ var freqs, times, signal, env;

		//These two variables are for the klank references array:
		freqs = Array.fill(50, { LinRand(30, 14000) }); //Rand would highlight the high freqs and ExpRand would balance low and high freqs. LinRand is in the mid way of both distributions (linear distribution).
		times = Array.fill(50, { Rand(0.01, 0.1) });

		//Our synth here: the input of Klank is a Resonz filter, filtering a Dust and modulating its freq with an exponential line:
		signal = Klank.ar(
			`[ freqs, 1, times], //The ` of the array in Klank hides the array so it is not turned into a multichannel expansion.
			Resonz.ar(
				Dust.ar(35 !2, 0.075), //Though we have here a duplicator provoking the multichannel expansion.
				XLine.ar(14000, 30, 15), //The freqs are not decided in the routine but here directly. The line is fixed, but the timbre changes due to the random freqs in Klank in each iteration of the Synth.
				0.2
		));

		env = EnvGen.ar(
			Env([ 0, 1, 1, 0 ], 5, \sine), //we are using the same time for all segments in the envelope (trans / sust times), so one single number can be set.
			doneAction: 2
		);

		Out.ar(0, signal * env)
}).add
)

( //No arguments are being choosen in the Routine, just the move between the synths.
Routine({
	inf.do({
		Synth(\klanks);
		(5 + 5).wait
	})
}).play
)

//////////////////////////////////////////////////////////////

//OVERLAP ROUTINES
//It will create several synths at the same time and this density can be controlled. The synths will replaced each other continuously in order to create a constant texture. Using the same system as in the cross-fade routine, the waiting time of the routine will be transTime1 + transTime2 + sustTime / density, that is to say, the duration of the entire envelope divided between the number of synths we want to hear at the same time.

//First simple example: five synths renewing themselves with every iteration (open the NodeTree in order to see how the synths replace themselves successively):
(
SynthDef(
	\filtering,
	{| freq, transTime, sustTime, density |
		var signal, env, individualAmp;

		individualAmp = ((density.log2 + 1) * -3.01).dbamp * 0.5; //This formula allows the amplitude to be modified automatically according to the density we set in the routine. You can try the formula by itself giving different values to the density. This is a formula given by my almighty first SC professor and I don't really understand why there is + 1 after the log2 (it is calculated in db, so it depends on the db functioning), after all, it is adapted to be always below 0.25, which will be applied to the envelope. Maybe it could be simplified, but this one works (IF 0.5 IS TO LOUD, REPLACE IT WITH 0.25 for instance).

		signal = BPF.ar(
			BrownNoise.ar(1!2),
			freq,
			0.5/freq,
			10
		);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * individualAmp, //Balancing the amplitude according to the density (and the formula above).
				[ transTime, sustTime, transTime ],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
Routine({
	var density, transTime, sustTime, freqs;

	density = 5; //Change the density taking into consideration the number of freqs created in the Array.geom (which will be the maximum density). The size of the array also depends on the type of interval chosen for the "grow" argument, so be aware of this. Density = 1: the routine wait until the synth is done, so there is only one layer.

	transTime = 5; //Fixed transTime and sustTime for now.
	sustTime = 5;

	freqs = Array.geom(14, 35, 3/2); //Pitagoric fifths as the interval for the frequencies. Any other Array or series of freqs can be created.

	inf.do({
		Synth(\filtering,
			[ \freq, freqs.choose,
				\transTime, transTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((transTime + sustTime + transTime) /density).wait
	})
}).play
)

//ALL OF THIS CAN BE DONE WITH PATTERNS, which will be studied later on:
//Using the same SynthDef as before (\filtering):
(
Routine({
	var density, transTime, sustTime, freqs, line;

	density = 100;
	transTime = 5;
	sustTime = 5;

	freqs = Array.geom(200, 35, 0.5.midiratio); //0.5.midiratio creates quarter tones.
	line = Env([0, freqs.lastIndex], 30).asStream; //This is an envelope which will give values from 0 to 199 (which is the lastIndex of the Array.geom) to another during 30 seconds (and the values are taken in the loop, asked by the .next message in each iteration + as the density is 100, the wait time is very small, so the values change fast successively). See the continuation in the freq argument of the loop:

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[line.next.asInt.postln..].choose, //Using .asInt so the index values are integers for sure. [first value wanted..], creates an array from the first value we want up to the last one: our first value is the value of the line created above, which will be changing successively (and posted just for us to see, but delete .postln to save CPU). At the end, it maintains the last frequencie (all the layers, because there is nothing else among which they can choose regarding the freqs array).
				\transTime, transTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((transTime + sustTime + transTime) /density).wait
	})
}).play
)

//Here same routine, but the process (sort of glissando) is 3 seconds long (so the transTimes and sustTime should be = 1, so everything fits in 3 seconds):
(
Routine({
	var density, transTime, sustTime, freqs, line;

	density = 100; //Para cuartos de tono en el geom
	transTime = 1;
	sustTime = 1;

	freqs = Array.geom(200, 35, 0.5.midiratio);
	line = Env([0, freqs.lastIndex], 3).asStream;

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[line.next.asInt.postln..].choose,
				\transTime, transTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((transTime + sustTime + transTime) /density).wait
	})
}).play
)

//Contrary direction for the glissando (from high to low): just changing the order of the values in the Envelope (line). You can try out different times for the envelope (adapting the trans and sust times). At the end all the freqs are available because the freqs array is opened instead of closed:
(
Routine({
	var density, transTime, sustTime, freqs, line;

	density = 100;
	transTime = 1;
	sustTime = 1;

	freqs = Array.geom(200, 35, 0.5.midiratio);
	line = Env([freqs.lastIndex, 0], 3).asStream;

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[line.next.asInt.postln..].choose,
				\transTime, transTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((transTime + sustTime + transTime) /density).wait
	})
}).play
)

//Here is the same, but remaining only with the low freqs at the end: changing the syntax of the freqs array [..last value wanted], so the array includes all the values up to the one we choose (so if the first one is 0, and we reduce the possibilities from 199 to 0, then at the end the only possibility will be 0).


(//Aquí para que empiece con todo y se quede solo con el grave (cambiando los .. al principio, así acota dónde se corta el segmento del array y no que vaya hasta el final. Provar también con la env al revés [0, freqs.lastIndex]
Routine({
	var density, transTime, sustTime, freqs, line;

	density = 100; //Para cuartos de tono en el geom
	transTime = 1;
	sustTime = 1;

	freqs = Array.geom(200, 35, 0.5.midiratio);
	line = Env([freqs.lastIndex, 0], 3).asStream;

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[..line.next.asInt.postln].choose,
				\transTime, transTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((transTime + sustTime + transTime) /density).wait
	})
}).play
)

//Try out other combinations of the former codes.
/*REMINDER OF THE ARRAYS SHORTCUTS:

[..this] --> From the beginning of the array up to the value we want it to end at.
[this..] --> From the value we want it to begin with up to the end of the array.
*/

/////////////////////////////////////////////////////////////////////////////////////
//SOLUTIONS TO PROBLEMS POSED BY DONEACTION 2:
//DoneAction = 2 can provoke that a processes such as envelopes, delays or reverbs are not concluded before the Synth is removed from the server. There are different solutions to this problem: DetectSilence, dissengaged Line or overall envelope:

//Here is our SynthDef and the different solutions mentioned before:
(
SynthDef(
	\chords,
	{ arg out = 0, freq1, freq2, freq3, freq4, rq, crossTime1, sustTime, crossTime2, which;
		var freqs, amps, signal, env, signalOut, delay, finalSignal;

		freqs = Array.geom(4, freq1, 2) //Creating a chord and duplicating each pitch in different octaves.
		++
		Array.geom(6, freq2, 2)
		++
		Array.geom(6, freq3, 2)
		++
		Array.geom(6, freq4, 2);

		signal = Select.ar( //We will choose between three different inputs for the filter:
			which,
			[
				PinkNoise.ar,
				WhiteNoise.ar,
				BrownNoise.ar
		]);

		signal = FreeVerb.ar({Mix(BPF.ar(signal, freqs, rq, 1.2))} !2, 0.5, 1, 0.5, 0.5); //Filtering, mixing and applying reverb.

		env = EnvGen.ar( //Envelope for the routine:
			Env(
				[0, 1, 1, 0],
				[crossTime1, sustTime, crossTime2],
				\sine
			),
			doneAction: 0 //DoneAction = 2 will be applied by the solution procedures, thus in here we need doneAction = 0.
		);

		signalOut = signal * env;

		delay = DelayC.ar(signalOut, 10, 2); //Delay of 2 seconds.

		//FIRST OPTION: DetectSilence is a UGen that detects the moment when a process is over and then applies doneAction 2 (this is why doneAction = 0 in the envelope). The first argument is the signal it is applied to (it has to detect the delay in this case). There is also a "time" argument, which is the time that it would take to kill the Synth since the silence is detected.
		DetectSilence.ar(delay, doneAction: 2);

		//SECOND OPTION: the Line is not applied to any variable, but it contains doneAction so it will shut down the synth. It is a possible alternative if DetectSilence does not work (the +2 is added because is the value of the delay):
		//Line.ar(0, 1, crossTime1 + sustTime + crossTime2 + 2, doneAction: 2);

		//THIRD SOLUTION: creating an overall envelope, which will be multiplied by the signal in the Out.ar. It is not the best option since this one has a direct sounding resutl.
		//envGlobal = EnvGen.ar(Env([0.0001, 1, 1, 0.0001], [0.01, crossTime1 + sustTime + crossTime2 + 2, 1], \exponential), doneAction: 2);

		finalSignal = [delay, signalOut];

		Out.ar(out, finalSignal)
}).add
)

//Try it out with the routine:
(
Routine({
	var crossTime1, sustTime, crossTime2, rq, which, freqs;

	crossTime1 = rrand(1.0, 4);

	rq = rrand(0.001, 0.01);

	which = [0, 1, 2];

	freqs = [26, 28, 29, 31, 33, 34, 36, 38].midicps; //D minor scale.

	100.do({

		sustTime = rrand(1.0, 4);
		crossTime2 = rrand(1.0, 4);

		Synth(\acordes, [
			\frec1, freqs.choose,
			\frec2, freqs.choose,
			\frec3, freqs.choose,
			\frec4, freqs.choose,
			\rq, rq,
			\crossTime1, crossTime1,
			\sustTime, sustTime,
			\crossTime2, crossTime2,
			\which, which.choose
		]);

		(crossTime1 + sustTime).wait;

		crossTime1 = crossTime2;

	})
}).play
)

////////////////////////////////////////////////////////////////////////////////////

//TDEF (from the JITLib library, mainly for live coding)
//In order to test routines without having to stop the SynthDef and evaluate it again, we can use Tdef instead of Routine (T = task, "def" = defined by a name, like a SynthDef, so it does not need to be placed into a variable, but it is called through a \symbol).

//Simple example: routine that changes randomly the order of the letters of "hello":
(
Tdef(\x, { //The name for the Tdef can be whatever.

	inf.do({
		"hello".scramble.postln;
		1.wait; //New order each second.

	})
}).play
)

//Now in the former code, while it is running, we can modify whichever parameter (the content of the string, the waiting time, etc.) and it will replace the new values in real time (it might need a certain time to replace them depending on the kind of processes and the waiting time --> it needs to wait until the next iteration of the routine).

//Try here to evaluate and change values and evaluate it again on top without stopping it:
(
Tdef(\x, {

	inf.do({
		{ SinOsc.ar(440) !2 * EnvGen.ar(Env.sine(0.25), doneAction: 2) * 0.1}.play;
		0.5.wait;

	})
}).play
)

//Last example applied to the latest SynthDef (\filtering): try to replace the interval in Array.geom (be aware of the size and freq limit though), the transTime or sustTime, etc.:
( //Copying the SynthDef again here, just in case:
SynthDef(
	\filtering,
	{| freq, transTime, sustTime, density |
		var signal, env, individualAmp;

		individualAmp = ((density.log2 + 1) * -3.01).dbamp * 0.5;

		signal = BPF.ar(
			BrownNoise.ar(1 !2),
			freq,
			0.5/freq,
			10
		);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * individualAmp,
				[ transTime, sustTime, transTime ],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
Tdef(\overlap,
	{
	var density, transTime, sustTime, freqs, line;

	density = 100;
	transTime = 10;
	sustTime = 10;

	freqs = Array.geom(50, 35, 2.1.midiratio); //Whole tone scale here, but detuned because of the float as midiratio for the interval.
	line = Env([freqs.lastIndex, 0], 3).asStream;

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[..line.next.asInt.postln].choose,
				\transTime, transTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((transTime + sustTime + transTime) /density).wait
	})
}).play
)

//////////////////////////////////////////////////////////////////////////////////
//NDEF (Also from the "Just In Time" library (Ndef, Tdef, MIDIdef, Pdef...etc.)
//Continuing with the "live coding" tools, there is an alternative for creating SynthDefs (which cannot be modified once they are compiled: the size of an array, the sending of lists - arrays - apart from using a fixed array #[0, 0, 0], for example, the number of channels, etc.). Once it is compiled (.add) it is a program from which you can create different instances modifying the value of its arguments.
//Ndef is the alternative for live coding: instead of a compiled synth, it creates an empty synth which can be changed and which is directly playble:

Ndef(\x, { Mix.ar(SinOsc.ar(Array.rand(2, 333, 666), 0, 0.1)) }).play //Creates a Synth as SynthDef would do.

Ndef(\y).play //Already creates the synth (empty).
Ndef(\y).source = {WhiteNoise.ar(0.03)} //For example (.source = what is inside the synth).
Ndef(\y).source = {SinOsc.ar(440, 0, 0.1)} //Another example for the source.
Ndef(\y).pause //For pausing the synth.
Ndef(\y).resume //For resuming the synth.
Ndef(\y).fadeTime = 2; //To set a fade time (right now is working as fade-in, it works when the fadeTime is evaluated, then the "resume").

//Each time it is evaluated, it gives a different value (try to quickly evaluate it successively). Then, go to the next line of code and open the graphical interface (.gui), where some arguments (those within the Dictionary "ControlSpec") can be changed:
(
	Ndef(
	\ssaw, {
	| out = 0, gate = 1, freq = 440, inBus, ffreq = 880 | //ffreq is the freq of the ressonant low pass filter.
		var myEnv, signal, flt;

		myEnv = EnvGen.ar(Env.perc(0, 0.8), gate, doneAction: 2); //Percussive envelope with gate = 1 by default and doneAction = 2: essentials.
		signal = Mix([Saw.ar((Array.rand(10, 0.1, 1)) * freq, 0.1)]); //Creating an array of 10 sawtooth waves with different detunings of the fundamental frequency.
		flt = RLPF.ar(signal.sum, ffreq, 0.1); //The method .sum is needed to group the frequencies from the Mix (not sure why tho: QUESTION FOR ALEJANDRO). Then the freqs are filtered.

		Out.ar(out, Pan2.ar(flt, 0, 0.7 * myEnv)); //A pan = 0 is used here to send the signals by both channels of the stereo.

	}).add;
)

Ndef(\ssaw).gui //Freq = 1200 ca. and Ffreq = 1600 ca., cool.

