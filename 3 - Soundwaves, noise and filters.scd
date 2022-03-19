//3 - WAVE SHAPES, NOISE AND FILTERS:
///////////////////////////////////////////

//WAVE SHAPES:

//TRIANGLE WAVE: LFTri is a non-band-limited triangle oscillator. This means that the signal is not limited (filtered).  As we'll se with the square and sawtooth waves, there are both limited and non-limited versions, with different functions. All LF signals (Low Frequency) are prepared to be used in modulations rather than to produce sound. Its amplitude value oscillates between -1 and 1. The arguments are the same as in a SinOsc (the phase in here is iPhase or "initial phase").

{ LFTri.ar(440, 0, 0.5)}.plot(1/440) //Graph of the wave.
{ LFTri.ar(440, 0, 0.5)}.scope //Graph of the signal AND sound.

//We can build a triangular wave out of a sum of sine waves. Their frequency has to be multiplied by the odd numbers (odd overtones), from 1 to as many as we need (the more overtones we add, the more defined the triangular wave is). Then, the amplitude of each overtone will be calculated as the inverted power of two (square) of the overtone number:

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
	SinOsc.ar (freq * 25, 0, 1/25.squared) //The more overtones, the more definition (we will learn later on a more efficient way to do this).
	*
	0.5 //General amplitude of the total sum of signals (when adding signals, their amplitude is also added, therefore we have to control the total amplitude in order to maintain it between 0 and 1 (and preferably below 1).
}.scope
)

//SQUARE WAVE: in the case of the square wave, we have two versions of it: LFPulse is the non-band-limited pulse oscillator, mainly used for modulations. The filtered version is Pulse, better for producing sound because it reduces the possibility of aliasing. The filtered version, Pulse, does not have the iPhase argument (because it is not used for modulations). If the non-filtered version is used for sound, it can produce aliasing when modulated. Aliasing sounds are interesting (akin to old radios trying to syntonize a frequency), but can also sound too evident as aliasing. The square wave is the only one which does not oscillate below amplitude 0 (it produces the pulses from 0 to 1, or any other value used for a modulation). This has to be taken into consideration when calculating the mul and add for a modulation. The 3rd argument in LFPulse (or 2nd in Pulse) is the "width", the percentage of the wave that is at 0 and at 1, usign a ratio between 0 and 1 (0.5 is the default, same percentage at 0 and at 1. If we use 0.8, there is more percentage at 1. If we use 0.2, there is more percentage at 0), this is especially useful when modulating with a square wave.

{ Pulse.ar(440, 0.5, 0.5) }.scope //Filtered version (signal and sound). The filtered version has no phase argument.
{ LFPulse.ar(440, 0, 0.5, 0.5) }.scope //Non filtered version (careful with sound, produces aliasing).
{ LFPulse.ar(440, 0, 0.5, 0.5) }.plot(2/440) //Graph (two cycles).

//A square wave can also be built out of a sum of sine waves. In this case, the odd overtones are also used, but the amplitude of each is only the inverted number of the overtone:

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

{Pulse.ar(MouseX.kr(20, 22050, \exponential).poll, 0.5, 0.125) }.scope //Moving the mouse from left to right, we increase the frequency. Thanks to the filtering, all overtones frequencies go up or down at the same time.
{LFPulse.ar(MouseX.kr(20, 22050, \exponential).poll, 0.5, 0.125) }.scope //Here, using the non-filtered version, we can hear the aliasing: some overtones go up, some go down (especially regarding the higher frequencies).

//Modulating with a Square wave (in this case, amplitude modulation): pulsation effect:

{ SinOsc.ar(440) * LFPulse.ar(1) }.play //The square wave turns on and off the signal, like a switch.

//SAWTOOTH WAVE: we find the same two options: Saw is the band-limited sawtooth generator, used to produce sound; then, LFSaw is the non-band-limited sawtooth generator, used for modulations. As in Pulse, Saw does not feature a phase argument because it is not used for modulations. The amplitude oscillates between -1 and 1.

{ Saw.ar(440, 0.5, 0.5) }.scope //Filtered version. No phase argument (graph and sound).
{ LFSaw.ar(440, 0, 0.5, 0.5) }.scope //Non-filtered version. The sound produces aliasing.
{ LFSaw.ar(440, 0, 0.5, 0.5) }.plot(2/440) //Graph.

//We can build a sawtooth wave out of a sum of sine waves. In this case, we add all even and odd overtones, and the amplitude of each will be the inverted of the overtone number, as in the pulse wave:

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
	SinOsc.ar (freq * 14, 0, 1/14)//... roughly 50 sine waves bring about a decent sawtooth wave.
	*
	0.5 //General amplitude for the total addition.
}.scope
)

//Modulating with a sawtooth (frequency modulation of a sine wave):

{ SinOsc.ar(LFSaw.ar(1, 0, 400, 1000), 0, 0.3)}.play //The frequency goes down suddenly and comes up progressively again (following the waveshape of the saw).

