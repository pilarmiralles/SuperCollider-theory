//13 - PBIND

/////////////////////////////////////////////////////////////////////
//INTRODUCTION

//Associations between objetcs: we can use the relationship key --> value:
a = \freq -> 440 //The key \freq is associated to the value 440, and this association is contained in the variable "a".

//Now we can ask "a" about its key or its value:
a.key
a.value

//As we already know, there are other kinds of collections besides Array: A Dictionary is an associative (unordered) collection mapping keys to values. In a Dictionary, two keys match if they are equal (==), that is to say, strings and symbols can be both equally used as keys because the matching is done by equality and not identity:
d = Dictionary[\freq -> 440, \amp -> 0.1]

//We can ask "d" about the value in any of the keys contained within the dictionary (the keys within the dictionary are used as indexes: as mentioned, the order within the dictionary is not important unlike in an array, where we can use numbers as indexes):
d[\freq]
d[\amp]

//See more about Dictionary and its methods here: https://depts.washington.edu/dxscdoc/Help/Classes/Dictionary.html


//There is another type of collection called IdentityDictionary, which accesses the keys much quicker because it compares them using identity instead of equality (and hence we can only use symbols as keys):
//Remember:
"horse" == "horse" //"True": equivalent --> two different strings featuring the same characters.
"horse" === "horse" //"False": not identical --> they are not the same object.
\horse === \horse //"True": equivalent AND identical --> Symbols featuring the same name represent the same object.

//Then, the series of Classes within the Class Tree is (Array is in a different super class, SequenceableCollection, alongside the collections in which the order of the elements is important):
Collection --> Set (set according to equality) --> Dictionary (associative collection mapping keys to values) --> IdentityDictionary (dictionary based on identity / symbols) --> Environment (a dictionary which can serve as a 'name space' for functions) --> Event (an environment that represents an action)

//Next, we will focus on that last subclass named Event (usually used as a shortcut for an IdentityDictionary), with which we can created sonic events, that is to say, something with frequency, amplitude, duration, etc. It works with .play:
Event[\midinote -> 61, \amp -> 0.1, \dur -> 1] //Here is an event with some values associated to some keys.

//In order to make it sound according the given values (associations), we need to sent the message .play:
Event[\midinote -> 61, \amp -> 0.1, \dur -> 1].play //The default sound in SC is a very ugly and cheap piano sampler (although it has an interesting envelope if sustained).

(midinote: 61, amp: 0.1, dur: 1, pan: 1).play //When the Event is already created, we can change the values in this other way (like a shortcut). All values can be replaced or reassigned as with variables. All defined keys have their own default value. It is also possible to define new associations apart from the default ones.

//In summary (for instance):
Event[].play //Default Event.
(dur: 3, midinote: 71, amp: 0.5).play //New values.

//As said in the Help file: "The class Event provides a large library of default event instances and play functions, e.g. for pitch". In here we can see all the default keys and values of Event:
Event.default.parent.associationsDo(_.postln);"" //The empty string "" at the end provokes that the last element to be returned and printed is an empty string, avoiding lots of extra lines, and the underscore before .postln is just a shortcut meaning "apply to all items" (and thus all the list is printed). For example, we can see that the default value for the key "pan" is 0.0 (and indeed we already have an estereo signal when creating a defult Event).

//For instance, there are several ways of writing the pitch (this happens to many other parameters, as we'll se later on):
(midinote: 60).play //In Midi values.
(freq: 5000).play //In Hz.
(note: 2).play //In pitch class (number of semitones into a scale from C).


/////////////////////////////////////////////////////////////////////
//PBIND

//Pbind is one of the most popular classes in SC. According to the Help file, it "combines several value patterns to one event stream by binding keys to values". That is to say, in Pbind we can create a stream (a sequence) of sonic events, whose characteristics are defined by pairs key-value (normally, those used for Event by default and those defined to control the SynthDef to be played, we will see this later on). Because Pbind creates a stream, its keys can receive patterns (value streams).
//Pbind's implementation might seem to be more hidden than, for instance, a Routine (that is, might seem to be built at a higher level of coding, just like any pattern). Nonetheless, many processes will be much more efficient using Pbind instead of building the equivalent Routine. As with Routines, Pbind can be connected to our own SynthDef, but for now we will focus on Pbind itself, leaving the synthesis part to SC's ugly piano synth (which is a hidden SynthDef called "default", hence a reason not to use this name for any of our SynthDefs).

Event[].play //A single sonic event (default parameters).
Pbind().play //A stream of default sonic events.

//For example:
p = Pbind(\midinote, 60, \dur, 1).play //The event defined by the keys is played successively (a middle C every second, this is equal to the default parameters). If we open the node tree, we'll see a succession of synths one after another.
//We can apply some methods right away:
p.mute //Mutes the Pbind (there are no synths anymore in the node tree). In the help file it says: "keeps playing, but replaces notes with rests" (we'll see rests later on).
p.unmute //Resumes playing normally.
p.stop //Stops playing after the current event is finished (just like with Routine): as with anything that is not a function.play, try to get used to stopping the sound by using the method .stop instead of ctrl-period.
p.play //We can play again the Pbind.
p.reset //As in Routine, there is also the option of resetting (not possible to perceive in here as the events are all the same). I think after .stop, the stream is also reset.
p.pause //Can pause the stream (unlike mute, it does not keep running).
p.resume //And can resume from that point.

//Now for the fun part, as mentioned before, we can assign patterns to the keys instead of fixed numbers. The method .asStream is no longer needed because Pbind is already creating an event stream combining all patterns into it (as in a nested or embedded pattern):
p = Pbind(\midinote, Pseq([60, 62], inf), \dur, 1).play //Alternating between two pitches with a Pseq.
p.stop

//This would be the (almost) equivalent routine to the Pbind above, just to show the shortcut Pbind provides us with (for certain algorithmic processes, making our own routines could be more effective though, it all depends on the result we pursue):
(
var note;

note = Pseq([60, 62], inf).asStream;

r = Routine({
	inf.do({
		var synth;

		~synth = Synth(
			\default,
			[\freq, note.next.midicps, \amp, 0.1]
		);

		1.wait;
		~synth.release //In order to free the synth every second (the default synth does not seem to have doneAction 2).
	})
}).play
)

r.stop
~synth.free //Cannot really control much of the default synth because it is hidden.

//Before continuing, let's understand how to replace / reassign values in sonic events:
p = Pbind(\a, 1, \b, 2, \z, 789).asStream //Using .asStream instead of .play avoids the control of the clock over the events: now it is just a stream, which needs a .next to be asked for values (when executing it, the post window says we got a Routine). We are going to use an empty Event as .next for our Pbind, and which will be filled up with the values we wrote inside "p" before:

p.next(Event[]) //Remember that the order of the keys does not matter. We get the previous values in "p" in the post window.

