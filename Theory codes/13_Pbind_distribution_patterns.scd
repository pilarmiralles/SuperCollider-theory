//13 - PBIND
//////////////////////

//INTRODUCTION
//Associations between objetcs: we can use the relationship key --> value:

a = \freq -> 440 //The key \freq is associated to the value 440, and this association is contained in the variable "a".

//Now we can ask "a" about its key or its value:

a.key
a.value

//Besides Array, there are other classes regarding collections: a Dictionary is a collection of associations:

d = Dictionary[ \freq -> 440, \amp -> 0.1 ] //The use of [] without the specification of the type of collection is an Array by default because it is the most common collection.

//We ask "d" about the value in any of the keys contained within the dictionary (the keys within the dictionary are used as indexes --> the order within the dictionary is not important unlike the order within an array: this is why we don't use numbers as indexes anymore in this context):

d[\freq]
d[\amp]

//There is another type of collection called IdentityDictionary, which accesses the keys much quicker because it compares them using identity instead of equivalence: hence we only use symbols as keys:

"horse" == "horse" //"True": equivalent --> two different strings featuring the same characters.
"horse" === "horse" //"False": not identical --> they are not the same object.
\horse === \horse //"True": equivalent AND identical --> Symbols featuring the same name represent the same object.

//Then, the series of Classes within the Class Tree is (Array is in a different super class, SequenceableCollection, alongside the collections in which the order of the elements is important):

Collection --> Set (set according to equality) --> Dictionary (associative collection mapping keys to values) --> IdentityDictionary (dictionary based on identity / symbols) --> Environment (a dictionary which can serve as a 'name space' for functions) --> Event (an environment that represents an action)

//Next, we will focus on that last subclass named Event, with which we can created sonic events, that is to say, something with frequency, amplitude, duration, etc. It works with .play.

Event[ \midinote -> 61, \amp -> 0.1, \dur -> 1 ] //Here is an event with some values associated to some keys.

//In order to make it sound according the given values (associations), we need to implement the method .play:

Event[ \midinote -> 61, \amp -> 0.1, \dur -> 1 ].play //The default sound in SC is a very ugly and cheap piano sampler (although it has an interesting envelope if sustained).

(midinote: 61, amp: 0.1, dur: 1, pan: 1).play //When the Event is already created, we can change the values in this other way (like a shortcut). All values can be replaced or reasigned as with variables. All defined keys have their own default value. It is also possible to define new associations apart from the default ones.

//In summary (for instance):

Event[].play
(dur: 3, midinote: 71, amp: 0.5).play

//In here we can see all the default keys and values of Event:

Event.default.parent.associationsDo(_.postln);"" //The empty string "" at the end provokes that the last element to be returned and printed is an empty string, avoiding lots of extra lines. For example, we can see that the default value for the key "pan" is 0.0 (and indeed we already have an estereo signal).

//For instance, there are several ways of writing the pitch (this happens to many other parameters, as we'll se later on):

(midinote: 60).play //In Midi values.
(freq: 5000).play //In Hz.
(note: 2).play //In pitch class (number of semitones into a scale from C).

/////////////////////////////////////////////////////////////////////////////////

//PBIND
//Most popular class in SC :)
//Pbind sequences events (the syntax here is behind the class and not exposed as when we build our own routines, but many processes are much more doable and efficient using Pbind. As we will see later on, Pbind can be connected to our own SynthDef, but for now we will use the piano sound of SC, which is actually a default SynthDef called "default" (this is a reason for not using that name in any other SynthDef, as we would lose the communication with this default SynthDef). Pbind is also based on key-value associations:

Event[].play //A single sonic event (default parameters).
Pbind().play //A stream of sonic events.

//For example:

Pbind(\midinote, 60, \dur, 1).play //It is going to play successively the event defined by the keys: a middle C every second. It is a stream of sonic events.

//Now the fun part is that the keys do not only receive fixed numbers, but they can also be defined by patterns. The method .asStream is no longer needed because Pbind is already turning the patterns into streams (like an embedded or nested pattern):

Pbind(\midinote, Pseq([60, 62], inf), \dur, 1).play //Alternating between two pitches with a Pseq.

