//3 - WAVE SHAPES, NOISE AND FILTERS

////////////////////////////////////////////////

//WAVE SHAPES:

//TRIANGLE WAVE: LFTri is a non-band-limited triangle oscillator. This means that the signal is not limited (filtered).  As we will see when studying the square and sawtooth waves, there are both limited and non-limited versions with different functions. All LF signals (Low Frequency) are prepared to be used in modulations rather than to produce sound. Its amplitude value oscillates between -1 and 1. The arguments are the same as in a SinOsc (the phase here is called iPhase or "initial phase").

{ LFTri.ar(440, 0, 0.5)}.plot(1/440) //Graph of the triangle wave (one cycle).
{ LFTri.ar(440, 0, 0.5)}.scope //Graph of the signal AND sound.

//We can build a triangular wave out of a sum of sine waves. Their frequency has to be multiplied by the odd numbers (odd overtones), from 1 to as many as we need (the more overtones we add, the more defined the triangular wave will be). Then, the amplitude of each overtone will be calculated as the inverted power of two (.squareds) of the overtone number:

({
	var freq = 440; //Fundamental freq (overtone 1).

	SinOsc.ar (freq * 1, 0, 1/1.squared)
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
	SinOsc.ar (freq * 25, 0, 1/25.squared) //The more overtones, the more definition (we will learn a more efficient way to do this later on).
	*
	0.5 //General amplitude of the total sum of signals (when adding signals, their amplitude is accumulated, therefore we have to control the total amplitude in order to maintain it between 0 and 1 (and preferably below 1).
}.scope
)

//Modulating with a triangle wave:
//Note for myself: The number of steps affects also the pace of the freq modulation: the higher the round value, the slower the change because the bigger the steps (so the faster the range is covered), but the lower the number (the smaller the steps) the faster is has to move in order to cover the space in the same time, each seconds. As the steps are fixed in 200 Hz and the frequency in Hz is exponential, the steps are bigger at the low freqs and smaller when reaching higher freqs (it works like an overtone series):

(
{
	a = LFTri.ar(1, 0, 500, 1500); //A triangular wave moves in the graph between 1000 and 2000 Hz each second (up and down).
	a = a.round(125); //This creates little steps of 125 hz within the continuous movement given the range from 1000 to 2000. Without this, the sound of the SinOsc would be continuous.
	c = SinOsc.ar(a, 0, 0.3); //The triangular wave is applied to the sine wave, modulating its continuous frequency into the discontinuous steps.

}.plot(1/1500) //This is the visualization of the wave (observe closely the wave, it is not smoothly rounded, but built out of little straight segments).
//}.play //For playing the sound.
)

//Smaller steps:
(
{
	a = LFTri.ar(1, 0, 500, 1500);
	a = a.round(75); //Feels almost continuous with steps of 75 already.

	a.poll(20); //Need to print more than 10 values per second if I want to see all steps from 1000 to 2000 with the applied round value.

	c = SinOsc.ar(a, 0, 0.3)

}.play
)

//Bigger steps:
(
{
	a = LFTri.ar(1, 0, 500, 1500);
	a = a.round(200);

	a.poll(20);

	c = SinOsc.ar(a, 0, 0.3)

}.play
)

//SQUARE WAVE: two versions of the square wave might be used according to its function: LFPulse is the non-band-limited pulse oscillator, mainly used for modulations. The filtered version is Pulse, better for producing sound because it reduces the possibility of aliasing. The filtered version, Pulse, does not have the iPhase argument (because it is not used for modulating other signals). If the non-filtered version is used for sound synthesis, it can produce aliasing when modulated. Aliasing sounds are interesting (akin to old radios trying to syntonize a frequency), but they can also sound too evident as aliasing. The square wave is the only one which does not oscillate below amplitude 0 (it produces the pulses from 0 to 1, or any other value used for a modulation). This has to be taken into consideration when calculating the mul and add for a modulation. The 3rd argument in LFPulse (or 2nd in Pulse) is "width", the percentage of the wave that is at 0 and at 1, usign a ratio between 0 and 1 (0.5 is the default, same percentage at 0 and at 1. If we use 0.8, there is more percentage at 1. If we use 0.2, there is more percentage at 0), this is especially useful when modulating using a square wave (at a rate at which the width is audible, as it happened with the phase in a SinOsc):

