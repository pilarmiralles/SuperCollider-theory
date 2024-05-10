//3 - WAVE SHAPES, NOISE AND FILTERS

/////////////////////////////////////////////////////////////////////
//WAVE SHAPES

//Other basic periodic wave shapes apart from the sine wave are the triangle, square and sawtooth oscillators. These UGens have a non-filtered and a filtered (band-limited) version the non-filtered featuring in its identifier the letters LF, standing for low frequency, as these UGens are usually used as lFOs). the triangle oscillator, LFTri, exists only as non-filtered because it does not usually pose any aliasing problem (a form of undersampling occuring when the signal is not sampled fast enough to construct an accurate waveform: we'll see an example of this when introducing the square wave). But if LFPulse or LFSaw are used to produce sound, they might produce aliasing. Instead, when used for sound, the UGens Pulse and Saw (the band-limited versions) might be a better option. Aliasing effects can be nonetheless an aesthetical choice or an expressive resource to be used as well.


//Triangle wave:
{ LFTri.ar(440, 0, 0.5) }.plot(1/440) //Graph of cycle (will boot the server if it wasn't running).
{ LFTri.ar(440, 0, 0.1) }.scope //Oscilloscope and sound.
//The arguments of LFTri are the same as in SinOsc. The phase aregument is called iphase in here referring to the "initial" phase. This argument is present in LFTri, LFPulse and LFSaw, but not in their band-limited versions, as there is no point in changing the phase value (when used for sound). Because this waveshape is no longer based on a circumference, its phase values go from 0 to 4 (0 = 0 radians in a SinOsc, 1 = 0.5pi, 2 = 1pi, 3 = 1.5pi, 4 = 2pi = 0, and everything in between). In LFSaw and LFPulse the phase is measured in different ways, see the respective help file!

//Building a triangle wave out of a sum of sine waves in order to understand how the spectrum is built:
(
{ var freq = 440; //Fundamental freq (overtone 1).

	//Sum of odd overtones (when summing up a bunch of signals, they are added to a single channel, thus the amplitude should be compensated).
	SinOsc.ar (freq * 1, 0, 1/1.squared) //The amplitude of each overtone is the power of 2 of the overtone reciprocal.
	+
	SinOsc.ar (freq * 3, 0, 1/3.squared)
	+
	SinOsc.ar (freq * 5, 0, 1/5.squared)
	+
	SinOsc.ar (freq * 7, 0, 1/7.squared)
	+
	SinOsc.ar (freq * 9, 0, 1/9.squared)
	+
	SinOsc.ar (freq * 11, 0, 1/11.squared)
	+
	SinOsc.ar (freq * 13, 0, 1/13.squared)
	+
	SinOsc.ar (freq * 15, 0, 1/15.squared)
	+
	SinOsc.ar (freq * 17, 0, 1/17.squared)
	+
	SinOsc.ar (freq * 19, 0, 1/19.squared)
	+
	SinOsc.ar (freq * 21, 0, 1/21.squared)
	+
	SinOsc.ar (freq * 23, 0, 1/23.squared)
	+
	SinOsc.ar (freq * 25, 0, 1/25.squared)
	*
	0.1 //Total amplitude * 0.1 (compensate addition of signals).
}.scope //Close, but not like a triangle wave (need more overtones to be closer to it). The more overtones, the more definition of the wave shape.
)

//Example of a modulation with LFTri: try out different ranges, different values for the round argument, different frequencies for the modulating signal, etc.:
(
{ var modulating, carrier;

	modulating = LFTri.ar(1/2, 0, 500, 1500); //Moving from 1000 to 2000. The speed of the steps depends on the freq of the modulating signal (adapting to a longer or shorter time to wander the same amount of steps).
	modulating = modulating.round(200); //Split into 5 steps with 200, 1000/200=5 (as equal steps in Hz, smaller distance in between the higher the frequency and vice-versa).

	carrier = SinOsc.ar(modulating, 0, 0.2) //Applying the LFTri to a SinOsc's freq.

}.play
)


//Square wave:
//Filtered version (normally, for sound). It does not feature an iphase argument:
{ Pulse.ar(440, 0.5, 0.5) }.plot(2/440)
{ Pulse.ar(440, 0.5, 0.1) }.scope

