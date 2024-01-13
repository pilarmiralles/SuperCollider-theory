//4 - MULTICHANNEL EXPANSION, FILTER BANKS, KLANK

////////////////////////////////////////////////
//MULTICHANNEL EXPANSION

//In SuperCollider, multiple channels of audio are represented as Arrays. Each channel of the array of output channels will go out through a different loudspeaker and, therefore, the limit of output channels is limited by what our audio interface supports. A single signal will be played by default through channel 0 (left), whereas an array of two signals will be played through channels 0 and 1 (left and right, stereo). A stereo signal, for instance, is therefore an array of two elements (two signals).
//Busses (or buses) are the virtual placeholders of signals in SC, similar to the sends of analog mixing desks (we could define them as an abstract representation of channels, which are better understood as physical channels in a sound card, for instance). Their purpose is to rout signals from one place to another. There are control rate busses and audio rate busses. By default, there are 1024 audio rate busses and 16384 control rate busses. Of those audio rate busses, by defualt there are 2 input (indexes 0-1) and 2 output (indexes 2-3) channels reserved for hardware inputs and outputs:

s.meter //Visualization of the default in-out hardware channels.

//The rest of the audio rate busses, indexes 4 and onwards, are called "private busses" (or channels) and can be used for internal routing of signals (for instance, for effects send) and will result in no sound. The number of control and audio rate busses available, and the number of default hardware input and output channels, is set at the time the server app is booted. These numbers can be changed by using the following methods and rebooting the server (they can also be implemented as default options if placed in the startup file). After applying these changes, s.meter will show the new number of hardware in-out channels:
Server.local.numInputBusChannels_(32); //For 32 input channels, for example.
Server.local.numOutputBusChannels_(64); //For 64 output channles.

//More on busses here: https://doc.sccode.org/Tutorials/Getting-Started/11-Busses.html. We'll come back to this topic when studying SynthDefs.
//More on default settings of the server app: https://doc.sccode.org/Classes/ServerOptions.html

s.scope //Applied to the server, it shows running signals at the active channels. Applied to a UGen function (a signal), it also acts as .play:

{ SinOsc.ar(440, 0, 0.1) }.scope //Coming out through the left channel (index 0).
{ SinOsc.ar(440, 0, 0.1 !2) }.scope //Coming out through the left and right channels (indexes 0-1).
{ SinOsc.ar(440, 0, 0.1) }.scope(outbus: 10) //Now the signal is in the output bus 10 (we cannot hear it, because bus 10 is already a private bus, unless this setting has been changed).

//In SC, all UGens have only a single output to facilitate the array operations when manipulating multi-channel structures. We can trick this by sending an array of values as an input to a UGen, causing an array of multiple copies of that UGen holding the different values from the input array (for instance, sending an array of frequencies to the frequency argument of an SinOsc). This phenomenon is called multichannel expansion. According to the help file: “when a UGen is called with an array of inputs, it returns an array of instances”.

//Let's see how this works in practice:
//Array of two signals with different frequency (the are summed up in a single channel):
(
{
	[
		SinOsc.ar(440, 0, 0.1), //Two signals with slightly  different frequency (producing one beat per second, as they are 1 Hz off).
		SinOsc.ar(441, 0, 0.1)
	]
}.scope
)

{ SinOsc.ar([440, 441], 0, 0.1) }.play //Equivalent code: an array of two elements as input of a signal creates as many instances of that signal as elements present in the array. The rest of the arguments are shared by all signals.

//Multichannel expansion can be multilayered: if the generated array is the input of another UGen, another array is created. For instance, if a sawtooth wave receives an array of two frequencies, and array of two sawtooth waves will be created and, if this array of sawtooth waves is placed as input of a lowpass filter, and array of two lowpass filters will be created. Both filters will share a single instance of any other UGen (or value) received as input that is not expanded. If a UGen receives more than one array as input, the longest array will determine the number of instances of the UGen that are created.

//The object Mix:
//The object Mix (Mix.new, although the method .new can be omitted in most of the UGens that can respond to it: .new creates a new instance of the class) reduces multichannel arrays to a single channel. Assuming that a, b and c are our signals:
Mix([a, b, c]) //Is equal to:
[a, b, c].sum //or to:
a + b + c
//Using Mix reduces the performing time of the addition, so that it is more efficient than the equivalent formules.

