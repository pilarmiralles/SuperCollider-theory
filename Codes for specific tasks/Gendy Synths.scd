//GENDY SYNTHS
/////////////////////////

//The theory I gathered when I started using Gendy3:

//TESTING THE UGEN GENDY3:

//Arguments from the help file:
/*
ampdist
Choice of probability distribution for the next perturbation of the amplitude of a control point.

The distributions are (adapted from the GENDYN program in Formalized Music):

0:	LINEAR.
1:	CAUCHY.
2:	LOGIST.
3:	HYPERBCOS.
4:	ARCSINE.
5:	EXPON.
6:	SINUS.
Where the sinus (Xenakis' name) is in this implementation taken as sampling from a third party oscillator. See example below.

durdist
Choice of distribution for the perturbation of the current inter control point duration.

adparam
A parameter for the shape of the amplitude probability distribution, requires values in the range 0.0001 to 1 (there are safety checks in the code so don't worry too much if you want to modulate!).

ddparam
A parameter for the shape of the duration probability distribution, requires values in the range 0.0001 to 1.

freq
Oscillation frequency.

ampscale
Normally 0.0 to 1.0, multiplier for the distribution's delta value for amplitude. An ampscale of 1.0 allows the full range of -1 to 1 for a change of amplitude.

durscale
Normally 0.0 to 1.0, multiplier for the distribution's delta value for duration. An ampscale of 1.0 allows the full range of -1 to 1 for a change of duration.

initCPs
Initialise the number of control points in the memory. Xenakis specifies 12. There would be this number of control points per cycle of the oscillator, though the oscillator's period will constantly change due to the duration distribution.

knum
Current number of utilised control points, allows modulation.

mul
add
*/

//Examples from the help file -> EXPERIMENT WITH THOSE, APPLY RESONATORS, FILTERS, RING MODULATIONS, ETC. (the way they are written is AWFUL):

//LOUD! defaults like a rougher Gendy1:
{Pan2.ar(Gendy3.ar(mul:0.1))}.play //Mmmm, crispy... Interesting. Pan2 is there just for the stereo.

//stochastic waveform distortion: Mouse control!
{Pan2.ar(Gendy3.ar(1,2,0.3,-0.7, MouseX.kr(55,110,'exponential'), 0.03, 0.1, mul: 0.1))}.play

//Weird filter example:
(
{Pan2.ar(
Normalizer.ar( //This is just a normal normalizer.
RLPF.ar( //Two layers of filter, Idk why.
RLPF.ar(Mix.new(Gendy3.ar(freq:[230, 419, 546, 789])),
MouseX.kr(10,10000,'exponential'),0.05, 0.5), //Gendy freq.
MouseY.kr(10,10000,'exponential'),0.05, 0.5), //Filter freq.
0.8)
,Lag.kr(LFNoise0.kr(1),0.5, 0.1))}.play
)

//concrete pH? -> More like noise.
(
{Pan2.ar(
Mix.new(Gendy3.ar(freq:([1,1.2,1.3,1.76,2.3]*MouseX.kr(3,17,'exponential')),mul:0.1)))}.play
)

//glitch low, mountain high, WTF, very retro. It changes even without moving the mouse:
(
{Pan2.ar(
Mix.new(Gendy3.ar(3,5,1.0,1.0,(Array.fill(5,{LFNoise0.kr(1.3.rand,1,2)})*MouseX.kr(100,378,'exponential')),MouseX.kr(0.01,0.05),MouseY.kr(0.001,0.016),5,mul:0.05)))}.play
)

//play me: this could be a nice sound for a Pbind with pitches XD:
{Pan2.ar(RLPF.ar(Gendy3.ar(1,3,freq:MouseX.kr(100,1000), durscale:0.0, ampscale:MouseY.kr(0.0,0.1), initCPs:7, knum: MouseY.kr(7,2)), 500,0.3, 0.1), 0.0)}.play

//used as an LFO (like a LFDNoise, but more difficult to program XD):
(
{Pan2.ar(SinOsc.ar(Gendy3.kr(2,5,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51), 0.34, SinOsc.kr(0.17,0,0.49,0.51), SinOsc.kr(0.19,0,0.49,0.51),10,10,mul:50, add:350), 0, 0.3), 0.0)}.play
)

//buzzpipes (wow XD):
{Pan2.ar(Mix.new(Gendy3.ar(0, 0, SinOsc.kr(0.1, 0, 0.1, 0.9),1.0, [100,205,410], 0.011,0.005, 12, 12, 0.05)), 0.0)}.play