//Raw version, non-band-limited (normally, as LFO):
{ LFPulse.ar(440, 0, 0.5, 0.5) }.plot(2/440)
{ LFPulse.ar(440, 0, 0.5, 0.1) }.scope //Already produces sound artifacts.

//Both versions include a new argument, the "width", which represents with a ratio from 0 to 1 the percentage of time that the wave spends at 0 and 1 in each cycle. By default, the width is 0.5 (half of the time in 0, half in 1). With a width equal to 0.8, the wave will spend 80% of the time at 1, and 20% at 0, for instance.

//Comparing Pulse and LFPulse: moving, especially through higher frequencies will produce aliasing when using LFPulse:
{ Pulse.ar(MouseX.kr(20, 22050, \exponential).poll, 0.5, 0.125) }.scope
{ LFPulse.ar(MouseX.kr(20, 22050, \exponential).poll, 0.5, 0.125) }.scope

//The square wave is unipolar, meaning that its amplitude range or depth goes from 0 to 1 instead of from -1 to 1 (as it happens in bipolar signals). Compare these two signals:
(
{
	[
		SinOsc.ar(440, 0, 1, 0), //Sine wave is bipolar: with mul 1 and add 0, the amplitude range will go from -1 to 1 (so add represents the center).
		LFPulse.ar(440, 0, 0.5, 1, 0) //Pulse wave is unipolar: with mul 1 and add 0, the amplitude range will go from 0 to 1 (so add represents to lower limit).
	]
}.plot(5/440, minval: -3, maxval: 3) //Displaying 5 cycles of the periodic waves within amplitude values -3 to 3.
)

//Unipolar signals can be turned into bipolar and vice-versa by using the methods .bipolar and .unipolar:
(
{
	[
		//SinOsc.ar(440, 0, 1, 0).unipolar, //Sine wave turned into a unipolar signal. See the following line:
		SinOsc.ar(440) * 0.5 + 0.5, //This calculation is equivalent to the method .unipolar applied to the previous line (and equal to writing mul = 0.5 and add = 0.5 within the signal).
		LFPulse.ar(440, 0, 0.5, 1, 0).bipolar //Pulse wave turned into a bipolar signal.
	]
}.plot(5/440, minval: -3, maxval: 3)
)

//The band-limited version is, on the other hand, bipolar (because it is prepared to generate sound):
(
{
	[
		SinOsc.ar(440, 0, 1, 0), //Both signals are bipolar.
		Pulse.ar(440, 0.5, 1, 0) //Because of the band limitation, the amplitude of the Pulse wave seems to be lower than the one indicated in its "mul" (or rather it seems that instead of converting the signal to bipolar, the unipolar signal's center is moved down to 0).
	]
}.plot(5/440, minval: -3, maxval: 3)
)

//Building a square wave out of sine waves:
(
{ var freq = 440; //Fundamental frequency (overtone 1).

	//Sum of odd overtones (as in the triangle wave):
	SinOsc.ar (freq * 1, 0, 1/1) //The amplitude of each overtone is the overtone reciprocal (overtones are more present than in a triangle wave).
	+
	SinOsc.ar (freq * 3, 0, 1/3)
	+
	SinOsc.ar (freq * 5, 0, 1/5)
	+
	SinOsc.ar (freq * 7, 0, 1/7)
    +
	SinOsc.ar (freq * 9, 0, 1/9)
	+
	SinOsc.ar (freq * 11, 0, 1/11)
	+
	SinOsc.ar (freq * 13, 0, 1/13)
	+
	SinOsc.ar (freq * 15, 0, 1/15)
	+
	SinOsc.ar (freq * 17, 0, 1/17)
	+
	SinOsc.ar (freq * 19, 0, 1/19)
	+
	SinOsc.ar (freq * 21, 0, 1/21)
	+
	SinOsc.ar (freq * 23, 0, 1/23)
	*
	0.1 //Total amplitude * 0.1
}.scope //Close, but not a real square (need more overtones to sharp the definition of the spectrum).
)

