//9 - DELAY, COMB FILTERS, REVERBERATORS AND IN/OUT SYNTHS
///////////////////////////////////////////////////////////////

//DELAY LINES
//DelayN, DelayL and DelayC create delay lines with different types of interpolation (the way in which the values are connected between them, determined by the final letter of the UGen) --> N = no interpolation / L = linear interpolation / C = cubic interpolation (but this difference is only perceptible when using the UGen in specific ways, for example, when modulating it).
//Arguments of Delay:

Delay.ar(in, maxdelaytime, delaytime, mul, add) //"in" (input signal to which the delay will be applied), "maxdelaytime" (is the maximum time of delay that the memory saves for this use, it has to be higher or equal to the next argument, delaytime), "delaytime" (time that will pass before the input signal is repeated), "mul" and "add" as in any other UGen.

//First example (take into consideration that the delay with such a small delaytime - so the frequency resonates because of the audio rate - is not usually used to filter noise), similar to a flanger: when creating a constant delay repeated each milisecond a new frequency is created due to this new periodicity:

(
{
	var noise, delay;

	noise = PinkNoise.ar(0.1) !2;
	delay = DelayC.ar(noise, 1/2000, 1/2000); //Half of a milisecond of delay (try different values, but take care of the maxdelaytime).

	noise + delay //Different timbre if adding the original noise to its delay.

}.play
)


//This is an example where we can hear the differences brought about by different types of interpolation: the delay is moving between values (it is been modulated). Try the different types of interpolation here:

(
{
	var noise, delay;

	noise = PinkNoise.ar(0.1) !2;
	delay = DelayC.ar(noise, 1/50, 1/XLine.ar(14000, 50, 10)); //Exponential line of 10 seconds, delaytime from 1/14000 to 1/50.
	//delay = DelayN.ar(noise, 1/50, 1/XLine.ar(14000, 50, 10));
	//delay = DelayL.ar(noise, 1/50, 1/XLine.ar(14000, 50, 10));

	noise + delay

}.play
)

//Now we try the more conventional use of the delay, featuring a much longer delay time such as 3 seconds: the modulated SinOsc appears first in one channel and 3 seconds later in the other:

(
{
	var signal, delayedSignal;

	signal = SinOsc.ar(
		LFDNoise3.ar(15, 4000, 4010), //Frequency modulation with an LFDNoise.
		0,
		LFDNoise3.ar(1, 0.25).max(0) //Amplitude modulation with an LFDNoise: the modulation goes between 0.25 and -0.25, but thanks to .max(0), the signal is out only when it is above 0, so those silences are created randomly each second.
	);

	delayedSignal = DelayC.ar(signal, 3, 3); //Try with delaytime = 1, more noticeable (more like birds), though it depends on the creation of silences (.max).

	[signal, delayedSignal] //We need a mono signal in order to separate the signal and the delayed signal into different channels.
	//signal + delayedSignal //Adding the signals, they would go both through one channel (a duplicator would be needed to have a stereo or monoduplicated signal).

}.play
)

//A historical piece based on delays is Luigi Nono's "Postpraeludium", for tuba and electronics (delays of 5, 7, 10 and 15 seconds in the first section: there is a prime number between each of those numbers, 2, 3 and 5). He is also using some reverberation, a phasing to detune a bit, and an LPF to control the high freqs. The input sound of the tubist and the output sound of the delay are controlled so they are not always going in and out equally and constantly (this way, input and delayed signals are confused with each other). There are many other details to notice throughout the rest of the piece, it deserves a good analysis.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//COMB FILTERS
//Comb filters are normally used as resonators when, as earlier shown using delay, the frequency of the filter is so small that it produces its own spectrum: CombN, CombL, CombC, feature the same interpolations types as in Delay.

CombC.ar(in, maxdelaytime, delaytime, decaytime, mul, add) //Same arguments as in Delay, but including the argument "decaytime" (time for which the delays will still be heard).

