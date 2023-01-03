//4 - FILTER BANKS, KLANK, MIX
////////////////////////////////////////////////

//CHANNELS: channels are arrays --> there are 128 audio channels by default and 4096 control channels by default (for example, for Midi control and so forth). A stereo signal is an array of two elements (two channels), and so forth.
//By default, there are two channels out and two channels in, occupaying the four first indexes within the array of channels (0, 1 for out L-R; 2, 3 for in L-R). From index 4 onwards, the channels are free up to 127 (those are the indexes that we'll use, for instance, to send other signals via private channel).

s.meter //Shows the in /out channels and their level (volume), if evaluated without any signal in SC, it is possible that it shows what the microphone of the computer is capturing.

s.scope //Shows the signal at the active channels (remember that .scope ALSO plays the audio).

{ SinOsc.ar(440, 0, 0.3)}.scope //Coming out through the left channel (index 0).
{ SinOsc.ar(440, 0, 0.3)}.scope(outbus: 10) //Now the signal is at channel 10 (we cannot hear it, because channel 10 is already a private channel, not an out if we're not using 11 loudspeakers. But .scope shows it).

//Now we'll send several signals to several channels: here two sine waves, through L-R (there is a pulse each second due to the difference in frequency). More than two signals won't sound unless we have more than two loudspeakers:

(
{
	[
		SinOsc.ar(440, 0, 0.3),
		SinOsc.ar(441, 0, 0.3)
	]
}.scope
)

//MULTICHANNEL EXPANSION

{ SinOsc.ar([440, 441], 0, 0.3)}.play //This UGen has an array as one of its arguments (the freq). It will create subsequently as many instances of itself as elements in the array (here, two sine waves: the rest of the arguments are shared for both UGens).

//We are creating here 100 sine waves between 30 and 8000 Hz, mixed in a single channel. The amplitude should be taken into account, so this is why we write 1/100, which will be a mul = 1 for the total sum of signals.
(
{
	Mix(
	SinOsc.ar(
			Array.fill(100, { exprand (30, 8000)}), //We use exprand as a better option than rrand when working with frequencies due to the natural exponential distribution of them (otherwise, the high spectrum would be too present, not balanced, because it occupies a large amount of numbers, linearly).
			0,
			1/100 //This is already really loud, 1/200 would be a mul of 0.5 for the total.
	))
}.play
)

//Same array, using the duplicator (!):
{ Mix(SinOsc.ar({ exprand(30, 8000)} !100, 0, 1/100)) }.scope //One single channel, 100 sine waves with different freqs.

//In the next case, the UGen with an array as an argument is inside another UGen: the outer UGen (RLPF) will create as many instances of itself as elements in the array, containing at the same time, a different version of the inner UGen (Saw) in each of its instances:

(
{
	RLPF.ar(
		Saw.ar([100, 250], 0.05),
		XLine.ar(8000, 400, 5),
		0.005

	)
}.play
)

//This would be the result of such code:
(
{
	var xline;

	//The XLine is shared as a common argument (so is the 0.005 for the rq). If we want to keep it for real the same (shared) for both UGens, we should put it inside a variable, so it gives the same values for both (if it was a random process, the result would be very different).
	xline = XLine.ar(8000, 400, 5);

	//An array of two filters with the two different Saw waves, with the two different frequencies, is created:
	[
	RLPF.ar(Saw.ar(100, 0.05), xline, 0.005),
	RLPF.ar(Saw.ar(250, 0.05), xline, 0.005)
]

}.play
)

//Here is an example to see what it would happen if the shared process is a random process:

{ RLPF.ar(Saw.ar([100, 250], 0.05), LFDNoise3.ar(1, 1000, 1030), 0.005)}.play

( //Both RLPF use the same LFDNoise, so the result is the same:
{
	var noise;

	noise = LFDNoise3.ar(1, 1000, 1030);

	[
	RLPF.ar(Saw.ar(100, 0.05), noise, 0.005),
	RLPF.ar(Saw.ar(250, 0.05), noise, 0.005)
]
}.play
)

( //If not properly shared into a variable, the LFDNoise procudes different random values for each element of the array of UGens, eventhough its values are the same:
{

	[
	RLPF.ar(Saw.ar(100, 0.05), LFDNoise3.ar(1, 1000, 1030), 0.005),
	RLPF.ar(Saw.ar(250, 0.05), LFDNoise3.ar(1, 1000, 1030), 0.005)
]
}.play
)