//Modulating with LFPulse (useful as a switch): when multiplying a signal by another signal, the modulation is applied to the amplitude of the first (just like when multiplying a number by a signal, which is applied equally to its "mul"):
{ (SinOsc.ar(440) * LFPulse.ar(1)) * 0.2 }.play //Using the filtered version would generate two pulses per second still at freq = 1, possibly because of being bipolar and featuring a positive and negative max value.


//Saw tooth wave:
//Filtered version (normally, for sound). It does not feature an iphase argument:
{ Saw.ar(440, 0.1, 0) }.plot(2/440)
{ Saw.ar(440, 0.1, 0) }.scope

//Raw version (normally, for LFO):
{ LFSaw.ar(440, 0, 0.1, 0) }.plot(2/440)
{ LFSaw.ar(440, 0, 0.1, 0) }.scope

{[LFSaw.ar(1000), Saw.ar(1000)]}.plot(0.02) //Comparing both versions, the filtered one has its shape inverted and reaches only half of the amplitude.

//Comparing Pulse and LFPulse (aliasing when moving in between higher freqs and when sustaining higher freqs, artifacts reflected over the low spectrum):
{ Saw.ar(MouseX.kr(20, 22050, \exponential).poll, 0.5, 0.125) }.scope
{ LFSaw.ar(MouseX.kr(20, 22050, \exponential).poll, 0.5, 0.125) }.scope

//Building a saw tooth wave out of sine waves:
(
{ var freq = 440; //Fundamental frequency (overtone 1).

	//Sum of both odd and even overtones (this is why we might need even more overtones to sharp the spectrum towards a real sawtooth wave):
	SinOsc.ar (freq * 1, 0, 1/1) //The amplitude of each overtone is, again, the overtone reciprocal.
	+
	SinOsc.ar (freq * 2, 0, 1/2)
	+
	SinOsc.ar (freq * 3, 0, 1/3)
	+
	SinOsc.ar (freq * 4, 0, 1/4)
	+
	SinOsc.ar (freq * 5, 0, 1/5)
	+
	SinOsc.ar (freq * 6, 0, 1/6)
	+
	SinOsc.ar (freq * 7, 0, 1/7)
	+
	SinOsc.ar (freq * 8, 0, 1/8)
	+
	SinOsc.ar (freq * 9, 0, 1/9)
	+
	SinOsc.ar (freq * 10, 0, 1/10)
	+
	SinOsc.ar (freq * 11, 0, 1/11)
	+
	SinOsc.ar (freq * 12, 0, 1/12)
	+
	SinOsc.ar (freq * 13, 0, 1/13)
	+
	SinOsc.ar (freq * 14, 0, 1/14)
	+
	SinOsc.ar (freq * 15, 0, 1/15)
	*
	0.1 //Total amplitude * 0.1.
}.scope //Very poor sawtooth with just 15 overtones, not convincing:
)

//We would need approx. 50 sine waves to obtain something closer to Saw:
(
{ var freq = 440, signal;

	signal = SinOsc.ar(freq * 1, 0, 1/1); //Fundamental frequency (overtone 1).

	//Repeating 49 times the addition of sine waves (+ the fundamental freq = 50 sine waves):
	49.do({ |i| //Argument "i" = number of iteration (from 0 to 48

		signal = signal + SinOsc.ar(freq * (i + 2), 0, 1/(i + 2)); //i + 2 to avoid the overtone 0 and the overtone 1 (already the fundamental freq).
	});

	signal * 0.05 //Balancing the total amplitude.

}.scope
)

//Modulating with LFSaw (can clearly ientify the wave shape):
{ SinOsc.ar(LFSaw.ar(1, 0, 400, 1000), 0, 0.1 !2) }.play


/////////////////////////////////////////////////////////////////////
//LOW FREQUENCY NOISE GENERATORS

//Low frequency noise generators can present three different interpolations, that is to say, ways in which they move from one random value to the next:
//Low frequency noise generators are mostly used at low frequencies, that is, below 20 Hz (as any repetition or iteration performed above 20 Hz will produce a new frequency spectrum). In the following examples, a frequency above 20 Hz is used to exemplify the auditory difference between different interpolations:
{ LFDNoise0.ar(440, 0.2, 0) }.play //No interpolation or step interpolation (leaps between values).
{ LFDNoise1.ar(440, 0.3, 0) }.play //Linear interpolation (straight lines between values).
{ LFDNoise3.ar(880, 0.3, 0) }.play //Cubic interpolation (curved lines between values).

