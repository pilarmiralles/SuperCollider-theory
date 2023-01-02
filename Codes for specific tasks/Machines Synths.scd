//MACHINES SYNTHS --> All of those using Schroeder filter could be enhanced with the filter in an independent Synthdef (add to tail), but Idk if that would change the sound result (test).
/////////////////////////////////////

//From "machines synth" and "Closing My Eyes, Smiling and Touching Your Hair Again":
(
SynthDef(\machines,

	{arg out = 0, rq = 0.01, mulNoise = 0.1, mul = 0.1, freqPulse = 80, freqInf = 80, freqSup = 300, time = 1;
		var signal, env, signalOut, finalSignal, wet, dry, reverb;

		signal = {Mix(
			BPF.ar(
				Pulse.ar(freqPulse, PinkNoise.ar(mulNoise), 0.2),
				Array.fill(100, {ExpRand(freqInf, freqSup)}),
				rq,
				mul
			)
		)} !2;

		env = EnvGen.ar(Env.sine(1, 0.5), doneAction: 0);

		signalOut = signal * env;

		finalSignal = signalOut ring1: BrownNoise.ar(0.7);

		dry = finalSignal;

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !4
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		reverb = LPF.ar(wet, 2000);

		DetectSilence.ar(reverb, doneAction: 2);

		Out.ar(out, reverb)
}).add
)

(
Tdef(
	\holaa,
	{ var freqs;

		freqs = Array.series(10, 300, 100);

		inf.do({
			Synth(\machines,
				[
					\out, 0,
					\rq, 0.001,
					\mulNoise, 0.5,
					\mul, 5,
					\freqPulse, freqs.choose,
					\freqInf, 50, //100
					\freqSup, 300, //600
					\time, 5
			]);
			([1, 0.6, 0.42].choose).wait
		})
}).play
)

//Same code, but using specific freqs:
(
SynthDef(\machines,

	{arg out = 0, rq = 0.01, mulNoise = 0.1, mul = 0.1, freqPulse = 80, root, time = 1;
		var signal, env, signalOut, finalSignal, wet, dry, reverb;

		signal = {Mix(
			BPF.ar(
				Pulse.ar(freqPulse, PinkNoise.ar(mulNoise), 0.2),
				Array.geom(6, root.midicps, 2),
				rq,
				mul
			)
		)} !2;

		env = EnvGen.ar(Env.sine(1, 0.5), doneAction: 0);

		signalOut = signal * env;

		finalSignal = signalOut ring1: BrownNoise.ar(0.7);

		dry = finalSignal;

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !4
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		reverb = LPF.ar(wet, 1000);

		DetectSilence.ar(reverb, doneAction: 2);

		Out.ar(out, reverb)
}).add
)

(
Tdef(
	\holaa,
	{ var freqs, roott;

		freqs = [43, 45, 46, 48, 50, 51, 53, 55];
		roott = [31, 33, 34, 36, 38, 39, 41, 43];

		inf.do({
			Synth(\machines,
				[
					\out, 0,
					\rq, 0.0001,
					\mulNoise, 0.5,
					\mul, 7,
					\freqPulse, freqs.choose.midicps,
					\root, roott.choose,
					\time, 10
			]);
			([1, 0.6, 0.42].choose).wait
		})
}).play
)

//And with complete chords:
(
SynthDef(\machines,

	{arg out = 0, rq = 0.01, mulNoise = 0.1, mul = 0.1, freqPulse = 80, root, root2, root3, root4, time = 1, mastervolume = 2, clip;
		var signal, env, signalOut, finalSignal, wet, dry, reverb, freqs;

		freqs = Array.geom(5, root, 2) ++ Array.geom(5, root2, 2) ++ Array.geom(5, root3, 2) ++ Array.geom(5, root4, 2);

		signal = {Mix(
			BPF.ar(
				Pulse.ar(freqPulse, PinkNoise.ar(mulNoise), 0.2),
				freqs,
				rq,
				mul
			)
		)} !2;

		env = EnvGen.ar(Env.sine(1, 0.5), doneAction: 0);

		signalOut = signal * env;

		finalSignal = signalOut ring1: BrownNoise.ar(0.7);

		dry = finalSignal; //Colocar aquí cualquier código.

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !4
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		reverb = LPF.ar(wet, 500);
		//reverb = reverb.clip2(clip); //Try with possible distortion.

		DetectSilence.ar(reverb, doneAction: 2);

		Out.ar(out, reverb * mastervolume)
}).add
)