//In the next example we have two arrays in two of the arguments of a UGen. In this case, the biggest array tells us how many instances will be created. On the other hand, the elements from the small array will be distributed cyclically (as when two arrays of different size are added). The single elements are shared, as before:

{ Pulse.ar([400, 500, 600], [0.5, 0.1], 0.2)}.play //A UGen with two arrays in two of its arguments.

//Result: how the elements of the arrays would be distributed (3 UGens, as the biggest array had three elements):
(
{
	[
		Pulse.ar(400, 0.5, 0.2),
		Pulse.ar(500, 0.1, 0.2),
		Pulse.ar(600, 0.5, 0.2)
	]
}.play
)

//USE OF MIX FOR MULTICHANNEL EXPANSION:
//Mix creates a single channel signal mixing a bunch of signals:

{Mix([ PinkNoise.ar(0.1), Saw.ar(mul: 0.1), SinOsc.ar(30, 0, 0.1) ])}.play //These three signals go out through a single channel thanks to Mix.

//As we studied before, we can use up to two channels out (when working with stereo). Hence, when mixing two arrays of signals, each array will go out through a different channel:
(
{
Mix(
	[
		[BrownNoise.ar(0.2), SinOsc.ar(220, 0, 0.2)], //A bunch of signals mixed all in left channel.

		[Dust.ar(50, 0.5), Saw.ar(LFDNoise3.ar(1, 3000, 4000), 0.2)] //A bunch of signals mixed all in right channel.
	]
)
}.scope
)

//USE OF PAN2.AR:
//Pan2 is a panner for mono signals. Its arguments are in, pos and level: "in" has to be a mono signal / "pos" indicate the position from -1 (Left) to 0 (center) to 1 /right) / "level" is similar to mul, it is not necessary to change it normaly (if the signal in is already balanced).

{Pan2.ar(PinkNoise.ar(0.1), SinOsc.ar(1, 0, 1))}.play //Here an example of the use of Pan2: The "in" is a Pink Noise and its position is modulated by a sine wave --> Try to change the frequency of the sine wave (the speed of the modulation).

//Pan2 applied to our first multichannel mix:
(
{
	Pan2.ar(
		Mix(SinOsc.ar({ exprand(30, 8000)} !100, 0, 1/100)),
		SinOsc.ar(2, 0, 1)
)
}.play
)
s.scope

//////////////////////////////////////////////////////////////
//OTHER EXAMPLES FOR MULTICHANNEL EXPANSION:

//An array of 100 sine waves is created in 100 different channels, then those are mixed through a single channel using Mix (amplitude 1/100 = mul 1 for the total sum of signals) - basic example, already studied above:

(
{
	Mix(
		SinOsc.ar(
			Array.fill(100, { exprand(20, 16000) }),
			0,
			1/100
		)
	)
}.play
)

//Now the amplitude is different for each one of the 100 sine waves (and anyways divided by 100 to compensate):

(
{
	Mix(
		SinOsc.ar(
			Array.fill(100, { exprand(20, 16000)}),
			0,
			Array.fill(100, { exprand(0.025, 1) }) / 100,
		)
	)
}.play
)

//Notice the difference between these two codes: when WhiteNoise is within the Array that brings about the multichannel expansion, there will be 18 different noises. In the second example, the noise is outside the array (same noise shared for all filters), which is applied to the frequencies of the filter, bringing about the multichannel expansion of it (in both examples there are 18 different Ringz filters).

(
{
	Mix.ar(
		Array.fill(18, { Ringz.ar(WhiteNoise.ar(0.0001), exprand (100, 3000)) })
	) !2
}.play
)

(
{
	Mix.ar(
		Ringz.ar(
			WhiteNoise.ar(0.0001),
			Array.fill(18, { exprand (100, 3000)})
		)
	) !2
}.play
)

//Mix in two different channels (below, just using a !2, as seen before), creating an array of two Mix. The result will be 100 different sine waves through each side of the stereo (thus, 200 sine waves in total: the sound is much richer):

(//Use of the array:
{
	Array.fill(2,
		{
			Mix(
				SinOsc.ar(
					Array.fill(100, { exprand(20, 16000) }),
					0,
					Array.fill(100, { exprand(0.025, 1) })/100
				)
			)
		}
	)
}.play
)

