//6 - SYNTHDEF, OUT.AR, IN.AR
////////////////////////////////

/*The SynthDef class defines synthesis instruments. It defines:
1 - An interconexion between signals (UGens).
2 - The in and out audio (or control) signals (a metasignal).
3 - The arguments that allows the instrument (interconexion of signals) to be controlled from outside the instrument.
4 - Its two fundamental parts (arguments) are: a name, and a function:
*/

SynthDef(name, ugenGraphFunc) //This is SynthDef: "name" should define as a \symbol, the utility or output of the SynthDef (as when naming variables) / "ugenGraphFunc" is a function that will be evaluated just once, when the SynthDef is compiled. Once that the graph is built (the SynthDef is compiled), the architecture of the graph (the interconexions between the signals or UGens) is fixed. The SynthDef is compiled sending it the message .add, then it is sent to the audio server.
//Structure of the SynthDef (no necessary to write .new) - Function.play represents a similar process automatically:

(
SynthDef.new(
	\whateverName,
	{

	}
).add
)

//Example featuring a name, arguments, variable, a signal and the UGen Out.ar: its areguments are "bus", the out channel, which should be between 0 and 3, in order not to use the private channels / and "channelsArray", which is the signal out (or array of signals out) - See everything about the UGen Out down below. It includes the message .add, but it does not sound, this is just the instruments, sent to the audio server. Later on, we need to "play" the instrument:

(
SynthDef(
	\sineWave,
	{arg out, freq, phase, amp;
	var signal;

		signal = SinOsc.ar(freq, phase, amp);
		Out.ar(out, signal)
	}
).add
)

//In order to play the instrument and obtain sound, we need to create a synthesizer (Synth.new), which calls the SynthDef through its name and modifies its arguments, which are called using symbols as well. Notice that it is not possible to evaluate the SynthDef and the Synth at the same time because it takes a certain time for the server to decode the text into its own language (owr writing --> Byte-code: we can apply the method .asBytes.asCompileString at the end of a SynthDef to see in the postwindow these numbers that the server understands).

Synth(\sineWave, [\out, 0, \freq, 1000, \phase, 0, \amp, 0.1]) //Out = 0 goes to the left side by default / Out = 1 goes to right side by default.
Synth(\sineWave, [\out, 0, \freq, exprand(30, 3000), \phase, 0, \amp, 0.1]) //The order of the arguments is not important because we are calling them by their names.

//Due to the fact that the UGen graph is fixed once we compile the SynthDef, randomness and other changeable methods need their UGen version in order to variate once the SynthDef is running in the server. For instance, if working with rrand or exprand as a method (lower-case letters), everytime we run the Synth (we play the instrument), the random values will be the same as the previous evaluation. As an alternative, we can use the classes Rand and ExpRand (see the end of this document for an expanded explanation of randomness and choice within SynthDefs):

(
SynthDef(
	\sineWaveRand,
	{arg out, freq, phase, amp;
	var signal;

		signal = SinOsc.ar(ExpRand(100, 2000), phase, amp);
		Out.ar(out, signal)
	}
).add
)

Synth(\sineWaveRand, [\out, 0, \phase, 0, \amp, 0.1]) //Now the frequency will be different each time the Synth is evaluated.
//The Synth is already part of the client and not of the server, thus if an exprand or rrand needs to be used in the Synth, it does not have to run as a UGen.

//IMPORTANT: it is not possible to change the size of any kind of array within the SynthDef once it is compiled (for example, sending it as an argument from the outside), therefore, it is not possible to apply any kind of modulation or external argument to the size on an array.
//The arguments are most usually fed with numbers.

//Another example of SynthDef and Synth (instrument and performer):
(
SynthDef(
	\filters,
	{
		var noise, signal;

		noise = WhiteNoise.ar(0.0001);

		signal = Array.fill(18, { Ringz.ar(noise, ExpRand (100, 3000)) });
		signal = Mix(signal);
		signal = Pan2.ar(signal, 0);

		Out.ar(0, signal)
}).add
)

Synth(\filters) //SynthDef is evaluated once, then each evaluation of the Synth will create a new version due to the randomness of the function within the SynthDef. Some ideas for arguments that could be controlled from the outside (that is the point of an instrument) are: the amplitude, the panning, the upper and lower limites of the frequency of the ExpRand, etc. (Try to do this as an exercise).

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//The UGen Out sends out the signals produced within the function of SynthDef: "bus" is the index in the channels array from which the signals will be sent out / "channelsArray" it's a mono signal or array of signals:
Out.ar(bus, channelsArray) //For audio signals.
Out.kr(bus, channelsArray) //For control signals.