//Example: in this case, Comb is not working as a resonator due to the low frequency of the filter (that is to say, due to the long delay time).
(
{
	var signal;

	signal = Impulse.ar(1/2) !2; //There is an impulse every two seconds (which, in this case, is equal to the decay time of the filter) and the signal is mono-duplicated.
	CombC.ar(signal, 0.5, 0.5, 2); //There is an "echo" every half a second, during 2 seconds (decaytime). The "echoes" lose their stength progressively as the decay is applied.

}.play
)

//If using the comb filter as a resonator, the resonant frequency will be calculated this way: freq = 1/delaytime (because delaytime = 1/freq = seconds). This sound is similar to the pluck of a guitar. The resonated frequency here is 440 Hz:

(
{
	var signal;

	signal = Impulse.ar(1/2) !2; //One impulse every two seconds and mono-duplicated.
	CombC.ar(signal, 1/440, 1/440, 2); //The delaytime is so fast that it becomes part of the spectrum and not a noticeable echo anymore.

}.play
)

//This is why the filters can be used to create reverberators. Here is our first example: it sounds like a very realistic friction:

({
	var signal, resonators, freqs;

	freqs = Array.fill(10, { exprand(100, 200) }); //Array of 10 random frequencies from 100 to 200 Hz.
	signal = Saw.ar(LFDNoise3.ar(10, 30, 70).poll(5), LFDNoise3.ar(10).max(0)); //A Sawtooth wave with a frequency modulation and an amplitude modulation which is sent out only when above 0 (using .max again).

	resonators = Mix(CombC.ar(signal, 1/freqs, 1/freqs, 0.4, 1/freqs.size)); //.size adapts the compensation of the amplitude according to the number of frequencies in the array of freqs, as this is the amount of comb filters that will be mixed into a single channel.

	LeakDC.ar(resonators) !2 //LeakDC is a filter commonly used when working with comb filters. It is a high pass filter which avoids the DC offset, produced when the signal is too separated from the center (0) in the waveform graph (in Reaper, for example, applying a HPF of 20 Hz to the sound sample is enough to fix this problem).

}.play
)

//Here is a more complex example of how to use the comb filter as a resonator before studying reverberators: the routine creates sounds in private channels and the comb filter takes those frequescies through the out channel. Remember to apply LeakDC to avoid DC offset when using comb filters, for instance.
//The first SynthDef contains a sawtooth wave with panning and percussive envelope (remember to use doneAction = 2 in order to kill the envelopes whenever they are done). The comb filters in the second SynthDef are applied within a Mix because they receive ten random delay frequencies.

(
SynthDef(
	\sawtooth,
	{| out, freq, dur, amp |
		var signal, env;

		signal = Pan2.ar(Saw.ar(freq), Rand(-1, 1)); //Remember to use the UGen version of random operations to keep the variation when creating a new instance of the Synth without compiling the SynthDef again (rrand becomes Rand).

		env = EnvGen.ar(
			Env.perc(0.005, dur, amp),
			doneAction: 2
		);

		Out.ar(out, signal * env)

}).add;
SynthDef(
	\resonator,
	{| in |
		var input, signal;

		input = In.ar(in, 2);

		signal = LeakDC.ar( //LeakDC filter applied directly to the comb filters.
			Mix(
				CombC.ar(
					input * 0.1, //Lowering the amplitude beforehand.
					1/2900, //The maxdelaytime here features the lowest freq value because of the inversion of the time to calculate the frequency in Hz (1/2900 is bigger than 1/3100).
					1/({ LFDNoise3.ar(0.1, 100, 3000) } !10), //New delaytime value each 10 seconds between 2900 and 3100 Hz of resonant freq. This function is duplicated 10 times, bringing about the multichannel expansion.
					-1 //Decaytime =  -1 --> only the odd overtones an octave below will resonate (try out the positive and negative value to see which timbre suits you better).
				).clump(2) //TRICK: The Mix of the comb filters here would kill the Pan2 used above for the sawtooth waves. Clump(2) will divide the union of the 10 comb filters into a single channel provoked by the Mix (a single array) into arrays of two elements within the bigger array. This will bring about a two-channel signal adding odd with odd and even with even, hence keeping the panning above as if the Mix was not there.
		));

		Out.ar(0, signal)

}).add
)

