//7 - BUFFERS, WAVESHAPE DISTORTION, AM, FM AND DECAY

/////////////////////////////////////////////////////////////////////
//BUFFERS

//Buffers are ordered arrays of floats and serve to store data in the server. Their most common use is to either write or read sound files, but any sort of data that can be represented as floats can be stored in a buffer (for example, they are also commonly use for wavetable synthesis). Like busses, the number of available buffers is set before the server is booted (by default, the available number of global sample buffers is 1024. The real-time memory allocated to the server for synths and UGens such as delays, also set before booting the server, is separated from the memory used for buffers). Before buffers can be used, we need to allocate memory to them, which is an asynchronous step (at booting time, all buffers have a size of 0). Like busses, buffers are represented by integers starting from 0 (and which are automatically assigned by the server when using the Buffer object): when calling .free on a buffer object (Buffer), it will release the buffer's memory in the server, and free the buffer number for future reallocation.

//Something very basic, but important, is to bear in mind that SuperCollider does not read MP3 files. Use .aiff or .wav for uncompressed audio, or .flac for compressed (lossless) audio.

//Buffer.read: reads a sound file disk into memory. Regarding the arguments, the first one is the server in use, which in SC can be reached through the variable "s". Then, we need to copy the path of the audio file as a string (dragging the file into the space of the second argument is enough), the "startFrame" is the frame (see equivalences below) from which the audio will be read, and the "numFrames", the number of frames that will be read (by default it will read the entire audio), "action" can include a function to be evaluated when the file has been read, and "bufnum" is the identifier of the buffer (which is better set by default).

//We normally assign the buffer to a variable:
a = Buffer.read(s, "C:/Program Files/SuperCollider-3.10.3/sounds/a11wlk01.wav") //This is a SC default sound (it might have a different path in each computer).
a.numChannels //Asking its number of channels.
a.bufnum //Asking its bufnum.
a.query //Several parameters of the audio file will be printed on the postwindow (bufnum, numFrames, numChannels and sampleRate).
a.play //To simply play the audio.
a.free //Proper way to free the buffer (instead of ctrl-period).
{ PlayBuf.ar(a.numChannels, a.bufnum) }.play //Plays the sample contained in the buffer back and allows to adjust some parameters.

//There is an alternative way to indicate the path of the audio files, but it only works if the audios are located in the same drive (in C, in case of using PC). This technique is called "standardizePath" and it is useful to work on the same project from different computers. This following line searches in the SC resources folder, which contain the SC default audios (really ugly, but useful to work with the same audio with all students at class). This is the equivalent to the path written above:

p = Platform.resourceDir +/+ "sounds/a11wlk01.wav" //Path.
b = Buffer.read(s, p) //Reading the file.
{ PlayBuf.ar(b.numChannels, b.bufnum) }.play //Playing the file from the buffer.

//Regarding the relationship between number of frames, duration in seconds, and sampling rate:
5 * b.sampleRate //The number of frames is equal to the duration in seconds multiplied by the sampling rate.
b.numFrames / b.sampleRate //The duration in seconds is equal to the number of frames divided by the sample rate.
b.duration //There is already a method which executes the former operation and gives the number of seconds directly (though it is good to bear in mind where this value comes from, how it is calculated).
b.free


/////////////////////////////////////////////////////////////////////
//PLAYBUF

//Let's delve into this object with more detail: PlayBuf is used for reading audio files allocated into buffers (using, for example, Buffer.read before). The arguments:
PlayBuf.ar(numChannels, bufnum, rate, trigger, startPos, loop, doneAction) //numChannels (number of channels, which is important to know because within a SynthDef the number of channels has to be fixed as the size of the arrays cannot be modified), bufnum (it is advisable to ask the buffer about it rather than giving a number ourselves. That way, it is guaranteed that the number won't repeat if reading from other buffers), rate (1 = original, 0.5 = half pace and an octave lower, 2 = double pace and an octave higher, -1 = original rate, but inverted reading, and everything in between and beyond), trigger (triggers the following argument), startPos (when the previous argument provides with a trigger, the audio will come back to the position set as starting position --> startPos is calculated in frames --> to calculate it in seconds, the number of seconds should be multiplied by the sampling rate, 44100 by default), loop (loops to audio file: 1 = loop on, 0 = loop off), doneAction (see options in "Done" help file --> "Actions": https://doc.sccode.org/Classes/Done.html).

//When the sampling rate of the audio is different than the sampling rate in SuperCollider (which is 44100 by default), the rate read by PlayBuf can be misleading. The following UGen can be used in the rate argument in order to compensate different sampling rates (but this is normally not needed):
rate * BufRateScale.kr(bufnum)

