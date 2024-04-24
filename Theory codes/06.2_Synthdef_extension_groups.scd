//6.2 - WORK WITH BUSSES AND GROUPS

/////////////////////////////////////////////////////////////////////
//This is an advanced extension for the SynthDef theory file (6.1). Two strategies will be studied in this chapter: passing single arguments of a synth through separate SynthDefs for modulation, and passing entire synths through a separate SynthDef for FX and DSP (processing).

//Just as a reminder:
sclang //Client, language: routines, patterns, tasks, maths, number crushing machine, musical calculator, booleans... (passes numbers).
scsynth //Server: sound synthesis, sampling rate... (passes signals).
superCollider IDE //The interface, what we "see", what we "write".


/////////////////////////////////////////////////////////////////////
//MAPPING ARGUMENTS THROUGH BUSSES
//The synthesis SynthDef goes still to Out 0, but some of its arguments pass through a private channel to be modulated before coming out:

//Modulating the amplitude from the client side:
SynthDef(\inLFO, { |freq = 400, amp = 0.1| Out.ar(0, SinOsc.ar(freq, 0, amp) !2) }).add //Simple sine SynthDef with bus out = 0.
x = Synth(\inLFO) //Instance of the SynthDef.
x.set(\amp, 0.2) //Sending a new amplitude value while running on the server.
(var val = Array.series(11, 0.1, -0.01); { 11.do({ |i| x.set(\amp, val[i]); 1.wait }) }.fork) //Using a Routine (.fork) to assign new amplitude values progressively (but the change is discrete and not continuous), by taking the values from an array with each iteration: this is not efficient.
x.set(\amp, Line.kr(0, 1, 10)) //A Line can't be passed from the language side (client and server sides can't be mixed up). GIVES AN ERROR.
x.free //Freeing the synth.

//If we need another UGen to perform such a process, this means we need another SynthDef (for example, mapping the frequency):
SynthDef(\inLFO, { |freq = 400, amp = 0.1| Out.ar(0, SinOsc.ar(freq, 0, amp) !2) }).add //Same simple synthesis SynthDef.
SynthDef(\outLFO, { |chOut = 10, speed = 1, mul = 1, add = 0| Out.ar(chOut, LFDNoise0.ar(speed, mul, add)) }).add //Modulating SynthDef going out through a private channel (by default).
c = Bus.audio(s, 1) //Creating an audio bus (in the first available private channel, so that we don't need to assign the bus number).
y = Synth(\outLFO, [\chOut, c, \mul, 500, \add, 1000]) //Creating an instance of the modulator.
x = Synth(\inLFO) //Creating an instance of the synth to be modulated.
//x.set(\freq, 1000) //Changing its frequency value.
x.map(\freq, c) //Mapping the frequency argument to read from bus "c" (the argument could affect an entire group if needed): it will be controlled by the LFDNoise0.
y.set(\speed, 4) //Changing other parameters of the modulating synth.
x.free
y.free

//Let's try to map the amplitude now:
SynthDef(\inLFO, { |freq = 400, amp = 0.1| Out.ar(0, SinOsc.ar(freq, 0, amp) !2) }).add //Same synthesis SynthDef.
SynthDef(\fadeOut, { |chOut = 11, amp = 0.1, end = 0, dur = 5| Out.ar(chOut, Line.ar(amp, end, dur, doneAction: 2)) }).add //Fade out (modulating) SynthDef.
d = Bus.audio(s, 1) //Need a different bus if the frequency is passing through "c" (the previous one).
x = Synth(\inLFO) //Creating an instance of the synth to be modulated.
x.map(\amp, d) //Mapping the amplitude argument to read from bus "d" (of course, there is nothing in "d" yet: this can be solutioned by using control rate busses, as we will see in the next section).
z = Synth(\fadeOut, [\chOut, d, \amp, 0.1]) //Instance of the fade out SynthDef.
o = Synth(\fadeOut, [\chOut, d, \amp, 0, \end, 0.1]) //The synth in "z" is gone because of doneAction 2, so, in order to bring back the \inLFO synth, we need to create another instance of the fade out SynthDef (now as a fade in SynthDef). The synth "o" is also gone because of doneAction 2, so just need to free "x":
x.free