//Example:
(
{
	Mix(
		SinOsc.ar(
			Array.fill(100, { exprand(30, 8000) }), //An array of 100 frequencies will bring about 100 sine oscillators. The method exprand is a better option than rrand when working with freq in Hz due to its exponential distribution. Otherwise, the high spectrum would be too present, as it linearly occupies a larger span of frequency values.
			0,
			1/500 //Balancing the amplitude: total amplitude of 0.2.
		)
	)
}.play
)

{ Mix(SinOsc.ar({ exprand(30, 8000) } !100, 0, 1/500)) }.scope //Equivalent function using the duplicator.

//Array do not cause Mix to create copies of itself. If Mix receives an array of arrays, it will only reduce one layer of arrays (for instance, if receiving an array containing an array of sine waves and an array of sawtooth waves, it will mix the sine waves in one channel and the sawtooth waves in another channel: in each array, signals will mix in each available output channel). This is the layering limit, as Mix cannot be used on arrays of arrays of arrays. In conclusion, Mix only clears one level of arrays:
(
{
	Mix(
		[
			[BrownNoise.ar(0.05), SinOsc.ar(880, 0, 0.05)],
			[Dust.ar(50, 0.1), Saw.ar(LFDNoise3.ar(1, 3000, 4000), 0.05)],
		]
	) //Take care of the sum of amplitudes. Otherwise, you can also control the general amplitude by multiplying Mix by a master volume factor.
}.scope
)


//Deconstructing multichannel expansion (useful practice to understand how signals are expanded and distributed among channels). Let's see how we would "deconstruct" the following line:
{ RLPF.ar(Saw.ar([100, 250], 0.05), LFDNoise3.ar(1, 1000, 1030), 0.005) }.play //A resonant low-pass filter is filtering a Saw oscillator and its cutoff frequency is being modulated by a LFDNoise3.

//Equivalent to the previous line:
(
{ var noise;

	noise = LFDNoise3.ar(1, 1000, 1030); //Same noise shared by both signals, same randomness.

	//An array of two frequencies brings about two instances of the Saw oscillator, bringing about at the same time two instances of the RLPF:
	[
		RLPF.ar(Saw.ar(100, 0.05), noise, 0.005),
		RLPF.ar(Saw.ar(250, 0.05), noise, 0.005)
	]
}.play
)

//Different noise, different randomness: this is what happens if the modulating signal involving randomness is not shared by both signals by placing it into a variable (not equivalent to the first example):
(
{
	[
		RLPF.ar(Saw.ar(100, 0.05), LFDNoise3.ar(1, 1000, 1030), 0.005),
		RLPF.ar(Saw.ar(250, 0.05), LFDNoise3.ar(1, 1000, 1030), 0.005)
	]
}.play
)

//Another example: as mentioned before, when more than one argument receives an array of values, the longest array indicates the number of instances. The values of shorter arrays will loop:
{ Pulse.ar([400, 500, 600], [0.5, 0.1], 0.1) }.play

//Equivalent to the previous line:
(
{
	[
		Pulse.ar(400, 0.5, 0.1),
		Pulse.ar(500, 0.1, 0.1),
		Pulse.ar(600, 0.5, 0.1)
	]
}.play
)


//Stereo using Mix:
//As the output of Mix is a single channel signal, there are several options to get some stereo sound out of it.

//Using Pan2: Mix will produce a mono signal and, therefore, can be used as input of Pan2:
(
{
	Pan2.ar(
		Mix(SinOsc.ar({ exprand(30, 8000) } !100, 0, 1/500)),
		SinOsc.ar(1/2, 0, 1) //Low freq modulation for the position argument.
	)
}.play
)

//Using the duplicator:
{ Mix(SinOsc.ar({ exprand(30, 8000) } !100, 0, 1/500)) !2 }.play //Mono-duplicated (same frequencies on both sides).
{ { Mix(SinOsc.ar({ exprand(30, 8000) } !100, 0, 1/500)) } !2 }.play //Duplicated function (different frequencies on each side, richer sound).
{ { Mix(SinOsc.ar({ exprand(30, 8000) } !100, 0, 1/500)) }.dup(2) }.play //As already seen, .dup(2) fulfills the same function as !2.

//Using Splay:
//Splay allows the distribution of a mono signal in the stereo field (instead of 100 different freqs on each side, as with !2, the 100 freqs will be distributed among both sides of the stereo):
{ Splay.ar(SinOsc.ar({ exprand(30, 8000) } !100, 0, 1/500), 1, 2.5) }.play //The second argument is "spread" (when = 0, all signals go to the center, when = 1, they distribute among the -1 to 1 stereo field, and everything in between); and the third argument is "level" (for amplitude compensation).


