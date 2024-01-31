//7.2 - EXTENSION CHAPTER ABOUT BUFFERS

/////////////////////////////////////////////////////////////////////
//(Here I include some methods related to buffers that I learnt recently and did not mention in the previous document. Also, some theory about how to upload and use a library of samples).

//A buffer is a language representation of a memory space (RAM) in the server. SuperCollider is great for sound synthesis because everything related to audio gets the maximum priority. But this also means that every process that does not involve sound synthesis is an asynchronous operation, and this includes loading a buffer.

//Method .readChannel for reading a channel (with the method .read, all channels are read, but with .readChannel, channels can be specified):
p = "C:/Users/SmallAngel/Desktop/THEORY CODES/Audio-for-granular-examples-2.wav" //Loading a sample (remember to change the path!).

//These are the arguments of .readChannel:
(
b = Buffer.readChannel(
	s, //Where to allocate the memory (the server).
	p, //Path (drag and drop).
	0, //Starting frame.
	-1, //Number of frames (frame = sample * channels). A stereo file has two times more frames than a mono file. When this argument is -1, the entire file will be read.
	channels: 0, //In a stereo or mono file: 0 = left. In a multichannel file: 0 = fisrt channel (if more channels, receives an array).
	action: { |b| b.postln }, //This action happens when the buffer has being loaded in the server. The argument is the buffer itself, so this can tell us if the file has been loaded (in case so much is going on in the computer that loading takes more time than expected).
	bufnum: 10 //Identifier of this buffer (conventionally counted from 10, but it does not matter).
)
)

b.play //To simply play the sample within the path (careful with the amplitude, we are not controlling it yet).
b.numFrames //Number of frames
b.duration //= number of frames / sampling rate.
b.numChannels //Because we selected channel 0, it says there is only 1 channel. For the stereo audio, you would need [0, 1]).
b.free //To free the buffer (can't be played again until it is read again, although, when read again, it retakes the audio file from where it was left: AHA! The synth is still running in the server, if you look at the node tree. So that is why. And when the audio file is finished, the synth is gone).

//The proper way to play a buffer, though, is through UGens (Buffer is not a UGen, but a clien-side representation of a server object) and there are several of them for that: in PlayBuf, arguments are numChannels, bufnum, rate (using the BufRateScale.kr tool to compensate possible sampling rate discrepancies), trigger, startPos, loop, and doneAction.
//This function is executed after reading the buffer (and the bufnum needs to match the one assigned by the Buffer object):
//(As we are using just function.play, it's okke to stop the sound with ctrl-period. That way we free the synth, but not the buffer. We'll free the buffer after all these examples using the same).
(
{
	PlayBuf.ar(
		1,
		b.bufnum,
		BufRateScale.kr(b.bufnum) * LFDNoise3.ar(1, 2, 1), //Modulating, for example between -1 and 3, each second. Sometimes, when playing backwards, the file has a long silence at the end, so it might happen that we need to wait (this can be solutioned by changing the startPos).
		loop: 1,
		doneAction: 0 //If the loop is 0 (no loop) and doneAction is 0, the synth will remain in there until we use ctrl-period. If the loop is 0 and we set doneAction 2, then the synth will be freed when the audio is finished.
	) * 0.5
}.play
)

//This can multichannel expand like a normal UGen:
(
{
	PlayBuf.ar(
		1,
		b.bufnum,
		BufRateScale.kr(b.bufnum) * [1, -1], //Here, for example, one channel goes forward and the other one, backwards (wait a bit for the backwards one with this specific sample...).
		loop: 1,
		doneAction: 0
	) * 0.5
}.play
)

//Let's look at the trigger argument:
(
{
	var freq, trigger;

	freq = [1, 1.1];
	trigger = Impulse.ar(freq);

	PlayBuf.ar(
		1,
		b.bufnum,
		BufRateScale.kr(b.bufnum) * 1,
		trigger, //With every trigger, coming back to the startPos (by default, to the beginning). Nice making loops. Can be multichannel expanded like this (creating here a displacement as there are two different frequencies for the trigger). There is a tiny click when jumping to the starting position if not using an envelope.
		2.5 * 44100, //Needed to adjust a bit the starting position for this specific sample.
		loop: 1,
		doneAction: 0
	) * 0.3
	* EnvGen.ar(Env([0, 1, 1, 0], (1/freq) * [0.01, 0.98, 0.01]), trigger) //Using an envelope to avoid the click when jumping (see explanation in the previous theory file).
}.play
)