//Their arguments are the frequency (number of random values per second), and the mul and add. There are other kinds of low frequency noise generators in SC, such as LFNoise0, LFNoise1, LFNoise2, LFClipNoise, LFDClipNoise, etc. (they simply feature different randomness).

//Low frequency noise generators are normally used for aperiodic low frequency modulations (examples of modulation applied to a sine wave's frequency, this time under 20 Hz):
{ SinOsc.ar(LFDNoise0.ar(10, 500, 1000), 0, 0.2) }.play //No interpolation.
{ SinOsc.ar(LFDNoise1.ar(10, 500, 1000), 0, 0.3) }.play //Linear interpolation.
{ SinOsc.ar(LFDNoise3.ar(10, 500, 1000), 0, 0.3) }.play //Cubic interpolation.

{ SinOsc.ar(LFDNoise3.ar(10, 12, 60).round(1).midicps, 0, LFDNoise3.ar(3, 0.5, 0).max(0)) }.play //Applied to two parameters and using the method .max (usefult to create random gaps, as .max only passes what's above 0, and the amplitude range here is -0.5 to 0.5). Because LFDNoise generates floats, when using it with MINI numbers, it is advisable to round the results to 1.

//The methods .min and .max are useful to limit ranges of parameters:
20.max(60) //Passes only whats above the argument (here, 60): so, if lower than the argument, it passes the argument --> FOR LOW LIMIT.
20.min(10) //Passes only what's below the argument (here, 10): so, if higher than the argument, it passes the argument --> FOR HIGH LIMIT.

{ SinOsc.ar(5000, 0, LFDNoise0.ar(10, 0.3, 0.3)) }.play //Another example, only amplitude modulation (constant freq, quite effective).

//Last example:
(
{ var times;

	times = LFDNoise0.ar(1, 4.5, 5.5); //Modulation of an LFDNoise0's frequency with another LFDNoise0 (random value each second). As this LFDNoise is assigned to a variable, the same random value is shared among all the signals (unlike the LFDNoise applied to the frequencies, which produces different random frequencies for each signal, but let's deepen into this in the next theory file).

	Mix( //Five sine waves with different random frequencies mixed into a single channel (and then duplicated on both channels). See next theory file for an explanation of multichannel expansion.
		SinOsc.ar(
			Array.fill(5, { LFDNoise0.ar(times, 220, 660) }), //Random frequency value between 1 to 10 times per second (every second, new value for the frequency of the modulation). Freqs between 440 and 880 Hz.
			0,
			1/20) //Compensating the addition of signals (0.05 * 5 = 0.25).
	) !2
}.play
)


//##############################################################
//Controlling parameters with the mouse:

//Sometimes it is useful to use the mouse to wander about the given range of a specific parameter. We can control parameters with the mouse using:
MouseX.kr //Horizontally across the screen.
MouseY.kr //Vertically across the screen.
MouseButton.kr //Clicking the mouse.

//These UGens are usually used at control rate because they don't produce signals, but control already existent signals (and we will by no means move the mouse at audio rate).
//Some examples:

{ SinOsc.ar(MouseX.kr(20, 16000, \exponential).poll, 0, 0.1) }.play //Simply controlling the frequency of a sine wave. The Mouse UGen is placed in the argument to be controlled. Then, its arguments are the min and max values (range), the type of interpolation or "warp" (being exponential best when working with Hz), and a lag value, the time needed for moving from one value to the next (0.2 sec by default). Same could be applied to MouseY.

{ SinOsc.ar(MouseButton.kr(500, 1000), 0, 0.5) }.play //MouseButton does not have a warp value, just the range values and the lag. In this case, when clicking, we obtain the upper octave of the sine wave. minVal is played when not clicking, and maxVal is obtained when clicking.

//##############################################################


/////////////////////////////////////////////////////////////////////
//NOISE GENERATORS

