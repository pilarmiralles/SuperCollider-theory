//PITCH TRACKER - USING A BUFFER (sound file as input for the pitch)
///////////////////////////////////////////////////////////////////////////

//THEORY: Pitch.ar
//This Ugen gives back two different parameters within an array: "freq" in Hz in index 0, and "hasFreq" gives a 0 when there is no pitch tracked and 1 when there is, in index 1. The # in the variable name stablishes the reference to the resulting array (#a, b, c = myArray --> assign consecutive elements of myArray to multiple variables): For example:

		/*
		var a, b, c;
		#a, b, c = [1, 2, 3]; // equivalent to a = 1; b = 2; c = 3;
		When used before an array: makes a totally fixed (non-dynamic) Array --> This is why those arrays can be set as arguments of Synthdef (as the size of arrays in Synthdefs cannot be changed).
		*/

//The aruments of Pitch: here I am using the input (needs two channels), the initFreq (the freq that will be output if hasFreq = 0), execFreq (= 100 means that it is checking the pitch 100 times per second. The accuracy of the pitch tracker depends on this), ampThreshold (limit of amp for the pitch tracking), median (filter of length, adds a bit of latency inthe pitch stimation, by default is = 1, which means no filter is applied)).

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//It works, but it is still very dissonant with respect to the original. It might need more work, but it works (maybe a different synthesis part, a different input, different values, etc.).
//BEWARE THE CPU PERCENTAGE: especially dependent on the durEnv:

b = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/12 - Audio example 2 for granular.wav")

( //Pitch analysis SynthDef:
SynthDef(
	\analysisPitch,
	{
		var amps, signal, env, signalOut, pitchInput, freq, hasFreq, tempPitch;

		pitchInput = PlayBuf.ar(2, b.bufnum, loop: 1);

		# freq, hasFreq = Pitch.kr(pitchInput, 440, 80, execFreq: 100, ampThreshold: 0.02, median: 7); //Maybe reducing the execFreq?

		//TESTING VALUES:
		//freq[0].poll(5);
		//hasFreq[1].poll(5);

		SendReply.kr(Impulse.kr(100), '/pitch', [freq[0], hasFreq[1]]) //This will send the data of the pitch analysis outside the Synthdef thanks to the command name '/pitch' (specific notation, see in the list of arguments). The data (arg values) we are sending is an array with the freq and hasFreq output from Pitch. The trigger for sending is equal to the execFreq in Pitch.

}).add
)


( //Synthesis SynthDef:
SynthDef(\resz, {
	|tempPitch = 440, durEnv = 0.5, amp = 0.1 |
	var amps, signal, env;

	signal= {Mix(
		BPF.ar(
			PinkNoise.ar,
			Array.geom(2, tempPitch * 7.midiratio, 2), //Freq offset (of a fifth in here, 7.midiratio). "tempPitch" is the "start" frequency.
			0.001,
			amp)
	)} !2;

	env = EnvGen.kr(Env.sine(durEnv, 0.5), doneAction: 2);

	Out.ar(0, signal * env * amp)

}).add
)

//Running the synthesis part (what it sounds):
//OSCdef(\x, { |msg, time| msg.postln}, '/pitch') //Test.
OSCdef(\x, { |msg, time| if(msg[4] == 1){Synth(\resz, [\tempPitch, msg[3], \durEnv, 2.5, \amp, 1.2 ])}{}}, '/pitch') //Receiver of the data from SendReply in the analysis SynthDef. In OSCdef we have a name (\x), a function, and a command name ('\pitch') connected to the SendReply. In the function, the conditional says that if the msg in 4 (which is the hasFreq of Pitch) is = 1, then the SynthDef with the synthesis part is going to start working, and the arguments of the filter can be set - the frequency is msg in 3, which is the freq of Pitch from the SendReply. If hasFreq is = 0, then nothing (that is why the "else" space of the conditional is empty).

//Running the analysis part, which gives the frequency to the synthesis:
Synth(\analysisPitch);

////////////////////////////////////////////////////////////////////////////

//WITH NO BUFFER (Using the microphone of the computer --> TRY WHISTLING):

//PROBLEMS: The argument initFreq is 440 Hz by default --> The problem is that it keeps sounding even if the routine is not sending the signal + There is not a perfect adjustment of the delay between the pitch and the synthesis, and there is not a perfect accuracy of tracking every pitch (but the pitch itself is QUITE accurate) + There are some strange peaks sometimes, it really peaks the amp randomly.

//"Minimal synth" with reverb:
(
SynthDef(
	\minimalPitchTracker,
	{   arg out = 8, addAmps = 26, mulAmps = 5, rq = 0.0005, dur = 2;
		var amps, signal, env, signalOut, pitchInput, freq, hasFreq;

		//Section of the pitch tracker:
		pitchInput = SoundIn.ar([0, 1], 1); //Bus in (to take the laptop microphones, use [0, 1]), and mul (it always needs two channels).

		# freq, hasFreq = Pitch.kr(pitchInput, 220, execFreq: 100, ampThreshold: 0.02, median: 7);

		freq[0].poll(5);

		//Section of the minimal routine:
		amps = LFDNoise3.ar(5, mulAmps, addAmps);

		signal = Mix(
			Resonz.ar(
				PinkNoise.ar,
				freq[0],
				rq,
				amps)
		)!2;

		env = EnvGen.ar(Env.sine(dur, 0.5), doneAction: 2);

		signalOut = signal * env;

		Out.ar(out, signalOut)

}).add;
SynthDef(
	\reverb,
	{ arg in = 8, time = 1, roomSize = 10, mix = 0.7, masterVolume = 1;
		var input, dry, wet;

		input = In.ar(in, 2);

		dry = input;

		//wet = GVerb.ar(dry, roomSize, time, 0.5);
		wet = FreeVerb.ar(dry, mix, time, 0.5);

		OffsetOut.ar(0, wet * masterVolume)

}).add
)

(
Routine ({
	var freqs, scale, durs;

	Synth(\reverb, [ \in, 8, \time, 3, \masterVolume, 1.2 ], s, \addToTail);

	durs = Pwrand([2.5, 3, 4, 4.5], [2, 5, 4, 3].normalizeSum, inf).asStream;

	inf.do({
		Synth(\minimalPitchTracker,
			[
				//\freqs, freqs.midicps.choose,
				\mulAmps, 5,
				\addAmps, 28,
				\rq, 0.0007,
				\dur, durs.next,
				\out, 8
			],
			s, \addToHead,
		);
		[0.7, 1, 1.5, 2].choose.wait
	})
}).play
)
