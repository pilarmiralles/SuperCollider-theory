b//13 - PBIND
//////////////////////

//INTRODUCTION
//Associations between objetcs: we can use the relationship key --> value:

a = \freq -> 440 //The value 440 is pointed by the key \freq.

//Now we can ask "a" about its key or its value:

a.key
a.value

//Besides Array, there are other classes regarding collections: a Dictionary is a collection of associations:

d = Dictionary[ \freq -> 440, \amp -> 0.1 ] //The use of [] without the specification of type of collection is an Array by default because it is the most common one.

//We ask "d" about the value in any of the keys contained within the dictionary (the keys within the dictionary are used as indexes --> the order within the dictionary is not important as it is within an array: this is why we don't use numbers as indexes anymore in this context):

d[\freq]
d[\amp]

//There is another type of collection called IdentityDictionary, which accesses the keys much quicker because it compares using identity instead of equivalence: hence we only use symbols as keys:

"horse" == "horse" //"True": equivalence --> two different strings featuring the same characters.
"horse" === "horse" //"False": not identical --> it is not the same object.
\horse === \horse //"Ture": equivalent AND identical --> Symbols featuring the same name are the same object.

//Then, the series of Classes within the Class Tree is (Array is in a different super class, SequenceableCollection, alongside the collections in which the order of the elements is important):

Collection --> Set (set according to equality) --> Dictionary (associeaty collection mapping keys to values) --> IdentityDictionary (dictionary based on identity / symbols) --> Environment (a dictionary which can serve as a 'name space' for functions) --> Event (an environment that represents an action)

//Next, we will focus on that last subclass named Event, with which we can created sonic events, that is to say, something with frequency, amplitude, duration, etc. It works with .play.

Event[ \midinote -> 61, \amp -> 0.1, \dur -> 1 ] //Here is an event with some values.

//In order to make it sound according the given values (associations), we need to implement the method .play:

Event[ \midinote -> 61, \amp -> 0.1, \dur -> 1 ].play //The default sound in SC is a very ugly and cheap piano (although it has an interesting envelope if sustained XD).

(midinote: 61, amp: 0.1, dur: 1, pan: 1).play //When the Event is already created, we can change the values this other way (like a shortcut). All values can be replaced or reasigned as in the variables. All defined keys have their own default value. It is also possible to define new associations apart from the default ones.

//In summary (for instance):

Event[].play
(dur: 3, midinote: 71, amp: 0.5).play

//In here we can see all the default keys and values of Event:

Event.default.parent.associationsDo(_.postln);"" //The empty string "" at the end in order to avoid printing what it is evaluated at the end.

//For instance, there are several ways of writing the pitch (as it happens to many other parameters, as we'll se later on):

(midinote: 60).play //In Midi values.
(freq: 5000).play //In Hz.
(note: 2).play //In pitch class (number of semitones into a scale from C).

/////////////////////////////////////////////////////////////////////////////////

//PBIND
//Most popular class in SC :)
//Pbind sequences events (the grammar here is behind the class and not exposed as when we build our own routine, but it is true that many processes are much more doable using Pbind, easier and more efficiently. As we will see later on, Pbind can be connected to our own SynthDef, but for now we will use the piano sound of SC, which is actually a default SynthDef called "default" (do not use that number for your own SynthDef as it will disengage from the original one). Pbind is also based on key-value associations:

Event[].play //A single sonic event (default parameters).
Pbind().play //A stream of sonic events.

//For example:

Pbind(\midinote, 60, \dur, 1).play //It is going to play successively the event defined by the keys: a C every second. It is a stream of sonic events.

//Now the fun part is that the keys not only receive fixed numbers, but they can be defined by other patterns. The method .asStream is no longer needed because Pbind is already turning the patterns into a stream (like an embedded or nested pattern):

Pbind(\midinote, Pseq([60, 62], inf), \dur, 1).play //Alternating between two pitches with a Pseq.

//This would be the equivalent routine to the Pbind above, just to show the shortcut it provides us with (for certain algorithmic processes, making your own routines could be more effective tho, it all depends on the result you pursue):
(
var note;

note = Pseq([ 60, 62 ], inf).asStream;

Routine({
	inf.do({
		var synth;

		synth = Synth(
			\default,
			[ \freq, note.next.midicps, \amp, 0.1 ]
		);

		1.wait;
		synth.release //In order to free the synth every second (as we don't have doneAction in the SynthDef by default?).
	})
}).play
)

//Let's understand how to replace / reassign values in sonic events:

p = Pbind(\a, 1, \b, 2).asStream //Using .asStream instead of .play avoids the control of the clock over the events, now it is just a stream. We are going to use an empty event which will act as a .next for our Pbind, and which will be filled up with the values we wrote inside "p":

p.next(Event[]) //Remember that the order of the keys does not matter.

p.next(Event[ \a -> 0, \b -> 0, \c -> 1000 ]) //This will reassign the default (or original) values of the Pbind in "p". If we include new keys different from the one stated in the original Pbind, they will be included in the new version:

p = Pbind(\a, 1, \b, 2, \z, 777).asStream //Original version.
p.next(Event[ \a -> 0, \b -> 0, \c -> 1000 ]) // Adds \c and replaces the values of \a and \b.

//Las example: you can evaluate the event after running the Pbind and see the successive values.
p = Pbind(\a, Pseq([ 0, 1 ], inf), \b, Prand([ 100, 200 ], inf)).asStream
p.next(Event[])

/////////////////////////////////////////////////////////////////////////////////////////////////////

//KEYS
//KEY DUR: it is 1 by default (in seconds).
//Also by default, the note occupies an 80% of the duration we set (0.8 seconds if dur = 1), including a slight fade out (we will be able to change this later on):

Pbind().play //A Pbind with all values by default.
Pbind(\dur, 0.25).play //Changing the default value of duration.
Pbind(\dur, Pseq([ 0.25, 0.5, 0.25 ], inf)).play //Using patterns.
Pbind(\dur, Pseq(Array.geom(20, 1, 0.8).mirror, inf)).play //Speeding up and slowing down.

//KEY AMP: it is 0.1 by default.

Pbind().play //By default.
Pbind(\amp, 0.1).play //Ideam as default.
Pbind(\amp, 0.5).play //Louder.
Pbind(\amp, Prand([ -36, -30, -24, -18, -12 ].dbamp, inf), \dur, 1/8).play //Using a pattern with dB values (convertir dB to lineal amplitude, otherwise use values within 0-1, BEWARE OF THIS.
Pbind(\db, Prand([ -36, -30, -24, -18, -12 ], inf), \dur, 1/8).play //Using key \db so the conversion is not needed.

//Simple example: 90% of the dynamics is more likely to be soft, 10% to be loud:

(
Pbind(
	\midinote, Pseq([ 61, 71 ], inf),
	\dur, Pseq([ 0.25, 0.5, 0.25 ] / 4, inf),
	\amp, Pwrand([ 0.01, 0.1 ], [0.9, 0.1 ], inf)
).play
)

//KEY PAN: it is 0 by default.

Pbind().play //Pan = center.
Pbind(\pan, 1).play //Pan = right.

//Same example as before, speed doubled and spread from left to center to right every three notes (synchronized with duration because both feature 3 values):

(
Pbind(
	\pan, Pseq([ -1, 0, 1 ], inf),
	\midinote, Pseq([ 61, 71 ], inf),
	\dur, Pseq([ 0.25, 0.5, 0.25 ] / 16, inf),
	\amp, Pwrand([ 0.01, 0.1 ], [0.9, 0.1 ], inf)
).play
)

//KEY FREQ:
//Several ways to specify the frequency, as we saw before:

\freq //In Hz.

//G overtones, following the natural temperament (whole multiples of the fundamental pitch):
(
Pbind(
	\freq, Pseq([ 100, 200, 300, 400, 500, 600, 700 ], inf),
	\dur, 0.1
).play
)

\detune //A key to work with \freq (also in Hz):

//Each tone is detuned by -50 Hz (the detunning is different regarding the frequency, if using a fixed value (but that's the point):
(
Pbind(
	\freq, Pseq([ 100, 200, 300, 400, 500, 600, 700 ], inf),
	\detune, -50,
	\dur, 0.1
).play
)

//There is no multichannel expansion integrated in Pbind: if two frequencies are sent to it, two sonic events will be created in parallel. The rest of the keys are shared between both events (beware of the amplitude). Here same frequency, one of them slightly detuned:
(
Pbind(
	\freq, [ 440, 440 * 1.5 ], //The channel distribution depends on the panning within the SynthDef. Pan = 1 will put both frequencies through the right channel.
	\detune, -50,
	\dur, 0.1
).play
)

//Another example with a pattern: first two frequences, then just one (notice that the amp is double when the two freqs are played at the same time):
(
Pbind(
	\freq, Pseq([ [ 440, 440 * 1.5 ], 220 ], inf),
	\detune, -50,
	\dur, 0.1
).play
)

//Another example using the detune to create two frequencies: we can here 3 tremolos per second because of the frequency difference:
(
Pbind(
	\freq, 1000,
	\detune, [ 0, 3 ],
	\dur, 9 //Nine seconds of duration.
).play
)

//KEY NOTE: another way of setting the frequency, with pitch class values (numbers from 0 to 11, as 12 will be C again. It is not exactly pitch class because it will add the octave difference (-1 = lower B, 12 = higher C).

//Chromatic scale: by default, 0 = C4 (middle C):
(
Pbind(
	\note, Pseq([ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ], inf), //Beware the inf XD.
	\dur, 0.2
).play
)

//Key octave: to specify the octave instead of calculating the number. The middle C is the octave 5 here (because middle C is 60 midi, so 60 / 12 is 5, is the fifth octave in midi numbers from 0):
(
Pbind(
	\octave, 5, //Try other values like 3 or 7.
	\note, Pseq([ 0, 2 ], inf),
	\dur, 0.2
).play
)