//Examples:
c = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav") //Let's use this one as a base for all our examples (it has to be evaluated in order to use the codes below):

//Using PlayBuf within a function (just to illustrate the arguments as variables):
(
{
	var numChannels, bufnum;

	numChannels = c.numChannels;
	bufnum = c.bufnum;

	PlayBuf.ar(numChannels, bufnum)

}.play
)
c.free //Freeing the buffer in "c" --> Then, if running the previous code again, the program will complain because there is nothing in "c". Run the buffer again and continue with the examples. The synth created by function.play is still running in the server. Let's use ctrl-period for the following examples:

//Playing around with the rate: When lowering the rate, the higher frequencies are lost (for example, if the maximum was 22050 Hz - half of the sampling rate -, when lowering the rate to half, now the maximum is 11025 Hz) --> The solution for this would be to increase the sampling rate (it is one of the reasons for doing so: reproducing sounds at a lower rate while keeping all the spectrum of audible frequencies, as frequencies that where above it might be now within it). When increasing the rate, on the contrary, we may obtain aliasing because frequencies over 22050 will fold back to the audible spectrum, being the solution the same for this phenomenon. Lastly, negative rates reproduce the audio file backwards keeping the same behavior as positive rates otherwise:
(
{
	var numChannels, bufnum, rate;

	numChannels = c.numChannels;
	bufnum = c.bufnum;
	rate = 0.5; //Half of the speed and an 8ve lower (0.25 = two 8ves lower / 0.125 = three 8ves lower / etc. and vice-versa)

	PlayBuf.ar(numChannels, bufnum, rate, loop: 1) //Using the loop.

}.play
)

//Modifying parameters with the mouse:
(
{
	var numChannels, bufnum, rate;

	numChannels = c.numChannels;
	bufnum = c.bufnum;
	rate = MouseX.kr(1/8, 8).poll; //Modifying the rate with the mouse movement from left to right, from rate = 0.125 to 8.

	PlayBuf.ar(numChannels, bufnum, rate, loop: 1)

}.play
)

//Controlling the trigger and startPos: remember that the starting position is the number of seconds (within the audio file) * 44100 (sampling rate) = number of frames. For calculating the mid point of the audio, we can use "c.numFrames / 2" in the startPos argument. Be aware of the clicks due to sudden amplitude changes (see next example for the use of an envelope to avoid them):
(
{
	var numChannels, bufnum, rate, trigger, startPos;

	numChannels = c.numChannels;
	bufnum = c.bufnum;
	rate = 1;
	trigger = Impulse.ar(1); //Jumping to the startPos each second (there is a little click, see next code for a solution).
	startPos = 0; //If the startPos was the first second of the audio file --> startPost = 1 * 44100 (for instance).

	PlayBuf.ar(numChannels, bufnum, rate, trigger, startPos, loop: 1)

}.play
)

//Using an envelope to avoid clicks: multiplying PlayBuf by an envelope. The envelope shares the trigger with PlayBuf, and the duration of the envelope is equal to the inversion of the frequency of the trigger (1/freq = seconds of duration, although here is 1/1 = 1). Then the duration of the envelope is multiplied by [0.01, 0.98, 0.01], giving three times, a 1% of fade in, a 98% of sustain, and a 1% of fade out:
(
{
	var numChannels, bufnum, rate, trigger, startPos, freq;

	numChannels = c.numChannels;
	bufnum = c.bufnum;
	rate = 1;
	freq = 1; //One trigger per second.
	trigger = Impulse.ar(freq);
	startPos = c.numFrames /2; //The startPos is the mid point of the audio file.

	PlayBuf.ar(numChannels, bufnum, rate, trigger, startPos, loop: 1)

	*

	EnvGen.ar(
		Env([0, 1, 1, 0], (1/freq) * [0.01, 0.98, 0.01]), trigger
	)

}.play
)

c.free //Now we can free the buffer in "c" (remember to use ctrl-period to free the function.play synth tho!).


/////////////////////////////////////////////////////////////////////
//WAVESHAPE DISTORTION

//The timbre of a sound depends greatly on its waveshape. Distortion is the alteration of the waveshape of a signal, and it is usually nonlinear. In non-linear distortion, the relationship between the input and output is nonlinear: the amplitude of the output is not strictly proportional to the input's amplitude, bringing about new frequency components in the output signal. Linear distortion is an alteration of amplitude or phase that doesn't produce new frequency components, but what we understand as "distortion" refers mainly to non-linear distortion, that is to say, the alteration of not only the waveshape but also the spectrum of a signal.
//Distortion can be complemented by other processes so it does not have to be, for example, noisy (it can work alongside a filter, for instance). It is very useful for expanding the spectrum of a sound.

