//11 - ALGORITHMIC COMPOSITION, CONTROL STRUCTURES, PATTERNS

/////////////////////////////////////////////////////////////////////
//ALGORITHMIC COMPOSITION TOOLS

//The resources that are dealt with in this file will, for instance, contribute to the creation of algorithmic Routines and other systems for algorithmic composition that are much more flexible, versatile, and dynamic. These resources are control structures based on boolean expressions and patterns (other patterns related to distributions will be explained in the theory file 13, in addition to those presented here).


/////////////////////////////////////////////////////////////////////
//BOOLEAN EXPRESSIONS

//Boolean expressions return the literals "true" or "false". Therefore, they are useful for making an operation or process depend on something (such as a "condition"):
//Some of them are:
4 == 5 //Equal to
4 != 5 //Different from
4 > 5 //Higher than
4 <= 5 //Lower or equal to
4.odd //Is an odd number
4.even //Is an even number
x.isNil //Is empty (nil)
0.6.coin //Returns true or false depending on the given probability (from 0 to 1, 0 to 100%)
(2 > 1).and(2.odd) //Both conditions need to be met to return true
(2 > 1).or(2.odd) //At least one of the conditions needs to be met to return true


//Control structures: control structures are normally based on boolean expressions (in order to express conditions, for example). Control structures are tools that determine the direction or path chosen based on given parameters and conditions. Some of these control structures are explained here: https://doc.sccode.org/Reference/Control-Structures.html. Let us introduce some of them:

//"if": if the boolean expression returns true, the first function is executed, and if not, the second function is executed. We can come across up to three different syntaxes:

if (1 > 2, { "true".postln }, { "false".postln }) //The one I normally use.

(0.7.coin).if({ "true".postln }, { "false".postln })

if(3.odd) { "true".postln } { "false".postln } //The one recommended by the style guide.

//Imaginary examples of the use of "if", for example, if applied within a Routine to condition a process (using .do and the iteration argument "i"):
if ((i % 3) == 0, { function1 }, { function2 }) //Something happens every three iterations.
if (i.asInteger.even, { function1 }, { function2 }) //Alternating between two options (could also use .odd, or the module of 2).
if (0.5.coin.and(i != 0), { function1 }, { function2 }) //Avoiding applying the condition to the first iteration.

//"while": it only executes the second function if the first function returns true (and re-executes again as far as it returns true, so it is a conditional loop):
(
while(
    { var value;

        value = (1..10).choose.postln;
        (value == 2).or(value == 5);

    },
    { "success".postln }
)
)

//"switch": given an initial operation, and some pairs of result-function, it executes a different function according to the result of the operation each time. There is an "else case" at the end of the pairs:
(
var value;

value = rrand(0, 20);

switch
(value % 4)
{ 0 } { "zero" }
{ 1 } { "one" }
{ 2 } { "two" }
{ "error" } //When the result is 3, for instance.
)

//"case": similar to switch, but not based on a common initial operation or condition: each pair features its own input condition and output function. I think that, if two of the cases are met with the same value, the first one in order from top to bottom is the one returned:
(
var value;

value = rrand(1, 10);

case
{ value == 2 } { "two" }
{ (value % 3) == 0 } { "module" }
{ value.odd } { "odd" }
{ value >= 7 } { "high" }
{ "error" }
)

//"select": it creates a collection consisting of all items from the receiver for which the function returns true. The function passes two arguments, the item and the index:
[1, 2, 3, 4].select({ |item, i| item.even });

//"for": receives an integer series ( startValue, endValue, function ), stepping by one each time. The function is evaluated each iteration of the series and it passes the current integer from the series as an argument. Here, it simply prints values 3 to 7:
for (3, 7, { arg i; i.postln });

//"forBy": same as "for", but it includes as third argument a variable step size ( startValue, endValue, stepValue, function ). Here, again, it simply prints values 0 to 8, but stepping by 2 each iteration:
forBy (0, 8, 2, { arg i; i.postln });


