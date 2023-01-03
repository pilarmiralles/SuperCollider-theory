//Other synths (leftovers from categorization) - Ready to modify and use ^^
///////////////////////////////////////////////////////////////////////////////

//THE organ filter bank code:
//Filtro que mola mazo (acorde mi menor)
(
{
	var freqs;

	freqs = Array.geom(7, 28.midicps, 2)
	        ++
	        Array.geom(7, 31.midicps, 2)
	        ++
	       Array.geom(6, 35.midicps, 2);

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.05,
			1)
	)!2
}.play
)

/////////////////////////////////////////////////

//Radio interferences:
(
{
	var trigger, signal, env, finalSignal, masterVolume = 0.3;

	trigger = Dust.ar(Array.fill(20, {rrand(3, 7)}));

	signal = LFPulse.ar(
		Array.fill(20, {exprand(90, 300)}),
		0,
		LFDNoise0.ar(600, 0.3, 0.5),
		0.1 !2
	);

	env = EnvGen.ar(Env.perc(0.05, 0.05, 0.3), trigger);

	finalSignal = {Mix(signal * env)} !2;

	finalSignal * masterVolume;

}.play
)

//////////////////////////////////////////////////

//Minimal routine (alone) enhanced:
(
SynthDef(
	\lonePitches,
	{   arg freqs = 440, out = 0, rq = 0.0005, masterVolume = 1;
		var amps, signal, env, signalOut;

		amps = LFDNoise3.ar(15, 2, 22); //Subtle tremolo.

		signal = Mix(
			Resonz.ar(
				PinkNoise.ar,
				freqs,
				rq,
				amps)
		)!2;

		env = EnvGen.ar(Env.sine(2, 0.5), doneAction: 2);

		signalOut = (signal * env) * masterVolume;

		Out.ar(out, signalOut)

}).add;
SynthDef(
	\reverb,
	{ arg mix = 0.5, room = 1, mulReverb = 1, out = 0;
		var input, reverb;

		input = In.ar(4, 2);

		reverb = FreeVerb.ar(input, mix, room, 0.7, mulReverb);

		Out.ar(out, reverb)

}).add
)

(
r = Routine ({
	var freqs, rq;

	Synth(\reverb, [\out, 0, \mix, 0.7, \room, 1.2, \mulReverb, 1.5]);

	freqs = Prand([[45, 47, 49, 50, 52, 54, 56, 57]+ 12, [45, 47, 49, 50, 52, 54, 56, 57]+ 24, [45, 47, 49, 50, 52, 54, 56, 57]+ 36].flat, inf).asStream;
	rq = Prand((0.0002, 0.0003..0.0008), inf).asStream;

	inf.do({
		Synth(\lonePitches,
			[
				\freqs, freqs.next.midicps,
				\masterVolume, 3,
				\out, 4,
				\rq, rq.next
			]
		);
		[1, 2, 3].choose.yield
	})
}).play
)

