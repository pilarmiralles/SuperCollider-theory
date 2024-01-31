//6 - SYNTHDEF, OUT AND IN

/////////////////////////////////////////////////////////////////////
//SYNTHDEF: SYNTH DEFINITION

//This tutorial might come in handy to get started with this: https://doc.sccode.org/Tutorials/Getting-Started/10-SynthDefs-and-Synths.html

//A synth is a collection of unit generators that run together: it represents a single sound producing unit. What a synth does is defined in a synth definition (or SynthDef). Synths are created from SynthDefs: SynthDefs are created in the language application (client side), and then compiled and loaded into the server. In a SynthDef, we can specify what UGens are used, how they are put together, and what inputs and outputs their synth instances will have. SynthDefs are kind of fixed patterns, upon which synths are created, but they can provide a surprising flexibility and variation: all values can be modified except for those changing the structure of the synth (that is, for instance, the size of arrays, the number of inputs or outputs - which is also represented by array size -, etc.). The client-side representation of a synth, the class Synth, is used to obtain the sound (or processing) from a SynthDef: it represents or "calls" a single instance of it, being able to specify the value of its arguments (input values that we can change from outside the SynthDef). Synth and SynthDef are connected through a name expressed as a symbol (so that it can be used as a tag, representing the same object).
//Notice that when we use function.play, a SynthDef is being created too, although this occurs at a deeper level that we don´t see (this is only convenient for short examples and quick testing). When creating a SynthDef, we can control all aspects of this level.

/* The SynthDef class creates synthesis instruments. It defines:
1 - An interconnection between signals (UGens).
2 - The in and out audio (or control) signals (a metasignal).
3 - The arguments that allow the instrument (interconnection of signals) to be controlled from outside the instrument (from the client-side).
4 - Its two fundamental parts (arguments) are: a name, and a function:
*/

SynthDef(name, ugenGraphFunc) //This is a SynthDef: "name" should be defined as a \symbol (or 'symbol'), which will allow us to call the SynthDef from anywhere in the code; "ugenGraphFunc" is a function that will be evaluated just once, when the SynthDef is compiled. Once the graph is built (the SynthDef is compiled), the architecture of the graph (the interconnections between the signals or UGens) is fixed. The SynthDef is compiled by sending the message .add to it.

//Structure of the SynthDef (.new can be omitted, as usual). When executed, the following code returns "a SynthDef":
(
SynthDef.new(
	\whateverName,
	{

	}
).add
)

//Example including a name, arguments, variables, a signal and the object Out, which is a UGen as well. If we want the SynthDef to output a signal, we need an output UGen, for which the most basic one is Out: its areguments are "bus" (the out channel, which should occupy one of our output channels (by default, channels 0 or 1) and "channelsArray" (the signal or array of signals to be output). More on the UGen Out later on in this document. This SynthDef includes the message .add, but it does not produce sound: it is just the compiled intrument. We'll need a Synth object to "play" the instrument:
(
SynthDef(
	\sineWave,
	{ arg out, freq, phase, amp;
		var signal;

		signal = SinOsc.ar(freq, phase, amp);
		Out.ar(out, signal)
	}
).add
)

//In order to play the instrument and obtain sound, we need to create a Synth (Synth.new), the client-side representation of a single sound producing unit (synth), which calls the SynthDef through its name and modifies its arguments, which are called using symbols as well. Notice that it is not possible to evaluate the SynthDef and the Synth at the same time because it takes a certain time for the server to decode the text into its own language (our writing --> Byte-code: we can apply the method .asBytes.asCompileString at the end of a SynthDef to see in the postwindow these numbers that the server understands. The Byte-code is something in between our language and the binary code):