//We can use methods such as clip2, wrap2 and fold2: they accept an argument which indicates the amplitude value from which the signal will be affected by the distortion (the smaller this value, the sooner the signal will be affected while increasing its amplitude from 0). They basically modify the amplitude limit from which the distortion will be produced and specify what happens to that excess of amplitude:
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav") //Let's use the previous sample for all following examples.

//Clip2: this one is the smoothest (and most used) out of these methods:

{ SinOsc.ar(440, 0, MouseX.kr(0.01, 10, \exponential).poll).clip2(0.5) }.scope //It will cut information from the SinOsc waveshape from 0.5 amplitude value.
{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(0.01, 10, \exponential).poll).clip2(0.5) }.scope //Observe the distortion, now applied to the buffer.

//Fold2: what is beyond the limit imposed by the method (here 0.5) is folded or "bounced" within the limits:

{ SinOsc.ar(440, 0, MouseX.kr(0.01, 10, \exponential).poll).fold2(0.5) }.scope //Same example. It is more aggressive than clip2:
{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(0.01, 10, \exponential).poll).fold2(0.5) }.scope

//Wrap2: the harshest. What exceds the limit of the distortion is folded and wrapped into the negative spectrum. The jump is too big a too sudden (careful with the volume!):

{ SinOsc.ar(440, 0, MouseX.kr(0.01, 10, \exponential).poll).wrap2(0.5) }.scope
{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(0.01, 10, \exponential).poll).wrap2(0.5) }.scope

b.free

//We can use these methods applied to numbers (for algorithmic operations, for example). Study the differences between the three:
1.1.clip2(1.0) //Clip2 simply cuts the number within the limit (1.0)
1.1.fold2(1.0) //Fold2 cuts the exceding amount and substracts it to the limit (0.9)
1.1.wrap2(1.0) //Wrap2 cuts the amount beyond the limit, substracts it and wraps the result into the negative spectrum (-0.9)


//ROUND:
//Another alternative to distort a signal is to round the amplitude of its samples, creating little steps in the waveshape as if it was losing definition. This is, therefore, closer to digital distortion (because of the loss of continuity in the waveshape or decrease of the number of bits):

{ SinOsc.ar(440, 0, 0.5).round(MouseX.kr(0.0, 1.0)) }.scope //Visualization.


//.tanh, .softclip, .distort:
//From the harshest to the softest, these methods add different types of distortion to a signal. In order to use them, the amplitude of the signal has to be risen beyond 1 (for example, to 10), and then the method will modify the waveshape maintaining the signal between -1 and 1 (it is advisable to lower the distorted signal a bit more using a factor, such as the 0.5 at the end of these functions in the following examples):

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(1, 100, \exponential)).tanh * 0.5 }.scope

{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(1, 100, \exponential)).softclip * 0.5 }.scope

{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(1, 100, \exponential)).distort * 0.5 }.scope

b.free

//The following graphical representations show the differences in the waveshape with each method:

{[\tanh, \softclip, \distort].collect{ |method| Line.ar(0, 10, 0.1).perform(method) }}.plot(0.1) //The method .performs just send a specific method (expressed as a symbol) to its receiver (the Line in here).

//Same representation, using a sine wave here with an amplitude from 1 to 10 and each distortion method applied:

{[\tanh, \softclip, \distort].collect{ |method| SinOsc.ar(100, 0, Line.kr(1, 10, 0.1)).perform(method) }}.plot(0.1)


/////////////////////////////////////////////////////////////////////
//OVERSAMPLING DISTORTION

//This kind of distortion is digital and generaly applied to a sample (an audio file within a buffer, for instance). It hinders the lecture of the information in all frames of the audio files. As some information is lacking, the distortion is produced. We can choose how much information we read (and therefore, how much we lose):

Latch.ar //This UGen is used for oversampling distortion.

//Example of how Latch works: here the noise by itself would take random values from 0 and 16000, 44100 times per second. But Latch is here hindering this process, in this case allowing the noise to take only 1 value per second (this is shown in the frequency of the impulse working as a trigger). The noise is distorted because of the loss of information and alteration of its timbre in consequence:
(
{
	SinOsc.ar(
		Latch.ar(
			WhiteNoise.ar(8000, 8000), Impulse.ar(1) //Dust is also possible as a trigger, for instance.
		),
		0,
		0.1
	)
}.play
)

