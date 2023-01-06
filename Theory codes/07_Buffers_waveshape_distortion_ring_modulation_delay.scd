//7 - BUFFERS, WAVESHAPE DISTORTION, RING MODULATION AND DECAY
///////////////////////////////////////////////////////////////////

//BUFFERS:
//Something very basic, but important, to bear in mind is that SuperCollider does not read MP3 files. Use .aiff or .wav or, for compressed audio (lossless), .flac. Now, regarding Buffer: a buffer is usually used to contain sampled audio (audio files), but it can be used to contain other types of data. It is an array of floats running in the audio server. We need to boot the Buffer in order to create the space in the memory, then the audio is copied in that space so it can be read. Each buffer is identified with a number, "bufnum", which is automatically assigned by the server (it can also be assigned by us).

//Buffer.read: regarding the arguments, the first one is the server in use, which in SC can be reached through the variable "s". Then, we need to copy the path of the audio file as a string (dragging the file into the space of the second argument), the "startFrame" is the frame (see equivalences below) from which the audio will be read, and the "numFrames", the number of frames that will be read (by default it will read the entire audio and this argument is only useful when the file is really long), "action" can include a function to be evaluated when the file has been read, and bufnum is the identifier of the buffer (which is better set by default the servers).

//We normally assign the buffer to a variable, so that we can ask that variable some information about the buffer (about the file contained in the buffer):
a = Buffer.read(s, "C:/Program Files/SuperCollider-3.10.3/sounds/a11wlk01.wav") //This is a SC default sound (it might have a different path in each computer).
a.numChannels //Asking its number of channels.
a.bufnum //Asking its bufnum.
a.query //All information about the buffer will be printed in the postwindow (bufnum, numFrames, numChannels and sampleRate).
a.play //To simply play the audio.
{PlayBuf.ar(a.numChannels, a.bufnum)}.play //Playing the buffer (this UGen will be studied later on) and modifying parameters.

//There is an alternative way to indicate the path of the audio files, but it only works if the audios are located in the same drive (in C, in case of using PC). This technique is called "standardizePath" and it is useful to work on the same project from different computers. This following line searches in the SC resources folder, which contain the SC default audios (really ugly, but useful to work with the same audio with all students in the class). This is the equivalent to the path written above:

p = Platform.resourceDir +/+ "sounds/a11wlk01.wav" //Path.
b = Buffer.read(s, p) //Reading the file.
{PlayBuf.ar(b.num.Channels, b.bufnum)}.play //Playing the file from the buffer.

//Regarding the frame and the equivalence to duration in seconds:
b.numFrames / b.sampleRate //The duration in seconds is equal to the number of frames divided by the sample rate.
b.duration //There is already a method which executes that operation and gives the number of seconds directly (though it is good to bear in mind where this value is coming from, how it is calculated).

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//PLAYBUF
//PlayBuf is used for reading audio files located into buffers (using, for example, Buffer.read before). As Buffer.read can't be located inside a SynthDef, but we can use PlayBuf to read it from inside the SynthDef. The arguments:

PlayBuf.ar(numChannels, bufnum, rate, trigger, startPos, loop, doneAction) //numChannels (number of channels, which is important to know because within a SynthDef the number of channels has to be fixed as the size of the arrays cannot be modified), bufnum (it is advisable to ask the buffer about it rather than giving a number ourselves. That way, it is guaranteed that the number won't repeat in other bufnums), rate (1 = original, 0.5 = half of the original and an octave lower, 2 = doubled the original and an octave higher, -1 = original rate, but inverted reading, and everything in between and beyond), trigger (triggers the following argument), startPos (when the previous argument causes a trigger, the audio will come back to the position set as starting position --> startPos is calculated in frames --> to calculate it in seconds, the number of seconds should be multiplied by the sampling rate, 44100), loop (loops to audio file: 1 = loop on, 0 = loop off), doneAction (normally using doneAction = 2 to kill the synth when the audio file is done).

//When the sampling rate of the audio is different than the sampling rate of the buffer (which is 44100 by default), the rate read by PlayBuf can be misleading. The following UGen can be used in the rate argument in order to compensate different sampling rates (but this is normally not needed):

rate * BufRateScale.kr(bufnum)

//EXAMPLES:

