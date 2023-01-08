//11 - ALGORITHMIC COMPOSITION, PATTERNS (other patterns related to distributions are explained in the theory file 13)
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//BOOLEAN EXPRESSIONS
//They give back the literals "true" or "false" as a result. Some boolean expressions are: == (equal to), != (not equal to), <= (higher or equal to), .odd (odd number), .even (even number), .isNil (it's empty, for example, a variable or an array), > (lower than), .coin (sent to a number between 0.0 and 1.0 = probability between 0-100% of obtaining true, and false in consequence - Notice that 0.5.coin means equal probability for both options, but that is not a guarantee for obtaining the same number of each result, as it is just probability).

//IF METHOD
//The method .if conditions the evaluation of a function. There are different possibilities for its syntax:

if (1 > 2, {"true".postln}, {"false".postln}) //This is the one I normally use: if (boolean expression, {function if true}, {function if false}).

(0.7.coin).if({"true".postln}, {"false".postln}) //This other syntax resembles that of other methods such as .do: (boolean expression).if({function if true}, {function if false}).

if(3.odd) {"true".postln} {"false".postln}; //This is supposed to be the new recommended way: if(boolean expression) {function if true} {function if false};

//.and / .or --> For comparing two or more boolean expressions:

(2 > 1).and(2.odd) //Both expressions have to be true in order to obtain true with .and.

(2 > 1).or(2.odd) //Only one of the expressions has to be true in order to obtain true with .or.

//In order to make things happen every given number of times (for example, one time out of three), we can use the module:

(21 % 3) == 0) //The number to which the module is applied could be, for instance, the changing number of the iterations of a routine. The module 3 will only give back "true" for the numbers that are multiple of 3.

((21 % 3) == 0).and((21 % 7) == 0) //Using both the multiples of 3 and 7 (the receiver of the module could be, once again, replaced by a variable value).

//Sometimes, in order to alternate between two options, we could think about several strategies using "if":
if (i.asInt.even, {"true".postln}, {"false".postln}) //Using .even or .odd in combination with the argument index if used within a routine is a good option, but the argument index is considered a float, bringing about errors. Using the argument .asInt (.asInteger) will solve that problem.
if ((i % 2) == 0, {"true".postln}, {"false".postln})//Though an even better option is to use the module 2, keeping the numbers between 0 and 1.

//In case of using "if" within a routine and wanting to avoid applying an operation to the very first iteration, you can add to your conditional ".and(i != 0)" using the method "i" from .do:
if (0.5.coin.and(i != 0), {"true".postln}, {"false".postln})

//////////////////////////////////////////////////////////////////
//OTHER CONTROL STRUCTURES (advanced, apart from "if"):

//WHILE -> syntax and example:
while ( testFunc, bodyFunc );

(
var structure, newStructure, position;

structure = [ "a", "b", "c", "b", "a", "d", "c", "e", "c", "d" ];
position = -1; //Initial value of -1, so there is a possibility for choosing just "a" during the first iteration (otherwise, it would always start further within the array because of position + rrand (1, 3) applied later on).

while( //"while": it only executes the second function if the first one is true. It is going to be executed as many times as the first function is evaluated (here, as many times as "position" receives a value, whenever it is lower than "structure.lastIndex").

	{ position < structure.lastIndex }, //"lastIndex" is used here ( = last index of the collection), so the function is only evaluated when the position value is lower than the last index of the collection.

	{  position = (position + rrand(1, 3)).min(structure.lastIndex); //A number between 1 and 3 is chosen randomly = this is equal to the number of indexes that will be added in order in each iteration until the series of structure is completed. The use of ".min(structure.lastIndex) is redundant (I think), as the filter for the lastIndex is already applied in the previous function. "position" keeps reassigning its value in each iteration, thus it continues where is stopeed during the former iteration.

		structure[..position].postln; //The new "position" value becomes the limit for the array up to which the collection of the structure is read, in order to print the different results of the growing structure up to the completed series (all at once thanks to "while").
})
)

//FOR -> syntax and example:
for ( startValue, endValue, function )

for (3, 7, { arg i; i.postln }); //Prints values 3 through 7, which means that the function is evaluated between those values.

//FORBY -> syntax and example:
forBy ( startValue, endValue, stepValue, function )

forBy (0, 8, 2, { arg i; i.postln }); //Prints values 0 through 8, 2, by 2: same as previous, but adding a step between the values.

