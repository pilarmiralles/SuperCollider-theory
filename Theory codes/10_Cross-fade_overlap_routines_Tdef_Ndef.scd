//10 - CROSS FADE AND OVERLAP ROUTINES, TDEF and NDEF
/////////////////////////////////////////////////////////

//This document is about the creation of continuous textures using routines which change over time thanks to the concatenation or overlapping of various synths --> Cross-fade routine + Overlap routines.

//CROSS-FADE ROUTINES
//The idea is to create a synthesizer with a fade-in and a fade-out: when the fade-out is initiated, the fade-in of the next synthesizer begins. This way the fade-out from one synth has to feature the same duration as the fade-in of the next synth (transition time = cross-fade). On the other hand, during the sustain time, there will be just one synthesizer at a time. The synths go out of the server using doneAction = 2. The objective is to bring about a continuous sound rather than a sequence of sounds.

Env([ 0, 1, 1, 0 ], 1, \sine).plot //This is the basic envelope normally used for fading in and out, but the type of envelope can be changed (exponential, gaussian, etc.). Then, the number in the "times" argument will be replaced by our transition and sustain times.

//Simple example: here the transition times are always the same (periodic routine). We will try to variate this in the following examples, keeping in mind that the choice on this matter depends on our necessities:
(
SynthDef(
	\filters,
	{ arg freq1, freq2, freq3, crossTime1, sustTime, crossTime2;
		var signal, env;

		signal = { //BPF featuring three frequencies, and three different RQs, then mixed in one channel.
			Mix(
				BPF.ar(
					BrownNoise.ar,
					[freq1, freq2, freq3],
					0.5/[freq1, freq2, freq3],
					2
				)
			)
		} !2; //Duplicated function: the BrownNoise will be different in each channel.

		//Basic envelope, now applying the transition and sustain times:
		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0],
				[crossTime1, sustTime, crossTime2],
				\sine
			),
			doneAction: 2 //doneAction = 2 is essential when working with infinite routines.
		);
		Out.ar(0, signal * env) //Applying the envelope to the signal.
}).add
)

(
r = Routine({ //Fixed values for the transition and sustain times:

	inf.do({
		Synth(\filters, [
			\freq1, exprand(100, 1000),
			\freq2, exprand(100, 1000),
			\freq3, exprand(100, 1000),
			\crossTime1, 3,
			\sustTime, 3,
			\crossTime2, 3
		]);
		(3 + 3).wait //The waiting time is the fade-in + sustain time, because during the fade-out, the new synth is already introduced.
	})

}).play
)

r.stop