p.next(Event[\a -> 0, \b -> 0, \c -> 1000]) //We can use a non-empty event, but the values in identical keys will be replaced with those in the Pbind (they are reassigned from the Pbind to the Event and not vice-versa), new keys will be added to the collection and keys only present in Pbind will appear too.

//Just like in any other pattern, we can obtain the successive values from Pbind's patters by successively executing the Event below:
p = Pbind(\a, Pseq([0, 1], inf), \b, Prand([100, 200], inf)).asStream
p.next(Event[])


/////////////////////////////////////////////////////////////////////
//FIRST PART: KEYS

//Understanding keys and their hierarchy can take some time. In the help file of Pbind and Event there is a list of certain keys (we also saw a complete list before that we can print on the post window): the important part of this at the very beginning is trying to adopt these names as a convention, also as argument names, because later on these keys will allow the automatic communication between our SynthDefs and Pbind. At the end of the Event help file (https://depts.washington.edu/dxscdoc/Help/Classes/Event.html) there is a graph showing the hierarchy of keys related to frequency (or pitch). We will understand this later, but, for example, using the argument "freq" in our SynthDef will allow us to use other keys such as "midinote" or "note" in our Pbind specifying that specific key as argument (as shown in the graph, "midinote" leads to "freq", so Pbind already knows that the input value is going to be a MIDI note to be send as freq in Hz to the SynthDef. In the Help file of Pbind, https://doc.sccode.org/Classes/Pbind.html, at the end of "SynthDef and Event" section, there is an explanation of how the values from the keys are eventually converted to freq in Hz in the SynthDef).
//The different levels of the hierarchy cannot be mixed up though: if we decide to work with midinote, they key freq is out of question, as it represents a different way of expressing pitch.


//KEY DUR: it is 1 by default (and by default, in seconds, that is, at 60 bpm):
//The key "dur" is a sub-key of "delta", which means "the time until the next event". By default, an event occupies an 80% of the duration value (if dur = 1, an event will sound for 0.8 seconds and then fade out). These properties can be changed as well, we'll see how later, when talking about other keys related to duration:

Pbind().play //A Pbind with all values by default.
Pbind(\dur, 0.25).play //Changing the default value of duration.
Pbind(\dur, Pseq([0.25, 0.5, 0.25], inf)).play //Using patterns.
Pbind(\dur, Pseq(Array.geom(20, 1, 0.8).mirror, inf)).play //Speeding up and slowing down.


//KEY AMP: it is 0.1 by default (normally measured as we would with a mul argument):

Pbind().play //By default.
Pbind(\amp, 0.1).play //Idem as default.
Pbind(\amp, 0.5).play //Louder.
Pbind(\amp, Prand([-36, -30, -24, -18, -12].dbamp, inf), \dur, 1/8).play //Using a pattern with dB values (be aware of using the method .dbamp when working with amp in db values).
Pbind(\db, Prand([-36, -30, -24, -18, -12], inf), \dur, 1/8).play //Using the key \db (sub-key of amp) so that the method .dbamp is not needed (same result as former line).

//Simple example: 90% of the notes are more likely to be soft, 10% to be loud:
(
p = Pbind(
	\midinote, Pseq([61, 71], inf), //We'll talk about frequency keys soon enough.
	\dur, Pseq([0.25, 0.5, 0.25] / 4, inf), //Divided by 4 = 4 times faster that the specified values.
	\amp, Pwrand([0.01, 0.1], [0.9, 0.1], inf)
).play
)
p.stop


//KEY PAN: it is 0 by default:

Pbind().play //Pan = center.
Pbind(\pan, 1).play //Pan = right.

//Same example as before, speed doubled and spread from left to center to right every three notes (synchronized with duration because both feature 3 values, although I think it is too fast to tell):
(
p = Pbind(
	\pan, Pseq([-1, 0, 1], inf),
	\midinote, Pseq([61, 71], inf),
	\dur, Pseq([0.25, 0.5, 0.25] / 8, inf),
	\amp, Pwrand([0.01, 0.1], [0.9, 0.1], inf) //The only random value is the amplitude.
).play
)
p.stop


//KEY FREQ: as mentioned in the Help file of Event, "the pitchEvent (frequency keys) has the most complex system of functions that provide a variety of useful ways to determine pitch":
//These are the four main keys to determine pitch:

\freq //Pitch as frequency in Hz (default value: 440 Hz)
\midinote //Pitch in MIDI values (default value: 60; 69 = 440 Hz).
\note //Pitch as a scale degree within an equal tempered scale (chromatic scale, default value: 0, middle C or 60 MIDI).
\degree //Pitcj as scale degree within a determined scale (default value: 0 = first degree of the scale).

//Let's start with the key FREQ:
//In the following example, we obtain the overtones from a G, following the natural or Pithagoric tuning (whole multiples of the fundamental freq):
(
p = Pbind(
	\freq, Pseq([100, 200, 300, 400, 500, 600, 700], inf),
	\dur, 0.1
).play
)
p.stop

//We can combine "freq" with the sub-key "detune", which is also measured in Hz. In this example, each tone is detuned by -50 Hz (remember that freq in Hz behaves exponentially = smaller distances between pitches in the upper register):
(
p = Pbind(
	\freq, Pseq([100, 200, 300, 400, 500, 600, 700], inf),
	\detune, -50,
	\dur, 0.1
).play
)
p.stop


//MULTICHANNEL EXPANSION IN PBIND:
//As mentioned in the Help file of Pbind: "If we supply an array for any argument, the synth node will automatically replicate to handle the additional arguments", that is to say, if an array of, for instance, two frequencies is sent to the key freq, two sonic events will be created in parallel (that is, summed in the output, and because of this, beware the amplitude). The rest of the keys are shared between both events.
(
p = Pbind(
	\freq, [440, 440 * 1.5], //An A4 and its natural fifth (* 1.5), although affected by the key detune. The channel distribution depends on the panning within the SynthDef (which is 0 by default). Pan = 1 will put both frequencies through the right channel, for example.
	\detune, -50,
	\dur, 0.2,
	\amp, 0.05
).play
)
p.stop

//Keys "dur" and "instrument" (which we will see later on) are an exception for the multichannel expansion of Pbind. Two different durs cannot be combined to expand a Pbind because events need to run in parallel (at the same time). But we will see solutions for this later on.
//It is also not possible to send an array of patterns for multichannel expansion but only patterns that return arrays:
Pbind(\degree, [Pseq([0, 2, 3], inf), Pseq([2, 4, 5, 6], inf)]).play; //This does not work.
Pbind(\degree, Pseq([[0, 2], [2, 4], [3, 5], [0, 6]], inf)).play; //This would be a solution.
//The pattern Ptuple transforms an array of patterns into a pattern that returns arrays:
Pbind(\degree, Ptuple([Pseq([0, 2, 3], inf), Pseq([2, 4, 5, 6], inf)])).play; //Same result as before.

