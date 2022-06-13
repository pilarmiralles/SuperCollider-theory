//12 - GRANULAR SYNTHESIS
//////////////////////////////

//The objective here is to create our own granulators instead of using the UGens already prepared for such a purpose. The advantage of this is to be able to control every single parameter, being conscious of the background process.
//We will work from a buffer (digital sound file), but it is possible to create an alternative source of sound (synthesizer, for example) to be granulated.

p = Platform.resourceDir +/+ "sounds/a11wlk01.wav" //Deafult sound from SC library.

b = Buffer.read(s, p) //Into the buffer.
b.numChannels //It's a mono signal in this case.

//Here our grain producer, the "chopping machine": Playbuf, panning, and an envelope (similar to our algorithmic routines):

(
SynthDef(
	\grain,
	{ | bufnum, position, rate, dur, pan, amp = 0.1 |
		var signal, env;

		signal = PlayBuf.ar(1, bufnum, rate, 1, position); //Mono signal. This won't be able to be changed (no change in the size of arrays within SynthDefs). The trigger also needs a 1 to start playing right away. We always create an argument for the bufnum so it can be assigned by the server.
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);

		OffsetOut.ar(0, signal * env) //We use OffsetOut when creating more than 20-50 synths per second, more or less (for fast pace and short durations = grains). But this UGen is equivalent to Out.ar. OffsetOut sets a delayfor the synths to be read (interpreted) by the server, which is usually performed in kontrol blocks (each 64 values). But if the reading process of the Synths is as fast as 20-50 Hz or above, then we'll obtain a frequency out of the fast periodicity. The delay of OffsetOut avoids precisely this, despite reading the synths in blocks of 64.
}).add
)

//This is an isolated grain (we obtain just one each time it is evaluated): the duration of the grain is 0.1 seconds here. They can be longer or shorter, or randomized within a certain range, etc. There is no rule, but the traditional average is 0.05 to 0.1 secs.

Synth(\grain, [\bufnum, b.bufnum, \position, 1 * 44100, \rate, 1, \dur, 0.1, \pan, 0 ])

//Now we need a routine so the grains appear one after another (or overlapping each other). Observe what happens to the number of synths in the CPU manu below the postwindow. Take into consideration that all arguments and parameters can be modified according to your taste and necessities. This is just one example. Also, observe where is each argument being sent within the SynthDef above:

(
Routine ({
	var durBuffer, durGrain, position, rate = 1;

	durBuffer = b.duration; //The total duration of the audio file is asked in here in seconds. Then it will pass to the loop.

	inf.do({

		durGrain = rrand(0.0, durBuffer); //The duration of each grain is random from 0 to the total duration of the buffer (be aware of this if the used audio is longer).
		position = rrand(0, durBuffer - durGrain) * 44100; //The position is calculated in no. of frames, hence the number of the seconds is multiplied by the sample rate (44100). The position is random from the beginning of the audio file up to the end (substracting the length of the grain so it does not run out of audio file).

		s.bind({ //s.bind can only be around the Synth, which will help the server reading the synths.
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position,
					\rate, rate, //The rate can be randomized (for example, using a rrand (0.5, 2), or rrand(1, 7.midiratio), in order to used specific intervals).
					\dur, durGrain,
					\pan, rrand(-1.0, 1.0), //The panning is random from -1 to 1.
					\amp, 0.1
			]);
		});
		//1.wait //There is the same space between each grain: this is called synchronic synthesis. This separation would be too long for traditional granular synthesis (it is more like a random routine). Try the option below:
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

		s.bind({ //Without the s.pind it is much irregular. But changing OffsetOut makes a smaller difference.
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

{SinOsc.ar(689.0625, 0, 0.1)}.play

//When the audio file within the buffer is already stereo, using Pan.ar is not necessary to obtain sound through both channels. On the other hand, if the panning needs to be applied to a stereo signal, we have to take only one of the signals of the array. Using signal = signal[0] after the Playbuf is enough to obtain a mono signal to be distributed.
//Other variants include using several buffers and creating a variable which randomly chooses among them (remember that all arguments dependant on the buffer should be now dependant on that variable, for example, the bufnum).

//Next example includes superposition and its objective is to playthe grains in chronological order:
(
Routine ({
	var durBuffer, durGrain, position, rate = 1, superposition; //Falta por averiguar qué sería el tiempo de espera, pero al menosya suena.

	durBuffer = b.duration;
	position = 0;
	rate = [1, 0.5, 0.25, 2, 0.25, 2.6, 3.2]; //Array of different rate values.

	inf.do({ | i |

		i.postln;
		durGrain = 1; //The duration could be randomized.
		superposition = 3; //This avoids noticing the gap between grains: now the position and the wait time will be 3 times shorter than the duration of the grain, so there will be 3 grains where only 1 was expected.
		position = durGrain / superposition;

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position * 44100, //The position is defined before the wait, so we need a default value as first value (stated above, before the loop), then, the position is read in frames, so we need to multiply by 44100 (sample rate).
					\rate, rate[i % (rate.size - 1)], //The argument "i" (index) will give the number of the indexes of the rates array, and will be kept within the number of rate values thanks to the module of rate.size - 1 (because the last index is the number of items - 1 --> It could be easier to use the method .lastIndex instead of .size). Thus, each grain will feature a new speed (this could also have been done with a pattern).
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
//Let's prepare a longer buffer to try out the different examples:

b = Buffer.read(s, "F:/DOCUMENTOS/1 SIBELIUS 2021-22/SC y Compo Electro/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/12 - Audio example 1 for granular.wav")
b.numChannels //Stereo signal.

//This first one is an example of using a stereo signal with panning (taking just one of the sides of the stereo array). Then, there is superposition as well, but the position is random, unlike the former example:
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
	var durBuffer, durGrain, position, rate = 1, superposition;

	durBuffer = b.duration;

	inf.do({

		durGrain = rrand(1.0, 5);
		superposition = 3;
		position = rrand(0, durBuffer - durGrain) / superposition;

		s.bind({
		Synth(
			\stereoGrain,
			[
				\bufnum, b.bufnum,
				\position, position * 44100,
				\rate, rrand(0.8, 1.2),
				\dur, durGrain,
				\pan, rrand(-0.6, 0.6)
		]);
		});
		rrand(0.5, 1.5).wait
	});
}).play
)

//Applying reverb and other processes on top of our original signal (after granulating it) --> For instance, reverb (other options are a filter, distortion, any modulation that would affect all grains at the same time, etc.): we have to connect the out of our original signal to a private channel, which will be taken by the second SeynthDef (which will apply the process). Here also using two different buffers randomly chosen:
(
b = Buffer.read(s, "F:/DOCUMENTOS/1 SIBELIUS 2021-22/SC y Compo Electro/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/12 - Audio example 1 for granular.wav");
c = Buffer.read(s, "F:/DOCUMENTOS/1 SIBELIUS 2021-22/SC y Compo Electro/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/12 - Audio example 2 for granular.wav")
)

( //The result with this two audio files is sooo weird XD. I saved a recorded excerpt in the folder of examples.
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
		signal = GVerb2.ar(input);
		OffsetOut.ar(0, signal)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, rate = 1, superposition, buffer;


	position = 0;

	Synth(\reverb, [ \in, 4 ]);
	inf.do({

		buffer = [ b, c ].choose;
		durBuffer = buffer.duration;
		durGrain = 1;
		superposition = 4;
		position = (rrand(0, durBuffer - durGrain)) / superposition;

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

//A similar example, applying a filter instead (just the second buffer):

c = Buffer.read(s, "F:/DOCUMENTOS/1 SIBELIUS 2021-22/SC y Compo Electro/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/12 - Audio example 2 for granular.wav")

(
SynthDef(
	\grainFilter,
	{ arg out, position, rate, dur, amp = 0.4;
		var signal, env, signalOut;

		signal = PlayBuf.ar(2, c.bufnum, rate, 1, position);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);

		signalOut = signal * env;

		OffsetOut.ar(out, signalOut)

}).add;
SynthDef(
	\filter,
	{ arg in, rq, filterAmp;
	 var input, signal, freqs;

		freqs = Array.geom(6, 25.midicps, 2) ++ Array.geom(5, 29.midicps, 2) ++ Array.geom(5, 32.midicps, 2);

		input = In.ar(in, 2);
		signal = {Mix(
			BPF.ar(
				input,
				freqs,
				rq,
				filterAmp
			)
		)} !2;

		OffsetOut.ar(0, signal)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, rate = 1, superposition, buffer;

	position = 0;

	Synth(\filter, [ \in, 6, \rq, 0.01, \filterAmp, 2 ]); //Try different values of RQ: 0.08 or 0.5, a bit rougher. 0.1 cleaner (but the narrower, the more amp is needed).

	inf.do({

		durBuffer = c.duration;
		durGrain = 1;
		superposition = 25;
		position = (rrand(0, durBuffer - durGrain)) / superposition;

		s.bind({
			Synth(
				\grainFilter,
				[
					\position, position * 44100,
					\rate, 1,
					\dur, durGrain,
					\amp, 0.5,
					\out, 6
			]);
		});

		rrand(0.05, 0.1).wait

	});
}).play
)

//


//Model of granular routine which follows the chronological development of the audio files (here mixing three possible buffers, but not needed):
(
b = Buffer.read(s, "file1");
c = Buffer.read(s, "file2");
d = Buffer.read(s, "file3")
)

( //Info:
[b.duration, b.numChannels].postln;
[c.duration, c.numChannels].postln;
[d.duration, d.numChannels].postln;
[]
)

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, speed, dur, pan, amp = 0.4;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan); //Could use the pan.
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env)
}).add;
SynthDef(
	\reverb,
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
	var durBuffer, durGrain, position, speed = 1, buffer, whichBuffer; //No superposition.


	position = 0;

	Synth(\reverb, [ \in, 4, \time, 0.5, \masterVolume, 1.2 ], s, 'addToTail');

	position = Pseg((0, 1..(134 - 9)), 1.5, 'lin', inf).asStream.trace; //This is an envelope for the position so it is just going straight instead of jumping randomly (I calculated the buf duration - of the shortest buffer - and substracted the maximum duration of the grain (which is random).

	buffer = Pwrand([b, c], [6, 3].normalizeSum, inf).asStream; //For now, without the third buffer.

	inf.do({

		whichBuffer = buffer.next;

		durBuffer = whichBuffer.duration;
		durGrain = (3, 3.5..8.5).wchoose((1, 2..12).normalizeSum); //If you wanna use longer or shorter grains, modify the wait time of the routine so the gaps between the entries are still the same (unless you also want each sound to be closer to next one, or even to overlap).
		//position = (rrand(0, durBuffer - durGrain));



		s.bind({
			Synth(
				\grain,
				[
					\bufnum, whichBuffer.bufnum,
					\position, position.next * 44100,
					\speed, (0.9, 0.95..1.1).wchoose((0.9, 0.95..1.1).normalizeSum), //This modifies the tuning of the buffers.
					\dur, durGrain,
					\pan, rrand(-0.6, 0.6),
					\amp, 0.8,
					\out, 0

			],
				s, 'addToHead'
			);

		});

		((3, 3.5..5.5).wchoose((1, 2..6).normalizeSum)).wait

	});
}).play
)

////////////////////////////////////////////////////////////////////////////

//PITCH-SHIFTING AND TIME-STRETCHING (USING GRANULAR SYNTHESIS):
//We will use this basic granulator:

c = Buffer.read(s, "F:/DOCUMENTOS/1 SIBELIUS 2021-22/SC y Compo Electro/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/12 - Audio example 2 for granular.wav")

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

//Here we create 50 grains per second instead of the continuous sound of the audio file: the different superposition values will affect the accuracy:
(
Routine({
	var durBuffer, durGrain, position = 1, rate, waitTime, superposition;

	durBuffer = c.duration;
	waitTime = 0.02; //Fixed value for the time between the grains: try out waitTime = 1 to see how the grains are taken in order.
	superposition = 3; //With no superposition (1), the audio seems to be perforated, damaged. With 3 or 4 of superposition, it is closer to the original file (it is incredibly accurate).
	durGrain = waitTime * superposition; //The duration of the grain is calculated with the wait time and superposition. It could also work to stablish a fixed value for the duration of the grains, so the waitTime would depend on it and the superposition (as practiced in the examples before).

	inf.do({
		position = (position + waitTime) % durBuffer; //We obtain again the grains in chronological order, this time depending on the waiting time, but it could have been the duration of the grain as before, if fixed.

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
//Consists of speeding up or slowing down the audio without altering the pitch (use the same granulator and buffer):

(
Routine({
	var durBuffer, durGrain, position = 1, rate, waitTime, superposition, stretch;

	durBuffer = c.duration;
	waitTime = 0.02; //The higher the waiting time, the more perceptible the separation between the grains.
	superposition = 3;
	durGrain = waitTime * superposition;
	stretch = 0.5; //Use values similar to the rate values: 2 for half speed, 0.5 for double, etc.

	inf.do({
		position = (position + (waitTime/stretch)) % durBuffer; //Here is the trick for the stretch (only working with really small waiting times): the next position will skip half of the waiting time with each grain, so it will advance at double the speed.

		s.bind({
			Synth(\grain2,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, 1, //Without deviation.
					//\rate, 1 * rrand(0.975, 1.025), //With deviation (see below the explanation in the waiting time).
					\position, position * 44100,
					\amp, 0.5
			])
		});
		(waitTime * rrand(0.95, 1.05)).wait; //In order to get rid of possible sonic artifacts, we can add some irregularity to the waiting time so there is no periodicity and resonances derived from it. There is a little deviation applied, a 5% higher and lower from the chosen waiting values. A more agressive deviation could be applied, for example: rrand(0.975, 1.025). Also no deviation could be good. It all depends on the specific audio. This deviation can be also applied to the rate values above. This process is called time wrap (or rate wrap, etc.).
		//waitTime.wait //Different harmonics indeed HAHAHAHA.
	});
}).play
)

//PITCH-SHIFTING
//On the contrary, changing the pitch (the rate) of the audio without speeding it up or slowering it down: now that the rate depends on the stretch variable, the rate will be applied without altering the speed. There are a lot of sonic artifacts, try different deviations or none, but remember that even the plugins for pitch-shifting produce sonic artifacts:
//Now you can combine both processes, for example, doubling the speed of the audio, but raising the pitch at the same time:

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
			Synth(\grain2,
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

//One last experiment adding several synths at the same time to create a chord (it works pretty well applying a different delay to each synth too): each synth features a different pitch-shifting (one featuring the original tuning, for example, the rest using the interval relationships with .midiratio. You shouls also adjust the amplitudes (can create a balance depending on the pitch):
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
					\position, position * 44100
			]);
			Synth(\grain2,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, speed * 4.midiratio,
					\position, position * 44100
			]);
			Synth(\grain2,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, speed * 7.midiratio,
					\position, position * 44100
			]);
		});
		(waitTime * rrand(0.975, 1.025)).wait;
	});
}).play
)

///////////////////////////////////////////////////////////////////////////
//SUMMARY: BASIC MODELS OF GRANULATORS (to be extended and modified):

//GRANULATOR WITH SUPERPOSITION (for stereo files):
b = Buffer.read(s, )

(
SynthDef(
	\grain,
	{ arg bufnum, position, speed, dur, amp = 0.5;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);

		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);

		OffsetOut.ar(0, signal * env)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, speed = 1, superposition;

	durBuffer = b.duration;
	position = 0;

	inf.do({

		durGrain = 3;
		superposition = 4;
		position = (rrand(0, durBuffer - durGrain)) / superposition;

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position * 44100,
					\speed, rrand(0.5, 2),
					\dur, durGrain,
					\amp, 0.5
			]);
		});
		rrand(0.05, 0.1).wait

	});
}).play
)


//GRANULATOR WITHOUT SUPERPOSITION (for stereo files):
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