//Three octaves at the same time (beware the amplitude):
(
Pbind(
	\octave, [ 4, 5, 6 ],
	\note, Pseq([ 0, 3 ], inf),
	\dur, 0.2
).play
)

//Using Ptuple: Ptuple creates in each iteration an array with the values given by the several patterns within its list (here, a Prand duplicated, so two Prand. Then, those values are distributed between the two events created because of the array of two values in \octave:
(
Pbind(
	\octave, [ 4, 6 ],
	\note, Pseq([ 0, 2 ], inf),
	\dur, 2,
	\amp, Ptuple({ Prand([ 0.05, 0.1, 0.2 ], inf) } !2).trace //.trace to visualize the values coming out of a specific pattern.
).play
)

//Another example with Ptuple: in this case it directly creates two events because its output in an array of two values, one from each of the Prand of its list:
//Also here is another key for the frequency: \midinote (in midi numbers):
(
Pbind(
	\midinote, Ptuple(
		[
			Prand((60..84), inf),
			Prand((60..84), inf)
		]
	).trace //Just to visualize the values.

).play
)

//Last example taking advantage of a fast octave change:
(
Pbind(
	\octave, Pseq([ 2, 3, 4, 5, 6, 7, 8 ], inf),
	\note, Pseq([ 0, 2 ], inf),
	\dur, 0.2
).play
)

//Imitating Boulez's Structures for piano (but without the series): maximum level of randomness applied to pitch, duration, amplitude, octaves, etc.
(
Pbind(
	\note, Pn(Pshuf((0..11))), //Random permutations using Pn and Pshuf.
	\octave, Pn(Pshuf((2..9))),
	\dur, Pn(Pshuf((1..12))) * (1/32), //From 1 to 12 units, then multiplied by 1/32 they become 32nd-notes.
	\db, Pn(Pshuf((-6, -12..-72))), //Amplitude in dB.
).play
)

//KEY STEPSPEROCTAVE: the default value is 12, 12 steps per octave is the chromatic scale, hence the equal temperament. We can create other divisions of the octave, bringing about microtones (or supertones?):

//Dividing the octave in 13 equal parts:
(
Pbind(
	\stepsPerOctave, 13,
	\note, Pseq(Array.series(14, 0, 1), inf), //A series of 14 steps so we have all the tones from octave to octave.
	\dur, 0.2
).play
)

//Same example, divided by 11 (and adjusting the Array.series):
(
Pbind(
	\stepsPerOctave, 11,
	\note, Pseq(Array.series(12, 0, 1), inf),
	\dur, 0.2
).play
)

//This is an interesting example in which we use new methods: there is a melody from Bach's Invention no. 2 sequenced by the Pseq for the pitches. There are 18 notes in the melody, thus in stepsPerOctave we use a Pstutter, which is a pattern that will repeat a certain number of times each value produced by the pattern in its argument, which in this case is augmenting by 1 the number of divisions of the octave using Pseries (functions as Arrai.series). This will provoke that the intervals of the melody are smaller each time it is repeated (this takes time). The duration of each note of the melody is also sequenced in the key dur (Pn is used just to avoid repeating the same value in the Pseq's list) and then it is multiplied by a Pgeom (which is the equivalent of Array.geom in pattern verion): this will speed up the progression every time more (the speed will increase exponentially, so the process of speeding up will reach a point when it becomes much faster).

//VERY IMPORTANT: STOP THE SYNTH WHEN A CERTAIN EXTREME IS REACHED (around the 80th iteration), OTHERWISE, THE SERVER WILL COLLAPSE BECAUSE OF THE INFINITE LOOP!!!
(
Pbind(
	\stepsPerOctave, Pstutter(18, Pseries(12, 1, inf)).trace,
	\note, Pseq([ 2, 4, 5, 7, 9, 10, 1, 10, 9, 7, 5, 4, 5, 9, 14, 7, 13, 16 ],
		inf),
	\dur, Pseq([ Pn(0.25, 12), Pn(0.5, 6) ], inf)
	*
	Pgeom(0.5, 0.999).trace,
	\amp, 0.25
).play
)

//KEY SCALE Y DEGREE

\scale //It works alongside the key \degree. The scale is defined with pitch classes (number of semitones within the chromatic scale).
\degree //This key defines the degrees of the chosen scale but: the tonic = 0, the dominant = 4, so the numbers change a bit (you can also use the conventional numbers and then substract 1 to the whole list). Indeed, the degrees are referring to the index of the pitches defined in the \scale key within its array.

//There is a whole C major scale, but it only plays the degree 0, which is C:
(
Pbind(
	\scale, [ 0, 2, 4, 5, 7, 9, 11 ],
	\degree, 0,
	\dur, 0.2
).play
)