//Control VS audio rate busses:
SynthDef(\source, { |freq = 400, amp = 0.1| Out.ar(0, SinOsc.ar(freq, 0, amp) !2) }).add //Same synthesis SynthDef, called now "source".
e = Bus.control(s, 1) //Control bus.
e.set(200) //The main difference between audio and control busses is that a control bus can be set to a value.
x = Synth(\source) //Instance of the source SynthDef.
x.map(\freq, e) //When mapping the frequency argument to control bus "e", it receives the value set to the bus.
e.set(2000) //We can still change and move around the value hold by the control bus to which the frequency of synth "x" has been mapped to.
SynthDef(\lfo, { |chOut = 10, speed = 2, mul = 500, add = 1000| Out.kr(chOut, LFDNoise0.kr(speed, mul, add)) }).add //We can create another SynthDef for modulating the frequency. The UGens going through a control bus should run at control rate (LFDNoise0.kr AND Out.kr).
y = Synth(\lfo, [\chOut, e]) //Goes out through bus "e" (and runs according to its default parameters if nothing else is set).
y.set(\speed, 10, \mul, 1500, \add, 2500) //Changing the modulation parameters.
x.free
y.free //If freeing "y" first (the control SynthDef), the source SynthDef in "x" will hold still the last value given by the control SynthDef.

//Using groups:
SynthDef(\source, { |freq = 400, amp = 0.1| Out.ar(0, SinOsc.ar(freq, 0, amp) !2) }).add //Same source SynthDef.
g = Group(1, 1) //Creating a group: target and action = within which group (1 = default group) and at which position (1 = tail).
10.do({ Synth(\source, [\freq, rrand(1000, 2000), \amp, 0.01], g, 1)}) //Sending ten synth instances of the source SynthDef to the group "g".
g.set(\amp, 0) //Setting amplitude values for all synths in the group "g".
g.set(\amp, 0.1/10) //(careful with the amplitude compensation: this value goes to each synth).
f = Bus.control(s, 1) //Control bus for the amplitude.
f.set(0.05/10) //Setting the value of the control bus.
g.map(\amp, f) //Mapping the amplitude value to read from bus "f".
SynthDef(\fadeOut, { |chOut = 11, amp = 0.1, end = 0, dur = 5| Out.kr(chOut, Line.kr(amp, end, dur, doneAction: 2)) }).add //Same fade out SynthDef (AT CONTROL RATE).
y = Synth(\fadeOut, [\chOut, f, \amp, 0.1/10, \dur, 2]) //Turning off the entire group.
z = Synth(\fadeOut, [\chOut, f, \amp, 0, \end, 0.1/10, \dur, 6]) //Bringing it back (different instance because the one in "y" does not exist anymore thanks to doneAction 2. This synth "z" will also disappear when the line is done.
g.free //To turn everything off.

//Another example using both control and audio rate busses:
SynthDef(\source, { |freq = 400, amp = 0.1| Out.ar(0, SinOsc.ar(freq, 0, amp) !2) }).add //Source.
SynthDef(\fadeOut, { |chOut = 11, amp = 0.2, end = 0, dur = 5| Out.kr(chOut, Line.kr(amp, end, dur, doneAction: 2)) }).add //Control rate.
SynthDef(\lfo, { |chOut = 10, speed = 2, mul = 1, add = 0| Out.ar(chOut, { LFDNoise0.ar(speed, mul, add) }) }).add //Audio rate.

g = Group(1, 1) //Group.
10.do({ Synth(\source, [\freq, rrand(1000, 2000), \amp, 0.01], g, 1) }) //10 synths sent to the new group.
g.set(\amp, 0.01) //Can set any new value for the entire group.
c = Bus.control(s, 1) //Control bus for the amplitude.
c.set(0.01) //Can set it beforehand to the value of the group (here matching the same amplitude, so it does not changes when mapping, as it happened when using audio rate busses).
g.map(\amp, c) //Mapping the amplitude

y = Synth(\fadeOut, [\chOut, c, \amp, 0.01, \end, 0.0, \dur, 4]) //Turning off.
y = Synth(\fadeOut, [\chOut, c, \amp, 0.0, \end, 0.01, \dur, 10]) //Turning on ("y" is now a new instance, instead of changing the variable, just reassigning).