//DO -> Syntax (already part of your vocabulary, see theory file 8):
collection.do(function)

//SWITCH -> syntax and example:
switch (value,
        testvalue1, trueFunction1,
        testvalue2, trueFunction2,
        ...
        testvalueN, trueFunctionN,
        defaultFunction); //Else case.

(//This example was taken from the Xenakis code (review its synthdef in its own document - "codes for specific tasks"):
Routine({

	var thisIteration, xenakisCode, counter, modulo, iterationsPattern;

	counter = Pseries(0, 1, inf).asStream;
	modulo = Prand([3, 4, 5, 7], inf).asStream;
	iterationsPattern = Prand([3, 5, 10], inf).asStream;

	xenakisCode = {

		thisIteration = iterationsPattern.next;

		switch
		(counter.next % modulo.next) //Depending on the result value of this first operation, switch will choose between these options:
		{0}{{~do1.value}.fork; ~iterations = thisIteration; "first path".postln} //Three actions within a function in this case.
		{1}{{~do2.value}.fork; ~iterations = thisIteration; "second path".postln}
		{2}{{~do3.value}.fork; ~iterations = thisIteration; "third path".postln}
		{3}{{~do4.value}.fork; ~iterations = thisIteration; "fourth path".postln}
		{{~do5.value}.fork; ~iterations = thisIteration; "fifth path".postln} //The "else" case (when none of the previous results is the result of the first operation).
	};

	inf.do({
		xenakisCode.value;
		thisIteration.wait //Then the number of iterations will be used as waiting time before activating the switch again (this value is not equal to seconds, take this into consideration).
	})

}).play
)

//CASE -> The case method allows for conditional evaluation with multiple cases. Since the receiver represents the first case this can be simply written as pairs of test functions and corresponding functions to be evaluated if true. Compared to "switch", it does not need to incorporate the operation on which its results depend on because the boolan expression is written within each case (instead of just the result):

(
var i, x, z;
z = [0, 1, 1.1, 1.3, 1.5, 2, 3, 4];
i = z.choose;
x = case
    { i == 1 }   { \no }
    { i == 1.1 } { \wrong }
    { i == 1.3 } { \wrong }
    { i == 1.5 } { \wrong }
    { i == 2 }   { \wrong }
    { i == 0 }   { \true }
    {\hehe}; //"Else" case: it will be activated when 3 or 4 are chosen from the collection.
x.postln;
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////

//ALGORITHMIC COMPOSITION WITH ROUTINES
//We will use a very simple SynthDef in order to work in a more complex level on the client and not on the server dimension of SC:
(
SynthDef(
	\sine,
	{ | freq = 262, amp = 0.1, durEnv = 1, pan = 0 |
		var signal, env;

		//A simple sine wave with a percussive envelope, duplicated using Pan2:
		signal = SinOsc.ar(freq, 0, amp);
		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);
		signal = Pan2.ar(signal * env, pan);

		Out.ar(0, signal)

}).add
)

//Algorithmic composition scale: BORING (maximum number of rules) ----> Maximum interest ----> BAFFLING (minimum number of rules). The middle point (maximum interest point) depends so much on the composer and the listener: it can be closer to either extreme of our scale.
//Here we will apply codes from BAFFLING to BORING in that order, using the former SynthDef:

//Minimum number of rules: random pitch in Hz and random duration from 32nd-note to half-note (taking the second as unit for the quarter-note):
(
Routine({
	inf.do({
		Synth(
			\sine,
			[ \freq, exprand(27.5, 4186) ] //In a piano, from A0 to C8, whole register.
		);
		rrand(1/8, 2).wait //Uniform distribution of the note values, from 32nd-note to half-note (and everything in between).
	})
}).play
)

//Increasing the order: exponential distribution for choosing durations --> Higher probability for short values:
(
Routine({
	inf.do({
		Synth(
			\sine,
			[ \freq, exprand(27.5, 4186) ]
		);
		exprand(1/16, 2).wait //Expanding the duration range up to 64th-notes.
	})
}).play
)

//Unifying the durations using just 32nd-notes so rhythmic complexity is removed:
(
Routine({
	inf.do({
		Synth(
			\sine,
			[ \freq, exprand(27.5, 4186) ]
		);
		(1/8).wait
	})
}).play
)