//This is the entire scale in order thanks to the Pseq (it can be done in many ways, for example, using Pseries):
(
Pbind(
	\scale, [ 0, 2, 4, 5, 7, 9, 11 ],
	\degree, Pseq((0..7), inf),
	\dur, 0.2
).play
)

//First time: whole scale in order + second time: eight random notes from the scale:
(
Pbind(
	\scale, [ 0, 2, 4, 5, 7, 9, 11 ],
	\degree, Pseq(
		[
		Pseq((0..7), 1),
		Prand((0..7), 8)
		], inf),
	\dur, 0.2
).play
)

//Both keys \scale and \tuning are used to make scales, you can press ctrl + i over the class Scale in order to see all the implemented scales by default (and you can use their names instead of writing the numbers, but it is always good to think about your own scales too):

Scale.scaleName //This is how this class would work, being able to put it into the \scale key directly. See all the possibilities using ctrl + i.

//Example of implementation of the class Scale (same code as the former one, just changing the scale):
(
Pbind(
	\scale, Scale.pelog, //The pelog scale, that Xenakis loved so much. He especially used four notes B-C-E-F, two perfect fourths a semitone apart, good balance of tension and resolution ([0, 1, 5, 6] in pitch class).
	\degree, Pseq(
		[
		Pseq((0..7), 1),
		Prand((0..7), 8)
		], inf),
	\dur, 0.2
).play
)

//Using Pbrown (brown movement)
(
Pbind(
	\scale, Scale.pelog,
	\degree, Pbrown(0, 24, 3), //Values from 0 to 24, but the maximum step is 3, so the randomness is very organic.
	\octave, 4, //We can use the key \octave also with any scale from Scale.
	\dur, 0.2
).play
)

//KEYS FOR DURATION: \dur and \legato:

\dur //This indicates the time between each event in seconds.

\legato //By default, \legato has a value of 0.8: the duration of the sound = \dur * \legato: hence, using 0.1 of legato means making it sound a 10% of the time between the two events. It is also possible to use a number higher than 1: in this case, the Events will overlap, as in an overlap routine. Be aware that there will be several synths activated at the same time.

Pbind(\dur, 1, \midinote, Pseq((60..66), inf)).play //The pitches are separated by 1 second, by the real duration by default is 0.8 seconds. If the SynthDef we use features some release (fade-out) then the separation will be milder (the release of the envelope would start at 0.8 seconds, being the duration = 1 and the legato by default).

Pbind(\dur, 1, \legato, 5, \midinote, Prand((36..84), inf)).play //Random pitches (wider range) and overlap between them as the legato is 5.

\stretch //Then, \stretch is a factor for the duration: it lengthen or shorten the durations proportionally.

//For example, here we use our own numbers for duration, then the \stretch sets the note value (the unit) as 8th-notes:
(
Pbind(
	\dur, Prand([3, 5, 7, 11], inf),
	\stretch, 1/8,
	\midinote, Prand((60..72), inf)
).play
)

\sustain = \dur * \legato * \stretch //The key \sustain is equal to this operation, but not so recommended: it is easier to set durations using \dur and \legato, adn maybe \stretch.

///////////////////////////////////////////////////////////////////////////

//SECOND PART: USING OUR OWN SYNTHDEFS:

//KEY INSTRUMENT: so we can use our own Synths:

Synth(\default) //This is the SynthDef we have been using until now, the cheap piano sound from SC.

//Now we can create and implement our own "instruments": let's use this super basic SynthDef:

(
SynthDef(
	\newSine,
	{ arg out, freq, amp, pan, gate = 1;
		var signal, env;

		signal = Mix(SinOsc.ar(freq * [ 1, 1.01 ], 0, 0.5)); //Two frequencies are produced with 0.01 difference factor, then they are mixed producing this little detuning or tremolo.
		env = EnvGen.ar(
			Env.asr(0.01, amp * 0.5, 0.3), //Envelope with attack, sustain and release, because Pbind needs the gate to boot up.
			gate, //Gate needs a 1 by default in order to boot up the envelope right away. Pbind sends a 0 each time it's done with a synth, then it picks up again the 1 as default value within the SynthDef.
			doneAction: 2 //doneAction = 2 is essential to keep each Synth out of the server when it is done.
		);

		Out.ar(out,Pan2.ar(signal * env, pan)) //We apply Pan2, as the output of the Mix is a mono signal.
}).add
)

//This would be the connection to the new instrument through the name of the SynthDef, and its default values (all arguments included in the SynthDef with our own default values or rather the default values of the Event keys (only replaced automatically in the keys defined by default: our own arguments that are not in that list would need default values within the SynthDef if not defined in Pbind):

Pbind(\instrument, \newSine).play

Pbind(\instrument, \newSine, \midinote, Pseq([ 72, 67, 68, 75 ], inf)).play //For example, \midinote is going to be placed automatically in the freq argument (and converted to Hz if I am not wrong).

