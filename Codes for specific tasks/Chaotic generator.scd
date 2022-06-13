//Chaotic generators (from ChaosGen, implementations file):
//////////////////////////////////////////////////////////////

/*
Non-linear Dynamic Sound Generators
Lance Putnam 2004
lance@uwalumni.com

This is a set of iterative functions and differential equations that
are known to exhibit chaotic behavior.  Internal calculations are
done with 64-bit words to ensure greater accuracy.

The name of the function is followed by one of N, L, or C.  These
represent the interpolation method used between function iterations.
	N -> None
	L -> Linear
	C -> Cubic

*/

ChaosGen : UGen {
}

// General Quadratic Map
QuadN : ChaosGen {
	const <equation="x1 = a*x0^2 + b*x0 + c";
	*ar { arg freq=22050, a=1, b= -1, c= -0.75, xi=0, mul=1, add=0;
		^this.multiNew('audio', freq, a, b, c, xi).madd(mul, add)
	}
}
QuadL : QuadN {}
QuadC : QuadN {}

// Cusp Map
CuspN : ChaosGen {
	const <equation="x1 = a - b*sqrt(|x0|)";
	*ar { arg freq=22050, a=1, b=1.9, xi=0, mul=1, add=0;
		^this.multiNew('audio', freq, a, b, xi).madd(mul, add)
	}
}
CuspL : CuspN {}

// Gingerbreadman Map
GbmanN : ChaosGen {
	const <equation="x1 = 1 - y0 + |x0|\ny1 = x0";
	*ar { arg freq=22050, xi=1.2, yi=2.1, mul=1, add=0;
		^this.multiNew('audio', freq, xi, yi).madd(mul, add)
	}
}
GbmanL : GbmanN {}

// Henon Map
HenonN : ChaosGen {
	const <equation="x2 = 1 - a*(x1^2) + b*x0";
	*ar { arg freq=22050, a=1.4, b=0.3, x0=0, x1=0, mul=1.0, add=0.0;
		^this.multiNew('audio', freq, a, b, x0, x1).madd(mul, add)
	}
}
HenonL : HenonN {}
HenonC : HenonN {}

// Latoocarfian
LatoocarfianN : ChaosGen {
	const <equation="x1 = sin(b*y0) + c*sin(b*x0)\ny1 = sin(a*x0) + d*sin(a*y0)";
	*ar { arg freq=22050, a=1, b=3, c=0.5, d=0.5, xi=0.5, yi=0.5, mul=1.0, add=0.0;
		^this.multiNew('audio', freq, a, b, c, d, xi, yi).madd(mul, add)
	}
}
LatoocarfianL : LatoocarfianN {}
LatoocarfianC : LatoocarfianN {}

// Linear Congruential
LinCongN : ChaosGen {
	const <equation="x1 = ((a * x0) + c) % m";
	*ar { arg freq=22050, a=1.1, c=0.13, m=1.0, xi=0, mul=1.0, add=0.0;
		^this.multiNew('audio', freq, a, c, m, xi).madd(mul, add)
	}
}
LinCongL : LinCongN {}
LinCongC : LinCongN {}

// Standard Map
StandardN : ChaosGen {
	const <equation="x1 = (x0 + y1) % 2pi\ny1 = (y0 + k*sin(x0)) % 2pi";
	*ar { arg freq=22050, k=1.0, xi=0.5, yi=0, mul=1.0, add=0.0;
		^this.multiNew('audio', freq, k, xi, yi).madd(mul, add)
	}
}
StandardL : StandardN {}

// Feedback Sine with Linear Congruential Phase Indexing
FBSineN : ChaosGen {
	const <equation="x1 = sin(im*y0 + fb*x0)\ny1 = (a*y0 + c) % 2pi";
	*ar { arg freq=22050, im=1, fb=0.1, a=1.1, c=0.5, xi=0.1, yi=0.1, mul=1, add=0;
		^this.multiNew('audio',freq,im,fb,a,c,xi,yi).madd(mul, add)
	}
}
FBSineL : FBSineN {}
FBSineC : FBSineN {}

// ODEs
// 'h' is integration time-step