//Simplifying the pitches: the freqs are transformed into midi and rounded to integers (as exprand always give back floats) in order to use equal temperament. The range is also reduced to one octave only:
(
Routine({
	inf.do({
		Synth(
			\sine,
			[ \freq, exprand(4186/2, 4186).cpsmidi.round(1).midicps ] //.round(2) would create a whole tone scale.
		);
		exprand(1/8, 1.0).wait //Varying the durations a bit, using the exponential distribution again to prioritize the short durations.
	})
}).play
)


//Now we move from BORING to BAFFLING in that order, using the former SynthDef, and building different levels of randomness:

//Two routines are interacting with each other: the first one, an infinite loop, functions thanks to a .next asking for pitches from the second loop in each iteration. We obtain one pitch at a time because of .yield. The second routine asks for pitches and runs automatically thanks to .play. The durations (wait time) are now equal, there is no variation (all of this will be simplified when studying the patterns, but it is useful to understand how it works internally):
(
var pitches;

pitches = Routine({
	inf.do({
		60.yield; //C4
		63.yield; //E4
		67.yield; //G4
		70.yield; //Bb4
		72.yield; //C5
})
});

Routine({
	inf.do({
		Synth(\sine,
			[\freq, pitches.next.postln.midicps] //The freqs are in midi numbers. If postln is placed after .midicps, the freqs would be posted in Hz.
		);
		(1/8).wait
	})
}).play
)

//Let's add some complexity to our system: 1 out of 5 times there is the probability of obtaining the arpeggio transposed a tritone up. The coin is the last step of the first routine, so the alternative arpeggio has a probability to appear after the first. If it doesn't, the loop will come back to the beginning of the first arpeggio:
(
var pitches;

pitches = Routine({
	inf.do({
		60.yield; //C4
		63.yield; //E4
		67.yield; //G4
		70.yield; //Bb4
		72.yield;//C5

		if ((1/5).coin.postln, { //When getting "true" out of the .coin, the second arpeggio is played.
			66.yield; //F#4
			69.yield; //A4
			73.yield; //C#5
			76.yield; //E5
			78.yield;//F#5

			[41, 42, 43].choose.yield; //Extra step: if the second arpeggio is chosen, there is a selection of one low pitch at the end of it, (F2, F#2 or G2). Hence, sometime groups of 6 notes instead of 5 will be inserted to vary the periodicity.
		});
	})
});

Routine({
	inf.do({
		Synth(\sine,
			[\freq, pitches.next.postln.midicps]
		);
		(1/8).wait
	})
}).play
)

//Opening the choice a bit more: the variable "transposition" chooses a number between 0 (no transposition) and 6 (tritone transposition). After that, there is a new loop: a G7 chord from which 0, 1 or 2 pitches are selected (pitches are chosen from the chord thanks to .do, and it does it from 0 to 2 times), and the variable "transposition" is added. If transposition = 6, the chord will be C#7. Now we are playing with three .do, two of them nested within a single routine:
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

Routine({
	inf.do({
		Synth(\sine,
			[\freq, pitches.next.postln.midicps]
		);
		(1/8).wait
	})
}).play
)

//Now we'll add new algorithmic processes to the second routine. Looking at the wait time, durations of 32nd note OR durations between 8th-notes and half-notes are chosen. Wchoose prioritizes the random short values:
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

Routine({
	inf.do({
		Synth(\sine,
			[\freq, pitches.next.postln.midicps]
		);
			[1/8, exprand(0.5, 2)].wchoose([8/9, 1/9]).wait //Try out other ratios such as 4/5, 1/5.

	})
}).play
)

//Now we create a condition so only the higher pitches (above midi 90) are going to have longer durations. We need a new variables for this: "thisPitch", so we can connect such a condition to the frequency argument later on, and "dur" so we can condition the duration in the waiting time:
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

Routine({
		var dur, thisPitch;

	inf.do({
			thisPitch = pitches.next; //When using random values chosen with .next in several places, it is best to locate it in a variable so the result is the same whenever the values are asked.
			if (thisPitch > 90, {dur = exprand(0.5, 2)}, {dur = 1/8});

		Synth(\sine,
			[\freq, thisPitch.postln.midicps]
		);
			dur.wait
	})
}).play
)

//We add now another condition to the conditional using .and: the pitch has to be higher than midi 90 AND overcome the probability of 1/6.coin:
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