//And here the simple routine:
(
Routine({

	Synth(\resonator, [\in, 4], s, \addToTail); //Sent to the tail of the default group.

	inf.do({

		Synth(\sawtooth, [
			\out, 4,
			\freq, exprand(3000, 6000),
			\dur, exprand(0.001, 0.125),
			\amp, exprand(0.05, 0.3)
		],
		s, \addToHead); //Sent to the head of the default group (by default).

		exprand(0.05, 1.0).wait
	})

}).play
)

//Here is another example: using the envelope within the SinOsc's freq we can create melodies (the first value is repeated because the \step curve will skip it). The Comb filter is NOT used as a resonator in here:
(
{
	var signal, comb;

	signal = SinOsc.ar(
		EnvGen.ar(
			Env([60, 60, 64, 67, 62, 66, 69] + 12, 0.5, \step).circle
		).midicps, //.midicps outside the parenthesis: if the curve was not a \step, the gliss between the pitches would be done between midi numbers, keeping the balance between high and low frequencies.
		0,
		0.1);

	comb = CombC.ar(signal, 0.5, 0.5/3, 4); //Try out different values: delaytime denominator, decaytime, time of the envelope above, etc. The delaytime numerator and maxdelaytime should be equal to the duration of the envelope (the time of the envelope), while the denominator will bring about more or less "echoes".

	signal + comb

}.play
)

///////////////////////////////////////////////////////////////////////////////////////////

//REVERBERATORS
//There are digital reverberators, such as the Schroeder filter, FFT or convolution reverberators (applying the recorded reverberation of a space to a sound by convolution (they usually record a noise or a gliss of a SinOsc touring all the audible spectrum). We are going to build a Schroeder filter whose parameters can be controlled by ourselves in detail. We'll see other reverberators such as FreeVerb and GVerb, but those are already built-in and less flexible (yet convenient in many cases).
//Schroeder filter, coming from Manfred Schroeder, from Bell Telephone Laboratories: it is a combination of comb filters (usually with cubic interpolation) and allpass filters (usually with no interpolation). The allpass filter loses energy faster than the comb filter if comparing both using the same parameters. The difference between the interpolations in each filter is almost inperceptible (but is a historical practice to keep them that way):

//Compare the loss of energy:
{CombC.ar(Impulse.ar(1/5), 0.1, 0.1, 1)}.play

{AllpassN.ar(Impulse.ar(1/5), 0.1, 0.1, 1)}.play

//Now 5 seconds of decaytime (even more perceptible):

{CombC.ar(Impulse.ar(1/5), 0.1, 0.1, 5)}.play

{AllpassN.ar(Impulse.ar(1/5), 0.1, 0.1, 5)}.play

//Sound test: radar spund (try out an allpass filter instead of the comb filter to compare):

(
{
	var trigger, env, signal, echoes;

	trigger = Impulse.ar(1/5); //One impulse every 5 seconds (in this case, working as a trigger).
	env = EnvGen.ar(Env.perc(0.01, 0.09), trigger);
	signal = SinOsc.ar * env; //Sine wave with default values.
	echoes = CombC.ar(signal, 0.1, 0.1, 5) //The frequency is not fast enough in order to blend with the input as a reverberation.
	//echoes = AllpassN.ar(signal, 0.1, 0.1, 5) //Try this line INSTEAD of the previous one.

}.play
)

//Here applying the smaller schoes to the arpeggio code from before. Try out different values for the times of each envelope and the freq of the impulse (trigger):
(
{
	var trigger, env, signal, echoes, freq;

	trigger = Impulse.ar(2);
	freq = EnvGen.ar(
			Env([ 60, 60, 64, 67, 62, 66, 69] + 12, 0.5, \step).circle
		).midicps;
	env = EnvGen.ar(Env.perc(0.01, 0.09), trigger); //Two notes each second (from the impulse frequency above).
	signal = SinOsc.ar(freq) * env;
	echoes = CombC.ar(signal, 0.1, 0.1, 5, 0.3 !2) //These are 10 echoes per second and 5 seconds of decaytime, hence the frequencies overlap.

}.play
)