//NOTICE! We are using booleans on the client side. Booleans on the server side (for example, used within a SynthDef) work in a very different way: booleans in SynthDef are either 1 or 0 (as floats), instead of true or false. More information on this issue here: https://doc.sccode.org/Guides/UserFAQ.html (section about "if" statements in a SynthDef), and in this video: https://www.youtube.com/watch?v=ZapNpkN7q7I (where the object Select studied in the theory file 6 is explained alongside others such as SelectX).


//##############################################################
//CASE STUDY OF CONTROL STRUCTURES:

//Practical example of while (e.g. systematic random lengthening the structure of a piece):
(
var structure, newStructure, position;

structure = ["a", "b", "c", "b", "a", "d", "c", "e", "c", "d"];
position = -1; //Initial value of -1, so that there is a possibility for only "a" to be chosen as first iteration (otherwise, "a" would never appear alone as first iteration because of the seconf function: position + rrand(1, 3)).

while( //"while" only executes the second function if the first one returns true. It might be executed many times as far as the first function continues returning true (here, as many times as "position" receives a value lower than "structure.lastIndex").

	{ position < structure.lastIndex }, //"lastIndex" is used here so that the function is only evaluated when the position value is lower than the last index of the collection.

	{  position = (position + rrand(1, 3)).min(structure.lastIndex); //A number between 1 and 3 is chosen randomly: this is equal to the number of indexes that will be added in order in each iteration until the series of "structure" is completed. The use of ".min(structure.lastIndex)" is redundant as the filter for the lastIndex is already applied in the conditioning function. "position" keeps reassigning its value in each iteration, thus it continues where is stopeed during the former iteration.

		structure[..position].postln; //The new "position" value becomes the limit for the array up to which the collection of the "structure" is read, in order to print the different results of the growing structure up to the completed series (all at once thanks to "while").
})
)
//##############################################################


/////////////////////////////////////////////////////////////////////
//ALGORITHMIC COMPOSITION (WITH ROUTINE): BORING VS FUZZY SYSTEMS

//Let's start by simply using the following SynthDef to work will all the following Routines. This time, we will focus on a more complex work on the client side:
(
SynthDef(
	\sine,
	{ |freq = 262, amp = 0.1, durEnv = 1, pan = 0|
		var signal, env;

		signal = SinOsc.ar(freq, 0, amp);
		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);
		signal = Pan2.ar(signal * env, pan);

		Out.ar(0, signal)

}).add
)


//One of my teachers was used to teach us the "scale of interest" of algorithmic composition: BORING (maximum number of rules/determinism) ----> Maximum interest ----> FUZZY (minimum number of rules/randomness). Maximum interest seems to be somewhere midway the "boring" and the "fuzzy", but this is not an absolute rule and it depends on the composer, context and listener how the outcome of an algorithmic system is perceived. Let's create some simple algorithmic systems from "boring" to "fuzzy" using the former SynthDef:

//Let's move first from "fuzzy" to "boring":
//Minimum number of rules: random pitch in Hz and random duration from 32nd-note to half-note (taking the second as unit for the quarter-note):
(
r = Routine({
	inf.do({
		Synth(
			\sine,
			[\freq, exprand(27.5, 4186)] //In a piano, from A0 to C8, whole register.
		);
		rrand(1/8, 2).wait //Uniform distribution of the note values, from 32nd-note to half-note (and everything in between).
	})
}).play
)
r.stop

//Increasing the control: exponential distribution for the duration choice = Higher probability for short values:
(
r = Routine({
	inf.do({
		Synth(
			\sine,
			[\freq, exprand(27.5, 4186)]
		);
		exprand(1/16, 2).wait //Expanding the duration range up to 64th-notes.
	})
}).play
)
r.stop

//Unifying the durations using just 32nd-notes so rhythmic complexity is removed:
(
r = Routine({
	inf.do({
		Synth(
			\sine,
			[\freq, exprand(27.5, 4186)]
		);
		(1/8).wait
	})
}).play
)
r.stop

