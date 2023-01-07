//8 - ITERATIONS AND ROUTINES
////////////////////////////////

//METHOD .DO
//The method .do evaluates a function for each element of the collection to which the method is applied. It's receiver (left side) is a collection and its message (right side) is a function:
//Syntax of .do: [element1, element2, ...].do( arg item, i; {function}). Two arguments can be sent to the function: the element of the array (item) and the index (iteration) of each element (or number of repetitions of the function assigned).

//First example for illustration: this function gives back each element of the array and its index in separated arrays. In addition, the method .do always gives back its receiver (the original array in this case). The method .do does not give back (collect) the result of the function, it just performs it. Therefore, if we want to see the result of the function, we need the method .postln (other options are locating the result into a variable or making the result sound). If .do was contained in the variable "a", "a" would be equal to .do's receiver. The method .collect works in a similar way, but giving back the results of the function into an array, that is to say, collecting the results.

(
[\Feldman, \Ustvolskaya, \Xenakis].do({|surname, index|

	[surname, index].postln
})
)

//Another example: locating into a sentence the elements (concatenation of the strings of text and the symbols from the array) and repeating this action for each element of the array. The parenthesis are necessary to get the .postln affecting the entire sentence:
(
[\dog, \cat, \horse].do({|animal, index|

	("the animal " ++ animal ++ " features the index " ++ index).postln //Is there some other more elegant way of adding the spaces in between the words?
})
)

//This function changes the range of rrand: the high limit is modified with each iteration of the .do:

([ 10, 20, 30, 40, 50 ].do({| num | rrand(0, num).postln})) //It will post 5 random values within the new limits imposed by the elements of the array.

//Taking the former code as a point of departure, the numbers of the array in "a" are used as lower limit of rrand, and the following number of the array is used as top limit. The function is repeated only 5 times, excluding the last item of the array in "a" becuase that value shouldn't be stablished as lower limit:

(
a = [0, 10, 20, 30, 40, 50];

a[..4].do({|num, i| rrand(a[i], a[i + 1]).postln}) //As in the former code, it print five random values between the limits imposed by the function.
)

//The receiver of .do can be a single number instead of an array: the function will be evaluated as many times as the receiver value indicates (as it happens with Array.fill but without creating an array). It still gives back the receiver:

100.do({rrand(1, 64).postln}) //100 random values between 1 and 64.

//When using a number istead of an array as the receiver of .do, the only argument we can use is the iteration:

100.do({|i| iteration.postln}) //Printing the iteration value.

//Here a brownian type of aleatoric movement is created when reassigning the value of the variable: "a" = 0 as a default value, but with every iteration of the function it is reassigned adding a random value from -1 to 1. Then, "a" is printed:

(
a = 0;
100.do({a = a + rrand(-1.0, 1.0); a.postln}) //The range -1 to 1 is the range of possible deviation from the current value of "a" in each iteration.
)

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//ROUTINES
//Functions have an "eager" evaluation because all their instructions are evaluated in one shot and at the end they give back the result of the last line of the text by default:

(
f = {
	var result;

	result = 1 + 1;
	result = result * 1000;
	result = rrand(0, result)

}
)
f.value //Giving back only the last line of the operations (having performed the rest of the operations before).

//Now the operations are evaluated, but the result is "hi" because the string is placed at the last line of the function:
(
g = {
	var result;

	result = 1 + 1;
	result = result * 1000;
	result = rrand(0, result);
	"hi"

}
)
g.value

//Now the result given in the postwindow is still "hi" because it occupies the last line of the code, but the variable "z" contains the result of the former operations. Therefore, we can reach the result of the operations through the variable "z" (and demonstrate that, despite the value of the function is "hi", all the operations it contains are performed):
(
h = {
	var result;

	result = 1 + 1;
	result = result * 1000;
	z = result = rrand(0, result);
	"hi"

}
)
h.value //Giving back the last line of the code.
z //The variable "z" still contains the result of the operations within the function, although their result is not shown as the value of the function (though we need to use the method .value before for "z" to contain this value.