//Noise generators are usually used to produce sound (noise) or as the sound source for filtering. They only have two arguments: mul and add. Their frequency depends on the sample rate: by default, they produce 44100 random frequency values per second, bringing about as a result what we call "noise" (an aperiodic signal).
//The random frequencies are picked from the whole spectrum, although some types of noise are affected by filtering. The following objects allows the visualization of the frequency spectrum:
FreqScope.new //Compare the different spectrum of the following noise generators with it (the graph can be frozen by pressing "stop").

// These are the main noise generators, from the brightest to the darkest (the last one being an extra, exception):
{ ClipNoise.ar(0.1) }.play //Brightest (chooses values from the extremes of the spectrum).
{ WhiteNoise.ar(0.1) }.play //Bright (although all frequencies feature the same probability of been chosen, higher frequencies seem to be highlighted).
{ PinkNoise.ar(0.1) }.play //Perceived as "plain" noise (that is, with all frequencies featuring the same probability) but, in fact, spectrum falling 3dB per octave (25% of their amplitude).
{ BrownNoise.ar(0.1) }.play //Darkest because values are chosen out of Brownian motion or random walk (that is to say, there is a maximum deviation for going from one random value to the next). Also spectrum falling 6dB per octave (50% of their amplitude).
{ GrayNoise.ar(0.1) }.play //Based on digital synthesis (flips random values in the binary code at sample rate).

//Modulations with noise generators: as the frequency of the noise is changing randomly at sample rate, the result is another aperiodic signal, although the spectrum is perceptibly defined by the mul and add parameters of the modulating signal. Some examples of FM (frequency modulation):
{ SinOsc.ar(ClipNoise.ar(1980, 4000), 0, 0.1) }.play
{ SinOsc.ar(WhiteNoise.ar(1980, 2000), 0, 0.1) }.play
{ SinOsc.ar(PinkNoise.ar(7620, 8000), 0, 0.1) }.play
{ SinOsc.ar(PinkNoise.ar(54.5, 76.5).midicps, 0, 0.1) }.play
{ SinOsc.ar(BrownNoise.ar(1980, 4000), 0, 0.1) }.play
{ SinOsc.ar(BrownNoise.ar(54.5, 76.5).midicps, 0, 0.1) }.play

//Experimenting with different combinations of mul and add (with the mouse).
{ SinOsc.ar(PinkNoise.ar(MouseY.kr(100, 9000), MouseX.kr(200, 10000)), 0, 0.1) }.play
{ SinOsc.ar(GrayNoise.ar(MouseY.kr(100, 8000), MouseX.kr(300, 10000)), 0, 0.1) }.play
{ SinOsc.ar(BrownNoise.ar(MouseY.kr(100, 9000), MouseX.kr(200, 10000)), 0, 0.1) }.play

//Duplicator (!) when working with randomness: difference between mono-duplicated signals and different instances of a function (different randomness on each channel). Note that the use of one or another of these options depends on our objectives:
{ BrownNoise.ar(0.1) !2 }.play //Mono-duplicated signal: same randomness on each side of the stereo.
{ BrownNoise.ar(0.1 !2) }.play //Creating two different instances of the function (applying !2 to the mul argument of the UGen): different function on each side of the stereo, meaning different randomness (the difference between mono-duplicated and different instances of the function is obviously perceptible only when a signal involves some kind of randomness).
{ { BrownNoise.ar(0.1) } !2 }.play //Equivalent to the former function (when a function receives a duplicator, the contents of the function are executed as many times as it is duplicated, therefore creating different instances of it): useful when applying the duplicator to signals with no mul (such as Mix, which will be studied in the next theory file).
{ Array.fill(2, { BrownNoise.ar(0.1) }) }.play //Yet another example of the former line using Array.fill to duplicate the function (equivalent of !n).
{ { BrownNoise.ar(0.1) }.dup(2) }.play //Yet another option using the method .dup(n), as seen in the previous theory file (but only true duplication of the function if the UGen is enclosed in curly brackets).

//Little example to demonstrate how functions respond to duplication:
rrand(50, 1000) !4 //Same result repeated 4 times.
{ rrand(50, 1000) } !4 //Four different results.

//In some cases, though, the duplicator is applied to other arguments of the UGen to obtain the proper duplication:
{ SinOsc.ar(PinkNoise.ar(1800 !2, 2700), 0, 0.05) }.play //Duplicated differently on each side
{ SinOsc.ar(PinkNoise.ar(1800, 2700), 0, 0.05 !2) }.play //Monoduplicated