//More examples of multichannel expansion: two freqs are played first, then just one. Here we can notice that the amp is doubled when the two freqs are played at the same time:
(
p = Pbind(
	\freq, Pseq([[440, 440 * 1.5], 220], inf),
	\detune, -50,
	\dur, 0.2
).play
)
p.stop

//Now we expand from the key detune, which creates two frequencies again: we can hear the 3 beats per second cause by the 3 Hz of detune between frequencies:
(
p = Pbind(
	\freq, 1000,
	\detune, [0, 3],
	\dur, 9 //Nine seconds of duration (including the 20% fade out and pause).
).play
)
p.stop


//KEY MIDINOTE: as seen before, pitch in MIDI values:
//Another example with Ptuple:
(
p = Pbind(
	\midinote, Ptuple(
		[
			Prand((60..84), inf),
			Prand((60..84), inf)
		]
	).trace //The method .trace allows us to print the values coming from a specific pattern (here, an array of values extracted by Ptuple). We should use it only with testing purposes.

).play
)
p.stop


//KEY NOTE: the next way of indicating frequency consists of using pitch class values, that is, integers from 0 to 11 representing (by default) semitones in a chromatic scale. It does not exactly match pitch class naming as when reaching 12, it will still count the pitch as the next octave and vice-versa (0 = middle C, -1 = lower B, 12 = higher C).

//Chromatic scale: by default, 0 = C4 (middle C, MIDI = 60):
(
p = Pbind(
	\note, Pseq([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], inf),
	\dur, 0.2
).play
)
p.stop

//Key octave: to specify the octave instead of calculating the number when using "note", we can use the sub-key "octave". The middle C is the octave 5 here (because middle C is 60 MIDI, and 60 / 12 is 5, is the fifth octave in MIDI numbers from 0):
(
p = Pbind(
	\octave, 7, //Try other values such as 3 or 5 (default).
	\note, Pseq([0, 2], inf),
	\dur, 0.2
).play
)
p.stop

//Three octaves at the same time, expanded (beware the amplitude):
(
p = Pbind(
	\octave, [4, 5, 6],
	\note, Pseq([0, 3], inf),
	\dur, 0.2,
	\amp, 0.02
).play
)
p.stop

//Using Ptuple again: as Prand is duplicated (array of two Prands), Ptuple is needed to extract for each event an array with the values given by each pattern in the list. The key octave is also contributing to the expansion (the two amplitude values are assigned to the two octaves created):
(
p = Pbind(
	\octave, [4, 6],
	\note, Pseq([0, 2], inf),
	\dur, 2,
	\amp, Ptuple({ Prand([0.05, 0.1, 0.2], inf) } !2).trace //.trace to visualize the values.
).play
)
p.stop

//Last example taking advantage of a fast octave change, alternating only between two pitches:
(
p = Pbind(
	\octave, Pseq([ 2, 3, 4, 5, 6, 7, 8 ], inf),
	\note, Pseq([ 0, 2 ], inf),
	\dur, 0.15
).play
)
p.stop

//Imitating Boulez's Structures for piano (but without the series), my teacher's joke (maximum level of randomness applied to pitch, duration, amplitude, octave, etc.):
(
p = Pbind(
	\note, Pn(Pshuf((0..11))), //Random permutations using Pn and Pshuf (different from Prand as it plays the entire series of scrambled numbers from 0 to 11 instead with no repetitions until next chosen order. Prand chooses one single value from its list, so repetition may occure before all values are played).
	\octave, Pn(Pshuf((2..9))), //("octave" is the only parameter with less than 12 different values here).
	\dur, Pn(Pshuf((1..12))) * (1/32), //From 1 to 12 units of duration, then multiplied by 1/32 so that one unit = 32nd-note and values above 1 will bring about longer durations.
	\db, Pn(Pshuf((-6, -12..-72))), //Amplitudes in dB.
).play
)
p.stop


//KEY STEPSPEROCTAVE: this sub-key of "note" indicates the number of divisions of the octave, which, by default, is 12 (= conventional chromatic scale in equal temperament). With this key, we can create other divisions of the octave, playing with "microtones" or "macrotones":

//Dividing the octave in 13 equal parts:
(
p = Pbind(
	\stepsPerOctave, 13,
	\note, Pseq(Array.series(14, 0, 1), inf), //A series of 14 steps so that we have all the tones from an octave featuring our new division (including the upper octave).
	\dur, 0.2
).play
)
p.stop

//Same example, dividing in 11 parts (and adjusting the Array.series' size):
(
p = Pbind(
	\stepsPerOctave, 11,
	\note, Pseq(Array.series(12, 0, 1), inf),
	\dur, 0.2
).play
)
p.stop

//Next example is an interesting one provided by my teacher: a melody from Bach's Invention no. 2 is sequenced by the Pseq for pitches and durations. There are 18 pitches in the melody: in stepsPerOctave we use a Pdup to duplicate 18 times each value produced by the Pseries, so that the stepsPerOctave value is different only when completing the melody. Intervals in the melody will therefore get subsequently smaller with each iteration of the complete sequence (this process takes some time). The duration is also synchronized with this process: the entire sequence is multiplied by a Pgeom, which is creating a geometric series of duration deviation (from half the values, to exponentially smaller values by factor 0.999). The series is infinite, thus at some point, it will be too fast for the computer to process and SuperCollider will crash (THIS WILL HAPPEN APPROX. WHEN STEPSPEROCTAVE = 80, look at the post window, in which the duration and stepsPerOctave values are printed and MAKE SURE TO STOP IT BEFORE THIS HAPPENS). In any case, to scape such a situation, just be patient when trying to drag the cursor to "quit interpreter" in the Language menu above):
(
p = Pbind(
	\stepsPerOctave, Pdup(18, Pseries(12, 1, inf)).trace, //Pdup: first arg = number of repetitions of each value; second arg = pattern in which values are duplicated.
	\note, Pseq([2, 4, 5, 7, 9, 10, 1, 10, 9, 7, 5, 4, 5, 9, 14, 7, 13, 16], inf), //The more steps per octaves, the narrower the distances between the pitches of the melody.
	\dur, Pseq([Pn(0.25, 12), Pn(0.5, 6)], inf)
	*
	Pgeom(0.5, 0.999, inf).trace, //Each duration value is a bit smaller (unlike stepsPerOctave, this deviation changes with each value and not with each whole sequence).
	\amp, 0.15
).play
)
p.stop


//KEY SCALE Y DEGREE: these two keys are commonly used together. The key "scale" defines the arrangment of degrees (either by hand or making use of the clas Scale, which we will see later), which are indicated as "notes" (that is, again, in pitch classes, taking the 12-tone chromatic scale as default reference). Then, the key "degree" allow us to access the degrees of the specified scale referring to them as indexes within the array of "scale" (so 0 = "tonic", and 4 = "dominant", if wanting to use tonal harmony terminology).

//Whole C major scale, but only playing degree 0, which is the C:
(
p = Pbind(
	\scale, [0, 2, 4, 5, 7, 9, 11],
	\degree, 0,
	\dur, 0.2
).play
)
p.stop