a = Synth(\sineWave, [\out, 0, \freq, 1000, \phase, 0, \amp, 0.1]) //Out = 0 goes to the left side by default / Out = 1 goes to right side by default.
b = Synth(\sineWave, [\out, 0, \freq, Array.fill(50, {exprand(100, 3000)}).choose, \phase, 0, \amp, 0.1]) //The order of the arguments is not important because we are calling them using symbols (something similar happens when using keyword assignment). Here, using a random frequency (any operations we can perform on the client side can be applied to the SynthDef's arguments).

//When operating with SynthDefs, the command ctrl-period shouldn't be used to stop the sound. Instead, the method .free applied to the Synth should be used:
a.free;
b.free;

//Some other consequences of the "fixation" of the UGen graph after compiling a SynthDef with .add: randomness and other client-side methods need their UGen version so that they can output different values even after the SynthDef is compiled. For instance, rrand and exprand will find its values fixed if used as client-side methods (we would need to compile the SynthDef anew to obtain new values). Instead, we can use their UGen versions, Rand and ExpRand. We will see later on in this document some other UGens for randomness and choice when using SynthDefs:
(
SynthDef(
	\sineWaveRand,
	{ arg out, freq, phase, amp;
		var signal;

		signal = SinOsc.ar(ExpRand(100, 2000), phase, amp); //Random frequency (exponential distribution).
		Out.ar(out, signal)
	}
).add
)

c = Synth(\sineWaveRand, [\out, 0, \phase, 0, \amp, 0.1]) //Now the frequency will be different each time a synth is created (each time the Synth is executed). As seen before, Synth is already part of the client, so methods like rrand and exprand can be used when applied to arguments in Synth.
c.free

//As mentioned before, one of the things we cannot modify after compiling the SynthDef is the size of any array within it. It is therefore not possible to apply any operation from outside the SynthDef that would affect the size of an array. Take into consideration as well that arguments are usually fed with numbers. Let's see another example of SynthDef and Synth ("instrument" - "score"):
(
SynthDef(
	\filters,
	{
		var noise, signal;

		noise = WhiteNoise.ar(0.0001);

		signal = Array.fill(18, { Ringz.ar(noise, ExpRand(100, 3000)) }); //Think about the differences between duplicating the Ringz 18 times and creating 18 different random frequencies within the Ringz (applying the array to ExpRand), in terms of multichannel expansion: in this case, as the noise is shared through a variable, the result would be the same.
		signal = Mix(signal);
		signal = Pan2.ar(signal, 0); //Now that the signal is stereo (two channels), it will be directly output through indexes 0 and 1 (left and right) in the Out UGen. This will be explained in the next section.

		Out.ar(0, signal)
}).add
)

d = Synth(\filters) //The SynthDef is executed (compiled) just once. Then, each execution of the Synth will create a different instance of a synth thanks to the randomness of the function within the SynthDef. We could create several arguments to be controlled from the Synth here: the amplitude, the panning, the upper and lower limits of the random frequency choice, etc. (but, for example, we wouldn't be able to change the number of random frequencies - the size of the array - using an argument).
d.free


/////////////////////////////////////////////////////////////////////
//OUT

//The UGen Out sends as outputs the signals created within the SynthDef's function: "bus" is the index in the channels array (audio or control busses) from which the signals will be sent out; "channelsArray" it's a mono signal or array of signals (when more than one):
Out.ar(bus, channelsArray) //For audio signals.
Out.kr(bus, channelsArray) //For control signals.

//Some examples:
Out.ar(0, SinOsc.ar) //The sine wave will be sent to the channel 0 (left out).
Out.ar(0, SinOsc.ar !2) //This way, the signal will be stereo (it creates an array of two sine waves that are sent through channels 0 and 1).
Out.ar(0, SinOsc.ar !8) //Eight channels (if not using 8 loudspeakers, we will only be able to hear the two first channels - remember to adapt the number of input and output channels according to the number of speakers: see https://doc.sccode.org/Classes/ServerOptions.html).
Out.kr(100, SinOsc.kr) //Using control channels (not so usual nowadays).


