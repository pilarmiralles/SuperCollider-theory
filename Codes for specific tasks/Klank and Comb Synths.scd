//KLANK SYNTHS :)
///////////////////////////////////////////////////////////////////////////

//A very deep klank:
(
{
	Klank.ar(
		`[
			Array.fill(10, {exprand (30, 60).midicps}),
			Array.fill(10, {exprand (0.1, 0.7)}),
			Array.fill(10, {exprand (0.03, 0.3) * 20})
				],
		{LPF.ar(Dust.ar(2, 0.3), 900)} !2

	)}.play
)

//ASRM using PinkNoise:
(
{
	Klank.ar(
		`[
			Array.fill(10, {exprand (20, 60).midicps}),
			Array.fill(10, {exprand (0.1, 0.7)}),
			Array.fill(10, {exprand (0.03, 0.3) * 20})
				],

		{PinkNoise.ar * EnvGen.ar(Env.sine(0.1, 0.01), Dust.ar(2, 0.3))} !2

	)}.play
)

//Little bells:
(
{
	{Klank.ar(
		`[
			Array.fill(10, {exprand (70, 100).midicps}),
			Array.fill(10, {exprand (0.01, 0.1)}),
			Array.fill(10, {exprand (0.01, 1) * 20})
				],

		BrownNoise.ar * EnvGen.ar(Env.sine(0.1, 0.01), Dust.ar(10, 0.3))
	)}!2
}.play
)

///////////////////////////////////////////////////////////////////////////////////

//Synthdef and Routine from "There Is a Party in My Mouth..." (based on a Klank filter of fifths) --> Could turn it into a "tonal" routine:
(
SynthDef(
	\overlapKlank,
	{arg out = 0, transitionTime, sustainTime, density, freq = #[0, 0, 0, 0, 0], grow, decaytime, mulNoise;
		var signal, resonator, env, amps, signalOut, finalSignal;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal = Klank.ar(

			`[
				Array.geom(10, 24, grow),
				0.1,
				Array.fill(10, { ExpRand(0.01, 0.1)}) * 50],

			PinkNoise.ar(mulNoise)
		);

		resonator = Mix(
			CombC.ar(signal, 1/freq, 1/freq, decaytime, 1/freq.size)
		);

		signalOut = LeakDC.ar(resonator) !2;

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		finalSignal = signalOut * env;

		Out.ar(out, finalSignal)
}).add
)