//Try next example with a freq of 20, 50, 100, 200, 500, 1000... in the LFDNoise: the higher the frequency, the closer it comes to a noise:
{ SinOsc.ar(LFDNoise3.ar(500, 180, 270), 0, 0.05 !2) }.play //Monoduplicated
{ SinOsc.ar(LFDNoise3.ar(500, 180 !2, 270), 0, 0.05) }.play //Monoduplicated
{ SinOsc.ar(LFDNoise3.ar(500 !2, 180, 270), 0, 0.05) }.play  //Duplicated differently on each side

//Same case as before:
{ Saw.ar(200,  LFDNoise3.ar(2 !2, 0.1, 0.1)) * 0.2 }.play //Duplicated differently on each side
{ Saw.ar(200, LFDNoise3.ar(2, 0.1 !2, 0.1)) * 0.2 }.play //Monoduplicated

s.meter //See how each channel moves independently or together. The method .meter shows the volume level of each input and output channel (the input channel, by default, is just the microphone of out computer, if any).

//One last noise generator: chaotic noise generator (based on a chaotic function): its arguments are chaosParam, mul and add. About the first argument: "A parameter of the chaotic function with useful values from just below 1.0 to just above 2.0. Towards 2.0 the sound crackles". Some more information about the chaotic function here: https://github.com/supercollider/supercollider/blob/608bb981162c2c26f0a32c09d82557b29774a32e/server/plugins/NoiseUGens.cpp#L379 and here (where I got the previous link from) https://scsynth.org/t/are-crackle-and-dust-repetitive/3087:
{ Crackle.ar(MouseX.kr(1, 2), 0.5) }.scope


/////////////////////////////////////////////////////////////////////
//IMPULSE GENERATORS

//Impulse generators (commonly used as triggers, that is, something that causes a reaction. In SC, a trigger is produced when zero is crossed in the input of the trigger):
{ Impulse.ar(1, 0, 0.5) }.play //Single impulse (contains the full freq spectrum) = click. The arguments are freq, phase, mul and add (see help file for further discussion). Impulse is a unipolar signal.
{ Dust.ar(10, 0.5) }.play //Random impulse generator (density = average of impulses per second), also called impulse noise generator. Dust is also unipolar, but there is a bipolar version, Dust2.

//For example, ToggleFF acts as a switch, like LFPulse, but it is not an oscillator and therefore needs a trigger: Dust can act as its trigger (applied to the amplitude of the SinOsc):
{ SinOsc.ar(440, 0, ToggleFF.ar(Dust.ar(3))) * 0.1 }.play //Morse code :) (if only using Dust, the signal wouldn't be longer than a click).

//There is another UGen related to impulse generators, called Blip, which is a "band limited impulse generator" (it includes a filter). There is a warning in the help file: "This waveform in its raw form could be damaging to your ears at high amplitudes or for long periods", therefore, BEWARE THE AMPLITUDE!

{ Blip.ar(1, 500, 0.2) }.play //The first argument is the frequency of the impulses and the second argument is the number of harmonics (from 0 = sine wave, to as many harmonics as we want = the higher, the more "squared" the timbre), which gives the frequency (pitch) of each impulse. Last, but not least, the mul.


//##############################################################
//Advanced note:

//I found a tutorial with the equivalent of Blip in SynthDef version, which could be useful to understand how Blip works. I'll leave it copied over here:
(
SynthDef(\blip, {
	|freq = 200|
	var temp, sum;

	sum = 0; //Initial value for sum (so the later addition does not lead to an error because sum is not nil).

	10.do{ |i|
		temp = SinOsc.ar(freq * (i + 1)); //Fundamental freq and 9 more overtones, using the argument "i" (iteration) to get the multiples of the fundamental (i + 1 so it does not multiply the first time by 0).

		sum = sum + temp; //Each iteration adds one more sine wave up to a sum of ten signals (this occurs all at once though).
	};

	sum = sum * 0.05; //Balancing the amplitude.

	Out.ar(0, sum)
}).add
)

Synth(\blip)