//DONE ACTION: as studied in the theory file 5, doneAction (and done flags, if not as an argument) will be found in many Ugens that, despite they stop producing sound, they might still be running in the server (for instance, an envelope). doneAction will become increasingly important when creating several instances of a Synth successively to prevent the accumulation of nodes (events running in the server) at a time.
//Let us remember how it works with an example, now applied within a SynthDef: when the envelope is finished, here with doneAction 2, the synth stops running in the server (you can see it in the status bar below the post window, "s" being the number of running synths in the server. When executing the SynthDef and its Synth, this value will increase to 1s. After closing the gate and finishing the release time, the value will come back to 0s. If doneAction = 0, then the synth won't disappear after closing the gate (you can also check this opening the node tree in the menu "Server" above, "Show node tree"):
(
SynthDef(
	\sineGate,
	{ |out, freq, amp, gate = 1|
		var signal, env;

		env = EnvGen.ar(
			Env.adsr(0.01, 0.1, 0.3, 3, 1),
			gate,
			doneAction: 2
		);

		signal = SinOsc.ar(freq, 0, amp);

		Out.ar(out, signal * env)
}).add
)

e = Synth(\sineGate, [\out, 0, \freq, 500, \amp, 0.3, \gate, 1]) //Open the gate.
e.set(\gate, 0) //Close the gate, killing the Synth due to doneAction = 2 (no need to apply the method .free to the Synth). The method .set can be sent to the Synth to change an argument while the synth is running.


/////////////////////////////////////////////////////////////////////
//ARCHITECTURE OF THE AUDIO SERVER

//A link to remember: Client vs Server: https://doc.sccode.org/Guides/ClientVsServer.html
//And a new link for this section: https://doc.sccode.org/Reference/Server-Architecture.html

/* MAIN CONCEPTS (partly from the previous help document, see the link for more details):

NODE: A Node is an addressable point run by the synth engine (the server). Nodes are ordered in a tree of nodes (the node tree) which defines their order of execution. There are two types of nodes: Synths and Groups (in the node tree, synths are represented by a white rectangle and groups are represented by a grey rectangle). All nodes have an integer ID (the node ID), which allows the communication with them, for instance, to change the value of their arguments, shit them down, ask them about their state, etc.

GROUP: A Group is a collection of nodes. New nodes can be added to the head or the tail of a group, and all nodes within a group can be controlled together. Nodes within a group can be synths or other groups. There are two groups by default: a root group with ID = 0, which is created when the server is booted up; and a default group with ID = 1, also created at booting time and inside the root group. We usually find all the recording, monitoring and primitive functions in the root group (encompassing all other groups). In the default group, all new nodes are created if not indicated otherwise. See RootNode and Default Group for more info.

Synths and SynthDefs are part of the basic concepts of the architecture of the audio server. Get back to the beginning of this document for their definition.

NODE TREE: All nodes are placed within the node tree, which defines the order in which they run in the server, which is from top to bottom: on top what is heard (a noise, for instance), at the bottom, what hears and process what is heard (a filter, for example). We will talk later about the order of execution.

AUDIO BUSES: Synths send audio signals to each other via a single global array of audio buses (signals can be used as inputs to other synths by reading them from a bus, for instance). Audio buses are indexed by integers beginning with zero. Using buses rather than connecting synths to each other directly allows synths to connect themselves to the community of other synths without having to know anything about them specifically. The lowest numbered buses get written to the audio hardware outputs, immediately followed by the input buses. Check the server options for default values details (any change in these values, for example, in the number of input and output hardware buses, require the server to be rebooted).

CONTROL BUSES: Synths can send control signals to each other via a single global array of control buses. These are also indexed by integers beginning with zero.

BUFFERS: Buffers are arrays of 32 bit floating point values with a small descriptive header. Buffers are stored in a single global array indexed by integers beginning with zero. Buffers may be safely allocated, loaded and freed while synthesis is running, even while unit generators are using them. Buffers are used for wave tables, sample buffers, delay lines, envelopes, or for any other need which can use an array of floating point values. Sound files may be loaded into or written from buffers. We will study Buffers with greater detail in theory files 7.1 and 7.2.

UNIT GENERATOR DEFINITIONS: Unit Generator Definitions are plug-ins loaded automatically when the program starts. They are binary code libraries that are used as building blocks by Synths to build synthesis algorithms. Unit Generator Definitions have names that match the names of SuperCollider language classes used in building Synth Definitions (they are the server-side version of UGens as represented on the client side).
*/