//Splay: takes a multichannel signal and spreads it in the stereo field:
(
{
	Splay.ar(
		PlayBuf.ar(
			1,
			b.bufnum,
			BufRateScale.kr(b.bufnum) * (1..10).linlin(1, 10, 1.0, 2.0), //Using an array of 10 rates, and therefore, bringing about several signals (values from 1 to 2: could try with 0 to 1, or a different number of rates).
			loop: 1,
			doneAction: 0
		) //By default, the spread argument is 1, so there is maximum spread from -1 to 1 (and the distribution is not random, the channels go from left to right). Also, the level is compensated automatically depending on how many signals are sent.
	) * 0.5
}.play
)

//We can work now with the starting position, which is in number of frames (move around and find cool patterns!):
(
{ 	var bufnum = 10, freq, trigger;

	freq = [1, 1.1]; //Can also play around with other trigger frequencies and combinations.
	trigger = Impulse.ar(freq);

	PlayBuf.ar(
		1,
		b.bufnum,
		BufRateScale.kr(b.bufnum) * MouseY.kr(-1, 1.0), //Controlling the rate with the mouse (vertically).
		trigger,
		BufFrames.kr(b.bufnum) * MouseX.kr(0, 1, 0, 1), //This is modulating it between 0 and 1 with MouseX (* 0, it would be the beginning of the piece, which is 0, and * 1, it would be the complete number of frames of the file, so that's why we use that range (maybe easier than calcularing the number of seconds and then multiplying by the sampling rate? Yes, certainly, working with the duration of the file as a 0 to 1 ratio).
		loop: 1,
		doneAction: 0
	) * 0.3
	* EnvGen.ar(Env([0, 1, 1, 0], (1/freq) * [0.02, 0.96, 0.02]), trigger) //This time, this envelope does not seem to suffice to get rid of the clicks, I think it is because of the change of position. Need to think about a solution.
}.play
)

b.free //We can finally free the buffer.

/////////////////////////////////////////////////////////////////////
//LOADING LIBRARIES OF SAMPLES
//(advanced, in connection to the creation of algorithmic routines and granulators, for instance):

//Loading a library of samples (it will be adapted to any library no matter the number of samples):
a = []; //Here is the empty array where the samples will be located. Call the index of "a" from the code through which you want to control the samples.
p = PathName.new("folder path"); //Folder with multiple sound files: new path name for each.

//This is how we load the samples in the empty array:
(
p.entries.do{ //It will repeat the function as many times as elements are in the folder whose path is assigned to "p".
	arg path, i; //Arg "path" is each sample of the folder (each element), and "i" is the number of the iteration (index).

	a = a.add( //The array in "a" is filled up with each sample.
		Buffer.readChannel(
			s,
			path.fullPath, //Path of each audio file.
			bufnum: i, //Different bufnum for each sample using the index argument.
			channels: 0

		)
	);
}
)

//Using non-declared variables: the previous code would be implemented as follows:
(
~folder = [];
~path = PathName.new("C:/Users/SmallAngel/Desktop/THEORY CODES/ugly_percussion_library/group2"); //Random path (drag your folder of samples here)
~path.entries.do({ arg path, i; ~folder = ~folder.add(Buffer.readChannel(s, path.fullPath, bufnum: i)) })
//~folder.size //Testing the size of the folder (number of samples).
)


//Another option, a bit shorter because collect generates the array instead of needing to create an empty one, as when using .do:
PathName.new("C:/Users/SmallAngel/Desktop/THEORY CODES/ugly_percussion_library/group2").entries.collect({ |paths, i| Buffer.readChannel(s, paths.fullPath, bufnum: i, channels: 0) })

(
{
	var bufnum = 0;

	bufnum = MouseX.kr(0, 8).floor; //Changing with the mouse from one sample to another from the library (should be adjusted to the size of the folder: number of samples). Floor is turning the values into integers.

	PlayBuf.ar(
		1, //This number needs to be changed when using stereo files.
		bufnum,
		BufRateScale.kr(bufnum),
		Impulse.kr([1, 1.1]), //Multichannel expansion here, bringing about a signal on each side.
		loop: 1,
		doneAction: 0
	)
}.play
)

(
{
	var bufnum = 0;

	bufnum = PulseCount.kr(Impulse.kr(1), Impulse.kr(1/9)); //The PulseCount object allows to go through the samples of the library with each trigger (the first Impulse). The second impulse resets the count after 9 impulses (so after counting up to the nine numbufs we have). Again, adjust to the size of the folder. Cool.

	PlayBuf.ar(
		1,
		bufnum,
		BufRateScale.kr(bufnum), //The rate could be multiplied by 2.pow(semitones / 12) or semitones.midiratio to be measured in specific intervals.
		Impulse.kr([1, 1.1]),
		loop: 1,
		doneAction: 0
	)
}.play
)