(
Tdef(
	\holaa,
	{ var freqs, roott, roott2, roott3, roott4;

		freqs = ([43, 45, 46, 48, 50, 51, 53, 55] - 12).midicps;
		roott = [31, 33, 34, 36, 38, 39, 41, 43].midicps;
		roott2 = [31, 33, 34, 36, 38, 39, 41, 43].midicps;
		roott3 = [31, 33, 34, 36, 38, 39, 41, 43].midicps;
		roott4 = [31, 33, 34, 36, 38, 39, 41, 43].midicps;

		inf.do({
			Synth(\machines,
				[
					\out, 0,
					\rq, 0.0001,
					\mulNoise, 0.5,
					\mul, 10,
					\freqPulse, freqs.choose,
					\root, roott.choose,
					\root2, roott2.choose,
					\root3, roott3.choose,
					\root4, roott4.choose,
					\time, 10,
					//\clip, 0.005 //For possible distortion.
			]);
			([1, 0.6, 0.42].choose).wait
		})
}).play
)

///////////////////////////////////////////////////////////////////////////

//Your dear machines Synth (turned into a routine):
(
SynthDef(
	\overlapMachines,
	{arg out = 0, rq = 0.01, mulNoise = 0.1, mul = 0.1, freqPulse = 80, freqInf = 80, freqSup = 300, combFreq = 20, decayTime = 1.5, masterVolume = 1, transitionTime, sustainTime, density;
		var signal1, signal2, finalSignal, env, amps, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal1 = {Mix(
			BPF.ar(
				Pulse.ar(freqPulse, PinkNoise.ar(mulNoise), 0.2),
				Array.fill(100, {ExpRand(freqInf, freqSup)}),
				rq,
				mul
			)
		)} !2;

		signal2 = CombC.ar(signal1, 1/combFreq, 1/combFreq, decayTime, 0.5);

		finalSignal = (signal1 ring2: signal2) * masterVolume;

		finalSignal.clip2(0.0001);
		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = finalSignal * env;

		Out.ar(out, signalOut)
}).add
)