(//Use of the duplicator (!2):
{
	{
		Mix(
			SinOsc.ar(
				Array.fill(100, { exprand(20, 16000) }),
				0,
				Array.fill(100, { exprand(0.025, 1) })/100,
			)
		)
	} ! 2
}.play
)


//Using 30 different sine waves modulated through a BrownNoise (Freq) and Dust (Amp) through each side of the stereo (due to the !2, which needs the Mix between curly brackets in order to affect it all):
(
{
	{ Mix(
		Array.fill(30, {
			SinOsc.ar(
				BrownNoise.ar(40, 60).midicps,
				0,
				Dust.ar(20, 200).lag(0.5))
			* 0.5})
	)}!2 // --> This would be equivalent to applying the duplicator directly to the mul of a Uegn, but since in Mix we don't have the mul directly, this is the easiest way of duplicating the function.
}.play
)

(//Otherwise, with no curly brackets, the Mix is copied from one side to the other (duplicated mono) and the sound is not richer, but just a copy of the same frequencies in each side of the stereo):
{
	Mix(
		Array.fill(30, {
			SinOsc.ar(
				BrownNoise.ar(40, 60).midicps,
				0,
				Dust.ar(20, 200).lag(0.5))
			* 0.5})
	) !2 //Only mono-duplicated, because it is outside the parenthesis.
}.play
)

(//Compare the same code duplicated differently through each side of the stereo (the duplicator creates two functions and not only duplicates one):
{
	{Mix(
		Array.fill(30, {
			SinOsc.ar(
				BrownNoise.ar(40, 60).midicps,
				0,
				Dust.ar(20, 200).lag(0.5))
			* 0.5})
	)} !2 //Duplicated differently in both sides.
}.play
)

//Similar example, applying XLine to the density of the Dust:
(
{
	{ Mix(
		Array.fill(30, {
			SinOsc.ar(
				PinkNoise.ar(40, 60).midicps,
				0,
				Dust.ar(XLine.ar(50, 2, 10), 200).lag(0.5))
			* 0.5})
	)}!2
}.play
)

//The use of the variable here allows to modulate the time of the modulation between 3 and 10 times per second (each second, a different freq for the modulation). The frequencies are different through each side of the stereo:
(
{
	var mod;

	mod = LFDNoise0.ar(1, 3.5, 6.5);

	{ Mix(
		SinOsc.ar(
			Array.fill(100, { LFDNoise0.ar(mod, 3985, 4015)}),
			0,
			1/200)
	)} !2
}.play
)

//////////////////////////////////////////////////////////////////
//DECONSTRUCTION OF MULTICHANNEL EXPANSION:
//This is a really useful practice because we realize how the multichannel expansion works internally:

//Example:

(
{
	var freqDeviation;

	freqDeviation = LFNoise2.ar(0.05, 0.2, 1); //Little deviation for the frequencies of the filter bank (of fifths, but we'll study this below):

	Mix(
		BPF.ar(
			BrownNoise.ar, //The BrownNoise is common to all BPF.
			f = Array.geom(5, 440, 3/2) * freqDeviation, //All frequencies in the array are multiplied by the freq deviation.
			0.05/f, //The RQ value is adapted to each of the resultant frequencies.
			[24, 30].dbamp //There are two amplitudes in dB.
		)
	)
}.play
)

//The result will be a sum of BPF through a same channel (mono). The content of the Mix will be an array of BPF, separated by commas. If there are several arrays in a UGen, the key is to find the biggest one, in this case, the array of 5 frequencies: the Mix array will have 5 elements, and the rest of the elements in arrays are distributed cyclically. The common arguments are placed into variables and shared between all elements of the Mix array. Using the index from the arrays that should be distributed allows us not to copy them inside each instance of the Mix array:

(
{
	var freqDeviation, noise, amps, freqs;

	freqDeviation = LFNoise2.ar(0.05, 0.2, 1); //This variable was already independent and is applied to each frequency.

	noise = BrownNoise.ar; //The BrownNoise is shared (same noise for all BPF).
	freqs = Array.geom(5, 440, 3/2) * freqDeviation; //Array of frequencies (index 0 to 4), modified by the freqDeviation: random number for all freqs.
	amps = [24, 30].dbamp; //Array of amps (smaller than freqs array, hence distributed cyclically).

	Mix.ar(
		[
			BPF.ar(noise, freqs[0], 0.05/freqs[0], amps[0]),
			BPF.ar(noise, freqs[1], 0.05/freqs[1], amps[1]),
			BPF.ar(noise, freqs[2], 0.05/freqs[2], amps[0]),
			BPF.ar(noise, freqs[3], 0.05/freqs[3], amps[1]),
			BPF.ar(noise, freqs[4], 0.05/freqs[4], amps[0])
		])
}.play
)