//Other examples of multichannel expansion:
//Comparing these two codes (see another example of this issue at the very end of this document):
(
{
	Mix.ar(
		Array.fill(18, { Ringz.ar(WhiteNoise.ar(0.0001), exprand(100, 3000)) }) //There will be 18 different white noises, as the Array.fill includes the entire filter function into it (if put into a variable, equivalent to next code).
	) !2
}.play
)

(
{
	Mix.ar(
		Ringz.ar(
			WhiteNoise.ar(0.0001), //A unique noise is shared among the 18 filters (the Array.fill affects only the function for the random choice of frequencies within the filter).
			Array.fill(18, { exprand(100, 3000) })
		)
	) !2
}.play
)

//Deconstruction of Mix:
( //Given code presenting arrays in several arguments:
{ var freqDeviation;

	freqDeviation = LFNoise2.ar(0.05, 0.2, 1); //A very slow frequency deviation (over 20 seconds).

	Mix(
		BPF.ar(
			BrownNoise.ar,
			f = Array.geom(5, 440, 3/2) * freqDeviation, //Array of five frequencies (with a fifth of separation between each) multiplied by the freq deviation.
			0.05/f, //The higher the frequency, the smaller the RQ value (the "cleaner" the sound.
			[24, 30].dbamp //Array of two amplitude values in db.
		)
	)
}.play
)

( //Equivalent code showing the multichannel expansion:
{ var freqDeviation, noise, amps, freqs;

	freqDeviation = LFNoise2.ar(0.05, 0.2, 1);

	noise = BrownNoise.ar; //The noise is shared by all signals.
	freqs = Array.geom(5, 440, 3/2) * freqDeviation; //Longest array determines number of instances.
	amps = [24, 30].dbamp; //Smaller array loops.

	//Obtaining each value through the indexes of each array (this way, no need to extract the freq values from Array.geom):
	Mix.ar(
		[
			BPF.ar(noise, freqs[0], 0.05/freqs[0], amps[0]),
			BPF.ar(noise, freqs[1], 0.05/freqs[1], amps[1]),
			BPF.ar(noise, freqs[2], 0.05/freqs[2], amps[0]),
			BPF.ar(noise, freqs[3], 0.05/freqs[3], amps[1]),
			BPF.ar(noise, freqs[4], 0.05/freqs[4], amps[0])
		]
	)
}.play
)


////////////////////////////////////////////////
//FILTER BANKS

//One application of multichannel expansion that I like is the creation of filter banks. This consists of stacking a series of filters at specific intervalic distance (based on overtone ratios or equal intervalic raios). Array.geom is the best way to attain this: the fundamental frequency will be set at the "start" argument, whereas the "grow" argument will determine the intervalic ratio:

//Some examples:
(
{
	Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(16, 30, 3/2), //Pitagoric fifths (or natural fifths), ascending from the given fundamental frequency (30 Hz). When the ratio is bigger than 1 (given ratio, 3/2), the series will go upward as the freq values get bigger; when the ratio is smaller then 1 (reciprocal of the given ratio, 2/3), the series will go downward as the freq values get smaller (beware the starting freq for this). Remember that reciprocal of "x" = 1/x; here 1/(3/2) = (1*2)/3 = 2/3.
			0.001,
			5
		)
	) !2
}.play
)

(
{
	Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(16, 30, 7.midiratio), //Tempered fifths (equal temperament), using n.midiratio (being "n" the number of semitones of the desired interval). Compare with the previous code (here, less bright).
			0.001,
			5
		)
	) !2
}.play
)

(
{
	Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(8, 30, 2), //Octaves (it is advisable to always check the highest frequency given by the array according to its size, start and grow arguments in order not to exceed the audible spectrum).
			0.001, //Try out other RQ values to obtain a "cleaner" or "dertier" sound (remember, the smaller the RQ, the cleaner the filter).
			3
		)
	) !2
}.play
)