// Lorenz Attractor
LorenzL : ChaosGen {
	const <equation="x' = s*(y-x)\ny' = x*(r-z)-y\nz' = x*y - b*z";
	*ar { arg freq=22050, s=10, r=28, b=2.667, h=0.05, xi=0.1, yi=0, zi=0, mul=1.0, add=0.0;
		^this.multiNew('audio', freq, s, r, b, h, xi, yi, zi).madd(mul, add)
	}
}


/////////////////////////////////////////////////////////////////////////////////////////////////

//Experimentos con Feedback:

//FBSineC: Arguments: freq (Iteration frequency in Hertz), im (Index multiplier amount), fb	(Feedback amount), a (Phase multiplier amount), c Phase increment amount), xi	(Initial value of x), yi (Initial value of y). THESE EXAMPLES ARE FROM THE HELP FILE:

// default initial params
{ {FBSineC.ar(SampleRate.ir/4) * 0.05} !2 }.play(s);

// increase feedback
{ {FBSineC.ar(SampleRate.ir, 1, Line.kr(0.01, 4, 10), 1, 0.1) * 0.05} !2 }.play(s);

// modulate frequency and index multiplier (maybe this is too much XD)
{ {FBSineC.ar(LFNoise2.kr(1, 1e4, 1e4), LFNoise2.kr(1,16,17), 1, 1.005, 0.7) * 0.05} !2 }.play(s);

// increase phase multiplier
{ {FBSineC.ar(SampleRate.ir, 1, 0, XLine.kr(1, 2, 10), 0.1) * 0.05} !2 }.play(s);

// randomly modulate params (too much again, but useful to see more or less the ranges of the arguments)
(
{ {FBSineC.ar(
    LFNoise2.kr(1, 1e4, 1e4),
    LFNoise2.kr(1, 32, 33),
    LFNoise2.kr(1, 0.5),
    LFNoise2.kr(1, 0.05, 1.05),
    LFNoise2.kr(1, 0.3, 0.3)
) * 0.05} !2 }.play(s);
)

//Otras UGens:
// default params
{ {QuadC.ar(SampleRate.ir/8) * 0.05} !2 }.play(s);

// default initial params
{ {GbmanL.ar(MouseX.kr(20, SampleRate.ir)) * 0.05} !2 }.play(s);

// default initial params
{ HenonC.ar(MouseX.kr(20, SampleRate.ir)) * 0.05 !2}.scope(s);

// default initial params
{ {LatoocarfianC.ar(MouseX.kr(20, SampleRate.ir)) * 0.05} !2 }.play(s);

// default initial params
{ {LinCongC.ar(MouseX.kr(20, SampleRate.ir)) * 0.05} !2 }.play(s);

// randomly modulate params
(
{ {LorenzL.ar(
    SampleRate.ir,
    LFNoise0.kr(1, 2, 10),
    LFNoise0.kr(1, 20, 38),
    LFNoise0.kr(1, 1.5, 2)
) * 0.05} !2 }.play(s);
)

////////////////////////////////////////////////////////////
//MY OWN IMPLEMENTATIONS:

//FreeVerb to feedback code and some slight modulations:
(
{ var signal;

	signal = {
		FBSineC.ar(
			freq: SampleRate.ir/(LFDNoise3.ar(1/5, 1.0, 8)),
			fb: LFDNoise3.ar(1/3, 1.2, 1.75)
		) * 0.2
	} !2;

	FreeVerb.ar(signal, 0.8, 1, 0.6) //Try out without reverb too.

}.play
)

//Schroeder filter (possibly changing parameters):
(
{
	var dry, wet, time, out;

	time = 2.5;

	dry = {
		FBSineC.ar(
			freq: SampleRate.ir/(LFDNoise3.ar(1/5, 1.0, 12)),
			fb: LFDNoise3.ar(1/3, 1.2, 2.2)
		) * 0.2
	} !2;

	wet = Mix(
		{ CombC.ar(
			dry,
			0.035,
			rrand(0.025, 0.035),
			time,
			rrand(0.01, 0.1)
		)
		} !8
	);

	wet = LeakDC.ar(wet);

	4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

	out = (dry * -6.dbamp) + LPF.ar(wet, 3000);

	out * 0.5

}.play
)