/////////////////////////////////////////////////////////////////////
//IN

//The UGen In reads the signals located in the audio and control channels. These signals are produced by synths or by the hardware inputs (for instance, a microphone). In and Out UGens will allow us to route signals between several SynthDefs. Separating synthesis and processing procedures into different SynthDefs can allow us to control all links of the synthesis chain.

In.ar(bus, numChannels) //For audio channels.
In.kr(bus, numChannels) //For control channels.

//Regarding the arguments: "bus" is the index of the channels from which In will read the signals; "numChannels" is the number of channels to read from the indicated index. For example:
In.ar(0, 1) //From channel 0, it will read 1 channel.
In.ar(30, 2) //From channel 30, it will read 2 channels (30 and 31).
In.ar(40, 10) //From channel 40, it will read 10 channels (40 to 49).

//Example of SynthDefs using In and Out: producing a noise and filtering:
(
SynthDef(\noise,
	{ |out|
		Out.ar(out, BrownNoise.ar)
}).add;
SynthDef(\filter,
	{ |out, in, freq|
		var input, signal;

		input = In.ar(in, 1);
		signal = BPF.ar(input, freq, 0.01, 0.5);
		Out.ar(out, signal)
}).add
)

//WHY DOES THIS NOT SOUND? See the node tree: the filter is above the noise, hence we need to flip them in order to hear the noise (noise = what sounds / filter = what listens to what sounds):
f = Synth(\noise, [\out, 4,]) //The noise is sent to channel 4, a private channel, so that it can be processed before sending it through the hardware out.
g = Synth(\filter, [\out, 0, \in, 4, \freq, 600]) //The filter takes the noise from channel 4, filters it, and sends the result through channel 0 (out left).
f.free; g.free

//ORDER OF EXECUTION: we need to indicate that the noise goes to the top of the group (head) and the filter to the bottom (tail). This is done by indicating the target argument ("s" in our case, refering to the server - and by default, to the default group (we may use any node ID to specify the target) - and specifying in the addAction argument where each synth goes: 'addToHead' is the default action in all Synths; 'addToTail' allows us to precise the order of execution:
f = Synth(\noise, [\out, 4], s, \addToHead) //Does not produce sound: sends the noise to the filter.
g = Synth(\filter, [\out, 0, \in, 4, \freq, 600], s, \addToTail) //Does produce sound: sends the filtered noise out.
s.scope //Visualize the signal now.
//Review again the node tree to check the change.
f.free; g.free //Free both synths.

//These two Synths can be evaluated at the same time (never the SynthDef and the Synth though), but they need parenthesis and a semicolon between them:
(
f = Synth(\noise, [\out, 4], s, \addToHead);
g = Synth(\filter, [\out, 0, \in, 4, \freq, 600], s, \addToTail)
)
f.free; g.free

//The order of execution is a crucial matter in SuperCollider, especially when creating synths (or groups) that interact with each other. Possibilities for the addAction argument of Synths and Groups are varied, apart from the two we alredy saw: \addToHead (default, head of the target group), \addToTail (tail of the target group), \addAfter (immediately after the target’s node), \addBefore (immediately before the target’s node), or \addReplace (replacing the target’s node). For adding to head or tail, the target must be a group (or the server). The easiest way to approach this is to test and check the node tree. There are also methods to be applied to the Synth class for each addAction (for instance, Synth.tail or Synth.after).
//More on this very important matter in here: https://depts.washington.edu/dxscdoc/Help/Guides/Order-of-execution.html