//Another example using the same instrument:
(
Pbind(
	\instrument, \newSine,
	\midinote, Pn(Pshuf([ 40, 42, 43, 45, 46 ] + 12, 2), inf),
	\dur, 0.5 / (180/60), //Corcheas en un tiempo de 180 la negra (esto es mejor que usar la key "tempo", porque cambia el tempo a todo SC).
	\legato, 0.5, //Aquí cada nota dura la mitad del espacio (con 0.1 duraría la décima parte, sería como staccato). Si ponemos dos, habrá dos sonando al mismo tiempo porque se solapan (como en una rutina overlap).
	\amp, Pwrand([ 0.1, 0.7 ], [ 0.8, 0.2 ], inf),
	\pan, Pseq([ -1, -0.5, 0, 0.5, 1 ], inf)
).play
)

//In SC folder, there are some examples: in "pieces", there is this example called "Spacelab", easy to analyze and very useful regarding the use of Pbind. All layers are defined at the beginning and at the end, everything is sequenced thanks to a Pseq.

//NEW SYNTHDEF: remember that gate and doneAction are essential in order to use your own instrument with Pbind:

(
SynthDef(
	\klank,
	{| gate = 1, freqscale, amp, pan | //the argument "freqscale" is not within Pbind's keys, but it can be defined within Pbind through the argument's name.
		var impulse, signal, env;

		impulse = Impulse.ar(0); //Impulse with freq = 0: it will create a single impulse at the beginning, as input for the Klank.
		signal = Klank.ar(
			`[
				[ 42, 5600, 11639 ],
				1,
				[ 10, 0.01, 2 ]
			],
			impulse,
			freqscale //Freqscale allows us to transpose the freqs of Klank (2 = octave up, 0.5 = octave down, 7/4 = minor 7th, etc. all overtone ratios).
		);
		env = EnvGen.ar(
			Env.asr(0.001, amp, 0.001),
			gate,
			doneAction: 2
		);
		Out.ar(0, Pan2.ar(signal * env, pan))
}).add
)

(
Pbind(
	\instrument, \klank,
	\dur, Pwrand([1, 0.05 ], [0.9, 0.1 ], inf) * (60/90), //Last multiplication so it runs at 90 bpm.
	\freqscale, Pseq([ 1, 7/4 ], inf),
	\amp, Pwrand([ 0.5, 0.1 ], [ 0.1, 0.9 ], inf),
	\pan, Prand([ -0.7, -0.3, 0, 0.3, 0.7 ], inf)
).play
)

//RESTS: \rest or just \ in any key for the freqs is interpreted as a rest:

Pbind(\note, Pseq([ 0, 2, \rest, 5, 6, \rest, 10, 11, \rest ], inf)).play

//Here is our newSien synth again:
(
SynthDef(
	\newSine,
	{|out, freq, amp, pan, gate = 1|
		var signal, env;

		signal = Mix (SinOsc.ar(freq * [1, 1.01], 0, 0.5));
		env = EnvGen.ar(
			Env.asr(0.01, amp * 0.5,0.3),
			gate,
			doneAction: 2
		);
		Out.ar(out, Pan2.ar(signal * env, pan))
}).add
)

//In this example, there is a random permutation each 5 repetitions of the Pshuf model: there are 5 different pitches and 3 rests to be sorted randomly. This will alternate the pitches and rests quite fast, giving a similar impression as with Ligeti's studio of the blocked keys:

(
Pbind(
	\instrument, \newSine,
	\midinote, Pn(Pshuf([ 64, 66, 67, 69, 70, \, \, \ ], 5)),
	\amp, 0.1,
	\dur, 0.25 * (60/180), //Here we use 16th-notes (a quarter of a quarter-note, 0.25 from 1), at 180 bpm. This could be calculated with \stretch, but seems easier to use a single key (just \dur).
	\legato, 0.25,
	\pan, Pseq([ -1, -0.5, 0, 0.5, 1 ], inf)
).play
)

//The rests can also be created using the class Rest() within any key: here in \amp:

(
Pbind(
	\note, Pseq([ 0, 2, 4, 5, 6, 7, 10, 12 ], inf), //As the Rest is in \amp, the flow of pitches is maintained and we can get rid of the randomness for this system.
	\amp, Pseq([
		Pseq([ 0.1, 0.1, Rest() ], 8), //We create the pattern note-note-rest. There are 8 pitches, so the pattern is displaced during 24 iterations (8 series of 3 pulses (note-note-rest)) and comes back to its initial phase only after that.
		Pn(0.1, 8) //When the 24-notes period is completed, the complete series of pitches appears (8 repetitions, because 8 pitches).
	],
	inf),
	\pan, Pseq([ Pn(0, 3 * 8), Pseq([ -1, 1 ], 4) ], inf), //The period of the amps coincides with the pan: it maintaines a 0 during 3 * 8 iterations, then it alternates between -1 and 1 four times (for the last 8 iterations of the complete scale).
	\dur, 0.1,
	\instrument, \newSine
).play
)

//In case Rest is used in any of the keys related to the duration (mainly in \dur), then we have to specify the duration of the Rest (in seconds):

(
Pbind(
	\note, Pseq([ 0, 2, 4, 5, 6, 7, 10, 12 ], inf),
	\dur, Pwrand([ 0.1, Rest(0.3) ], [ 0.8, 0.2 ], inf),
	\instrument, \newSine
).play
)

/////////////////////////////////////////////////////////////////////////////////////

//PATTERNS FOR STOCHACTIC DISTRIBUTION: stochastic = random = chance = haphazard...

//UNIFORM DISTRIBUTION (= rrand):

Pwhite(lo, hi, length) //Arguments.

//Example: in the first graph, we can see how the values are spread equally everywhere from 0 to 1, whereas in the second graph, we can see how the probability of each value is maintained around the same place:

(
a = Pwhite(0.0, 1.0).asStream; //Numbers between 0 and 1 with uniform distribution, as in white noise, also called rectangular distribution.
b = a.nextN(100000); //It creates an array asking "a" for values 100000 times.
b.plot("The values", bounds: Rect(10, 410, 520, 380), discrete: true); //This is just defining the pixels of the window that will display (plot) the values in discontinuous points (discrete).
([ 0 ] ++ b.histo(1000)).plot("Graphic representation of values distribution", bounds: Rect(10, 10, 520, 380), discrete: true) //The initial 0 is forthe initial space, then a histogram is created for the representation of the distributions.
)

//Using a simpler SynthDef for the sonic examples (without the detuning):
(
SynthDef(
	\simpleSine,
	{|out, freq, amp, pan, gate = 1|
		var signal, env;

		signal = SinOsc.ar(freq);
		env = EnvGen.ar(
			Env.asr(0.01, amp * 0.5,0.1),
			gate,
			doneAction: 2
		);
		Out.ar(out, Pan2.ar(signal * env, pan))
}).add
)

//Choosing notes from C1 to C8: uniform distribution model:
(
Pbind(
	\midinote, Pwhite(24, 108),
	\dur, 1/8,
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//Small fragments of six pitches: when the 6 iterations are done, the pattern receives "nil", so the Pbind stops there. Then, you can evaluate it again (sometimes when composing algorithmic music, it is better to have short outputs):
(
Pbind(
	\midinote, Pwhite(24, 108, 6),
	\dur, 1/8,
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//Now the uniform distribution is also applied to the durations. Try out the limitation of the number of iterations as in the former code, there can be found very interesting short motives:
(
Pbind(
	\midinote, Pwhite(24, 108),
	\dur, Pwhite(1/8, 1.0),
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//The entire Pbind in this following code is repeated 4 times, so there are four Pbinds sounding at the same time (the amplitude should be taken into consideration).
(
{
Pbind(
	\midinote, Pwhite(24, 108, inf).trace,
	\dur, Pwhite(1/16, 2.0),
	\amp, 0.1,
	\instrument, \simpleSine
).play
} ! 4 //Quadruplication of the whole Pbind.
)

//A smaller range could work better sometimes (here between B6 and B7). The durations are constant now, and back to the "piano" sound:
(
{
Pbind(
	\midinote, (Pwhite(95, 107, inf) - 48).trace, //Now going 4 octaves down: try other combinations.
	\dur, 1/8,
	\amp, 0.1,
).play
} ! 4
)

//EXPONENTIAL DISTRIBUTION (= exprand):

Pexprand(lo, hi, length) //Arguments.

//Graphical representation:
(
a = Pexprand(0.001, 1.0).asStream; //Only change here is that the range does not departure from 0, as the distribution is exponential (0 can't be touched, nor crossed).
b = a.nextN(100000);
b.plot("The values", bounds: Rect(10, 410, 520, 380), discrete: true); //The values are accumulated in the lower part of the range.
([ 0 ] ++ b.histo(1000)).plot("Graphic representation of values distribution", bounds: Rect(10, 10, 520, 380), discrete: true) //And here we can see the exponential graph.
)

//Here we can hear the exponential distribution, with a bigger presence of lower tones:
(
Pbind(
	\midinote, Pexprand(24, 108, inf),
	\dur, Pwhite(1/8, 1.0),
	\amp, 0.1,
	\instrument, \simpleSine
).play
)

//Applied to the durations, we get more organic phrases:
(
Pbind(
	\midinote, Pexprand(24, 108, inf),
	\dur, Pexprand(1/16, 2.0),
	\amp, 0.1,
	\instrument, \simpleSine
).play
)

//The first line of the following example gives us the random seed of the evaluation of the code, printed in the postwindow. Then, we can replace its value with that number in order to obtain the same exact random progression of pitches and durations:
(
thisThread.randSeed = Date.seed.postln; //The random seed is named using the date and time, thereby avoiding any repetition of numbers:
Pbind(
	\midinote, Pexprand(24, 108, inf),
	\dur, Pexprand(1/16, 5.0),
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//Replace the number with the value given by the former code and observe how the random values are now the exact same:
(
thisThread.randSeed = 78814054; //Replace the number here.
Pbind(
	\midinote, Pexprand(24, 108, inf),
	\dur, Pexprand(1/16, 5.0),
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//Control of the octaves and pitches within a specific mode (Messiaen's?)
(
thisThread.randSeed = Date.seed.postln;
Pbind(
	\scale, [ 0, 3, 4, 5, 6, 9, 10, 11 ],
	\degree, Pwhite(0, 7, exprand(2, 12)), //It outputs 2 to 12 notes (most likely a smaller number because of the exponential distribution).
	\octave, Prand([ 5, 6, 7 ], inf), //The difference between Pwhite and Prand is that Prand receives a specific list of values while Pwhite receives a range.
	\dur, Pexprand(1/16, 2.0),
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//NORMAL OR GAUSSIAN DISTRIBUTION: priority given to the central values within a range.

Pgauss(mean, dev, length) //Arguments (mean is the center, dev is the maximum deviation from that center to left and right (the width of the "gaussian bell", how fast or slow the values grow or decrease), length is the nymber of values.

//Graphical representation:
(
a = Pgauss(1.0, 0.25).asStream; //Center = 1, 0.25 = deviation (is the width of the gaussian bell).
b = a.nextN(100000);
b.plot("The values", bounds: Rect(10, 410, 520, 380), discrete: true); //Values are accumulated around 1.
([ 0 ] ++ b.histo(1000)).plot("Graphic representation of values distribution", bounds: Rect(10, 10, 520, 380), discrete: true) //Central values are more probable than extreme values.
)

//Here the sonic example: the gaussian distribution is applied to midi note: the pitch can be deviated within a range from 81 to 87 approximately (it does not mean that it goes from 82 to 86, it is not linear. Thus, we obtain microtones as well):
(
Pbind(
	\midinote, Pgauss(84, 2).trace, //Observe that the values are not integers.
	\dur, 0.1,
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//Using the former synthDef \newSine (if too far in the code, you can use ctrl + F in order to search for the name and find it within the code). It sounds granular because of the short duration of the synths:

(
Pbind(
	\freq, Pgauss(5000, 1250),
	\pan, Pgauss(0, 0.3),
	\dur, 0.01,
	\amp, 0.05,
	\instrument, \newSine
).play
)

//Normal distribution applied to rhythms: dev = 0 would be a regular pulse. The wider the deviation, the greater the difference between the pulses. Observe that dev = 1 is already a relatively big deviation:
(
Pbind(
	\midinote, Pgauss(90, 1),
	\dur, Pgauss(1, 0.25),
	\instrument, \simpleSine //Bewere the change of synth.
).play
)

//Creating chords: Ptuple separates each freq created by Pgauss, then a different octave is added to each of those freqs:
(
Pbind(
	\midinote, Ptuple({ Pgauss(36, 1) } !3) + [ 0, 24, 36 ], //Three frequencies, three octaves.
	\dur, Pgauss(3, 0.5), //Here there is a greater range of durations because of the greater deviation.
	\instrument, \simpleSine //Try with the other synths or without \instrument (default piano).
).play
)

//PSEG: the pattern for creating segments --> envelopes: thus, we can draw the behavior of Pbind in time.

Pseg(levels, durs, curves) //Arguments as in a simple envelope.

//Example with sound: envelope from 60 to 67 midi, in 5 seconds, and going to back down in 0.2: it actually performs the envelope in loop, so there is no need for one less value of durations because we need that value for coming back to the first value and close the circle.
(
Pbind(
	\instrument, \simpleSine,
	\midinote, Pseg(Pseq([ 60, 67 ], inf), Pseq([ 5, 0.2 ], inf)).trace,
	\dur, 0.1
).play
)

//TENCENDY MASK (well, this term was made up by my professor, so I wouldn't use it over there):

//We choose random value within two limits and these two limits (low and high) change in time. It is difficult to perceive the "drawing" that the limits describe in time, so the paths need to be simple enough (one example of not being perfectly able to perceive the drawings is Xenakis' Pithoprakta alongside its graphical representation: for example, a range that open and close in a specific direction upwards or downwards, etc.
//This is especially useful applied to granular synthesis, controlling the positions within the buffer, the grain durations, the separation (wait time) between grains, etc.

//Using a new SynthDef for the sonic examples:
(
SynthDef(
	\saw,
	{| freq |

		OffsetOut.ar(0,
			Saw.ar(freq)
			*
			EnvGen.ar(Env.sine(0.3, 0.05),
				doneAction: 2
			)
		)
}).add
)

//First of all, defining the lines (limites), then implementing the Pbind: notice that the range of freqs is narrower up to 100 midi unification and then it descends reaching the widest range from 10 to 70 midi:
(
var lineA, lineB;

lineA = Pseg( //Bottom line.
	Pseq([ 85, 100, 10 ], inf), //MIDI values (from 85 to 100, to 10 and back to 85).
	Pseq([ 10, 10, 0 ], inf), //Durations of 10 second between each value and 0 to get back to the beginning, thus jumping back).
);
lineB = Pseg( //Top line.
	Pseq([ 90, 100, 70 ], inf), //Same number of values as in the previous line.
	Pseq([ 10, 10, 0 ], inf), //Durations synchronized between both lines.
);

Pbind(
	\instrument, \saw,
	\midinote, Pwhite(lineA, lineB),
	\dur, 0.015
).play
)

//Here trying to represent the lines graphically: same envelopes as in the former code (also, you can see in the help document of the Plotter the function of each letter command. For example, "s" superposes the graphs):

( //Turning each envelope into a stream:
a = Pseg(
	Pseq([ 85, 100, 10 ], inf),
	Pseq([ 10, 10, 0 ]/20, inf),
).asStream;
b = Pseg(
	Pseq([ 90, 100, 70 ], inf),
	Pseq([ 10, 10, 0 ]/20, inf),
).asStream;
)

( //Now we create empty arrays and fill them up with the values from the former Pseg using a Routine to activate the streams:
~arrayA = [];
~arrayB = [];
Routine({
	1000.do({
	~arrayA = ~arrayA.add(a.next);
	~arrayB = ~arrayB.add(b.next);
		(1/1000).wait
	})
}).play
)
p = [ ~arrayA, ~arrayB ].plot //Now it displays both lines with the values and pressing "s" they superpose and create the graphs with the limits:

//BROWNIAN MOTION: there is a continuous addition or subtraction of a number within a range to the original output:

a = 1
a = (a + rrand(-1.0, 1.0)).fold(0.0, 10.0) //"a" is originally = 1, then it is reassigned and with each evaluation, a random number between -1 and 1 is added. Fold is just keeping the range from 0 to 10.

//Pbrown is the pattern for brownian movement:

Pbrown(lo, hi, step, length) //Arguments: low and high boundaries of values (as with fold earlier), step (max deviation) and number of values (length).

//Graph of the tendency applied to 100000 values: observe that there are not many great jumps between random values:
(
a = Pbrown(0.0, 10.0, 0.1, inf).asStream;
a.nextN(100000).plot
)

//Sonic example using the chromatic scale:
(
Pbind(
	\midinote, Pbrown(60, 96, 1),
	\dur, 0.1,
	\instrument, \simpleSine //Former SynthDef for the distributions.
).play
)

////////////////////////////////////////////////////////////////////////

//EXTENSIONS FOR THIS CHAPTER:

//Creating a displacement of the phase of two similar melodies (as in Steve Reich's piano phase, for example):
(
SynthDef(
	\saw2,
	{ arg freq = 60, amp = 0.051, gate = 1;
		var env, signal;

		signal = LPF.ar(LFSaw.ar(freq), 440);
		env = EnvGen.ar(Env.adsr(0, 0, 1, 1), gate, doneAction: 2);

		Out.ar(0, Pan2.ar(signal, 0, amp * env))
}).add
)

//Here the two Pbind displaced: this could be done within the same Pbind, creating two patterns in the key \dur (maybe Ptupple is not necessary because the freqs are shared and not independent?):
(
Pbind(
	\instrument, \saw2,
	\midinote, Pseq([48, 46, 44, 42], inf),
	\amp, 0.1,
	\dur, Pseq([0.5, 0.5, 1, 1], inf),
).play;
Pbind(
	\instrument, \saw2,
	\midinote, Pseq([48, 46, 44, 42], inf),
	\amp, 0.1,
	\dur, Pseq([0.5, 0.5, 0.75, 1], inf),
).play
)

//PDEF: There is the possibility of changing the parameters without stopping the server using Pdef:
(
Pdef(
	\x, Pbind(
		\instrument, \saw,
		\midinote, Pseq([48, 46, 44, 42] + 12, inf),
		\amp, 0.1,
		\dur, Pseq([0.5, 0.5, 0.75, 1], inf),
	)
).play
)

//Applying the Fibonacci series to Pbind:

Array.fib(100, 0, 1); //Within a series of 100 numbers from the Fibonacci series, the 32bits of the integers already reach the limit of SC so there are negative values.
Array.fib(100, 0, 1.0); //Once we add the float value, the 64bits of floats allow us to avoid negative numbers.

x = [0.0] ++ Array.fib(10, 0, 1.0) % 4; //Ten values from the Fibonacci series, limited within the module 4, and adding a 0 at the beginning of the series.

//So in here such series is converted into pitches following the doriand scale (applying the Fibonacci values to the degrees of the scale, turning them into a loop thanks to the infinite Pseq). This could be applied to a library of samples (and the Pbind connected to the SynthDef that would extract the samples), for example, featuring percussion instruments. Also, try to change the module so you can obtain more values and different series for the loop.
(
Pdef(
	\x, Pbind(
		\instrument, \default,
		\scale, Scale.dorian,
		\degree, Pseq(x, inf),
		\dur, 0.1,
		\amp, 0.1
	)
).play
)