d = Bus.audio(s, 1) //Creating an audio rate bus for the frequencies.
z = Synth(\lfo, [\chOut, d, \mul, 1500, \add, 2500]) //Instance of the modulating synth for the frequency.
g.map(\freq, d) //Mapping the frequency to audio bus "d": the same frequency is applied to all synths at the same time. I guess a buss can only pass single values (if passed several values by creating 10 instances of the lfo Synth, they are summed up!) so that, if wanting to change the frequency of each synth, we would need a bus for each of them, THO: "The truth is that there aren't multichannel busses per se, but Bus objects are able to represent a series of busses with consecutive indices. They encapsulate several adjacent server-side busses into a single Bus object, allowing you to treat them as a group. This turns out to be rather handy" (from the tutorial: https://doc.sccode.org/Tutorials/Getting-Started/11-Busses.html). But in any case, we are not dealing with a multichannel signal here, but a single output of 10 Synths in a group.
z.set(\speed, 10) //Changing parameters of the modulation.
z.free //Freeing the modulating synth (the last random frequency stands still).
d.set(100) //Cannot set another value as the synth was freed (unlike in control busses): GIVES AN ERROR.
g.free //Freeing the entire group.


/////////////////////////////////////////////////////////////////////
//SIGNAL PROCESSING USING BUSSES AND GROUPS
//Passing entire synths through a FX SynthDef: the synthesis SynthDef does not go to Out 0, but to a private channel, and the FX SynthDef is the one being output through 0:
//(Btw, if ever needing to learn how to take audio from a mic and process it in SC, here is a very good tutorial on that: https://www.youtube.com/watch?v=3vu4UbS2NMw&list=PLPYzvS8A_rTaNDweXe6PX4CXSGq4iEWYC&index=21).

//Creating three different source SynthDefs (for a mic input, a sample input or a synth input):
(
//Mono input from a mic:
SynthDef(\sourceMic, {
	arg inChannel = 0,  outChannel = 0, ffreqHPF = 80, ffreqLPF = 20000, gain = 1, amp = 1, atck = 0.01, rel = 0.01;
	var input, imp;

	input = SoundIn.ar(inChannel) * gain; //Boosting the signal with a "gain" (microphone input). It is advisable to plug in some headphones before executing a SoundIn object, so that possible feedback is avoided.
	input = HPF.ar(input, ffreqHPF); //HPF and LPF to clean a bit the signal from the mic (almost covering all the audible spectrum by default).
	input = LPF.ar(input, ffreqLPF);

	imp = Impulse.kr(5); //This will be used in the analysis tools as follows:

	SendReply.kr(imp, '/envFollowerMic', Amplitude.kr(input, atck, rel)); //Amplitude follower for analysis (which could be used also to map values read from the input signal to control other parameters, for example, in the language). The frequency of the trigger (imp) will read that number of messages per second (it shouldn't go over 100 Hz because it wouldn't be realistic at control rate anymore). The arguments of SendReply are: trigger, command name, values to be sent (as OSC messages).

	SendReply.kr(imp, '/pitchFollowerMic', Pitch.kr(input, ampThreshold: 0.1)); //Pitch follower, similar indications as for the amplitude follower.

	Out.ar(outChannel, input * amp) //Like a master level.
}).add;

//Sample playback:
SynthDef(\sourceSample, {
	arg bufnum = 0, outChannel = 0, rate = 1, gain = 1, amp = 1, startPos = 0.0, loop = 1, atck = 0.01, rel = 0.01;
	var input, imp;

	input = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, 1, BufFrames.kr(bufnum) * startPos, loop) * gain; //Start position as 0-1 ratio.

	imp = Impulse.kr(5);

	SendReply.kr(imp, '/envFollowerSample', Amplitude.kr(input, atck, rel)); //Repeating the same analysis tools as in the previous SynthDef.
	SendReply.kr(imp, '/pitchFollowerSample', Pitch.kr(input, ampThreshold: 0.1));

	Out.ar(outChannel, input * amp)
}).add;

//Synthesizer (for whichever other signal, being another synth in SC or a synth from a different sound synthesis source, etc.):
SynthDef(\sourceSynth, {
	arg inChannel = 0,  outChannel = 0, ffreqHPF = 80, ffreqLPF = 20000, gain = 1, amp = 1, atck = 0.01, rel = 0.01;
	var input, imp;

	input = In.ar(inChannel) * gain; //This is the "inlet".
	input = HPF.ar(input, ffreqHPF);
	input = LPF.ar(input, ffreqLPF);

	imp = Impulse.kr(5);

	SendReply.kr(imp, '/envFollowerInline', Amplitude.kr(input, atck, rel));
	SendReply.kr(imp, '/pitchFollowerInline', Pitch.kr(input, ampThreshold: 0.1));

	Out.ar(outChannel, input * amp)
}).add
)