(
Routine(
	{
		var density, transitionTime, sustainTime, grows, decays, muls;

		density = 5;
		transitionTime = rrand(1.0, 5);
		sustainTime = rrand(1.0, 5);

		grows = Array.fill(10, { rrand(1.4, 1.6) });
		decays = Array.fill(10, { rrand(0.7, 2) });
		muls = Array.fill(10, { rrand(0.01, 0.025) });

		inf.do({

			Synth(\overlapKlank,
				[
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\freq, { exprand(200, 300) } !5,
					\grow, grows.choose,
					\decaytime, decays.choose,
					\mulNoise, muls.choose,
			]);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

/////////////////////////////////////////////////////////////

//Another little useful code (test other values):
(
{
	var signal;

		signal = FreeVerb.ar(
			Klank.ar(

				`[
					Array.fill(8, { exprand(1000, 1300)}),
					0.4,
					Array.fill(8, { exprand(0.002, 0.02)}) * 20],

				{Pulse.ar(
					100,
					PinkNoise.ar(0.1),
					0.1
				)} !2
			),
			1,
			1
		).clip2(0.2);

		signal = CombC.ar(signal, 1/40, 1/40, 1, 0.05);
}.play
)

///////////////////////////////////////////////////////////////////////////

//Comb filter original code:
(
{ var signal;

	signal = FreeVerb.ar(
		Klank.ar(

		`[
			Array.fill(8, { exprand(30, 2000)}),
			0.4,
			Array.fill(8, { exprand(0.002, 0.02)}) * 20],

		{Pulse.ar(
			80,
			PinkNoise.ar(0.1),
			0.1
		)} !2
		),
		1,
		1
	).clip2(0.2);

	CombC.ar(signal, 1/30, 1/30, 1, 0.1)

}.play
)

//Another example (ventilation machine XD):
(
{ var signal;

	signal = FreeVerb.ar(
		Klank.ar(

		`[
			Array.fill(8, { exprand(80, 1000)}),
			0.4,
			Array.fill(8, { exprand(0.002, 0.02)}) * 20],

		{Pulse.ar(
			80,
			PinkNoise.ar(0.1),
			0.1
		)} !2
		),
		1,
		1
	).clip2(0.2);

	CombC.ar(signal, 1/50, 1/50, 1, 0.1)

}.play
)

//Routine out of it:
(
SynthDef(
	\overlapMachines,
	{arg out = 0, rq = 0.01, mulNoise = 0.1, mulComb = 0.1, freqNoise = 80, freqInf = 30, freqSup = 2000, combFreq = 30, decayTime = 1, masterVolume = 1, transitionTime, sustainTime, density;
		var signal, env, amps, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal = FreeVerb.ar(
			Klank.ar(

				`[
					Array.fill(8, { exprand(freqInf, freqSup)}), //Also between 30 and 500.
					0.4,
					Array.fill(8, { exprand(0.002, 0.02)}) * 20],

				{Pulse.ar(
					freqNoise,
					PinkNoise.ar(mulNoise),
					0.1
				)} !2
			),
			1,
			1
		).clip2(0.2);

		signal = CombC.ar(signal, 1/combFreq, 1/combFreq, decayTime, mulComb); //Also freq = 20.

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = (signal * env) * masterVolume;

		Out.ar(out, signalOut)
}).add
)

(
Routine(
	{
		var density, transitionTime, sustainTime, combFreq, freqInf, freqSup;

		density = 3;
		transitionTime = rrand(4.0, 7);
		sustainTime = rrand(5.0, 8);

		combFreq = Prand((20, 22..30), inf).asStream;

		freqInf = Prand((30, 40..300), inf).asStream;
		freqSup = Prand((600, 700..2500), inf).asStream;

		inf.do({

			Synth(\overlapMachines,
				[
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\out, 0,
					\mulNoise, 0.4,
					\mulComb, 0.4,
					\frecNoise, 80,
					\freqInf, freqInf.next,
					\freqSup, freqSup.next,
					\combFreq, combFreq.next,
					\decayTime, 1.0,
					\masterVolume, 1
			]);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

//////////////////////////////////////////////////////////////////////

//Horror klank:
(
SynthDef(
	\klankHorror,
	{arg out = 0, freq = #[0, 0, 0, 0, 0, 0, 0, 0], clip, transitionTime, sustainTime, density, masterVolume = 1;
		var signal, env, amps, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal = 	FreeVerb.ar(
			Klank.ar(

				`[
					freq,
					0.4,
					Array.fill(8, { ExpRand(0.002, 0.02)}) * 20],

				{Pulse.ar(
					80,
					PinkNoise.ar(0.1),
					0.1
				)} !2
			),
			1,
			1
		).clip2(0.8);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = (signal * env) * masterVolume;

		Out.ar(out, signalOut)
}).add
)

(
Tdef(
	\test,
	{
		var density, transitionTime, sustainTime;

		density = 8; //8 max. in case there is 8 freqs in the freq array below.
		transitionTime = rrand(1.0, 5);
		sustainTime = rrand(1.0, 5);
		inf.do({
			Synth(\klankHorror,
				[   \freq, {exprand(40, 700)} !8,
					\clip, rrand(0.02, 0.2),
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\masterVolume, 0.5
			]);
			((transitionTime + sustainTime + transitionTime) /density).wait
		})
}).play
)

//////////////////////////////////////////

//Klank distort crossfade routine:
(
SynthDef(
	\klank,
	{ arg freqs = #[0, 0, 0, 0, 0, 0, 0, 0], clip, crossTime1, sustTime, crossTime2;
		var signal, env, signalOut;

		signal = FreeVerb.ar(
			Klank.ar(

				`[
					freqs,
					0.1,
					Array.fill(8, { exprand(0.002, 0.02)}) * 20],

				{Pulse.ar(
					80,
					PinkNoise.ar(0.1, 0),
					0.1
				)} !2
			),
			1,
			1
		).clip2(clip);

		env = EnvGen.ar(
			Env(
				[0,1,1,0],
				[crossTime1, sustTime, crossTime2],
				\sine
			),
			doneAction: 2
		);

		signalOut = signal * env;

		Out.ar(0, signalOut)

}).add
)

(
Routine({
	var crossTime1, sustTime, crossTime2, freqmin, freqmax;

	crossTime1 = rrand(0.5, 2);

	inf.do({

	sustTime = rrand(0.5, 3);
	crossTime2 = rrand(0.5, 2);

		Synth(\klank, [
			\freqs, {exprand(100, 4000)} !8,
			\clip, rrand(0.01, 0.1),
			\crossTime1, crossTime1,
			\sustTime, sustTime,
			\crossTime2, crossTime2
		]);

		(crossTime1 + sustTime).wait;

		crossTime1 = crossTime2;
	})

}).play
)

///////////////////////////////////////////////////////////////

//Very distorted klank routine (klank filter):
(
SynthDef(
	\base,
	{ arg freqMidi = 28, out = 4, rq = 0.05, amp = 0.7;
		var signal;

		signal = Mix(
			Resonz.ar(
				GrayNoise.ar,
				Array.geom(4, freqMidi.midicps, 2),
				rq,
				amp)
		)!2;

		Out.ar(out, signal)

}).add;
SynthDef(
	\klank,
	{ arg out = 0, in = 4, freqs = #[0, 0, 0, 0, 0, 0, 0, 0], clip, crossTime1, sustTime, crossTime2, room = 1, mix = 1, amp = 0.1;
		var input, signal, env, signalOut;

		input = In.ar(in, 2);

		signal = FreeVerb.ar(
			Klank.ar(

				`[
					freqs,
					amp,
					Array.fill(8, { exprand(0.02, 0.2)}) * 30],

				{Pulse.ar(
					80,
					PinkNoise.ar(0.1, 0),
					0.1
				)} !2
			),
			mix,
			room
		).clip2(clip);

		env = EnvGen.ar(
			Env(
				[0,1,1,0],
				[crossTime1, sustTime, crossTime2],
				\sine
			),
			doneAction: 2
		);

		signalOut = (signal * env) ring2: input;

		Out.ar(out, signalOut)

}).add
)

(
Routine({
	var crossTime1, sustTime, crossTime2, freqmin, freqmax;

	Synth(\base, [\freqMidi, 24, \out, 4, \rq, 0.01, \amp, 0.5], s, 'addToHead');

	crossTime1 = rrand(3, 6); //Just initial value (then, it is reassigned within the loop).

	inf.do({

	sustTime = rrand(6, 12);
	crossTime2 = rrand(4, 7);

		Synth(\klank, [
			\freqs, {exprand(100, 3000)} !8,
			\clip, rrand(0.01, 0.08),
			\crossTime1, crossTime1,
			\sustTime, sustTime,
			\crossTime2, crossTime2,
			\mix, 1,
			\room, 1.2,
			\amp, 0.03
		],
		s, 'addToTail'
		);

		(crossTime1 + sustTime).wait;

		crossTime1 = crossTime2;
	})

}).play
)