//Simplifying the pitch selection: the freqs are transformed into midi and rounded to integers (as exprand always returns floats) in order to use equal temperament. The range is also reduced to one octave only:
(
r = Routine({
	inf.do({
		Synth(
			\sine,
			[\freq, exprand(4186/2, 4186).cpsmidi.round(1).midicps] //.round(2) would create a whole tone scale.
		);
		exprand(1/8, 1).wait //Varying the durations a bit, using the exponential distribution again to prioritize the short durations.
	})
}).play
)
r.stop


//Let's move now from "boring" to "fuzzy":
//Let's also add some more complexity in the Routine: using two routines interacting with each other. The first one, an infinite loop, works thanks to a .next asking for pitches from the second loop in each iteration. We obtain one pitch at a time because of .yield. The second routine asks for pitches and runs automatically thanks to .play. The durations (wait time) are now equal:
(
var pitches;

pitches = Routine({
	inf.do({ //This very repetitive structure will be replaced soon by patterns, which will be studied later on. It is nonetheless interesting to understand how it works internally:
		60.yield; //C4
		63.yield; //E4
		67.yield; //G4
		70.yield; //Bb4
		72.yield; //C5
	})
});

r = Routine({
	inf.do({
		Synth(\sine,
			[\freq, pitches.next.postln.midicps] //The freqs are in midi numbers. If postln is placed after .midicps, the freqs would be posted in Hz.
		);
		(1/8).wait
	})
}).play
)
r.stop

//Adding some complexity to the system: an average of 1 out of 5 times, the routine will play the arpeggio transposed a tritone up (although we will always obtain the original arpeggio as first option, because it appears before the .coin option). If the coin returns false, the loop will come back to the original arpeggio:
(
var pitches;

pitches = Routine({
	inf.do({
		60.yield; //C4
		63.yield; //E4
		67.yield; //G4
		70.yield; //Bb4
		72.yield;//C5

		if ((1/5).coin.postln, { //Second arpeggio.
			66.yield; //F#4
			69.yield; //A4
			73.yield; //C#5
			76.yield; //E5
			78.yield;//F#5

			[41, 42, 43].choose.yield; //Extra step: if the second arpeggio is chosen, there is a selection of one low pitch at the end of it, (F2, F#2 or G2). Hence, sometime groups of 6 notes instead of 5 will be inserted to vary the periodicity.
		});
	})
});

r = Routine({
	inf.do({
		Synth(\sine,
			[\freq, pitches.next.postln.midicps]
		);
		(1/8).wait
	})
}).play
)
r.stop

//Opening the choice a bit more: the variable "transposition" chooses a number between 0 (no transposition) and 6 (tritone transposition). After that, there is a new loop: a G7 chord from which 0, 1 or 2 pitches are selected (pitches are chosen from the chord thanks to .do, and it does it from 0 to 2 times), and the variable "transposition" is added. If transposition = 6, the chord will be C#7:
(
var pitches;

pitches = Routine({
	var transposition;

	inf.do({
		60.yield;
		63.yield;
		67.yield;
		70.yield;
		72.yield;

		if ((1/5).coin.postln, {
			66.yield;
			69.yield;
			73.yield;
			76.yield;
			78.yield;

			[41, 42, 43].choose.yield;
		});

		transposition = [0, 6].choose;

		rrand(0, 2).do({ ([91, 94, 98, 101, 103].choose //Try out rrand(0, 4) so more notes from the chord can be chosen each time.
			+
			transposition
		).yield
		})
	})
});

r = Routine({
	inf.do({
		Synth(\sine,
			[\freq, pitches.next.postln.midicps]
		);
		(1/8).wait
	})
}).play
)
r.stop

//Now we'll add new algorithmic processes to the second routine. Looking at the wait time, durations of 32nd note OR durations between 8th-notes and half-notes are chosen. Wchoose prioritizes the short values:
(
var pitches;

pitches = Routine({
	var transposition;

	inf.do({
		60.yield;
		63.yield;
		67.yield;
		70.yield;
		72.yield;

		if ((1/5).coin.postln, {
			66.yield;
			69.yield;
			73.yield;
			76.yield;
			78.yield;

			[41, 42, 43].choose.yield;
		});

		transposition = [0, 6].choose;

		rrand(0, 2).do({ ([91, 94, 98, 101, 103].choose
			+
			transposition
		).yield
		})
	})
});

r = Routine({
	inf.do({
		Synth(\sine,
			[\freq, pitches.next.postln.midicps]
		);
		[1/8, exprand(0.5, 2)].wchoose([8/9, 1/9]).wait //Try out other ratios such as 4/5, 1/5.

	})
}).play
)
r.stop

