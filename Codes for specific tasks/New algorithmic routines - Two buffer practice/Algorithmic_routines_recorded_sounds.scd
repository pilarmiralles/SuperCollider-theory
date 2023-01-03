//ALGORITMIC ROUTINES COMBINING PAIRS OF BUFFERS
//////////////////////////////////////////////////////

//SCHNITTKE + BACH (Improvements notated in code from line 80):

(
b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Two buffer practice/Schnittke - Choir Concert.wav");
c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Two buffer practice/Bach - Gm sonata.wav")
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
	rate = Pwrand([2, 5, 7, 1, -2, -5, -7].midiratio, [2, 3, 4, 6, 4, 3, 2].normalizeSum, inf).asStream; //Also adjust here the pitch values (rate).

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

////////////////////////////////////////////////////////////
//STILL SOME ENHANCEMENTS TO TRY (read all notes):

(
b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Two buffer practice/Schnittke - Choir Concert.wav");
c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Two buffer practice/Bach - Gm sonata.wav")
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

	position = Pseg((0, 1..(235 - 7)), 1.5, 'lin', inf).asStream; //If the distance between the numbers of the series is smaller, the complete track up to the new repetition will take more time. But it will also sound a bit more repetitive.

	//Rate patterns for each buffer (adjust the pitch values as needed) + Maybe testing a Pbrown in here could be good:
	ratePatternChoir = Pwrand([2, 5, 1, -2, -5].midiratio, [2, 3, 5, 3, 2].normalizeSum, inf).asStream; //Maybe add more options for the choir but within the 5.midiratio scope.
	ratePatternViolin = Pwrand([2, 5, 7, 1, -2, -5, -7].midiratio, [2, 3, 4, 6, 4, 3, 2].normalizeSum, inf).asStream;

	waitPattern = Pbrown(1.0, 3.5, 0.3, inf).asStream; //For density / superposition variation.

	inf.do({ arg i;

		//i.postln; //Testing.

		//Initial conditions:
		if(i != 0, {waitTime = waitPattern.next}, {waitTime = 2.2});
		if(i != 0, {buffer = [b, c].wchoose([5, 3].normalizeSum)}, {buffer = c}); //Vary weights as needed.
		if(i == 0, {rate = 1}, {
			if(buffer == b, {rate = ratePatternChoir.next}, {rate = ratePatternViolin.next})
		}); //This solution does not work: see next code, implementing a case.

		durBuffer = buffer.duration;
		durGrain = (3, 3.5..6.5).wchoose((1, 2..8).normalizeSum); //Variable probability --> In connection to waiting time.

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, buffer.bufnum,
					\position, position.next * 44100,
					\speed, rate,
					\dur, durGrain,
					\pan, rrand(-0.7, 0.7), //You could think about connecting the range of panning to the density (for example, the smaller the waiting time between grains, the more extreme the panning values, and vice versa).
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

///////////////////////////////////////////////////////////////////////////////////////////////////////
//ENHANCEMENTS AND IMPLEMENTATION OF A THIRD BUFFER (Chaplin's speech):
(
b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Two buffer practice/Schnittke - Choir Concert.wav");
c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Two buffer practice/Bach - Gm sonata.wav");
d = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Two buffer practice/Chaplin speech.wav") //This could be implemented as suggested in the code, or could be added to a possible piece in the DAW (option with best results should be chosen).
)
//"b" and "c" had two channels / Approx. 235 seconds of duration --> What about "c"? (only a bit less, 210 secs, also two channels).

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, speed, dur, pan, amp = 0.5, masterVolume = 1;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp), //Maybe trying other kind of envelopes.
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env * masterVolume)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, buffer, ratePatternChoir, ratePatternViolin, rate = 1, waitPattern, waitTime = 2, pan = 0, panRandomSide = 0;

	position = 0.5; //Initial. Could be also just stated as a default value in the variables.

	position = Pseg((0, 1..(235 - 7)), 1.5, 'lin', inf).asStream;

	ratePatternChoir = Pwrand([2, 3, 5, 1, -2, -3].midiratio, [3, 2, 3, 5, 3, 2].normalizeSum, inf).asStream;
	ratePatternViolin = Pwrand([2, 5, 7, 1, -2, -5, -7].midiratio, [2, 3, 4, 6, 4, 3, 2].normalizeSum, inf).asStream;

	waitPattern = Pbrown(1.0, 3.5, 0.3, inf).asStream; //For density / superposition variation (alongside the grain duration variable). Pbrown works quite well and very organically generating zones of higher and lower density and the transitions between those are extremely smooth (it wouldn't work for acute contrasts).

	inf.do({ arg i;

		//i.postln; //Overall testing.

		//Initial conditions:
		if(i != 0, {waitTime = waitPattern.next}, {waitTime = 2.2});
		if(i != 0, {buffer = [b, c, d].wchoose([5, 3, 4].normalizeSum)}, {buffer = c}); //Vary weights as needed (added buffer "d").

		//waitTime.postln; //To test alongside the panRandomSide variable.

		//Replacing the failed conditional of former code with this case:
		case
		{buffer == b} {rate = ratePatternChoir.next}
		{buffer == c} {rate = ratePatternViolin.next}
		{buffer == d} {rate = 1} //Added buffer "d".
		{rate = 1};

		if(i == 0, {rate = 1}); //This "initial condition" needed to be after the case for some reason (it didn't work when placed before it in the code).

		//rate.ratiomidi.postln; //Testing rate conditional --> Working better with the case.

		durBuffer = buffer.duration;
		durGrain = (3, 3.5..6.5).wchoose((1, 2..8).normalizeSum);

		//The smaller the waiting time between grains, the more extreme the panning values, and vice versa:
		//Formula calculated from the normalization of waitTime range 1 to 3.5 into pan values -0.8 to 0:
		pan = (waitTime - 3.5) / 3.125; //--> Now I need to randomize the values between positive and negative (following line):
		panRandomSide = [pan, pan * -1].choose; //Because "pan" is already negative, the other option is pan * -1 to convert itz to positive.

		//panRandomSide.postln; //Panning testing (test alongside the waitTime variable).


		s.bind({
			Synth(
				\grain,
				[
					\bufnum, buffer.bufnum,
					\position, position.next * 44100,
					\speed, rate,
					\dur, durGrain,
					//\pan, rrand(-0.7, 0.7),
					\pan, panRandomSide,
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