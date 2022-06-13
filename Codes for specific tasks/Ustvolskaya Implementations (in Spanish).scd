//IMPLEMENTACIONES DEL TFM DE USTVOLSKAYA:

////////////////////////////////////////////////////////////////////////////////////////////
//CONSTRUCCIÓN POLIFÓNICA:

//Construcción de clústeres: dos posibilidades:
(
var mode, cluster;

mode = [ 0, 2, 4, 6, 8, 9, 10 ];

cluster = mode[ 0 ];

	7.collect({ arg i;

	if (i > 0,	{cluster = ([ cluster ] ++ mode[ 0 + i ]).flat}, {[ cluster ]});
	})

)

(
var mode, cluster;

mode = [ 0, 2, 4, 6, 8, 9, 10 ].stutter(2);

mode = mode.rotate(rrand(0, 7));

cluster = mode[ 0 ];

Routine({

	8.do({ arg i;

		if ((i > 0).and(i.even), {cluster = ([ cluster ] ++ mode[ 0 + (2 * i) ]).flat}, {[ cluster ]});

		cluster.postln;

		1.wait
	})

}).play
)

//Acordes en bloque: dos posibilidades:
(
var mode, notes;

mode = [ 0, 1, 3, 5, 6, 8, 10 ];

notes = [ 0, 1, 2, 3, 4, 5, 6 ].scramble.keep(3).sort;

8.collect({ | i |

	mode.rotate(i)[ notes ].postln;

})
)

(
var mode, notes, result;

mode = [ 0, 1, 3, 5, 6, 8, 10 ];

notes = [ 0, 1, 2, 3, 4, 5, 6 ].scramble.keep(3).sort;

8.collect({ | i |

	result = mode.rotate(i)[ notes ];

	if (i.even, {(result ++ [ ["octaveUp"], ["octaveDown"] ].choose ).postln}, {result.postln});

})
)

///////////////////////////////////////////////////////////////////////////////////////////////
//CONSTRUCCIÓN CONTRAPUNTÍSTICA:

//Desplazamiento entre voces:
(
SynthDef(
	\voice1,

	{ arg freq1, amp = 0.3, durEnv = 1, pan = 0;
		var signal1, env;

		signal1 = SinOsc.ar(freq1, 0, amp);

		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);

		signal1 = Pan2.ar(signal1 * env, pan);

		Out.ar(0, signal1)

}).add;

SynthDef(
	\voice2,

	{ arg freq2, amp = 0.3, durEnv = 1, pan = 0;
		var signal2, env;

		signal2 = SinOsc.ar(freq2, 0, amp);

		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);

		signal2 = Pan2.ar(signal2 * env, pan);

		Out.ar(0, signal2)

}).add
)

(
var melody, series1, series2, dur;

melody = (60..71).scramble.keep(7);

series1 = Pseq(melody, inf).asStream;

series2 = Pseq(melody, inf).asStream;

dur = 1;

Routine({
	inf.do({ arg i;

		i.postln;

		(Synth(\voice1,
			[ \freq1, series1.next.postln.midicps, \pan, -1 ]
		);

		if (i > 3,

			{Synth(\voice2,
				[ \freq2, series2.next.postln.midicps, \pan, 1 ])}
		));

		dur.wait
	})

}).play
)

( //Modelo con extensiones:
SynthDef(
	\voice1,

	{ arg freq1, amp = 0.2, durEnv = 1, pan = 0;
		var signal1, env;

		signal1 = SinOsc.ar(freq1, 0, amp);

		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);

		signal1 = Pan2.ar(signal1 * env, pan);

		Out.ar(0, signal1)

}).add;

SynthDef(
	\voice2,

	{ arg freq2, amp = 0.2, durEnv = 1, pan = 0;
		var signal2, env;

		signal2 = SinOsc.ar(freq2, 0, amp);

		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);

		signal2 = Pan2.ar(signal2 * env, pan);

		Out.ar(0, signal2)

}).add;