{ Blip.ar(200, 10, 0.5) }.play //Same exact thing, using Blip with 10 harmonics and fundamental freq of 200.

//##############################################################


/////////////////////////////////////////////////////////////////////
//BUTTERWORTH FILTERS

//A filter is used to emphasize or eliminate some frequencies from a signal, that is to say, filters affect the frequency spectrum of a sound. The main filters used in SC include the high pass filter (HPF), low pass filter (LPF), band pass filter (BPF), band reject filter (BRF), and resonating filters (such as RHPF, RLPF, Resonz, Ringz, etc.). The basic filters LP, HP, BP and BR are 2nd order Butterworth filters: Butterworth filters are designed to have a frequency response that is as flat as possible, and its order refers to the slope of the filter (how fast the frequencies are cut off: 2nd order = 12dB per octave). These filters receive a signal and a cutoff frequency from which the spectrum will fall gradually. Noises are good input signals for filters as they contain all (or a very big chunk of) the frequency spectrum.
//https://en.wikipedia.org/wiki/Butterworth_filter (about Butterworth filters).
//https://depts.washington.edu/dxscdoc/Help/Tutorials/Mark_Polishook_tutorial/14_Subtractive_synthesis.html (some info about filters in this link about subtractive synthesis).

//High-pass filter. Arguments are the input signal, cutoff frequency, mul and add:
{ HPF.ar(PinkNoise.ar, 1000, 0.1) }.play //Filtering a PinkNoise.
{ HPF.ar(PinkNoise.ar, LFTri.ar(1/10, 0, 8000, 8020), 0.1) }.play //LFTri modulating the cut-off freq from 20 to 16020 Hz every 10 seconds.

//Low-pass filter. Same arguments as in a HPF:
{ LPF.ar(PinkNoise.ar, LFTri.ar(1, 0, 54.5, 76.5).midicps, 0.1) }.play //LFTri modulating the cut-off freq, now using midi values and modulating every second.

//Band-pass filter. The new argument here is "rq" or "reciprocal of q", being q = cutoff freq / bandwidth (remember that x/y/z = x * (z/y), that is to say, "rq" = bandwidth / cutoff freq). The lower the "rq" value, the narrower the passed band of frequencies ("cleaner" sound). But also, the lower the "rq", the more we need to increase the amplitude to compensate, so that we could need mul values even well over 1:
{ BPF.ar(PinkNoise.ar, 1000, 0.01, 3) }.play //Try other RQ (0.5-0.005): compensate the amplitude!
(
{
	BPF.ar(
		PinkNoise.ar,
		LFTri.ar(1/10, 0, 54.5, 76.5).midicps, //Modulating the frequency with a LFTri.
		0.01,
		3
	)
}.play
)

//Band-reject filter. Same arguments as in a BPF:
(
{
	BRF.ar(
		PinkNoise.ar,
		LFTri.ar(1/10, 0, 54.5, 76.5).midicps,
		1, //RQ: the closer to 1, the more noticeable is the rejected band (try out 0.1 for a less clear result). Going over 1 can result in sonic artifacts.
		0.3
	)
}.play
)

//Resonant high-pass and low-pass filters:
{ RHPF.ar(PinkNoise.ar, 1000, 0.01, 0.2) }.play //Same arguments as in a BP or BR filter.
{ RLPF.ar(PinkNoise.ar, 1000, 0.01, 0.2) }.play

//Resonz filter (the "bwr" argument is equivalent to the "RQ" value), another kind of resonant filter:
(
{
	Resonz.ar(
		PinkNoise.ar,
		LFTri.ar(1, 0, 8000, 8100),
		0.05,
		1
	)
}.play
)

//Ringz filter or "ringing filter". It includes a "decay time" instead of an "rq" value. Beware the amplitude when using a Ringz filter: unlike filters with rq value, which might need an amplitude above 1, Ringz filters will require to decrease the amplitude quite a bit as the decay time argument increases:
{ Ringz.ar(Impulse.ar(1), 440, 0.5, 0.1) }.play //Clear example of how the Ringz's decay works, here resonating a click at 440 Hz with a decay time of 0.5 seconds.
{ Ringz.ar(WhiteNoise.ar(1), 440, 1, 0.001) }.play //Here applied to a noise as continuous sound.