//On the contrary, the evaluation of a Routine is lazy instead of eager, the lines are evaluated one at a time when it is ordered to do so. The message .yield separates the instructions and gives back the result up to that point of the function as if the line it is sent to was the last line of such a function. Then, we can continue evaluating the routine from that line onwards. In order to evaluate the routine, we use the method .next instead of .value: when evaluating .next, the results of each block of code up to a .yield will be evaluated each time in order from top to bottom within the function:

//Simple example with numbers:
(
r = Routine({ //The first argument of a Routine is a function, hence we need the curly brackets.

	1.yield;

	15.yield;

})
)

r.next //Result of the operations up to the first .yield of the routine. Keep evaluating for obtaining the rest of the values. When there are no more values next, "nil" ("empty") is printed in the post window.

r.reset //Gives back the reseted routine, to be evaluated from its top again.

//Example with more elements: strings, something that sounds, something that turns off the sound, etc.:
(
r = Routine({

	"hello".postln;
	a = {SinOsc.ar(1000, 0, 0.1)}.play;
	1.yield;

	"here".postln;
	a.release(1);
	15.yield;

})
)

r.next //First evaluation: give back "hello", the sound of the SinOsc and the number 1 (receiver of .yield) / Second evaluation (without stopping the server): gives back "here" and the number 15, and turns off the SinOsc in "a" (using .release, with 1 second of decay) / If it is evaluated for the third time, it gives back "nil", which means "empty", because there are no more instructions to be evaluated within the routine unless it is reseted.
r.reset

//Another example (the string as a receiver of .yield does not need to be printed with .postln because .yield gives back the string as if it was the last line of a function. However, the other string contained within the first block of instructions needs to be printed with .postln to be visible in the postwindow):
(
r = Routine({
	var synth1, synth2, synth3;

	"hello".postln;
	synth1 = {SinOsc.ar(1000, 0, 0.05)}.play;
	"synth1 created".yield;

	synth2 = {BrownNoise.ar(0.1)}.play;
	"synth2 created".yield;

	synth3 = {Ringz.ar(Impulse.ar(1), 1500, 0.2, 0.1)}.play;
	"synth3 created".yield;

	synth1.release;
	"synth1 turned off".yield;

	synth2.release;
	"synth2 turned off".yield;

	synth3.release;
	"synth3 turned off".yield;

})
)

r.next //Follow the steps of each block of instructions up to each .yield.

/////////////////////////////////////////////////////////////////

//LOOPS WITH ROUTINES
//Now we can apply .do to the routines in order to create loops.

(
r = Routine({
	var options;

	options = [\green, \black, \white];

	5.do({options.choose.yield})
})
)

r.next //With this message .next, the routine is activated, the three symbols go into the variable "options", and the first value of "options" is asked to .do. It only gives back one result each time because .yield is included in the function of .do. It can be evaluated 5 times until it gives back "nil" (with no .yield, the 5 results would be given back at the same time, but .postln would be necessary to see the results in the postwindow).

//This is how the former code worked, but without the .do:
(
r = Routine({
	var options;

	options = [\green, \black, \white];

	//5.do({opciones.choose.yield})
	options.choose.yield;
	options.choose.yield;
	options.choose.yield;
	options.choose.yield;
	options.choose.yield;
})
)

r.next

//Now we create an infinite loop, so it will always give back values instead of giving back "nil" at some point. Be aware of .yield: when .inf is sent to .do, yield is essential in order to stop the infinite loop, which would make the interpreter collapse (in such a case, try patiently to open the menu "language" above and press "quit interpreter". Later on you can "boot interpreter" again):

(
r = Routine({
	var options;

	options = [\green, \black, \white];

	inf.do({options.choose.yield})
})
)

r.next

//If the routine is controlled by .play, then a clock ask the routine for results automatically (without having to send the message .next). The routine is evaluated automatically each certain amount of time:

(
r = Routine({
	inf.do({
		[\paper, \scissors, \rock].choose.postln;
		1.yield
	})
})
)

r.play //In here, .yield goes to the number 1, which will be interpreted as the number of seconds between each evaluation of the routine. Yield cannot receive now any other kind of objects but numbers.