{ Pulse.ar(440, 0.5, 0.5) }.scope //Filtered version (signal and sound). The filtered version has no phase argument.
{ LFPulse.ar(440, 0, 0.5, 0.5) }.scope //Non filtered version (careful with sound, produces aliasing).
{ LFPulse.ar(440, 0, 0.5, 0.5) }.plot(2/440) //Graph (two cycles).

//A square wave can also be built out of a sum of sine waves. In this case, we also use the odd overtones only, but the amplitude of each is the inverted number of the overtone (without the power of 2):

({
	var freq = 440; //Fundamental frequency.

	SinOsc.ar (freq * 1, 0, 1/1)
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
	SinOsc.ar (freq * 23, 0, 1/23) //... The more overtones, the more definition.
	*
	0.5 //Again, general amplitude for the total sum of sine waves.
}.scope
)

//Differenciating Pulse and LFPulse: aliasing:

{Pulse.ar(MouseX.kr(20, 22050, \exponential).poll, 0.5, 0.125) }.scope //By moving the mouse from left to right, we increase the frequency. Thanks to the filtering, all overtones frequencies go up or down at the same time.
{LFPulse.ar(MouseX.kr(20, 22050, \exponential).poll, 0.5, 0.125) }.scope //Here, using the non-filtered version, we can hear the aliasing: some overtones go up, some go down (especially regarding the higher frequencies, because of their reflection when getting out of the audible spectrum --> See Nyquist theorem).

//Modulating with a Square wave (in this case, amplitude modulation): pulsation effect:

{ SinOsc.ar(440) * LFPulse.ar(1) }.play //The square wave turns on and off the signal, like a switch.

//Difference between LFPulse and Pulse:

{ SinOsc.ar(440) * LFPulse.ar(1) }.play; //Version used to modulate (1 pulse per second): the non-filtered version is UNIPOLAR because it does not reach negative values (just values from 0 to x).
{ SinOsc.ar(440) * Pulse.ar(1) }.play; //Version for sound (not for modulating, produces 2 pulses per second): the filtered is BIPOLAR because it has a positive and negative maximum (might be the reason why it produces two pulses per second).
{ SinOsc.ar(440) * (Pulse.ar(1) > 0.00125)}.play; //Solution for it to play one pulse per second (keeping it below zero).

{[LFPulse.ar(1000), Pulse.ar(1000)]}.plot(0.02) //Observe the graphs, the upper one is the pure basic form of the Pulse wave from 0 to 1 (LFPulse), but the one below (Pulse) crosses the 0.

//Now observe the differences when the different signals are converted to unipolar / bipolar:
{[Pulse.ar(1000).unipolar, Pulse.ar(1000)]}.plot(0.02) //Pulse is bipolar by default: when .unipolar is applied, it is cut to half (in amplitude) and lifted between 0 and 1 (it is higher than 0 maybe because of the embedded filter).
{[LFPulse.ar(1000), LFPulse.ar(1000).bipolar]}.plot(0.02) //LFPulse is unipolar by default: when .bipolar is applied, it is expanded to double its amp, reaching the amplitude range between -1 and 1.

//SAWTOOTH WAVE: we find the same two options: Saw is the band-limited sawtooth generator, used to produce sound; LFSaw is the non-band-limited sawtooth generator, used for modulations. As in Pulse, Saw does not feature a phase argument because it is not used for modulations. The amplitude oscillates between -1 and 1.