//Let's create a condition so only the higher pitches (above MIDI 90) are going to have longer durations. We need a new variables for this: "thisPitch", so that we can connect such a condition to the frequency argument later on; and "dur" so that we can condition the duration for the waiting time:
(
var pitches;

pitches = Routine({
	var transposicion;

	inf.do({
		60.yield;
		63.yield;
		67.yield;
		70.yield;
		72.yield;

		if ((1/5).coin.postln, {
			66.yield;
			69.yield;
			73.yield;
			76.yield;
			78.yield;

			[41, 42, 43].choose.yield;
		});

		transposicion = [0, 6].choose;

		rrand(0, 2).do({ ([91, 94, 98, 101, 103].choose
			+
			transposicion
		).yield
		})
	})
});

r = Routine({
	var dur, thisPitch;

	inf.do({
		thisPitch = pitches.next; //When using values involving randomness coming from .next in several places, it is best to assign .next to a variable so that it returns the same values wherever it is asked to do so.
		if (thisPitch > 90, { dur = exprand(0.5, 2) }, { dur = 1/8 });

		Synth(\sine,
			[\freq, thisPitch.postln.midicps]
		);
		dur.wait
	})
}).play
)
r.stop

//We add now another condition to the conditional using .and: the pitch has to be higher than MIDI 90 AND overcome the probability of 1/6.coin:
(
var pitches;

pitches = Routine({
	var transposition;

	inf.do({
		60.yield;
		63.yield;
		67.yield;
		70.yield;
		72.yield;

		if ((1/5).coin.postln, {
			66.yield;
			69.yield;
			73.yield;
			76.yield;
			78.yield;

			[41, 42, 43].choose.yield;
		});

		transposition = [0, 6].choose;

		rrand(0, 2).do({ ([91, 94, 98, 101, 103].choose
			+
			transposition
		).yield
		})
	})
});

r = Routine({
	var dur, thisPitch;

	inf.do({
		thisPitch = pitches.next;
		if ((thisPitch > 90).and((1/6).coin), { dur = exprand(0.5, 2) }, { dur = 1/8 });

		Synth(\sine,
			[\freq, thisPitch.postln.midicps]
		);
		dur.wait
	})
}).play
)
r.stop

//Lastly, now every 24 notes, something is going to happen, using the module %24 connected to the index argument of the second routine's loop. We need a second "transposition" variable. Every 24 notes, a  random number from 0 to 11 is going to be chosen. Then, the new transposition is going to be added to the pitches obtained from the first routine (rememeber that it can be 0 = no transposition):
(
var pitches;

pitches = Routine({
	var transposition1;

	inf.do({
		60.yield;
		63.yield;
		67.yield;
		70.yield;
		72.yield;

		if ((1/5).coin.postln, {
			66.yield;
			69.yield;
			73.yield;
			76.yield;
			78.yield;

			[41, 42, 43].choose.yield;
		});

		transposition1 = [0, 6].choose;

		rrand(0, 2).do({ ([91, 94, 98, 101, 103].choose
			+
			transposition1
		).yield
		})
	})
});

r = Routine({
	var dur, thisPitch, transposition2 = 0;

	inf.do({ | i |

		if (i % 24 == 0, {
			"modulation change".postln;
			transposition2 = rrand(0, 11)
		});

		thisPitch = pitches.next + transposition2;
		if ((thisPitch > 90).and((1/6).coin), { dur = exprand(0.5, 2) }, { dur = 1/8 });

		Synth(\sine,
			[\freq, thisPitch.postln.midicps]
		);
		dur.wait
	})
}).play
)
r.stop


//Continue experimenting with different levels of randomness and different systems to achieve it :)


/////////////////////////////////////////////////////////////////////
//PATTERNS

