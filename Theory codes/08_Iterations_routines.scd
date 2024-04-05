//8 - ITERATIONS AND ROUTINES

/////////////////////////////////////////////////////////////////////
//METHOD .DO

//There are many methods for iteration. Some of them can be found in the Collection help file --> Iteration paragraph: https://depts.washington.edu/dxscdoc/Help/Classes/Collection.html (we mentioned some of this in the theory file 2). Iteration will eventually allow us to automatize the creation of multiple or successive instances (synths) of a SynthDef and customize their behavior over time.

//The method .do evaluates a function for each element of the collection to which the method is applied (it's receiver). The function passes two arguments: the item of the correction, and the iteration number (from 0 to the last index of the collection):

//Syntax:
[element1, element2, ...].do({ |item, iteration| function })

//Example: .do executes the function as many times as items in the receiver collection. This method does not return the results of the function unless we print them though, just like in this example (it only executes the function). What .do always returns at the end is the receiver (the collection):
[\dog, \cow, \chicken].do({ |animal, index| [animal, index].postln })

//The method collect works similarly, although results are collected within an array and printed (no need to use .postln). In any case, let's focus on .do for now:
[\dog, \cow, \chicken].collect({ |animal, index| [animal, index] })


//##############################################################
//Playing with strings (a very unnecessary section):

//Another example of .do, this time placing into a sentence the elements of the collection (concatenation of strings and symbols):
(
[\dog, \cat, \horse].do({|animal, index|

	("the animal " ++ animal ++ " features the index " ++ index).postln //There should be, though, a more efficient way to leave spaces in between:
})
)

//According to the help file, ++ is used for concatenation with no spaces, and + is used for concatenation leaving a space, but this only works between two strings, and here we are combining symbols and strings:

"hello" ++ "you" //No space.
"hello" + "you" //Space in between.

//A possible solution I found is this: .scatArgs concatenates a string with the following args with spaces in between:
"These are some args:".scatArgs(\fish, SinOsc.ar, {4 + 3}).postln;

//Applied to our function, it does work really well:
(
[\dog, \cat, \horse].do({|animal, index|


	"the animal".scatArgs(animal, "features the index", index).postln;

})
)
//##############################################################


//Example using the item argument: the upper limit of the rrand method will be higher with each iteration:
[10, 20, 30, 40, 50].do({ |num| rrand(0, num).postln })

//Example using the iteration (or index) argument:
(
a = [0, 10, 20, 30, 40, 50]; //The variable "a" contains the receiver array of .do.

a[..4].do({ |num, i| rrand(a[i], a[i + 1]).postln }) //We execute the function to only indexes 0 to 4 from the array in "a", as we are using "i + 1" in the function and it would point already to the index 5. With each iteration, the range of rrand moves between the next two consecutive indexes (0-10, 10-20, 20-30, and so on).
)

//When receiving a single number (an integer), .do executes the function as many times as the number indicates, that is to say, it actually iterates from 0 up to such a number (thus, the receiver is equivalent to a collection of integers from 0 to the last index -that number- and, for this reason, the item argument and the iteration argument are equal, so we only use one argument in this case):
100.do({ rrand(1, 64).postln })

//Example: Brownian movement model. We obtain 100 values at once:
(
a = 0; //Initial value.
100.do({ a = a + rrand(-1.0, 1.0); a.postln }) //In each iteration, the value of "a" is reassigned to "a" plus a random number within the range of deviation.
)

//There is a method called .reverseDo, which goes through the receiver in reverse order
10.reverseDo({ |i| i.postln }) //Posts from 9 to 0.


/////////////////////////////////////////////////////////////////////
//ROUTINES

//More on Routines (and an alternative called "Task") here: https://doc.sccode.org/Tutorials/Getting-Started/15-Sequencing-with-Routines-and-Tasks.html
//In order to automatize the iteration process of .do, we need a Routine. Let's first understand the difference between "eager" and "lazy" evaluation or execution in SuperCollider (difference between Function and Routine):

//Function (eager): all instructions are run at once (from top to bottom). The postwindow only shows the result of the last line of the function:
(
f = {
	var result;

	result = 1 + 1;
	result = result * 1000;
	z = result = rrand(0, result);
	"hi" //Last line of the function: the only one returned to the postwindow.
}
)
f.value
z //This variable contains the result of its line in the function anyways.

//Routine (lazy): the class Routine allows the lazy evaluation of a function: each instruction is executed when it is asked to:
(
r = Routine({

	1.yield; //The method .yield indicates each instruction or group of instructions to be executed at a time (as if this was the "last line of a function").

	15.yield;
})
)
r.next //The method .next asks the Routine to execute instructions up to each .yield (from top to bottom). When all instructions are executed, the Routine returns "nil" ("empty").
r.reset //Reset allows us to come back to the beginning of the function, so that we can run it again directly by using .next.

