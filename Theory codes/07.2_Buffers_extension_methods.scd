//7.2 - EXTENSION CHAPTER ABOUT BUFFERS (some methods that I didn't mention in the previous document)
/////////////////////////////////////////////////////////////////////////////////////////////////////////

//A buffer is a language representation of a memory space (RAM) in the server. SuperCollider is great for sound synthesis because everything related to audio gets the maximum priority. But this also means that every process that does not involve sound synthesis is an asynchronous operation, and this includes loading a buffer.

//Method .readChannel for reading a channel (with the method .read, all channels are read, but with .readChannel, channels can be specified):
p = "F:/DOCUMENTOS/!VERANO 2023/SUPERCOLLIDER/THEORY CODES/Audio-for-granular-examples-2.wav" //Loading a sample (remember to change the path!).

//These are the arguments of .readChannel:
(
b = Buffer.readChannel(
	s, //Where to allocate the memory.
	p, //Path (drag and drop).
	0, //Starting frame.
	-1, //Number of frames (frame = sample * channels). A stereo file has two times more frames than a mono file. When this argument is -1, the entire sample will be read.
	channels: 0, //In a ttereo or mono file: 0 = left. In a multichannel file: 0 = fisrt channel (if more channels, receives an array).
	action: { |b| b.postln }, //This action happens when the buffer has being loaded in the server. The argument is the buffer itself, so this can tell us if the file has been loaded (in case so much is going on in the computer that loading takes more time than expected).
	bufnum: 10 //Identifier of this buffer (conventionally counted from 10, but it does not matter).
)
)

b.play //To simply play the sample within the path.
b.numFrames //Asking several questions to the buffer.
b.duration // = number of frames / sampling rate.
b.numChannels //If the audio was stereo, I guess with channels: 1 I am only getting the left channel (for stereo, would need [0, 1]).
b.free //To free the synth (can't be played again until it is read again).

//The proper way to play a buffer, though, is through UGens and there are several of them for that: in PlayBuf, arguments are numChannels, bufnum, rate (using the BufRateScale.kr tool to compensate possible sampling rate discrepancies), trigger, startPos, loop, and doneAction.
//This function is executed after reading the buffer (and the bufnum needs to match the one assigned by the Buffer object):
(
{
	PlayBuf.ar(
		1,
		b.bufnum,
		BufRateScale.kr(b.bufnum) * LFDNoise3.ar(1, 2, 1), //Modulating, for example between -1 and 1, each second. Sometimes, when playing backwards, the file has a long silence at the end, so it might happen that we need to wait (or stablish a startPos?).
		loop: 1,
		doneAction: 0 //Freeing the synth afterwards (not the buffer, right?). Should be 0 if looping, right?
	)
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
	)
}.play
)

//Let's look at the trigger argument:
(
{
	var bufnum = 10;

	PlayBuf.ar(
		1,
		b.bufnum,
		BufRateScale.kr(bufnum) * 1,
		Impulse.ar([1, 1.1]), //With every trigger, coming back to the startPos (by default, to the beginning). Nice for short loops if the file is short (something with percussion is best). Can be multichannel expanded like this (creating here a displacement as there are two different triggers).
		2.5 * 44100, //Needed to adjust a bit the starting position for this specific sample (though the issue of the clicks would need to be solved).
		loop: 1,
		doneAction: 0
	)
}.play
)

//Splay: takes a multichannel signal and spreads it in the stereo field:
(
{
	Splay.ar(
		PlayBuf.ar(
			1,
			b.bufnum,
			BufRateScale.kr(b.bufnum) * (1..10).linlin(1, 10, 1.0, 2.0), //Using an array of rates (1 to 2). Could try with 0 to 1, or with a different number of rates (now 10).
			loop: 1,
			doneAction: 0
		) //By default, the spread argument is 1, so there is maximum spread from -1 to 1 (and the distribution is not random, the channels go from left to right).
	)
}.play
)

//We can work now with the start position, which is in number of frames:
(
{
	PlayBuf.ar(
		1,
		b.bufnum,
		BufRateScale.kr(b.bufnum) * MouseY.kr(-1, 1.0),
		Impulse.ar([1, 1.1]), //Again, issue of the clicks still to be resolved.
		BufFrames.kr(b.bufnum) * MouseX.kr(0, 1, 0, 1), //This is modulating it between 0 and 1 with MouseX (* 0, it would be the beginning of the piece, which is 0, and * 1, it would be the complete number of frames of the file, so that's why we use that range (maybe easier than calcularing the number of seconds and then multiplying by the sampling rate? Yes, certainly, working with the duration of the file as a 0 to 1 ratio).
		loop: 1,
		doneAction: 0
	)
}.play
)


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Loading a library (some other techniques for loading libraries are included at the end of the theory file 13):