//Let's copy the previous SynthDef once more to use it for the rest of the examples:
(
SynthDef(
	\sine,
	{ |freq = 262, amp = 0.1, durEnv = 1, pan = 0|
		var signal, env;

		signal = SinOsc.ar(freq, 0, amp);
		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);
		signal = Pan2.ar(signal * env, pan);

		Out.ar(0, signal)

}).add
)


//Streams
//A stream is the "lazy" version of an envelope: it represents a sequence of values that are obtained when it is asked to output them. Just like we studied when using Routines (which work as streams), its values can be asked using the method .next, and it can be reseted by using the method .reset. Objects that are not streams by default can be turned into a stream by sending the message .asStream. We will use the methods .asStream and .next when working with patterns, but let's see first an example of this:

//The following envelope is turned into a stream. There is a time of 3 seconds between each value, but values will be only obtained when asking for them using .next (the faster we ask for values successively, the more values "in between" we get, and the more defined is the envelope):

a = Env([0, 1, 2.99, 1, 0], 3).asStream

a.next //Values from 0 to 0
a.reset


//Patterns
//Patterns are one of the most used and powerful tools in SuperCollider. Here is a very nice guide on how to use them: https://doc.sccode.org/Tutorials/A-Practical-Guide/PG_01_Introduction.html, and this one too: https://doc.sccode.org/Tutorials/Streams-Patterns-Events1.html.
//Patterns are higher-level representations of certain calculations, that is to say, they perform very specific small tasks. It might be difficult to find the specific pattern needed for a task, but when we do so, it eases the process quite a bit. Patterns are like blueprints: streams (sequences of data) can be made from patterns, executing their instructions and outputing the data if asked to do so. This data is often numbers, but patterns can generate any kind of object. Streams are made from patterns by sending the method .asStream to the pattern. Values are output when sending the method .next to the stream made from the pattern, for instance, in the context of a Routine. There are over 120 patterns in SC, so we will mention here just some of the most common ones, but remember, the harder part about patterns is finding the one that perfectly suits your needs, so keep exploring beyond this narrow list!

//PSEQ: reads an array of values as many times as indicated in "repeats", and from the index of the array specified in "offset".
//Example with numbers:
(
var stream;

stream = Pseq([0, 1, 2, 3, 4], 1).asStream; //Try out 2 in the number of repeats.

15.do({ stream.next.postln }) //The rest of the iterations will be filled up with "nil".
)

//Example with sound (simplifying the arpeggio Routine from before: now the pattern stream replaces the first Routine of the before-mentioned code):
(
var pitches;

pitches = Pseq([60, 63, 67, 70, 72], inf).asStream;

r = Routine({
	inf.do({

		Synth(\sine, [\freq, pitches.next.postln.midicps]);
		(1/8).wait
	})
}).play
)
r.stop

//Operations with patterns: example with sound: they work as the operations between arrays of different size (the smaller array wraps):
(
var pitches, durations;

pitches = (
	Pseq([60, 63, 67, 70, 72], inf)
	+
	Pseq([0, 0, 12], inf) //The pitch is going to be raised one octave every three values.
).asStream;

durations = Pseq([0.25, 0.5, 0.25], inf).asStream; //Pseq also applied to durations.

r = Routine({
	inf.do({

		Synth(\sine, [\freq, pitches.next.postln.midicps]);
		durations.next.wait
	})
}).play
)
r.stop

//Embedded (nested) patterns: example with sound (the method .asStream is only applied to the outer pattern):
(
var pitches, durations;

pitches = (
	Pseq([ Pseq([60, 63], 3), 67, 70, Pseq([73, 72], 5)], inf) //Two Pseq are used to shorten an array featuring repetitions. This would be the array without inner patterns: [60, 63, 60, 63, 60, 63, 67, 70, 73, 72, 73, 72, 73, 72, 73, 72, 73, 72]
	+
	Pseq([0, 0, 12], inf)
).asStream;

durations = (1/8); //Stable durations now so we can focus on the pattern of pitches.

r = Routine({
	inf.do({

		Synth(\sine, [\freq, pitches.next.postln.midicps]);
		durations.next.wait
	})
}).play
)
r.stop