//Remember that the aliasing is also avioded raising the sample rate (over the 44100 Hz set by default).

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//LOW FREQUENCY NOISE GENERATORS:

//LFDNoise0, 1 and 3 are UGens used to modulate. They are low frequency noise generators. The number in thir names corresponds to their interpolation (how the lines between the random values produced by the generator are traced: 0 = no interpolation / 1 = linear interpolation (straight lines) / 3 = cubic interpolation (curved lines). They have three arguments: frequency (freq = 10, for instance, will produce 10 random values per second; freq = 1/10 will produce 1 value each 1 seconds / mul and add (calculate those for the specific modulation values).

//Some examples:

{ LFDNoise0.ar(440, 0.3, 0)}.play //LFNoise is not prepared to produce sound, but this is the noise generator at audio rate (440 Hz).

a = { SinOsc.ar(LFDNoise0.ar(10, 500, 1000), 0, 0.3) }.play //Applied to a sinewave's frequency, produces 10 random values per second, between 500 and 1500 Hz. There is no interpolation, so the signal jumps to each new frequency.


{ LFDNoise1.ar(440, 0.3, 0) }.play //Different interpolation, different sound quality of the pure noise (again, not prepared for sound), as if LPF was applied.

a = { SinOsc.ar(LFDNoise1.ar(10, 500, 1000), 0, 0.3) }.play //Linear interpolation: now the pitches are connected by sort of a glissando.

a = { SinOsc.ar(LFDNoise1.ar(10, 24, 60).midicps, 0, 0.3) }.play //Using notes in midi (equal temperament) within four octaves.


{ LFDNoise3.ar(880, 0.3, 0) }.play //Last type of interpolation, higher frequencies even more cut (higher frequency so we can hear).

a = { SinOsc.ar(LFDNoise3.ar(10, 500, 1000), 0, 0.3) }.play //Frequency modulation using cubic interpolation: more accute glissando between freqs.

{ SinOsc.ar(LFDNoise3.ar(10, 12, 60).midicps, 0, max(LFDNoise3.ar(3), 0))}.play //Usign LFNoise to modulate the frequency + using another LFDNoise to modulate the amplitude, applying the method "max" to keep only the values above 0 (thus, it produces silence when the signal goes below 0. Applying the method "min", it would keep only what is below zero on the contrary).

//Amplitude modulation using LFDNoise (keeping constant freq so the changes can be easily percieved):

{ SinOsc.ar(5000, 0, LFDNoise0.ar(10, 0.3, 0.3))}.play


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//CONTROL OF PARAMETERS WITH THE MOUSE:

//We can control parameters using MouseX.kr (horizontally), MouseY.kr (vertically) or MouseButton.kr (pressing the mouse buttom). We usually use control rate (.kr) with these UGens which does not produce signals but they control already existent signals (the mouse is by no means going to be moved at 44100 Hz of sample rate, hence we don't need the audio rate).
//Some examples:

{SinOsc.ar(MouseX.kr(20, 16000, \exponential).poll, 0, 0.1)}.play //Same would be using MouseY. Controlling the frequency. The wrap argument is the type of interpolation netween frequencies (\exponential is the most natural one. Other option is \linear. This influences the distribution of the frequencies on the space of the screen. This is why the exponential is the best option when working with frequencies, whose distribution is exponential). The lag argument is the time used for moving from one value to the next one.

{SinOsc.ar(MouseButton.kr(500, 1000), 0, 0.5) }.play //Not pressing = minVal / Pressing = maxVal (minVal and maxVals are the arguments). The lag argument is the time used for going to one frequency to the next (no wrap argument due to the pulse nature of this UGen).

//NOTE FOR MYSELF----> It is good to work with frequency in MIDI (and convert with .midicps) and with amplitude usedin dB (and convert with .dbamp), in order to be conscious of the real values we are working with.

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//NOISE GENERATORS:

//The noise generators are used to produce sound, especially as the sound souce for filtering. They only have mul and add as arguments. We can use four main noise generators, from the brightest to the darkest:

FreqScope.new //Evaluate this to analize (visualize) the frequencies when trying the following noise generators.

{ClipNoise.ar(0.3)}.play //The brightest one as it chooses values from the extremes of the frequency (the high freqs tend to be perceived as more intense). At 44100 Hz of sample rate, the UGen chooses 44100 random values per second, which produces the noise sound.

{WhiteNoise.ar(0.3)}.play //A bit less bright, all the freqs have the same probability to be chosen, but we tend to perceive the higher ones as more intense still.

{PinkNoise.ar(0.3)}.play //It is perceived as plain sound (all freqs same probability), but indeed its spectrum falls 3dB of per octave (a 25% of the amplitude).

{BrownNoise.ar(0.3)}.play //The brown noise is also known as brownian noise or random walk noise, is the darkest one. There is no abrupt jumps between frequencies and the spectrum falls 6 dB per octave (a 50% of the amplitude).