//Now we can play the entire scale (and upper octave) in order using Pseq with degrees 0 to 7 (could have also used Pseries):
(
p = Pbind(
	\scale, [0, 2, 4, 5, 7, 9, 11],
	\degree, Pseq((0..7), inf),
	\dur, 0.2
).play
)
p.stop

//Now we play the entire scale in order and then, eight random notes from it:
(
p = Pbind(
	\scale, [ 0, 2, 4, 5, 7, 9, 11 ],
	\degree, Pseq( //Here we have a sequence of patterns, not an array of patterns. If using Ptuple here instead of Pseq, two different events would be created and Pseq and Prand would be played in parallel.
		[
			Pseq((0..7), 1),
			Prand((0..7), 8)
	], inf),
	\dur, 0.2
).play
)
p.stop

//Let's take a look at the class Scale, with which we can create several types of scales. A complete list of the types of scale that this class supports (applied as messages) can be found in its source code (ctrl-i hovering on the class) or using this method (although it only shows the names and not the degrees):
Scale.directory //These "pre-made" scales have their own default tunings, which can be modified using the method .tuning (take a look at the Help file).

//Example of implementation of the class Scale (same code as the former one, just changing the scale):
(
p = Pbind(
	\scale, Scale.pelog, //The pelog scale, which Xenakis loved so much. He especially used four notes (G-Ab-C-Db in this transposition), two perfect fourths a semitone apart, good balance of tension and resolution ([0, 1, 5, 6] in pitch class).
	\degree, Pseq(
		[
			Pseq((0..4), 1), //Patterns adapted to the number of pitches of the scale (which is 5).
			Pxrand((0..4), 4)
	], inf),
	\dur, 0.2
).play
)
p.stop

//Using Pbrown (brownian movement):
(
p = Pbind(
	\scale, Scale.pelog,
	\degree, Pbrown(0, 24, 3), //Values from 0 to 24, but the maximum step is 3, so the randomness is very organic. These degrees cover 5 octaves (as the scale features 5 degrees within each octave).
	\octave, 3, //We can also apply the key \octave in this context (as the key scale works with pitch classes as so does the key note). In here, it acts as octave onset.
	\dur, 0.2
).play
)
p.stop


//KEYS FOR DURATION: in Pbind, the duration of the event and the duration of the synth are different.

\dur //The key "dur" refers to the time until the next event in the sequence of events: it is measured in beats (by defaul, these run at 60 bpm, so that dur can be measured in seconds, but this can be changed).
\stretch //This is one of the possible keys changing the tempo unit of "dur". The key "stretch", according to the help file, "scales event timings", so if we assign a 2 to stretch, durations will be twice as long and vice-versa (that is, stretch is a factor that lengthens or shortens the durations proportionally).
\legato //This key refers now to the duration of the synth, according to the help it is "the ratio of the synth's duration to the event's duration. By default, as commented earlier, it is 0.8 (an event of 1 second will be heard during 0.8 seconds, including afterwards a slight fade-out and a silence gap). This is, in fact, the duration of the sustain level of the envelope. The real duration is then \dur (* \stretch) * \legato. Numbers lower than 1 will bring about overlapping synths.
\sustain //This last key is in fact equal to the previous operation (\dur * \stretch * \legato) and, subsequentially, to the real duration of the synth.

//Some examples:
Pbind(\dur, 1, \midinote, Pseq((60..66), inf)).play //One pitch per second. At 0.8 seconds, the decay of the envelope is triggered.

Pbind(\dur, 1, \legato, 5, \midinote, Pxrand((36..84), inf)).play //Random pitches overlapping because of the legato value (5 units of duration).

//All durations in the series of the pattern are shortened proportionally by multiplying their value by 1/8:
(
p = Pbind(
	\dur, Prand([3, 5, 7, 11], inf),
	\stretch, 1/8,
	\midinote, Prand((60..72), inf)
).play
)
p.stop


/////////////////////////////////////////////////////////////////////
//SECOND PART: USING OUR OWN SYNTHDEFS

//Now that we got to know a few of the many keys that can be used with Pbind, we can start experimenting with the instrument it is connected to (other than the rather annoying \default synth).


//KEY INSTRUMENT: This key will allow the communication with a SynthDef.

//This is the SynthDef we have been using until now (the cheap piano sampler from SC):
d = Synth(\default) //I haven't found yet where is the source code of this SynthDef :'D
d.free

//Let's create a rather simple instrument of ours:
(
SynthDef(
	\newSine,
	{ arg out, freq, amp, pan, gate = 1;
		var signal, env;

		signal = Mix(SinOsc.ar(freq * [1, 1.01], 0, 0.5)); //Two frequencies are produced with 0.01 deviation factor, then they are mixed producing this little detune or beating.

		env = EnvGen.ar(
			Env.asr(0.01, amp * 0.5, 0.3), //Envelope with attack, sustain and release, because Pbind needs to open and close the gate.
			gate, //Gate needs a 1 by default in order to boot up the envelope right away. Pbind sends a 0 to the gate each time it's done with a synth, then it picks up again the 1 by default in the SynthDef.
			doneAction: 2 //doneAction = 2 is essential to keep each Synth out of the server when it is done.
		);

		Out.ar(out, Pan2.ar(signal * env, pan)) //We apply Pan2, as the output of the Mix is a mono signal.
}).add
)

//Now we connect Pbind with our instrument by specifying the name of the instrument. If we don't specify the value of the arguments, those that are conventional event keys will be assigned to their default values. If any argument is created apart from those that Pbind understands by default, it needs to be assigned a default value in the SynthDef or otherwise always be specified within Pbind:
p = Pbind(\instrument, \newSine).play //Default values.
p.stop

p = Pbind(\instrument, \newSine, \midinote, Pseq([ 72, 67, 68, 75 ], inf)).play //For example, \midinote is going to be placed automatically in the freq argument (and converted to Hz).
p.stop

//Another example using the same instrument:
(
p = Pbind(
	\instrument, \newSine,
	\midinote, Pn(Pshuf([ 40, 42, 43, 45, 46 ] + 24, 2), inf), //Two repetitions of each order.
	\dur, 0.5 * (60/180), //Using 8th-notes considering the 180 quarter-notes per minute. This is another way of skipping the use of other duration keys (this operation is equivalent to using the stretch key).
	//\dur, 0.5 / (180/60) //Equivalent operation.
	\legato, 0.5, //Each event is half the duration of the space between the events (the release of the envelope starts at half of the duration set in \dur).
	\amp, Pwrand([0.1, 0.5], [0.8, 0.2], inf), //There are some sharper attacks.
	\pan, Pseq([ -1, -0.5, 0, 0.5, 1 ], inf)
).play
)
p.stop

//As it can be observed, there is no "dur" argument in the SynthDef. This is because duration keys are understood by Pbind as triggers for the gate of the envelope to be opened and closed.