//Another example: an array is applied to the frequency of the filter: the rest of the arguments are shared (the noise and RQ), and the smaller arryas (amp) are shared cyclically:
(
{
	Mix(
		BPF.ar(
			BrownNoise.ar,
			Array.fill(5, { exprand (50, 1000)}),
			0.01,
			[0.2, 0.6]
		)
	) !2

}.play
)

(
{
	var in, rq, freq, amps;

	in = BrownNoise.ar;
	rq = 0.01;
	freq = Array.fill(5, { exprand (50, 1000)});
	amps = [0.2, 0.6];

	Mix(
		[
			BPF.ar(in, freq[0], rq, amps[0]),
			BPF.ar(in, freq[1], rq, amps[1]),
			BPF.ar(in, freq[2], rq, amps[0]),
			BPF.ar(in, freq[3], rq, amps[1]),
			BPF.ar(in, freq[4], rq, amps[0]),
	]) !2

}.play
)


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//FILTER BANKS:
//We can use the multichannel expansion to create banks of filters based on specific intervals. We use Array.geom for this:

//In this case, the fundamental frequency (start) is 30 Hz. Then we should take care of the top frequency of the filter not to surpass the 15000 Hz more or less.  The grow argument of the Array.geom determines the interval using ratios of the overtone numbers in the case of Pitagoric or natural temperament (for example, here using 5ths, the number of overtones in the overtone series creating a fifth are 3 and 2: 3/2 in the grow will create fifths. Inverting the ratio, using 2/3 will create a series of fifths but downwards - take into consideration the start freq, which should be higher then and not reaching a freq lower than 30-50Hz). We use a BPF to filter a PinkNoise in this case. The RQ of the filter has to be narrow in order to hear the frequencies. The narrower the filter is, the more mul (amplitude) it needs (even over 1). Last but not least, the Mix allows us to create 16 BPF (due to the freq array) mixed through a single channel (and here, mono-duplicated due to the !2 and no use of {}):

(
{
	Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(16, 30, 1.5), //1.5 = 3/2 = ascending fifths.
			0.001,
			7)
	)!2
}.play
)

//Using descending major 3rds, up to 30 Hz aprox (big augmented chord, only three different pitches because the octave is only divided into three major 3rds). Do not use the tritone as an interval unless necessary, it only producess two different pitches:

(
{
	{
	Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(29, 16000, 4/5),
			0.01,
			3)
)}!2
}.play
)

//Some reminder of pitagoric relationships (the intervals are not exact, especially those that are not P5hts, 4ths or the 8ve):
/*
(Here, ascending intervals --> invert the ratio to get the descending version):
Unison --> 1
min 2nd --> 17/16
maj 2nd --> 9/8
min 3rd --> 6/5
maj 3rd --> 5/4
perfect 4th --> 4/3
perfect 5th --> 3/2
min 6th --> 8/5
maj 6th --> 5/3
min 7th --> 7/4
maj 7th --> 17/9
perfect 8th --> 2
(Remember that a division is expensive for the processing of the program: it is better to express these rations in floats whenever possible).
*/

//Method .midiratio (and .ratiomidi for opposite result), turns an interval calculated in number of semitones into an interval ratio, but in this case, the temperament is equal (sometimes, the little tunning deviations from the Pitagoric temperament could be interesting, and in other cases, the equal temperament could be more convenient, depends on your objectives):

7.midiratio //Tempered fifths.

//Filter bank of fifths, now with equal temperament:
(
{
	Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(16, 30, 7.midiratio),
			0.01,
			3)
	)!2
}.play
)

//Octave filter (ratio = 2/1, thus 2), "organ filter". Try different RQ: rq = 0.1 will create a dirtier sound:
(
{
	Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(8, 30, 2),
			0.001,
			3)
	)!2
}.play
)

//Minor seventh filter (Pitagoric temperament, so not as perfect as the equal one, which could be interesting), between the 4th and 7th overtones:
(
{
	Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(12, 30, 7/4),
			0.01,
			1)
	)!2
}.play
)