//Examples of modulation using noise generators:

{SinOsc.ar(ClipNoise.ar(1980, 2000), 0, 0.3)}.play //The frequency is still changes at a very fast pace, so the resultant sound is closer to noise than to a sine.
{SinOsc.ar(WhiteNoise.ar(1980, 2000), 0, 0.3)}.play //A bit more centered.
{SinOsc.ar(PinkNoise.ar(8000, 8000), 0, 0.3)}.play  //Using a higher frequence.
{SinOsc.ar(PinkNoise.ar(54.5, 76.5).midicps, 0, 0.3)}.play //Between 22 and 131 midi.
{SinOsc.ar(BrownNoise.ar(1980, 2000), 0, 0.3)}.play //Last, trying the brown noise.
{SinOsc.ar(BrownNoise.ar(54.5, 76.5).midicps, 0, 0.3)}.play //Or using midi.

//Amplitude modulations using noises also modulate the value 44100 times per second, producing a hybrid noise (it is an alternative way of performing ring modulation, but we'll see this later on).

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//IMPULSE GENERATORS:

{Impulse.ar(1, 0, 0.5)}.play //Produces a click (a single value) per second. Its frequency is the number of impulses per second. The amplitude moves from 0 to 1, as in a square wave (thus, take into consideration that add = bottom limit, not the center).

{Dust.ar(10, 0.5)}.play //This is the random version of Impulse: with a freq = 10, it will produce 10 click per second, but randomly distributed throughout the second. The amplitude of each click is also random within the given range.

//Examples: if used for a modulation (instead of as a trigger, which is their main use), Dust or Impulse need some more duration, and ToggleFF is a good option for this (other option is the method "lad"):

{SinOsc.ar(440, 0, ToggleFF.ar(Dust.ar(3))) * 0.1}.play //Toggle is a switch so we can apply the Dust as a trigger to switch on and off the sine wave.

/////////////////////////////////////////////////////////////////////////////////////
//BUTTERWORTH FILTERS: HPF, LPF, BPF y BRF: when filtering a signal, the amplitude of its frequencies falls at a specific pace from a cut-off frequency onwards. It is not an abrupt cut, but a gradual one: in SuperCollider, these are 2nd order filters, which means that the freqs from the cut-off point, are going to fall 12 dB per octave.

//There are several types of filters:

//HPF (High Pass Filter) and LPF (Low Pass Filters): as arguments, there is the signal to be filtered (in), the cut-off freq, the mul and the add:
//Examples:

{HPF.ar(PinkNoise.ar, 1000, 0.1)}.play //Noise filter (1000 = cut-off frequency).

{HPF.ar(PinkNoise.ar, LFTri.ar(1/10, 0, 8000, 8020), 0.1)}.play //A triangular oscillator modulates the frequency of the filter. WARNING: be careful will very low or negative frequencies, they can create extremely loud noise artifacts.

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

{BPF.ar(PinkNoise.ar, 1000, 200/1000, 0.3)}.play //Calculated as bandwidth / cutOff Freq. Not so narrow.

//A bit narrower + modulating the frequency at the same time using a LFTri.
(
{BPF.ar(
	PinkNoise.ar,
	LFTri.ar(1/10, 0, 54.5, 76.5).midicps,
	0.01,
	0.5

)
}.play
)

//Example of the Band Reject Filter: the "hole" (with a RQ of 0.5) is moved thoughout the spectrum by the LFTri that is modulating the frequency:s
(
{BRF.ar(
	PinkNoise.ar,
	LFTri.ar(1/10, 0, 54.5, 54.5 + 22).midicps,
	0.5,
	0.3

)
}.play
)

//Renonant Filters: RHPF, Resonz, RLPF (the latter one including the RQ argument). The best one to use is Resonz.

{RHPF.ar(PinkNoise.ar, 1000, 0.01, 0.5)}.play //The cut-off frequency resonates. As the RQ is lower (narrower bandwidth), the frequency is more noticeable within the noise). The amplitude has to be risen when lowering the RQ.

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

//Ringz Filter: also a resonant filter, including decay time instead of RQ. WARNING: when working with Ringz, the amplitudes of each frequency that is mainained are accumulated until the decay is produced. The higher the decay time, the lower the volume!!

{ Ringz.ar(Impulse.ar(1), 440, 0.5, 0.3)}.play //As an example to see how the decay time works: the impulse resonates during 0.5 seconds.

{ Ringz.ar(WhiteNoise.ar(0.001), 440, 1)}.play //When filtering a noise, the frequencies accumulate. Thus, the mul has to be very low. Here decay of 1 second. s

{ Ringz.ar(Impulse.ar(1), XLine.ar(440, 880, 10), 1, 0.3)}.play //XLine can be used to trace a line regarding the value of a specific parameter. Here, it traces a cuadratic line between 440 and 880 hz in 10 seconds (it is not an envelope, thus, it does not repeat the process, but rather stays at the final pitch of the line).