//CREATING THE SCHROEDER FILTER:
//This is the strcture of the Schroeder filter:
/* ARCHITECTURE OF THE SCHROEDER FILTER (most basic layout):
Signal --> Comb filter (comb filters in parallel) --> all pass filter - all pass filter --> LPF (default at 3000 Hz, to lower the amplitude of higher freqs).
           Comb filter      + Mix (addition of          (all pass filters in series)
           Comb filter        the filters)
           Comb filter
*/

//First step of the implementation in SuperCollider: four comb filters in parallel (so they act at the same time, they are added into a Mix). The LeakDC filter is essential to control the percentage of CPU usage:
(
{
	var signal, comb;

	signal = Impulse.ar(0.5); //One impulse each 2 seconds (in this case, input signal).

	//The random values in the arguments of the allpass and comb filters will make the sound slightly different with each impulse, hence more natural.
	comb = Mix(
		{ CombC.ar(
			signal,
			0.035,
			rrand(0.025, 0.035), //Random values of delaytime (within the limit of maxdelaytime).
			1, //Decay time (time of "reverb").
			rrand(0.25, 0.5) //Random values of amplitude.
		)
		} !4 //Four comb filters combined into a Mix (single channel).
	);

	comb = LeakDC.ar(comb)

}.play
)

//Second step: creating a series of all pass filters (not in parallel as in the comb filter combination): the way of creating the series of allpass is to reassign the variable "signal" successively. The array in the delaytime brings about multichannel expansion (duplicating the function differently in each channel) and the next allpass will be applied to the former and so forth:

(
{
	var signal;

	signal = Impulse.ar(0.5);

	signal = AllpassN.ar(signal, 0.05, [ rrand(0.005, 0.05), rrand(0.005, 0.05)], 1);
	signal = AllpassN.ar(signal, 0.05, [ rrand(0.005, 0.05), rrand(0.005, 0.05)], 1);
	signal = AllpassN.ar(signal, 0.05, [ rrand(0.005, 0.05), rrand(0.005, 0.05)], 1);
	signal = AllpassN.ar(signal, 0.05, [ rrand(0.005, 0.05), rrand(0.005, 0.05)], 1)

}.play
)

//Simplification of the former code using iteration with .do. We need to write down that "signal" is what comes out of the function (last line of the function), because the method .do gives back by default its receiver (here, the number 4). To increase or decrease the number of filters, just change the number of iterations of .do:

(
{
	var signal;

	signal = Impulse.ar(0.5);

	4.do({signal = AllpassN.ar(signal, 0.05, { rrand(0.005, 0.05)} !2, 1)});

	signal //Last line = what goes out of the function.

}.play
)

//Implementation of both filters and final code for a schroeder filter (a Buffer could be used placing the PlayBuf as input, to try the reverb with any sound file). Here we notice the sound of the impulse (a click) and its resonance (due to the mixture stablished at the end of the code, which can be changed):

(
{
	var dry, wet, time;

	time = 1; //Resonance time for both filters (whether we get silence or not after this time, depends on its relationship with the impulse frequency).

	dry = Impulse.ar(0.5); //The dry could be any audio through a Buffer or any synth function we would like to reverberate including the In.ar from a SynthDef sent through a private channel and sent out after applying this reverb.

	wet = Mix(
		{ CombC.ar(
			dry,
			0.035,
			rrand(0.025, 0.035),
			time,
			rrand(0.25, 0.5)
		)
		} !12 //Try out other values such as 4, 8, 16, etc. (but be aware of the CPU percentage).
	);

	wet = LeakDC.ar(wet); //Essential to avoid the DC offset.

	4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) }); //As commented before, other numbers of all pass filters could be used, other than 4.

	dry + LPF.ar(wet, 3000) //This is the conventional mixture in a Schroeder filter: dry + wet with a LPF of 3000 Hz. Other balances can be applied such as (dry * -6.dbamp) + LPF.ar(wet, 3000), or with no LPF, or with no dry (applying dry * -inf.dbamp or 0.dbamp, which is the same).

}.play
)