//Some examples:
Out.ar(0, SinOsc.ar) //The sine wave will be sent to the channel 0.
Out.ar(0, SinOsc.ar !2) //This way, the signal will be stereo (it creates an array of two sine waves, thus, it sends them to channels 0 and 1).
Out.ar(0, SinOsc.ar !8) //Eight channels (if not using 8 loudspeakers, we can only hear two signals).
Out.kr(100, SinOsc.kr) //Using control channels (not so usual now).

//UGens and Synths: we can see the number of UGens and Synthesizers that are currently running in the server in the status bar below the postwindow (0u and 0s, respectively).

//DONEACTION: doneAction may appear in all UGens that, despite they can be stopped (their sound) they still run in the server, for instance, an Envelope adsr. The argument doneAction has different values (see help document): the one explained here is doneAction: 2 (using the keyword assignment for this argument because it might be the last one out of a long list of argument in the UGen). When doneAction = 2, if a zero is sent to the gate of the envelope, the envelope will stop running in the server. This will prevent the accumulation of nodes (events running in the server) at the same time, reduce the CPU percentage and other future application we'll see.

//Example: when the envelope disappears, the synthesizer stops running in the server.
(
SynthDef(
	\sineGate,
	{|out, freq, amp, gate = 1|
		var signal, env;

		env = EnvGen.ar(
			Env.adsr(0.01, 0.1, 0.3, 3, 1),
			gate,
			doneAction: 2 //Here the argument doneAction, using the keyword assignment.
		);

		signal = SinOsc.ar(freq, 0, amp);

		Out.ar(out, signal * env)
}).add
)

a = Synth(\sineGate, [\out, 0, \freq, 500, \amp, 0.3, \gate, 1])
a.set(\gate, 0)



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//ARCHITECTURE OF THE AUDIO SERVER:
See in help file -> Client vs Server // Audio server <--> Client (language + interpreter) = SuperCollider application (OSC, Open Sound Control for messages between both sides).
See the diagram about the Sclang in language wrapping, including -> Function (.play) / Synth (.new) / Events and Patterns / s (.sendMsg) //The later one is already included in the OSC message level, while the former ones are at a higher level.
See the document in help about the Buffers, nodeIDs, Groups, etc.

