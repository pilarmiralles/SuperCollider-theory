b//12 - GRANULAR SYNTHESIS
//////////////////////////////

//The objective here is to create our own granulators instead of using the UGens already prepared for such a purpose in SC. The advantage of this is to be able to control every single parameter, being conscious of the background process.
//We will work from a buffer (digital sound file), but it is possible to create an alternative source of sound (another synthesizer, for example) to be granulated.

p = Platform.resourceDir +/+ "sounds/a11wlk01.wav" //Deafult sound from SC library.

b = Buffer.read(s, p) //Sound file into the buffer.
b.numChannels //It's a mono signal in this case.

//Here is our grain producer, the "chopping machine": Playbuf, possible panning, and an envelope (similar to our algorithmic routines):

(
SynthDef(
	\grain,
	{ | bufnum, position, rate, dur, pan, amp = 0.1 |
		var signal, env;

		signal = PlayBuf.ar(1, bufnum, rate, 1, position); //Mono signal. We won't be able to change this once the SynthDef is compiled. The trigger argument also needs to be = 1 to start playing the audio right away. We always create an argument for the bufnum (which will be assign to the variable containing the buffer) so it can be automatically assigned by the server.
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);

		OffsetOut.ar(0, signal * env) //We use OffsetOut when creating more than 20-50 synths per second, more or less (for fast pace and short durations = grains). But this UGen is equivalent to Out.ar. OffsetOut sets a small delay for the synths to be read (interpreted) by the server, which is usually performed in control blocks (each 64 values). But if the reading process of the Synths is as fast as 20-50 Hz or above, then we'll obtain a frequency out of this rate (and a possible periodicity). The delay of OffsetOut avoids the possible creation of a spectrum due to the fast-paced creation of Synths, despite reading thm in blocks of 64.
}).add
)

//This is an isolated grain (we obtain just one each time this Synth evaluated): the duration of the grain is 0.1 seconds here. Grains can be longer or shorter. Their duration can also be randomized within a certain range. There is no rule for the duration of grains (conventions set the average in 0.05 - 0.1 secs).

Synth(\grain, [\bufnum, b.bufnum, \position, 1 * 44100, \rate, 1, \dur, 0.1, \pan, 0 ])

//Now we need to create a routine in order to produce Synths successively (one after another or overlapped). Observe what happens to the number of synths in the CPU menu below the postwindow. Take into consideration that all arguments and parameters can be modified according to your taste and necessities. This is just one example. Also, observe where each argument is being sent within the SynthDef above:

(
Routine ({
	var durBuffer, durGrain, position, rate = 1;

	durBuffer = b.duration; //The total duration of the audio file is asked in here in seconds. Then it will be used in the loop.

	inf.do({

		durGrain = rrand(0.0, durBuffer); //The duration of each grain is random from 0 to the total duration of the buffer (be aware of this if the used audio is longer).
		position = rrand(0, durBuffer - durGrain) * 44100; //The position is calculated in no. of frames, hence the number of the seconds is multiplied by the sample rate (44100). The position is random from the beginning of the audio file up to the end (substracting the length of the grain itself so it does not run out of audio file).

		s.bind({ //s.bind can only be around the Synth, which will help the server reading the synths.
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position,
					\rate, rate, //The rate can be randomized (for example, using a rrand (0.5, 2), or rrand(1.midiratio, 7.midiratio) in order to used specific intervals).
					\dur, durGrain,
					\pan, rrand(-1.0, 1.0), //The panning is random from -1 to 1.
					\amp, 0.1
			]);
		});
		//1.wait //There is the same space between each grain: this is called synchronic synthesis. This separation would be too long for conventional granular synthesis (this is more like a random routine). Try the option below:
		rrand(0.01, 0.1).wait //This would be asynchronic synthesis: different space between each grain, randomized.
	});
}).play
)

//Example with a fixed position: try out the routine with no s.bind, then try out changing the OffsetOut by Out.ar to see how it changes:
(
Routine ({
	var durBuffer, durGrain, position, rate = 1;

	durBuffer = b.duration;

	inf.do({

		durGrain = 0.07;
		position = 3.3 * 44100;

		s.bind({ //Without the s.bind it is much more irregular. But changing OffsetOut makes a smaller difference.
		Synth(
			\grain,
			[
				\bufnum, b.bufnum,
				\position, position,
				\rate, 1,
				\dur, durGrain,
				\pan, 0,
				\amp, 0.2

		]);
		});
		rrand(0.01, 0.1).wait
	});
}).play
)

