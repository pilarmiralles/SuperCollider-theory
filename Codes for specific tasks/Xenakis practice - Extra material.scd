(//INSTRUMENT:
SynthDef(
	\overlapXenakisReverbCombo,
	{arg out = 4, transitionTime, sustainTime, density, midFreq = 1000, freqDev = 5, timeLFNoise = 2, levelLo = -1.0, levelHi = 1.0, timeLo = 0.00001, curveLo = -4.0, curveHi = 4.0, volume = 0.05, which = 0;
		var amps, nextDuration, levels, curves, trigger, numPoints = 12, signal, freq, env, signalOut;


		amps = ((density.log2 + 1) * -3.01).dbamp;

		freq = LFDNoise3.ar(1/timeLFNoise, (midFreq + midFreq/freqDev) - (midFreq - midFreq/freqDev)/2 + midFreq - midFreq/10, (midFreq + midFreq/freqDev) - (midFreq - midFreq/freqDev)/2);

		trigger = Impulse.ar(freq);

		levels = Array.fill(numPoints, {TRand.ar(levelLo, levelHi, trigger)});

		nextDuration = Array.fill(numPoints - 1, {TRand.ar(timeLo, freq.reciprocal/12, trigger)});

		curves = Array.fill(numPoints -1, {TRand.ar(curveLo, curveHi, trigger)});

		signal = Select.ar(which,
			[
				EnvGen.ar(
					Env(
						levels,
						nextDuration,
						curves
					),
					Impulse.ar(1/nextDuration.sum)
				),
				EnvGen.ar(
					Env(
						levels,
						nextDuration,
						curves
					),
					trigger,
					timeScale: freq.reciprocal

				)
		]);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = (signal * env) * volume !2;

		Out.ar(out, signalOut)
}).add;
SynthDef(
	\reverb,
	{ arg in, time;
		var input, dry, wet, signalOut;

		input = In.ar(in, 2);

		dry = input;

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !8
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		signalOut = dry + LPF.ar(wet, 3000);

		OffsetOut.ar(0, signalOut)
}).add
)

/////////////////////////////////////////////////////////////////////////////////////////EVALUATE EVERY STEP SO IT SOUNDS!! (which is a little bit annoying)
//SCORE: this is not a routine anymore, so first I just compile a bunch of patterns and functions:

(
var densityDefault = 5, density1, density2, density3, transitionTime, sustainTime, freqs, freqMin1 = 1000, freqMax1 = 10000, timeLo1 = 0.00001, freqMin2 = 1000, freqMax2 = 10000, timeLo2 = 0.00001, freqMin3 = 1000, freqMax3 = 10000, timeLo3 = 0.00001, freqMin4 = 600, freqMax4 = 13000, timeLo4 = 0.001, freqMin5 = 13000, freqMax5 = 16000, timeLo5 = 0.00001, which = 0, thisDensity = 5, iterations1 = 1;

Synth(\reverb, [ \in, 4, \time, 2 ], s, \addToTail);

which = Pwrand([0, 1], [5, 2].normalizeSum, inf).asStream;

//First path's values:
freqMin1 = Pseg([500, 12000], [10, 5], \lin, inf).asStream;
freqMax1 = Pseg([2000, 15000], [10, 5], \lin, inf).asStream;
timeLo1 = Pseg([0.001, 0.00005], [10, 5], \lin, inf).asStream;

//Second path's values;
freqMin2 = Pseg([7000, 15000, 500], [10, 3, 5], \lin, inf).asStream;
freqMax2 = Pseg([10000, 17000, 1500], [10, 3, 5], \lin, inf).asStream;
timeLo2 = Pseg([0.005, 0.00001, 0.001], [10, 3, 5], \lin, inf).asStream;

//Third path's values;
freqMin3 = Pseq([Pseg([8000, 15000], [5], \lin, 1), Pbrown(11000, 13000, 200, inf)], 1).asStream;
freqMax3 = Pseq([Pseg([11000, 17000], [5], \lin, 1), Pbrown(13000, 17000, 200, inf)], 1).asStream;
timeLo3 = Pseq([Pseg([0.0005, 0.000005], [5], \lin, 1), Pbrown(0.00005, 0.00001, 0.000005, inf)], 1).asStream;
density1 = Pseg([5, 5, 2, 3, 7], [1, 7, 5, 4, 3], \step, inf).asStream; //First value repeated because of the /step.

//High frequencies path:
freqMin4 = Pbrown(13000, 15000, 200, inf).asStream;
freqMax4 = Pbrown(15000, 18000, 200, inf).asStream;
timeLo4 = Pbrown(0.00005, 0.000005, 0.000001, inf).asStream;
density2 = Pseq([7, Pwrand([7, 5, 3], [20, 2, 1].normalizeSum, inf)], 1).asStream;

//Low frequencies path:
freqMin5 = Pbrown(600, 1300, 200, inf).asStream;
freqMax5 = Pbrown(1300, 2500, 200, inf).asStream;
timeLo5 = Pbrown(0.001, 0.0005, 0.00001, inf).asStream;
density3 = Pwrand([7, 5, 3], [3, 4, 4].normalizeSum, inf).asStream;

//NOW EACH LOOP (.DO) IS A FUNCTION THAT IS CALLED FROM THE OUTSIDE (manually):

~do1 = {
	~iterations.do({ arg i;

		var thisFreq1 = 10000, synth1;

		i.asInt.postln;

		transitionTime = rrand(0.5, 1.5);
		sustainTime = rrand(1.0, 3.0);

		thisFreq1 = Array.fill(50, {exprand(freqMin1.next, freqMax1.next)});
		thisDensity = densityDefault;

		synth1 = Synth(\overlapXenakisReverbCombo, //Add more arguments, if needed.
			[
				\transitionTime, transitionTime,
				\sustainTime, sustainTime,
				\density, thisDensity,
				\midFreq, thisFreq1.choose,
				\timeLo, timeLo1.next,
				\volume, 0.1,
				\which, which.next
			],
			s, \addToHead
		);


		((transitionTime + sustainTime + transitionTime) /thisDensity).wait

	})
};

~do2 = {
	~iterations.do({ arg i;

		var thisFreq2 = 10000, synth2;

		i.asInt.postln;

		transitionTime = rrand(0.5, 1.5);
		sustainTime = rrand(1.0, 3.0);

		thisFreq2 = Array.fill(50, {exprand(freqMin2.next, freqMax2.next)});
		thisDensity = densityDefault;

		synth2 = Synth(\overlapXenakisReverbCombo,
			[
				\transitionTime, transitionTime,
				\sustainTime, sustainTime,
				\density, thisDensity,
				\midFreq, thisFreq2.choose,
				\timeLo, timeLo2.next,
				\volume, 0.1,
				\which, which.next
			],
			s, \addToHead
		);

		((transitionTime + sustainTime + transitionTime) /thisDensity).wait

	})
};

~do3 = {
	~iterations.do({ arg i;

		var thisFreq3 = 10000, synth3;

		i.asInt.postln;

		transitionTime = rrand(0.5, 1.5);
		sustainTime = rrand(1.0, 3.0);

		thisFreq3 = Array.fill(50, {exprand(freqMin3.next, freqMax3.next)});
		thisDensity = density1.next;

		synth3 = Synth(\overlapXenakisReverbCombo,
			[
				\transitionTime, transitionTime,
				\sustainTime, sustainTime,
				\density, thisDensity,
				\midFreq, thisFreq3.choose,
				\timeLo, timeLo3.next,
				\volume, 0.1,
				\which, which.next
			],
			s, \addToHead
		);

		((transitionTime + sustainTime + transitionTime) /thisDensity).wait

	})
};

~do4 = {
	~iterations.do({ arg i;

		var thisFreq4 = 10000, synth4;

		i.asInt.postln;

		transitionTime = rrand(0.5, 1.5);
		sustainTime = rrand(1.0, 3.0);

		thisFreq4 = Array.fill(50, {exprand(freqMin4.next, freqMax4.next)});
		thisDensity = density2.next;

		synth4 = Synth(\overlapXenakisReverbCombo,
			[
				\transitionTime, transitionTime,
				\sustainTime, sustainTime,
				\density, thisDensity,
				\midFreq, thisFreq4.choose,
				\timeLo, timeLo4.next,
				\volume, 0.1,
				\which, which.next
			],
			s, \addToHead
		);

		((transitionTime + sustainTime + transitionTime) /thisDensity).wait

	})
};

~do5 = {
	~iterations.do({ arg i;

		var thisFreq5 = 10000, synth5;

		i.asInt.postln;

		transitionTime = rrand(0.5, 1.5);
		sustainTime = rrand(1.0, 3.0);

		thisFreq5 = Array.fill(50, {exprand(freqMin5.next, freqMax5.next)});
		thisDensity = density3.next;

		synth5 = Synth(\overlapXenakisReverbCombo,
			[
				\transitionTime, transitionTime,
				\sustainTime, sustainTime,
				\density, thisDensity,
				\midFreq, thisFreq5.choose,
				\timeLo, timeLo5.next,
				\volume, 0.1,
				\which, which.next
			],
			s, \addToHead
		);

		((transitionTime + sustainTime + transitionTime) /thisDensity).wait

	})
};
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Then, the function: NOW controlling the number of iterations: THIS WORRRRRRRKS, but there is only one small issue -> number of iterations != number of seconds (for the wait), so there might be gaps between the routines or small overlaps. BUT IT WORKS BY ITSELF OMGGGG + doing away with some of the global variables, so it is not so dangerous to confuse them:
(
Routine({

	var thisIteration, xenakisCode, counter, modulo, iterationsPattern;

	counter = Pseries(0, 1, inf).asStream;
	modulo = Prand([3, 4, 5, 7], inf).asStream;
	iterationsPattern = Prand([3, 5, 10], inf).asStream;

	xenakisCode = {

		thisIteration = iterationsPattern.next; //First choosing the number of iterations for any of the paths:

		switch
		(counter.next % modulo.next)
		{0}{{~do1.value}.fork; ~iterations = thisIteration; "first path".postln}
		{1}{{~do2.value}.fork; ~iterations = thisIteration; "second path".postln}
		{2}{{~do3.value}.fork; ~iterations = thisIteration; "third path".postln}
		{3}{{~do4.value}.fork; ~iterations = thisIteration; "fourth path".postln}
		{{~do5.value}.fork; ~iterations = thisIteration; "fifth path".postln} //The "else" case
	};

	inf.do({
		xenakisCode.value;
		thisIteration.wait //Then the number of iterations would be the waiting time before activating the switch again (but number of iterations is not equal to seconds, that is a little issue right there). BUT SOMEHOW IT WORKS, SO IT'S ALL GOOD...
	})

}).play
)

//YASSSSSS, EVENTUALLY WORKING (see recorded example): now it is just a matter of adjusting the values within the envelopes of the second block (the "score") and also varying the modulo values, abd the iteration values of the latter routine, so there is a different kind of randomness (just a matter of taste).