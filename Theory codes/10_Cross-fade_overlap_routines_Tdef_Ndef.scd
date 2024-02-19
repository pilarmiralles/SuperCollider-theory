//10 - CROSS FADE AND OVERLAP ROUTINES, TDEF and NDEF

/////////////////////////////////////////////////////////////////////
//ALGORITHMIC COMPOSITION WITH ROUTINES

//This theory file deals with the first steps into algorithmic composition using Routines. Cross-fade and overlap Routines will allow us to create continuous textures that can change over time thanks to the concatenation or overlap of various instances of a SynthDef. These are just a couple of possible strategies to work with the SynthDef-Routine combo.


/////////////////////////////////////////////////////////////////////
//CROSS-FADE ROUTINES

//The idea behind the cross-fade routine is to create synths with a time of fade-in and fade-out: when the fade-out of a synth is initialized, the fade-in of the next synth is triggered, bringing about a continuous cross-fade texture (constant flow). Therefore, we need the fade-out time of a synth to be shared as the fade-in time of the next, and this is the iteration process we can program in the Routine alonside the creation of synths itself. The key to make these systems more flexible and versatile is to take advantange of all Client-side resources, such as patterns or control structures, as we will study in the theory file 11. The use of doneAction = 2 is essential, once again, to allow the synths to be successively freed.

//First example, simplest case: equal cross and sustain times. In all cases, the SynthDef will pretty much consist of the same elements, a signal (in this case, a bank of three BPF filtering a BrownNoise, and whose cutoff freq is sent from the Routine), an envelope (in this case, a simple sine envelope) and an Out object which writes the signal multiplied by the envelope to an output channel:
(
SynthDef(
	\filters1,
	{ |freqs = #[0, 0, 0], crossTime, sustTime| //Sending an array of literals to an argument (its size cannot be changed once the SynthDef is compiled).
		var signal, env;

		signal = Mix(
			BPF.ar(
				BrownNoise.ar,
				freqs,
				0.5/freqs, //The higher the frequency, the smaller the rq value.
				2
			)
		) !2; //Mono-duplicated Mix (only three freqs are sent from the Routine, so the same three freqs would be copied on each side anyway if using curly brackets around the Mix).

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0], //The segments of the envelope represent the fade-in, sustain and fade-out of each synth.
				[crossTime, sustTime, crossTime],
				\sine
			),
			doneAction: 2 //As mentioned before, doneAction = 2 is essential to free the synths after the envelope is finished.
		);

		Out.ar(0, signal * env)
}).add
)

(
r = Routine({
	var freqs;

	freqs = 100 * Array.series(16, 1); //Option for random overtones from a series of 16 overtones from a fundamental freq of 100 Hz (100-1600 Hz).
	//freqs = Array.fill(30, { exprand(800, 4000) }); //Option for random frequencies (high range, for instance).

	inf.do({
		Synth(\filters1, [
			\freqs, { freqs.choose } !3, //Array of three random frequencies.
			\crossTime, 3, //Cross time and sustain time are equal and fixed.
			\sustTime, 3,
		]);

		(3 + 3).wait //Each envelope lasts for 3 + 3 + 3 seconds. The waiting time is only 3 + 3 so that when a synth starts its fade-out, the next instance begins its fade-in, being cross-faded for 3 seconds.
	})
}).play
)
r.stop //The sound will stop afte the last envelope is finished instead of suddenly.


//Second example: different cross and sustain times. The SynthDef is exactly the same as in the former example. The only difference is that now we need different arguments for the fade-in and fade-out times:
(
SynthDef(
	\filters2,
	{ |freqs = #[0, 0, 0], crossTime1, sustTime, crossTime2|
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
				[crossTime1, sustTime, crossTime2], //Different arguments for fade-in and fade-out times.
				\sine
			),
			doneAction: 2
		);
		Out.ar(0, signal * env)
}).add
)

