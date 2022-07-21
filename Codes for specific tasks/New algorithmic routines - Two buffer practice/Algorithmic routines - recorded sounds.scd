//ALGORITMIC ROUTINES COMBINING PAIRS OF BUFFERS
//////////////////////////////////////////////////////

//SCHNITTKE + BACH (Improvements notated in code from line 80 + SECOND STAGE with added buffers after it - coming soon):

(
b = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/SPECIFIC CODES/New algorithmic routines - with recorded sounds/Schnittke - Choir Concert.wav");
c = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/SPECIFIC CODES/New algorithmic routines - with recorded sounds/Bach - Gm sonata.wav")
)
//Two channels / Approx. 235 seconds of duration.

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, speed, dur, pan, amp = 0.7, masterVolume = 1;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env * masterVolume)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, speed = 1, buffer, rate, wait = 2;

	position = 0.5;

	position = Pseg((0, 1..(235 - 7)), 1.5, 'lin', inf).asStream;

	//Maybe personalized rate for each buffer --> Conditional??
	rate = Pwrand([2, 5, 7, 1, -2, -5, -7].midiratio, [2, 3, 4, 6, 4, 3, 2].normalizeSum, inf).asStream; //Also adjust here the pitch values (pitchshifting).

	//Initial condition? (+ also for pitch and for buffer?).
	wait = Pbrown(1.0, 3.5, 0.3, inf).asStream; //For density / superposition variation. Try with Pseg if this does not work properly.

	inf.do({ arg i;

		//i.postln; //For testing.

		buffer = [b, c].wchoose([5, 3].normalizeSum); //Maybe change this probability.

		durBuffer = buffer.duration;
		durGrain = (3, 3.5..6.5).wchoose((1, 2..8).normalizeSum); //Myabe change this probability.


		s.bind({
			Synth(
				\grain,
				[
					\bufnum, buffer.bufnum,
					\position, position.next * 44100,
					\speed, rate.next,
					\dur, durGrain,
					\pan, rrand(-0.7, 0.7),
					\amp, 0.3,
					\out, 0,
					\masterVolume, 2.5
				]
			);

		});

		//((2, 2.5..3.5).choose).wait
		(wait.next).wait


	});
}).play
)

//////////////////////////////////////////////////////////////////////////////////////////////////
//STILL SOME ENHANCEMENTS TO TRY (possibly copying the code again just in case), READ ALL NOTES:

(
b = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/SPECIFIC CODES/New algorithmic routines - with recorded sounds/Schnittke - Choir Concert.wav");
c = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/SPECIFIC CODES/New algorithmic routines - with recorded sounds/Bach - Gm sonata.wav")
)

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, speed, dur, pan, amp = 0.5, masterVolume = 1;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env * masterVolume)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, buffer, ratePatternChoir, ratePatternViolin, rate = 1, waitPattern, waitTime = 2;

	position = 0.5; //Initial.

	position = Pseg((0, 1..(235 - 7)), 1.5, 'lin', inf).asStream; //If the distance between the numbers of the series is smaller, the complete track up to the new repetition with take more time, will be longer. But it will sound a bit more repetitive.

	//Rate patterns for each buffer (adjust the pitch values as needed) + Maybe testing a Pbrown in here could be good:
	ratePatternChoir = Pwrand([2, 5, 1, -2, -5].midiratio, [2, 3, 5, 3, 2].normalizeSum, inf).asStream; //Maybe add more options for the choir but within the 5.midiratio spectrum.
	ratePatternViolin = Pwrand([2, 5, 7, 1, -2, -5, -7].midiratio, [2, 3, 4, 6, 4, 3, 2].normalizeSum, inf).asStream;

	waitPattern = Pbrown(1.0, 3.5, 0.3, inf).asStream; //For density / superposition variation.

	inf.do({ arg i;

		//i.postln; //Testing.

		//Initial conditions:
		if(i != 0, {waitTime = waitPattern.next}, {waitTime = 2.2});
		if(i != 0, {buffer = [b, c].wchoose([5, 3].normalizeSum)}, {buffer = c}); //Vary weights as needed.
		if(i == 0, {rate = 1}, {
			if(buffer == b, {rate = ratePatternChoir.next}, {rate = ratePatternViolin.next}) //NEED TO TEST IF THIS IS REALLY WORKING!!!
		});

		durBuffer = buffer.duration;
		durGrain = (3, 3.5..6.5).wchoose((1, 2..8).normalizeSum); //Variable probability --> In connection with waiting time.

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, buffer.bufnum,
					\position, position.next * 44100,
					\speed, rate,
					\dur, durGrain,
					\pan, rrand(-0.7, 0.7), //You could think about connecting the range of panning to the density (for example, the smaller the waiting time between grains, the more extreme the panning values, and vice versa.
					\amp, 0.3,
					\out, 0,
					\masterVolume, 1.7
				]
			);

		});

		//((2, 2.5..3.5).choose).wait
		waitTime.wait


	});
}).play
)