( //Be aware of the CPU %:
Routine(
	{
		var density, transitionTime, sustainTime, combFreq, rq, detuning;

		density = 3;
		transitionTime = rrand(3.0, 6);
		sustainTime = rrand(4.0, 8);

		combFreq = Prand((15.5, 16..20), inf).asStream;
		//rq = Prand((0.002, 0.0025..0.004), inf).asStream;
		rq = Prand((0.0006, 0.0007..0.002), inf).asStream;

		detuning = Prand((0.9, 1..1.9), inf).asStream;

		inf.do({

			Synth(\overlapMachines,
				[
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\out, 0,
					\rq, rq.next,
					\mulNoise, 0.5,
					\mul, 2,
					\freqPulse, 70 * detuning.next,
					\freqInf, 60,
					\freqSup, 4000,
					\combFreq, combFreq.next,
					\decayTime, 1.5,
					\masterVolume, 2.5
			]);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

/////////////////////////////////////////////////////

//Under the sea routine (from machine synth) --> I STILL NEED TO LOOK DEEPER INTO IT TO UNDERSTAND WHY IT SOUNDS LIKE THAT (but still, woah):
(
SynthDef(
	\machinesComb,
	{ arg transitionTime, sustainTime, density, out = 0, rq = 0.01, mulNoise = 0.1, mul = 0.1, freqPulse = 80, freq, combFreq = 30, decayTime = 1, mulComb = 0.4;
		var ampIndividual, signal, comb, signalOut, env;

		ampIndividual = ((density.log2 + 1) * -3.01).dbamp;

		signal = BPF.ar(
			Pulse.ar(freqPulse, PinkNoise.ar(mulNoise !2), 0.2),
				freq,
				rq,
				mul
			);

		comb = CombC.ar(signal, 1/combFreq, 1/combFreq, decayTime, mulComb);

		signalOut = signal + comb;

		env = EnvGen.ar(
			Env(
			[0, 1, 1, 0] * ampIndividual,
			[ transitionTime, sustainTime, transitionTime ],
			\sine
		),
		doneAction: 2
	);
	Out.ar(out, signalOut * env)
}).add
)

(
Tdef(
	\bajoelmar,
	{
	var density, transitionTime, sustainTime, freqs;

	density = 50;
	transitionTime = rrand(1, 3.5);
	sustainTime = rrand(1, 3.5);

	freqs = Array.fill(100, {exprand(60, 2500)});

	inf.do({
		Synth(\machinesComb,
			[ \freq, freqs.choose,
				\transitionTime, transitionTime,
				\sustainTime, sustainTime,
				\density, density,
				\out, 0,
				\rq, 0.02,
				\mulNoise, 1,
				\mul, 10,
				\freqPulse, 30,
				\combFreq, 40,
				\decayTime, 1.5,
				\mulComb, 0.2
		]);
		((transitionTime + sustainTime + transitionTime) /density).wait
	})
}).play
)

//Tonal version (using the same SynthDef):
(
Tdef(
	\bajoelmar,
	{
		var density, transitionTime, sustainTime, root1, root2, freqs;

		density = 50;
		transitionTime = rrand(1, 3.5);
		sustainTime = rrand(1, 3.5);

		inf.do({

			root1 = [19, 21, 22, 24, 26, 27, 29, 31].midicps.choose;
			root2 = [19, 21, 22, 24, 26, 27, 29, 31].midicps.choose;

			freqs = Array.geom(6, root1, 2)
			++ Array.geom(6, root2, 2);

			Synth(\machinesComb,
				[ \freq, freqs.choose,
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\out, 0,
					\rq, 0.02,
					\mulNoise, 1,
					\mul, 10,
					\freqPulse, 31,
					\combFreq, 38,
					\decayTime, 1.5,
					\mulComb, 0.05
			]);
			((transitionTime + sustainTime + transitionTime) /density).wait
		})
}).play
)

/////////////////////////////////////////////////////////////////

//Interesting routine out of machine synth (BUT CPU PROBLEM !!) --> Maybe Schroeder should be applied into a different Synthdef (it is really dangerous right now):
(
SynthDef(\machines,

	{arg out = 0, rq = 0.01, mulNoise = 0.1, mul = 0.1, freqPulse = 80, freqInf = 80, freqSup = 300, time = 1;
		var signal, env, signalOut, finalSignal, wet, dry, reverb;

		signal = {Mix(
			BPF.ar(
				Pulse.ar(freqPulse, PinkNoise.ar(mulNoise), 0.2),
				Array.fill(100, {ExpRand(freqInf, freqSup)}),
				rq,
				mul
			)
		)} !2;

		env = EnvGen.ar(Env.sine(1, 0.5), doneAction: 0);

		signalOut = signal * env;

		finalSignal = signalOut ring1: BrownNoise.ar(0.7);

		dry = finalSignal; //Colocar aquí cualquier código.

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !4
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		reverb = LPF.ar(wet, 2000);

		DetectSilence.ar(reverb, doneAction: 2);

		Out.ar(out, reverb)
}).add
)

(
Tdef(
	\holaa,
	{ var freqs;

		freqs = Array.series(10, 300, 100);

		inf.do({
			Synth(\machines,
				[
					\out, 0,
					\rq, 0.001,
					\mulNoise, 0.5,
					\mul, 5,
					\freqPulse, freqs.choose,
					\freqInf, 50, //100 (for trying other values).
					\freqSup, 300, //600
					\time, 5
			]);
			([1, 0.6, 0.42].choose).wait
		})
}).play
)
