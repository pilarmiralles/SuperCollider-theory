//9 - DELAY, COMB FILTERS, REVERBERATORS

/////////////////////////////////////////////////////////////////////
//The Delay, Comb, and Allpass family of UGens create time-based effects to give a sense of location and space (that is, reverb, resonance, etc.).
//More on this: https://doc.sccode.org/Tutorials/Mark_Polishook_tutorial/17_Delays_reverbs.html

/////////////////////////////////////////////////////////////////////
//DELAY LINES

//With delay lines, we can create simple echoes with no feedback: a signal equal to the input signal is output after the indicated delay time. DelayN, DelayL and DelayC are some Ugens that create delay lines with different types of interpolation (that is, the way in which they move from one value to another). The last letter of the Delay object indicates the interpolation: N (no interpolation), L (linear interpolation), and C (cubic interpolation). However, this difference is only perceptible in specific situations, for example, when modulating the delay time argument of the Delay object.

DelayN.ar(in, maxdelaytime, delaytime, mul, add) //Arguments of Delay (also in DelayL or DelayC): "in" (input signal to be delayed), "maxdelaytime" (maximum time saved in the memory for delay: it has to be higher - longer - or equal to the next argument, delaytime), "delaytime" (time in between the input signal and delayed signal), "mul" and "add" (as in any other UGen).

//First example: because the delay time is so small, the delayed signal will create a new frequency spectrum when added to the input signal (their phase difference is what alters the waveform). Because the frequency is the inversion of the time period, the frequency of the resultant spectrum will be the inversion of the delay time (around 2000 Hz in here). In this case, the delay is used as sort of a resonator (although comb filters, as we will study later in this document, work better for that):
(
{
	var noise, delay;

	noise = PinkNoise.ar(0.1) !2;
	delay = DelayC.ar(noise, 1/2000, 1/2000); //Half of a milisecond of delay (try different values, but take care of the maxdelaytime: because of the inversion, the lower the denominator, the longer the delay time).

	noise + delay //We need to add both signals in order to create the "resonance". Otherwise, the delay by itself reproduces exactly the same signal as the noise generator.

}.play
)

//In this example, we can actually perceive the differences between the three types of interpolation, as the delay time is moving between differen values, that is, being modulated (similar to a flanger):
(
{
	var noise, delay;

	noise = PinkNoise.ar(0.1) !2;

	//Try out the three options (take into account that XLine is always exponential though). XLine creates an exponential line of 10 seconds between delay time 1/14000 and 1/50 (shorter to longer):
	//delay = DelayC.ar(noise, 1/50, 1/XLine.ar(14000, 50, 10));
	delay = DelayN.ar(noise, 1/50, 1/XLine.ar(14000, 50, 10));
	//delay = DelayL.ar(noise, 1/50, 1/XLine.ar(14000, 50, 10));

	noise + delay

}.play
)

//In the following example, the delay is used as it is most commonly understood, as a perceptible single echo. In this case, it has a delay time of 3 seconds, meaning that the delayed signal will be heard after that time. The SinOsc (input signal) is being modulated in its frequency and amplitude using low frequency noise generators:
(
{
	var signal, delayedSignal;

	signal = SinOsc.ar(
		LFDNoise3.ar(15, 4000, 4010), //Frequency modulation with an LFDNoise.
		0,
		LFDNoise3.ar(1, 0.25).max(0) //Amplitude modulation with an LFDNoise: the modulation goes between 0.25 and -0.25, but .max(0) only allows what's above 0 to go out creating random gaps of silence.
	);

	delayedSignal = DelayC.ar(signal, 3, 3); //Try with delaytime = 1, more noticeable (like birds).

	[signal, delayedSignal] //We need a mono input signal in order to output each signal (input and delayed) through a different channel.
	//signal + delayedSignal //Remember that when adding the signals, they will be mixed in a single channel (we would need a duplicator to have a stereo or mono-duplicated signal).

}.play
)

//A historical piece based on delays is Luigi Nono's "Post-Prae-Ludium" (1987), for tuba and electronics. Throughout its first section, the sound engineer is directed to randomly vary the input and output volume to four delays (of 5, 7, 10 and 15 seconds: there is a prime number between each of those numbers, 2, 3, and 5), one for each speaker of the quadraphonic sound system. This way, the original sound of the tubist and its delays are difficult to differentiate from each other. Some other tools used during the piece are reverb, phasing, filtering and quadraphonic panning.
//Someone actually recreated the piece using SuperCollider: https://ccrma.stanford.edu/~kermit/website/nono.html