//Instead of hard-routing the in and out signals, we may use the object Bus to create the virtual channels for each signal. This is more efficient in cases with a greater complexity of interconnection between different SynthDefs, or when mixing different audio interfaces that might not share the same number of inputs and outputs. Let's briefly demonstrate this applied to the previous example:
(
SynthDef(\noise,
	{ |out|
		Out.ar(out, BrownNoise.ar)
}).add;
SynthDef(\filter,
	{ |out, in, freq|
		var input, signal;

		input = In.ar(in, 1);
		signal = BPF.ar(input, freq, 0.01, 0.5);
		Out.ar(out, signal)
}).add;

~firstBus = Bus.audio(s, 1) //The object Bus handles the allocation of buses for us. Its arguments are the server and the number of channels. We can use current environment variables for a more precise interconnection. The Bus object will always choose the lowest available bus that does not conflict with hardware buses (therefore, it will only choose private channels). When creating multichannel signals (stereo onwards), Bus will reserver as many adjacent bus indexes as needed (there is no such thing as "multichannel bus" in SC).
)
~firstBus.index //Returns the bus index, although this is also indicated in the post window when the Bus is created.

(
f = Synth(\noise, [\out, ~firstBus], s, \addToHead); //Now, instead of refering to a hard-coded index, we can let the object Bus create the virtual channel for us.
g = Synth(\filter, [\out, 0, \in, ~firstBus, \freq, 600], s, \addToTail)
)
f.free; g.free; h.free //The Bus object needs to be freed as well.

//You can come back to this link: https://doc.sccode.org/Tutorials/Getting-Started/11-Busses.html, from "Creating a Bus Object" to continue detailing this.


/////////////////////////////////////////////////////////////////////
//POSSIBLE APPLICATIONS OF IN.KR

//We can track values that are constantly changing and keep a specific one to use later on: for example, it is useful to fix values from amplitude or frequency trackers and save them in a control channel (this can also be done without the In UGen, as the previously-mentioned tutorial shows at the end, and as will be shown in the theory file 6.2). This is possible because of the fact that, unlike audio rate busses, control rate busses hold their last value until something new is written in them.

//In this example, 4 SynthDefs are created: a sine wave (at audio rate), and three kinds of frequency modulators (another sine wave, a sawtooth wave and an LFDNoise, at control rate). These will be evaluated at the same time (the program will read them from top to bottom in fact, although the order of execution is not important when using .kr, a control structure):

(
SynthDef(
	\sine,
	{ |in, amp = 0.1|
		var input, signal;

		input = In.kr(in, 1);
		signal = SinOsc.ar(input * [1, 1.1], 0, amp); //The array will create a slight freq deviation (and the subsequent stereo signal).
		Out.ar(0, signal)
}).add;
SynthDef(
	\controlSine,
	{ |out = 0, freq = 1|
		var signal;

		signal = SinOsc.kr(freq, 0, 500, 1000);
		Out.kr(out, signal)
}).add;
SynthDef(
	\controlSaw,
	{ |out = 1, freq = 1|
		var signal;

		signal = LFSaw.kr(freq, 0, 500, 1000);
		Out.kr(out, signal)
}).add;
SynthDef(
	\controlNoise,
	{ |out = 2, freq = 1|
		var signal;

		signal = LFDNoise3.kr(freq, 500, 1000);
		Out.kr(out, signal)
}).add;
)

a = Synth(\sine, [\in, 0, \amp, 0.1]) //This runs the sine wave, and listens to the control channel 0, but there is nothing there yet.

b = Synth(\controlSine, [\out, 0, \freq, 1]) //Now we hear the sine wave being controlled by the control sine wave (the sine wave listens to control 0 (in), and control sine wave goes out through control 0, thus we don't hear the static sine way, but its modulation. Now, if we stop the modulation and evaluate "a" again, the last value where we stopped the modulation will be still there, as it is stored in the control channel.
b.free //When freeing "b", the control channel (in = 0) holds the static sine wave.
a.free //When freeing "a", the sine wave is silenced, but the information about the last value is still in the control channel 0, so "a" will recover it anyway if evaluated again listening to that channel.