//When the audio file within the buffer is already stereo, using Pan.ar is not necessary to obtain sound through both channels. On the other hand, if the panning needs to be applied to a stereo signal, we have to take only one of the signals of the array. Using signal = signal[0] (taking just the left channel of the signal) after the Playbuf is enough to obtain a mono signal to be distributed using Pan2.

//Other variants include using several buffers and creating a variable which randomly chooses among them (remember that all arguments dependant on the buffer should be now dependant on that variable, for example, the bufnum).

//Next example includes superposition and its objective is to play the grains in chronological order:
(
Routine ({
	var durBuffer, durGrain, position, rate = 1, superposition;

	durBuffer = b.duration;
	position = 0;
	rate = [1, 0.5, 0.25, 2, 0.25, 2.6, 3.2, 3.5]; //Array of different rate values.

	inf.do({ | i |

		i.postln;
		durGrain = 1; //The duration could be randomized.
		superposition = 3; //This avoids noticing the gap between grains: now the position and the wait time will be 3 times shorter than the duration of the grain, so there will be 3 grains when only 1 was expected.
		position = durGrain / superposition;

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position * 44100, //The position is defined before the wait, so we need a default value as first value (stated above, before the loop). Then, the position is read in frames, so we need to multiply by 44100 (sample rate).
					\rate, rate[i % (rate.size - 1)], //The argument "i" (index) will give the number of the indexes of the rates array, and will be kept within the number of rate values thanks to the module of rate.size - 1 (because the last index is the number of items - 1 --> It could be easier to use the method .lastIndex instead of .size to avoid the substraction). Thus, each grain will feature a new speed in order according to the array of rates (this could also have been done with a pattern).
					\dur, durGrain,
					\pan, 0,
					\amp, 0.5

			]);
		});
		position = (position + durGrain) % durBuffer; //In here, the grains will be read successively: the position (affected before by the superposition) will add the duration of the grain and go ahead within the audio file according to this addition. Then, there is the module of the total duration of the buffer, which will maintain the values of position in seconds within the total duration of the buffer.
		(durGrain / superposition).wait
	});
}).play
)

//////////////////////////////////////////////////////////////////////////////////////

//SOLUTIONS TO DIFFERENT ISSUES (GRANULAR SYNTHESIS):
//Let's prepare a longer buffer to try out the different examples (take into consideration that you will need to change the path of the audio file according to the folder where the audio file is located in your computer):

b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Theory codes/Audio-for-granular-examples-1.wav")
b.numChannels //Stereo signal.

//This first one is an example of using a stereo signal with panning (taking just one of the sides of the stereo array):
(
SynthDef(
	\stereoGrain,
	{ arg bufnum, position, rate, dur, pan, amp = 0.4;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(0, signal * env)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, rate = 1;

	durBuffer = b.duration;

	inf.do({

		durGrain = rrand(3.0, 5); //Superposition is implied in this code due to the excess of grain duration in comparison with the wait time, which will cause an overlapping of the grains.
		position = rrand(0, durBuffer - durGrain); //Random position within the duration of the buffer.

		s.bind({
		Synth(
			\stereoGrain,
			[
				\bufnum, b.bufnum,
				\position, position * 44100,
				\rate, rrand(0.8, 1.2), //Random rate.
				\dur, durGrain,
				\pan, rrand(-0.6, 0.6) //Random panning.
		]);
		});
		rrand(0.5, 1.5).wait
	});
}).play
)

//Applying operations on top of our original signal (after granulating it) --> For instance, reverb (other options are filters, distortion, any modulation that would affect all grains at the same time, etc.): we have to connect the out of our original signal to a private channel, which will be taken by the second SeynthDef (which will apply the process). Here also using two different buffers randomly chosen:
(
b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Theory codes/Audio-for-granular-examples-1.wav");
c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Theory codes/Audio-for-granular-examples-2.wav")
)

( //Info:
[b.duration, b.numChannels].postln;
[c.duration, c.numChannels].postln;
[] //The empty array avoid repeating the last line of the code as it is being already printed.
)