//modulate distributions (I like the differences between the layers): THIS ONE SOUNDS GOOD:
//change of pitch as distributions change the duration structure and spectrum
{Pan2.ar(Gendy3.ar(MouseX.kr(0,7),MouseY.kr(0,7),mul:0.1), 0.0)}.play

//modulate num of CPs (akin to the latter, but no leaps, more gradual):
{Pan2.ar(Gendy3.ar(knum:MouseX.kr(2,13),mul:0.1), 0.0)}.play

//wolf tones: this is actually kind of nice: SCARY THOUGH...
(
{
Mix.fill(10,{
var freq;

freq= exprand(130,1160.3);
Pan2.ar(SinOsc.ar(Gendy3.ar(6.rand,6.rand,SinOsc.kr(0.1,0,0.49,0.51),SinOsc.kr(0.13,0,0.49,0.51),freq, SinOsc.kr(0.17,0,0.0049,0.0051), SinOsc.kr(0.19,0,0.0049,0.0051), 12, 12, 200, 400), 0, 0.05), 1.0.rand2)
});
}.play
)

/////////////////////////////////////
//MY OWN IMPLEMENTATIONS:

//The original bagpipes code:
(
{
	Pan2.ar(
		Mix(
			Gendy3.ar(
				ampdist: 5,
				durdist: 3.9, //Increasing this number makes the sound a bit rougher (4.5), it definitely changes the timbre (at 1.5 seemed to have a flanger or something like that) / between 3 and 4 seems to have a milder timbre.
				adparam: 1.0, //This can be between 0.0001 and 1.0. Changing it to this value (0.001), the "tremolo" is almost gone.
				ddparam: 1.0, //If it is below 1 (between the former range), it sounds really unstable. Better to leave this one.
				freq: [Array.geom(5, 14.midicps, 12.midiratio) * Array.fill(5, { rrand(0.98, 1.02) }), Array.geom(5, 21.midicps, 12.midiratio) * Array.fill(5, { rrand(0.98, 1.02) }) ].flat, //Slight detuning applied to both freqs banks.
				ampscale: 0.03, //Freq. of the tremolo (0.01 slow - 0.1 fast), original = 0.091.
				durscale: 0.005, //This coming closer to 1 makes the sound more damaged, and around 0.1 creates clear sound (there is not much defference below 0.1 anymore).
				initCPs: 12, //This shouldn't be changed.
				knum: 12, //This should always coincide with the initCPs value (although, according to the help file "it allows modulation").
				mul: Array.geom(10, 0.2, 0.85)) //Applied to each frequency.
		) * 0.7,
		LFDNoise3.ar(1/7, 0.4, 0.0) //Random pan.
	)
}.play
)

//Tender noise (gendy) -> based on E-B (and less detuned):

(
{
	Pan2.ar(
		Mix(
			Gendy3.ar(
				ampdist: 5,
				durdist: 3.9,
				adparam: 1.0,
				ddparam: 1.0,
				freq: [Array.geom(4, 16.midicps, 12.midiratio) * Array.fill(4, { rrand(0.98, 1.02) }), Array.geom(4, 23.midicps, 12.midiratio) * Array.fill(4, { rrand(0.98, 1.02) }) ].flat,
				ampscale: 0.031, //Freq. of the tremolo (0.01 slow - 0.1 fast)
				durscale: 0.005,
				initCPs: 12,
				knum: 12,
				mul: Array.geom(8, 0.2, 0.85)) //Applied to each frequency.
		) * 0.5,
		0.0)
}.play
)

//Gendy routine alternating fifths:
(
SynthDef(
	\overlap,
	{arg out = 0, freq1 = 16, freq2 = 23, mul = 0.3, trem = 0.031, transitionTime, sustainTime, density;
		var signal, env, amps, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp; //Density = 0, amp = inf (need to take care of that, but density shouldn't be 0 anyways).

		signal = Pan2.ar(
			Mix(
				Gendy3.ar(
					ampdist: 5,
					durdist: 3,
					adparam: 1.0,
					ddparam: 1.0,
					freq: [Array.geom(4, freq1.midicps, 12.midiratio) * Array.fill(4, { Rand(0.98, 1.02) }), Array.geom(4, freq2.midicps, 12.midiratio) * Array.fill(4, { Rand(0.98, 1.02) }) ].flat,
					ampscale: trem,
					durscale: 0.005,
					initCPs: 12,
					knum: 12,
					mul: Array.geom(8, 0.2, 0.85)) //Match the number of freqs with the size of this array!
			) * mul,
			0.0);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = signal * env;

		Out.ar(out, signalOut)
}).add
)