SynthDef(
	\voice3,

	{ arg freq3, amp = 0.2, durEnv = 1, pan = 0;
		var signal3, env;

		signal3 = SinOsc.ar(freq3, 0, amp);

		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);

		signal3 = Pan2.ar(signal3 * env, pan);

		Out.ar(0, signal3)

}).add
)

(
var melody, series1, series2, series3, dur;

melody = Array.fill(50, {[ 60, 62, 64, 66, 68, 69, 71, 72 ].choose});

series1 = Pseq(melody, inf).asStream; //Original
series2 = Pseq(melody + rrand(0, 11), inf).asStream; //Con transporte
series3 = Pseq(melody, inf).asStream; //Sin transporte

dur = 1/8;

Routine({
	inf.do({ arg i;

		i.postln;

		(Synth(\voice1,
			[ \freq1, series1.next.postln.midicps, \pan, 0 ]
		);

		if (i > 11,

			{Synth(\voice2,
				[ \freq2, series2.next.postln.midicps, \pan, -1 ])}
		);

		if (i > 24,

			{Synth(\voice3,
				[ \freq3, series3.next.postln.midicps, \pan, 1 ])}
		)
		);

		dur.wait
	})

}).play
)

//Espejo entre manos: dos posibilidades:
(
var mode, notes;

mode = [ 0, 1, 3, 4, 6, 7, 9, 10 ];

notes = [ 0, 1, 2, 3, 4, 5, 6, 7 ].scramble.keep(3).sort;

8.collect({ | i |

	[ (mode.rotate(i.neg)[ notes ] ++ [ "right" ]),

		(mode.rotate(i)[ notes ] ++ [ "left" ]) ];

})
)

(
var mode, notesRight, notesLeft;

mode = [ 0, 1, 3, 4, 6, 7, 9, 10 ];

notesRight = [ 0, 1, 2, 3, 4, 5, 6, 7 ].scramble.keep(3).sort;

notesLeft = [ 0, 1, 2, 3, 4, 5, 6, 7 ].scramble.keep(2).sort;

8.collect({ | i |

	[ (mode.rotate(i)[ notesRight ] ++ [ "right" ]),

		(mode.rotate(i.neg + 3)[ notesLeft ] ++ [ "left" ]) ];

})
)

//////////////////////////////////////////////////////////////////////
//CONSTRUCCIÓN MELÓDICA:

//Paso aleatorio:
(
SynthDef(
	\randomScale,

	{ arg freq, amp = 0.1;
		var signal, env;

		signal = SinOsc.ar(freq, 0, amp);

		env = EnvGen.ar(Env.perc(0.005, 1, 0.2), doneAction: 2);

		Out.ar(0, signal * env)

}).add
)

(
var notes, durs;

notes = Pseq([ 60 + Prand((-2..-1) ++ (1..2)) ], inf).asStream;

durs = 1/4;

Routine({ var sequence;

	inf.do({ arg i;

		sequence = (notes.next + i).postln;

		Synth(\randomScale,
			[ \freq, sequence.midicps ]
		);

		durs.wait
	})

}).play
)

//Transformación motívica:
(
var series, group1, group2, group3;

series = [ 0, 2, 3, 1, 6, 4, 6, 8, 11 ];

series = series.clump(3).postln;

group1 = series[0];
group2 = series[1];
group3 = series[2];

group1 = [ group1.reverse, group1.invert, group1.reverse.invert ].choose;
group2 = [ group2.reverse, group2.invert, group2.reverse.invert ].choose;
group3 = [ group3.reverse, group3.invert, group3.reverse.invert ].choose;

[ group1, group2, group3 ]

)

//Frustración escalar:
(
var series, position, note, insertion;

series = [ 0, 1, 3, 4, 6, 7, 9, 10 ];

position = rrand(0, 7);

note = series[ position ];

insertion = if (0.5.coin, {([ note ] ++ [ note + 1 ] ++ [ note - 2 ] ++ [ note ]) % 10 }, {([ note ] ++ [ note - 2 ] ++ [ note + 1 ] ++ [ note ]) % 10});

series[ position ] = [ insertion ];

series
)

