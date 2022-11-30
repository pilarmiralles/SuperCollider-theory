//GRANULAR SYNTHESIS SYNTHS:
/////////////////////////////////////

//Distortion, pitch modulation and delay between synths:
b = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/SPECIFIC CODES/!For granular examples.wav")
b.numChannels
b.duration

(
SynthDef(
	\grano,
	{ arg out, bufnum, posicion, velocidad, dur, amp = 0.1, pan = 0, latch = 12000;
		var senal, env;

		senal = Latch.ar(PlayBuf.ar(2, bufnum, velocidad, 1, posicion), Impulse.ar(latch));
		senal = senal[0];
		senal = Pan2.ar(senal, pan);

		env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);

		OffsetOut.ar(out, senal * env)
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
	var durBuffer, durGrano, posicion = 0, velocidad, tiempoEspera, superposicion, stretch;

	Synth(\reverb, [ \in, 4, \time, 2.2 ], s, \addToTail);

	durBuffer = b.duration;
	tiempoEspera = 0.02;
	superposicion = 4;
	durGrano = tiempoEspera * superposicion;
	stretch = 0.5;
	velocidad = 1.5;

	inf.do({
		posicion = (posicion + (tiempoEspera/stretch)) % durBuffer;
		s.bind({
			Synth(\grano,
				[
					\bufnum, b.bufnum,
					\dur, durGrano,
					\velocidad, velocidad,
					\out, 4,
					\pan, 0,
					\latch, 16000,
					\posicion, posicion * 44100
			],
				s, 'addToHead'
			);
			Synth(\grano,
				[
					\bufnum, b.bufnum,
					\dur, durGrano,
					\velocidad, velocidad * 5.midiratio,
					\out, 4,
					\pan, -0.8,
					\latch, 10000,
					\posicion, (posicion + 0.2) * 44100
			],
				s, 'addToHead'
			);
			Synth(\grano,
				[
					\bufnum, b.bufnum,
					\dur, durGrano,
					\velocidad, velocidad * 10.midiratio,
					\out, 4,
					\pan, 0.8,
					\latch, 6000,
					\posicion, (posicion + 0.5) * 44100
			],
				s, 'addToHead'
			);
		});
		(tiempoEspera * rrand(0.975, 1.025)).wait;
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
b = Buffer.read(s, "F:/DOCUMENTOS/1 Year 2022-2023/SUPERCOLLIDER/SPECIFIC CODES/!For granular examples.wav")

(//Granular synthesis with Schroeder and Latch (digital distortion):
SynthDef(
	\grain,
	{ arg out, bufnum, posicion, velocidad, dur, pan, amp = 0.1, latch = 12000;
		var senal, env;

		senal = Latch.ar(PlayBuf.ar(2, bufnum, velocidad, 1, posicion), Impulse.ar(latch));
		senal = senal[0];
		senal = Pan2.ar(senal, pan);
		env = EnvGen.ar(
			Env.sine(dur, amp),
			doneAction: 2
		);
		OffsetOut.ar(out, senal * env)
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
		position = (rrand(0, durBuffer - durGrain));

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, b.bufnum,
					\posicion, position * 44100,
					\velocidad, rrand(0.8, 1),
					\dur, durGrain,
					\amp, 0.8,
					\pan, rrand(-1.0, 1.0),
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
b = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/12 - Audio example 1 for granular.wav");
c = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/12 - Audio example 2 for granular.wav");
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

		if(buffer == c, {amp = 2.5}, {amp = 0.6});

		s.bind({
			Synth(
				\grain,
				[
					\bufnum, buffer.bufnum,
					\position, position * 44100,
					\speed, [ 1, 1.35, 1.5, 2 ].choose, //Rate * 4.midiratio (Meaning the number of half tones of the interval).
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

//Very damaged (quite good):
c = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/SPECIFIC CODES/!For granular examples.wav")
c.numChannels

(
SynthDef(
	\grano,
	{ arg out = 4, bufnum, posicion, velocidad, dur, amp = 0.1;
		var senal, env;

		senal = PlayBuf.ar(2, bufnum, velocidad, 1, posicion);
		env = EnvGen.ar(Env.sine(dur, amp), doneAction: 2);
		OffsetOut.ar(out, senal * env)
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
	var durBuffer, durGrano, posicion = 0, velocidad, tiempoEspera, tiempoEsperaDev, superposicion;

	Synth(\dsp, [\in, 4, \clip, 0.05], s, 'addToTail');

	durBuffer = c.duration;
	superposicion = 4; //"Bad" sound (discontinuous) -> bad superposition (with 2 is perfect), but with 3 or 4 it's also very very interesting.

	tiempoEsperaDev = Prand((0.01, 0.02..0.1), inf).asStream; //The problem was to include negative numbers.

	inf.do({

		tiempoEspera = tiempoEsperaDev.next;
		durGrano = tiempoEspera * superposicion;
		posicion = (posicion + tiempoEspera) % durBuffer;

		s.bind({
			Synth(\grano,
				[
					\bufnum, c.bufnum,
					\dur, durGrano,
					\velocidad, 1,
					\posicion, posicion * 44100,
					\amp, 0.8
			],
				s, 'addToHead'
			)
		});
		tiempoEspera.wait;
	});
}).play
)

//////////////////////////////////////////////////////////

//Fading in and out randomly:
c = Buffer.read(s, "F:/DOCUMENTOS/1 VERANO 2022/SUPERCOLLIDER - My own codes 2022/SuperCollider - Pilar Miralles/SPECIFIC CODES/!For granular examples.wav");

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

	position = Pseg((0, 1..(192 - 9)), 1.5, 'lin', inf).asStream.trace; //This is an envelope for the position so it is just going straight instead of jumping randomly (I calculated the buf duration and substracted the maximum duration of the grain (which is random).

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
					\speed, (0.65, 0.7..1).wchoose((0.65, 0.7..1).normalizeSum),
					\dur, durGrain,
					\pan, rrand(-1.0, 1),
					\amp, 0.5,
					\out, 0 //I don't want to use the reverb right now.

			],
				s, 'addToHead'
			);

		});

		((3, 3.5..8.5).wchoose((1, 2..12).normalizeSum)).wait

	});
}).play
)