//PRAND: returns a number of random values from a collection according to "repeats".
//Example with numbers:
(
var stream;

stream = Prand([0, 1, 2, 3, 4], 5).asStream;

15.do({ stream.next.postln })
)

//Example with sound:
(
var pitches, durations;

pitches =  Pseq( //Nested pattern (alternation between the two Prand):
	[
		Prand((72..77), 10),
		Prand((72..77) + 12, { rrand(1, 3) }) //Random number of repeats (rrand needs the curly brackets to be refreshed each time).
	],
	inf).asStream;

durations = Prand([0.1, Pseq(Array.geom(8, 0.1, 1.5).mirror)], inf).asStream; //Random duration between 0.1 and a Pseq with a mirrored Array.geom (deccel-accel).

r = Routine({
	inf.do({

		Synth(\sine, [\freq, pitches.next.postln.midicps]);
		durations.next.wait
	})
}).play
)
r.stop

//There is also Pxrand, which is a Prand that never repeats the same value twice in a row:
(
var stream;

stream = Pxrand([0, 1, 2, 3, 4], 15).asStream;

15.do({ stream.next.postln })
)

//PWRAND: similar to Prand, but including a list of weights (a list of probabilities which should sum up to 1.0, or alternatively, use the method .normalizeSum):
//Example with numbers:
(
var stream;

stream = Pwrand([0, 1, 2], [0.5, 0.375, 0.125], 15).asStream;

15.do({ stream.next.postln })
)

//Example with sound:
(
var pitches, durations;

pitches = Pwrand( //A list of four possible arpeggios (of dominant seventh, separated by minor thirds):
	[
		Pseq(60 + [0, 4, 7, 10], 1),
		Pseq(63 + [0, 4, 7, 10], 1),
		Pseq(66 + [0, 4, 7, 10], 1),
		Pseq(69 + [0, 4, 7, 10], 1),
	],
	[1, 2, 3, 4].normalizeSum, //Probability for each arpeggio.
	inf
).asStream;

durations = 1/8;

r = Routine({
	inf.do({

		Synth(\sine, [\freq, pitches.next.postln.midicps]);
		durations.wait
	})
}).play
)
r.stop

//PSHUF: scrambles randomly the elements of a list and read the list as many times as indicated in "repeats":
//Example with numbers:
(
var stream;

stream = Pshuf([0, 1, 2, 3, 4, 5], 2).asStream; //The random order remains the same in both repetitions of the list.

15.do({ stream.next.postln })
)

//Example with sound:
(
var pitches, durations;

pitches =  Pshuf([60, 62, 64, 65, 67, 69, 71], inf).asStream; //Fixed order once the list is scrambled.

durations = 1/8;

r = Routine({
	inf.do({

		Synth(\sine, [\freq, pitches.next.postln.midicps]);
		durations.wait
	})
}).play
)
r.stop

//Back to the arpeggio code, if replacing the Pseq by Pshuf, so that pitches in each arpeggio appear in different orders, it seems that this order is not kept, but refreshed by the Pwrand every time it chooses the same arpeggio:
(
var pitches, durations;

pitches = Pwrand(
	[
		Pshuf(60 + [0, 4, 7, 10], 1),
		Pshuf(63 + [0, 4, 7, 10], 1),
		Pshuf(66 + [0, 4, 7, 10], 1),
		Pshuf(69 + [0, 4, 7, 10], 1),
	],
	[1, 2, 3, 4].normalizeSum,
	inf
).asStream;

durations = 1/8;

r = Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.wait
	})
}).play
)
r.stop

//PN: Pn is another option to, for instance, refresh Pshuf's randomness. Pn simply runs a pattern as many times as indicated in "repeats":
//Example with numbers:
(
var stream;

stream = Pn(Pseq([ 0, 1, 2, 4, 5 ], 1), 2).asStream; //Simply repeating twice the list of Pseq, which according to its arguments, only reads the list once.

15.do({ stream.next.postln })
)

