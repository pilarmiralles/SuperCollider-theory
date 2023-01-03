//"WIDTH MODULATION" SYNTHS:
/////////////////////////////////////

//Original code from "toxic waste", but reverb applied:
(
{
	var signal;

	signal = Pulse.ar(
		LFDNoise3.ar(1/4, 7, 100), //Original freqs mul = 20 and add = 1080 (high freqs). The lower, the smaller the deviation bc of the exponential nature of Hz.
		PinkNoise.ar(0.3).lag(0.01), //My signatured "width modulation".
		0.1!2
	);

	FreeVerb.ar(signal, 0.8, 1, 0.6)

}.play
)

//And the high one always used for pieces:
(
{
	var signal;

	signal = Pulse.ar(
		LFDNoise3.ar(1/4, 20, 1108),
		PinkNoise.ar(0.3).lag(0.01),
		0.1!2
	);

	FreeVerb.ar(signal, 0.8, 1, 0.6)

}.play
)

//Former code, into an overlap routine:
(
SynthDef(
	\overlapWidth1,
	{arg out = 0, transitionTime, sustainTime, density, mulNoise = 10, addNoise = #[0, 0, 0, 0, 0, 0, 0], amp = 0.3;
		var amps, signal, env, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal = Pulse.ar(
			LFDNoise3.ar(1/4, mulNoise, addNoise),
			PinkNoise.ar(amp).lag(0.01),
			0.1!2
		);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = signal * env;

		signalOut = FreeVerb.ar(signalOut, 0.8, 1, 0.6);

		Out.ar(out, signalOut)
}).add
)