c = Buffer.read(s, "C:/Program Files/SuperCollider-3.10.3/sounds/a11wlk01.wav") //Let's use this one as a base for all our examples (it has to be evaluated in order to use the codes below):

//Using PlayBuf within a function (just to illustrate the arguments as variables):
(
{
	var numChannels, bufnum;

	numChannels = c.numChannels;
	bufnum = c.bufnum;

	PlayBuf.ar(numChannels, bufnum)

}.play
)

//CHANGING THE RATE: When lowering the rate, the higher frequencies are lost (if the maximum was 22050 Hz, half of the sampling rate, now the maximum is 11025 Hz) --> The solution for this would be raising the sampling rate (it is one of the reasons for doing so: reproducing sounds at a lower rate and conserving all the requencies). When raising the rate, on the contrary side, we can obtain aliasing because frequencies over 22050 will fold down to the audible spectrum (rate = 2, double speed and 8ve higher, 4 = two 8ves higher, etc.). Lastly, try to use negative rates, so the audio is inverted:
(
{
	var numChannels, bufnum, rate;

	numChannels = c.numChannels;
	bufnum = c.bufnum;
	rate = 0.5; //Half of the speed and an 8ve lower (0.25 = two 8ves lower / 0.125 = three 8ves lower / etc.)

	PlayBuf.ar(numChannels, bufnum, rate, loop: 1) //Using the loop.

}.play
)

//Modifying parameters with the mouse. Here the rate:
(
{
	var numChannels, bufnum, rate;

	numChannels = c.numChannels;
	bufnum = c.bufnum;
	rate = MouseX.kr(1/8, 8).poll; //Position of the mouse from left to right.

	PlayBuf.ar(numChannels, bufnum, rate, loop: 1)

}.play
)

//Controlling the trigger and start position: remember that the start position is the number of seconds (in the audio) * 44100 (sampling rate). For calculating the mid point of the audio, we can use "c.numFrames / 2" in the startPos argument. Be aware of the clicks: if the jump from one point to another that is not = 0 will produce a sudden amplitude change = click: see next example for the use of an envelope to avoid this:
(
{
	var numChannels, bufnum, rate, trigger, startPos;

	numChannels = c.numChannels;
	bufnum = c.bufnum;
	rate = 1;
	trigger = Impulse.ar(1); //Jumping to the startPos each second.
	startPos = 0; //If the startPos was the first second of the audio --> startPost = 1 * 44100.

	PlayBuf.ar(numChannels, bufnum, rate, trigger, startPos, loop: 1)

}.play
)

//Using an envelope to avoid clicks: multiplying the envelope by PlayBuf. The envelope shares the trigger with the PlayBuf, and the duration of the envelope is equal to the inversion of the frequency of the trigger (1/freq = seconds of duration, although here is 1/1 = 1). Then the 1 second envelope is multiplied by [0.01, 0.98, 0.01], giving three times, a 1% of fade in, a 98% of sustain, and a 1% of fade out. This will avoid clicks:
(
{
	var numChannels, bufnum, rate, trigger, startPos, freq;

	numChannels = c.numChannels;
	bufnum = c.bufnum;
	rate = 1;
	freq = 1; //One trigger per second.
	trigger = Impulse.ar(freq);
	startPos = c.numFrames /2; //The startPos is the mid point of the audio.

	PlayBuf.ar(numChannels, bufnum, rate, trigger, startPos, loop: 1)

	*

	EnvGen.ar(
		Env([0, 1, 1, 0], (1/freq) * [0.01, 0.98, 0.01]), trigger
	)

}.play
)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//WAVESHAPE DISTORTION
//The timbre of a sounds greatly depends on the waveshape of that sound. Distortion is, the vast majority of the times, nonlinear. This means that the relationship between the input and the output is nonlinear: the output amplitude is not strictly proportional to the input amplitude. As a consequence, the output waveshape is not the same as the input waveshape. The output waveshape includes frequency components that were not in the input waveshape.
//Distortion can be complemented by other processes so it does not have to be, for example, noisy (it can work alongside a filter, for example). It is very useful for expanding the spectrum of a sound.

//We can use methods such as clip2, wrap2 and fold2: they are sent an argument which indicates the amplitude value from which the signal will be affected by the distortion: they avoid that the information of the waveshape beyond that value is included within the distortion limits, creating the distortion:

//Clip2: this one is the smoothest and the best-working (for me):

{ SinOsc.ar(440, 0, MouseX.kr(0.01, 10, \exponential).poll).clip2(0.5)}.scope //It will cut information from the SinOsc waveshap from 0.5 amplitude value.

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav"); //Using again the default sound from SC library.
{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(0.01, 10, \exponential).poll).clip2(0.5) }.scope //Observe the distortion now applied to the buffer.

//Fold2: what is beyond the limit imposed by the method (here 0.5) is folded or "bounced" within the limits:

{ SinOsc.ar(440, 0, MouseX.kr(0.01, 10, \exponential).poll).fold2(0.5)}.scope //Same example. It is much harsher than clip2:

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav")
{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(0.01, 10, \exponential).poll).fold2(0.5) }.scope

//Wrap2: the harshest. What exceds the limit of the distortion is copied below the spectrum. The jump is too big a too sudden:

{ SinOsc.ar(440, 0, MouseX.kr(0.01, 10, \exponential).poll).wrap2(0.5)}.scope

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");
{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(0.01, 10, \exponential).poll).wrap2(0.5) }.scope

//We can use these methods applied to numbers (for algorithmic processes, for example). Study the differences between these:

1.1.clip2(1.0) //Clip2 simply cuts the number within the limit (1.0)
1.1.fold2(1.0) //Fold2 cuts the exceding amount and substract it to the limit (0.9)
1.1.wrap2(1.0) //Wrap2 cuts the amount beyond the limit, substracts it and inverts it to the negative spectrum (-0.9)

//ROUND:
//Another alternative to distort a sound: it rounds the amplitude values of a signal, creating little steps in the waveshape as if was losing definition (as with the number of bits and resolution of digital sound. The waveshape loses its continuity and the distortion (akin in timbre to a digital distortion) appears:

{ SinOsc.ar(440, 0, 0.5).round(MouseX.kr(0.0, 1.0)) }.scope


//.tanh, .softclip, .distort:
//From the harshest to the softest, these methods add different types of distortion to a signal. In order to use them, the amplitude of the UGen (the signal) has to be risen beyond 1 (for example, to 10), and then the method will modify the waveshape maintaining the signal between -1 and 1 (it is recommendable to lower the distorted signal a bit more using a factor, such as the 0.5 at the end of the functions in the following examples):

b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav");

{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(1, 100, \exponential)).tanh * 0.5 }.scope

{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(1, 100, \exponential)).softclip * 0.5 }.scope

{ (PlayBuf.ar(1, b, loop: 1) * MouseX.kr(1, 100, \exponential)).distort * 0.5 }.scope

//The following graphical representations show the differences in the waveshape with each method:

{[\tanh, \softclip, \distort ].collect{|method| Line.ar(0, 10, 0.1).perform(method) }}.plot(0.1)

//Same representation, using a sine wave here with an amplitude from 1 to 10 and each distortion method:

{[\tanh, \softclip, \distort ].collect{|method| SinOsc.ar(100, 0, Line.kr(1, 10, 0.1)).perform(method) }}.plot(0.1)


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//OVERSAMPLING DISTORTION

//This kind of distortion is digital and generaly applied to a sample (an audio within a buffer). It avoids taking the information from all frames of such an audio, thus some information is lacking (we can choose how much).

Latch.ar //This UGen is used to practice oversampling distortion.

//Example of how Latch works: here the noise by itself would take random values from 0 and 16000, 44100 times per second. But Latch is here limitating the information, in this case it only allows the noise to take 1 value per second (according to the freq of the impulse trigger). This is a distortion of the noise because it is losing information and altering its timbre:
(
{
	SinOsc.ar(
		Latch.ar(
			WhiteNoise.ar(8000, 8000), Impulse.ar(1) //Dust is also possible.
		),
		0,
		0.1
	)
}.play
)

//Let's try with an actual sample:
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav")

(
{
	Latch.ar(
		PlayBuf.ar(b.numChannels, b.bufnum, loop: 1),
		Impulse.ar(16000) //Here we take 16000 frames out of its 44100 by default. The smaller the number, the harsher the distortion. Solo 16000 muestras. Test it with lower numbers such as 12000, 8000, 2000, etc.
	)
}.play
)

