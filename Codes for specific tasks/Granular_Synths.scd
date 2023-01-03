//GRANULAR SYNTHESIS SYNTHS:
/////////////////////////////////////

//Distortion, pitch modulation and delay between synths:
b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/Audio-for-granular-examples-1.wav")
b.numChannels
b.duration

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, rate, dur, amp = 0.1, pan = 0, latch = 12000;
		var signal, env;

		signal = Latch.ar(PlayBuf.ar(2, bufnum, rate, 1, position), Impulse.ar(latch));
		signal = signal[0];
		signal = Pan2.ar(signal, pan);

		env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);

		OffsetOut.ar(out, signal * env)
}).add;
SynthDef(
	\reverb,
	{ arg in, time;
		var input, dry, wet, signalOut;

		input = In.ar(in, 2);

		dry = input;

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !8
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		signalOut = dry + LPF.ar(wet, 2000);

		OffsetOut.ar(0, signalOut)

}).add
)

(
Routine({
	var durBuffer, durGrain, position = 0, rate, waitTime, superposition, stretch;

	Synth(\reverb, [ \in, 4, \time, 2.2 ], s, \addToTail);

	durBuffer = b.duration;
	waitTime = 0.02;
	superposition = 4;
	durGrain = waitTime * superposition;
	stretch = 0.5;
	rate = 1.5;

	inf.do({
		position = (position + (waitTime/stretch)) % durBuffer;
		s.bind({
			Synth(\grain,
				[
					\bufnum, b.bufnum,
					\dur, durGrain,
					\rate, rate,
					\out, 4,
					\pan, 0,
					\latch, 16000,
					\position, position * 44100
			],
				s, 'addToHead'
			);
			Synth(\grain,
				[
					\bufnum, b.bufnum,
					\dur, durGrain,
					\rate, rate * 5.midiratio,
					\out, 4,
					\pan, -0.8,
					\latch, 10000,
					\position, (position + 0.2) * 44100
			],
				s, 'addToHead'
			);
			Synth(\grain,
				[
					\bufnum, b.bufnum,
					\dur, durGrain,
					\rate, rate * 10.midiratio,
					\out, 4,
					\pan, 0.8,
					\latch, 6000,
					\position, (position + 0.5) * 44100
			],
				s, 'addToHead'
			);
		});
		(waitTime * rrand(0.975, 1.025)).wait;
	});
}).play
)

///////////////////////////////////////////////////////////