//A bit harsher than the former version:
(
{
	var dry, wet, time, out;

	time = 2;

	dry = {
		FBSineC.ar(
			freq: SampleRate.ir/(LFDNoise3.ar(1/7, 1.5, 16)),
			fb: LFDNoise3.ar(1/3, 1.2, 2.3)
		) * 0.2
	} !2;

	wet = Mix(
		{ CombC.ar(
			dry,
			0.035,
			rrand(0.025, 0.035),
			time,
			rrand(0.01, 0.1)
		)
		} !12
	);

	wet = LeakDC.ar(wet);

	4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

	out = (dry * -6.dbamp) + LPF.ar(wet, 3500);

	out *0.5

}.play
)

//Multichannel expansion (it is clipping a bit):
(
{ var signal, freqs;

	freqs = Array.fill(5, {exprand(8, 12)});

	/*signal = FBSineC.ar(
		freq: SampleRate.ir/(LFDNoise3.ar(1/7, 1.0, freqs)),
		fb: LFDNoise3.ar(1/3, 1.2, 1.75)
	) * 0.2; //Así se mueven todas a la vez*/

	signal = {FBSineC.ar(
		freq: SampleRate.ir/(LFDNoise3.ar(1/5, 1.0, exprand(10, 15))),
		fb: LFDNoise3.ar(1/3, 1.2, 1.75)
	) * 0.2} !5;

	signal = { Mix(signal) } !2;

	signal = FreeVerb.ar(signal, 0.8, 1, 0.6);

	signal * 0.2;

}.play
)

/////////////////////////////////////////////////////
//Overlap routine with reverb example:

(
SynthDef(
	\overlap,
	{arg out = 4, freq, transitionTime, sustainTime, density, freqModRange = 1.0, freqModTime = 5, fbModTime = 3, fbModMul = 1.2, fbModAdd = 2.2, fbMul = 0.2, masterVolume = 0.5;
		var signal, env, amps, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal = {
		FBSineC.ar(
			freq: SampleRate.ir/(LFDNoise3.ar(1/freqModTime, freqModRange, freq)),
			fb: LFDNoise3.ar(1/fbModTime, fbModMul, fbModAdd)
		) * fbMul
	} !2;

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
}).add;
SynthDef(
	\reverb,
	{ arg in = 4, time = 2.5, dryDecrease = -6;
		var input, signalOut, dry, wet;

	dry = In.ar(in, 2);

	wet = Mix(
		{ CombC.ar(
			dry,
			0.035,
			rrand(0.025, 0.035),
			time,
			rrand(0.01, 0.1)
		)
		} !8
	);

	wet = LeakDC.ar(wet);

	4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

	signalOut = (dry * dryDecrease.dbamp) + LPF.ar(wet, 3000);

	OffsetOut.ar(0, signalOut)

}).add
)