//TESTING INSTANCES OF EACH SYNTHDEF:
//The mic in (beware possible feedback):
x = Synth(\sourceMic, [\inChannel, 0, \amp, 0.1]) //"inChannel" needs to be 0 to catch whatever the mic of the laptop catches.
OSCdef(\print, { |msg, time| msg.postln }, \pitchFollowerMic) //Mapping the pitch values (last value of the OSC message).
OSCdef(\print, { |msg, time| msg.postln }, \envFollowerMic) //Mapping the amplitude values (also last value of the OSC message).
OSCdef(\print).clear //Stops the printing.
x.free //Frees the synth.

//The sample reader:
Buffer.readChannel(s, "C:/Users/SmallAngel/Desktop/THEORY CODES/Audio-for-granular-examples-2.wav", 0, -1, 0, { |b| b.normalize }, 10) //Loading a sound file, remember to change the path (numFrames = -1 will read the entire file, also adding the normalization action, though it might be not needed, and assigning the bufnum 10).
x = Synth(\sourceSample, [\bufnum, 10, \amp, 0.1])
OSCdef(\print, { |msg, time| msg.postln }, \pitchFollowerSample)
OSCdef(\print, { |msg, time| msg.postln }, \envFollowerSample)
OSCdef(\print).clear
x.free


//PROCESSORS (one by one):
//This one is for distortion. First, some experimentation with no sound:
{ SinOsc.ar(100).wrap(0.2, 2).tanh }.plot(0.1) //Wrap applied to a SinOsc. Parameters are lo and hi. Using tanh to limit the signal.
{ SinOsc.ar(100).fold(-0.5, 0.5) }.plot(0.1) //Fold is also used for distortion.
{ SinOsc.ar(100).wrap(-0.5, 0.5).tanh.fold(-1.0, 1) }.plot(0.1) //Combining them all.
{ SinOsc.ar(100, 0, 100).distort }.plot(0.1) //Needs an increased amplitude in the signal
{ SinOsc.ar(100, 0, 1).ring1(SinOsc.ar(100)) }.plot(0.1) //Using the ring modulation to distort (remember that distorting is simply modifying the waveshape).

(
SynthDef(\wavesmasher, {
	arg inChannel = 10, outChannel = 0, mursk = 0.75, mursk2 = 0.99, gain = 1, amp = 0.1;
	var input, imp;

	input = In.ar(inChannel) * gain;

	//I put the methods in a list for clarity (this crazy recipe is clearly not mine :D):
	input = input
	.wrap(mursk.neg, mursk)
	.tanh
	.fold((1 - mursk2.clip(0.0001, 0.9999)).neg, 1 - mursk2.clip(0.0001, 0.9999)); //We clip to a range and, as fold and wrap values need to be small to get greater distortion, we operate with 1 - that value, so that when going up in the range 0 - 1, it will distort more. So, mursk = 1, fully distort, and mursk = 0, no distort.

	Out.ar(outChannel, input * amp)
}).add
)

//This one is for delay:
(
SynthDef(\timesmasher, {
	arg inChannel = 10, outChannel = 0, gain = 1, amp = 0.1, speedChorus = 0.05, depthChorus = 0.1, predelayChorus = 0.08;
	var input, chorus, modulators, numDelays = 10;

	input = In.ar(inChannel) * gain;

	modulators = Array.fill(numDelays, { |i| LFPar.ar(speedChorus * Rand(0.94, 1.06), i * 0.1, depthChorus, predelayChorus) }); //Creating an array of different delay times for the DelayC in the chorus variable: the delay time is modulated by a LFPar, a low frequency parabolic oscillator. It's frequency is randomly deviated by the Rand Ugen, the phase is deviated for each delay time and the mul and add represent the range of the modulation: depth Chorus and predelayChorus = multiplicator and offset.
	chorus = DelayC.ar(input, 1, modulators);
	chorus = Splay.ar(chorus, LFTri.kr(0.1));

	Out.ar(outChannel, chorus * amp)
}).add
)

//This one will be a pitchshifter (keeping the same skeleton so that the input signal adapts to the processors):
(
SynthDef(\pitchsmasher, {
	arg inChannel = 10, outChannel = 0, gain = 1, amp = 0.1, pitch = 1, disp = 0, timeDisp = 0;
	var input, shifter;

	input = In.ar(inChannel) * gain;

	shifter = PitchShift.ar(input, 0.1, pitch, disp, timeDisp); //Premade pitchShifter, for a fast implementation (see theory file 12 for a handmade option).

	Out.ar(outChannel, shifter * amp)
}).add
)