//This is an example suggested in the help browser (be aware of Blip, it can be really loud, BEHOLD BLIP):
//Latch is being applied to the frequency of Blip to generate random patterns (but this is more like a "visual" example):
(
{
	Blip.ar(
		Latch.ar(
			WhiteNoise.ar,
			Impulse.ar(9) //Nine values per second: random freqs from the WhiteNoise spectrum (which is the entire spectrum).
		) * 400 + 500, //Multiplied by the mul 400, and applied an add (addition) of 500, we obtain the freq range 100 to 900 Hz (see the function below to get this).
		4, //This is the number of harmonics (1 = sine wave, and it keeps adding up to the timbre you wish): The higher, the narrower, thin and "squared" the sound.
		0.2)
}.play
)

{ Blip.ar(LFNoise0.kr(9, 400, 500), 4, 0.2) }.play; //This would be a faster way to perform the function above.


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//RING MODULATION

//The ring modulation is a type of amplitude modulation in which the fundamental frequency disappears.

//In this first example we'll hear 207-88 Hz and 207+88 Hz, but none of the written freqs:
(
{
	SinOsc.ar(207) * SinOsc.ar(88) //The amplitude modulation is practice just multiplying the signals.
}.play
)

//Equivalent to the former code is to put the "modulating" signal into the "carrier" signal's mul argument:
(
{
	SinOsc.ar(207, 0, SinOsc.ar(88)) //Exact same result.
}.play
)

//Equivalent to the two former codes, directly adding the two resultant frequencies (295 and 119 Hz)
(
{
	SinOsc.ar(295) + SinOsc.ar(119) * 0.5 //There is no arithmetic operation priority in SuperCollider: the arithmetic operations are culculated from left to right, so the addition will go first, and the product will apply to its result (here we are directly adding signals, so the amplitude has to be compensated (1 + 1 * 0.5 = 1)
}.play
)

//When the amplitude modulation is practiced above 20 Hz, the modulation of the amplitude will produce an audible result, which will turn into a spectrum modulation (which is the normal use of this kind of modulation). Be aware of the resulting frequencies in order not to go below or above the audible spectrum so there is not aliasing in this latter case. This is also a good strategy to obtain new material out of the material we already have --> practicing the modulation between two of those materials.

//AMPLITUDE MODULATION
//If the depth of the modulation is 0 to 1 (the depth of the ring modulation is, on the other hand, -1 to 1), then we obtain an amplitude modulation (AM), which conserves the fundamental frequency [(carrier + modulating) + (carrier - modulating) + carrier].

(
{
	SinOsc.ar(207) * SinOsc.ar(88, 0, 0.5, 0.5) //Mul and add are adapted to the amplitude is kept from 0 to 1.
}.play
)

//Other examples (normally, the result is something mid way from what you had, a monster mixture):

{ BrownNoise.ar(0.3) * SinOsc.ar(LFDNoise3.ar(1, 2000, 2000))}.play //A BrownNoise is modulated by a SinOsc whose freq is, at the same time, modulated by an LFDNoise.

{ BrownNoise.ar(0.3 !2) * SinOsc.ar(500)}.play //Fixed freq in the modulating signal: 500 = very noise filter. But try out with 100, 50, 20, 10, to actually perceive the beats.

{Saw.ar(200) * LFDNoise3.ar(200 !2, 0.3)}.play //Two complex signals here. The duplicator !2 is located within the parenthesis of the random signal, so the randomness is different through each channel (and the sound is richer).

//Ring modulation using a sample:
b = Buffer.read(s, Platform.resourceDir +/+ "sounds/a11wlk01.wav") //Reminder of the same buffer throughout this document.

{ PlayBuf.ar(b.numChannels, b.bufnum, loop: 1) * SinOsc.ar(MouseX.kr(20, 14000, \exponential).poll) }.play //Try out different values using the mouse (the freqs will be printed in the postwindow). Be aware of the aliasing produced by the highest frequencies (and at 20 Hz we can hear the fragmentation at real time).