//Example with sound:
(
var pitches, durations;

pitches = Pn(Pshuf(Array.series(7, 72, 0.5), { rrand(1, 4).postln }), inf).asStream; //The order chosen by Pshuf is refreshed after 1 to 4 repetitions (being this number randomly chosen). The pitches are a quarter-tone appart (0.5 MIDI).

durations = 1/8;

r = Routine({
	inf.do({

		Synth(\sine, [\freq, pitches.next.postln.midicps]);
		durations.wait
	})
}).play
)
r.stop

//PLAZY: runs a function that returns (as its last line) another pattern. That means Plazy allows us to "customize" the pattern it returns. It is usually used in combination with Pn, so that the function can be executed as many times as needed and its possible randomness is refreshed, returning different results:
//Example with numbers:
(
var stream;

stream = Pn(
    Plazy({
        var size;

        size = rrand(1, 12);

		Pseq(Array.series(size, 0, 1)) //The size of the array in Pseq is randomized within Plazy's function.
    }),
    inf
).asStream;

50.do({ stream.next.postln })
)

//Example with sound:
(
var durations, thisDur, newArray, pan;

durations = Pn( //Pattern for the duration:
    Plazy({
        newArray = Array.geom(
            rrand(1, 29), //Random size.
            0.01,
            rrand(1.0, 1.15) //Random grow. Other ranges to try: 1.2 - 1.25.
        );

		Pseq(newArray.mirror) //The randomized geometric series is mirrored (accel-decel).
    }),
    inf
).asStream;

pan = Pseq([-1, 1], inf).asStream; //The pattern for panning alternates between -1 and 1.

r = Routine({
    inf.do({
        thisDur = durations.next; //As we will use this value in several places, we need to put it into a variable. Otherwise, we would create different instances of a pattern that involves randomness, and thus we would obtain different values from each instance.

        Synth(
            \sine,
            [
                \freq, 4000,
                \durEnv, thisDur,
				\pan, (pan.next * (thisDur/newArray.last)).postln, //The position of the panner depends on the duration: (current duration value / last value of the current array of durations) --> The longer the duration, the closer the division is equal to 1, and the shorter the duration, the closer the division is to 0. Then, multiplied by -1 or 1 from the pan, the longer the duration, the more extreme the position of the panner, and the shorter the duration, the closer to the center the position is (and, thanks to the Pseq in "pan", the position will always alternate between left and right).
                \amp, 0.1
            ]
        );
        (thisDur * 2).wait
    })
}).play
)
r.stop

//One more example: choosing between two patterns in the last line of the function of Plazy. The chosen pattern is printed in the postwindow:
(
var midinote;

midinote = Pn(
	Plazy({
		var array;

		//Choose one option for the array of pitches and comment the other:
		//array = ({ rrand(60, 84) } !3); //Three random pitches between MIDI 60 and 84.
		array = ({ [0, 2, 4, 5, 7, 9, 11].choose + [60, 72].choose } !3); //Three random pitches from the C major scale chosen randomly and placed randomly at the 4th or 5th octave (also in MIDI).
		//array = ({ Scale.major.ratios.choose * [60, 72].choose.midicps } !3); //Another option to simplify the major scale. THO we need to remove .midicps from the Synth's freq argument!

		[ Pseq(array, 10), Pxrand(array, 30) ].wchoose([0.7, 0.3]).postln //Then, there is a random choice with probability between a Pseq with 10 repetitions of the three-note array or a Pxrand with 30 random notes out of those three as well. The choice will be made every time one of the patterns is played through, that is, every 30 values.

	})
).asStream;

r = Routine({
	inf.do({
		Synth(
			\sine,
			[
				\freq, midinote.next.postln.midicps, //This time, the Plazy is applied to the frequencies.
				\durEnv, 0.15 //Fixed duration, equal to the fixed waiting time below.
			]
		);
		0.12.wait //Fixed duration.
	})
}).play
)
r.stop