//A very classic "granular synthesis":
(
SynthDef(
	\klankGrain,
	{arg out, freq = #[0, 0, 0, 0, 0, 0, 0, 0], dur, pan = 0, amp;
		var signal, env, signalOut;

		signal = Klank.ar(

			`[
				freq,
				Array.fill(10, { rrand(0.05, 0.2) }),
				Array.fill(10, { exprand(0.01, 0.1) }) * 20

			],

			PinkNoise.ar(0.1)
		);

		signal = Pan2.ar(signal, pan);

		env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);

		signalOut = signal * env;

		OffsetOut.ar(out, signalOut)
}).add;
SynthDef(
	\reverb,
	{ arg in, out = 0;
	 var input, signal;

		input = In.ar(in, 2); //Two channels so the panning is kept.
		signal = FreeVerb.ar(input, 0.7, 2, 1, 1);
		OffsetOut.ar(out, signal)

}).add
)

(
Routine(
	{
		var freqs, limiteInf;

		Synth(\reverb, [ \in, 4, \out, 0 ]);

		limiteInf = Pseq((100, 150..3000).mirror, inf).asStream;

		inf.do({

			freqs = {exprand(limiteInf.next, 10000)} !10;

			Synth(\klankGrain,
				[
					\freq, freqs,
					\dur, rrand(0.1, 0.7),
					\pan, rrand(-1, 1),
					\amp, rrand(0.3, 0.8),
					\out, 4
			]);

			rrand(0.01, 0.1).wait

		})
}).play
)

//////////////////////////////////////////////////////////////////////

//Latch distortion for audio samples:

//Better result if something without a constant rhythm is used (maybe for advertisements, speeches, etc.) --> MAINLY FOR VOICE!
b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/Audio-for-granular-examples-1.wav")

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, rate, dur, pan, amp = 0.1, latch = 12000;
		var signal, env;

		signal = Latch.ar(PlayBuf.ar(2, bufnum, rate, 1, position), Impulse.ar(latch));
		signal = signal[0];
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env)
}).add;
SynthDef(
	\reverb,
	{ arg in, time;
		var input, dry, wet, signalOut;

		input = In.ar(in, 2);

		dry = input;

		wet = Mix(
			{ CombC.ar(
				dry,
				0.035,
				rrand(0.025, 0.035),
				time,
				rrand(0.25, 0.5)
			)
			} !8
		);

		wet = LeakDC.ar(wet);

		4.do({wet = AllpassN.ar(wet, 0.05, { rrand(0.005, 0.05)} !2, time) });

		signalOut = dry + LPF.ar(wet, 1000);

		OffsetOut.ar(0, signalOut)

}).add
)

(
Routine ({
	var durBuffer, durGrain, position, speed = 1, latch = 12000;

	durBuffer = b.duration;
	position = 0;

	Synth(\reverb, [ \in, 4, \time, 2.5 ], s, \addToTail);

	latch = Prand((4000, 4500..11000), inf).asStream;

	inf.do({

		durGrain = rrand(4.0, 7);
		position = (rrand(100, durBuffer - durGrain)); //Trying to catch the sang part only to apply on the voice.

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\position, position * 44100,
					\rate, rrand(0.8, 1),
					\dur, durGrain,
					\amp, 0.3,
					\pan, rrand(-0.8, 0.8),
					\out, 4,
					\latch, latch.next

			],
				s, \addToHead
			);

		});

		rrand(1.0, 1.5).wait


	});
}).play
)

/////////////////////////////////////////////////////////////////////////////

//BASIC "GRANULATOR" (to alternate two buffers, or more):
(
b = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/Audio-for-granular-examples-1.wav");
c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/Audio-for-granular-examples-2.wav");
)

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, speed, dur, amp = 0.1;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env)
}).add;
SynthDef(
	\reverb,
	{ arg in, mix = 0.7, room = 1.5;
		var input, signalOut;

		input = In.ar(in, 2);

		signalOut = FreeVerb.ar(input, mix, room, 0.7);

		OffsetOut.ar(0, signalOut)

}).add
)

(
Routine ({
	var buffer, durBuffer, durGrain, position, speed = 1;

	position = 0;

	Synth(\reverb, [ \in, 4, \mix, 0.5, \room, 0.5 ], s, \addToTail);

	inf.do({ var amp = 0.8;

		buffer = [ b, c ].wchoose([5, 3].normalizeSum);

		durBuffer = buffer.duration;

		durGrain = rrand(3.5, 7);
		position = (rrand(0, durBuffer - durGrain));

		if(buffer == c, {amp = 1.5}, {amp = 0.8});

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, buffer.bufnum,
					\position, position * 44100,
					\speed, [ 1, 1.35, 1.5, 2 ].choose, //Rate (1) * 4.midiratio (Meaning the number of half tones of the interval), if specific interval needed.
					\dur, durGrain,
					\amp, amp,
					\out, 4

				],
				s, \addToHead
			);

		});

		rrand(0.5, 1.5).wait

	});
}).play
)

///////////////////////////////////////////////////////////////

//Very damaged (quite good, adjust clip according to the amp of the specific sample):
c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/Audio-for-granular-examples-1.wav")
c.numChannels

(
SynthDef(
	\grain,
	{ arg out = 4, bufnum, position, rate, dur, amp = 0.1;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, rate, 1, position);
		env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);
		OffsetOut.ar(out, signal * env)
}).add;
SynthDef(
	\dsp,
	{arg in = 4, out = 0, clip = 0.5;
		var input, signal;

		input = In.ar(in, 2);

		signal = input.clip2(clip);

		OffsetOut.ar(out, signal)
}).add
)

(
Routine({
	var durBuffer, durGrain, position = 0, rate, waitTime, waitTimeDev, superposition;

	Synth(\dsp, [\in, 4, \clip, 0.05], s, 'addToTail');

	durBuffer = c.duration;
	superposition = 4; //"Bad" sound (discontinuous, perforated) -> bad superposition (with 2 is perfect), but with 3 or 4 it's also very very interesting.

	waitTimeDev = Prand((0.01, 0.02..0.1), inf).asStream;

	inf.do({

		waitTime = waitTimeDev.next;
		durGrain = waitTime * superposition;
		position = (position + waitTime) % durBuffer;

		s.bind({
			Synth(\grain,
				[
					\bufnum, c.bufnum,
					\dur, durGrain,
					\rate, 1,
					\position, position * 44100,
					\amp, 0.8
			],
				s, 'addToHead'
			)
		});
		waitTime.wait;
	});
}).play
)

//////////////////////////////////////////////////////////

//Fading in and out randomly:
c = Buffer.read(s, "C:/Users/user/Desktop/MI PROPIA TEORÍA SC - 2022/SuperCollider-theory/Codes for specific tasks/Audio-for-granular-examples-2.wav");
c.duration

(
SynthDef(
	\grain,
	{ arg out, bufnum, position, speed, dur, pan, amp = 0.4;
		var signal, env;

		signal = PlayBuf.ar(2, bufnum, speed, 1, position);
		signal = signal[0];
		signal = Pan2.ar(signal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, signal * env)
}).add;
SynthDef(
	\reverb,
	{ arg in, time;
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

		OffsetOut.ar(0, finalSignal)
}).add
)

(
Routine ({
	var durBuffer, durGrain, position, speed = 1, buffer;

	position = 0;

	Synth(\reverb, [ \in, 4, \time, 0.5 ], s, 'addToTail');

	position = Pseg((0, 1..(261 - 9)), 1.5, 'lin', inf).asStream.trace; //This is an envelope for the position so it is just going straight instead of jumping randomly (I calculated the buf duration and substracted the maximum duration of the grain (which is random). Tracing position for testing only.

	inf.do({

		buffer = c; //Could alternate between two or more in here!!
		durBuffer = buffer.duration;
		durGrain = (3, 3.5..8.5).wchoose((1, 2..12).normalizeSum); //If you wanna use longer or shorter grains, modify the wait time of the routine so the gaps between the entries are still the same (unless you also want each sound to be closer to next one, or even to overlap).
		//position = (rrand(0, durBuffer - durGrain));

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, buffer,
					\position, position.next * 44100,
					\speed, (0.7, 0.8..1.4).wchoose((0.7, 0.8..1.4).normalizeSum),
					\dur, durGrain,
					\pan, rrand(-0.8, 0.8),
					\amp, 0.8,
					\out, 0 //No reverb now.

			],
				s, 'addToHead'
			);

		});

		((3, 3.5..8.5).wchoose((1, 2..12).normalizeSum)).wait

	});
}).play
)