(
Routine(
	{
		var density, transitionTime, sustainTime, muls;

		density = 7;
		transitionTime = rrand(1.0, 5);
		sustainTime = rrand(1.0, 5);

		muls = Array.fill(10, { rrand(0.5, 5) });

		inf.do({

			Synth(\overlapWidth1,
				[
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\mulNoise, 200,
					\addNoise, { exprand(2000, 4000) } !7, //Try out different registers.
					\amp, 1.2
			]);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

//"Width modulation", line applied:
(
{
	Pulse.ar(
		LFDNoise3.ar(1/4, 10, 1108),
		PinkNoise.ar(Line.ar(0.03, 50, 30)).lag(0.01), //Possibility of using XLine, so the modulation is more gradual.
		0.05!2
	)
}.play
)

//More original "width modulation":
(
{
	{Mix.ar(Resonz.ar(
		Pulse.ar(
			Array.fill(10, {exprand (50, 500)}),
			PinkNoise.ar(0.1, 0), //Tryout different kinds of noise and different kinds of filter (LPF at freq 500 is good).
			0.1
		),
		200,
		0.5,
		8)
	)} !2
}.play
)

//Another example ("width modulation"):
(
{
	{Mix.ar(
		Pulse.ar(
			Array.fill(5, { exprand (50, 200)}),
			LFDNoise0.ar(900, 0.3, 0.5).lag(0.001),
			0.05
		)
	)} !2
}.play
)

//A latter enhancement of the width code (also within a Schroeder filter, could be nice):
(
{
	var signal;

	signal = Pulse.ar(
		LFDNoise3.ar(1/4, 20, 552),
		PinkNoise.ar(0.3).lag(0.01),
		0.1!2
	);

	signal = signal ring1: PinkNoise.ar(Decay.ar(signal, 3)); //Va molando bastante.

	FreeVerb.ar(signal, 0.8, 1, 0.6)

}.play
)

//Here applying an Schroeder filter to the "width modulation" (could implement the "line" version --> The later peaks are enhanced by the reverb, or create an overlap routine out of this):
(
{
	var dry, wet, time;

	time = 2;

	dry = Pulse.ar(
		LFDNoise3.ar(1/4, 20, 1208), //Little deviation of the frequency (random).
		PinkNoise.ar(2).lag(0.01), //"Width modulation".
		0.1!2
	);

	wet = Mix(
		{ CombC.ar(
			dry,
			0.035,
			rrand(0.025, 0.035),
			//1/rrand(25, 100).nthPrime,
			time,
			rrand(0.25, 0.5)
		)
		} !12
	);

	wet = LeakDC.ar(wet);

	4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

	//(dry * -12.dbamp) + (LPF.ar(wet, 1000) * -6.dbamp)
	(dry * -24.dbamp) + LPF.ar(wet, 1000) //Maybe too little dry.

}.play
)

//////////////////////////////////////////////////////////////////////////////////

//A very interesting and easy "old and damaged, distant frequency":
(
{
	{Mix(
		BPF.ar(
		Pulse.ar(
			Array.geom(5, 48.midicps, 2),
			LFDNoise0.ar(900, 0.3, 0.5).lag(0.001),
			0.1),
			84.midicps,
			1.5,
			0.05)

	)} !2
}.play
)

///////////////////////////////////////////////////////////////////////////////

//A good routine of mixed "width modulations". Needs some adjustments:
(
SynthDef(
	\granularFake,
	{ arg out = 0, density, crossTime, sustTime, which, masterVolume, freqInf1 = 60, freqSup1 = 5000, mulNoise1 = 100, freqInf2 = 100, freqSup2 = 10000, mulNoise2 = 100, mulPulse3 = 100, freqInf4 = 50, freqSup4 = 500, freqFilter4 = 200, rq4 = 0.5;
		var amps, signal, env, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal = Select.ar(
			which,
			[

				{Mix(
					Pulse.ar(
						Array.fill(10, {exprand(freqInf1, freqSup1)}),
						BrownNoise.ar(0.1 !2, 0),
						0.05
					)

					ring1:

					PinkNoise.ar(mulNoise1)
					* 0.05

				)} !2,

				{Mix(
					Pulse.ar(
						Array.fill(10, {exprand(freqInf2, freqSup2)}),
						BrownNoise.ar(0.1 !2, 0),
						0.03
					)

					ring1:

					BrownNoise.ar(mulNoise2)
					* 0.03

				)} !2,

				{Pulse.ar(
					mulPulse3,
					PinkNoise.ar(0.1, 0),
					0.1
				)} !2,

				{Mix.ar(Resonz.ar(
					Pulse.ar(
						Array.fill(5, {exprand (freqInf4, freqSup4)}),
						PinkNoise.ar(0.1, 0),
						0.1
					),
					freqFilter4,
					rq4,
					8)
				)} !2,

		]);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[crossTime, sustTime, crossTime],
				\sine
			),
			doneAction: 2
		);

		signalOut = FreeVerb.ar(signal, 0.5, 1, 0.5) * masterVolume;

		OffsetOut.ar(0, signalOut * env)
}).add
)

(
Routine({
	var crossTime, sustTime, which, frecs, density, freqInf1, freqSup1, mulNoise1, freqInf2, freqSup2, mulNoise2, mulPulse3, freqInf4, freqSup4, freqFilter4, rq4;

	density = 5;
	crossTime = 1;
	sustTime = 2;

	which = [0, 1, 2, 3];

	freqInf1 = Array.fill(20, {exprand(60, 400)});
	freqSup1 = Array.fill(20, {exprand(500, 5000)});
	mulNoise1 = Array.fill(20, {exprand(80, 200)});

	freqInf2 = Array.fill(20, {exprand(80, 600)});
	freqSup2 = Array.fill(20, {exprand(800, 10000)});
	mulNoise2 = Array.fill(20, {exprand(80, 200)});

	mulPulse3 = Array.fill(20, {exprand(70, 250)});

	freqInf4 = Array.fill(20, {exprand(50, 800)});
	freqSup4 = Array.fill(20, {exprand(900, 5000)});
	freqFilter4 = Array.fill(20, {exprand(90, 500)});
	rq4 = Array.fill(20, {exprand(0.4, 0.6)});

	inf.do({

		crossTime = rrand(0.5, 1.5);
		sustTime = rrand(0.2, 1.5);

		Synth(\granularFake,
			[
				\crossTime, crossTime,
				\sustTime, sustTime,
				\which, which.choose,
				\density, density,
				\masterVolume, 0.8,
				\freqInf1, freqInf1.choose,
				\freqSup1, freqSup1.choose,
				\mulNoise1, mulNoise1.choose,
				\freqInf2, freqInf2.choose,
				\freqSup2, freqSup2.choose,
				\mulNoise2, mulNoise2.choose,
				\mulPulse3, mulPulse3.choose,
				\freqInf4, freqInf4.choose,
				\freqSup4, freqSup4.choose,
				\freqFilter4, freqFilter4.choose,
				\rq4, rq4.choose,

		]);

		((crossTime + sustTime + crossTime) /density).wait

	})
}).play
)

/////////////////////////////////////////////////////////////////

//Another routine: BUT GREAT PROBLEMS WITH CPU %! --> (again, maybe the Schroeder filter should be applied through another SynthDef "add to tail"):
(
SynthDef(
	\overlapWidth,
	{arg out = 0, transitionTime, sustainTime, density, freq = #[0, 0, 0, 0, 0, 0, 0], mulNoise, reverbTime, mulPulse;
		var dry, wet, time, env, amps, signalOut, finalSignal;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		time = reverbTime;

		dry = Pulse.ar(
			LFDNoise3.ar(1/4, 20, freq), //Pequeña modulación de la frecuencia.
			PinkNoise.ar(mulNoise).lag(0.01), //Modulación del width.
			mulPulse!2
		);

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				//1/rrand(25, 100).nthPrime,
				time,
				rrand(0.25, 0.5)
			)
			} !8
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		signalOut = (dry * -24.dbamp) + LPF.ar(wet, 1000);

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
		var density, transitionTime, sustainTime, muls;

		density = 10;
		transitionTime = rrand(1.0, 5);
		sustainTime = rrand(1.0, 5);

		muls = Array.fill(10, { rrand(0.5, 5) });

		inf.do({

			Synth(\overlapWidth,
				[
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\freq, { exprand(1500, 3000) } !7,
					\mulNoise, muls.choose,
					\reverbTime, 3,
					\mulPulse, 0.2
			]);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)