//These digital filters, nonetheless, tend to highlight certain frequencies. In order to avoid that, we can try different solutions, for example, avoiding the relationships between numbers that are multiple of each other (which is the relationship between overtones). Maybe we could use prime numbers:

//Reminder of the prime numbers methods:

(0..12).nthPrime //This method gives back prime numbers in order: the numbers the method is applied to represent the position of the prime numberss in the infinite series of prime numbers (here, prime numbers from the first one to the 13th within the series).
100.nthPrime //100th prime number of the series of prime numbers.

1/rrand(100, 400).nthPrime //Random prime numbers between the 100th and the 400th numbers in the series of prime numbers, then inverted in order to use them as the resonance frequencies of the comb filters.

//Implementation of the prime numbers into the Schroeder filter in order to avoid highlighting certain freqs (for some reason it sounds much more "harmonic" to me):

(
{
	var dry, wet, time;

	time = 1; //Reverb time.

	//dry = Impulse.ar(0.5); //Implement here any code you want to apply the reverb to.
	dry = Saw.ar(LFDNoise3.ar(10, 250, 350), LFDNoise3.ar(10, 0.3).max(0)); //Testing other kinds of timbres (rubber sounds here).

	//Try all the possible timbres: it depends on what we use as an input, the needs will change:
	wet = Mix(
		{ CombC.ar(
			dry,
			0.035, //Check out that this is the biggest number possible out of the random delaytime numbers.
			1/rrand(25, 100).nthPrime, //The range of numbers could be changed: try different values.
			//rrand(100, 400).nthPrime /40000, //This option includes numbers that are much smaller.
			//rrand(0.025, 0.035), //Here all numbers as before (not only prime numbers).
			time,
			rrand(0.25, 0.5)
		)
		} !12
	);

	wet = LeakDC.ar(wet);

	4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

	dry + LPF.ar(wet, 3000) //Balance the final mix.
}.play
)

//Some "retro" example (and retro syntax) from SC2: "analog bubbles":
(
{
	f = LFSaw.kr(0.4, 0, 24, LFSaw.kr([8, 7.23], 0, 3, 80)).midicps; // glissando function (the gliss is brought about by the shape of the modulating sawtooth wave).

	CombN.ar(SinOsc.ar(f, 0, 0.04), 0.2, 0.2, 4) // echoing sine wave (thanks to the use of a comb filter).

}.play
)

////////////////////////////////////////////////////////////////////////////////////////////////
//PREBUILT REVERB

//We can use FreeVerb and GVerb as deafult reverberators:

FreeVerb.ar(in, mix, room, damp, mul, add) //Arguments: "in" (imput signal), "mix" (percentage of dry / wet using a ratio from 0 to 1), "room" (kind of reverb time, but limited to 0 - 1, otherwise the value is clipped by the UGen, as explained in the help file), "damp" (it cuts a bit the highest freqs, 0 = brighter / 1 = darker). It normally requires to add more amplitude because it absorbes some of the power of the original signal.

GVerb.ar //It receives a mono signal and gives back a two-channel signal. It has many arguments so the best option to define it, is using all of them with keyword assignment. Some of them are: the input (mono), the size of the room "in squared meters", the reverb time in seconds, some damping (here for some reason 0 = total damping, 1 = no damping at all), "spread" modulates the size of the room (careful), drylevel is = 1 so both parts (dry and wet) are equal. If the room size is bigger than 300 (which is already a lot), then the arg maxroomsize (last one) has to be modified from its default value.

//GVerb2, which receives a stereo signal, generating a reverb in each side of the stereo and mixing both signals a bit in each side, was created by Sergio Luque, but is not available yet in SC libraries.
