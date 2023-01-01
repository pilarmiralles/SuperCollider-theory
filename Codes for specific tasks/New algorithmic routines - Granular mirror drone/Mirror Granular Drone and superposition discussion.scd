//Continuous granular drone from three synthetic recordings:
//IF USING A DIFFERENT MACHINE: AUDIO FILES TO THE SAME FOLDER + CHANGE THE PATHS OF EACH FILE!
(
b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Granular mirror drone/Sher-Gendy.aiff"); //It works much better with the normal gendy rather than the klank gendy.
c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Granular mirror drone/Klank-Comb.aiff");
d = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/New algorithmic routines - Granular mirror drone/Windy-Klank.aiff")
)

(
SynthDef(
	\caressingGranulator,
	{ arg out, bufnum, position, rate, dur, amp = 0.1, pan = 0;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position, 1);
		signal = signal[0];

		env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);
		signal = Pan2.ar(signal * env, pan); //Pan is 0 by default, I'm not using it for now.

		OffsetOut.ar(out, signal)

}).add;
SynthDef(
	\reverb,
	{ arg out = 0, in, time;
		var input, dry, wet, signalOut;

		input = In.ar(in, 2);

		//Schoeder filter (could try with any other type of reverb or no reverb at all:
		dry = input;

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !12
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		signalOut = dry + LPF.ar(wet, 3000); //Could try with other balances of dry and wet.

		OffsetOut.ar(out, signalOut)

}).add
)

(
Routine({
	var durBuffer, durGrain, position = 1, rate, waitTime, alternation, buffer, ratePattern, waitPattern, rateArraySize;

	Synth(\reverb, [ \in, 4, \time, 2 ], s, \addToTail);

	//Rate modifier: creates stairs going upwards and reflected backwards (mirrored):
	ratePattern = Pn(
		Plazy({ var rateArray;

			rateArraySize = rrand(5, 12); //This variable is outside the Plazy because I need it somewhere else (in the waitPattern).

			rateArray = Array.series(
				rateArraySize, //There can be a higher / lower number of steps
				0.5, //Lowest rate modifier --> It always starts here and lands here again, maybe the start should be also randomized.
				rrand(0.1, 0.5) //Each step can be bigger / smaller.
			);
			Pseq(rateArray.mirror)
		}),
		inf
	).asStream;

	//Wait time modifier:
	waitPattern = Pn(
		Plazy({ var waitArray1, waitArray2;

			//Maybe the duration of the very short pieces in the rapid mirror should be the same (so it doesn't sound awckward). Maybe 0.2 instead of random.
			waitArray1 = Array.fill(
				(rateArraySize * 2) - 1, //The size of the array needs to be the same as in the rateArray. I NEED TO COMPENSATE THE MIRROR OR THE RATEPATTERN, this is why I am multiplying by 2 and substracting 1 (because of the odd number cause by the mirror's symmetric axis). NOW IT DOES WORK (BUT I don't really like it when it goes too high, so maybe I could limit this so it only happens when the size is under, let's say 8 steps? But Idk yet how to condition this. Right now the choice is random according to the final pattern within the Plazy).
				{rrand(0.1, 0.3)}
			);
			waitArray2 = Array.fill(
				(rateArraySize * 2) - 1,
				{rrand(0.5, 3)}
			);

			Pwrand([Pseq(waitArray1), Pseq(waitArray2)], [2, 8].normalizeSum) //More probability for the longer values and sometimes, the short values happen. But I should maybe somehow avoid the rapid changes happening at the very beginnig.
		}),
		inf
	).asStream;

	//alternation = Pwrand([b, c, d], [2, 4, 4].normalizeSum, inf).asStream; //Now controlled with a conditional inside the loop.

	inf.do({

		rate = ratePattern.next;

		//buffer = alternation.next;
		if(rate < 0.8, { buffer = [c, d].wchoose([4, 2].normalizeSum)}, { buffer = [b, c, d].wchoose([4, 4, 2].normalizeSum)}); //Excluding the gendy buffer when the rate is below 0.8.

		//Also just for testing that the former conditional works properly (could be commented to save CPU usage):
		case
		{buffer == b} {"b".postln}
		{buffer == c} {"c".postln}
		{buffer == d} {"d".postln};


		durBuffer = buffer.duration;

		//waitTime = rrand(0.5, 3);
		waitTime = waitPattern.next;
		durGrain = waitTime * 3;

		position = rrand(1, durBuffer - durGrain); //Randomized and not reproducing "in order".

		s.bind({
			Synth(\caressingGranulator,
				[
					\bufnum, buffer.bufnum,
					\dur, durGrain,
					\rate, rate.postln, //Postln just for testing (delete to cut on CPU usage).
					\position, position * 44100,
					\amp, 0.4,
					\out, 4 //Going to reverb Synth.
				],
				s, \addToHead
			)
		});
		waitTime.wait;
	});
}).play
)

//The mirror for the rate is quite interesting in this case, because not all the three samples hold the same pitch, thus if we were using samples with the same pitch, the mirroring would be more boring because we would have exactly the same set of frequencies back and forth in each round. Now, having the samples in different pitches provokes that, although the mirror of rates keeps the same frequencies, they change because of the randomness of the chosen sample.

//My conclusion is that there are two ways of obtaining superposition (overlapping) in granular synthesis (it also depends on the kind of granular synthesis you are using, it is not the same when using granular synthesis for pitch shifting or time stretching because it controlles then the level of "perforation" of the sound), but anyway, two ways: having duration of the grains longer than waiting time (no superposition variable is needed) / having waiting time shorter than duration of the grains. I guess the superposition variable is only needed when the parameter that is longer or shorter, for example, the wait time, is at the same time conditioning another parameter (such as the position). In that sense, both parameters have to be modified at the same time and by the same value, thus we need the variable.

//This has been tried to be revised in all my files containing any sort of granulator, but there is no guarantee that I spotted all possibles mistakes.