//##############################################################
//Little reminder of overtone ratios for each (approximate) interval. Examples for ascending series and some comments comparing to the equal temperament intervals:
/*
unison - 1
min 2nd - 17/16 (still too open compared to 1.midiratio).
maj 2nd - 9/8 (still too open compared to 2.midiratio, but 10/9 is already too little).
min 3rd - 6/5 (same problem...)
maj 3rd - 5/4 (same problem...)
P 4th - 4/3
tritone - 7/5 (not even close to a tritone, not really present in the overtone series).
P 5th - 3/2
min 6th - 8/5 (same problem...)
maj 6th - 5/3 (same problem...)
min 7th - 7/4 (uffffff)
maj 7th - 17/9 (surprisingle close!)
octave - 2
*/
//##############################################################


//Other examples of filter banks:
(
{ var freqs;

	//Concatenation of two arrays (all values put into a single array):
	freqs = Array.geom(8, 30, 2) //Octaves.
	++
	Array.geom(16, 30, 1.5); //Fifths (3/2 = 1.5).

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.005,
			2
		)
	) !2
}.play
)

(
{ var freqs, amps;

	freqs = Array.geom(10, 30, 2)
	*
	Array.fill(10, { |i| ((i + 1 / 10) * 0.5).midiratio }); //Frequency deviation for each freq value: from 0.05.midiratio (applied to the fundamental freq) up to 0.5.midiratio of deviation (applied to the last frequency), which is equal to from almost unisone, to a quarter tone (this way of writing the algorithm, with a factor, allows us to change the level of deviation: change the * 0.5 (to * 0.1 or * 1, for instance) to test different deviation levels). Each deviation interval is multiplied by each frequency in the previous Array.geom, which is producing octaves.

	amps = Array.geom(10, 2, 0.96); //Amplitude deviation (the higher the frequency, the smaller the amplitude, as the series goes upwards).

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.001,
			amps
		)
	) !2
}.play
)

(
{ var freqs;

	freqs = 35 * Array.series(12, 0, 1).integrate.midiratio; //A series of 12 intervals is created here by applying the method .integrate (see below) to a series of integers and then converting the resulting series into intervalic ratios with .midiratio. Finally, each frequency is obtained by multiplying each ratio by the fundamental frequency. The result is a series of all intervals in order (from minor 2nd to major 7th).

	//freqs = (25 + Array.series(12, 0, 1).integrate).midicps; //Another option is to use MIDI values instead (as anyway we are working with equal temperament ratios). In this case, we don't need to convert the incremental (integrate) series to ratios, it can be added to the fundamental in MIDI to adjust the starting point, and then converted to Hz with .midicps. The result is close enough

    Mix(
        BPF.ar(
            PinkNoise.ar,
            freqs,
            0.01,
            1)
    )!2
}.play
)

//This is how the method .integrate works:
[0, 1, 2, 3, 4].integrate; //It returns a collection with the incremental sums of all elements = [0, 0+1, 0+1+2, 0+1+2+3, 0+1+2+3+4] = [0, 1, 3, 6, 10]

(
{ var freqs;

	freqs = Array.fill(16, { arg i; (i + 1 * 50)}); //Using the index argument to calculate the number of each overtone (i + 1 to avoid starting from 0) and then multiplying by a fundamental frequency, thus creating an overtone series of the 16 first overtones (fundamental freq * n = overtone freq, being n the number of the overtone. Overtone 1 = fundamental freq).

	//freqs = 50 * Array.series (16, 1, 1); //Same series, different syntax (avoiding the use of the index argument).

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.01,
			2)
	)!2
}.play
)


//##############################################################
//Quick reminder about conversions between MIDI and Hz values:

//.midicps inside the LFDNoise (converting to Hz before the random distribution is applied) --> Uniform distribution of exponential values, higher frequencies more likely, narrower range:
(
{
	Mix(
		SinOsc.ar(
			Array.fill(5, { LFDNoise0.ar(1, 9.midicps, 69.midicps)}),
			0,
			1/20) //For mul = 0.25.
) !2}.play
)

//.midicps outside the LFDNoise (converting to Hz after the random distribution is applied) --> Uniform distribution of linear values, broader range, all frequencies equally likely:
(
{
	Mix(
		SinOsc.ar(
			Array.fill(5, { LFDNoise0.ar(1, 9, 69).midicps}),
			0,
			1/20)
) !2}.play
)
//##############################################################


////////////////////////////////////////////////
//KLANK FILTER