Routine({
		var dur, thisPitch;

	inf.do({
			thisPitch = pitches.next;
		if ((thisPitch > 90).and((1/6).coin), {dur = exprand(0.5, 2)}, {dur = 1/8});

		Synth(\sine,
			[\freq, thisPitch.postln.midicps]
		);
			dur.wait
	})
}).play
)

//Now, every 24 notes, something is going to happen, using the module %24 connected to the index argument of the second routine's loop. We need a second "transposition" variable. Every 24 notes, a  random number from 0 to 11 is going to be chosen. Then, the new transposition is going to be added to the pitches obtained from the first routine (rememeber that it can be 0 = no transposition):
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

Routine({
		var dur, thisPitch, transposition2 = 0;

	inf.do({ | i |

		if (i % 24 == 0, {
			"modulation change".postln;
			transposition2 = rrand(0, 11) });

			thisPitch = pitches.next + transposition2;
		if ((thisPitch > 90).and((1/6).coin), {dur = exprand(0.5, 2)}, {dur = 1/8});

		Synth(\sine,
			[\freq, thisPitch.postln.midicps]
		);
			dur.wait
	})
}).play
)

//Continue experimenting with other possibilities, other choices, expanding the code, playing with the extremes between boring and baffling...

////////////////////////////////////////////////////////////////////////////////////////////

//PATTERNS
//We will start repeating the basic SynthDef used for the algorithmic composition earlier:

(
SynthDef(
	\sine,
	{ | freq = 262, amp = 0.1, durEnv = 1, pan = 0 |
		var signal, env;

		signal = SinOsc.ar(freq, 0, amp);
		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);
		signal = Pan2.ar(signal * env, pan);

		Out.ar(0, signal)

}).add
)

//STREAMS
//The message .asStream is sent to objects that do not feature a lazy evaluation, so they turn into streeams with lazy evaluation (into routines, for instance). When evaluating the envelope with the method .asStream, its has turned into a Routine:

a = Env([0, 1, 2.99, 1, 0], 3).asStream //There is a time of 3 seconds between each value, but values will only appear when asking for them using .next (the faster we ask for values successively, the more values in between we get, and the more defined is the envelope).

a.next //Evaluate successively to obtain the values from the envelope in a lazy way (from 0 to 0).

//PATTERNS
//Patterns define simple algorithms, methods that we already know, but compressed and ready to use for other kind of processes using lazy evaluation. There are more than 150 patterns by default in SuperCollider: we'll focus on a few of them.s
//Patterns receive the method .asStream and realize their tast when applying the method .next:

//PSEQ
Pseq(list, repetitions, offset) //Pseq reads an array in loop. Its arguments are the list (array to read), the number of repetitions (how many times the array is read) and the offset (if we want the array to start by an index other than 0, which is the default value).

//Example with numbers: it gives back the five numbers once (the rest of the iterations of .do up to 15 are filled up with "nil" (empty).
(
var stream;

stream = Pseq([0, 1, 2, 3, 4], 1).asStream; //Try out with 2 repetitions (make sure that .do have enough iterations to show all values).
15.do({ stream.next.postln })
)

//Example with sound (using the SynthDef above): this is the first arpeggio code we created before, but simplified using patterns as mentioned above:
(
var pitches;

pitches = Pseq([60, 63, 67, 70, 72], inf).asStream;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		(1/8).wait
	})
}).play
)

//We can perform arithmetic operations with patterns. Here there is an addition: the addition between arrays with different size is cyclical from the smaller to the bigger, as seen when studying the arrays. The method .asStream should affect both patterns. Now we are also creating a second pattern for the durations:
(
var pitches, durations;

pitches = (
	Pseq([60, 63, 67, 70, 72], inf)
	+
	Pseq([0, 0, 12], inf) //It raises the octave of a pitch every three pitches.
).asStream;

durations = Pseq([0.25, 0.5, 0.25], inf).asStream; //Fixed rhythm (short - long - short): try to divide the array by 4, so the durations are shorter.

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.next.wait
	})
}).play
)

//We can also embed patterns (nested patterns): here, in the bigger pattern of the former addition, there are two smaller patterns creating smaller loops to write a more complex series of numbers in the array in a shorter way: 3 times of 60-63 loop, 67, 70, and 5 times of 73-72 loop. The inner loops shouldn't have an infinite number of repetitions, because the bigger pattern would be stuck at them. The method .asStream is only applied to the outer pattern:
(
var pitches, durations;

pitches = (
	Pseq([ Pseq([60, 63], 3), 67, 70, Pseq([73, 72], 5)], inf)
	+
	Pseq([0, 0, 12], inf)
).asStream;

durations = (1/8); //Stable durations now so we can focus on the pattern of pitches.

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.next.wait
	})
}).play
)