//More complex example:
(
r = Routine({
	var synth1, synth2, synth3;

	//Each of these blocks (until next .yield) will be executed at once:
	"hello".postln; //Needs .postln because it is not the line of the .yield.
	synth1 = { SinOsc.ar(1000, 0, 0.05) }.play;
	"synth1 created".yield; //No need for .postln as this is the "last line of the function".

	synth2 = { BrownNoise.ar(0.1) }.play;
	"synth2 created".yield;

	synth3 = { Ringz.ar(Impulse.ar(1), 1500, 0.2, 0.1) }.play;
	"synth3 created".yield;

	synth1.release;
	"synth1 turned off".yield;

	synth2.release;
	"synth2 turned off".yield;

	synth3.release;
	"synth3 turned off".yield;

})
)
r.next
r.reset


/////////////////////////////////////////////////////////////////////
//ROUTINES AND .DO: ITERATION

//Combining .do and Routine allows us to automatize iteration processes. These two examples show how .do can perform an iterative process much more efficiently:

//Without .do:
(
r = Routine({
	var options;

	options = [\green, \black, \white];

	options.choose.yield;
	options.choose.yield;
	options.choose.yield;
	options.choose.yield;
	options.choose.yield;
})
)
r.next

//Using .do:
(
r = Routine({
	var options;

	options = [\green, \black, \white];

	5.do({ options.choose.yield })
})
)
r.next

//Creating an infinite loop: .do can receive "inf" as a receiver in order to create an infinite loop or iteration. Though in this case the method .yield is essential in order not to make SC crash because of the infinite number of iterations executed at once:
(
r = Routine({
	var options;

	options = [\green, \black, \white];

	inf.do({ options.choose.yield }) //Use .yield!
})
)
r.next //Now we can obtain an infinite number of results.

//The method "loop" is equivalent to inf.do:
(
r = Routine({
	var options;

	options = [\green, \black, \white];

	loop({ options.choose.yield })
})
)
r.next


/////////////////////////////////////////////////////////////////////
//USING CLOCKS: ROUTINE.PLAY

//In order to automatize the Routine instead of using the method .next repeatedly, we need to make Routine depend on a clock. This is done by sending it the method .play: when a Routine receives the method .play, it is controlled by a clock. The number assigned to .yield will represent now the time between each iteration of the Rotuine (counted in beats, not necessarily in seconds).
//The topic of clocks in SC is quite heavy and here I will just touch the surface. The following link might be useful to deepen into this: https://depts.washington.edu/dxscdoc/Help/Tutorials/Getting-Started/14-Scheduling-Events.html

//Routine is controlled by a clock:
(
r = Routine({

	inf.do({
		[\paper, \scissors, \rock].choose.postln;
		1.yield //The receiver of .yield is the time between each iteration of the Routine (by default: 1 = 1 sec, or 1 beat at 60bpm).
	})
})
)
r.play //We obtain one result per second.
r.stop //This is the proper way to stop a running routine, avoid using ctrl-period.

//The control of Routines with clocks can be also carried out by the method .fork (equivalent to the previous code). According to the Help file, "fork returns a Routine using the receiver as it's function, and plays it in a TempoClock" (we will talk later about this specific clock). As with "play" (when applied to a stream - more on streams in theory file 11), it also receives the arguments "clock" and "quant" (see .play in the help file of Routine):
(
f = {
	inf.do({
		[\paper, \scissors, \rock].choose.postln;
		1.yield
	})
}
)
f.fork
f.stop

//Understanding clocks in SC:
r.clock //The clock of "r" is "a TempoClock" (the clock by default in SC, measured in beats according to a specific tempo, 60 bpm by default). Other clocks in SuperCollider are SystemClock and AppClock. SystemClock always runs in seconds, so for musical events, it is less flexible than TempoClock. SC resorts to AppClock for lower system priority processes (everything that is not related to sound synthesis, such as graphical interfaces and other non-time-critical tasks, such as anything carried out in the language). TempoClock is the most flexible clock for musical events as its unit can depend on different tempos (not just seconds).
r.clock.tempo //The tempo of "r" is 1 (measured in beats per second instead of beats per minute! Hence, by default, the beat is equivalent to the second, or to 60 bpm).
r.clock.tempo = 100/60 //We can ask "r" to change it's tempo to 100 bpm.
r.clock.tempo //Now the tempo of "r" has changed (try out the previous Routine and compare its pace).
r.clock.tempo = 1 //= 60/60 //Setting the tempo back to 60 bpm (second as a referential time unit).
//By changing the "tempo" in this way, we are changing the default TempoClock of SC, so that all Routines will be subjected to this tempo.
r.clock === TempoClock.default //Proof of identity between the clock of "r" and the default TempoClock (returns true).