{ Saw.ar(440, 0.5, 0.5) }.scope //Filtered version. No phase argument (graph and sound).
{ LFSaw.ar(440, 0, 0.5, 0.5) }.scope //Non-filtered version. The sound produces aliasing.
{ LFSaw.ar(440, 0, 0.5, 0.5) }.plot(2/440) //Graph.

{[LFSaw.ar(1000), Saw.ar(1000)]}.plot(0.02) //It is interesting that the filtered version has its graph inverted and reaching almost half of the amplitude.

//We can build a sawtooth wave out of a sum of sine waves. In this case, we add all even and odd overtones, and the amplitude of each will be the inversions of the overtone number, as in the pulse wave:

({
	var freq = 440; //Fundamental frequency.

	SinOsc.ar (freq * 1, 0, 1/1)
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
	SinOsc.ar (freq * 14, 0, 1/14)//... roughly 50 sine waves bring about a decent sawtooth wave (this one does not sound convincing yet).
	*
	0.5 //General amplitude for the total addition.
}.scope
)

//Modulating with a sawtooth (frequency modulation of a sine wave, for instance):

{ SinOsc.ar(LFSaw.ar(1, 0, 400, 1000), 0, 0.3)}.play //The frequency goes down suddenly and comes up progressively again (following the waveshape of the saw).

//Remember that the aliasing is also avioded raising the sample rate (over the 44100 Hz set by default).

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//LOW FREQUENCY NOISE GENERATORS:

//LFDNoise0, 1 and 3 are UGens used to modulate. They are low frequency noise generators. The number in thir names corresponds to their interpolation (how the lines between the random values produced by the generator are traced: 0 = no interpolation / 1 = linear interpolation (straight lines) / 3 = cubic interpolation (curved lines). They have three arguments: frequency (freq = 10, for instance, will produce 10 random values per second; freq = 1/10 will produce 1 value each 10 seconds / mul and add (calculate those for the specific modulation values as studied in the document 2).

//Some examples:

{ LFDNoise0.ar(440, 0.3, 0)}.play //LFNoise is not prepared to produce sound, but this is the noise generator at audio rate (440 Hz).

a = { SinOsc.ar(LFDNoise0.ar(10, 500, 1000), 0, 0.3) }.play //Applied to a sinewave's frequency, produces 10 random values per second, between 500 and 1500 Hz. There is no interpolation, so the signal jumps to each new frequency.


{ LFDNoise1.ar(440, 0.3, 0) }.play //Different interpolation, different sound quality of the pure noise (again, not prepared for sound), as if LPF was applied.

a = { SinOsc.ar(LFDNoise1.ar(10, 500, 1000), 0, 0.3) }.play //Linear interpolation: now the pitches are connected by sort of a glissando.

a = { SinOsc.ar(LFDNoise1.ar(10, 24, 60).midicps, 0, 0.3) }.play //Using notes in midi (equal temperament) within four octaves (two octaves - 24 midi values - below 60 midi and two above 60 midi). The conversion method.


{ LFDNoise3.ar(880, 0.3, 0) }.play //Last type of interpolation, higher frequencies even more cut (higher frequency so we can hear it).

a = { SinOsc.ar(LFDNoise3.ar(10, 500, 1000), 0, 0.3) }.play //Frequency modulation using cubic interpolation: more accute glissando between freqs.

{ SinOsc.ar(LFDNoise3.ar(10, 12, 60).midicps, 0, max(LFDNoise3.ar(3), 0))}.play //Usign LFNoise to modulate the frequency + using another LFDNoise to modulate the amplitude, applying the method "max" to keep only the values above 0 (thus, it produces silence when the signal goes below 0. Applying the method "min", it would keep only what is below zero on the contrary, which in this case would bring about a similar effect if not the same, as negative or positive amplitude at audio rate just depends on the phase of the sound wave, it is "symmetric").

//Amplitude modulation using LFDNoise (keeping constant freq so the changes can be easily percieved):

{ SinOsc.ar(5000, 0, LFDNoise0.ar(10, 0.3, 0.3))}.play