//Klank is a bank of fixed frequency resonators (that is to say, a bank of Ringz filters). Let's explain its main arguments:
//specificationsArrayRef (see Help file "Multichannel expansion" --> "Protecting arrays against expansion"): the little inverted comma before the array prevents this argument from being interpreted as an array of arrays, and thus avoiding its expansion. In this array we define and array of frequencies, an array of amplitudes, and an array of decay times:
`[
	Array of freqs,
	Array of amps,
	Array of decay times
]
//As always, if one of the arrays features less elements than the others, its values will loop to cover the additional ones in the longest array. Writing a single value in any of the arrays will lead to the application of that value to all values in the other arrays.
//input: it can be any kind of signal, but it is usually some kind of signal you would filter with a Ringz (such as an Impulse, Dust, or any noise generator).
//freqscale: scale factor to be multiplied by all frequencies (as they are fixed (cannot be modulated), they can be "transposed" using this argument).
//The rest of the arguments are rarely used (see help file of Klank).

//Just for reference, this is a single Ringz filter applied to an Impulse (compare to the second and third upcoming examples):
{Ringz.ar(Impulse.ar(0.5), 1000, 1, 0.1)}.play //1000 Hz of frequency and 1 second of decay time.

//Examples of Klank:
(
{
	Klank.ar(
		`[
			//Array.fill(8, { exprand(150, 14000) }), //Random freqs.
			Array.geom(8, 80, 3/2), //Stack of fifths.
			1, //A simgle amplitude value is applied to all frequencies.
			Array.fill(8, { exprand(0.02, 0.2) }) * 32 //The factor value is just lengthening the ringing times.
		],
		{ PinkNoise.ar(0.005) } !2 * 0.5, //Applied to a PinkNoise.
	)
}.play
)

(
{
	Klank.ar(
		`[
			[178, 570, 7384, 605, 356, 1150, 14768, 1210],
			1,
			[0.002, 0.012, 0.018, 0.013] //Smaller array loops.
		],
		{ Dust.ar(3, 0.1) } !2 //Applied to a Dust (quite realistic tapping).
	)
}.play
)

(
{
	Klank.ar(
		`[
			[178, 570, 7384, 605, 356, 1150, 14768, 1210],
			1,
			[0.002, 0.012, 0.018, 0.013] * 16 //Ading some greater decay (now it seems that we are tapping some sort of glass).
		],
		{ Dust.ar(3, 0.1) } !2
	)
}.play
)


//##############################################################
//An additional case study involving multichannel expansion:

//The following two codes are equivalent. There is a single Dust as it is shared through a variable (!2 is duplicating the function of the Mix. This does not provoke Dust's randomness to be different on each side of the stereo):
(
{
	var in, signal;

	in = Dust.ar(3);

	signal = Ringz.ar(
		in,
		Array.fill(60, { exprand(200, 3000) }),
		Array.fill(60, { exprand(0.2, 0.5) }),
		0.01
	);

	{ Mix(signal) } !2

}.play
)

(
{
	var in;

	in = Dust.ar(3);

	{ Mix(
		Ringz.ar(
			in,
			Array.fill(60, { exprand(200, 3000) }),
			Array.fill(60, { exprand(0.2, 0.5) }),
			0.01
		)
	) } !2
}.play
)

//In the following example, there is a different Dust on each side as the UGen is within the scope of !2 (60 different filters on each side, a different Dust for each side). Dust is, nonetheless, not expanded as the Array provoking the multichannel expansion is applied to the frequency and decay arguments only:
(
{
	var in;

	//in = Dust.ar(3);

	{ Mix(
		Ringz.ar(
			Dust.ar(3),
			Array.fill(60, { exprand(200, 3000) }),
			Array.fill(60, { exprand(0.2, 0.5) }),
			0.01
		)
	) } !2
}.play
)

//In this last example, the array encompasses the entire Ringz filter, provoking that each one of the 60 filters (on each side, which are different) features its own Dust (and thus its own randomness):
(
{
	var in;

	//in = Dust.ar(3);

	{ Mix(
		Array.fill(60,
			{ Ringz.ar(
				Dust.ar(3),
				exprand(200, 3000),
				exprand(0.2, 0.5),
				0.01
			)}
		)
	) } !2
}.play
)


///////////////////////////////////////////////////////////////////////
//IGNORE THIS:
//Bonus code (so GitHub doesn't turn my file into markdown):

(
SynthDef(
	\filters,
	{
		var noise, signal;

		noise = WhiteNoise.ar(0.0001);

		signal = Array.fill(18, { Ringz.ar(noise, ExpRand (100, 3000)) });
		signal = Mix(signal);
		signal = Pan2.ar(signal, 0);

		Out.ar(0, signal)
}).add
)

Synth(\filters)
