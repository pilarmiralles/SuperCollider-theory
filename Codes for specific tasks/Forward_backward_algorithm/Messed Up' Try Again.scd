//FORWARD-BACKWARD ALGORITH
/////////////////////////////////////////////////////

//Objective: Create a code that reproduce 2-5 seconds of the buffer in question, then it comes backwards (and at higher rate) to position = i + 2 sec (for example). This shouldn't be too difficult :)

b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/Forward_backward_algorithm/Abstractions-II.wav")
b.numChannels //2 channels.

(
SynthDef(
	\messedUp,
	{ | bufnum, position, rate, dur, pan, amp = 0.1 |
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position);
		//signal = signal[0]; //For using panning + Also next line.
		//signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env([0.1, amp, amp, 0.1], [0.001, dur, 0.001], \sine), //0.001 is an "anticlick", need to search for a more elegant solution.
			doneAction: 2
		);

		OffsetOut.ar(0, signal * env)
}).add
)

//Random rate backwards + wchoose for durGrainPatter? --> BUT SAVE THIS CODE!!!
(
Routine ({
	var durBuffer, durGrain = 3, position, rate = 1, durGrainPattern, waitWithRate;

	durBuffer = b.duration;

	//I need to duplicate the random value chosen for durGrain in order to have the same section of audio forward and backward:
	durGrainPattern = Pstutter(2, Prand((2, 2.5..5.0), inf)).asStream; //Could be Prand so a bit more controlled (less 5 sec, more short ones?).

	inf.do({ arg i;

		//i.postln;

		//Duration of the grain:
		durGrain = durGrainPattern.next;

		//Position choice:
		position = (i + 1.5) * 44100; //Try this out so the piece is not 20 min long (if it's too long, just increate the position addition to 1.5 or 2; original value is 1).

		//Rate choice:
		if( i.asInt.even, {rate = 1}, {rate = -2.5}); //You could randomize the amount of rate when backwards.

		//Wait choice (in order to avoid gaps, compensate rate change):
		waitWithRate = durGrain / rate.abs; //Absolute value since the negative sign only affect the rate going backwards instead of forward.

		s.bind({
			Synth(
				\messedUp,
				[
					\bufnum, b.bufnum,
					\position, position,
					\rate, rate,
					\dur, waitWithRate, //NOW IT WORKS!! (the mistake was to leave the durGrain here with no rate compensation).
					//\pan, 0, //Only if working with a single channel of the signal.
					\amp, 1
			]);
		});

		waitWithRate.wait //Connected to durGrain, but need to compensate rate change in order to avoid gaps (see variable above).
	});
}).play
)

///////////////////////////////////////////////////////
//Second version with more randomizations: Random rate backwards + wchoose for durGrainPatter? + See all explanations in the code above:

b = Buffer.read(s, "F:/DOCUMENTOS/1 Year 2022-2023/Last subjects from SibA/Acousmatic Composition/PIECE 2/Abstractions II, mov III.wav")
b.numChannels //2 channels.

(
SynthDef(
	\messedUp,
	{ | bufnum, position, rate, dur, pan, amp = 0.1 |
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position);
		//signal = signal[0]; //For using panning + Also next line.
		//signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env([0.1, amp, amp, 0.1], [0.001, dur, 0.001], \sine),
			doneAction: 2
		);

		OffsetOut.ar(0, signal * env)
}).add
)

(
Routine ({
	var durBuffer, durGrain = 3, position, rate = 1, durGrainPattern, waitWithRate, randomRate;

	durBuffer = b.duration;

	durGrainPattern = Pstutter(2, Pwrand((1, 1.5..4.5), [4, 5, 5, 4, 3, 2, 2, 1].normalizeSum, inf)).asStream;
	randomRate = Prand([-2.5, -2.3, -2, -1.7], inf).asStream; //I'll need to try other values or make a list (-2.5..-1.5), for example.

	inf.do({ arg i;

		//i.postln;

		//Duration of the grain:
		durGrain = durGrainPattern.next;
		durGrain.postln; //Just testing.

		//Position choice:
		position = (i + 1.5) * 44100;

		//Rate choice:
		if( i.asInt.even, {rate = 1}, {rate = randomRate.next});

		//Wait choice:
		waitWithRate = durGrain / rate.abs;

		s.bind({
			Synth(
				\messedUp,
				[
					\bufnum, b.bufnum,
					\position, position,
					\rate, rate,
					\dur, waitWithRate,
					//\pan, 0, //Only if working with a single channel of the signal.
					\amp, 1
			]);
		});

		waitWithRate.wait
	});
}).play
)