//Nota pivote:
(
var mode, position;

mode = [ 0, 1, 3, 5, 6, 8, 10 ];

position = [ 0, 1, 2, 3, 4, 5, 6 ].scramble.keep(3).sort;

8.collect({ | i |

	if ((0.3.coin), {"pivot".postln; i = i.neg}, {i = i.abs});

	mode.rotate(i)[ position ].postln;

})
)

//Frases de clústeres:
(
var cluster, root;

root = rrand(0, 11);

cluster = [ root, (root + 1) % 12, (root + 2) % 12 ];

({cluster} !10).collect{ arg note; note ++ [

	["octaveUp"],
	["octaveDown"],
	["doubleOctaveUp"],
	["doubleOctaveDown"],
	["noChange"],
	["tritoneUp"],
	["tritoneDown"]

].wchoose([3, 3, 1, 1, 5, 3, 3].normalizeSum) }
)

/////////////////////////////////////////////////////////////////////////
//CONSTRUCCIÓN RÍTMICA:

//Compresiones y expansiones temporales:
(
SynthDef(
	\expansion,

	{ arg freq, amp = 0.5, durEnv = 1.5;
		var signal, env;

		signal = SinOsc.ar(freq, 0, amp);

		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);

		Out.ar(0, signal * env)

}).add
)

(
var series, notes;

series = [ 74, 76, 77, 79, 80, 90, 75, 73, 72, 70, 68, 67, 65, 66, 64, 65, 63, 61, 60 ];

notes = Pswitch1([

	100,
	Pseq(series, inf)

],

Pseq([ 0, Pn(1, Pseries(1).asStream) ], inf)

).asStream;

Routine({

	25.do({

		Synth(\expansion,
			[\freq, notes.next.postln.midicps]
		);

		0.5.wait
	})

}).play
)

//Frustración del pulso constante:
(
SynthDef(
	\rhythmicFrustration,

	{ arg freq, amp = 0.1, pan = 0;
		var signal, env;

		signal = SinOsc.ar(freq, 0, amp);
		env = EnvGen.ar(Env.perc(0.005, 1, 0.2), doneAction: 2);
		signal = Pan2.ar(signal * env, pan);

		Out.ar(0, signal)

}).add
)

(
var notes, freq;

notes =  Pwrand([ 31, 32, 33, 34, 35, 36 ] + 24, [ 0.5, 1, 2, 4, 2, 1 ].normalizeSum, inf).asStream;


Routine({
	inf.do({

		freq =  notes.next.postln;

		Synth(\rhythmicFrustration,
			[
				\freq, freq.midicps,
				\amp, 0.5
			]
		);
		if ((freq != 57).postln, {0.5.wait}, {0.25.wait})
	})
}).play
)

//////////////////////////////////////////////////////////////////////////
//RECURSOS ESTRUCTURALES:

//Sonata no. 6: espejo frustrado:
(
var sections, mirror, frustration, place;

sections = [ 1, 2, 3, 4, 5 ];

mirror = sections.mirror;

frustration = rrand(0, 4);

place = rrand(1, 7);

if (sections[ frustration ] == mirror[ place ], { frustration = (0..4); frustration.removeAt(mirror[ place ]; frustration = frustration.choose)});

	mirror[ place ] = [ mirror[ place ], sections [frustration] ];
)

//Sinfonía no. 4: compresión sistemática:
(
var structure, remove;

structure = [ "a", "b", "c", "b", "a" ];

structure.postln;

Routine({

	4.do({

		structure = structure.drop(-1);

		structure.postln;

		1.wait
	})

}).play
)

( //Expansión 1:
var structure, index;

structure = [ "a", "b", "c", "b", "a", "d", "c", "e", "c", "d" ];

(structure.size.div(2)-1).do({

	index = Array.series(structure.size).scramble.keep(2);

	index.do({| i | structure[i] = nil });

	structure = structure.select({| item | item.notNil }).postln

})
)

( //Expansión 2:
var structure, newStructure, position;

structure = [ "a", "b", "c", "b", "a", "d", "c", "e", "c", "d" ];

position = -1;

while(

	{ position < structure.lastIndex },
	{  position = (position + rrand(1, 3));

	structure[..position].postln;

})
)