//Independent clocks: in order to avoid changing the default TempoClock, we can create our own independent clock for a specific Routine:
(
r = Routine({
	inf.do({
		[\paper, \scissors, \rock].choose.postln;
		1.yield //Number 1 is understood as one unit (beat) within the 180 bpm set below in the new clock.
	})
});

z = Routine({
	inf.do({
		"hello".postln;
		1.yield
	})
});
)

//Setting different clocks for each Routine by using the class TempoClock (and the method .new, although it can be omitted):
(
r.play(TempoClock(180/60)); //Three times faster than "z": check what is returned in the post window (one result of "z" every three results of "r").
z.play(TempoClock(60/60))
)s
r.stop; z.stop

//If we run the previous "r" routine (line 199), then we can check that its "tempo" hasn't been affected by these clocks.

TempoClock.tempo = 1 //Let's reset this for the rest of the session (just in case).

//Anyway, in some situations, creating new clocks and assigning different tempos can be replaced by working with the second as a unit by default and adjusting the waiting time using floats if needed.


//First example of the instrument-score relationship (SynthDef-Routine): the automatized iteration process will consists of the successive creation of instances (synths) of a SynthDef:
(
SynthDef(
	\sawtooth, { //Simple SynthDef: a sawtooth oscillator with two frequencies is multiplied by a sine envelope.
		|freq|
		var signal;

		signal = Saw.ar(freq * [1, 1.1], 0.1)
		*
		EnvGen.ar(Env.sine(0.1), doneAction: 2); //DoneAction: 2 is essential here in order to avoid that the synths accumulate in the server with each iteration.

		Out.ar(0, signal)
}).add
)

(
r = Routine({
	var overtones;

	overtones = 400 * (1..11);

	//Nested or embedded loops:
	//Outer .do (loops the alternation between the two inner loops, and depends on their waiting times):
	inf.do({

		//First inner .do (chooses 5, 7, 10 or 3 frequencies from the array of overtones and send them to the SynthDef, creating different instances of it):
		([5, 7, 10, 3].choose).do({
			Synth(\sawtooth,
				[\freq, overtones.choose.postln]
			);
			0.1.wait //When using .play with Routines, it is common to use the method .wait instead of .yield (although they are equivalent).
		});

		//Second inner .do (creates four instances of the sine oscillator choosing a different random frequency each time). This synth in independent from the one in the SynthDef:
		4.do({
			{ SinOsc.ar(
				exprand(1000, 8000),
				0,
				0.05 !2
			) * EnvGen.ar(Env.sine(1), doneAction: 2)
			}.play; //This .play is not applied to the Routine, but to a function, so its result is to create an instance of a synth out of the function it is applied to.

			1.wait
		})
	})
}).play //This .play is sent to the Routine so that it is controlled by a clock.
)
r.stop //doneAction 2 already frees every synth, so there is no need to free it separately.

//The relationship between SynthDef and Routine is very efficient because it allows us to clearly separate the two sides of SuperCollider (although the former example is not the best for this, it can be taken as a reference if we disregard that inner synthesis process within the sine oscillator loop): Routine operates on the Client side while SynthDef works on the Server side. Once SynthDef is compiled, its structure is fixed in the server, but Routine allows us to define different instances of the SynthDef over time, turning SynthDef into a flexible and versatile instrument to follow the "score" defined in Routine.
//In the theory file 10, we will take this idea further creting cross-fade and overlap routines.


//##############################################################
//Additional information about streams (lazy evaluation):

//Using the method .asStream applied to an envelope. In this code, an envelope is created within a Routine to modulate the number of beats over 80 (per minute) from 50 to 130. The method .asStream needs to be used in combination with .next (this relationship will be studied when talking about patterns). This could be then implemented to something that makes sound:
(
Routine({
	e = Env([50, 130], 15).asStream; //.asStream turns something that is not a stream (an envelope) into a stream (that is so say, something with "lazy" evaluation). I am guessing that the 15 are actually seconds.

	inf.do({
		TempoClock.default.tempo = (e.next/60).postln; //.postln will show the values (5 times per BEAT as 0.2.wait indicates, although the beat in this case is much shorter than a second: you can actually see in the post window how the process speeds up).
		0.2.wait;
	})
}).play
)
//##############################################################