(
Routine(
	{
		var density, transitionTime, sustainTime, freqs1 = 16, freqs2 = 23;

		density = 2;
		transitionTime = rrand(2.5, 5);
		sustainTime = rrand(5, 8.5);

		inf.do({

			freqs1 = [16, 20, 22].wchoose([6, 2, 3].normalizeSum);

			freqs2 = case
			{ freqs1 == 16 } { 23 }
			{ freqs1 == 20 } { 27 }
			{ freqs1 == 22 } { 29 };

			[freqs1, freqs2].postln;

			Synth(\overlap,
				[
					\freq1,freqs1,
					\freq2, freqs2,
					\mul, 0.5,
					\trem, 0.031,
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
			]);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

//Another option (newer?) - former one more "damaged":
(
SynthDef(
	\overlapGendy,
	{arg out = 0, mulGendy = 0.2, transitionTime, sustainTime, density, freqGendyMidiLow = 12, freqGendyMidiHigh = 19, masterVolume = 1;
		var amps, signal, env, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal = {
			Mix(
				Gendy3.ar(
					ampdist: 5,
					durdist: 3.5, //A bit unpredictable
					adparam: 1.0, //Between 0.001 and 1.0
					ddparam: 1.0,
					freq:[Array.geom(5, freqGendyMidiLow.midicps, 12.midiratio) * Array.fill(5, { rrand(0.98, 1.02) }), Array.geom(5, freqGendyMidiHigh.midicps, 12.midiratio) * Array.fill(5, { rrand(0.98, 1.02) }) ].flat, //Here the freq and detuning.
					ampscale: 0.021, //Pace of the "tremolo" (0.01 slow - 0.1 fast)
					durscale: 0.005, //Closer to 1.0 = rougher.
					initCPs: 12,
					knum: 12,
					mul: Array.geom(10, mulGendy, 0.85))
			) * 0.3
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
}).add
)

( //You could increase the density + the number of possible notes (although it is okke like this) + vary the sus and trans times.
Routine(
	{
		var density, transitionTime, sustainTime, freqGendyHigh, freqGendyLow; //It is stupid and does not allow me to randomize the fucking freq of the filter.

		density = 2;

		sustainTime = rrand(5.0, 8);
		transitionTime = rrand(3.0, 5);

		inf.do({ arg i;

			if (i == 0, {freqGendyLow = 11}, {freqGendyLow = [11, 13, 14, 16, 18].wchoose([5, 3, 4, 2, 4].normalizeSum)}); //To get B the first always?

			//freqGendyLow = [11, 13, 14, 16, 18].wchoose([5, 3, 4, 2, 4].normalizeSum); //Linear bc it is midi still.
			freqGendyHigh = freqGendyLow + 7; //To get a perfect fifth.

			Synth(\overlapGendy,
				[
					\freqGendyMidiLow, freqGendyLow,
					\freqGendyMidiHigh, freqGendyHigh,
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\mulGendy, 0.3,
					\masterVolume, 1,
					\out, 0
			]);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

/////////////////////////////////////////////

//Creating melodies out of the Gendy code:
(
SynthDef(
	\gendy3,
	{
		arg out = 4, freq = 24, gate = 1, amp = 0.1, crossTime, sustTime; //Default.
		var signal, env, finalSignal, reverb;

		signal = Pan2.ar(
			Mix(
				Gendy3.ar(
					0, 0, SinOsc.kr(0.1, 0, 0.1, 0.9), 1.0,
					Array.geom(5, freq.midicps, 2) * Array.fill(5, { rrand(0.95, 1.05) }), //It's a big detuning here.
					0.011, 0.005, 12, 12, amp)
			),
			0.0);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0],
				[crossTime, sustTime, crossTime],
				\sine
			),
			doneAction: 2
		);

		finalSignal = signal * env;

		Out.ar(out, finalSignal)

	}
).add;
SynthDef(
	\reverb,
	{
		arg in = 4, out = 0, mix = 0.9, room = 3, damp = 1, amp = 1;
		var input, reverb;

		input = In.ar(in, 2);

		reverb = FreeVerb.ar(input, mix, room, damp, amp);

		Out.ar(out, reverb)

}).add
)

(
Routine({
	var sustTime, crossTime, freqs;

	sustTime = Pn(Pstutter(3, Pshuf([1, 1, 2, 2, 4], 1)), inf).asStream; //Idk why I am repeating each element of the Pshuf 3 times, but well, it's kind of the same ratio of values.
	crossTime = 0.7;

	freqs = [24, 26, 27, 29, 31, 32, 34, 36] - 5; //Minor scale.

	Synth(\reverb, [ \in, 4, \mix, 0.9, \room, 3, \damp, 1, \amp, 1 ], s, \addToTail);

	inf.do({ var thisSustTime;

		thisSustTime = sustTime.next;

		Synth(\gendy3,
			[

				\freq, freqs.choose,
				\crossTime, crossTime, //This is kind of the legato we had in the Pbind (unique crossFade time).
				\sustTime, thisSustTime,
				\out, 4,
				\amp, [0.2, 0.2, 0.2, 0.6, 0.4] * 0.5,
				//\amp, 0.3 * 0.8

			],
			s, \addToHead
		);

		(crossTime + thisSustTime).wait;

	})
}).play
)

///////////////////////////////////////////////

//Rough and low one:
(
SynthDef(
	\overlapGendy,
	{arg out = 0, mulGendy = 0.3, transitionTime, sustainTime, density, freqFilter = 100, freqGendyMidi = 22, masterVolume = 1;
		var amps, signal1, combInput, signal2, modulation, finalSignal, env, signalOut;

		amps = ((density.log2 + 1) * -3.01).dbamp;

		signal1 = Gendy3.ar(1, 2, 0.3, -0.7, 60, 0.03, 0.1, mul: 0.2 !2); //Now it is mono-duplicated.

		combInput = {
			Mix(
				Gendy3.ar(
					ampdist: 5,
					durdist: 1.6,
					adparam: 1.0,
					ddparam: 1.0,
					freq: Array.geom(3, freqGendyMidi.midicps, 2) * Array.fill(3, { rrand(0.9, 1.1) }), //Here the freq and detuning.
					ampscale: 0.021, //Pace of the "tremolo" -----> Ramdomize it as well?
					durscale: 0.005,
					initCPs: 12,
					knum: 12,
					mul: Array.geom(3, mulGendy, 0.75))
			) * 0.3
		} !2;

		signal2 = CombC.ar(
			combInput,
			1/16,
			1/16,
			3.0,
			1.2
		);

		modulation = signal1 ring2: signal2;

		finalSignal = LeakDC.ar(modulation);

		env = EnvGen.ar(
			Env(
				[0, 1, 1, 0] * amps,
				[ transitionTime, sustainTime, transitionTime ],
				\sine
			),
			doneAction: 2
		);

		signalOut = (finalSignal * env) * masterVolume;

		Out.ar(out, signalOut)
}).add
)

(
Routine(
	{
		var density, transitionTime, sustainTime, freqGendy; //It is stupid and does not allow me to randomize the fucking freq of the filter (<-- younger Pilar).

		density = 2;

		sustainTime = rrand(7.0, 12);
		transitionTime = rrand(5.0, 8);

		//Freq = Pseq([ Prand((60, 70..150), {rrand(1, 3)}), Prand((400,420..840), {rrand(1, 3)}) ], inf).asStream; //The idea was to choose between 1 and 3 low cut-off freqs for the filter and then alternate with 1 to 3 high cut-off freqs.

		freqGendy = Array.fill(50, {rrand(20, 26)}); //Linear bc it is midi still.


		inf.do({

			Synth(\overlapGendy,
				[
					\freqFilter, {rrand(60, 600)},
					\freqGendyMidi, freqGendy.choose,
					\transitionTime, transitionTime,
					\sustainTime, sustainTime,
					\density, density,
					\mulGendy, 0.3,
					\masterVolume, 1,
					\out, 0
			]);

			((transitionTime + sustainTime + transitionTime) /density).wait

		})
}).play
)

//////////////////////////////////////////////////
//The classic comb machine (with Gendy3):

//Low machine sound (based on E):
(
{
	var signal, comb, finalSignal;

	signal = Pan2.ar(
		Gendy3.ar(1, 2, 0.3, -0.5, 28.midicps, 0.01, 0.1)
	);

	comb = CombC.ar(signal, 1/20, 1/20, 3.5, 0.3);

	finalSignal = signal ring1: comb;

	finalSignal = GVerb.ar(finalSignal, 3, 4, 0.7, 1, 15, 0.5);

	finalSignal * 0.2;

}.play
)