c = Synth(\controlSaw, [\out, 1, \freq, 1]) //We can evaluate "a" and "c", then set in = 1 to "a" in order to hear the modulation of the Saw wave (out = 1):
a.set(\in, 1)
c.free //When freeing "c", the last value will be tracked and frozen in control channel 1 (in = 1).
a.free //Same as before:
a = Synth(\sine, [\in, 1, \amp, 0.1]) //"a" still holds the last value of the modulation produced in "c".

d = Synth(\controlNoise, [\out, 2, \freq, 1]) //We can evaluate "a" and "d", then set in = 2 to "a" in order to hear the LFDNoise modulation (out = 2):
a.set(\in, 2)
d.free //The control channel (in = 2) holds the last frequency from the modulation produced in "d".
a.free //Same as before:
a = Synth(\sine, [\in, 2, \amp, 0.1]) //"a" still holds the last value of the modulation produced in "d".

//Now there are three frequencies stored in control channels:
a = Synth(\sine, [\in, 0, \amp, 0.1]) //Here, "a" will hear the frequency stored in channel 0.
a.set(\in, 1) //Here directly switching to channel 1.
a.set(\in, 2) //Lastly, channel 2.
a.free //Freeing "a" and stopping the sound.


//With .choose it is possible to choose between the three modulation options (we need to evaluate b, c and d before):
(
a = Synth(\sine, [\in, [0, 1, 2].choose, \amp, 0.1]);
b = Synth(\controlSine, [\out, 0, \freq, 1]);
c = Synth(\controlSaw, [\out, 1, \freq, 1]);
d = Synth(\controlNoise, [\out, 2, \freq, 1])
)

a.set(\in, [0, 1, 2].choose) //Once the previous block is evaluated, the modulation can be randomly changed setting a different "in" value to "a").

//Switch everything off (remember that the tracked frequencies will remain there though!):
a.free; b.free; c.free; d.free


/////////////////////////////////////////////////////////////////////
//SENDING ARRAYS AS ARGUMENTS

//We can send an array to the argument of a SynthDef by using an array of literals. This kind of array is preceded by a #. It is created at compile time and can't be altered at run time. This is, once again, why we can't modify its size once the SynthDef is compiled (more information can be found in the "Arrays" chapter of this link: https://doc.sccode.org/Reference/Literals.html):
(
SynthDef(
	\bank,
	{ arg freq = #[0, 0]; //We write an array as the argument using # and a fixed number of elements (their value here is not meaningful, they are dummy values):

		var signal;

		signal = SinOsc.ar(freq, 0, 0.1);
		Out.ar(0, signal)
}).add
)

j = Synth(\bank, [\freq, [1000, 1001]]) //Now we can send two frequency values at the same time, each one of them will go through one channel. Be careful with the sum of amplitudes.
s.scope //You can see them here.
j.free

//An example with four values: four frequencies require multichannel expansion (Mix) unless we have four speakers (and four audio bus outputs):
(
SynthDef(
	\bank,
	{ arg freq = #[0, 0, 0, 0];

		var signal;

		signal = Mix(SinOsc.ar(freq, 0, 0.3/4)); //The amplitude is divided by the 4 sine waves in order to compensate.
		Out.ar(0, signal)
}).add
)

k = Synth(\bank, [\freq, { exprand(500, 4000) } !4]) //Now we have four different pitches (different ones each time the Synth is run).
k.free


/////////////////////////////////////////////////////////////////////
//RANDOMNESS AND CHOICE WITHIN A SYNTHDEF