/////////////////////////////////////////////////////////////////////
//COMB FILTERS

//Comb filters produce delays with feedback (that is, they feed some of their output back into their input). They are normally used as resonators when, as earlier shown using delay lines, their delay time is so small that it produces its own spectrum. As with Delay, there are several Comb UGens according to the different types of interpolation: CombN, CombL, and CombC.

CombC.ar(in, maxdelaytime, delaytime, decaytime, mul, add) //The arguments are the same as in Delay, although there is a new one, "decaytime", which is the time for which the echoes will be heard.

//Example: in this case, Comb is not working as a resonator due to the low frequency of the filter (that is to say, due to the long delay time):
(
{
	var signal;

	signal = Impulse.ar(1/2) !2; //There is an impulse every two seconds (which, in this case, is equal to the decay time of the filter) and the signal is mono-duplicated.
	CombC.ar(signal, 0.5, 0.5, 2); //There is an "echo" every half a second (delaytime), during 2 seconds (decaytime). The "echoes" lose their stength progressively during the decay time: they decay 60 dB. If the decay time is negative, only the odd harmonics will be emphasizing (at an octave lower, see Help file).

}.play
)

//We can apply the former comb filter and impulse to a buffer with a percussive envelope:

b = Buffer.read(s, "C:/Users/SmallAngel/Desktop/THEORY CODES/Audio-for-granular-examples-2.wav")

(
{
	var trigger, signal, envelope;

	trigger = Impulse.ar(1/2) !2; //Impulse is used as a trigger for the envelope.
	signal = PlayBuf.ar(2, b.bufnum, 1.0, 1, 2.5 * 44100); //The audio file follows its normal duration and pace, but we only hear bits of it released by the envelope.
	envelope = EnvGen.ar(Env.perc(0.01, 0.5), trigger);

	CombC.ar(signal * envelope, 0.5, 0.5, 2) * 0.7;

}.play
)

b.free

//If using the comb filter as a resonator (that is, with a very small delay time), the resonant frequency will be calculated this way (as shown before): freq = 1/delaytime (because delaytime = 1/freq = seconds). The resonated frequency here is 440 Hz:
(
{
	var signal;

	signal = Impulse.ar(0.5) !2; //One impulse every two seconds and mono-duplicated.
	signal = CombC.ar(signal, 1/440, 1/440, 2); //We don't hear echoes anymore, but a new frequency spectrum.
	signal = LeakDC.ar(signal) //As Comb filters tend to create DC bias (or offset), LeakDC is a filter commonly applied to them. LeakDC is a high-pass filter that avoids the DC offset (DC offset is produced when the waveform is shifted or offset from its expected place, which is the center of the graph, 0).

}.play
)

//Another example of a comb filter used as a resonator. This one sounds like a very realistic friction (two balloons against each other?:
(
{
	var signal, resonators, freqs;

	freqs = Array.fill(10, { exprand(100, 200) }); //Array of 10 random frequencies from 100 to 200 Hz.
	signal = Saw.ar(LFDNoise3.ar(10, 30, 70), LFDNoise3.ar(10).max(0)); //A Sawtooth wave with a frequency modulation and an amplitude modulation which is sent out only when above 0 (using .max again).

	resonators = Mix(CombC.ar(signal, 1/freqs, 1/freqs, 0.4, 1/freqs.size)); //.size adapts the compensation of the amplitude according to the number of frequencies in the array of freqs, as this is the amount of comb filters that will be mixed into a single channel.

	LeakDC.ar(resonators) !2 * 0.5 //Here mono-duplicated.

}.play
)