//This would be the equivalent routine to the Pbind above, just to show the shortcut Pbind provides us with (for certain algorithmic processes, making your own routines could be more effective though, it all depends on the result you pursue):
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

p = Pbind(\a, 1, \b, 2, \z, 789).asStream //Using .asStream instead of .play avoids the control of the clock over the events: now it is just a stream. We are going to use an empty event which will act as a .next for our Pbind, and which will be filled up with the values we wrote inside "p" before:

p.next(Event[]) //Remember that the order of the keys does not matter.

p.next(Event[ \a -> 0, \b -> 0, \c -> 1000 ]) //We can use a non-empty event, but the values in identical keys will be replaced with those in the Pbind (they are reassigned from the Pbind to the Event and not vice-versa), new keys will be added to the collection and keys only present in Pbind will appear too.

//Las example: you can evaluate the event multiple after running the Pbind and see the successive values:
p = Pbind(\a, Pseq([ 0, 1 ], inf), \b, Prand([ 100, 200 ], inf)).asStream
p.next(Event[])

///////////////////////////////////////////////////////////////////////////////////////////////////////

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
Pbind(\amp, Prand([ -36, -30, -24, -18, -12 ].dbamp, inf), \dur, 1/8).play //Using a pattern with dB values (be aware of using the method .dbamp when working with  amp in db values).
Pbind(\db, Prand([ -36, -30, -24, -18, -12 ], inf), \dur, 1/8).play //Using key \db so the method .dbamp is not needed (same result as former line).

//Simple example: 90% of the notes are more likely to be soft, 10% to be loud:

(
Pbind(
	\midinote, Pseq([ 61, 71 ], inf),
	\dur, Pseq([ 0.25, 0.5, 0.25 ] / 4, inf),
	\amp, Pwrand([ 0.01, 0.1 ], [ 0.9, 0.1 ], inf)
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
	\amp, Pwrand([ 0.01, 0.1 ], [ 0.9, 0.1 ], inf)
).play
)

//KEY FREQ:
//Several ways to specify the frequency, as we saw before:

\freq //In Hz.

//G overtones, following the natural tunning (whole multiples of the fundamental pitch):
(
Pbind(
	\freq, Pseq([ 100, 200, 300, 400, 500, 600, 700 ], inf),
	\dur, 0.1
).play
)

\detune //A key to work with \freq (also in Hz):

//Each tone is detuned -50 Hz (remember that the frequency in Hz behaves exponentially):
(
Pbind(
	\freq, Pseq([ 100, 200, 300, 400, 500, 600, 700 ], inf),
	\detune, -50,
	\dur, 0.1
).play
)