//Here we use a concatenation of arrays in order to mix two different intervals (the number of frequencies will be the sum of the two arrays' size). The fundamental frequency is the same for both arrays in this case (but it can be different):

(
{
	var freqs;

	freqs = Array.geom(12, 30, 7/4) //Sevenths.
	        ++
	        Array.geom(23, 30, 4/3); //Fourths.

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.01,
			1)
	)!2
}.play
)

//Here, we create a filter bank using all intervals in order (m2nd, M2nd, m3rn, M3rd, P4th, etc. up to M7th), using the method .integrate (obtaining the distance in semitones of each further step in the scale, and converting it to interval ratios with .midiratio, and finally multiplying by the fundamental freq:

( //Notice the use of Array.series intead of Array.geom (not working with Hz in the first moment, thus no need for an exponential series):
{
	var freqs;

	freqs = 35 * Array.series(12, 0, 1).integrate.midiratio; //Using -1 as the step, the series will be created downwards. The factor 35 is the fundamental frequency (multiplied by each interval ratio, it will give back each frequency of the series).

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.01,
			1)
	)!2
}.play
)

//Here how the method .integrate works:
[3, 4, 1, 1].integrate; //It simply returns a collection with the incremental sums of all elements = [3, 3+4, 3+4+1, 3+4+1+1] = [3, 7, 8, 9]

//Example of the same process, using midi notes instead (addition instead of product, with no .midiratio method and converting to Hz at the end) - 36 midi is higher than 35 Hz, do not expect the same result as in the previous code:

(
{
	var freqs;

	freqs = (36 + Array.series(12, 0, 1).integrate).midicps;

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.01,
			1)
	)!2
}.play
)

//Here we create an octave filter: multiplying the frequencies by a little detunning (-0.5 quarter tone lower, 0 no detunning, or 0.5 quarter tone higher). The size of both arrays is the same, so each frequency gets its own detunning value (otherwise, the number of detunnings would be distributed cyclically if smaller than the number of freqs / if higher, some values are simply not used):

(
{
	var freqs;

	freqs = Array.geom(10, 30, 2/1)
	        *
	        Array.fill(10, {[-0.5, 0, 0.5].choose.midiratio});

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.01,
			1)
	)!2
}.play
)

//Same process here, but the detunning will be greater (higher) from no detunning. The argument "i" is the number of the index (instance) of the array.fill (as studied before)

(
{
	var freqs;

	freqs = Array.geom(10, 30, 2/1)
	        *
	        Array.fill(10, { arg i; ((i + 1/10) * 0.5).midiratio}); //The i + 1/10 calculate a number, everytime a bith higher and adapted to each of the 10 frequencies, finally multiplied by the quarter tone up detunning.

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.01,
			1)
	)!2
}.play
)

//Here the argument index is used to calculate the number of each overtone of the overtone series as a simple linear series, and then each number is multiplied by the fundamental frequency (35 Hz) in order to get the frequencies for the series (fundamental freq * overtone number = overtone freq).

(
{
	var freqs;

	freqs = Array.fill(10, { arg i; (i + 1 * 35)}); // We add i + 1 just to avoid starting by 0 and having an empty freq.

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.01,
			2)
	)!2
}.play
)

//We can obtain the same series without the use of the index argument:

(
{
	var freqs;

	freqs = 50 * Array.series (25, 1, 1); //Directly creating a linear series of simple integers from 1 and multiplying by the fundamental freq.

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.01,
			2)
	)!2
}.play
)

//Half tone chord from 35 Hz, up to six octaves:
//We can check the last freq of the array using the method .last (do not put the method inside the filter code, otherwise, wou'll get played just the last frequency of the array):
Array.geom (72, 35, 1.midiratio).last

(
{
	var freqs;

	freqs = Array.geom (72, 35, 1.midiratio);

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.002,
			1)
	)!2
}.play
)

//Same filter, with more pitches, using an array in the amplitudes to compensate the volume of the higher pitches (every time a bit lower):

(
{
	var freqs, amps;

	freqs = Array.geom (108, 35, 1.midiratio); //Both arrays, same size.
	amps = Array.geom (108, 1, 0.96); //0.96 create a little deviation so each freq is a bit lower in amplitude while going up in frequency.

	Mix(
		BPF.ar(
			PinkNoise.ar,
			freqs,
			0.002,
			amps)
	)!2
}.play
)