//Apart from ExpRand and Rand instead of their "method" version (client side), other methods for randomness and choice cannot be used within a SynthDef unless they can be run like a UGen if we want them to have a flexible value. Some of those methods we need an alternative for are: .scramble and .choose:

//TCHOOSE (can be used for .choose): it chooses a value each time it receives a trigger. It is placed within the parameter whose values we want to choose randomly among. Arguments: trigger (an impulse is commonly used), and the array of values between which we want to choose. It is used at control rate (.kr), both TChoose and the UGen used for its trigger argument. In the following example, it is applied to the frequency of a sine wave:
(
{
	SinOsc.ar(
		TChoose.kr(Impulse.kr(1),[440, 880, 1760]).lag(0.3), //.lag creates sort of a gliss between each value (interpolation).
		0,
		0.1 !2
	)
}.play
)

//SELECT (can be used for .scramble, or .choose): it includes an argument "which" (the index of the element we want from the given array, which can be random for .scramble, for instance) and the array of signals (Select always expect signals as inputs in its array of options):
(
a = (
	{ arg which = 0; //Signal to choose by default, see the options below this function:

		Select.ar(which,
			[
				SinOsc.ar(440, 0, 0.1),
				Saw.ar(150, 0.1),
				Dust.ar(7, 0.1)
		] )
	}.play
)
)

//The sound by default is index 0, then without freeing the synth, we can change the index, and hence the signal:
a.set(\which, 1) //Next signal.
a.set(\which, 2) //Next signal.
a.set(\which, 0) //Back to the original.
a.set(\which, {rrand(0, 2)}) //Random choice.

//It is necessary to reflect on which processes should be carried out within the SynthDef and which are to be done on the client side. Regarding randomness, a solution might be to carry out the random choice within the Synth (client) in order not to fix the randomness:

SynthDef(\chance, { [1, 2, 3, 4].choose.poll; Out.ar(0, DC.ar) }).add //Silent SynthDef, just to test (DC.ar's argument "in" is a constant amplitude signal: by default is 0, so it will output silence): .choose is an operation happening only in the language, so there is only an initial choice when the language is interpreted, and that choice is compiled (all instances of the SynthDef will carry the same value).
Synth(\chance) //All instances feature the same value unless the SynthDef is compiled again.

//(Here is an example of the use of DC for testing porpuses, this time with a simpler signal):
{ LFDNoise3.ar.scope; DC.ar }.play

//The solution in the previous case is to carry out the random choice in the language (through an argument):
SynthDef(\chance, { arg chance; chance.poll(5); Out.ar(0, DC.ar) }).add
x = Synth(\chance, [\chance, 2]) //Get the synth running.
x.set(\chance, [1, 2, 3, 4].choose) //Set a different value for the created SynthDef instance "x" (execute several times while running).

y = Synth(\chance, [\chance, 1]) //Other instances can be created (in different variables).
y.set(\chance, [5, 6, 7, 8].choose)

x.free //Different instances can be freed separately.
y.free

//Message style might be easier to use over object syle for addressing nodes in real time:
s.sendMsg(\s_new, \chance, 1011, 1, 1) //Addressing a specific node with \s_new, "new synth" (if evaluated twice, an error will be returned about not being able to overwrite the already-existing node).
s.sendMsg(\n_set, 1011, \chance, 1) //New values can be assigned at running time with \n_set, "set node".
s.sendMsg(\n_free, 1011) //Free the synth with \n_free, "free node".

//Let's study the message style in more detail:


/////////////////////////////////////////////////////////////////////
//MESSAGE STYLE VS OBJECT STYLE

//This is only useful when planning to use the server from a different machine, or in case the synthesis is performed in SC, and then a different software is going to play around with whatever is created throuhg SC.
//All the information is in the help file "Server Command Reference": all commands and information about the arquitecture of groups and server overall.