(
Tdef( //Try out all parameter changes without killing the synth in the server:
	\lalala,
	{
		var density, transitionTime, sustainTime, freqs;

		Synth(\reverb, [ \in, 4, \time, 2.5, \dryDecrease, -6 ], s, \addToTail);

		density = 7;
		transitionTime = rrand(3.0, 6);
		sustainTime = rrand(4.0, 7);

		freqs = Array.fill(20, {rrand(8, 16)});

		inf.do({

			Synth(\overlap,
				[
					\freq, freqs.choose,
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\freqModRange, 1.0,
					\freqModTime, 5,
					\fbModTime, 3,
					\fbModMul, 1.2,
					\fbModAdd,  2.0,
					\fbMul, 0.2,
					\masterVolume, 1

			],
				s, 'addToHead'
			);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

//New values for some parameters:
(
Tdef(
	\pinponlin,
	{
		var density, transitionTime, sustainTime, freqs;

		Synth(\reverb, [ \in, 4, \time, 2, \dryDecrease, -4 ], s, \addToTail);

		density = 7;
		transitionTime = rrand(3.0, 6);
		sustainTime = rrand(4.0, 7);

		freqs = Array.fill(20, {rrand(3, 6)});

		inf.do({

			Synth(\overlap,
				[
					\freq, freqs.choose,
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\freqModRange, 1.0,
					\freqModTime, 5,
					\fbModTime, 3,
					\fbModMul, 1.2,
					\fbModAdd,  2.0,
					\fbMul, 0.2,
					\masterVolume, 1

			],
				s, 'addToHead'
			);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

/////////////////////////////////////////////////////////////
//There is a serious issue with the volume, be careful:

(
{
	var signal1, signal2, modulation1, modulation2, masterVolume = 0.01;

	modulation1 = (
		signal1 = ({
			FBSineC.ar(
				freq: SampleRate.ir/(LFDNoise3.ar(1/5, 1.0, 5)),
				fb: LFDNoise3.ar(1/3, 1.2, 1.75)
			) * 0.1
		} !2)

		ring1:

		signal2 = Pulse.ar(
			LFDNoise3.ar(1/4, 20, 1108),
			PinkNoise.ar(0.3).lag(0.01),
			0.1!2
		)
	);

	modulation2 = modulation1 ring1: PinkNoise.ar(Decay.ar(modulation1, 2.1));

	modulation2 * masterVolume;

}.play
)

//Synthdef con esto:

(
SynthDef(
	\caution,
	{ arg out = 0, freqSine = 5, freqDev = 1.0, speedDev = 5, fbModTime = 3, fbModMul = 1.2, fbModAdd = 1.75, fbMul = 0.2, decay = 2.5, masterVolume = 0.01;
		var signal1, signal2, modulation1, modulation2, signalOut;

		modulation1 = (
			signal1 = ({
				FBSineC.ar(
					freq: SampleRate.ir/(LFDNoise3.ar(1/speedDev, freqDev, freqSine)), //The higher the number of the freqSine, the lower the frequency.
					fb: LFDNoise3.ar(1/fbModTime, fbModMul, fbModAdd)
				) * fbMul
			} !2)

			ring1:

			signal2 = Pulse.ar(
				LFDNoise3.ar(1/4, 20, 1108),
				PinkNoise.ar(0.3).lag(0.01),
				0.1!2
			)
		);

		modulation2 = modulation1 ring1: PinkNoise.ar(Decay.ar(modulation1, decay));

		signalOut = modulation2 * masterVolume;

		Out.ar(out, signalOut)

}).add
)

Synth(\caution, [\out, 0, \freqSine, 1, \freqDev, 0.7, \speedDev, 5, \fbModTime, 3, \fbModMul, 1.2, \fbModAdd, 2.2, \fbMul, 0.2, \decay, 2.5, \masterVolume, 0.01]) //Pretty good.
Synth(\caution, [\out, 0, \freqSine, 2.5, \freqDev, 1.2, \speedDev, 4, \fbModTime, 4, \fbModMul, 1.5, \fbModAdd, 3, \fbMul, 0.2, \decay, 3.0, \masterVolume, 0.01])

//LPF applied and random values for the routine:
(
SynthDef(
	\overlap,
	{arg out = 4, transitionTime, sustainTime, density, freqSine = 5, freqDev = 1.0, speedDev = 5, fbModTime = 3, fbModMul = 1.2, fbModAdd = 1.75, fbMul = 0.2, decay = 2.5, masterVolume = 0.01;
		var signal1, signal2, modulation1, modulation2, env, amps, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		modulation1 = (
			signal1 = ({
				FBSineC.ar(
					freq: SampleRate.ir/(LFDNoise3.ar(1/speedDev, freqDev, freqSine)), //The higher the number of the freqSine, the lower the frequency.
					fb: LFDNoise3.ar(1/fbModTime, fbModMul, fbModAdd)
				) * fbMul
			} !2)

			ring1:

			signal2 = Pulse.ar(
				LFDNoise3.ar(1/4, 20, 1108),
				PinkNoise.ar(0.3).lag(0.01),
				0.1!2
			)
		);

		modulation2 = modulation1 ring1: PinkNoise.ar(Decay.ar(modulation1, decay));

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = (modulation2 * env) * masterVolume;

		Out.ar(out, signalOut)
}).add;
SynthDef(
	\dps,
	{ arg in = 4, mulFilter = 0.5, freqFilter = 1000;
		var input, signalOut;

		input = In.ar(in, 2);

		signalOut = LPF.ar(input, freqFilter, mulFilter);

		OffsetOut.ar(0, signalOut)

}).add
)

(
Tdef(
	\holacaracola,
	{
		var density, transitionTime, sustainTime, freqs, feedback;

		Synth(\dps, [ \in, 4, \mulFilter, 0.5, \freqFilter, 3500 ], s, \addToTail);

		density = 8;
		transitionTime = rrand(3.0, 6);
		sustainTime = rrand(4.0, 7);

		freqs = Array.fill(20, {rrand(4, 14.0)});
		feedback = Array.fill(20, {rrand(1.8, 3.0)});

		inf.do({

			Synth(\overlap,
				[
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\freqSine, freqs.choose,
					\freqDev, 0.5,
					\speedDev, 5,
					\fbModTime, 5,
					\fbModMul, 1.5,
					\fbModAdd, feedback.choose,
					\fbMul, 0.2,
					\decay, 3.5,
					\masterVolume, 0.04

			],
				s, 'addToHead'
			);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

//Some reverb applied and harsher sound seeked:
(
SynthDef(
	\overlap,
	{arg out = 4, transitionTime, sustainTime, density, freqSine = 5, freqDev = 1.0, speedDev = 5, fbModTime = 3, fbModMul = 1.2, fbModAdd = 1.75, fbMul = 0.2, decay = 2.5, masterVolume = 0.01;
		var signal1, signal2, modulation1, modulation2, env, amps, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		modulation1 = (
			signal1 = ({
				FBSineC.ar(
					freq: SampleRate.ir/(LFDNoise3.ar(1/speedDev, freqDev, freqSine)), //The higher the number of the freqSine, the lower the frequency.
					fb: LFDNoise3.ar(1/fbModTime, fbModMul, fbModAdd)
				) * fbMul
			} !2)

			ring1:

			signal2 = Pulse.ar(
				LFDNoise3.ar(1/4, 20, 1108),
				PinkNoise.ar(0.3).lag(0.01),
				0.1!2
			)
		);

		modulation2 = modulation1 ring1: PinkNoise.ar(Decay.ar(modulation1, decay));

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = (modulation2 * env) * masterVolume;

		Out.ar(out, signalOut)
}).add;
SynthDef(
	\dps,
	{ arg in = 4, mulFilter = 0.5, freqFilter = 1000, time = 0.7, mixReverb = 0.5;
		var input, signalOut;

		input = In.ar(in, 2);

		signalOut = LPF.ar(input, freqFilter, mulFilter);

		signalOut = FreeVerb.ar(signalOut, mixReverb, time, 1);

		OffsetOut.ar(0, signalOut)

}).add
)

(
Tdef(
	\holacaracola,
	{
		var density, transitionTime, sustainTime, freqs, feedback;

		Synth(\dps, [ \in, 4, \mulFilter, 0.6, \freqFilter, 4000, \time, 2.5, \mixReverb, 0.8 ], s, \addToTail);

		density = 8;
		transitionTime = rrand(4.0, 6);
		sustainTime = rrand(5.0, 8);

		freqs = Array.fill(20, {rrand(20, 45.0)});
		feedback = Array.fill(20, {rrand(1.8, 3.0)});

		inf.do({

			Synth(\overlap,
				[
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\freqSine, freqs.choose,
					\freqDev, 0.5,
					\speedDev, 5,
					\fbModTime, 5,
					\fbModMul, 1.5,
					\fbModAdd, feedback.choose,
					\fbMul, 0.2,
					\decay, 3.5,
					\masterVolume, 0.04

			],
				s, 'addToHead'
			);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

( //New values for some parameters:
Tdef(
	\holacaracola,
	{
		var density, transitionTime, sustainTime, freqs, feedback;

		Synth(\dps, [ \in, 4, \mulFilter, 0.6, \freqFilter, 4000, \time, 1.5, \mixReverb, 0.6 ], s, \addToTail);

		density = 10;
		transitionTime = rrand(4.0, 6);
		sustainTime = rrand(5.0, 8);

		freqs = Array.fill(20, {rrand(1, 4.0)});
		feedback = Array.fill(20, {rrand(1.8, 3.0)});

		inf.do({

			Synth(\overlap,
				[
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\freqSine, freqs.choose,
					\freqDev, 0.5,
					\speedDev, 5,
					\fbModTime, 5,
					\fbModMul, 1.5,
					\fbModAdd, feedback.choose,
					\fbMul, 0.2,
					\decay, 3.5,
					\masterVolume, 0.04

			],
				s, 'addToHead'
			);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)