//Talking about the space all of this takes in the memory (which shouldn't be much, but a large sample library or long files will take some): it is recommended to free the buffers. These are commands to free buffers (all of them). Anyway, the proper practice is to free each buffer by using .free:
s.cachedBuffersDo({ |buf| buf.postln }); //To see all buffers.
s.cachedBuffersDo({ |buf| buf.free }); //To free all buffers.

//Adding the action (printing) just to see how fast the buffers are loaded in the library:
PathName.new("C:/Users/SmallAngel/Desktop/THEORY CODES/ugly_percussion_library/group2").entries.collect({ |paths, i| Buffer.readChannel(s, paths.fullPath, bufnum: i + 1, channels: 0, action: { |b| b.postln }) })


//Further application example (using Pbind):
//Let's use this instrument:
(
SynthDef(\playermono, {
	arg bufnum = 0, rate = 1, t_trig = 1, startPos = 0, amp = 1, pan = 0, gate = 1, attack = 0.0, release = 1, loop = 0, out = 0;

	var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, t_trig, BufFrames.kr(bufnum) * startPos, loop);
	var env = EnvGen.ar(Env.asr(attack, 1, release), gate, amp, doneAction: 2);

	Out.ar(out, Pan2.ar(sig, pan, env * amp))
}).add;
)

//Let's create a pattern:
(
Pdef(\a,
	Pbind(
		\instrument, \playermono,
		\amp, 0.5,
		\release, 1,
		\dur, Pn(Pshuf([0.5, 0.5, 0.5, Rest(0.5), Rest(0.5)], 1), inf),
		\startPos, 0,
		\bufnum, Pseq((1..9), inf).trace,
		\loop, 1,
		\rate, 1
	)
).play
)

Pdef(\a).clear
s.cachedBuffersDo({ |buf| buf.free });


//Yet another option: using dictionaries (and, in this case, two different folders with samples):
(
d = Dictionary.new; //Creating a dictionary.
//Associating each path with a key (\folder1 and \folder2):
d.add(\folder1 -> PathName("C:/Users/SmallAngel/Desktop/THEORY CODES/ugly_percussion_library/group1").entries.collect({ |sample| Buffer.read(s, sample.fullPath) }));
d.add(\folder2 -> PathName("C:/Users/SmallAngel/Desktop/THEORY CODES/ugly_percussion_library/group2").entries.collect({ |sample| Buffer.read(s, sample.fullPath) })); //We can load as many folder as we want by adding more keys.
)

d[\folder1].choose.play //Now we can easily play random samples from the \folder1 key within the dictionary "d".
d[\folder2].choose.play //Same with the other key.

//Simple SynthDef to control those samples:
(
SynthDef(\library, {
	|buf = 0, rate = 1, amp = 0.1|
	var signal;

	signal = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, doneAction: 2); //We can add doneAction 2 as last argument of PlayBuf.
	signal = signal * amp;

	Out.ar(0, signal)
}).add
)

Synth(\library, [\buf, (d[\folder1] ++ d[\folder1]).choose.bufnum]) //So, just to check it works, the buf is the bufnum, so we calculate the bufnum of a randomly chosen sample from both libraries (concatenated arrays).

//See, by the end of theory file 13, how this last way of loading libraries of samples could be implemented (using Pbind as well).


/////////////////////////////////////////////////////////////////////
//Another UGen that plays Buffers: BufRd, a buf reader. While PlayBuf goes always on, BufRd stays and moves when needed. It features an inner engine to move the buffer, the "phase" argument. The classic way to control this argument is to use a phasor (but anything at audio rate should work):

//Loading something (default SC sample):
Buffer.readChannel(s, Platform.resourceDir +/+ "sounds" +/+ "a11wlk01-44_1.aiff", 0, -1, 0, bufnum: 10);

{ BufRd.ar(1, 10, Phasor.ar(0, BufRateScale.kr(10) * 1, 0, BufFrames.kr(10)), 1).dup(2) * 0.2 }.play //This way, the file is played as it is: Phasor is counting from 0 to the end of the bufnum 10. See the Help file and read about the phase argument.

{ BufRd.ar(1, 10, K2A.ar(MouseX.kr(0, BufFrames.kr(10))), 1).dup(2) * 0.2 }.play //Using MouseX now to control the position, but need to be turned into audio rate. Try other signals at audio rate to control the phase.