//PRAND
//Prand gives back a number of random elements from the given list:
Prand(list, repeats) //Arguments: given list (array) and number of random elements to pick from the list.

//Example with numbers: functions like a .choose:
(
var stream;

stream = Prand([0, 1, 2, 3, 4], 5).asStream; //Five random values chosen here. The rest of iterations are filled up with "nil".
15.do({ stream.next.postln })
)

//Example with sound:
(
var pitches, durations;

pitches =  Prand([ 60, 62, 66, 67, 71, 72 ], inf).asStream; //In order to work with random pitches, a smaller number of options is usually better (chromatic = baffling).

durations = Prand([2, 3] /8, inf).asStream; //Prime numbers work well as random durations. A division is also applied so the values are proportionally shorter.

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.next.wait
	})
}).play
)

//Another example: pitches from a cluster 60-65 midi, and adding another prime number to the durations, 5.
(
var pitches, durations;

pitches =  Prand((60..65), inf).asStream;

durations = Prand([2, 3, 5] /8, inf).asStream;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.next.wait
	})
}).play
)

//Nested pattern here regarding the durations, using an Array.geom (and applying .mirror so the values go back and forth). Then, in the outer pattern, there is a choice between 0.1 and this inner pattern (Pseq is repeated just once by default):
(
var pitches, durations;

pitches =  Prand((60..65) + 12, inf).asStream; //Adding an octave higher.

durations = Prand([0.1, Pseq(Array.geom(8, 0.1, 1.5).mirror)], inf).asStream; //It speeds up suddenly and randomly.

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.next.wait
	})
}).play
)

//Prand with a variable number of repetitionss (remember that rrand needs the curly brackets to operate as a function):
(
var pitches, durations;

pitches =  Pseq(
	[
		Prand((60..71), {rrand(1, 3).postln}), //1 to 3 lower pitches are selected before the rest of the higher pitches are played.
		96, 97, 98, 99, 100
	],
	inf).asStream;


durations = 1/8; //Stable duration.

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.next.wait
	})
}).play
)

//############################################
//Advanced option:

//The alternative to the former code using only patterns (no functions) would need a Plazy renewed by a Pn (all these new patterns are to be studied later on in this document):

(
var pitches, durations;

pitches = Pn(
	Plazy({
		var pAmnt, pVals, pArray;

		pAmnt = Prand([1, 2, 5], inf).asStream; //Random number of chosen values among 1, 2 or 5, for instance.
		//pVals = Pn(Prand((60..71), 1)).asStream; //Either of the two options works, I guess the second one is simpler:
		pVals = Prand((60..71), inf).asStream; //Random values for the midi numbers between 60 and 71.
		pArray = Array.fill(pAmnt.next, {pVals.next}) ++ [ 96, 97, 98, 99, 100]; //The number of values is applied as a size of Array.fill, containing the midi values in its function.

		Pseq(pArray, 1); //The Array.fill is used as the list of a Pseq, output of the Plazy.
	}),
	inf).asStream;

durations = 1/8;

Routine({
	inf.do({
		Synth(\sine, [
			\amp, 0.5,
			\freq, pitches.next.postln.midicps
		]);
		durations.next.wait
	})
}).play
)
//############################################

//PWRAND
//Similar to Prand, but .wchoose version: the random values selected from the list have a specific probability. The second argument is "weights", the array of ratios we used in .wchoose (should be equal to 1 in total, or .normalizeSum should be used for converting other ratios).

//Example with numbers: 15 numbers are chosen according to the probability of the second array in Pwrand. The higher the number of chosen values (repetitions), the clearer the probability:
(
var stream;

stream = Pwrand([0, 1, 2], [0.5, 0.375, 0.125], 15).asStream;
15.do({ stream.next.postln })
)

//Example with sound: low, middle and high pitches with different probability:
(
var pitches, durations;

pitches =  Pwrand([36, 78, 97], [0.15, 0.8, 0.05], inf).asStream;

durations = 1/8;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.wait
	})
}).play
)