/* MAIN CONCEPTS:
NODE: A Node is an addressable node in a tree of nodes run by the synth engine. There are two types, Synths and Groups. The tree defines the order of execution of all Synths. All nodes have an integer ID (nodeID), which allows the communication with the node in order, for instance, to change the value of its arguments, shut it down, ask about its state, etc.

GROUP: A Group is a collection of Nodes represented as a linked list. A new Node may be added to the head or tail of the group. The Nodes within a Group may be controlled together. The Nodes in a Group may be both Synths and other Groups. At startup there is a top level group with an ID of zero that defines the root of the tree. If the server was booted from within SCLang (as opposed to from the command line) there will also be a 'default group' with an ID of 1 which is the default target for all new Nodes. See RootNode and Default Group for more info.

SYNTH: A Synth is a collection of unit generators that run together (an instrument = an interconnection between signals or UGens). They can be addressed and controlled by commands to the synthesis engine. They read input and write output to global audio and control buses. Synths can have their own local controls that are set via commands to the server. Their structure is defined by a SynthDef.

NODE TREE: Node tree: all nodes are placed within the node tree, which defines the order in which they run in the server (from top to bottom: what is heard goes on top of what hears and transforms what is heard). When booting up the server, two groups are automatically created: the root of the tree, RootNode (nodeID = 0), where all the nodes are created within the server / and the default group (nodeID = 1), within the root group where all the groups are created by default unless otherwise indicated. Processes like recording, or playing, which affect the entire default group, are created outside the default group, within the root group.

AUDIO BUSES: Synths send audio signals to each other via a single global array of audio buses. Audio buses are indexed by integers beginning with zero. Using buses rather than connecting synths to each other directly allows synths to connect themselves to the community of other synths without having to know anything about them specifically. The lowest numbered buses get written to the audio hardware outputs. Immediately following the output buses are the input buses, read from the audio hardware inputs. The number of bus channels defined as inputs and outputs do not have to match that of the hardware

CONTROL BUSES: Synths can send control signals to each other via a single global array of control buses. Buses are indexed by integers beginning with zero.

BUFFERS: Buffers are arrays of 32 bit floating point values with a small descriptive header. Buffers are stored in a single global array indexed by integers beginning with zero. Buffers may be safely allocated, loaded and freed while synthesis is running, even while unit generators are using them. Buffers are used for wave tables, sample buffers, delay lines, envelopes, or for any other need which can use an array of floating point values. Sound files may be loaded into or written from buffers.

UNIT GENERATOR DEFINITIONS: Unit Generator Definitions are plug-ins loaded automatically when the program starts. They are binary code libraries that are used as building blocks by Synths to build synthesis algorithms. Unit Generator Definitions have names that match the names of SuperCollider language classes used in building Synth Definitions.
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//IN.AR: In is the UGen that reads the signals located in the audio and control channels. These signals are produced by synths or by the hardware inputs.

In.ar(bus, numChannels) //For audio channels.
In.kr(bus, numChannels) //For control channels.

//Regarding the arguments: "bus" is the index of the channels from which In will read the rignals (the ones that are normally used are 2 and 3) / "numChannels" is the number of channels to read from the indicated index. For example:
In.ar(0, 1) //From channel 0, it will read 1 channel.
In.ar(30, 2) //From channel 30, it will read 2 channels (30 and 31).
In.ar(40, 10) //From channel 40, it will read 10 channels (40 to 49).

(//Example of SynthDef using In and Out: producing a noise and filtering:
SynthDef(\noise,
	{| out |
		Out.ar(out, BrownNoise.ar)
}).add;
SynthDef(\filter,
	{| out, in, freq |
		var input, signal;

		input = In.ar(in, 1);
		signal = BPF.ar(input, freq, 0.01, 0.2);
		Out.ar(out, signal)
}).add
)

s.scope //Visualize here what we will try next:

//WHY THIS DOES NOT SOUND? --> See the node tree: the filter is above the noise, thus we need to invert the order, because the noise is what sounds, while the filter listen to the noise.
a = Synth(\noise, [\out, 4,]) //The noise is sent to channel 4, a private channel (thus, it does not sound).
b = Synth(\filter, [\out, 0, \in, 4, \freq, 600]) //The filter takes the noise from channel 4, filters it, and sends the result through channel 0, out.

//Here is the correct version: we need to indicate that the noise should be on top (head) of the filter (tail).
//El problema de que no suene con el filtro es que el propio filtro (el que escucha) queda en el árbol de nodos por encima del ruido (el que es escuchado). We tell this to "s", which is the audio server of SuperCollider:

a = Synth(\noise, [\out, 4], s, \addToHead)
b = Synth(\filter, [\out, 0, \in, 4, \freq, 600], s, \addToTail)
//Review again the node tree to check the change + these two Synths can be evaluated at the same time (never the SynthDef and the Synth), but they need parenthesis and semicolon for that:

(
a = Synth(\noise, [\out, 4], s, \addToHead);
b = Synth(\filter, [\out, 0, \in, 4, \freq, 600], s, \addToTail)
)

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//POSSIBLE APPLICATIONS OF IN.KR: we can track values that are constantly changing and keep a specific one to use later on for something else: for example, it is useful to fix values from amplitude or frequency trackers and save them in a control channel, in order to use it later on.

//In this example, 4 SynthDefs are created: a sine wave, and three kinds of frequency modulators (another sine, a sawtoorh wave and an LFDNoise). These will be evaluated at the same time (the program will read them from top to bottom in fact, but the order of execution is not important when using .kr, a control structure:

(
SynthDef(
	\sine,
	{| in, amp |
		var input, signal;

		input = In.kr(in, 1);
		signal = SinOsc.ar(input * [1, 1.1], 0, amp);
		Out.ar(0, signal)
}).add;
SynthDef(
	\controlSine,
	{| out, freq |
		var signal;

		signal = SinOsc.kr(freq, 0, 500, 1000);
		Out.kr(out, signal)
}).add;
SynthDef(
	\controlSaw,
	{| out, freq |
		var signal;

		signal = LFSaw.kr(freq, 0, 500, 1000);
		Out.kr(out, signal)
}).add;
SynthDef(
	\controlNoise,
	{| out, freq |
		var signal;

		signal = LFDNoise3.kr(freq, 500, 1000);
		Out.kr(out, signal)
}).add;
)

a = Synth(\sine, [\in, 0, \amp, 0.3]) //This runs the sine wave, and listens to the channel 0, but there is nothing there yet.

b = Synth(\controlSine, [\out, 0, \freq, 1]) //Now we here the sine wave being controlled by the control sine wave (sine wave listens to 0, and control sine wave goes in through 0, thus we don't here the static sine way, but its modulation. Now, if we stop the modulation and evaluate "a" again, the last value where we stopped the modulation will be still there, sounding as a static sine wave, as that is the signal of that SynthDef.

c = Synth(\controlSaw, [\out, 1, \freq, 1]) //We can evaluate "a" and "c", then set in = 1 to "a" in order to hear the modulation of the Saw wave (out = 1).
a.set(\in, 1)
a = Synth(\sine, [\in, 1, \amp, 0.3]) //When stopping the modulation, the new frequency from channel 1 is tracked (in = 1).

d = Synth(\controlNoise, [\out, 2, \freq, 1]) //We can evaluate "a" and "d", then set in = 2 to "a" in order to hear the LFDNoise modulation (out = 2).
a.set(\in, 2)
a = Synth(\sine, [\in, 2, \amp, 0.3]) //When stopping the modulation, the new frequency from channel 2 is tracked (in = 2).

//With .choose it is possible to choose between the three modulation options (we need to evaluate b, c and d before)
a = Synth(\sine, [\in, [0, 1, 2].choose, \amp, 0.3])
a.set(\in, [0, 1, 2].choose) //This will make sound one random modulation.

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SENDING ARRAYS AS ARGUMENTS: in a SynthDef, but the number of elements within the array is fixed, as commented before:

(
SynthDef(
	\bank,
	{ arg freq = #[ 0, 0 ]; //We write an array as the argument using # and a fixed number of elements (its value here is not meaningful, they are dummy values):

		var signal;

		signal = SinOsc.ar(freq, 0, 0.3);
		Out.ar(0, signal)
}).add
)

Synth(\bank, [\freq, [1000, 1001]]) //Now we can send two frequency values at the same time, each one of them will go through one channel. Be careful with the sum of amplitudes.
s.scope //You can see them here.

//An example with four values: four frequencies require multichannel expansion (Mix)
(
SynthDef(
	\bank,
	{ arg freq = #[ 0, 0, 0, 0 ];

		var signal;

		signal = Mix(SinOsc.ar(freq, 0, 0.3/4)); //The amplitude is divided into the 4 sine waves in order to compensate.
		Out.ar(0, signal)
}).add
)

Synth(\bank, [\freq, {exprand(500, 4000)} !4]) //Now we have four different pitches.

/////////////////////////////////////////////////////////////////////////////////////
//RANDOMNESS AND CHOICE WITHIN A SYNTHDEF:

//Apart from ExpRand and Rand instead of their "method" versions, other methods for randomness and choice cannot be used within a SynthDef unless they can be running within the server just like a UGen.
//Some of those methods we need an alternative for are: .scramble and .choose:

//TCHOOSE ( = .choose): it chooses a value each time it receives a trigger. It is placed within the parameter amongst whose values we want to change randomly. Arguments: trigger (an impulse is commonly used), and the array of values between which we want to choose. It is used at control rate (.kr), both TChoose and the UGen used for its trigger argument.
//In the following example, it is applied to the frequency of a sine wave:
(
{
	SinOsc.ar(
		TChoose.kr(Impulse.kr(1),[440, 880, 1760]).lag(0.3), //The .lag creates sort of a gliss between each value.
		0,
		0.2 !2
	)
}.play
)

//SELECT (can be used for .scramble, or .choose, etc.): argument "which" (the index of the element we want from the given array, which can be random) and the array of signals or values.
//In the following example, an array of signals is used as input of Select so the synth is directly chosen using this tool:
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

a.set(\which, 1) //Here, the argument "which" can be changed without stopping the server.
a.set(\which, 2) //Next signal.
a.set(\which, 0) //Back to the original.
a.set(\which, {rrand(0, 2)}) //Random choice.

/////////////////////////////////////////////////
//MESSAGE STYLE VS OBJECT STYLE (SYNTHDEFS):
//This is only useful when planning to use the server from a different machine, or in case the synthesis is performed in SC, and then a different softwar is going to play around with whatever is created throuhg SC.
//All the information is in the Help Document: Server Command Reference: all commands and information about the arquitecture of groups and server overall.

//Ctrl + T allows you to see in the postwindow all the groups created.

//These are the two grammars for the Synth, in message and object style, respectively:

s.sendMsg(\s_new, \synthDefName, s.nextNodeID, 1, 1, \listOfArgs, values); //Message style: new synth's name, identifier (nextNodeID), group (1 = default), position in the group (1 = addToTail). Thus, the entire message style grammar is WHAT (\synthDefName), WHERE (nextNodeID, 1, 1002, for example), and HOW (list of all arguments and values).

Synth(\synthDefName, [\listOfArgs, values], target, action); //Object style: the target is the name of the group (s = default group, 0 = root group, etc.), and action could be 'addToTail' or 'addToHead' (remember, on the top what is listened, on the bottom, what affects what is listened).

Group.new(s, 'addToTail') //to create a new group. Execute it and get the node (1001, for example, so just put 1001 instead of 1 in the message style.

//STRUCTURE OF THE SERVER TREE: GROUP, NODE, BUS: the architecture is organized in groups of nodes (points in the server: a node can be a synth or a group of synths). The first node is the Root Group (nodeID = 0): recording or metering work inside that group; then the second one is the default group (nodeID = 1), is the user group, inside which the nodes are created; then third is all the other groups you can create (from 2 to inf), and so on. The synths and processes need to be organized (from the bottom to the top, which is the one that is heard).