//These are the two grammars for the Synth, in message and object style, respectively:
s.sendMsg //This method sends OSC messages to the server.
s.sendMsg(\s_new, \synthDefName, s.nextNodeID, 1, 1, \listOfArgs, values); //Message style: new synth's name, identifier (nextNodeID), position in the group (1 = addToTail), and group (1 = default). Thus, the entire message style syntax is WHAT (what is created and from which SynthDef), WHERE (nodeID, position, group), and HOW (argument-value pairs).

Synth(\synthDefName, [\listOfArgs, values], target, action); //Object style as studied before.


/////////////////////////////////////////////////////////////////////
//CREATING NEW GROUPS

//We can also use different groups to manage the order of execution of different synths. Let's see how this would be done in our previous example:
(
SynthDef(\noise,
	{ |out|
		Out.ar(out, BrownNoise.ar)
}).add;
SynthDef(\filter,
	{ |out, in, freq|
		var input, signal;

		input = In.ar(in, 1);
		signal = BPF.ar(input, freq, 0.01, 0.5);
		Out.ar(out, signal)
}).add;

~source = Group.new; //We create a group for the source sound (synthesis). It is created at the head by default.
~fx = Group.tail; //The group for the effect (filter, fx) is created at the tail. We could use something like "~fx = Group.after(~source)" as well.

~firstBus = Bus.audio(s, 1)
)

//Execute the Synths and show the node tree to see how the groups are created:
(
f = Synth(\noise, [\out, ~firstBus], ~source); //The group of each synth is specified in the target argument.
g = Synth(\filter, [\out, 0, \in, ~firstBus, \freq, 600], ~fx) //With an addAction, we could further specify the position of the Synth within its particular group, but in this case, there is only one.
)

~source.free; ~fx.free; h.free //Freeing the groups is enough to free the synths within them (check the node tree again).

//With the Group object, we can also indicate the target and addAction, just like in a Synth:
Group.new(s, 'addToTail') //For instance. The number obtained in the post window would replace the 1 in the message style, if using it. NodeIDs over 1000 are sort of a historical convention for naming nodes in SuperCollider.

//Groups can also be used to address all nodes within them at the same time:
~source.set(\amp, 0.01) //For instance, to change the amplitude of all nodes in the source group at the same time and at running time.
~source.freeAll //We can also free all nodes within the group at the same time.

//New groups can be also created in message style:
s.sendMsg(\g_new, 2, 1, 1) //Creating a new group in message style (message (create new group), nodeID (don't overwrite 0 or 1), position (1 = tail), location (1 = default group): "create a new group with nodeID of 2, at the tail of the group 1". All new groups should be inside group 1 (or inside a group that in inside group 1 eventually) so that all primitive functions in group 0 can apply to them).
s.queryAllNodes //This method allow us to print the node tree in the post-window (also with ctrl + T). See the new architecture of the server after creating the previous group.
s.plotTree //The node tree has a graphical representation too (just like using the option in the Server menu).
s.sendMsg(\n_set, 2, \amp, 0.01) //Messages can be set to the whole group so that all nodes and inner groups receive a new value, for example, here an amplitude value. It is also advisable, for this reason, to keep a certain cosistency regarding the name of certain common arguments (freq, amp, masterVolume, pan, etc.), so that all Synths within a group are addressed at the same time.
s.sendMsg(\n_free, 2) //Synths and groups need to be freed by sending the message \n_free (remember that ctrl-period will erase all the architecture created in the server).

//More on this topic in the following links:
//https://doc.sccode.org/Tutorials/Getting-Started/12-Groups.html (about groups - tutorial).
//https://doc.sccode.org/Classes/Group.html (about groups - help file).
//https://doc.sccode.org/Reference/Server-Command-Reference.html (all information about message style commands).


//##############################################################
//Additional commands for networking OSC messages between SC and some other software:
NetAddr.langPort //NetAddr creates a new network address: .langPort gets the port sclang is currently listening on.
NetAddr.localAddr //.localAddr gets a NetAddr corresponding to the localhost and the port sclang is listening on.
Server.local.addr //To connect NetAddr with the server.