//Our arpeggio code, choosing between four different chords. The chords are chosen randomly, but with a probability for each of them:
(
var pitches, durations;

pitches = Pwrand(
	[
		//Three transpositions of a dominant seventh chord from the midi note added to each list. Four pitches from each Prand are chosen each time one of the Prand (chord) is chosen. The pitches are random, so they can be unsorted and repeated:
		Prand(60 + [0, 4, 7, 10], 4),
		Prand(63 + [0, 4, 7, 10], 4),
		Prand(66 + [0, 4, 7, 10], 4),
		Prand(69 + [0, 4, 7, 10], 4),
	],
	[1, 2, 3, 4].normalizeSum, //Using normalizeSum to normalize the values of the list to probability ratios from 0 to 1.
	inf
).asStream;

durations = 1/8;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps]
		);
		durations.wait
	})
}).play
)

//PSHUF
//It comes from "shuffle", but it works as a .scramble: Pshuf reads an array as Pseq, but it changes randomly the order of the elements of the array. This order is chosen just once, and then it is kept for all repetitions of the pattern.

//Example with numbers: two repetitions of the random order. If evaluated again, a different order (the same for both repetitions) is chosen:
(
var stream;

stream = Pshuf([0, 1, 2, 3, 4, 5], 2).asStream;
15.do({ stream.next.postln })
)

//Example with sound: evaluate several times to listen to different orders:
(
var pitches, durations;

pitches =  Pshuf([60, 62, 64, 65, 67, 69, 71], inf).asStream;

durations = 1/8;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.wait
	})
}).play
)

//Back to the arpeggio code: applying Pshuf to each chord instead of Prand so now we hear all pitches from each chord (although in a random order). The number of repetitions now is 1 because it is referred to the number of repetitions of the whole list as in Pseq, and not to the number of chosen values as in Prand. It seems that the order of the values in Pshuf is indeed changed here with each repetition of the Pwrand (as it re-evaluates the inner patterns again):
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

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.wait
	})
}).play
)

//PN
//Similar to the former solution for evaluating Pshuf with a different order with each iteration --> Random permutation with Pn. Pn gives back any kind of object a specific number of times. It is ideal for nested patterns (to provide patterns such as Pshuf with the possibility of random permutation). No need to use the last argument for now (see the help document, for boolean application of "key"):

//Example with numbers: Pseq includes a single repetition, but as Pn includes 2 repetitions, the Pseq is re-evaluated:
(
var stream;

stream = Pn(Pseq([ 0, 1, 2, 4, 5 ], 1), 2).asStream;
15.do({ stream.next.postln })
)

//Pshuf: random permutation, so the chosen order will change every two repetitions (as the Pshuf have two repetitions itself):
(
var stream;

stream = Pn(Pshuf([ 0, 1, 2, 4, 5 ], 2), 4).asStream; //Every 10 numbers, the order changes. The 10 numbers (2 repetitions of each order) are repeated (and randomly permutated) 4 times, so there are 40 values (as set as number of iterations in .do).
40.do({ stream.next.postln })
)

//Example with sound: in each iteration, the order of the pitches in the list is different now:
(
var pitches, durations;

pitches = Pn(Pshuf([60, 62, 64, 65, 67, 69, 71], 1), inf).asStream;

durations = 1/8;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.wait
	})
}).play
)

//Same example, now changing the pattern every 5 repetitions:
(
var pitches, durations;

pitches = Pn(Pshuf([60, 62, 64, 65, 67, 69, 71], 5), inf).asStream;

durations = 1/8;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.wait
	})
}).play
)

//Same example, changing the order every 1 to 5 repetitions, being this number of repetitions random using the function of rrand:
(
var pitches, durations;

pitches = Pn(Pshuf([60, 62, 64, 65, 67, 69, 71], {rrand(1, 5).postln}), inf).asStream;

durations = 1/8;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.wait
	})
}).play
)

//Same example, using sixth-tones (thanks to the Array.series):
(
var pitches, durations;

pitches = Pn(Pshuf(Array.series(7, 67, 0.66), { rrand(1, 4).postln}), inf).asStream; //Slight error margin because the step would be 0.666666666666666...

durations = 1/8;

Routine({
	inf.do({

		Synth(\sine,
			[\freq, pitches.next.postln.midicps ]
		);
		durations.wait
	})
}).play
)

//###########################################################
//Advance example of algorithmic routines and patterns:

//Example of changing values each certain number of iterations of a routine, maintaining the new value until a new change comes. This code plays the melody of the Theme of the Goldberg variations by Bach, choosing a random factor of speed that affects the whole melody each time it is repeated (read the comments throughout the code):
(
SynthDef(
	\bachExample,
	{arg freq, amp = 0.2, durEnv = 1, pan = 0;
	var signal, env;

	signal = SinOsc.ar(freq, 0, amp);

	env = EnvGen.ar(
			Env.perc(0.01, durEnv, 0.2), //The duration of the envelope is compensated according to the speed of the melody using the same values as for the waiting time, so when the rhythm is faster, the pitches do not overlap (and viceversa, when the rhythm is slow, the values are not too short).
			doneAction: 2
		);

	signal = Pan2.ar(signal * env, pan);

	Out.ar(0, signal)

}).add
)

(
var pitches, durations;

pitches = Pseq([ 7, 7, 9, 7, 9, 11, 9, 7, 6, 4, 2 ] + 72, inf).asStream; //Pitches for Bach's melody.

durations = Pseq([ 1, 1, 1/8, 1/8, 1/2, 1/4, 1/2, 1/4, 1/4, 1/2, 1.5 ], inf).asStream; //Ratios (duration of each note of the melody) to be multiplied by the factor of speed.

Routine({ var thisDur, factor;

	inf.do({ arg i;

		if (i % 11 == 0, {factor = rrand(0.5, 2.5)}); //The conditional controls the operation which will affect the value that we need to change each certain time. The operation exists into a variable, which is reassigned to the new value only when the conditional's output is "true". It is important not to use this variable before the conditional within the loop because it would reassign its value again when the loop is reseted.

		thisDur = durations.next * factor; //The value of the variable "factor" is the same during 11 iterations, which is the number of notes within the melody (and thanks to the module in the conditional).

		//The resultant value (of thisDur) is applied both to the waiting time and to the release time of the percussive envelope:
		Synth(\bachExample,
			[
				\freq, pitches.next.postln.midicps, //Both the pitch in MIDI and the duration are being printed just for testing.
				\durEnv, thisDur
			]
		);
		thisDur.postln.wait
	})

}).play
)
//###########################################################

//PLAZY
//Plazy evaluates a function, whose last line should be a pattern which is going to be activated and whose content and output is going to be defined by the function:

//Example with numbers, just to understand the logic: using Pn in order to vary the result in each iteration, we can create flexible patterns. For instance, here the list of Pseq has a variable size, being normally uncommon or impossible to modify the list of the pattern:
(
var stream;

stream = Pn(
	Plazy({
		var size;

		size = rrand(1, 12);

		Pseq(Array.series(size, 0, 1))

	}), inf
).asStream;

50.do({ stream.next.postln}) //The number of repetitions of the Pseq is infinite due to the Plazy, so the number of values depends on the receiver of the .do (number of iterations).
)

//In this Array.geom, the size and grow are randomly chosen, so the length and the pace of the modulation is variable:
(
var lazy, stream;

lazy = Plazy({
	var newArray;

	newArray = Array.geom(
		rrand(1, 29),
		0.01,
		rrand(1.0, 1.15)
	);
	Pseq(newArray)
});

stream = Pn(lazy).asStream; //The Pn could be applied directly to the Plazy, as in the previous example.

15.do({ stream.next.postln })
)

//Examples with sound:
//Using a simple SynthDef again
(
SynthDef(
	\sine,
	{ | freq = 262, amp = 0.1, durEnv = 1, pan = 0 |
		var signal, env;

		signal = SinOsc.ar(freq, 0, amp);
		env = EnvGen.ar(Env.perc(0.005, durEnv, 0.2), doneAction: 2);
		signal = Pan2.ar(signal * env, pan);

		Out.ar(0, signal)

}).add
)