//Let's try with an actual audio sample:
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav")
b.sampleRate

(
{
	Latch.ar(
		PlayBuf.ar(b.numChannels, b.bufnum, loop: 1), //The input is an audio signal read at 44100 Hz of sampling rate.
		Impulse.ar(16000) //Here we take 16000 frames out of its 44100. The smaller the number of frames, the harsher the distortion. Test it with lower numbers such as 12000, 8000, 2000, etc.
	)
}.play
)

//This is an example suggested in the help browser (be aware of Blip, it can be really loud, BEHOLD BLIP):
//Latch is being applied to the frequency of Blip to generate random patterns (this example is the same as our first example of Latch applied to a noise within the freq of a SinOsc: it is being used as a modulating signal for the frequency of Blip):
(
{
	Blip.ar(
		Latch.ar(
			WhiteNoise.ar,
			Impulse.ar(9) //Nine values per second (the range is applied by hand to Lacth: multiplying by 400 and setting the center at + 500, so 100-900 Hz).
		) * 400 + 500, //These are basically the mul and add values to keep the frequency between 100 and 900 Hz. The Latch modulation for the freq of Blip could have being performed easily as shown below this function (could be clearer to look at such example, but it does not involve Latch).
		4, //This is the number of harmonics of Blip (1 = sine wave, and it keeps adding up to the desired timbre): the higher this value, the narrower, thin and "squared" the sound.
		0.2)
}.play
)

{ Blip.ar(LFNoise0.kr(9, 400, 500), 4, 0.2) }.play; //This would be a shorter way to write the function above (same exact result).


///////////////////////////////////////////////////////////////////////
//MODULATIONS (Ring, AM, FM)

//When modulating a signal at over 20 Hz of frequency, in opposition to LFOs, a new frequency spectrum starts to be perceivable out of this periodicity.

//Ring modulation:
//Ring modulation is a kind of amplitude modulation in which the fundamental frequency disappears. The modulation is performed by multiplying two signals or placing the modulating signal in the mul argument of the carrier signal:
{ SinOsc.ar(440) !2 * SinOsc.ar(220) * 0.1}.play //We don't hear 440 nor 220, but the subtraction and addition of both (440 + 220 and 440 - 220).

//Amplitude modulation (AM):
//Whereas the "depth" of the ring modulation is -1 to 1 (regarding the mul/add arguments of the modulating signal), the depth of the amplitude modulation should be 0 to 1 in order to keep the fundamental frequency audible:
{ SinOsc.ar(440) !2 * SinOsc.ar(220, 0, 0.5, 0.5) * 0.1 }.play //We hear (car + mod) + (car - mod) + car, as the mul/add arguments of the modulating signal are adjusted to the range 0-1.

//Other examples (ring modulation):
{ BrownNoise.ar(0.1 !2) * SinOsc.ar(5000) }.play //Try out 100, 50, 20, 10 for the SinOsc frequency to see what is happening.
{ BrownNoise.ar(0.1) * SinOsc.ar(LFDNoise3.ar(1, 975, 1025)) }.play //Random value from 50 to 2000 (try with LFDNoise0).
{ Saw.ar(200) * LFDNoise3.ar(50 !2, 0.1) }.play //Using an LDFNoise with frequency over 20 Hz (try with freq = 10 to see what is happening).
{ Saw.ar(2000) * LFDNoise3.ar(200 !2, 0.1) }.play //A different combination of frequencies for the previous line.

//Ring modulation applied to an audio sample (ugly default SC audio sample):
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav") //Loading an audio file into a buffer.

{ PlayBuf.ar(b.numChannels, b.bufnum, loop: 1) * SinOsc.ar(MouseX.kr(20, 14000, \exponential).poll) !2 * 0.2 }.play //Applying ring modulation to the recording using a sine oscillator, and controlling the frequency using the horizontal movement of the mouse (range of frequencies from 20 to 14000 Hz).

//Same example, creating our own mix at the end:
(
{ var signal, mod;

	signal = PlayBuf.ar(b.numChannels, b.bufnum, loop: 1);

	mod = SinOsc.ar(MouseX.kr(20, 14000, \exponential).poll) !2;

	signal + (signal * mod * 0.5) * 0.2 //car + (car * mod * 0.5) * masterVolume.

}.play
)

//Ring modulation methods: these methods represent operations between two signals (operations that, therefore, run at audio rate as well):
ring1: //(a * b) + a
ring2: //(a * b) + a + b
ring3: //a * a * b
ring4: //(a * a * b) - (a * b * b)