//I copied in the folder of theory files a file called "SpaceLab", although such a code is included in the SC folder created when installing the program (alongside other examples in a folder called "Pieces"). This code is easy to follow and a great old-school example of using Pbind connected to several instruments. It is a great exercise to analyze the code, even if certain things seem too complex.


//Let's create yet another SynthDef (remember that the only requisites are to include an envelope with sustain time, gate = 1, and doneAction = 2):
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
			freqscale //Freqscale allows us to transpose the freqs of Klank (2 = octave up, 0.5 = octave down, 7/4 = approx. minor 7th, etc., using all overtone ratios or .midiratio).
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
p = Pbind(
	\instrument, \klank,
	\dur, Pwrand([1, 0.5, 0.1], [0.7, 0.2, 0.1], inf) * (60/90), //The duration ratios are based on the 90 bpm applied as a factor at the end.
	\freqscale, Pseq([1, 2/3], inf),
	\amp, Pwrand([0.3, 0.05], [0.2, 0.8], inf),
	\pan, Pxrand([-0.7, -0.3, 0, 0.3, 0.7], inf)
).play
)
p.stop


//RESTS
//Let's introduce a bit the concept of rest in Pbind: the key \rest, or just a backslash "\" in any key related to frequency will be interpreted as a rest:
Pbind(\note, Pseq([0, 2, \rest, 5, 6, \rest, 10, 11, \rest], inf)).play