//Here is one last and more complex example of comb filters used as resonators before moving on to reverberators. The Routine creates sounds through a private channel (first SynthDef) which are sent to a comb filter (second SynthDef). LeakDC is applied to the whole Comb filter to avid DC offset. The sound synthesis consists of a Sawtooth wave with panning and a percussive envelope. The comb filter receives ten random frequencies and is therefore mixed in a single channel. Take a look at the use of .clump(2) to adapt the multichannel expansion to the previous panning of the Sawtooth wave:
(
SynthDef(
	\sawtooth,
	{ |out, freq, dur, amp|
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
	{ |in|
		var input, signal;

		input = In.ar(in, 2);

		signal = LeakDC.ar( //LeakDC filter applied directly to the comb filters.
			Mix(
				CombC.ar(
					input * 0.1, //Lowering the amplitude beforehand.
					1/2900, //The maxdelaytime here features the lowest freq value because of the inversion of the time to calculate the frequency in Hz (1/2900 is bigger than 1/3100).
					1/({ LFDNoise3.ar(0.1, 100, 3000) } !10), //New delaytime value each 10 seconds (try other values for the frequency, so that the gliss between resonant freqs is faster or slower) between 2900 and 3100 Hz of resonant freq. This function is duplicated 10 times, bringing about the multichannel expansion. The variation in the resonant freq is rather small (try mul = 500, add = 3000 for a wider range / try mul = 100, add = 800 for a lower resonance: more like little bells). The freq of the raw sawtooth wave can be also changed in the routine below, alongside the duration of the release of the perc envelope and the range of amplitudes.
					-1 //Negative decay time: as mentioned before, only the odd overtones an octave below will resonate (try out the positive and negative value to see which timbre suits you better: it does change the timbre quite a bit.
				).clump(2) //TRICK: The Mix of the comb filters here would kill the Pan2 used above for the sawtooth wave (because it would mix everything into one channel). .clump(2) will divide the union of the 10 comb filters into a single channel provoked by the Mix (a single array) into arrays of two elements within the bigger array. This will bring about a two-channel signal adding odd with odd and even with even, hence keeping the panning above because Mix is receiving an array of arrays (be aware that .clump is applied to the Comb filter, not to Mix, so that Mix receives already the array of arrays, otherwise it wouldn't make any sense).
		));

		Out.ar(0, signal)

}).add
)

//And here the simple routine:
(
r = Routine({

	g = Synth(\resonator, [\in, 4], s, \addToTail); //Sent to the tail of the default group.

	inf.do({

		Synth(\sawtooth, [
			\out, 4, //Try out the sawtooth wave alone by sending the out to 0.
			\freq, exprand(3000, 6000),
			\dur, exprand(0.001, 0.125),
			\amp, exprand(0.05, 0.3)
		],
		s, \addToHead); //Sent to the head of the default group (by default).

		exprand(0.05, 1.0).wait
	})

}).play
)

r.stop
g.free


//One last example: here the Comb filter is not being used as a resonator (back to the discernible echoes):
(
{
	var signal, comb;

	signal = SinOsc.ar(
		EnvGen.ar(
			Env([60, 60, 64, 67, 62, 66, 69] + 12, 0.5, \step).circle //The envelope with a step curve is used to form melodies (remember that the first value needs to be repeated to trick the envelope not to skip it).
		).midicps, //.midicps outside the parenthesis: if the curve was not a \step, the gliss between the pitches would be done between midi numbers, keeping the balance between high and low frequencies.
		0,
		0.1);

	comb = CombC.ar(signal, 0.5, 0.5/3, 4); //Try out different values: delaytime denominator (sort of subdivision of the beats), decaytime, time of the envelope above, etc. The delaytime numerator and maxdelaytime should be equal to the duration of the envelope (the time of the envelope) if wanting to maintain the synchronicity.

	signal + comb

}.play
)


/////////////////////////////////////////////////////////////////////
//REVERBERATORS

//Next we are moving to digital reverb, for whicht there are many options (spectral FFT reverb, Schroeder filters, convolution reverb, etc.). We are going to build a Schroeder filter as an example. Of course there are already built-in reverberators in SC, such as FreeVerb and GVerb (which we will take a look at later), but these are less flexible than a reverberator built by hand (although can be more convinient in many cases).
//The Schroeder filter (coming from Manfred Schroeder, from the Bell Telephone Laboratories) consists of several parallel comb filter (usually with cubic interpolation) passing through a series of allpass filters (usually with no interpolation, as a historical convention) and a LPF in the final mix. An allpass filter involves feedback as well, that is, it feeds some of its output back into its input. Allpass filters change the phase of signals passed through them, creating a similar result as with a Comb filter (and, as always, there is the cubic, linear and no interpolation UGen versions). Allpass filters lose energy faster than a comb filter is comparing both types using the same parameters (their arguments are the same):

//Compare the loss of energy:
{ CombC.ar(Impulse.ar(1/5), 0.1, 0.1, 5) }.play

{ AllpassN.ar(Impulse.ar(1/5), 0.1, 0.1, 5) }.play

//Sound test: radar sound (try out an allpass filter instead of the comb filter to compare):
(
{
	var trigger, env, signal, echoes;

	trigger = Impulse.ar(1/5); //One impulse every 5 seconds (in this case, working as a trigger).
	env = EnvGen.ar(Env.perc(0.01, 0.1), trigger);
	signal = SinOsc.ar * env; //Sine wave with default values.

	//The two possible "reverberators" (their frequency is not high enough to blend with the input as actual reverberation):
	echoes = CombC.ar(signal, 0.1, 0.1, 5)
	//echoes = AllpassN.ar(signal, 0.1, 0.1, 5)

}.play
)

//Here a slight variation of the previous arpeggio code (try out different values for the time of each envelope and the freq of the impulse):
(
{
	var trigger, env, signal, echoes, freq;

	trigger = Impulse.ar(2);
	freq = EnvGen.ar(
			Env([ 60, 60, 64, 67, 62, 66, 69] + 12, 0.5, \step).circle //Synchronized with the trigger of the percussive envelope.
		).midicps;
	env = EnvGen.ar(Env.perc(0.01, 0.09), trigger); //Two notes each second (from the impulse frequency above).

	signal = SinOsc.ar(freq) * env;
	echoes = CombC.ar(signal, 0.1, 0.1, 5, 0.3 !2) //These are 10 echoes per second and 5 seconds of decaytime, hence the frequencies overlap.

}.play
)


//CREATING THE SCHROEDER FILTER:
//This is the strcture of the Schroeder filter:
/* ARCHITECTURE OF THE SCHROEDER FILTER (most basic layout):
Signal in --> Comb filter (comb filters in parallel) --> allpass filter - allpass filter - allpass filter --> LPF (default at 3000 Hz, to balance high frequencies) --> Signal out
           Comb filter      + Mix (addition of                     (allpass filters in series)
           Comb filter        the filters)
           Comb filter
*/

//First step of the implementation in SuperCollider: four comb filters in parallel (so that they act at the same time, they are added into a Mix). The LeakDC filter is essential to control the percentage of CPU usage:
(
{
	var signal, comb;

	signal = Impulse.ar(0.5); //One impulse each 2 seconds (in this case, as input signal).

	//The random values in the arguments of the allpass and comb filters will make the sound slightly different with each impulse, hence more natural:
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

//Second step: creating a series of allpass filters (rather than in parallel, one after another): the way to create the series of allpasses is to reassign the variable "signal" successively. The array in the delaytime brings about multichannel expansion (duplicating the function differently on each channel) and the next allpass will be applied to the former and so forth:
(
{
	var signal;

	signal = Impulse.ar(0.5);

	signal = AllpassN.ar(signal, 0.05, [rrand(0.005, 0.05), rrand(0.005, 0.05)], 1);
	signal = AllpassN.ar(signal, 0.05, [rrand(0.005, 0.05), rrand(0.005, 0.05)], 1);
	signal = AllpassN.ar(signal, 0.05, [rrand(0.005, 0.05), rrand(0.005, 0.05)], 1);
	signal = AllpassN.ar(signal, 0.05, [rrand(0.005, 0.05), rrand(0.005, 0.05)], 1)

}.play
)

//Simplification of the former code using iteration with .do: we need to write down that "signal" is what comes out of the function (last line), because the method .do does not return the result of its function by itself. To increase or decrease the number of filters, just change the number of iterations of .do:
(
{
	var signal;

	signal = Impulse.ar(0.5);

	4.do({ signal = AllpassN.ar(signal, 0.05, { rrand(0.005, 0.05) } !2, 1) });

	signal //Last line = what is returned.

}.play
)

//Implementation of both steps, finally building the Schroeder filter (a Buffer and PlayBuf as input could be used to try out the reverb applied to any sound file). The last step of the implementation consists of mixing the input signal and the filtered signal, to which a LPF is applied. These two signals can be balanced at wish. In this example we can clearly hear the click of Impulse and its resonance:
(
{
	var dry, wet, time;

	time = 1; //"Reverb time" for both filters (whether we get silence or not after this time, depends on its relationship with the impulse frequency).

	dry = Impulse.ar(0.5); //The dry signal (input) could be any audio file sent through a Buffer or any synth funcion sent, for instance, through a private channel from another SynthDef.

	wet = Mix(
		{ CombC.ar(
			dry,
			0.035,
			rrand(0.025, 0.035),
			time,
			rrand(0.25, 0.5)
		)
		} !12 //Try out other values such as 4, 8, 16, etc. (but be aware of the CPU percentage!).
	);

	wet = LeakDC.ar(wet); //Essential to avoid the DC offset.

	4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05) } !2, time) }); //As mentioned before, we can try a different number of allpass filters.

	dry + LPF.ar(wet, 3000) //This is the conventional mix in a Schroeder filter: dry + wet with a LPF of 3000 Hz. Both signals can be otherwise balanced in different ways: for instance, (dry * -6.dbamp) + LPF.ar(wet, 3000) for a weaker presence of the original signal, or not including the dry signal at all (dry * -inf.dbamp or 0.dbamp, for reverb alone).

}.play
)