//Controlling the clock in SC:
r.clock //We open the communication with the clock, called "TempoClock".
r.clock.tempo //We ask about the tempo of the clock ("getter" message, because it gives back a value), which is 1 by default.
r.clock.tempo = 100/60 //We assign 100 bpm to the clock (as the default is 60 bpm = 1 sec), ("setter" message, because it changes the value).

//Syntax of the clock control: if the clock is not specified, the default clock will be used.

Routine.new(function).play(clock)

//There are different kinds of clocks in SC: TempoClock is used by default and understand the time as pulses within a unit (can be seconds) / SystemClock is not there by default and understand the time only in seconds, thus it is less flexible / AddClock is used for operations that are not a priority, meaning that they are not related to audio production (such as graphic content or midi), for example (if the program is reaching the CPU limit, the priority is given to TempoClock and SystemClock).

TempoClock.new(tempo) //Syntax: tempo is specified in bpm ratios (like metronomic tempo):
/*
1 = 60 bpm (60/60 is the ratio)
3 = 180 bpm (180/60)
0.66 = 40 bpm (40/60)
And so on. Writing the ratios is easier and clearer.
*/

//If we change the clock of a routine, this clock is == (equal) and === (identic) to TempoClock.default, which is the master clock of SC --> All clocks will be modify within the whole code. This is why we create TempoClock.new in ordr to create an independent clock to change the clock of the routine.
(
r = Routine({
	inf.do({
		[\paper, \scissors, \rock].choose.postln;
		1.yield //The number 1 is now interpreted as 1 unit of time within the 180 units of time per minute that will be produced by the clock.
	})
});

z = Routine({
	inf.do({
		"hello".postln;
		1.yield
	})
});
)

//Evaluating both routines at the same time, there is a polyrhythmia created because each routine features a different tempo:
(
r.play(TempoClock(180/60));
z.play(TempoClock(60/60))
)

//Example with sound:
(
SynthDef(
	\sawtooth,
	{| freq |
		var signal;

		signal = Saw.ar(freq * [1, 1.1]) //The product of the frequency is creating a slight detuning.
		*
		EnvGen.ar(Env.sine(0.1, 0.125), doneAction: 2); //doneAction = 2 is essential so the envelopes do not accumulate with each iteration of the loop.

		Out.ar(0, signal)
}).add
)

(
r = Routine({
	var overtones;

	overtones = 400 * (1..11); //Natural overtones from 400 Hz.

	inf.do({ //The Synth is created within the .do loop.
		Synth(\sawtooth,
			[\freq, overtones.choose.postln]
		);
		[1, 0.25, 0.125].wchoose([0.1, 0.4, 0.5]).yield //This will create different random units of thempo (within the default clock).
	})
}).play
)

//#####################################################
//Extra (and unnecessary) information: with this code, an envelope is created within the routine to modulate the number of beats over 60 (per minute), from 120 to 130 (.asStream in combination with .next will be studied in future chapters). This would need to be implemented in a routine that sounds (featuring any Synth):

(
Routine({
	e = Env([120, 130], 60).asStream;

	inf.do({
		TempoClock.default.tempo = (e.next/60).postln; //.postln will show the values.
		0.1.wait;
	})
}).play
)
//######################################################

//When using automatic evaluation in the routines, the message .wait is usually used instead of .yield, but both messages are equivalent.
//Another example applied to sound: here there is a bigger loop containing two smaller loops which alternate between each other: the first one contains the Synth, and the second one creates its own synth with .play:
(
SynthDef(
	\sawtooth,
	{| freq |
		var signal;

		signal = Saw.ar(freq * [1, 1.1])
		*
		EnvGen.ar(Env.sine(0.1, 0.125), doneAction: 2);

		Out.ar(0, signal)
}).add
)

(
r = Routine({
	var overtones;

	overtones = 400 * (1..11);

	inf.do({

		([5, 7, 10, 3].choose).do({
			Synth(\sawtooth,
				[\freq, overtones.choose.postln]
			);
			0.1.wait;
		});

		4.do({
			{SinOsc.ar(
				exprand(1000, 8000),
				0,
				0.1
			) * EnvGen.ar(Env.sine(1), doneAction: 2)
			}.play;

			1.wait
		})
	})
}).play
)