//Introducing arrays as arguments, for example, to replace the multiple choice of three frequencies in the former code. This is especially useful when working with a larger number of frequencies. Remember that the size of the array cannot be changed once the SynthDef has been compiled:
(
SynthDef(
	\filters,
	{ arg freqs = #[0, 0, 0], crossTime1, sustTime, crossTime2; //Using a single argument now for all three frequencies.
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
				[crossTime1, sustTime, crossTime2],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
r = Routine({

	inf.do({
		Synth(\filters, [
			\freqs, {exprand(100, 1000)} !3, //We need to duplicate the function 3 times in order to obtain an array of 3 random freqs (it could also be written using Array.fill, as it will be shown in future examples).
			\crossTime1, 3,
			\sustTime, 3,
			\crossTime2, 3
		]);
		(3 + 3).wait
	})

}).play
)

r.stop

//Variation of the former code using frequencies from the natural overtone series:
(
SynthDef(
	\filters,
	{ arg freqs = #[0, 0, 0], crossTime1, sustTime, crossTime2;
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
				[crossTime1, sustTime, crossTime2],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
r = Routine({
	var freqs;

	freqs = (27.5 * Array.series(120, 1)); //The fundamental freq is 27.5 Hz. Array.series create a series of 120 harmonics from the harmonic 1 of the series (the overtone 1 is the fundamental freq), up to roughly 3200 Hz (remember that the freq of an overtone is = to the fundamental freq * number of the overtone in the series). This is how this line of code works.

	inf.do({
		Synth(\filters, [
			\freqs, { freqs.choose} !3,
			\crossTime1, 3,
			\sustTime, 3,
			\crossTime2, 3
		]);
		(3 + 3).wait
	})

}).play
)

r.stop

//Now we will variate the transition and sustain time of each synth, so the routine won't be periodic, but flexible. We need to distinguish the crossTime1 and crossTime2. The synth in fade-out has to pass its fade-out duration to the next synth so it can be used as the new fade-in. Then, the new fade-out will be randomly chosen, for instance:
(
SynthDef( //Same exact synth, just adding the two different crossTimes:
	\filters,
	{ arg freqs = #[0, 0, 0], crossTime1, sustTime, crossTime2;
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
				[crossTime1, sustTime, crossTime2],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
r = Routine({
	var crossTime1, sustTime, crossTime2;

	crossTime1 = rrand(1.0, 8); //The first crossTime (fade-in) is chosen here, outside the loop, during the first iteration of the routine. After the first iteration, the next fade-in will always depend on the previous fade-out. It is placed out of the loop to allow the variable to reassign with each iteration of the routine:

	inf.do({

		sustTime = rrand(1.0, 8); //The sustTime is also random here.
		crossTime2 = rrand(1.0, 8); //Both random choices need to be inside the loop (.do) so the value is renewed with each iteration.

		Synth(\filters, [
			\freqs, {exprand(100, 1000)} !3,
			\crossTime1, crossTime1,
			\sustTime, sustTime,
			\crossTime2, crossTime2
		]);

		[ crossTime1, sustTime, crossTime2 ].round(0.1).postln; //Here the three times are posted in the postwindow just to visualize rounded to one decimal (delete this line in order to save CPU percentage).

		(crossTime1 + sustTime).wait; //Same system for the wait time, only adding the fade-in (crossTime1) time and the sustTime.

		crossTime1 = crossTime2; //The variable of the fade-in is reassigned here to the fade-out at the end of each iteration.

	})
}).play
)

r.stop

//Another example using Klank:
(
SynthDef(
\klanks,
	{ var freqs, times, signal, env;

		//These two variables will define Klank's specifications array ref:
		freqs = Array.fill(50, { LinRand(30, 14000) }); //Rand would highlight the high freqs and ExpRand would balance low and high freqs. LinRand is in the mid way of both distributions (linear distribution), but you can try out the others.
		times = Array.fill(50, { Rand(0.01, 0.1) }); //Uniform distribution for the decay times.

		//Our synth here: the input of Klank is a Resonz filter, filtering a Dust and modulating its freq with an exponential line:
		signal = Klank.ar(
			`[ freqs, 1, times],
			Resonz.ar(
				Dust.ar(35 !2, 0.075), //The function is duplicated here, provoking the stereo sound (35 different bits of dust on each channel).
				XLine.ar(14000, 30, 15), //The freqs are not decided in the routine (which could be) but directly here. The line is fixed, but the timbre changes due to the random freqs in Klank with each iteration of the Synth. This freq is controlling the filter frequency, then the freq of the bits of dust is still random (within the filtering freq) due to the array of freqs in Klank.
				0.2
		));

		env = EnvGen.ar(
			Env([ 0, 1, 1, 0 ], 5, \sine), //we are using the same time for all segments in the envelope (cross / sust times), so one single number can be set (this could be defined in the routine as well).
			doneAction: 2
		);

		Out.ar(0, signal * env)
}).add
)

( //No arguments are being choosen in the Routine: it just activate one synth after another.
r = Routine({
	inf.do({
		Synth(\klanks);
		(5 + 5).wait //The Xline is 15 seconds long, thus there will be an overlapping of 5 seconds.
	})
}).play
)

r.stop


//////////////////////////////////////////////////////////////

//OVERLAP ROUTINES
//An overlap routine will create several synths at the same time and this density (number of synths) can be controlled. The synths will replaced each other continuously in order to create a constant texture. The waiting time of this kind of routine will be crossTime1 + crossTime2 + sustTime / density, that is to say, the duration of the entire envelope divided by the number of synths we want to hear at the same time.

//First simple example: five synths overlap and renew with each iteration (open the NodeTree in order to see how the synths replace themselves successively):
(
SynthDef(
	\filtering,
	{| freq, crossTime, sustTime, density |
		var signal, env, individualAmp;

		individualAmp = ((density.log2 + 1) * -3.01).dbamp * 0.5; //This formula allows the amplitude to be modified automatically according to the density we set in the routine. You can try the formula by itself giving different values to the density. This is a formula given by my almighty first SC professor and I don't really understand why there is + 1 after the log2 of the density is calculated (the result of the operation is in db, so it depends on the db functioning), after all, it is adapted to be always below 0.25, which will be applied to the envelope. Maybe it could be simplified, but this one works (IF 0.5 IS TOO LOUD OR TOO QUIET, REPLACE IT with any other factor).

		signal = BPF.ar(
			BrownNoise.ar(1!2),
			freq,
			0.5/freq, //The RQ depends on the frequency.
			10
		);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * individualAmp, //Balancing the amplitude according to the density (applying the formula above as a factor).
				[ crossTime, sustTime, crossTime ],
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
r = Routine({
	var density, crossTime, sustTime, freqs;

	density = 5; //Change the density (the number of freqs created by the Array.geom does not matter because they are chosen randomly, and therefore they can be repeated, for instance). Density = 1: the routine wait until the synth is done, so there is only one layer.

	crossTime = 5; //Fixed crossTime and sustTime for now.
	sustTime = 5;

	freqs = Array.geom(14, 35, 3/2); //Pitagoric fifths as the interval for the frequencies. Any other Array or series of freqs can be created.

	inf.do({
		Synth(\filtering,
			[ \freq, freqs.choose,
				\crossTime, crossTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((crossTime + sustTime + crossTime) /density).wait //The different synths will appear and dissapear at different moments.
	})
}).play
)

r.stop

//ALL OF THIS CAN BE DONE WITH PATTERNS, which will be studied in documents 11 and 13.
//Using the same SynthDef as before (\filtering):
(
r = Routine({
	var density, crossTime, sustTime, freqs, line;

	density = 100;
	crossTime = 5;
	sustTime = 5;

	freqs = Array.geom(200, 35, 0.5.midiratio); //0.5.midiratio creates quarter tones.
	line = Env([0, freqs.lastIndex], 30).asStream; //This is an envelope which will give values from 0 to 199 (which is the lastIndex of the Array.geom) during 30 seconds. The values are then asked by the .next message in the loop in each iteration. as the density is 100, the wait time is very small, so the values change fast, completing the spectrum from the bottom to the top and ending on the very last top freq). The envelope is turned into a stream (.asStream) so its values can be asked one at a time from within the loop (using .next as shown in the frequency argument of the synth). This explanation continues in the freq argument of the loop:

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[line.next.asInt.postln..].choose, //Using .asInt so the index values are integers for sure. [first value wanted..], creates an array from the first value we want up to the last one available in that array ("freqs"): our first value is the first value of the envelope created above ("line"), which will be changing successively (and posted just for testing). At the end, it maintains the last frequency (there is not only one layer, but rather all layers playing the last value of the envelope of freqs at the end of the process, because that freq is the only available at that point).
				\crossTime, crossTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((crossTime + sustTime + crossTime) /density).wait
	})
}).play
)

r.stop

//Here is same routine, but the process (sort of glissando) is 3 seconds long (the crossTimes and sustTime are equal to 1 so everything fits in 3 seconds):
(
r = Routine({
	var density, crossTime, sustTime, freqs, line;

	density = 100;
	crossTime = 1;
	sustTime = 1;

	freqs = Array.geom(200, 35, 0.5.midiratio);
	line = Env([0, freqs.lastIndex], 3).asStream; //Upward series of freqs.

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[line.next.asInt.postln..].choose, //Closing the choice of freqs up to the top freq only.
				\crossTime, crossTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((crossTime + sustTime + crossTime) /density).wait
	})
}).play
)

r.stop

//Contrary direction for the glissando (from high to low): just changing the order of the values in the Envelope (line). You can try out different times for the envelope (adapting the cross and sust times, so their total sum is the time of the envelope). At the end, all freqs are available to be chosen because the array of freqs opens intead of closing (and of course, the freqs keep changing due to the overlap routine random choices):
(
r = Routine({
	var density, crossTime, sustTime, freqs, line;

	density = 100;
	crossTime = 1;
	sustTime = 1;

	freqs = Array.geom(200, 35, 0.5.midiratio);
	line = Env([freqs.lastIndex, 0], 3).asStream; //Downward series of freqs.

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[line.next.asInt.postln..].choose, //Openin the choice of freqs up to the whole spectrum.
				\crossTime, crossTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((crossTime + sustTime + crossTime) /density).wait
	})
}).play
)

r.stop

//Here is the same, but remaining only with the lowest freq at the end: changing the syntax of the freqs array [..last value wanted], so the array includes all the values up to the one we choose (so if the first one is 199, and we reduce the possibilities from 199 to 0, then at the end the only possibility will be 0):


(
r = Routine({
	var density, crossTime, sustTime, freqs, line;

	density = 100;
	crossTime = 1;
	sustTime = 1;

	freqs = Array.geom(200, 35, 0.5.midiratio);
	line = Env([freqs.lastIndex, 0], 3).asStream; // Downward series of freqs. This could be also tested with [0, freqs.lastIndex] (upward series).

	inf.do({
		Synth(\filtering,
			[ \freq, freqs[..line.next.asInt.postln].choose, //Closing the choice of freqs up to the bottom on only. If the array of freqs is inverted ([0, freqs.lastIndex], then opening the choice of freqs up to the whole spectrum
				\crossTime, crossTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((crossTime + sustTime + crossTime) /density).wait
	})
}).play
)

r.stop

/*REMINDER OF THE ARRAYS SHORTCUTS:

[..this] --> From the beginning of the array up to the value we want it to end at.
[this..] --> From the value we want it to begin with up to the end of the array.
*/

/////////////////////////////////////////////////////////////////////////////////////
//SOLUTIONS TO PROBLEMS POSED BY DONEACTION 2:
//DoneAction = 2 can provoke that processes such as envelopes, delays or reverbs do not conclude before the Synth is removed from the server. There are different solutions to this problem: using DetectSilence, a dissengaged Line or an overall envelope:

//Here we have our sawtooth SynthDef and routine (from heory file 9, see details in original code), now with Delay applied to it. Three different solutions to the problem mentioned before are explained at the end of the first SynthDef, after applying the Delay:

(
SynthDef(
	\sawtooth,
	{| out, freq, dur, amp |
		var signal, env, signalOut, delay, finalSignal;

		signal = Saw.ar(freq); //Pan2 has been removed from the original example in order to demonstrate the Delay and its solutions within a routine.

		env = EnvGen.ar(
			Env.perc(0.005, dur, amp),
			doneAction: 0
		);

		signalOut = signal * env;

		delay = DelayC.ar(signalOut, 2, 2); //Delay of 2 seconds: we need to avoid doneAction 2 in the envelope cutting this delay before it is done:

		//FIRST OPTION: DetectSilence is a UGen that detects the moment when a process is over and then applies doneAction 2 to it (this is why doneAction = 0 before in the code). The first argument is the signal it is applied to (it has to detect the delay in this case). There is also a "time" argument, which is the time that it would take to kill the Synth since the silence is detected. But the most important part of it is applying doneAction 2 (last argument).
		DetectSilence.ar(delay, doneAction: 2);

		//SECOND OPTION: we can use a Line that is not applied to any variable, but that contains doneAction = 2 so it will shut down the synth. It is a possible alternative if DetectSilence does not work (I think the arguments start and end (default values here) do not matter much as this UGen is not applied to any other process in the code, but just to take advantage of its "time counter" and doneAction argument): The time argument should contain the total time of the envelope and the time of the delay (hence the + 2, which could be controlled by an argument, so it can depend on the delay time, if variable). Then, doneAction = 2 is applied as last argument:
		//Line.ar(0, 1, dur + 2, doneAction: 2);

		//THIRD SOLUTION: creating an overall envelope, which will be multiplied by the signal in Out.ar. This one is not the best option since it has a direct result on the sound, but it could be useful at some point. Notice the time of the delay added as well to the segment of the sustain of the envelope:
		//envGlobal = EnvGen.ar(Env([0.0001, 1, 1, 0.0001], [0.01, dur + 2, 1], \exponential), doneAction: 2);

		finalSignal = [delay, signalOut] * 0.7;

		Out.ar(out, finalSignal)

}).add;
SynthDef(
	\resonator,
	{| in |
		var input, signal;

		input = In.ar(in, 2);

		signal = LeakDC.ar(
			Mix(
				CombC.ar(
					input * 0.1,
					1/2900,
					1/({ LFDNoise3.ar(0.1, 100, 3000) } !10),
					-1
				).clump(2)
		));

		Out.ar(0, signal)

}).add
)

//Try out the routine:
(
r = Routine({

	g = Synth(\resonator, [\in, 4], s, \addToTail);

	inf.do({

		Synth(\sawtooth, [
			\out, 4, //Try listening to the sawtooth wave alone with out = 0.
			\freq, exprand(3000, 6000),
			\dur, exprand(0.001, 0.125),
			\amp, exprand(0.05, 0.3)
		],
		s, \addToHead);

		exprand(0.05, 1.0).wait
	})

}).play
)

r.stop
g.free //When using a second synth for reverb (with no doneAction 2), it is necessary to free it as well, so that it doesn't remain running in the server.

////////////////////////////////////////////////////////////////////////////////////

//TDEF (from the JITLib library, mainly for live coding):
//In order to test routines without having to kill the Synth and evaluate it again when changing parameters, we can use Tdef instead of Routine (T = task, "def" = defined by a name, as in SynthDef: it is called through a \symbol).

//Simple example with no sound: routine that changes randomly the order of the letters of "hello" and prints the result:
(
Tdef(\tdef, { //The name of Tdef does not matter much.

	inf.do({
		"hello".scramble.postln;
		1.wait; //New order each second.

	})
}).play
)

//With Tdef in the former code, we can modify whichever parameter while it is running (evaluating - changing a value - evaluating again): try out adding or deleting letters from the string, changing the wait time, etc. Tdef will replace the new values in real time, therefore, it might need a certain time to perform this replacement depending on the waiting time we are using: Tdef waits until the next iteration of the routine to replace the values.

//Simple example with sound: try evaluating it, changing values and evaluating again while it is running:
(
Tdef(\tdef, {

	inf.do({
		{ SinOsc.ar(840) !2 * EnvGen.ar(Env.sine(0.25), doneAction: 2) * 0.1}.play; //Change the frequency, the duration of the envelope, the amplitude, the wait time, etc. Notice that the old and new parameters can be a bit overlapped depending on the wait time due to Tdef waiting for its next itersation.
		0.3.wait;

	})
}).play
)

Tdef(\tdef).clear; //Proper way to stop the Tdef.

//Last example applied to our SynthDef \klanks, shown earlier (see details in the original code): try to replace the value of the different arguments while running the Synth:
(
SynthDef(
	\klanks,
	{ arg bottomFreq = 30, topFreq = 14000, timesEnv = 3; //Defining some arguments here in order to test the Tdef (original values by default).
		var freqs, times, signal, env;


		freqs = Array.fill(50, { LinRand(bottomFreq, topFreq) });
		times = Array.fill(50, { Rand(0.01, 0.1) });

		signal = Klank.ar(
			`[ freqs, 1, times],
			Resonz.ar(
				Dust.ar(35 !2, 0.075),
				XLine.ar(14000, 30, 15),
				0.2
		));

		env = EnvGen.ar(
			Env([ 0, 1, 1, 0 ], timesEnv, \sine),
		);

		Out.ar(0, signal * env)
}).add
)

(
t = Tdef(\test,
	{ var waitTime;

		waitTime = 2; //Vary also the waitTime in relation to timesEnv.

		inf.do({
			Synth(\klanks,
				[
					\bottomFreq, 200,
					\topFreq, 10000,
					\timesEnv, 3 //Time for all envelope segments (wait time can cause fragmentation or superposition depending on this value).
				]
			);
			(waitTime).wait //It might take more time for it to change the values, depending on the wait time and the moment in which Tdef is evaluated again.
		})
}).play
)

t.clear //Remember that it will only stop when the last synth ends: the method won't cut the sound suddenly, it just stops the routine of Tdef.

//IMPORTANT NOTE AND RECENT QUESTION ABOUT Tdef: I realized I can't use Tdef with a SynthDef that is connected to another SynthDef in In and Out relationship (for example, a synth and a reverb applied through another SynthDef). The problem is that Tdef does not renew the values only, but it runs the synths again, so there is a superposition of both SynthDefs, as if they had just been evaluated twice. I still need to search for a solution to this (or a different possible cause).


////////////////////////////////////////////////////////////////////////////////////////
//NDEF and more about the "Just In Time" library (JITLib, including Ndef, Tdef, Pdef, OSCdef...etc.):
//The JIT library was created to change the architecture of a running program through the creation of a proxy node (an empty container of, for instance, synthesis, in the case of Ndef, or a Task in the case of Tdef, or a pattern in the case of Pdef, etc.). These classes (and let's focus now on Ndef) carry out the task of replacing the architecture while running, so that they are tools mainly intended for live coding, although sometimes they are also very useful for testing (just like we saw previously with Tdef).
//Ndef is sort of an alternative to SynthDefs, which cannot be modified once they are compiled. Instead of a compiled synth, Ndef creates an empty synth which can be modified and which is directly playable.

//Two main differences with respect to SynthDefs: Ndef receives the method .play in order to create an empty synth (or one with content already), and there is no Out object, as its use would overwrite the proxy node:
Ndef(\x, { Mix.ar(SinOsc.ar(Array.rand(2, 333, 666), 0, 0.1)) }).play //Creates a synth and can directly play it.

//Flexibility of Ndef:
Ndef(\y).play //Creates an empty array.
Ndef(\y).fadeTime = 2; //Assigning a fade time (works as fade in / cross fade / out).
Ndef(\y).source = {WhiteNoise.ar(0.03)} //Fills up the array with a WhiteNoise. It will sound right away if \y received .play before (as something that sounds was placed into it). Also, if .fadeTime was sent before, it will apply a fade in time to the noise.
Ndef(\y).source = {SinOsc.ar(440, 0, 0.1)} //Changing the sound source by a SinOsc (.fadeTime will cause a cross fading).
Ndef(\y).pause //We can pause the synth.
Ndef(\y).resume //We can resume the synth.
Ndef(\y).release(2) //Fading out (though still runnin).
Ndef(\y).clear //When sending the .clear message, there is no fade out, but the proxy node will be emptied.

//If any change is performed in any of the possible parameters, Ndef can be executed while running and will replace the new values (it does not create new instances, but modify the current one):
Ndef(\x, { LFSaw.ar(90 + LFPar.ar(100, 0, 100)).dup(2) * 0.1; }).play
Ndef(\x).fadeTime = 2 //Again, .fadeTime will be applied as a cross fade time when modifying the synth.
Ndef(\x).clear

//Ndef can receive arguments as well:
(
Ndef(\z, {
	arg freq = 100, amp = 0.1;

	LFSaw.ar(freq).dup(2) * amp;

}).play
)

Ndef(\z).fadeTime = 2
Ndef(\z).set(\amp, 0.001) //Changing parameters.
Ndef(\z).gui //We can create a graphical interface to control certain parameters (for example, here the keys "freq" and "amp" are recognized by the graphical user interface. There is kind of a list at the end of this documentation: https://doc.sccode.org/Classes/Spec.html (those keys contained within the Dictionary of ControlSpecs). I don't really know if there are more apart from those (like the ones recognized by the GUI in the last example of this document, line 660), but the important thing of ControlSpec is that it determines the lo and hi limits of each parameter (which values does the fader go throughout).

Ndef(\z).clear

//It might be good to try a bunch of different synthesis options to be changed on the go. No new UGens can be written (Ndef needs to be cleared after implementing new UGens), the only option is to replace the ones that were used:
(
Ndef(\m, {
	arg freq = 100, amp = 0.1;

	LFSaw.ar(freq).dup(2) * amp;
	//LFPulse.ar(freq).dup(2) * amp;
	//SinOsc.ar(freq).dup(2) * amp;
	//LFTri.ar(freq).dup(2) * amp;

}).play
)

Ndef(\m).fadeTime = 2 //And changing around in the code or by using the graphical interface, etc.
Ndef(\m).gui
Ndef(\m).clear

//There are, nontheless, some limitations still. The number of channels cannot be changed (the proxy would need to be cleared before changing it) because there is still a certain compilation of its architecture. Though we can change, for example, the channel of the node:
(
Ndef(\c, {
	arg freq = 100, amp = 0.1;

	LFSaw.ar(freq) * amp;

}).playN(1) //Playing the node through the right channel (try changing to 0 while running, it will directly go through the left channel instead). This method would accept an array of non-adjacent channels such as .playN([2, 4, 7]) if playing through a multichannel system.
)

Ndef(\c).clear

//Looking at the node tree, it seems that some new group is created for the proxy nodes.
//Anyway, take a further look into the documentation of Ndef (https://doc.sccode.org/Classes/Ndef.html) and the JIT lib overall (https://doc.sccode.org/Overviews/JITLib.html).

//As the Help file shows, an Ndef can play a Pbind (here, default intrument):
Ndef(\a, Pbind(\dur, 0.03, \freq, Pbrown(0, 1, 0.1, inf).linexp(0, 1, 200, 350))).play //This is why Ndef is between the client and server sides.

//More examples:
(
Ndef(\n, {
	arg freq = 120, amp = 0.1, speed = 8;

	LFTri.ar(LFDNoise0.ar(speed, 500, 1000)).dup(2) * amp;

}).play
)

Ndef(\n).fadeTime = 2;
Ndef(\n).set(\speed, 10) //Changing parameters.
Ndef(\n).release(1) //Turning off with a fade out time.
Ndef(\n).clear

//Last example: execute it successively (could a Tdef be connected to an Ndef to automatize it? Anyway, same limitations as with SynthDef: if using a trigger for the envelope, the deviation value will not be refreshed with each impulse):
(
Ndef(\saw, { //They can have, of course, more descriptive names.
	arg freq = 440, inBus, gate = 1, ffreq = 880; //"ffreq" = freq of the RLPF. Also gate 1 so when executing again, the env can be retriggered.
	var trigger, env, signal, filter;

	env = EnvGen.ar(Env.perc(0, 0.8), gate, doneAction: 2);
	signal = Mix(Saw.ar(freq * Array.rand(10, 0.1, 1), 0.1)); //Ten sawtooth waves with a freq deviation from a fundamental freq.
	filter = RLPF.ar(signal, ffreq, 0.1);

	Pan2.ar(filter, 0, 0.7 * env) //The envelope could have been applied to the filter instead.

}).play
)

Ndef(\saw).gui //freq = 1200 ca. and Ffreq = 1600 ca., cool.
Ndef(\saw).clear

//Extra examples:
//Using Splay on a multichannel signal:
(
Ndef(\x, {
	arg freq = 440, amp = 0.1;

	Splay.ar(
		LFSaw.ar(freq * (1..7) * rrand(1, 1.5), //Again, an array of 7 sawtooth wave overtones, wach one with a random deviation.
			pi.rand, //Random initial phase.
			0.1
		),
		LFTri.kr(0.2, 0, 0.5, 0.5), //Spread (moving between 0 and 1 in five seconds).
		amp
	)

}).play
)

Ndef(\x).fadeTime = 2;
Ndef(\x).gui //I don't really know where the "speed" fader is coming from.
Ndef(\x).release(1)
Ndef(\x).clear

//BEWARE THE VOLUME! Example of feedback: a sound modulating itself.
(
Ndef(\x, {
	SinOsc.ar(
		BrownNoise.ar(30!2, 200), //This is creating two different random signals, but how do they move through the stereo?
		Ndef(\x).ar * LFNoise1.kr(1 !2, 1, 1), //The proxy node is modulating itself (its phase). How does the phase modulation work here?
		1 //It does not work when lowering the amplitude (it sounds much more muffled). But even if I change the amplitude by multiplying the entire signal, it affects the feedback.
	)
}).play;
)

Ndef(\x).clear