(
SynthDef(
	\grainReverb,
	{ arg out, bufnum, position, rate, dur, pan, amp = 0.4;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position);
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env)
}).add;
SynthDef(
	\reverb,
	{ arg in;
	 var input, signal;

		input = In.ar(in, 2);
		signal = GVerb2.ar(input); //If using GVerb, we need a mono signal as input (otherwise, you can also use FreeVerb).
		OffsetOut.ar(0, signal)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, rate = 1, buffer;


	position = 0;

	Synth(\reverb, [ \in, 4 ], s, 'addToTail'); //Implementing the reverb.

	inf.do({

		buffer = [ b, c ].choose; //Choosing one of the buffers randomly.
		durBuffer = buffer.duration;
		durGrain = 1;
		position = (rrand(0, durBuffer - durGrain));

		s.bind({
			Synth(
				\grainReverb,
				[
					\bufnum, buffer,
					\position, position * 44100,
					\rate, rrand(0.5, 2),
					\dur, durGrain,
					\pan, 0,
					\amp, 0.05,
					\out, 4

			]);

		});

		rrand(0.01, 0.1).wait

	});
}).play
)

//Model of granular routine which follows the chronological development of the audio file:

b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Theory codes/Audio-for-granular-examples-1.wav");
b.duration

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, speed, dur, pan = 0, amp = 0.4;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan); //The panning could be used.
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env)
}).add;
SynthDef(
	\reverb, //We are implementing here an entire Schroeder filter as reverb:
	{ arg in, time = 0.5, masterVolume = 1;
		var input, wet, finalSignal;

		input = In.ar(in, 2);

		wet = Mix(
			{ CombC.ar(
				input,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !12
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		finalSignal = input + LPF.ar(wet, 3000);

		OffsetOut.ar(0, finalSignal * masterVolume)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, speed = 1;


	position = 0;

	Synth(\reverb, [ \in, 4, \time, 0.5, \masterVolume, 1.2 ], s, 'addToTail');

	position = Pseg((0, 1..(260 - 9)), 1.5, 'lin', inf).asStream.trace; //This is an envelope for the position so it is just going straight instead of jumping randomly within the duration of the buffer (I calculated the buf duration and substracted the maximum duration of the grain - which is random -). See Pseg in the theory file 13.

	inf.do({

		durBuffer = b.duration;
		durGrain = (3, 3.5..8.5).wchoose((1, 2..12).normalizeSum); //If you want use longer or shorter grains, modify the wait time of the routine so the gaps between the entries are still the same (unless you also want each sound to be closer to next one, overlap or keep a longer distance).

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position.next * 44100,
					\speed, (0.9, 0.95..1.1).wchoose((0.9, 0.95..1.1).normalizeSum), //This modifies the tuning of the buffers with a little deviation of the rate.
					\dur, durGrain,
					\pan, rrand(-0.6, 0.6),
					\amp, 0.8,
					\out, 0

			],
				s, 'addToHead'
			);

		});

		((3, 3.5..5.5).wchoose((6, 5..1).normalizeSum)).wait //Shorter durations are more probable.

	});
}).play
)

////////////////////////////////////////////////////////////////////////////

//PITCH-SHIFTING AND TIME-STRETCHING (USING GRANULAR SYNTHESIS):
//We will use this basic granulator:

c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Theory codes/Audio-for-granular-examples-2.wav")

(
SynthDef(
	\grain2,
	{ | bufnum, position, rate, dur, amp = 0.1 |
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position); //Prepared for a stereo signal (if applying panning, remember to take only signal[0]).
		env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);

		OffsetOut.ar(0, signal * env)

}).add
)

//Here we create 50 grains per second instead of the continuous sound of the audio file: the different superposition values will affect the accuracy of this "fake continuity":
(
Routine({
	var durBuffer, durGrain, position = 1, rate, waitTime, superposition;

	durBuffer = c.duration;
	waitTime = 0.02; //Fixed value for the time between the grains: try out waitTime = 1 to see how the grains are taken in order.
	superposition = 3; //With no superposition (= 1), the audio seems to be perforated, damaged. With superposition = 3 or 4, it is closer to the original file (it is actually incredibly accurate).
	durGrain = waitTime * superposition; //The duration of the grain is calculated with the wait time and superposition. It could also work to stablish a fixed value for the duration of the grains, so the waitTime and superposition would depend on it.

	inf.do({
		position = (position + waitTime) % durBuffer; //We obtain again the grains in chronological order, this time depending on the waiting time, but it could have been the duration of the grain as mentioned before, if fixed.

		s.bind({
			Synth(\grain2,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, 1,
					\position, position * 44100,
					\amp, 0.5
			])
		});
		waitTime.wait;
	});
}).play
)

//TIME-STRETCHING
//Consists of speeding up or slowing down the audio without altering the pitch (use the same granulator and buffer as above in this section):