Scale.major.ratios * 60
//PSWITCH and PSWITCH1: Pswitch receives a list of values or patterns (or both) and a "which" argument, which refers to the index of the elements of that list. Pswitch1 is different from Pswitch: if Pswitch receives a pattern, the entire output of the pattern is returned when asking for its index, whereas in Pswitch1, only one element of the pattern's output is returned at a time:
(
a = Pswitch1([
	100,
	Pseq([74, 76, 77, 79, 80, 90, 75, 73, 72, 70, 68, 67, 65, 66, 64, 65, 63, 61, 60], inf)
],

//Using a Pseq as "which" argument in Pswitch1: the output list should be [0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1...] and so forth (that is, increasing the number of 1 in between each 0):
Pseq([0, Pn(1, Pseries(1).asStream)], inf) //Exception for applying .asStream only to the outer pattern in nested patterns (only way it works, and I still don't know why :D). Anyway, there is a Pseries in here (start, step, length), and there is also Pgeom that can be used as geometric series (start, grow, length).
).asStream
)

a.next

//PLACE: Place takes one value from each item in the main array in succession (the smaller arrays wraps):
l = Place([0, [1, 2], [3, 4, 5]], inf).asStream
l.next

//PPATLACE: Ppatlace takes one value from each subpattern in succession:
(
t = Ppatlace(
	[
		Pseries(0, 1, inf),  //start, step, size (there is also Pgeom, for the creation of a geometric series).
		Pseries(2, 1, inf)
	], inf
).asStream
)

t.next


//##############################################################
//ADVANCED EXAMPLES:

//Alternative for the earlier example of Prand: replacing the function needed for rrand to refresh by another pattern (Plazy):
(
var pitches, durations;

pitches = Pn(
	Plazy({
		var pAmnt, pVals, pArray;

		pAmnt = Prand([1, 2, 5], inf).asStream; //Random number of chosen values among 1, 2 or 5, for instance.
		pVals = Prand((60..71), inf).asStream; //Random values for the midi numbers between 60 and 71. Remember, this is equivalent of: Pn(Prand((60..71), 1)).asStream;
		pArray = Array.fill(pAmnt.next, {pVals.next}) ++ [ 96, 97, 98, 99, 100]; //The number of values is applied as a size of Array.fill, containing the midi values in its function (then, a fixed chromatic scale in a higher register is added).

		Pseq(pArray, 1); //The Array.fill is used as the list of a Pseq, output of the Plazy.
	}),
	inf).asStream;

durations = 1/8;

r = Routine({
	inf.do({
		Synth(\sine, [
			\amp, 0.5,
			\freq, pitches.next.postln.midicps
		]);
		durations.next.wait
	})
}).play
)
r.stop

//Example of a Routine that changes the duration factor each certain number of iterations, maintaining the new value until the new change. The Routine plays the Theme of the Goldberg variations by Bach, choosing a random factor multiplied by all durations of the melody. Thus, every time the entire melody is played, a different speed is chosen for it:
(
var pitches, durations;

pitches = Pseq([ 7, 7, 9, 7, 9, 11, 9, 7, 6, 4, 2 ] + 72, inf).asStream; //Pitches for Bach's melody.

durations = Pseq([ 1, 1, 1/8, 1/8, 1/2, 1/4, 1/2, 1/4, 1/4, 1/2, 1.5 ], inf).asStream; //Ratios (duration of each note of the melody) to be multiplied by the factor of speed.

r = Routine({ var thisDur, factor;

	inf.do({ arg i;

		if (i % 11 == 0, {factor = rrand(0.5, 2.5)}); //The conditional controls the operation which will affect the value that we need to change each certain time. The operation exists into a variable, whose value is newly reassigned only when the conditional returns true. It is important not to use this variable before the conditional within the loop because it would reassign its value again with every new iteration.

		thisDur = durations.next * factor; //The value of the variable "factor" is the same during 11 iterations, which is the number of notes in the melody, thanks to the use of the module 11 in the conditional.

		//The resultant value (of thisDur) is applied both to the waiting time and to the release time of the percussive envelope, so that this duration is balance according to the speed of the melody (when the pace is faster, the release times are shorter, and vice-versa):
		Synth(\sine,
			[
				\freq, pitches.next.postln.midicps, //Both the pitch in MIDI and the duration are being printed just for testing.
				\durEnv, thisDur
			]
		);
		thisDur.postln.wait
	})

}).play
)
r.stop

//##############################################################
