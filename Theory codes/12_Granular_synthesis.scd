//12 - GRANULAR SYNTHESIS

/////////////////////////////////////////////////////////////////////
//CREATING A GRANULATOR

//The objective here is to create our own granulator using the SynthDef-Routine combo while using audio samples as input instead of audio synthesis processes. The audio samples are cur into pieces and different parameters are randomized in order to create different textures that can change over time. This does not only allow us to play around with granular synthesis (very small grains) but also to work with bigger chuncks of the audio samples (bigger than the "conventional" size of a grain in granular synthesis).
//Of course, there are UGens in SC for granular synthesis, being TGrains one of the most commonly used. The advantage of creating a granulator from scratch is to learn how granular synthesis works and to be able to control every single detail of the process.

//Building a granulator:
p = Platform.resourceDir +/+ "sounds/a11wlk01.wav" //Very ugly default audio sample from SC (good for testing as it is available in every computer where SC has been downloaded).

b = Buffer.read(s, p) //Allocating the buffer and reading the sample into it.
b.query //Information about the buffer "b".
b.duration //Duration of the buffer ( = numFrames / sampleRate).

//Here is the granulator (or rather chopper):
(
SynthDef(
	\grain,
	{ |bufnum, position, rate, dur, pan, amp = 0.1|
		var signal, env;

		//We only need a signal, which will be our audio sample (using PlayBuf here to play it), and an envelope (a sine envelope is conventionally used for granular synthesis, but any other kind of envelope can be tested):

		signal = PlayBuf.ar(1, bufnum, BufRateScale.kr(bufnum) * rate, 1, position); //The rate receives the object BufRateScale applied to the specific buffer number in order to compensate the possible difference of sampling rate (between the audio sample and the one stablished in SC). This should not be always needed and we will see examples without it (but it is the way to go if the post window points out a problem related to dealing with different sampling rates).
		//signal = signal[0]; //In case the audio sample has two channels and want to apply panning to it, we can just select one channel of it with this line (taking the first index of the array of channels).
		signal = Pan2.ar(signal, pan);

		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);

		OffsetOut.ar(0, signal * env) //Using OffsetOut: when creating something above 20 synths per second, it is possible that a frequency spectrum is generatesd out of this periodicity. OffsetOut helps to avoid this by creating a small delay when the synths are sent to the server based on the control cycles (see its Help file).

}).add
)

Synth(\grain, [\bufnum, b.bufnum, \position, 2 * 44100, \rate, 1, \dur, 0.1, \pan, 0]) //Isolated grain for testing (remember that the position is measured in frames, so it will be equal to the time in seconds * sampling rate.

( //The Routine will successively create grains and randomize parameters from the granulator (SynthDef):
r = Routine({
	var durBuffer, durGrain, position, rate = 1;

	durBuffer = b.duration;

	inf.do({

		durGrain = rrand(0.0, durBuffer); //In this case, the duration of each grain can go from 0 to the total duration of the buffer (around 4 seconds).
		//durGrain = rrand(0.01, 0.2); //Alternative for the durGrain (random short grains, for instance).

		position = rrand(0, durBuffer - durGrain) * 44100; //The position could be anywhere from 0 to the duration of the sample, but subtracting the duration of the current grain so that it does not exceed the total duration of the sample. Then, it is converted to frames by multiplying it by the sampling rate.

		s.bind({ //Yet another tool to control the large amount of synth in a short duration that is usual in granular synthesis. The method .bind refers to the server ("s") and is related with its latency in order to deal with timing inaccuracies when transmitting lots of OSC messages in a short period of time. This is not always needed, but just a preventive measure.
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position,
					\rate, rate, //The rate could be randomized: rrand(0.5, 2) or rrand(1.midiratio, 7.midiratio), for example, if working with intervals.
					\dur, durGrain,
					\pan, rrand(-1.0, 1.0), //Randomized panning.
					\amp, 0.1
			]);
		});

		//0.1.wait //"Synchronous" granular synthesis.
		rrand(0.01, 0.1).wait //"Asynchronous" granular synthesis (randonmized waiting time between grains).
	});
}).play
)
r.stop