//Some more detuning in here:
(
{ var freq;

	freq = Array.geom(5, 200, 4/3)
	       *
	Array.fill(5, {[1, 0].choose.midiratio}); //The only options are 1 or 0, so the fourths are Perfect (no detuning) or augmented (+ one half step).

	Mix.ar(BPF.ar(
		    PinkNoise.ar,
			freq,
			0.01,
			2)
	) !2
}.play
)

////////////////////////////////////////////////////////////////////////
//A reminder about the conversion between midi and Hz:

//.midicps inside the LFDNoise (converting to Hz before the random distribution is applied) --> Uniform distribution of exponential values, higher frequencies more likely.
(
{
	Mix(
		SinOsc.ar(
			Array.fill(5, { LFDNoise0.ar(1, 9.midicps, 69.midicps)}),
			0,
			1/20) //For mul = 0.25.
) !2}.play
)

//.midicps outside the LFDNoise (converting to Hz after the random distribution is applied) --> Uniform distribution of linear values, broader range, all frequencies equally likely.
(
{
	Mix(
		SinOsc.ar(
			Array.fill(5, { LFDNoise0.ar(1, 9, 69).midicps}),
			0,
			1/20) //For mul = 0.25.
) !2}.play
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//KLANK UGEN: BANK OF RINGZ FILTERS:

{Ringz.ar(Impulse.ar(0.5), 1000, 1, 0.1)}.play  //A single Ringz filtering an Impulse with a frequency of 1000 Hz and 1 second of delay time (the frequency - speed - of the impulse is 1 each 2 second).

//Klank is a bunch of Ringz filters mixed together. Its main argument is "specificationsArrayRef", which is a reference of an array of specifications. Those specifications are (in this order): frequencies, amplitudes and decay times. An array of values (or single value) is indicated for each one of the parameters, which will be the parameters of the Ringz filters inside Klank (and chosen randomly).

`[ //The little accent at the beginning of the array is the "reference". We need this to avoid the multichannel expansion that would result from the arrays (so it is just one array of values and not one arrays of arrays).
	Array of freqs, //Should we want the same freq / amp / decay time for all Ringz, use just a single number in the argument instead of an array.
	Array of amps,
	Array of decay times
]

//The other arguments are: INPUT: the signal that will be filtered / FREQSCALE: a transposition for the entire filter, due to the impossibility of modulating the freqs inside the specifications array reference / the rest of the arguments are rarely used:

//EXAMPLES (BE AWARE OF THE AMPLITUDE):
(
{
	Klank.ar(
		`[
			[178.4, 570.3, 7384, 605],
			1, //Shared amplitude and decay time.
			1
		],
		{PinkNoise.ar(0.001)} !2 //Equivalent to PinkNoise.ar(0.001 !2), the pinkNoise will be different on each side of the stereo (featuring different random values from the filter as well).
)}.play
)

(
{
	Klank.ar(
		`[
					[178.4, 570.3, 7384, 605, 356.9, 1150.6, 14768, 1210],
					1,
					[0.002, 0.012, 0.018, 0.013, 0.002, 0.012, 0.018, 0.013] //Different decay time for each frequency.
				],
				{PinkNoise.ar(0.01)} !2
	)}.play
)

(
{
	Klank.ar(
		`[
			[178.4, 570.3, 7384, 605, 356.9, 1150.6, 14768, 1210],
			1,
			[0.002, 0.012, 0.018, 0.013, 0.002, 0.012, 0.018, 0.013]
		],
		{Dust.ar(3, 0.1)} !2 //Using Dust: tapping sound, quite realist (ASMR).
)}.play
)

(
{
	Klank.ar(
		`[
					[178.4, 570.3, 7384, 605, 356.9, 1150.6, 14768, 1210],
					1,
					[0.002, 0.012, 0.018, 0.013, 0.002, 0.012, 0.018, 0.013] * 16 //The product in here works as a lag for each decay time.
				],
				{Dust.ar(3, 0.1)} !2
	)}.play
)

//Using Array.fill to produce random freqs and decay times (instead of writing the specific list of values):
(
{
	Klank.ar(
		`[
			Array.fill(8, { exprand(150, 14000)}),
			1,
			Array.fill(8, { exprand(0.002, 0.02)}) * 32],
		{PinkNoise.ar(0.01)} !2
)}.play
)