//From the former code, we can control here the balance between the original and the modulated signal:
(
{
	var signal, mod;

	signal = PlayBuf.ar(b.numChannels, b.bufnum, loop: 1);

	mod = SinOsc.ar(MouseX.kr(20, 14000, \exponential).poll); //If the mul and add of this SinOsc is set to 0.5 and 0.5, we will obtain amplitude modulation.

	(senal + (senal * mod * 0.5)) //Here the original signal is added to the modulated signal, but lowering the amplitude of the latter one.

}.play
)

//Methods to practice ring modulation: they directly contain the following mixes of signals:

ring1: //(a * b) + a
ring2: //(a * b) + a + b
ring3: //a * a * b
ring4: //(a * a * b) - (a * b * b)

//Applying these methods is equivalent to multiplying one signal by the other (and balancing the mixture) + be aware of the amplitude of each signal!
(
{
	SinOsc.ar(207) ring1: SinOsc.ar(88) * 0.5
}.play
)

(
{
	SinOsc.ar(207) ring2: SinOsc.ar(88) * 0.25
}.play
)

//Other examples: it will depend a lot on the signals we use, the resultant timbre or effect of each method. It is better to try out everything:
{ BrownNoise.ar(0.3) ring3: SinOsc.ar(LFDNoise3.ar(1, 2000, 2000), 0, 0.3)}.play

{ BrownNoise.ar(0.3) ring4: SinOsc.ar(LFDNoise3.ar(1, 2000, 2000), 0, 0.3)}.play

{SinOsc.ar(7000, 0, 0.1) ring4: SinOsc.ar(LFDNoise3.ar(3, 125, 7000), 0, 0.1) !2}.play

//"ring1, 2, or 3" is a method, but since it represents a product between two UGens, it also runs at 44100 Hz, turning into a UGen itself. When the method is applied to, for instance, numbers (for example, for algorithmic procedures), then it is not a UGen.

////////////////////////////////////////////////////////////////////////////////////////////
//DECAY LINES (just introduction)

//A decay line generates an exponential envelope with a certain duration. It is especially useful to enhance the beginning of sounds, as we'll see in some examples:
//The Decay acts as an envelope for the mul argument of the BrownNoise here. Delay generates an envelope each time the trigger is activated. Then. the second argument is the decay time in seconds:

{ BrownNoise.ar * Decay.ar(Impulse.ar(0.5), 1, 0.3)}.play

//A back of Ringz filters (three frequencies) is modulated (ring modulation) by a WhiteNoise, whose amplitude is defined by a Decay line. There is a common trigger for both signals (the Impulse), so both signals happen at the same time, being the WhiteNoise kind of the "attack" for the Ringz filters thank to the ring modulation. The sound is pretty realistic:
(
{
	var impulso;

	impulso = Impulse.ar(0.5); //One impulse (trigger) every two seconds.
	{
		Mix(
			Ringz.ar(
				impulso,
				[52, 7000, 14550], [3, 0.3, 2], //The Ringz filter has three frequencies and three decay times (so there are three filters mixed to a single channel (Mix) and then the whole modulation is duplicated (!2).
				0.4
			)
		)

		ring1:

		WhiteNoise.ar(Decay.ar(impulso, 0.04)) //If I try just with a product of the two signals, the fundamental is not heard, but ring1 adds the fundamental again.
	} !2
}.scope //Look at the graph
)

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//USING LIBRARIES (advance + in connection to the creation of algorithmic routines and granulators, for instance):

//To load a library of samples (it will be adapted to any library no matter the number of samples):

a = []; //Here is the array where the samples will be. Call the index of "a" from the code you want to control the samples through.
p = PathName.new("folder path"); //Folder with multiple sounds.
(
p.entries.do{
	arg path, i; //arg path is each sample of the folder, and "i" is the number of the iteration.

	a = a.add(
		Buffer.readChannel(
			s,
			path.fullPath,
			bufnum: i,
			channels: 0

	));
}
)

//Using global variables: then, the implementation would be suing the variable ~folder[ rrand(range of the number of samples in the folder) ] within the loop of the routine in order to choose among the samples of the folder.

(
~folder = [];
~path = PathName.new("F:/DOCUMENTOS/1 SIBELIUS 2021-22/Media and Sonic Arts/Old definitive work/Factory sounds library");
~path.entries.do({arg path, i; ~folder = ~folder.add(Buffer.readChannel(s, path.fullPath, bufnum: i));});
//~folder.size //For the size ( = 10 ).
)


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