//Examples (they respond very differently depending on the signals they receive):
{ SinOsc.ar(440) ring1: SinOsc.ar(220) !2 * 0.1 }.play //Equivalent to our first example of AM.

{ SinOsc.ar(440) ring2: SinOsc.ar(220) !2 * 0.1 }.play

{ BrownNoise.ar(0.5) ring3: SinOsc.ar(LFDNoise3.ar(1, 1500, 2000), 0, 0.3 !2) }.play

{ BrownNoise.ar(0.5) ring4: SinOsc.ar(LFDNoise3.ar(1, 1500, 2000), 0, 0.3 !2) }.play

{ SinOsc.ar(7000, 0, 0.2) ring4: SinOsc.ar(LFDNoise3.ar(3, 125, 7000), 0, 0.3 !2) }.play

//Frequency modulation (FM):
//Frequency modulation consists of adding a signal to the frequency of another signal.
//More info in these two tutorials:
//https://www.youtube.com/watch?v=UoXMUQIqFk4&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=22
//https://www.youtube.com/watch?v=dLMSR2Kjq6Y&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=23

{ SinOsc.ar(500 + SinOsc.ar(1)) * 0.1 !2 }.scope //No perceptible difference, but slight movement from left to right in the oscilloscope, meaning that the carrier signal is oscillating (in fact from 499 to 500 Hz every second).
{ SinOsc.ar(500 + SinOsc.ar(1, 0, 20)) * 0.1 !2 }.scope //Oscillation between 480 and 520 Hz every second (mul of modulating signal = range of freq modulation by adding and subtracting to the carrier's frequency).
{ SinOsc.ar(500 + SinOsc.ar(8, 0, 400)) * 0.1 !2 }.scope //Oscillation 8 times per second, between 100 and 900 Hz.
{ SinOsc.ar(500 + SinOsc.ar(22, 0, 400)) * 0.1 !2 }.scope //Crossing the 20 Hz limit = new frequency spectrum.
{ SinOsc.ar(500 + SinOsc.ar(80, 0, 400)) * 0.1 !2 }.scope //Fully new spectrum.
//By the way, equivalent to (using the add argument instead of literally adding to the frequency of the carrier):
{ SinOsc.ar(SinOsc.ar(80, 0, 400, 500)) * 0.1 !2 }.scope

//Example from first linked tutorial (to show a bunch of possible combinations of values): with MouseY, we change the carrier's freq (500-5000 Hz); with MouseX, we change the modulating's freq (1-2000 Hz); lastly, the modulating's mul, which is the range of frequency modulation, is controlled by a LFNoise0, which produces 8 random values per second.
{ SinOsc.ar((MouseY.kr(500, 5000, 1) + SinOsc.ar(MouseX.kr(1, 2000, 1), mul: LFNoise0.kr(8).range(400, 4500))).poll) * 0.1 !2 }.scope //Because of its ranges, this code could produce negative frequencies (see post window): negative frequencies mean we're asking an oscillator to produce its periodic shape in reverse (they don't exist in real life though, as time cannot go backwards, but in the digital domain, they translate into an inversion of the phase. In analog synthesis, a frequency of 0 means no voltage). Nonetheless, in many occasions, frequencies close to 0 or equal to 0 in some UGens might produce extremely loud artifacts, so it is necessary to be careful with crossing the 0.


///////////////////////////////////////////////////////////////////////
//DECAY LINES

//A decay line generates an exponential envelope with a certain duration triggered by impulses. Applied to certain sounds, it allows us to enhance the attack of those sounds:
{ BrownNoise.ar !2 * Decay.ar(Impulse.ar(0.5), 0.5, 0.2) }.play //Applied as an amplitude envelope for the BrownNoise. The arguments are the input (a trigger, in this case, an Impulse), the decay time, and the mul and add). The envelope is triggered every two seconds here.

//Further example, enhancing attacks:
(
{ var impulse;

	//The impulse acts as input of the filter and as trigger of the decay:
	impulse = Impulse.ar(0.5);

	//Three Ringz filters are created with a different frequency and decay time each, and mixed into a single channel:
	{ Mix(
		Ringz.ar(
			impulse,
			[52, 7000, 14550],
			[3, 0.3, 2],
			0.4
		)
	)

	ring1: //ring1: multiplies both signals and adds the filter to the mix.

	//Thanks to the common trigger, the WhiteNoise with the Decay envelope is applied to the attack of each filtered Impulse.
	WhiteNoise.ar(Decay.ar(impulse, 0.04))
	} !2 * 0.2

}.scope //Visualization.
)