(
r = Routine({
	var freqs, crossTime1, sustTime, crossTime2;

	//freqs = 200 * Array.series(20, 1); //Option with random overtones from a fundamental frequency of 200 Hz.
	freqs = Scale.minor.ratios * 72.midicps; //Option with pitches from a minor scale within the octave of C5.

	crossTime1 = rrand(1.0, 8); //Initial fade-in time (only applicable during the first iteration, later dependant on the crossTime2).

	inf.do({

		//Sustain and cross times are now radomly chosen in each iteration:
		sustTime = rrand(1.0, 8);
		crossTime2 = rrand(1.0, 8);

		Synth(\filters2, [
			\freqs, { freqs.choose } !3,
			\crossTime1, crossTime1,
			\sustTime, sustTime,
			\crossTime2, crossTime2
		]);

		[crossTime1, sustTime, crossTime2].round(0.1).postln; //For testing: the three times of the envelope segments are printed so that it can be checked that the duration of the third segment in each iteration is equal to the duration of the first segment in the next envelope. Any line of the code dedicated to testing should be eliminated or commented when the testing is done, so that it does not consume CPU resources.

		(crossTime1 + sustTime).wait; //Again, the fade-out time is excluded from the wait time so that the synths are overlapped during the cross time.

		crossTime1 = crossTime2; //This is the key step of this example: the fade-out time is reassigned as the fade-in time of the next synth at the end of each iteration of the Routine.

	})
}).play
)
r.stop


//Another example, using Klank:
(
SynthDef(
\klanks,
	{ var freqs, times, signal, env;

		//These two variables will define Klank's specifications array ref:
		freqs = Array.fill(50, { LinRand(30, 14000) }); //Rand would highlight the high freqs and ExpRand would balance low and high freqs. LinRand is in the mid way of both distributions (linear distribution), but you can try out the other options.
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
			Env([ 0, 1, 1, 0 ], 5, \sine), //We are using the same time for all segments in the envelope (cross / sust times), so one single number can be set (this could be defined in the routine as well).
			doneAction: 2
		);

		Out.ar(0, signal * env)
}).add
)

( //No arguments are being choosen in the Routine: it just activates one synth after another.
r = Routine({
	inf.do({
		Synth(\klanks);
		(5 + 5).wait //The Xline is 15 seconds long, thus there will be an overlapping of 5 seconds.
	})
}).play
)
r.stop


/////////////////////////////////////////////////////////////////////
//OVERLAP ROUTINES

//The idea is to create several synths at the same time, being this number of synths controlled by us through an argument called "density". The synths will replace each other continuously in the server: for this, we need the waiting time to be equal to the entire duration of each synth divided by the number of synths (density), so that the lower the waiting time, the greater the density.

//First example: the SynthDef is similar to the one used for cross-fade Routines. We are sending one frequency at a time only, and we are including the new argument "density", which in the SynthDef is only used to control the amplitude balance according to the number of synths we want to be running at the same time:
(
SynthDef(
	\overlapFilter,
	{ |freq, crossTime = 5, sustTime = 5, density = 5|
		var signal, env, individualAmp;

		individualAmp = ((density.log2 + 1) * -3.01).dbamp * 0.5; //Amplitude balance based on the number of synths running at the same time (applied to the levels of the envelope to lower the amplitude accordingly). Why this formula? I keep this formula from my first SC teacher because it works quite well, but some hints about it are:
		/*
		- the * 0.5 at the end can be adjusted as kind of a master volume for further amplitude control of the entire formula.
		- when density = 1, 1.log2 would be 0, so to avoid the 0, there is the + 1 and the amplitude would be then -3.01 dB.
		- when density = 2, 2.log2 would be 1, so 1 + 1 = 2, and 2 * -3.01 = -6.02 dB, which is more or less half of the amplitude for each).
		- the logarithmic function continues like this as it goes up, balancing the density in dB as these work within the logarithmic scale.
		*/

		signal = BPF.ar(
			BrownNoise.ar(1 !2),
			freq,
			0.5/freq,
			10
		);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * individualAmp, //Amplitude balance (multiplied by all levels of the amplitude envelope.
				[crossTime, sustTime, crossTime],
				\sine
			),
			doneAction: 2
		);

		Out.ar(0, signal * env)
}).add
)