//These digital filters, however, tend to highlight certain frequencies. To avoid that, we can try different solutions, such as avoiding relationships between numbers that are multiple of each other (which is the relationship between overtone frequencies). Perhaps using prime numbers?:

//Reminder of the prime numbers methods:
(0..12).nthPrime //This method gives back prime numbers in order: the numbers the method is applied to represent the position of the prime number in the infinite series of prime numbers (here, prime numbers from the first one to the 13th within the series).
100.nthPrime //100th prime number within the series of prime numbers, for instance.

1/rrand(100, 400).nthPrime //Random prime numbers between the 100th and the 400th numbers in the series of prime numbers, then inverted in order to use them as the resonance frequencies of the comb filters (the range goes from 547 to 2749 Hz).

//Implementation of the prime numbers into the Schroeder filter in order to avoid highlighting certain freqs (for some reason it sounds much more "harmonic" to me. The resulting timbre depends also on the input signal):
b = Buffer.read(s, "C:/Users/SmallAngel/Desktop/THEORY CODES/Audio-for-granular-examples-2.wav") //Example to try with PlayBuf as input.

(
{
	var dry, wet, time;

	time = 1;

	//dry = Impulse.ar(0.5);
	//dry = PlayBuf.ar(2, b.bufnum, 1.0, 1, 2.5 * 44100) * 0.2;
	dry = Saw.ar(LFDNoise3.ar(10, 100, 350), LFDNoise3.ar(10, 0.3).max(0)) * 0.5; //Testing other kinds of timbres (here rubber sounds from before).

	//Try out these options and others:
	wet = Mix(
		{ CombC.ar(
			dry,
			0.035, //Check out that this is the biggest number possible out of the random delaytime numbers.
			1/rrand(25, 100).nthPrime, //The range of numbers could be changed: try different values.
			//rrand(100, 400).nthPrime /40000, //This option includes numbers that are much smaller (gets closer to the option of no prime numbers).
			//rrand(0.025, 0.035), //Here all numbers as before (not only prime numbers).
			time,
			rrand(0.25, 0.5)
		)
		} !12
	);

	wet = LeakDC.ar(wet);

	4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05) } !2, time) });

	dry + LPF.ar(wet, 3000) //Balance the final mix.
}.play
)