//Example with a fixed position: try out the routine with no s.bind, then try out changing the OffsetOut by Out in the SynthDef to see how it changes:
(
r = Routine({
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
r.stop


//Another example (same SynthDef) using two audio samples (change the paths according to your own machine):
(
c = Buffer.read(s, "F:/DOCUMENTOS/!SUMMER 23 - PREPARATORY YEAR 23-24/SUPERCOLLIDER/THEORY CODES/Audio-for-granular-examples-1.wav");
d = Buffer.read(s, "F:/DOCUMENTOS/!SUMMER 23 - PREPARATORY YEAR 23-24/SUPERCOLLIDER/THEORY CODES/Audio-for-granular-examples-2.wav")
)

( //Same SynthDef, just adding the line to take one of the two channels of the audio samples so that they can be panned:
SynthDef(
	\grain2,
	{ |out = 0, bufnum, position, rate, dur, pan, amp = 0.1|
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan);

		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);

		OffsetOut.ar(out, signal * env)

}).add;
/*
SynthDef( //Possible use of this second SynthDef to pass the previous output through a private channel and apply a reverb to it:
	\reverb,
	{ |in, mix, room, mul|
	 var input, signal;

		input = In.ar(in, 2);
		signal = FreeVerb.ar(input, mix, room, mul: mul);
		OffsetOut.ar(0, signal)
}).add
*/
)

(
r = Routine({
	var buffer, durBuffer, durGrain, position, rate = 1, superposition;

	position = 0; //Initial value for the position as the position is reassigned a the end of the loop (this will only affect the frist grain).

	//This is the line we would need to pass the samples through the reverb (also, change the out value from 0 to private channel 4):
	//g = Synth(\reverb, [\in, 4, \mix, 0.7, \rev, 0.8, \mul, 1.2], s, 'addToTail');

	inf.do({

		buffer = [c, d].choose; //Choosing a random sample among both buffers.

		durBuffer = buffer.duration;
		durGrain = rrand(0.5, 2.5);
		superposition = 3; //This new variable will be used at the waiting time so that it is, in this case, three times shorter than the duration of the current grain, provoking the superposition or overlapping of grains.
		//Superposition can occur also just by simply using grain durations longer than the waiting time.

		s.bind({
			Synth(
				\grain2,
				[
					\bufnum, buffer.bufnum,
					\position, position * 44100,
					\rate, (0.9, 0.95..1.1).wchoose((0.9, 0.95..1.1).normalizeSum), //Choosing the rate with a specific probability for each value.
					\dur, durGrain,
					//\pan, rrand(-0.8, 0.8),
					\pan, 0, //I like it better with no random pos when no reverb.
					\amp, 0.5,
					\out, 0 //reverb = 4, no reverb = 0.

				], s, 'addToHead'
			);
		});

		//This way, we are able to make the sample advance "in order": the new position will always be the current position + 1, up to the duration of the buffer (by applying the module, so that it wraps when exceeding its value):
		position = (position + 1) % durBuffer;
		//position = (position + durGrain) % durBuffer; //Just another option.

		(durGrain / superposition).wait //Posible superposition.
		//durGrain.wait //No superposition.
	});
}).play
)

r.stop
c.free; d.free
//If using the reverb, the reverb synth will be still running after using r.stop, as it does not feature doneAction. Should use also g.free then (after stopping the routine, so that the reverb does not suddenly disappear in whatever is left).


/////////////////////////////////////////////////////////////////////
//PITCH-SHIFTING AND TIME-STRETCHING (USING A GRANULATOR)

//We can extend the use of our granulator to play around with pitch-shifting and time stretching. We need a basic granulator for this:

e = Buffer.read(s, "F:/DOCUMENTOS/!SUMMER 23 - PREPARATORY YEAR 23-24/SUPERCOLLIDER/THEORY CODES/Audio-for-granular-examples-2.wav") //Remember to adapt the path.

(
SynthDef(
	\grain3,
	{ | bufnum, position, rate, dur, amp = 0.1 |
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position); //Prepared for a stereo signal (if applying panning, remember to take only signal[0]).
		env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);

		OffsetOut.ar(0, signal * env)

}).add
)

//The strategy consists of creating a lot of short grains per second that will "reconstruct" the continuous audio file: the superposition value will help to cover the spaces in between and create an accurate "fake continuity" of the sound:
(
r = Routine({
	var durBuffer, durGrain, position = 1, rate, waitTime, superposition; //We need the position to have a default (and initial) value.

	durBuffer = e.duration;
	waitTime = 0.02; //Fixed value for the time between the grains.
	superposition = 3; //With no superposition (= 1), the audio seems to be perforated, damaged. With superposition = 3 or 4, it is closer to the original file (it is actually incredibly accurate).
	durGrain = waitTime * superposition; //The duration of the grain is calculated with the wait time and superposition. It could also work to stablish a fixed value for the duration of the grains, so that the waitTime and superposition would depend on it.

	inf.do({
		position = (position + waitTime) % durBuffer; //We obtain again the grains in chronological order, this time depending on the waiting time, but it could have been the duration of the grain as mentioned before, if fixed.

		s.bind({
			Synth(\grain3,
				[
					\bufnum, e.bufnum,
					\dur, durGrain,
					\rate, 1, //Changing the rate won't affect anymore the speed of the audio. We'll see why in the upcoming examples.
					\position, position * 44100,
					\amp, 0.5
			])
		});
		waitTime.wait;
	});
}).play
)
r.stop

//Let's use this Routine model to implement the two processes:


//TIME-STRETCHING
//Consists of speeding up or slowing down the audio without altering the pitch (use the same granulator and buffer as above in this section):
(
r = Routine({
	var durBuffer, durGrain, position = 1, rate, waitTime, superposition, stretch;

	durBuffer = e.duration;
	waitTime = 0.02; //The higher the waiting time, the more perceptible the separation between the grains.
	superposition = 3;
	durGrain = waitTime * superposition;
	stretch = 0.5; //The system works as an inversion of the rate values we used in the previous granulators: 2 for half speed (slower), 0.5 for double (faster), etc.

	inf.do({
		position = (position + (waitTime/stretch)) % durBuffer; //Here is the trick for the stretch (only if working with really small waiting times): for example, if the stretch is 0.5, the next position will be added double the waiting time with each grain, so it will advance at double the normal speed (faster). If the stretch is 2, it will add cur the waiting time in half, so it will advance at half the speed (slower).

		s.bind({
			Synth(\grain3,
				[
					\bufnum, e.bufnum,
					\dur, durGrain,
					\rate, 1, //No rate deviation.
					//\rate, 1 * rrand(0.975, 1.025), //With deviation (see below the explanation in the waiting time):
					\position, position * 44100,
					\amp, 0.5
			])
		});
		(waitTime * rrand(0.95, 1.05)).wait; //In order to get rid of possible sonic artifacts, we can add some irregularity to the waiting time so there is no periodicity and resonances derived from it. There is a little deviation applied, between 5% higher and lower from the chosen waiting values. A less agressive deviation could be tried out, for example, rrand(0.975, 1.025). Also no deviation could be good. It all depends on the specific audio and the way we process it. This deviation can be also applied to the rate value above. This process is called time wrap (or rate wrap).
		//waitTime.wait //Different harmonics indeed: there is a big difference if trying it out without the time wrap.
	});
}).play
)
r.stop


//PITCH-SHIFTING
//On the other hand, changing the pitch (the rate) of the audio without speeding it up or slowering it down: because the position depends on the waitTime and the stretch, the rate of the grains can feature a different rate without affecting the pace at which the grains happen (which is set by the position). Nonetheless, there are a lot of sonic artifacts: try different deviations or none (as shown before), I am still trying to understand and polish this.
//Now you can combine both processes (for example, slowing down the audio, but raising the pitch at the same time):
(
r = Routine({
	var durBuffer, durGrain, position = 1, speed, waitTime, superposition, stretch;

	durBuffer = e.duration;
	waitTime = 0.02;
	superposition = 4;
	durGrain = waitTime * superposition;
	stretch = 1; //stretch = 1: no time-stretch.
	speed = 1.2; //0.5 = octave down, 2 = octave up, and so on. You can use the interval relationships with .midiratio.

	inf.do({
		position = (position + (waitTime/stretch)) % durBuffer;

		s.bind({
			Synth(\grain3,
				[
					\bufnum, e.bufnum,
					\dur, durGrain,
					\rate, speed,
					\position, position * 44100,
					\amp, 0.5
			])
		});
		(waitTime * rrand(0.975, 1.025)).wait; //Again, try without the deviation or apply the deviation to other parameters.
		//waitTime.wait //Sounds a bit like old and detuned.
	});
}).play
)

r.stop

//One last experiment adding several synths featuring different rates at the same time to create a chord (it works pretty well when applying a different delay to each synth too): each synth features a different pitch-shifting (one featuring the original tuning, for example, the rest using the interval relationships with .midiratio). The amplitudes could be also adjusted to create a balance depending on the pitch (be aware of the addition of amplitudes as the principle is that, when multiple Synths write to the same bus, their output is summed (i.e. mixed)):
(
r = Routine({
	var durBuffer, durGrain, position = 92, speed, waitTime, superposition, stretch; //Starting from voice section :D sounds psychedelic.

	durBuffer = e.duration;
	waitTime = 0.02;
	superposition = 3;
	durGrain = waitTime * superposition;
	stretch = 0.8;
	speed = 1;

	inf.do({
		position = (position + (waitTime/stretch)) % durBuffer;

		s.bind({
			Synth(\grain3,
				[
					\bufnum, e.bufnum,
					\dur, durGrain,
					\rate, speed,
					\position, position * 44100,
					\amp, 0.4
			]);
			Synth(\grain3,
				[
					\bufnum, e.bufnum,
					\dur, durGrain,
					\rate, speed * 4.midiratio,
					\position, position * 44100,
					\amp, 0.35
			]);
			Synth(\grain3,
				[
					\bufnum, e.bufnum,
					\dur, durGrain,
					\rate, speed * 7.midiratio,
					\position, position * 44100,
					\amp, 0.3
			]);
		});
		(waitTime * rrand(0.975, 1.025)).wait;
	});
}).play
)

r.stop
e.free