//Here is our newSine SynthDef again:
(
SynthDef(
	\newSine,
	{ |out, freq, amp, pan, gate = 1|
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

//In this example, there is a random permutation of the Pshuf pattern each 5 repetitions: there are 5 different pitches and 3 rests to be sorted randomly. This will alternate the pitches and rests quite fast, giving a similar impression as in Ligeti's studio of blocked keys:
(
p = Pbind(
	\instrument, \newSine,
	\midinote, Pn(Pshuf([ 64, 66, 67, 69, 70, \, \, \ ], 5)), //Using the single backslashes as shortcut of \rest.
	\amp, 0.1,
	\dur, 0.25 * (60/180), //Here we use 16th-notes (a quarter of a quarter-note, 0.25 from 1), at 180 bpm.
	\legato, 0.25,
	\pan, Pseq([ -1, -0.5, 0, 0.5, 1 ], inf)
).play
)
p.stop

//The rests can be also created using the class Rest() in any key (here in \amp):
(
p = Pbind(
	\note, Pseq([ 0, 2, 4, 5, 6, 7, 10, 12 ], inf), //As Rest is used in \amp, the flow of pitches is maintained here despite the silences.
	\amp, Pseq(
		[
			Pseq([0.1, 0.1, Rest()], 8), //We create the pattern note-note-rest. There are 8 pitches, so the pattern is displaced during 24 iterations (8 series of 3 pulses (note-note-rest)), coming back to its initial phase only after that.
			Pn(0.1, 8) //When the 24-note sequence is completed, the complete series of pitches appears (8 repetitions, because 8 pitches).
		],
		inf),
	\pan, Pseq([Pn(0, 3 * 8), Pseq([-1, 1], 4)], inf), //The sequence of amp values coincides with the pan values: it maintaines a 0 during 3 * 8 iterations, then it alternates between -1 and 1 four times (for the last 8 pitches after the 24-note sequence).
	\dur, 0.1,
	\instrument, \newSine
).play
)
p.stop

//In case the class Rest is used in any of the keys related to the duration (mainly in \dur), we have to specify the duration of the Rest (in units):
(
p = Pbind(
	\note, Pseq([ 0, 2, 4, 5, 6, 7, 10, 12 ], inf), //Just like before, the pitches continue running during the gaps.
	\dur, Pwrand([0.1, Rest(0.3)], [0.8, 0.2], inf),
	\instrument, \newSine
).play
)
p.stop


/////////////////////////////////////////////////////////////////////
//PATTERNS FOR RANDOM DISTRIBUTION

//Let's use an even simpler SynthDef for the upcoming examples:
(
SynthDef(
	\simpleSine,
	{ |out, freq, atk = 0.01, amp, rel = 0.1, pan, gate = 1|
		var signal, env;

		signal = SinOsc.ar(freq);

		env = EnvGen.ar(
			Env.asr(atk, amp * 0.5, rel),
			gate,
			doneAction: 2
		);

		Out.ar(out, Pan2.ar(signal * env, pan))
}).add
)

//Uniform distribution (Pwhite): all values feature the same probability. Arguments are low and high limits, and number of values to be created (it is different from Prand as it chooses values from a range, instead of from a list). If both inputs are integers, all outputs will be integers, but if at least one input is float, all outputs will be floats (just like in rrand):
(
var stream;

stream = Pwhite(0, 100.0, 10).asStream;

15.do({ stream.next.postln })
)

//In the following graph, we can see how values are spread equally everywhere from 0 to 1 (first graph), and how the probability of each value is maintained around the same spot (second graph):
(
a = Pwhite(0.0, 1.0).asStream; //Numbers between 0 and 1 with uniform distribution (as in white noise): also called rectangular distribution.
b = a.nextN(100000); //It creates an array asking "a" for values 100000 times.
b.plot("Values", bounds: Rect(10, 410, 520, 380), discrete: true); //We can give a name to the plot, define the pixels of the rectangle window, and specify discontinuity (true) for the display of the values.
b.histo(1000).plot("Distribution of the values", bounds: Rect(10, 10, 520, 380), discrete: true) //The second graph is a histogram (which shows distribution of numerical data, see Help file of Collection for an explanation of its arguments), which needs to be plotted.
)

//Applied to sound: we have here a Pbind with random uniform distribution of pitches and durations, and which is duplicated up to four times. These are not parallel Pbinds (that is, a expanded Pbind) but four different Pbinds (that is why they feature different durations apart from different pitches):
(
p = { Pbind(
	\midinote, Pwhite(24, 108, inf).trace,
	\dur, Pwhite(1/16, 2.0),
	\amp, 0.05,
	\instrument, \simpleSine
).play } !4
)
p.stop //Because an array of Pbinds is created, can't apply .stop to all of them at the same time (.stop is not understood by the array).
p[0].stop; p[1].stop; p[2].stop; p[3].stop //Instead, .stop needs to be applied to each Pbind within the array.


//Exponential distribution (Pexprand): lower values are more likely to be chosen. Arguments are low and high limits and number of values to be created. All outputs will be floats no matter what inputs the pattern receives (just like exprand). Also the range should not touch nor cross zero:
(
var stream;

stream = Pexprand(1, 100, 10).asStream;

15.do({ stream.next.postln })
)

//Graphical representation, just like before. We can see now how values are accumulated in the lower part of the range (first graph), and how the distribution is highlighted in the first values (second graph):
(
a = Pexprand(0.001, 1.0).asStream; //Avoiding the 0 as lower limit, as exponential distribution cannot reach it.
b = a.nextN(100000);
b.plot("The values", bounds: Rect(10, 410, 520, 380), discrete: true);
b.histo(10000).plot("Distribution of values", bounds: Rect(10, 10, 520, 380), discrete: true)
)

//Applied to sound: using both exponential and uniform distribution, and using the arguments atk and rel to change the segments of the envelope:
(
p = Pbind(
	\freq, Pexprand(60, 5000, inf).round(65).trace, //Pexprand always outputs floats. With round, apart from obtaining all integers, we are keeping the freq values within the overtone series of a fundamental freq of 65 Hz (as it rounds values to the closest multiple of 65). Try out other fundamental frequencies.
	\dur, Pwhite(0.05, 0.5, inf),
	\atk, Pwhite(0.5, 3.0, inf),
	\rel, Pwhite(2.0, 8.0, inf), //Pwhite needs at least on float input to output floats, otherwise it will output integers.
	\amp, Pexprand(0.01, 0.1, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
	\instrument, \simpleSine
).play
)
p.stop

//The random seed: the first line of this code prints an integer on the post window that can be used as random seed ("random number generator seed"), that is to say, when applying that number to thisThread.randSeed instead of generating one, we will obtain the same combination of random values that we did before.
(
thisThread.randSeed = Date.seed.postln; //The random seed is named using the date and time, thereby avoiding any possible repeated seed value.
p = Pbind(
	\freq, Pexprand(60, 5000, inf).round(65).trace, //Pexprand always outputs floats. With round, apart from obtaining all integers, we are keeping the freq values within the overtone series of a fundamental freq of 65 Hz (as it rounds values to the closest multiple of 65). Try out other fundamental frequencies.
	\dur, Pwhite(0.05, 0.5, inf),
	\atk, Pwhite(0.5, 3.0, inf),
	\rel, Pwhite(2.0, 8.0, inf), //Pwhite needs at least on float input to output floats, otherwise it will output integers.
	\amp, Pexprand(0.01, 0.1, inf),
	\pan, Pwhite(-0.8, 0.8, inf),
	\instrument, \simpleSine
).play
)


//Normal or Gaussian distribution (Pgauss): values closer to the "mean" value are more likely to be chosen. The deviation argument refers to the "width" of the Gaussian bell: the higher the deviation, the more probable extreme values will be. It outputs floats as well:
(
var stream;

stream = Pgauss(50, 10, 10).asStream;

15.do({ stream.next.postln })
)

//Graphical representation: now we can see an accumulation of values around the center or "mean" point (1, in the first graph), and the shape of the Gaussian bell (greater distribution of values around the mean, that is, central values are more likely than extreme values (second graph):
(
a = Pgauss(1.0, 0.25).asStream; //Center (mean) = 1, deviation = 0.25 (width of the Gaussian bell).
b = a.nextN(100000);
b.plot("The values", bounds: Rect(10, 410, 520, 380), discrete: true);
b.histo(1000).plot("Distribution of values", bounds: Rect(10, 10, 520, 380), discrete: true)
)

//Applied to sound: USING A PREVIOUS SYNTHDEF (\newSine, use ctrl-F to search for it in the entire code). Because of the duration of the synths, this example has a granular quality to it:
(
p = Pbind(
	\freq, Pgauss(5000, 1250), //The few lower values are really noticeable because they are rare among the flow of values around the mean point.
	\pan, Pgauss(0, 0.3), //The panning is also maintained around the center. The little deviation makes it sound quite organic.
	\dur, 0.01,
	\amp, 0.05,
	\instrument, \newSine
).play
)
p.stop

//Yet another example (coming back to \simpleSine), to show the Guassian distribution applied to durations: a deviation of 0 would bring about a regular pulse, and therefore the higher the deviation, the greater the difference between the pulses. Here using Ptuple to extract three frequencies for each event. Then, each frequency is added a different octave transportation.
(
p = Pbind(
	\midinote, Ptuple({ Pgauss(67, 1) } !3) + [0, 14, 24], //Three frequencies, three different octaves.
	\dur, Pgauss(0.5, 0.1),
	\instrument, \simpleSine //Try out with \newSine as well, interesting result.
).play
)
p.stop


//Brownian motion (Pbrown): its arguments are low and high limits, the step and the number of values to be created. The step represents the maximum deviation from one value to the next (either + or -, that is, upwards or downwards). It outputs floats whenever any of its arguments is a float (except for the length argument). If going beyond the low or high limits, the values fold (are added instead of subtracted and vice-versa):
(
var stream;

stream = Pbrown(0, 10, 1, 10).asStream;

15.do({ stream.next.postln })
)

//Brownian motion model (as seen sin some other theory code):
a = 1 //Initial value.
a = (a + rrand(-1.0, 1.0)).fold(0.0, 10.0) //If going above 10 or below 0, it folds. The inputs of rrand represent the "step" argument, whereas the inputs of fold represent the low and high limits.

//Graph of the tendency applied to 100000 values: observe that there are not many great jumps between random values:
(
a = Pbrown(0.0, 10.0, 0.1, inf).asStream;
a.nextN(100000).plot
)

//Sonic example using the chromatic scale: the movement between pitches seems to be pretty organic:
(
p = Pbind(
	\midinote, Pbrown(60, 96, 1),
	\dur, 0.1,
	\instrument, \simpleSine
).play
)
p.stop


//PSEG: the envelope patter.
//According to the help file: "Pseg defines a function of time as a breakpoint envelope using the same parameters as Env" (that is, defines a series of segments, bringing about an envelope). It's arguments are a list of levels, a list of durations, a list of curves, and the number of repetitions.

//Simple example: creating an envelope of frequencies: the times of Pseg are independent from the duration key. The main difference between Pseg and Env is the use of as many time values as level values, as the pattern is prepared to be looped by default:
(
p = Pbind(
	\instrument, \simpleSine,
	\midinote, Pseg(Pseq([ 60, 67 ], inf), Pseq([ 5, 0.2 ], inf)).trace, //Five beats to go from 60 to 67, and 0.2 to come back to 60. Here, using the linear curve by default.
	\dur, 0.1
).play
)
p.stop

//Creating a "tendency mask": Pseg can be used for this structural resource, which consists of creating parallel envelopes applied as low and high limits of random choices for a parameter. These lines should be simple enough to perceive their trace. Ranges that open and close in specific directions can be a good example for this. It can be very useful when applied to granular synthesis, controlling the position within the buffer, the grain durations, the waiting time between grains, etc.
//Let's use a sawtooth SynthDef for this example:
(
SynthDef(
	\saw,
	{ |freq|
		var signal;

		signal = Saw.ar(freq, 0.2) * EnvGen.ar(Env.sine(0.3, 0.05), doneAction: 2);

		OffsetOut.ar(0, signal !2)

}).add
)

//In the following example, the frequency will be chosen randomly (using uniform distribution) within a range controlled by two Psegs (two envelopes). The two envelopes are synchronized in this example, but they don't have to be:
(
var lineA, lineB;

lineA = Pseg( //Bottom line.
	Pseq([85, 100, 10], inf), //Values (the range of freqs gets narrower up to a unison and then opens up again).
	Pseq([10, 10, 0], inf), //Times (if the last time is 0, then the envelope jumps back to the beginning).
);
lineB = Pseg( //Top line.
	Pseq([90, 100, 70], inf),
	Pseq([10, 10, 0], inf),
);

p = Pbind(
	\instrument, \saw,
	\midinote, Pwhite(lineA, lineB),
	\dur, 0.015
).play
)

p.stop

//My teacher tried to represent this tendency mask graphically, so here is the code for that:
//Same envelopes as before, but as streams:
(
a = Pseg(
	Pseq([85, 100, 10], inf),
	Pseq([10, 10, 0]/20, inf), //Reducing the times so that we can plot right away.
).asStream;
b = Pseg(
	Pseq([90, 100, 70], inf),
	Pseq([10, 10, 0]/20, inf),
).asStream;
)

//Next step is to create empty arrays to be filled up with the Pseg values. A Routine is used to ask each Pseg for its values and add them to the arrays. Remember that the Pseg times are independent from, for instance, the Routine times, hence if we don't plot fast enough, the envelope will be capture at a different moment of its performance.
(
~arrayA = [];
~arrayB = [];
Routine({
	1000.do({ //Using 1000 for more definition, but actually 4 values are enough to depict this envelope.
	~arrayA = ~arrayA.add(a.next);
	~arrayB = ~arrayB.add(b.next);
		(1/1000).wait //Total time is 1.
	})
}).play
)

p = [ ~arrayA, ~arrayB ].plot //With both lines displayed, we can press "s" to overlap them and therefore visualize the shape of the lo and hi limits and their evolutionn overtime (see other commands for the plotter in the Help file).


/////////////////////////////////////////////////////////////////////
//EXTENSIONS FOR THIS CHAPTER
//Other Pbind-related patterns, keys, and examples (beware each SynthDef used in here):


//PKEY: dependable keys.
//When we need the values of a specific key to depend on the values of an earlier stated key, we use Pkey. Pkey copies patterns from an earlier key so that we can apply other methods or operations to those values (outside the pattern, though). Let's take a previous example as starting point and make the amplitude depend on the frequency:
(
p = Pbind(
	\freq, Pexprand(60, 5000, inf).round(65).trace,
	\dur, Pwhite(0.05, 0.5, inf),
	\atk, Pwhite(0.5, 3.0, inf),
	\rel, Pwhite(2.0, 8.0, inf),
	\amp, Pkey(\freq).reciprocal * 50, //Remember x.reciprocal = 1/x: lower freqs will be louder than higher freqs. Seems to work.
	\pan, Pwhite(-0.8, 0.8, inf),
	\instrument, \simpleSine
).play
)
p.stop


//PFUNC: function pattern.
//Pfunc retunrs a stream that returns values from the "nextFunc", which is the first argument, a stream function (the second one is "resetFunc", called when the stream is reset and which received no arguments). The advantage of this pattern is that allows all kind of functions, including control structures (probably its most useful use), within Pbind, so this pattern creates systems between Pbind and Routine. The Pfunc's function is evaluated every time it is asked for a value.
//For a littel example, I'll copy the SynthDef used in the Help file of Pfunc:
(
SynthDef(\help_sinegrain,
	{ arg out = 0, freq = 440, sustain = 0.05, gate = 1, amp = 0.1;
		var env;

		env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), gate, doneAction: Done.freeSelf);
		Out.ar(out, SinOsc.ar(freq, 0, env).dup(2) * amp)

}).add;
)

//Now let's use Pfunc within a simple Pbind:
(
p = Pbind(
	\instrument, \help_sinegrain,
	//\freq, Pseq([1, 2, 3, 4, 5, 6, 7, 8] * 200, inf).trace,
	\freq, Pfunc({ var ot; ot = [1, 2, 3, 4, 5, 6].choose; if (ot.odd, { ot * 200 + 1000 }, { ot * 200 }) }).trace, //The conditional works perfectly.
	\dur, 0.2,
	\sustain, 0.8
).play
)
p.stop

//In the next example, Pfunc uses values from another key (to condition its value according to the other key's values). It seems that Pkey is not a solution for this, but from this blog, https://scsynth.org/t/linking-keys-patterns/1112, I discovered that Pfunc seems to pass an argument called "event", which can point to a key: the key is indicated like this, event[\key], and the argument will then contain the values from that key, which can be used in any way within the Pfunc:
(
p = Pbind(
	\instrument, \help_sinegrain,
	\freq, Pfunc({ var ot; ot = [1, 2, 3, 4, 5, 6].choose; if (ot.odd, { ot * 200 + 1000 }, { ot * 200 }) }).trace,
	//\dur, Pkey(\freq) * 0.001,
	//\dur, Pfunc({ var pitch; pitch = Pkey(\freq); if (pitch > 1200, { 1 }, { 0.2 }) }), //Does not work with Pkey.
	//\dur, Pfunc({ arg event; event[\freq] * 0.001 }), //Using the event argument.
	\dur, Pfunc({ arg event; if (event[\freq] > 1200, { 1 }, { 0.2 }) }), //Now trying with the conditional: works perfectly again.
	\sustain, 0.8
).play
)
p.stop

//For another pattern mid-way between Pbind and Routines, see the Help file of Pspawner and its examples ("Pspawner allows a routine to dynamically start and stop subpatterns").


//PPAR: parallel Pbinds.
//As a point of departure, let's create this other SynthDef:
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

//The objective was to create a gradual displacement of two similar melodic lines (just like in Steve Reich's piano phase, for instance). Because two parallel Pbinds (an expanded Pbind) cannot bear different durations, the first solution was to create two different Pbinds featuring different times (just like when we duplicated the whole Pbind in a previous example, although in that case, we wouldn't be able to apply specific patterns for each but just one in common, perhaps bringing about different randomness).
(
p = Pbind(
	\instrument, \saw2,
	\scale,Scale.minor,
	\degree, Pseq([ 0, 4, 5, 7], inf),
	\octave, 6,
	\amp, 0.1,
	\dur, Pseq([0.5, 0.5, 1, 1], inf),
).play;
q = Pbind(
	\instrument, \saw2,
	\scale,Scale.minor,
	\degree, Pseq([ 0, 4, 5, 7], inf),
	\octave, 6,
	\amp, 0.1,
	\dur, Pseq([Pseq([0.5, 0.5, 1, 1], 1), Pseq([0.5, 0.5, 0.75, 1], 3)], inf), //After certain number of iterations, it synchronizes again.
).play
)
p.stop; q.stop

//Now, for a greater efficiency, we can use Ppar to create parallel patterns. According to the Help file, it "embeds several event streams (Pbinds) so that they form a single output stream with all their events in temporal order" (not much difference in this example, but when creating more complex systems, it might help):
(
Ppar( //Arguments are list (array of Pbinds) and repeats.
	[
		p = Pbind(
			\scale,Scale.minor, //Minor scale
			\degree, Pseq([ 0, 4, 5, 7], inf),
			\octave, 6,
			\amp, 0.2,
			\dur, 0.25,
			\instrument, \saw2
		).play,

		q = Pbind(
			\scale,Scale.minor,
			\degree, Pseq([ 0, 4, 5, 7], inf),
			\octave, 6,
			\amp, 0.2,
			\dur, 0.26,
			\instrument, \saw2
		).play
	]
)
)
p.stop; q.stop


//PMONO: monophonic event stream.
//According to this guide chapter: https://depts.washington.edu/dxscdoc/Help/Tutorials/A-Practical-Guide/PG_03_What_Is_Pbind.html, Pmono is a useful variant of Pbind. "Pbind plays separate notes by default. Sometimes, you might need a pattern to act more like a monophonic synthesizer, where it plays just one Synth node and changes its values with each event. If Pbind normally corresponds to Synth.new or /s_new, Pmono corresponds to aSynth.set or /n_set". That is to say, Pbind creates a new instance of a Synth with each event, which is then normally freed in the Server, whereas Pmono seems to create a single instance of a Synth whose values are modified with each event.
//Compare these patterns from the guide: Pbind produces an attack on every note, while Pmono glides from pitch to pitch.
p = Pbind(\degree, Pwhite(0, 7, inf), \dur, 0.25, \legato, 1).play;
p.stop;
​
p = Pmono(\default, \degree, Pwhite(0, 7, inf), \dur, 0.25).play;
p.stop;

//According to the guide, articulating phrases (or single notes) is possible with Pmono by chaining several Pmono patterns together in a row, or by using PmonoArtic (according to its help file, PmonoArtic "allows events to re-articulate and supports staccato in the middle of a monophonic phrase". And this is how it is done: "If an event specifies a 'sustain' value shorter than the event delta, it means the synth should not sustain all the way through to the next event. In that case, the node will be released according to 'sustain' and the next event will start a new synth").


//PDEF: back to the JITlib.
//Just like Tdef, Pdef allows us to send new parameters to a Pbind at run time. Try changing any parameter in the following code while running (amp, degrees, octave, durations, etc.):
(
f = Pdef(
	\x, Pbind(
		\instrument, \saw,
		\scale,Scale.minor,
		\degree, Pseq([ 0, 4, 5, 7], inf),
		\octave, 6,
		\amp, 1,
		\dur, Pseq([0.5, 0.5, 1, 1] / 4, inf),
	)
).play
)

f.stop
Pdef(\x).stop //Can be also addressed by its name.


//Let's use a library of samples to feed the Pbind (remember to replace the paths with your own):
(
d = Dictionary.new; //Creating a new dictionary and loading the path of each folder of samples assigned to a new key (we can add as many folder as we like, creating different keys for each):
d.add(\folder1 -> PathName("C:/Users/SmallAngel/Desktop/THEORY CODES/ugly_percussion_library/group1").entries.collect({ |sample| Buffer.read(s, sample.fullPath) }));
d.add(\folder2 -> PathName("C:/Users/SmallAngel/Desktop/THEORY CODES/ugly_percussion_library/group2").entries.collect({ |sample| Buffer.read(s, sample.fullPath) }));
)

//Now we can easily play random samples from each key in "d" (beware the original volume of the samples!):
d[\folder1].choose.play
d[\folder2].choose.play

//Let's create a SynthDef to play these samples. Notice that, because we are using short sounds, there is no need for an envelope (doneAction 2 is included in PlayBuf), but be careful when using longer samples:
(
SynthDef(\library, {
	|buf = 0, rate = 1, amp = 0.1|
	var signal;

	signal = PlayBuf.ar(2, buf, BufRateScale.ir(buf) * rate, doneAction: 2); //BufRateScale was used to compensate a possible difference of sampling rate.
	signal = signal * amp;

	Out.ar(0, signal)
}).add
)

Synth(\library, [\buf, d[\folder1].choose.bufnum]) //Just to check it works: choosing a random sample through its bufnum, from folder1, for instance.

//And now we can build the Pbind to play this SynthDef:
(
Pdef(
	\heyhey,
	Pbind(
		\instrument, \library,

		//\dur, 0.25 * (60/120), //Using 16th notes within a tempo of 120 bpm. The duration here does not cut the sample duration though (they will overlap if longer than this value).
		\dur, 1/16, //As an alternative, we can use \dur in combination with \stretch to work with "measures" and use quantization later on. Here, for instance, we have 1/16 of the 4/4 bar, which gives us 16th notes (four notes for each of the four beats).
		\stretch, 60/120 * 4, //Stretch will be multiplied by \dur, so we need the time in seconds corresponding to the whole 4/4 measure, which will be devided by 16 in \dur to obtain the 16th notes of duration. For that, we devide the tempo we want (120 bpm, for instance) by 60, to get beats per second: if we invert this value, 120/60 to 60/120 we get seconds per beat, and we multiply by 4 because there are four beats in a 4/4 time. This last 2 seconds (it would be more efficient to write 2, but I will leave the operation to make it clearer).

		//\buf, Pxrand(d[\folder1] ++ d[\folder2], inf), //Creating an array with all the samples by concatenating both folders (both keys from the dictionary). Pxrand chooses random samples without repeating the same values twice in a row. We could use here Pwrand, Pshuf, Pn combined with Pshuf, or a specific sequence with Pseq, use nested patterns, etc., in order to create more defined yet still random sequences, including also different combinations of the keys within the dictionary. For example:
		\buf, Pseq(
			[
				Pxrand(d[\folder2], 8), //8 random samples from folder 2.
				Pxrand(d[\folder1] ++ d[\folder2], 8) //8 random samples from both folders.
			], inf
		),
		\rate, Pexprand(0.8, 2.0, inf), //The rate can also be randomized.
		\amp, 0.2
	)
).play(quant: 2) //If we want Pdef to wait until next "downbeat" to apply any changes made in Pbind, we can use quantization (scheduling changes according to measure durations). In here, we are using the quant argument of the event stream player (.play) and setting the duration value of a whole measure in 2 seconds. Once the Pdef is running, if we want to execute it again with new values, we can replace .play by .quant_(2). The changes will be apply from the next downbeat onwards. This is especially useful when using two or more Pdefs at the same time if they share durations and stretch values, and they are applied the same quantization. This allows the evaluation of several blocks of code while getting them still synchronized.
)

Pdef(\heyhey).stop //We can stop each Pdef (if having several) separately.

//Now, regarding this syntax: .quant_(2), I looked up the meaning of the underscore in SC and found this: https://doc.sccode.org/Reference/Partial-Application.html. In this case, it just means "set", so the underscore is equal to "= 2".