b.free

//Some "retro" example (and retro syntax) from SC2: "analog bubbles":
(
{
	f = LFSaw.kr(0.4, 0, 24, LFSaw.kr([8, 7.23], 0, 3, 80)).midicps; //Glissando function: the second LFSaw modulates the range of freq modulation later on in the SinOsc. The first LFSaw brings about th overall shape of going up and suddenly coming back down. The values are MIDI, then converted.
	//f = LFSaw.kr(0.4, 0, 24, 80).midicps; //Compare with this signal instead of the previous.

	CombN.ar(SinOsc.ar(f, 0, 0.04), 0.2, 0.2, 4) //Echoing sine wave (thanks to the use of a comb filter).

}.play
)


/////////////////////////////////////////////////////////////////////
//PREBUILT REVERB

//We can use FreeVerb and GVerb as deafult reverberators:

FreeVerb.ar(in, mix, room, damp, mul, add) //Arguments: "in" (imput signal), "mix" (percentage of dry / wet using a ratio from 0 to 1), "room" (kind of reverb time, but limited to 0 - 1, otherwise the value is clipped by the UGen, as explained in the help file), "damp" (it cuts a bit the highest freqs, 0 = brighter / 1 = darker). It normally requires to add more amplitude because it absorbes some of the power from the original signal.

GVerb.ar //It receives a mono signal and gives back a two-channel signal (mono-duplicated only, though). It has many arguments so the best option to define it, is using all of them with keyword assignment. Some of them are: the input (mono), the size of the room "in squared meters", the reverb time in seconds, some damping (here for some reason 0 = total damping, 1 = no damping at all), "spread" modulates the size of the room (careful), drylevel is = 1 so both parts (dry and wet) are equal. If the room size is bigger than 300 (which is already a lot), then the arg maxroomsize (last one) has to be modified from its default value. Take care with any argument related with the size of the room: there is still a note in the help file which says: "Changing the roomsize does not work properly! Still trying to look for the bug... (-josh)".
	