//Multichannel expansion (see help document): if an array of two frequencies is sent to the key freq, two sonic events will be created in parallel. The rest of the keys are shared between both events (beware of the amplitude). A4 and its natural fifth (* 1.5), but affected by the key detune, it seems to be a sixth:
(
Pbind(
	\freq, [ 440, 440 * 1.5 ], //The channel distribution depends on the panning within the SynthDef (which is 0 by default). Pan = 1 will put both frequencies through the right channel.
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

//Another example using the detune to create two frequencies: we can hear 3 beats per second because of the frequency difference:
(
Pbind(
	\freq, 1000,
	\detune, [ 0, 3 ],
	\dur, 9 //Nine seconds of duration.
).play
)

//KEY NOTE: another way of setting the frequency consists of using pitch class values (numbers from 0 to 11, as 12 will be C again. It is not exactly pitch class because it will add the octave difference when going beyond 12 or under 0 (-1 = lower B, 12 = higher C).

//Chromatic scale: by default, 0 = C4 (middle C):
(
Pbind(
	\note, Pseq([ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11 ], inf),
	\dur, 0.2
).play
)

//Key octave: to specify the octave instead of calculating the number when using \note. The middle C is the octave 5 here (because middle C is 60 midi, so 60 / 12 is 5, is the fifth octave in midi numbers from 0):
(
Pbind(
	\octave, 5, //Try other values such as 3 or 7.
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

//Using Ptuple: Ptuple creates in each iteration an array with the values given by the several patterns within its list (here, a Prand duplicated). Then, those values are distributed between the two events created because of the array of two values in \octave, for instance:
(
Pbind(
	\octave, [ 4, 6 ],
	\note, Pseq([ 0, 2 ], inf),
	\dur, 2,
	\amp, Ptuple({ Prand([ 0.05, 0.1, 0.2 ], inf) } !2).trace //.trace to visualize the values coming out of a specific pattern.
).play
)

//Another example with Ptuple: in this case, it directly creates two events because its output in an array of two values, one from each of the Prand of its list:
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
//See line 338 for another example of Ptuple.

//Last example taking advantage of a fast octave change, alternating only between two pitches:
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
	\note, Pn(Pshuf((0..11))), //Random permutations using Pn and Pshuf (different from Prand as it plays the entire series of scrambled numbers from 0 to 11 instead with no repetitions until next chosen order. Prand chooses one single value from its list, so repetition may occure before all values are played.
	\octave, Pn(Pshuf((2..9))), //(Only parameter with less than 12 different values).
	\dur, Pn(Pshuf((1..12))) * (1/32), //From 1 to 12 units, then multiplied by 1/32 so one unit = 32nd-note and values above 1 will bring about longer durations.
	\db, Pn(Pshuf((-6, -12..-72))), //Amplitude in dB.
).play
)

//KEY STEPSPEROCTAVE: the default value is 12. 12 steps per octave is the chromatic scale in equal temperament. We can create other divisions of the octave, bringing about microtones (and macrotones?):

//Dividing the octave in 13 equal parts:
(
Pbind(
	\stepsPerOctave, 13,
	\note, Pseq(Array.series(14, 0, 1), inf), //A series of 14 steps so we have all the tones from an octave featuring our new division.
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

//This is an interesting example in which we use new methods: there is a melody from Bach's Invention no. 2 sequenced by the Pseq for the pitches. There are 18 notes in the melody, thus in stepsPerOctave we use a Pstutter, which is a pattern that will repeat a certain number of times each value produced by the pattern in its second argument, which in this case is augmenting by 1 the number of divisions of the octave using Pseries (functions as Array.series). This will provoke that the intervals of the melody are smaller each time it is repeated (this takes some time). The duration of each note of the melody is also sequenced in the key dur (Pn is used just to avoid repeating the same value in the Pseq's list many times) and then it is multiplied by a Pgeom (which is the equivalent of Array.geom in a pattern): this will speed up the progression every time more (the speed will increase exponentially, so the process of speeding up will reach a point when it becomes much faster in very little time):

//VERY IMPORTANT: STOP THE SYNTH WHEN A CERTAIN EXTREME IS REACHED (around the 80th iteration), OTHERWISE, THE SERVER WILL COLLAPSE BECAUSE OF THE INFINITE LOOP!!! (If this happens, be patient to find the option "quit interpreter" in the Language menu).
(
Pbind(
	\stepsPerOctave, Pstutter(18, Pseries(12, 1, inf)).trace, //The more steps per octaves, the narrower the distances between the pitches of the melody.
	\note, Pseq([ 2, 4, 5, 7, 9, 10, 1, 10, 9, 7, 5, 4, 5, 9, 14, 7, 13, 16 ],
		inf),
	\dur, Pseq([ Pn(0.25, 12), Pn(0.5, 6) ], inf)
	*
	Pgeom(0.5, 0.999, inf).trace,
	\amp, 0.15
).play
)

//KEY SCALE Y DEGREE

\scale //It works alongside the key \degree. The scale is defined with pitch classes (number of semitones within the chromatic scale from C).
\degree //This key defines the degrees of the chosen scale but: the tonic = 0, the dominant = 4, so the numbers change a bit compared to tonal harmony (you can also use the conventional numbers and then subtract 1 to the whole list, if that is clearer). Indeed, the degrees are referring to the index of the pitches defined in the \scale key within its array.

//Here is a whole C major scale, but it only plays the degree 0, which is C, as stated in \degree:
(
Pbind(
	\scale, [ 0, 2, 4, 5, 7, 9, 11 ],
	\degree, 0,
	\dur, 0.2
).play
)

//This is the entire scale in order thanks to the Pseq in \degree (this can be done in many ways, for example, using Pseries):
(
Pbind(
	\scale, [ 0, 2, 4, 5, 7, 9, 11 ],
	\degree, Pseq((0..7), inf),
	\dur, 0.2
).play
)

//First time: whole scale in order, second time: eight random notes from the scale:
(
Pbind(
	\scale, [ 0, 2, 4, 5, 7, 9, 11 ],
	\degree, Pseq( //Note on Ptuple: if using here Ptuple instead of Pseq, two different Events would be created combining the Pseq and Prand in parallel.
		[
		Pseq((0..7), 1),
		Prand((0..7), 8)
		], inf),
	\dur, 0.2
).play
)

//Both keys \scale and \tuning are used to make scales, you can press ctrl + i over the class Scale in order to see all the implemented scales by default (and you can use their names instead of writing the numbers, but it is always good to think about your own scales too):

Scale.scaleName //This is how this class would work: it can be put into the \scale key directly. See all the possibilities using ctrl + i.

//Example of implementation of the class Scale (same code as the former one, just changing the scale):
(
Pbind(
	\scale, Scale.pelog, //The pelog scale, that Xenakis loved so much. He especially used four notes B-C-E-F, two perfect fourths a semitone apart, good balance of tension and resolution ([0, 1, 5, 6] in pitch class).
	\degree, Pseq(
		[
			Pseq((0..4), 1), //Patterns adapted to the number of pitches of the scale (which is 5).
			Prand((0..4), 4)
	], inf),
	\dur, 0.2
).play
)

//Using Pbrown (brownian movement):
(
Pbind(
	\scale, Scale.pelog,
	\degree, Pbrown(0, 24, 3), //Values from 0 to 24, but the maximum step is 3, so the randomness is very organic.
	\octave, 3, //We can also apply the key \octave to any scale from the class Scale.
	\dur, 0.2
).play
)

//KEYS FOR DURATION: \dur and \legato:

\dur //This indicates the time between each event in seconds.

\legato //By default, \legato has a value of 0.8: the real duration of the sound (of the sustain time of the envelope) = \dur * \legato: hence, using 0.1 of legato means making the event sound a 10% of the time between it and the next event. It is also possible to use a number higher than 1: in this case, the Events will overlap. Be aware that there will be several synths activated at the same time.

Pbind(\dur, 1, \midinote, Pseq((60..66), inf)).play //The pitches are separated by 1 second, by the real duration by default is 0.8 seconds. If the SynthDef we use features some release (fade-out) then the separation will be milder (the release of the envelope would start at 0.8 seconds, being the duration = 1 and the legato by default).

Pbind(\dur, 1, \legato, 5, \midinote, Prand((36..84), inf)).play //Random pitches (wider range) overlapped between them as the legato is 5.

\stretch //Then, \stretch is a factor for the duration: it lengthens or shortens the durations proportionally.

//For example, here we use our own numbers for duration (number of units), then the \stretch sets the note value (the unit) as 8th-notes:
(
Pbind(
	\dur, Prand([3, 5, 7, 11], inf),
	\stretch, 1/8,
	\midinote, Prand((60..72), inf)
).play
)

\sustain = \dur * \legato * \stretch //The key \sustain is equal to this operation, but it is not so recommended: it is easier to set durations using \dur and \legato, and maybe \stretch, in order to understand what is happening behind.

///////////////////////////////////////////////////////////////////////////

//SECOND PART: USING OUR OWN SYNTHDEFS:

//KEY INSTRUMENT: so we can use our own Synths:

Synth(\default) //This is the SynthDef we have been using until now (the cheap piano sampler from SC).

//Now we can create and implement our own "instruments": let's use this super basic SynthDef:

(
SynthDef(
	\newSine,
	{ arg out, freq, amp, pan, gate = 1;
		var signal, env;

		signal = Mix(SinOsc.ar(freq * [ 1, 1.01 ], 0, 0.5)); //Two frequencies are produced with 0.01 deviation factor, then they are mixed producing this little detune or beating.

		env = EnvGen.ar(
			Env.asr(0.01, amp * 0.5, 0.3), //Envelope with attack, sustain and release, because Pbind needs to open and close the gate.
			gate, //Gate needs a 1 by default in order to boot up the envelope right away. Pbind sends a 0 to the gate each time it's done with a synth, then it picks up again the 1 by default set in the SynthDef.
			doneAction: 2 //doneAction = 2 is essential to keep each Synth out of the server when it is done.
		);

		Out.ar(out, Pan2.ar(signal * env, pan)) //We apply Pan2, as the output of the Mix is a mono signal.
}).add
)

//This would be the connection to the new instrument through the name of the SynthDef, and its default values (all arguments included in the SynthDef with our own default values or rather the default values of the Event keys (only replaced automatically in the keys defined by default: our own arguments that are not in that list would need default values within the SynthDef if not defined in Pbind):

Pbind(\instrument, \newSine).play

Pbind(\instrument, \newSine, \midinote, Pseq([ 72, 67, 68, 75 ], inf)).play //For example, \midinote is going to be placed automatically in the freq argument (and converted to Hz).

//Another example using the same instrument:
(
Pbind(
	\instrument, \newSine,
	\midinote, Pn(Pshuf([ 40, 42, 43, 45, 46 ] + 24, 2), inf), //Two repetitions of each order.
	\dur, 0.5 / (180/60), //Using 8th-notes considering the 180 quarter-notes per minute (180/60).
	\legato, 0.5, //Each note is half the duration of the space between the notes (the release of the envelope starts at half of the duration set in \dur).
	\amp, Pwrand([ 0.1, 0.7 ], [ 0.8, 0.2 ], inf), //There are some sharper attacks.
	\pan, Pseq([ -1, -0.5, 0, 0.5, 1 ], inf)
).play
)

//In SC folder, there are some examples: in "pieces", there is this example called "Spacelab" (copied in this folder of theory files), easy to analyze and very useful regarding the use of Pbind. All layers are defined at the beginning and, at the end, everything is sequenced thanks to a Pseq.

//NEW SYNTHDEF: remember that gate = 1 and doneAction = 2 are essential in order to use your own instrument with Pbind:

(
SynthDef(
	\klank,
	{ |gate = 1, freqscale = 1, amp, pan| //the argument "freqscale" is not within Pbind's keys, but it can be defined within Pbind through the argument's name when using this SynthDef.
		var impulse, signal, env;

		impulse = Impulse.ar(0); //Impulse with freq = 0: it will create a single impulse at the beginning, as input for the Klank.
		signal = Klank.ar(
			`[
				Array.fill(10, { ExpRand(200, 2000) }),
				Array.fill(10, {Rand(0.2, 0.6) }),
				Array.fill(10, { Rand(0.01, 2) })
			],
			impulse,
			freqscale //Freqscale allows us to transpose the freqs of Klank (2 = octave up, 0.5 = octave down, 7/4 = minor 7th, etc. all overtone ratios).
		);
		env = EnvGen.ar(
			Env.asr(0.01, amp, 0.01),
			gate,
			doneAction: 2
		);
		Out.ar(0, Pan2.ar(signal * env, pan))
}).add
)

(
Pbind(
	\instrument, \klank,
	\dur, Pwrand([ 1, 0.5, 0.05 ], [ 0.7, 0.2, 0.1 ], inf) * (60/90), //The duration ratios are based on the 90 bpm applied as a factor at the end.
	\freqscale, Pseq([ 1, 2/3 ], inf),
	\amp, Pwrand([ 0.5, 0.1 ], [ 0.2, 0.8 ], inf),
	\pan, Prand([ -0.7, -0.3, 0, 0.3, 0.7 ], inf)
).play
)

//RESTS: \rest or just a backslash "\" in any key related to the frequency is interpreted as a rest:

Pbind(\note, Pseq([ 0, 2, \rest, 5, 6, \rest, 10, 11, \rest ], inf)).play

//Here is our newSine SynthDef again:
(
SynthDef(
	\newSine,
	{|out, freq, amp, pan, gate = 1|
		var signal, env;

		signal = Mix (SinOsc.ar(freq * [1, 1.01], 0, 0.5));
		env = EnvGen.ar(
			Env.asr(0.01, amp * 0.5, 0.3),
			gate,
			doneAction: 2
		);
		Out.ar(out, Pan2.ar(signal * env, pan))
}).add
)

//In this example, there is a random permutation each 5 repetitions of the Pshuf pattern: there are 5 different pitches and 3 rests to be sorted randomly. This will alternate the pitches and rests quite fast, giving a similar impression as in Ligeti's studio of blocked keys:

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

//The rests can be also created using the class Rest() in any key: here in \amp:

(
Pbind(
	\note, Pseq([ 0, 2, 4, 5, 6, 7, 10, 12 ], inf), //As Rest is used in \amp, the flow of pitches is maintained here despite the silences.
	\amp, Pseq(
		[
			Pseq([ 0.1, 0.1, Rest() ], 8), //We create the pattern note-note-rest. There are 8 pitches, so the pattern is displaced during 24 iterations (8 series of 3 pulses (note-note-rest)), coming back to its initial phase only after that.
			Pn(0.1, 8) //When the 24-note period is completed, the complete series of pitches appears (8 repetitions, because 8 pitches).
		],
		inf),
	\pan, Pseq([ Pn(0, 3 * 8), Pseq([ -1, 1 ], 4) ], inf), //The period of the amps coincides with the pan values: it maintaines a 0 during 3 * 8 iterations, then it alternates between -1 and 1 four times (for the last 8 iterations of the complete scale).
	\dur, 0.1,
	\instrument, \newSine
).play
)

//In case the class Rest is used in any of the keys related to the duration (mainly in \dur), we have to specify the duration of the Rest (in seconds):

(
Pbind(
	\note, Pseq([ 0, 2, 4, 5, 6, 7, 10, 12 ], inf),
	\dur, Pwrand([ 0.1, Rest(0.3) ], [ 0.8, 0.2 ], inf),
	\instrument, \newSine
).play
)

/////////////////////////////////////////////////////////////////////////////////////

//PATTERNS FOR STOCHASTIC DISTRIBUTION: stochastic = random = chance = haphazard...

//UNIFORM DISTRIBUTION (= rrand):

Pwhite(lo, hi, length) //Arguments.

//Example: in the first graph, we can see how the values are spread equally everywhere from 0 to 1, whereas in the second graph, we can see how the probability of each value is maintained around the same place:

(
a = Pwhite(0.0, 1.0).asStream; //Numbers between 0 and 1 with uniform distribution (as in white noise): also called rectangular distribution.
b = a.nextN(100000); //It creates an array asking "a" for values 100000 times.
b.plot("The values", bounds: Rect(10, 410, 520, 380), discrete: true); //This is just defining the pixels of the window that will display (plot) the values in discontinuous points (discrete: true).
([ 0 ] ++ b.histo(1000)).plot("Distribution of the values", bounds: Rect(10, 10, 520, 380), discrete: true) //The initial 0 is for the initial space, then a histogram is created for the representation of the distributions.
)

//Using a simpler SynthDef for the sonic examples (without the detuning):
(
SynthDef(
	\simpleSine,
	{|out, freq, amp, pan, gate = 1|
		var signal, env;

		signal = SinOsc.ar(freq);

		env = EnvGen.ar(
			Env.asr(0.01, amp * 0.5, 0.1),
			gate,
			doneAction: 2
		);

		Out.ar(out, Pan2.ar(signal * env, pan))
}).add
)

//Choosing notes from C1 to C8 with uniform distribution:
(
Pbind(
	\midinote, Pwhite(24, 108),
	\dur, 1/8,
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//Small fragments of six pitches: when the 6 iterations are done, the pattern receives "nil", so the Pbind stops there. Then, you can evaluate it again (sometimes when composing algorithmic music, it is better to obtain smaller outputs):
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

//The entire Pbind in this following code is repeated 4 times, so there are four Pbinds sounding at the same time (the amplitude should be taken into consideration). Durations and pitches are random differently for each Pbind:
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
a = Pexprand(0.001, 1.0).asStream; //The only change here is that the range does not start at 0, as the distribution is exponential (0 can't be touched, nor crossed).
b = a.nextN(100000);
b.plot("The values", bounds: Rect(10, 410, 520, 380), discrete: true); //The values are accumulated in the lower part of the range.
([ 0 ] ++ b.histo(1000)).plot("Distribution of values", bounds: Rect(10, 10, 520, 380), discrete: true) //Higher probability for lower values.
)

//Here we can hear the exponential distribution, with a bigger presence of lower tones (applied to freq in Hz, the distribution would result much more uniform):
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

//The first line of the following example gives us the random seed of the evaluation of the code, printed in the postwindow. Then, we can replace its value with that number in order to obtain the same exact random progression of pitches and durations (any random value):
(
thisThread.randSeed = Date.seed.postln; //The random seed is named using the date and time, thereby avoiding any repetition of seed numbers.
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

//Last example changing the octave and obtaining a short sentence:
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

Pgauss(mean, dev, length) //Arguments ("mean" is the center, "dev" is the maximum deviation from that center to left and right (the width of the "gaussian bell", how fast or slow the values grow or decrease), "length" is the number of values, as always.

//Graphical representation:
(
a = Pgauss(1.0, 0.25).asStream; //Center = 1, deviation = 0.25(width of the gaussian bell).
b = a.nextN(100000);
b.plot("The values", bounds: Rect(10, 410, 520, 380), discrete: true); //Values are accumulated around the center (= 1) or "mean".
([ 0 ] ++ b.histo(1000)).plot("Distribution of values", bounds: Rect(10, 10, 520, 380), discrete: true) //Central values are more probable than extreme values.
)

//Here the sonic example: the gaussian distribution is applied to midi notes: the pitch will stay around the mean value (84), deviating according to the veliation value (2), but this doesn't mean that the range of the pitch is 82-86 as the deviation is just a measurement of the width of the gauss bell, affecting the probability of the extreme values. In addition to this, as the resulting values are float numbers, microtones are brough about:
(
Pbind(
	\midinote, Pgauss(84, 2).trace, //Observe that the resulting values are not integers.
	\dur, 0.1,
	\amp, 0.2,
	\instrument, \simpleSine
).play
)

//Using the former synthDef \newSine (if too far in the code, you can use ctrl + F in order to search for the name and find it throughout the code). It sounds granular because of the short duration of the synths:

(
Pbind(
	\freq, Pgauss(5000, 1250), //The few lower values are really highlighted because they are not common.
	\pan, Pgauss(0, 0.3),
	\dur, 0.01,
	\amp, 0.05,
	\instrument, \newSine
).play
)

//Normal distribution applied to rhythms: dev = 0 would bring about a regular pulse. The wider the deviation, the greater the difference between the pulses:
(
Pbind(
	\midinote, Pgauss(90, 1),
	\dur, Pgauss(1, 0.25),
	\instrument, \simpleSine //Bewere the change of synth.
).play
)

//Creating chords: Ptuple separates each freq created by the three Pgauss, then a different octave is added to each of those freqs:
(
Pbind(
	\midinote, Ptuple({ Pgauss(67, 1) } !3) + [ 0, 14, 24 ], //Three frequencies, three octaves.
	\dur, Pgauss(0.5, 0.1),
	\instrument, \simpleSine //Try with other synths or without \instrument (default piano).
).play
)

//PSEG: the pattern for creating segments --> envelopes: thus, we can draw the behavior of Pbind over time.

Pseg(levels, durs, curves) //Arguments as in a simple envelope.

//Example with sound: envelope from 60 to 67 midi, in 5 seconds, and going to back down in 0.2: it actually performs the envelope in loop (as patterns are prepared for iterations), so there is no need for one less value of durations because we need that value for coming back to the first value and close the circle:
(
Pbind(
	\instrument, \simpleSine,
	\midinote, Pseg(Pseq([ 60, 67 ], inf), Pseq([ 5, 0.2 ], inf)).trace,
	\dur, 0.1
).play
)

//TENCENDY MASK (well, this term was made up by my professor, so I wouldn't use it over there):

//We choose random values within two limits and these two limits (low and high) change over time. It is difficult to perceive the "drawing" that the limits describe over time, so the paths need to be simple enough (one example of not being perfectly able to perceive the drawings is Xenakis' Pithoprakta alongside its graphical representation). Perceptible examples are a range that opens and closes in a specific direction (upwards or downwards), etc.
//This is especially useful when applied to granular synthesis, controlling the positions within the buffer, the grain durations, the separation (waiting time) between grains, etc.

//Using a new SynthDef for the sonic examples: a simple sawtooth wave with a sine envelope:
(
SynthDef(
	\saw,
	{| freq |

		OffsetOut.ar(0,
			Saw.ar(freq)
			*
			EnvGen.ar(
				Env.sine(0.3, 0.05),
				doneAction: 2
			)
		)
}).add
)

//First of all, defining the lines (range limits), then implementing in the Pbind: notice that the range of freqs is narrower up to 100 midi ("unison") and then it descends reaching the widest range from 10 to 70 midi:
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
p = [ ~arrayA, ~arrayB ].plot //Now it displays both lines with the values and pressing "s" they superpose and create the graphs with the limits between which the frequencies were being chosen before:

//BROWNIAN MOTION: there is a continuous addition or subtraction of a number within a range to the original output:

a = 1
a = (a + rrand(-1.0, 1.0)).fold(0.0, 10.0) //"a" is originally = 1, then it is reassigned and with each evaluation, a random number between -1 and 1 is added. Fold is just keeping the range from 0 to 10. This is what brownian motion looks like.

//Pbrown is the pattern for brownian motion:

Pbrown(lo, hi, step, length) //Arguments: "low" and "high" boundaries of values (as with fold earlier), "step" (max deviation) and number of values ("length").

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
	{ arg freq = 60, amp = 0.1, gate = 1;
		var env, signal;

		signal = LPF.ar(Saw.ar(freq), 440); //LPF will cut the higher overtones of Saw.
		env = EnvGen.ar(Env.adsr(0, 0, 1, 1), gate, doneAction: 2);

		Out.ar(0, Pan2.ar(signal, 0, amp * env))
}).add
)

//Here the two Pbind displaced and here we find out the limitation of Ptuple: we can't apply Ptuple to the durations because two parallel Pbind need to be coordinated in time. Duplicating the Pbind would allow different times using randomness, but we wouldn't be able to set specific patterns for each. Therefore, in order to create events with different duration, we need to set two different Pbind:
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
	\dur, Pseq([Pseq([0.5, 0.5, 1, 1], 1), Pseq([0.5, 0.5, 0.75, 1], 3)], inf), //After certain number of iterations, it synchronizes again.
).play
)

//PDEF: There is the possibility of changing the parameters without stopping the server using Pdef (as in Routines using Tdef):
(
Pdef(
	\x, Pbind(
		\instrument, \saw,
		\midinote, Pseq([48, 46, 44, 42] + 12, inf),
		\amp, 0.1,
		\dur, Pseq([0.5, 0.5, 1, 1], inf),
	)
).play
)

//Applying the Fibonacci series to Pbind:

Array.fib(100, 0, 1); //Within a series of 100 numbers from the Fibonacci series, the 32bits of the integers already reach the limit of SC so there are negative values.
Array.fib(100, 0, 1.0); //Once we add the float value, the 64bits of floats allow us to avoid negative numbers.

x = [0.0] ++ Array.fib(10, 0, 1.0) % 4; //Ten values from the Fibonacci series, limited within the module 4, and adding a 0 at the beginning of the series.

//So in here such series is converted into pitches following the doriand scale (applying the Fibonacci values to the degrees of the scale, turning them into a loop thanks to the infinite Pseq). This could be applied to a library of samples (and the Pbind cound be connected to the SynthDef that would extract the samples), for example, featuring percussion instruments. Also, try to change the module in "x" so you can obtain more values and different series for the loop.
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