//This one is for panoramics (for ambisonics):
(
SynthDef(\panoramics, {
	arg inChannel = 10, outChannel = 0, gain = 1, amp = 0.1, pos = 0;
	var input, processor;

	input = In.ar(inChannel) * gain;

	processor = PanAz.ar(12, input, pos); //The number of channels should be adapted to whatever there is (in Studio Erkki, 12).

	Out.ar(outChannel, input * amp)
}).add
)

//Alejandro Olarte's freezing FFT processor:
(
SynthDef(\freezesmasher, {
	arg inChannel = 10, outChannel = 0, gain = 1, amp = 0.1, freeze = 0; //freeze = 1 creates a good spectrum.
	var input, chain, processor ;

	input = In.ar(inChannel) * gain;//check also InFeedback.ar

	chain = FFT(LocalBuf(2048, 1), input);
	chain = PV_Freeze(chain, freeze); //PV_Freeze is a PlugIn --> It needs to be downloaded separately.
	processor = IFFT(chain);

	Out.ar(outChannel, processor * amp); //check also ReplaceOut.ar

}).add
)

//Could include an awful lot of other processors with reverb, ring modulation, comb delays, etc.


//PLAYING THROUGH!
//We are hardcoding here the out through private channels. This could be done, again by creating Bus objects, but in this case, we need to apply the method .index, as the message style will only read numbers and won't take by itself the index out of the Bus object (which is the whole point of using the Bus object).
//Send different values while running the synth (and never use ctrl-period to stop them):

s.sendMsg(\s_new, \sourceMic, 1000, 0, 1, \inChannel, 0, \amp, 0.1, \outChannel, 4) //Creating an instance of the mic SynthDef at the head of the default group. Goes out through a private channel. Mic input should be 0 (= first hardware input bus) to catcht the laptop's mic.
s.sendMsg(\s_new, \wavesmasher, 2000, 1, 1, \inChannel, 4, \amp, 0.1, \outChannel, 0) //Creating an instance of the processing SynthDef (distortion) at the tail of the default group. Takes in the same private channel and goes out through 0.
//Prepping all messages with different instances before making sound. Take care of the nodeID to that it refers to the specifi SynthDef we want to refer to:
s.sendMsg(\n_set, 2000, \amp, 0.45)
s.sendMsg(\n_set, 2000, \mursk, 0.45)
s.sendMsg(\n_set, 2000, \mursk, 0.99)
s.sendMsg(\n_set, 2000, \mursk2, 0.957) //Here the second and even the third decimal count a lot.
s.sendMsg(\n_set, 2000, \mursk2, 0.945)
s.sendMsg(\n_set, 2000, \gain, 0.99) //Play also with the gain to get more or less distortion.
s.sendMsg(\n_free, 2000) //Freeing both synths.
s.sendMsg(\n_free, 1000)

//Let's try with the sampler (remember to change the path):
Buffer.readChannel(s, "C:/Users/SmallAngel/Desktop/THEORY CODES/Audio-for-granular-examples-2.wav", 0, -1, 0, { |b| b.normalize }, 10) //Normalizing the buffer as an action (the peak absolute value will be 1 by default).

s.sendMsg(\s_new, \sourceSample, 1000, 0, 1, \bufnum, 10, \amp, 1, \outChannel, 4)
s.sendMsg(\s_new, \timesmasher, 2001, 1, 1, \inChannel, 4, \amp, 0.1, \outChannel, 0) //Using the delay SynthDef (can try to pass it through more than one processing synth).

s.sendMsg(\n_set, 2001, \amp, 0.45)
s.sendMsg(\n_set, 2001, \speedChorus, 1.65)
s.sendMsg(\n_set, 2001, \speedChorus, 0.145)
s.sendMsg(\n_set, 2001, \depthChorus, 0.58)
s.sendMsg(\n_set, 2001, \predelayChorus, 0.01)
s.sendMsg(\n_free, 1000) //I can free the source and take the other one (the mic one).
s.sendMsg(\n_free, 2001) //And then free also the timesmasher Synth.

//Let's try with the pitch shifter (needs to be reading from the 1000, mic or sampler):
s.sendMsg(\s_new, \pitchsmasher, 2002, 1, 1, \inChannel, 4, \amp, 0.1, \outChannel, 0)
s.sendMsg(\n_set, 2002, \amp, 0.45)
s.sendMsg(\n_set, 2002, \pitch, 1.45)
s.sendMsg(\n_set, 2002, \disp, 0.145) //Try like 4.5 it goes so far from the pitch (even more if the timeDisp is smaller).
s.sendMsg(\n_set, 2002, \timeDisp, 0.65)
s.sendMsg(\n_free, 2002)
s.sendMsg(\n_free, 1000)