//Taking the latter example with numbers as a point of departure: pay attention to what happens with the panning:
(
var durations, thisDur, newArray, pan;

durations = Pn(
	Plazy({
		newArray = Array.geom( //Array.geom with random size and grow.
			rrand(1, 29),
			0.01,
			rrand(1.0, 1.15) //Try out different grows such as larger ones (1.2 - 1.25, for instance).
		);

		Pseq(newArray.mirror) //Accel... to rit... using the mirror.
	}),
	inf
).asStream;

pan = Pseq([-1, 1], inf).asStream; //Panning: a new pattern is applied here for the panning: it creates a series alternating between -1 and 1 (left and right). Then, within the Synth (arguments below), this value is multiplied by the duration value from the array (which is changing in each iteration) divided by the last value of the values of that array (which is also different each time) --> When the result of that division is smaller, it means that the duration is shorter, and the panning goes closer to 0 / When the result of the division is higher (up to 1), the durations will be longer, and the panning will get to the extremes (1 or -1, alternating).

Routine({
	inf.do({
		thisDur = durations.next; //The former Plazy is applied to the waiting times (the durations, which is also connected to the duration of the envelope in the SynthDef). As we need the value of the pattern in several places, we need to put it into a variable, as commented earlier.

		Synth(
			\sine,
			[
				\freq, 4000, //Fixed frequency to focus on the durations and panning.
				\durEnv, thisDur,
				\pan, pan.next * (thisDur/newArray.last).postln,
				\amp, 0.1
			]
		);
		(thisDur * 2).wait
	})
}).play
)

//One more example: choosing between two patterns in the last line of the function of Plazy. The chosen pattern is printed in the postwindow:
(
var midinote;

midinote = Pn(
	Plazy({
		var array;

		//Choose one option for the array of pitches and comment the other:
		//array = ({ rrand(60, 84) } !3); //Three pitches between midi 60 and 84.
		array = ({ [0, 2, 4, 5, 7, 9, 11].choose + [60, 72].choose } !3); //Three pitches from the C major scale chosen randomly and placed at the 4th or 5th octave, also randomly.

		[ Pseq(array, 10), Prand(array, 30) ].wchoose([0.6, 0.4]).postln //Then, Pseq with 10 repetitions of those three notes and Prand with 30 random notes out of those as well --> Choice between both patterns with a probability for each, using .wchoose. It will choose between both patterns each 30 pitches (that is to say, when the chosen pattern is played).
	})
).asStream;

Routine({
	inf.do({
		Synth(
			\sine,
			[
				\freq, midinote.next.postln.midicps, //This time, the Plazy is applied to the frequencies.
				\durEnv, 0.15 //Fixed duration, equal to the fixed waiting time below.
			]
		);
		0.15.wait //Fixed duration.
	})
}).play
)

//////////////////////////////////////////

//OTHER PATTERNS (advanced):
//PSWITCH and PSWITCH1: Pswitch receives a list of patterns or values (numbers) - or a combination of both -, and its second arguments is "which", which will choose, according to its index, a pattern or value from the list that will be used or evaluated. For example, if the list features two elements and the objective is to alternate between them, a Pseq can be placed in the "which" argument, with an infinite loop of [0, 1], so the first and second index of the list of Pswitch alternate indefinitely.

//Pswitch1, if one or several of the elements of the Pswitch1 list is a patterns featuring several values at the same time, it will take only the first value, then the next, and so forth (one by one), unlike Pswitch, which will take all values within a pattern before jumping to its next element in the list (if asked for it).
//Next example uses Pswitch1 and a Pseq in the "which" argument: it takes the first (fixed) value of the list, then the first value of the list of the Pseq that occupies the second index of Pswitch1, then it goes back to the fixed value, then it takes two of the values of the Pseq, then fixed, then three of the Pseq, then fixed, then four of the Pseq, and so on:
(
a = Pswitch1([
	100,
	Pseq([ 74, 76, 77, 79, 80, 90, 75, 73, 72, 70, 68, 67, 65, 66, 64, 65, 63, 61, 60 ], inf)
],
Pseq([ 0, 1, 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 0 ], inf)
).asStream
)

a.next //Obtaining the values one by one.

//This next trick implemented in the former code allows us to create the infinite series of the Pseq for the "which" argument without writing all the values: Pseries will create an arithmetic series (1, 2, 3, 4, 5, etc. in this case, because the step is = 1 by default), which will be applied to the number of 1 that the Pn creates within the Pseq of the "which" argument. It is still a mystery for me why the Pseries needs the .asStream in order to work as a nested pattern (when usually in nested patterns, only the outer pattern gets the .asStream method), but otherwise, it doesn't work:
(
a = Pswitch1([
	100,
	Pseq([ 74, 76, 77, 79, 80, 90, 75, 73, 72, 70, 68, 67, 65, 66, 64, 65, 63, 61, 60 ], inf)
],
Pseq([ 0, Pn(1, Pseries(1).asStream) ], inf)
).asStream
)

a.next