//There are other low frequency noise generators such as LFNoise2. They just feature other kinds of randomness and interpolations (see in the help document).

//Example of nested LFDNoise to randomly modulate the frequency of another LFDNoise that is modulating the fresq of the Array of freqs of the sine wave: each second, there is a different number of random frequencies produces, from 1 to 10 (as the freq of the "times" variation is = 1, and its mul (4.5) and add (5.5) bring about the range 1 to 10):
(
{
	var times;

	times = LFDNoise0.ar(1, 4.5, 5.5);

	Mix(
		SinOsc.ar(
			Array.fill(5, { LFDNoise0.ar(times, 245, 539)}),
			0,
			1/20) //So the total mul is 0.25.
) !2}.play
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//CONTROL OF PARAMETERS WITH THE MOUSE:

//We can control parameters using MouseX.kr (horizontally), MouseY.kr (vertically) or MouseButton.kr (clicking the mouse). We usually use control rate (.kr) with these UGens which does not produce signals but they control already existent signals (the mouse is by no means going to be moved at 44100 Hz of sample rate, hence we don't need the audio rate).
//Some examples:

{SinOsc.ar(MouseX.kr(20, 16000, \exponential).poll, 0, 0.1)}.play //Same would be using MouseY. Controlling the frequency. The wrap argument is the type of interpolation between frequencies (\exponential is the most natural one. Other option is \linear. This influences the distribution of the frequencies on the space of the screen. This is why the exponential is the best option when working with frequencies, whose distribution is exponential). The lag argument is the time used for moving from one value to the next one.

{SinOsc.ar(MouseButton.kr(500, 1000), 0, 0.5) }.play //Not pressing = minVal / Pressing = maxVal (minVal and maxVals are the arguments). The lag argument is the time used for going to one frequency to the next (there is no wrap argument due to the pulse nature of this UGen).

//NOTE FOR MYSELF----> It is good to work with frequency in MIDI (and convert with .midicps) and with amplitude in dB (and convert with .dbamp), in order to be conscious of the real values we are working with. Though frequency in MIDI only allows working with equal temperament (unless using cents through decimals).

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//NOISE GENERATORS:

//The noise generators are used to produce sound, especially as the sound source for filtering. They only have mul and add as arguments. We can use four main noise generators, from the brightest to the darkest:

FreqScope.new //Evaluate this to analize (visualize) the frequencies when trying the following noise generators (you can freeze the graph by pressing "stop").

{ClipNoise.ar(0.3)}.play //The brightest one as it chooses values from the extremes of the frequency range (the high freqs tend to be perceived as more intense). At 44100 Hz of sample rate, the UGen chooses 44100 random values per second, which produces the noise sound.

{WhiteNoise.ar(0.3)}.play //A bit less bright, all the freqs have the same probability to be chosen, but we tend to perceive the higher ones as more intense still.

{PinkNoise.ar(0.3)}.play //It is perceived as plain noise (all freqs same probability), but indeed its spectrum falls 3dB of per octave (a 25% of the amplitude).

{BrownNoise.ar(0.3)}.play //The brown noise is also known as brownian noise or random walk noise, is the darkest one. There is no abrupt jumps between frequencies and the spectrum falls 6 dB per octave (a 50% of the amplitude).

//There is also GrayNoise.ar in SC, based on digital synthesis flipping random values in the binary code, which happen at sample rate, hence bringing about the noise. Lower frequencies are emphasized within the spectrum of this noise:
{GrayNoise.ar(0.1)}.play //QUITE NICE.

//Examples of modulation using noise generators:

{SinOsc.ar(ClipNoise.ar(1980, 2000), 0, 0.3)}.play //The frequency is still changed at a very fast pace, so the resultant sound is closer to noise than to a sine.
{SinOsc.ar(WhiteNoise.ar(1980, 2000), 0, 0.3)}.play //A bit more centered.
{SinOsc.ar(PinkNoise.ar(7620, 8000), 0, 0.3)}.play  //Using a higher frequence.
{SinOsc.ar(PinkNoise.ar(54.5, 76.5).midicps, 0, 0.3)}.play //Between 22 and 131 midi.
{SinOsc.ar(BrownNoise.ar(1980, 2000), 0, 0.3)}.play //Trying the brown noise.
{SinOsc.ar(BrownNoise.ar(54.5, 76.5).midicps, 0, 0.3)}.play //Or using midi.

//Amplitude modulations using noises also modulate the value 44100 times per second, producing a hybrid noise (it is an alternative way of performing ring modulation, but we'll study that later on).

//Randomness and stereo sounds using the duplicator !2:
{BrownNoise.ar(0.1) !2}.play //It copies the BrownNoise, with the same randomness (literal copy) on each side of the stereo = mono duplicated.
{BrownNoise.ar(0.1 !2)}.play //It duplicates the entire function of the BrownNoise, thus the noise will be different (different randomness) on each side.
{{BrownNoise.ar(0.1)} !2}.play //Equivalent of the former example, useful to duplicate Functions with UGens that do not feature the mul argument (Mix, for instance).
//As Array.fill is equivalent to !n, we can now understand why the function of Array.fill is written between curly brackets, in order to duplicate the function with different results (if the function produces different results) instead of just duplicating or copying the literal content.

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//IMPULSE GENERATORS:

{Impulse.ar(1, 0, 0.5)}.play //Produces a click (a single value) per second. Its frequency is the number of impulses per second. The amplitude moves from 0 to 1, as in a square wave (thus, take into consideration that add = bottom limit, not the center).

{Dust.ar(10, 0.5)}.play //This is the random version of Impulse: with a freq = 10, it will produce 10 click per second, but randomly distributed throughout the second. The amplitude of each click is also random within the given range.
//Dust.ar vs Dust2.ar: Dust amplitude's range goes from 0 to 1, and Dust2 amplitude's range goes from -1 to 1 (so one is unipolar and the other, bypolar).

//Examples: if used for a modulation (instead of as a trigger, which is their main use), Dust or Impulse need some more duration, and ToggleFF is a good option for this (other option is the method "lag"):

{SinOsc.ar(440, 0, ToggleFF.ar(Dust.ar(3))) * 0.1}.play //Toggle is a switch so we can apply the Dust as a trigger to switch on and off the sine wave.

//There is also Blip, which is sort of an impulse, but featuring a filter and amplified (BEWARE THE AMPLITUDE).

{Blip.ar(1, 500, 0.1)}.play //The first argument is the frequency of the impulses (the speed), and the second argument is the number of harmonics (from 0 = sine wave, to as many harmonics as we want = the higher, the more "squared" the timbre), which gives the frequency (the pitch) of each impulse. Last, but not least, the mul.

//Advanced note://///////
//I just found a tutorial with the equivalent of Blip in SynthDef version, just to understand how it works, could be useful to copy it over here:

(
SynthDef(\blip, {
	|freq = 200|
	var temp, sum;

	sum = 0; //Initial value for sum (so the later addition does not lead to an error because sum is not nil).

	10.do{ |i|
		temp = SinOsc.ar(
			freq * (i + 1) //Fundamental freq and 9 more overtones, using the argument "i" (iteration) to get the multiples of the fundamental (i + 1 so it does not multiply the first time by 0).
		);

		sum = sum + temp; //Each iteration adds one more sine wave up to a sum of ten signals (this occurs all at once though).
	};

	sum = sum * 0.05; //Balancing the amplitude.

	Out.ar(0, sum)
}).add
)

Synth(\blip)

{ Blip.ar(200, 10, 0.5) }.play //Same exact thing, using Blip with 10 harmonics and fundamental freq of 200.

/////////////////////////////////////////////////////////////////////////////////////
//BUTTERWORTH FILTERS: HPF, LPF, BPF y BRF: when filtering a signal, the amplitude of its frequencies falls at a specific pace from a cut-off frequency onwards. It is not an abrupt cut, but a gradual one: in SuperCollider, these are 2nd order filters, which means that the freqs from the cut-off point are going to fall 12 dB per octave.

//There are several types of filters:

//HPF (High Pass Filter) and LPF (Low Pass Filter): as arguments, there is the signal to be filtered (in), the cut-off freq, the mul and add:
//Examples:

{HPF.ar(PinkNoise.ar, 1000, 0.1)}.play //Noise filter (1000 = cut-off frequency).

{HPF.ar(PinkNoise.ar, LFTri.ar(1/10, 0, 8000, 8020), 0.1)}.play //A triangular oscillator modulates the frequency of the filter. WARNING: be careful wiith very low or negative frequencies, they can create extremely loud noise artifacts.

//Using Midi numbers in here:
(
{HPF.ar(
	PinkNoise.ar,
	LFTri.ar(1/10, 0, 54.5, 76.5).midicps,
	0.1

)
}.play
)

//Now applying a low pass filter:
(
{LPF.ar(
	PinkNoise.ar,
	LFTri.ar(1, 0, 54.5, 76.5).midicps,
	0.1

)
}.play
)

//BPF (Band Pass Filter) - and BRF (Band Reject Filter): they include a new argument, the RQ, which is equal to the bandwidth divided into the cut off freq. This means that the filter is going to be narrower when the RQ is low (0.005, for example), and wider, when it is high (0.5, for instance).

{BPF.ar(PinkNoise.ar, 1000, 200/1000, 0.3)}.play //RQ calculated as bandwidth / cutOff Freq. Not so narrow.

//A bit narrower + modulating the frequency at the same time using a LFTri:
(
{BPF.ar(
	PinkNoise.ar,
	LFTri.ar(1/10, 0, 54.5, 76.5).midicps,
	0.01,
	0.5
)
}.play
)

//Example of the Band Reject Filter: the "hole" (with a RQ of 0.5) is moved thoughout the spectrum by the LFTri that is modulating the frequency:
(
{BRF.ar(
	PinkNoise.ar,
	LFTri.ar(1/10, 0, 54.5, 54.5 + 22).midicps,
	0.5,
	0.3
)
}.play
)

//Renonant Filters: RHPF, Resonz, RLPF. Resonz is perhaps the most effective one:

{RHPF.ar(PinkNoise.ar, 1000, 0.01, 0.5)}.play //The cut-off frequency resonates. As the RQ is lower (narrower bandwidth), the frequency is more noticeable within the noise. The amplitude has to be risen when lowering the RQ.

//Here including a frequency modulation:
(
{RHPF.ar(
	PinkNoise.ar,
	LFTri.ar(1, 0, 8000, 8020),
	0.1,
	0.5
)
}.play
)

//Ringz Filter: also a resonant filter, including decay time instead of RQ. WARNING: when working with Ringz, the amplitude of each frequency that is mainained is accumulated until the decay is over. The higher the decay time, the lower the amplitude needs to be (do not mix up with the higher amplitude needed by filters featuring RQ):

{ Ringz.ar(Impulse.ar(1), 440, 0.5, 0.3)}.play //As an example to see how the decay time works: the impulse resonates during 0.5 seconds.

{ Ringz.ar(WhiteNoise.ar(0.001), 440, 1)}.play //When filtering a noise, the frequencies accumulate. Thus, the mul has to be very low. Here decay of 1 second.

{ Ringz.ar(Impulse.ar(1), XLine.ar(440, 880, 10), 1, 0.3)}.play //XLine can be used to trace an exponential line regarding the value of a specific parameter (working well with frequencies and otherwise, Line can be used for linear lines). Here, it traces a cuadratic line between 440 and 880 hz in 10 seconds (it is not an envelope, thus, it does not repeat the process, but rather stays at the final pitch of the line).


//IGNORE THIS:
//Bonus code (so GitHub doesn't turn my file into markdown:

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