//A bit shorter version of my other examples in theory file 13 (I loaded here a library of short percussion samples):
PathName.new("F:/DOCUMENTOS/!VERANO 2023/SUPERCOLLIDER/THEORY CODES/ugly_percussion_library/group1").entries.collect({ |paths, i| Buffer.readChannel(s, paths.fullPath, bufnum: i, channels: 0) })

(
{
	var bufnum = 0;

	bufnum = MouseX.kr(0, 7).floor; //Changing with the mouse from one sample to another from the library (should be adjusted to the size of the folder: number of samples). Floor is turning the values into integers.

	PlayBuf.ar(
		1, //This number needs to be changed when using stereo files.
		bufnum,
		BufRateScale.kr(bufnum),
		Impulse.kr([1, 1.1]),
		loop: 1,
		doneAction: 0
	)
}.play
)

(
{
	var bufnum = 0;

	bufnum = PulseCount.kr(Impulse.kr(1), Impulse.kr(1/7)); //The pulsecount allows to go through the samples of the library with each trigger (the first Impulse). The second impulse resets the count after 7 impulses (so after counting up to the seven numbufs we have). Again, adjust to the size of the folder. Cool.

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


//Talking about the space all of this takes in the memory (which shouldn't be much but, a large sample library or long files will take some): it is recommended to free the buffers. These are commands to free buffers (all of them). Anyway, the proper practice is to free wach buffer by using .free:
s.cachedBuffersDo({ |buf| buf.postln }); //To see all buffers.
s.cachedBuffersDo({ |buf| buf.free }); //To free all buffers.


PathName.new("F:/DOCUMENTOS/!VERANO 2023/SUPERCOLLIDER/THEORY CODES/ugly_percussion_library/group2").entries.collect({ |paths, i| Buffer.readChannel(s, paths.fullPath, bufnum: i + 1, channels: 0, action: { |b| b.postln }) }) //Addint the action just to see how fast the buffers in the library are loaded.

//Let's use this instrument:
(
SynthDef(\playermono, {
	arg bufnum = 0, rate = 1, t_trig = 1, startPos = 0, amp = 1, pan = 0, gate = 1, attack = 0.0, release = 1, loop = 0, out = 0;

	var sig = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, t_trig, BufFrames.kr(bufnum) * startPos, loop);
	var env = EnvGen.ar(Env.asr(attack, 1, release), gate, amp, doneAction:2);

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


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//Another UGen that plays Buffers: BufRd, a buf reader. While PlayBuf goes always on, BufRd stays and moves when needed. It features an inner engine to move the buffer, the "phase" argument. The classic way to control this argument is to use a phasor (but anything at audio rate should work):

//Loading something (default SC sample):
Buffer.readChannel(s, Platform.resourceDir +/+ "sounds" +/+ "a11wlk01-44_1.aiff", 0, -1, 0, bufnum: 10);

{ BufRd.ar(1, 10, Phasor.ar(0, BufRateScale.kr(10) * 1, 0, BufFrames.kr(10)), 1).dup(2) }.play //This way, the file is played as it is: Phasor is counting from 0 to the end of the bufnum 10. See the Help file and read about the phase argument.

{ BufRd.ar(1, 10, K2A.ar(MouseX.kr(0, BufFrames.kr(10))), 1).dup(2) }.play //Using MouseX now to control the position, but need to be turned into audio rate.

//Using now the library again:
PathName.new("F:/DOCUMENTOS/!VERANO 2023/SUPERCOLLIDER/THEORY CODES/ugly_percussion_library/group2").entries.collect({ |paths, i| Buffer.readChannel(s, paths.fullPath, bufnum: i + 1, channels: 0) })

//Modulating some parameters:
(
{
	var bufnum = 1;
	bufnum = LFDNoise3.kr(1, 9).floor; //Should be adjusted to the library size.

	BufRd.ar(1, bufnum, LPF.ar(PinkNoise.ar, MouseY.kr(20, 20000)).range(0, BufFrames.kr(bufnum)), 1).dup(2)
	//BufRd.ar(1, bufnum, LFDNoise3.ar(Array.rand(12, 0.75, 10.25)).range(0, BufFrames.kr(bufnum)), 1) //Multichannel option (12 channels), also using LFDNoise instead of MouseY and the LPF.

}.play
)