( //Open the node tree when executing the Routine to observe how the synths appear gradually and replace each other at a regular pace of (crossTime + sustTime + crossTime) / density (in this case, every 3 seconds as the total time of each synth is 15 secs and the density is 5: 15/5 = 3), keeping a constant flow of 5 synths at the same time:
r = Routine({
	var density, crossTime, sustTime, freqs;

	density = 5;

	crossTime = 5;
	sustTime = 5;

	//freqs = Array.geom(10, 100, 3/2); //Option for stack of fifths.
	freqs = Scale.minor.ratios * 72.midicps; //Option for minor scale within the C5 octave.

	inf.do({
		Synth(\overlapFilter,
			[
				\freq, freqs.choose,
				\crossTime, crossTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((crossTime + sustTime + crossTime) / density).wait
	})
}).play
)
r.stop //Takes some time for all envelopes to finish.


//Glissando effect (using the same SynthDef as in the previous example): try out the four possible combinations:
/*
- Line [0, freqs.lastIndex] and freqs[line.next.asInteger.postln..].choose --> Available indexes for choosing start from the entire array and close towards the very last index alone (high freq).
- Line [0, freqs.lastIndex] and freqs[..line.next.asInteger.postln].choose --> Available indexes for choosing start from the very first index only (low freq) and open up towards the entire array.
- Line [freqs.lastIndex, 0] and freqs[line.next.asInteger.postln..].choose --> Available indexes for choosing start from the very last index only (high freq) and open down towards the entire array.
- Line [freqs.lastIndex, 0] and freqs[..line.next.asInteger.postln].choose --> Available indexes for choosing start from the entire array and close towards to very first index alone (low freq).
*/
(
r = Routine({
	var density, crossTime, sustTime, freqs, line;

	density = 100;
	crossTime = 2;
	sustTime = 2;

	freqs = Array.geom(200, 35, 0.5.midiratio); //Series of 200 quarter tones (0.5.midiratio) from 35 Hz.

	//The line is 6 seconds long (equivalent time to the total duration of synths' envelope (2 + 2 + 2). The line is created by turning an envelope into a stream (this could have been done with a Pattern instead, but we will study those later on), so that we can ask for each value from the loop by using the method .next. The values given by this envelope are the indexes of the array of frequencies (from the first to the last or from the last to the first, if choosing the downward option):
	line = Env([0, freqs.lastIndex], 6).asStream; //[freqs.lastIndex, 0] downward option.

	inf.do({
		Synth(\overlapFilter,
			[
				//Asking the line for each value by using .next:
				\freq, freqs[line.next.asInteger.postln..].choose, //[..line.next.asInteger.postln] opposite option. Remember that the two dots mean "from this index up to the last available index" or "from the first available index up to this index".
				\crossTime, crossTime,
				\sustTime, sustTime,
				\density, density,
		]);
		((crossTime + sustTime + crossTime) / density).wait
	})
}).play
)
r.stop


/////////////////////////////////////////////////////////////////////
//SOLUTIONS TO PROBLEMS POSED BY DONEACTION = 2

//DoneAction = 2 can provoke that processes such as envelopes, delays or reverbs are cut suddently when the Synth is removed from the server. There are different solutions to this problem: using DetectSilence, a dissengaged Line or an overall envelope:

//Here we have a simple sawtooth SynthDef and routine similar to the one presented in theory file 9, now with Delay applied to it. Three different solutions to the problem mentioned before are explained at the end of the first SynthDef, after applying the Delay:
(
SynthDef(
	\sawtooth,
	{| out, freq, dur, amp |
		var signal, env, signalOut, delay, envGlobal, finalSignal;

		signal = Saw.ar(freq); //Pan2 has been removed from the original example in order to demonstrate the Delay and its solutions within a routine.

		env = EnvGen.ar(
			Env.perc(0.005, dur, amp),
			doneAction: 0
		);

		signalOut = signal * env;

		delay = DelayC.ar(signalOut, 2, 2); //Delay of 2 seconds: we need to prevent doneAction 2 in the envelope from cutting this delay before it is finished:

		//FIRST OPTION: the object DetectSilence allows us to apply doneAction 2 when a process that sounds is finished. According to the help file: it "detects when input falls below an amplitude threshold" (which is 0.0001 by default). The first argument is the signal to "be heard", the second one is the amplitude threshold, the third one is the "minimum duration for which the input must fall below the amplitude threshold before doneAction is triggered", and the last argument is doneAction. Try commenting DetectSilence and adding doneAction 2 to the envelope: in that case, the delayed signal will not be heard at all:
		DetectSilence.ar(delay, doneAction: 2); //doneActio: Done.freeSelf is equivalent to 2.

		//A SIMILAR BUT DIFFERENT OBJECT: FreeSelfWhenDone is slightly different from DetectSilence. According to the help file: it "frees the enclosing synth when a UGen is finished", that is to say, it is not dependent on an amplitude threshold. Its only argument is the source, the UGen to be checked "for done", and it is always used at control rate. This object cannot be applied to the delay: it can only be applied to UGens that feature what is called a "done flag", which is set when they are finished. This object is equivalent to doneAction, but there are UGens with done flag that do not feature a doneAction, so that this object becomes necessary for them (the list of UGens featuring a done flag can be seen at the beginning of this document: https://doc.sccode.org/Classes/Done.html). Anyway, this is not useful for our example here (as, applied to the EnvGen, it would be equivalent to doneAction: 2):
		//FreeSelfWhenDone.kr(env);

		//SECOND OPTION: this solution consists of creating a Line existing by its own (not applied to any variable) and containing doneAction 2. The arguments start and end do not matter much (as this line is not applied to anything that sounds), but the time argument needs to be adjusted to the total time of the process we need to prevent from being cut (in this case, the delay + the envelope time):
		//Line.ar(0, 1, dur + 2, doneAction: 2);

		//THIRD SOLUTION: the last solution for now is creating a global envelope to be multiplied by the out signal. This solution might not be the best as it might have a direct impact on the sound (not in this case though). The time of the delay and the duration of the envelope are included as time for the sustain segent of this global envelope:
		//envGlobal = EnvGen.ar(Env([0.0001, 1, 1, 0.0001], [0.01, dur + 2, 0.01], \exponential), doneAction: 2);

		finalSignal = [delay, signalOut] * 0.7;

		Out.ar(out, finalSignal) //Remember to multiply finalSignal * envGlobal if using the third solution for doneAction 2.

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
			\out, 4,
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
g.free //When using a second synth for reverb (with no doneAction 2), it is necessary to free it as well, so that it doesn't continue running in the server.


/////////////////////////////////////////////////////////////////////
//TDEF

//More information about the JITlib: https://doc.sccode.org/Overviews/JITLib.html. Also in the next section about NDef.
//Tdef is a class from the JITLib ("Just in Time" Library), which is mainly used for live coding. Nonetheless, this object is also quite useful when testing different values, for instance, for the arguments of a SynthDef sent from a Routine. It allows us to change parameters of the routine and execute it again while running: the new values will be replaced in the next iteration of the Routine, that is, in the next instance of the Synth created. It needs a name (a \symbol) and then the function (just like a Routine function):

//Simple example with no sound: you can try out adding or deleting characters in the string, changing the wait time, etc., while the loop is running, by simply executing the function again to replace the new values in real time:
(
Tdef(\tdef, {

	inf.do({
		"hello".scramble.postln;
		1.wait;
	})
}).play
)

Tdef(\tdef).clear //Proper way of stopping a Tdef.

//Simple example with sound: try out different values for the freq of SinOsc, duration of the envelope, wait time, etc., as before, just by changing the value and executing the function again while running:
(
Tdef(\tdef, {

	inf.do({
		{ SinOsc.ar(1040) !2 * EnvGen.ar(Env.sine(0.25), doneAction: 2) * 0.1 }.play;
		0.3.wait;
	})
}).play
)

Tdef(\tdef).clear

//One last example applied to the previous SynthDef-Routine with Klank (see details in the original code). Try as well to replace the value of the different arguments while running the Synth (remember that it might take time for the new values to be implemented, according to the duration of each synth):
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

		waitTime = 5; //Vary also the waitTime in relation to timesEnv.

		inf.do({
			Synth(\klanks,
				[
					\bottomFreq, 200,
					\topFreq, 10000,
					\timesEnv, 5 //Time for each envelope segment (depending on the wait time and this time, either segmentation or overlapping may occur).
				]
			);
			(waitTime).wait
		})
}).play
)
t.clear  //Tdef can be also directly cleared if assigned to a variable like this.


//When using Tdef with a system of SynthDefs In-Out, for instance, to apply a reverb to the passing synths of a routine as a whole, the reverb Synth (at the tail of the group) needs to be placed out of the Tdef, so that several instances of the reverb synth aren't created (and accumulated in the server). Let's see an example of this (let's use yet again the Sawtooth Synthdef from theory file 9):

(
SynthDef(
	\sawtooth,
	{ |out, freq, dur, amp|
		var signal, env;

		signal = Pan2.ar(Saw.ar(freq), Rand(-1, 1));

		env = EnvGen.ar(
			Env.perc(0.005, dur, amp),
			doneAction: 2
		);

		Out.ar(out, signal * env)

}).add;
SynthDef(
	\resonator,
	{ |in|
		var input, signal;

		input = In.ar(in, 2);

		signal = LeakDC.ar(
			Mix(
				CombC.ar(
					input * 0.1,
					1/500,
					1/({ LFDNoise3.ar(1, 300, 800) } !10), //The original had a freq of 0.1 for the LFDNoise. With a freq of 1, the gliss is quite evident.
				).clump(2)
		));

		Out.ar(0, signal)

}).add
)

o = Synth(\resonator, [\in, 4], s, \addToTail); //The resonator's Synth needs to be placed outside Tdef for it not to be duplicated constantly when changing values and executing Tdef while running. Now Tdef can be evaluated and values can be changed and sent on the go:

(
Tdef(\ping, {

	inf.do({

		Synth(\sawtooth, [
			\out, 4,
			\freq, exprand(1000, 3000),
			\dur, exprand(0.001, 0.125),
			\amp, exprand(0.05, 0.3)
		],
		s, \addToHead);

		exprand(0.05, 1.0).wait
	})

}).play
)

Tdef(\ping).clear
o.free


/////////////////////////////////////////////////////////////////////
//NDEF

//Anothe class from the JITLib that might be useful to get to know is NDef. Let's get a bit more in detail into the JITLib:
//The JIT library was created to change the architecture of a running program through the creation of a proxy node (an empty container of, for instance, synthesis, in the case of Ndef, or a Task in the case of Tdef, or a pattern in the case of Pdef, etc.). These classes (and let's focus now on Ndef) carry out the task of replacing the architecture while running, and thus they are tools mainly intended for live coding, although sometimes they are also very useful for testing (just like we saw previously with Tdef).
//Ndef is sort of an alternative to SynthDefs, which cannot be modified once they are compiled. Instead of a compiled synth, Ndef creates an empty synth which can be modified and which is directly playable.

//Two main differences with respect to SynthDefs: Ndef receives the method .play in order to create an empty synth (or one with content already), and there is no Out object as its use would overwrite the proxy node:
Ndef(\x, { Mix.ar(SinOsc.ar(Array.rand(2, 333, 666), 0, 0.1)) !2 }).play //Creates a synth and plays it directly.

//Flexibility of Ndef:
Ndef(\y).play //Creates an empty array.
Ndef(\y).fadeTime = 2; //Assigning a fade time (works as fade in / cross fade / out).
Ndef(\y).source = { WhiteNoise.ar(0.03 !2) } //Fills up the array with a WhiteNoise. It will sound right away if \y received .play before (as something that sounds was placed into it). Also, if .fadeTime was sent before, it will apply a fade in time to the noise.
Ndef(\y).source = { SinOsc.ar(440, 0, 0.1 !2) } //Changing the sound source to a SinOsc (.fadeTime will cause a cross fading).
Ndef(\y).pause //We can pause the synth.
Ndef(\y).resume //We can resume the synth.
Ndef(\y).release(2) //Fading out (though still running: we can use .source = something to obtain sound again).
Ndef(\y).clear //When sending the .clear message, there is no fade out and the proxy node will be emptied (we can use .release and then .clear to clearing the node smoothly).

//If any change is performed in any of the possible parameters, Ndef can be executed while running and will replace the new values (it does not create new instances, but modify the current one):
Ndef(\x, { LFSaw.ar(100 + LFPar.ar(100, 0, 100)).dup(2) * 0.02 }).play //Try out modifying the freq of LFSaw or LFPar or the mul of LFPar (this is FM).
Ndef(\x).fadeTime = 2 //Again, .fadeTime will be applied as a cross fade time when modifying the synth.
Ndef(\x).clear

//Ndef can receive arguments as well:
(
Ndef(\z, {
	arg freq = 100, amp = 0.02;

	LFSaw.ar(freq).dup(2) * amp;

}).play
)

Ndef(\z).fadeTime = 2
Ndef(\z).set(\freq, 80) //Changing parameters with .set while running.
Ndef(\z).gui //We can create a graphical interface to control certain parameters (for example, here the keys "freq" and "amp" are recognized by the graphical user interface. There is kind of a list at the end of this documentation: https://doc.sccode.org/Classes/Spec.html: those keys contained within the Dictionary of ControlSpecs. I don't really know if there are more apart from those (like the ones recognized by the GUI in the last example of this document), but the important thing about ControlSpec is that it determines the lo and hi limits of each parameter (which values does the fader go throughout)).
Ndef(\z).clear

//It might be good to try a bunch of different synthesis options to be changed on the go. No new UGens can be written (Ndef needs to be cleared after implementing new UGens), the only option is to replace the ones that were used:
(
Ndef(\m, {
	arg freq = 100, amp = 0.02;

	//These can be exchanged just like when using .source:
	//LFSaw.ar(freq).dup(2) * amp; //Careful, unfiltered version.
	LFPulse.ar(freq).dup(2) * amp; //Careful, unfiltered version.
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
	arg freq = 100, amp = 0.02;

	LFSaw.ar(freq) * amp;

}).playN(1) //Playing the node through the right channel (try changing to 0 while running, it will directly go through the left channel instead). This method would accept an array of non-adjacent channels such as .playN([2, 4, 7]) if playing through a multichannel system.
)
Ndef(\c).clear

//Looking at the node tree, it seems that some new group is created for the proxy nodes.
//Anyway, take a further look into the documentation of Ndef (https://doc.sccode.org/Classes/Ndef.html) and the JIT lib overall (https://doc.sccode.org/Overviews/JITLib.html).


//##############################################################
//Some more advanced examples:

//As the Help file shows, an Ndef can play a Pbind (here, default intrument):
Ndef(\a, Pbind(\dur, 0.03, \freq, Pbrown(0, 1, 0.1, inf).linexp(0, 1, 200, 350))).play //This is why Ndef is between the client and server sides.
Ndef(\a).clear

//Another example:
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

//Last example: execute it successively (could a Tdef be connected to an Ndef to automatize it? Anyway, same limitations as with SynthDef: if using a trigger for the envelope, the random deviation value will not be refreshed with each impulse):
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