(
Routine({
	var durBuffer, durGrain, position = 1, rate, waitTime, superposition, stretch;

	durBuffer = c.duration;
	waitTime = 0.02; //The higher the waiting time, the more perceptible the separation between the grains.
	superposition = 3;
	durGrain = waitTime * superposition;
	stretch = 0.5; //The system works as an inversion of the rate values we used in the previous granulators: 2 for half speed (slower), 0.5 for double (faster), etc.

	inf.do({
		position = (position + (waitTime/stretch)) % durBuffer; //Here is the trick for the stretch (only working with really small waiting times): for example, if the stretch is 0.5, the next position will be added only half of the waiting time with each grain, so it will advance at half of the normal speed. If the stretch is 2, it will add double the waiting time, so it will advance at double speed.

		s.bind({
			Synth(\grain2,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, 1, //No rate deviation.
					//\rate, 1 * rrand(0.975, 1.025), //With deviation (see below the explanation in the waiting time):
					\position, position * 44100,
					\amp, 0.5
			])
		});
		(waitTime * rrand(0.95, 1.05)).wait; //In order to get rid of possible sonic artifacts, we can add some irregularity to the waiting time so there is no periodicity and resonances derived from it. There is a little deviation applied, between 5% higher and lower from the chosen waiting values. A more agressive deviation could be applied, for example: rrand(0.975, 1.025). Also no deviation could be good. It all depends on the specific audio and the way we process it. This deviation can be also applied to the rate value above. This process is called time wrap (or rate wrap).
		//waitTime.wait //Different harmonics indeed: there is a big difference.
	});
}).play
)

//PITCH-SHIFTING
//On the other hand, changing the pitch (the rate) of the audio without speeding it up or slowering it down: now that the speed depends on the stretch variable, the rate will be applied without altering the speed (I guess the level of perforation of the sound is responsible of this). There are a lot of sonic artifacts: try different deviations or none (as shown before), but remember that even the plugins for pitch-shifting produce sonic artifacts:
//Now you can combine both processes, for example, slowing down the audio, but raising the pitch at the same time:

(
Routine({
	var durBuffer, durGrain, position = 1, speed, waitTime, superposition, stretch;

	durBuffer = c.duration;
	waitTime = 0.02;
	superposition = 3;
	durGrain = waitTime * superposition;
	stretch = 1; //stretch = 1: no time-stretch.
	speed = 2; //0.5 = octave down, 2 = octave up, and so on. You can use the interval relationships with .midiratio.

	inf.do({
		position = (position + (waitTime/stretch)) % durBuffer;

		s.bind({
			Synth(\grain2,s
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, speed,
					\position, position * 44100,
					\amp, 0.5
			])
		});
		(waitTime * rrand(0.975, 1.025)).wait; //Again, try without the deviation or apply the deviation to other parameters.
	});
}).play
)

//One last experiment adding several synths featuring different rates at the same time to create a chord (it works pretty well applying a different delay to each synth too): each synth features a different pitch-shifting (one featuring the original tuning, for example, the rest using the interval relationships with .midiratio. The amplitudes could be also adjusted to create a balance depending on the pitch (be aware of the addition of Synths):
(
Routine({
	var durBuffer, durGrain, position = 1, speed, waitTime, superposition, stretch;

	durBuffer = c.duration;
	waitTime = 0.02;
	superposition = 3;
	durGrain = waitTime * superposition;
	stretch = 1;
	speed = 1;

	inf.do({
		position = (position + (waitTime/stretch)) % durBuffer;

		s.bind({
			Synth(\grain2,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, speed,
					\position, position * 44100,
					\amp, 0.4
			]);
			Synth(\grain2,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, speed * 4.midiratio,
					\position, position * 44100,
					\amp, 0.4
			]);
			Synth(\grain2,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, speed * 7.midiratio,
					\position, position * 44100,
					\amp, 0.4
			]);
		});
		(waitTime * rrand(0.975, 1.025)).wait;
	});
}).play
)

///////////////////////////////////////////////////////////////////////////
//SUMMARY: BASIC MODEL OF GRANULATOR (to be modified and extended):

b = Buffer.read(s, )

(
SynthDef(
	\grain,
	{ arg bufnum, position, speed, dur, pan, amp = 0.5;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan);

		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);

		OffsetOut.ar(0, signal * env)

}).add
)

(
Routine ({
	var durBuffer, durGrain, position, speed = 1;

	durBuffer = b.duration;

	inf.do({

		durGrain = rrand(0.0, durBuffer);
		position = rrand(0, durBuffer - durGrain) * 44100;

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position,
					\speed, rrand(0.5, 1),
					\dur, durGrain,
					\pan, rrand(-1.0, 1.0)
			]);
		});
		rrand(0.05, 0.5).wait

	});
}).play
)