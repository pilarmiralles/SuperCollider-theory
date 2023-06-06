//6 - SYNTHDEF, OUT.AR, IN.AR
////////////////////////////////
//This tutorial might be super helpful to get started with this: https://doc.sccode.org/Tutorials/Getting-Started/10-SynthDefs-and-Synths.html

//The primary and more flexible procedure for producing sound consists of creating a SynthDef and then executing it by calling a specific instance of it (a synth). If SynthDef is the recipe, Synth is its execution. For instance, Function.play creates a SynthDef automatically, which is only convenient for shorter examples and quick testing.

/* The SynthDef class creates synthesis instruments. It defines:
1 - An interconnection between signals (UGens).
2 - The in and out audio (or control) signals (a metasignal).
3 - The arguments that allow the instrument (interconnection of signals) to be controlled from outside the instrument (from the client-side).
4 - Its two fundamental parts (arguments) are: a name, and a function:
*/

SynthDef(name, ugenGraphFunc) //This is a SynthDef: "name" should be defined as a \symbol (or 'symbol'), which will allow us to call the SynthDef from any part of the code thanks to the identity properties of symbols / "ugenGraphFunc" is a function that will be evaluated just once, when the SynthDef is compiled. Once the graph is built (the SynthDef is compiled), the architecture of the graph (the interconnections between the signals or UGens) is fixed. The SynthDef is compiled sending the message .add to it, which compiles the SynthDef (or, according to the help file, it adds the SynthDef to the SynthDescLib, and sends it to the library's servers. No defFile is writtem, all operations take place in memory).
//Structure of the SynthDef (.new can be omitted). Function.play represents a similar process automatically (it also builds a synth in the audio server):

(//When evaluated, we obtain "a SynthDef".
SynthDef.new(
	\whateverName,
	{

	}
).add
)

//Example featuring a name, arguments, variables, a signal and the UGen Out.ar. If we want the SynthDef to output a signal, then we need an output UGen, for which the most simple one is Out: its areguments are "bus", the out channel, which should be between 0 and 3 in order not to use the private channels (and being an out channel, preferably 0 or 1), and "channelsArray", which is the signal out (or array of signals out) - See everything about the UGen Out down below. It includes the message .add, but it does not sound: this is just the compiled instrument. Later on, we need to "play" the instrument using a Synth:

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

//In order to play the instrument and obtain sound, we need to create a Synth (Synth.new), the client-side representation of a single sound producing object (synth), which calls the SynthDef through its name and modifies its arguments, which are called using symbols as well. Notice that it is not possible to evaluate the SynthDef and the Synth at the same time because it takes a certain time for the server to decode the text into its own language (our writing --> Byte-code: we can apply the method .asBytes.asCompileString at the end of a SynthDef to see in the postwindow these numbers that the server understands. The Byte-code is something in between our language and the binary code).

Synth(\sineWave, [\out, 0, \freq, 1000, \phase, 0, \amp, 0.1]) //Out = 0 goes to the left side by default / Out = 1 goes to right side by default.
Synth(\sineWave, [\out, 0, \freq, Array.fill(50, {exprand(100, 3000)}).choose, \phase, 0, \amp, 0.1]) //The order of the arguments is not important because we are calling them by their names (similar to using keyword assignment). Here using a random frequency.

//In summary, according to the Help file of Synth: "A Synth is the client-side representation of a synth node on the server. A Synth represents a single sound producing unit. What it does is defined in a SynthDef, which specifies what UGens are used and how they are patched together. It also specifies what inputs and outputs the Synth will have. A SynthDef is thus a kind of fixed pattern, upon which Synths are be based".

//Due to the fact that the UGen graph is fixed, once we compile the SynthDef with .add, randomness and other changeable methods need their UGen version in order to variate their output values once the SynthDef is running in the server. For instance, if working with rrand or exprand (lower-case letters), the random values will be the same as in the previous evaluation everytime we run the synth (we would need to run - compile - the entire SynthDef again in order to obtain new values). As an alternative, we can use the classes Rand and ExpRand (see at the end of this document a more complete explanation of randomness and choice when using SynthDefs):

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
//The Synth is already part of the client and not of the server. Therefore, if a method such as exprand or rrand needs to be used in the Synth, it does not need to run in the server as a UGen.

//IMPORTANT: it is not possible to change the size of any kind of array within the SynthDef once it is compiled (for example, sending it as an argument from the Synth). Therefore, it is not possible to apply any kind of operation through an argument to the size of an array.
//The arguments are most usually fed with numbers.

//Another example of SynthDef and Synth ("instrument" and "score"):
(
SynthDef(
	\filters,
	{
		var noise, signal;

		noise = WhiteNoise.ar(0.0001);

		signal = Array.fill(18, { Ringz.ar(noise, ExpRand(100, 3000)) }); //Think about the differences between duplicating the Ringz 18 times and creating 18 different random frequencies within the Ringz (applying the array to ExpRand), in terms of multichannel expansion: in this case, as the noise is shared through a variable, the result would be the same.
		signal = Mix(signal);
		signal = Pan2.ar(signal, 0);

		Out.ar(0, signal)
}).add
)

Synth(\filters) //SynthDef is evaluated once, then each evaluation of the Synth will create a new version of the filter due to the randomness of the function within the SynthDef. Some ideas for arguments that could be controlled from the outside (which is the point of an instrument): the amplitude, the panning, the upper and lower limites of the ExpRand frequency values, etc. (Try to do send these arguments as an exercise).

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//The UGen Out sends out the signals created within the function of SynthDef: "bus" is the index in the channels array from which the signals will be sent out / "channelsArray" it's a mono signal or array of signals (when more than one):
Out.ar(bus, channelsArray) //For audio signals.
Out.kr(bus, channelsArray) //For control signals.

//Some examples:
Out.ar(0, SinOsc.ar) //The sine wave will be sent to the channel 0 (left out).
Out.ar(0, SinOsc.ar !2) //This way, the signal will be stereo (it creates an array of two sine waves, thus, it sends them to channels 0 and 1).
Out.ar(0, SinOsc.ar !8) //Eight channels (if not using 8 loudspeakers, we will only be able to hear the two first channels).
Out.kr(100, SinOsc.kr) //Using control channels (not so usual now).


//DONEACTION: doneAction may appear in all UGens that, despite they might stop sounding they still run in the server (for instance, any envelope). The argument doneAction has different values (see help document): the one explained here is doneAction: 2 (using the keyword assignment for this argument because it might be the last one out of a long list of arguments in a UGen). When doneAction = 2, if a zero is sent to the gate of the envelope, for instance, the envelope will stop running in the server (the synth will be killed). This will prevent the accumulation of nodes (events running in the server) at the same time and reduce the CPU percentage. It will be quite important when creating algorithmic routines (see document 10).

//Example: when the envelope disappears, the synthesizer stops running in the server (you can check the status bar below: s = number of synths running in the server, when interpreting out Synth, it will increase and then, when closing the gate, it will decrease --> If doneAction: 0, then the synth will stay there until we press ctrl + .).
(
SynthDef(
	\sineGate,
	{|out, freq, amp, gate = 1|
		var signal, env;

		env = EnvGen.ar(
			Env.adsr(0.01, 0.1, 0.3, 3, 1),
			gate,
			doneAction: 2 //The argument doneAction in EnvGen, using the keyword assignment.
		);

		signal = SinOsc.ar(freq, 0, amp);

		Out.ar(out, signal * env)
}).add
)

a = Synth(\sineGate, [\out, 0, \freq, 500, \amp, 0.3, \gate, 1]) //Open the gate.
a.set(\gate, 0) //Close the gate, killing the Synth due to doneAction = 2.


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//ARCHITECTURE OF THE AUDIO SERVER:
See in help file -> Client vs Server // Audio server <--> Client (language + interpreter) = SuperCollider application (OSC, Open Sound Control for messages between both sides).
See the diagram about the Sclang in language wrapping, including -> Function (.play) / Synth (.new) / Events and Patterns / s (.sendMsg) //The later one is already included in the OSC message level, while the former ones are at a higher level.
See the document in help about the Buffers, nodeIDs, Groups, etc.

/* MAIN CONCEPTS (partly from the help document, where there are more details):
NODE: A Node is an addressable point in a tree of nodes run by the synth engine. There are two types, Synths and Groups (they are subclasses of Node, and in the node tree, Synths are represented by a white rectangle, and groups are represented by a grey rectangle). The tree defines the order of execution of all nodes. All nodes have an integer ID (nodeID), which allows the communication with the node in order, for instance, to change the value of its arguments, shut it down, ask about its state, etc.

GROUP: A Group is a collection of Nodes represented as a linked list (that is to say, set in a specific order). A new Node may be added to the head or tail of the group. The Nodes within a Group may be controlled together. The Nodes in a Group may be both Synths and other Groups. There is a top level group with an ID of zero that defines the root of the tree. When the server is booted from within sclang, a 'default group' with an ID of 1, which is the default target for all new Nodes, is created. See RootNode and Default Group for more info.

SYNTH: A Synth is a collection of unit generators that run together (an instrument = an interconnection between signals or UGens). They can be addressed and controlled by commands to the synthesis engine. They read input and write output to global audio and control busses. Their structure is defined by a SynthDef.

NODE TREE: all nodes are placed within the node tree, which defines the order in which they run in the server (from top to bottom: what is heard goes on top of what hears and transforms what is heard). When booting up the server, two groups are automatically created: the root of the tree, RootNode (nodeID = 0), where all the nodes are created within the server / and the default group (nodeID = 1), within the root group where all the new nodes are created by default unless otherwise indicated. Processes like recording, or playing, which affect the entire default group, are created outside the default group, within the root group.

AUDIO BUSSES: Synths send audio signals to each other via a single global array of audio busses (a signal can be sent to a bus, and then that signal can be used as an input to another synth by reading from that bus). Audio busses are indexed by integers beginning by zero. Using busses rather than connecting synths to each other directly allows synths to connect themselves to the community of other synths without having to know anything about them specifically. The lowest numbered busses get written to the audio hardware outputs (0 and 1). Immediately following the output busses are the input busses, read from the audio hardware inputs (2 and 3). The number of bus channels defined as inputs and outputs do not have to match that of the hardware. When the audio server boots, there is a fixed number of audio busses available (s.options.numAudioBusChannels, which gives 128, from which 0-1 are hardware output busses (s.numOutputBusChannels, which is 2), 2-3 are input busses (s.options.numInputChannels, which is 2), 4-127 are "private busses", commonly for internally routing audio signals between synths). The methods for the number of output and input channels reserved by SC can be changed: s.options.numOutputBusChannels = 4, in case, for instance, of using four output channels; but the audio server needs a reboot so these changes take effect. s.meter will change the number of channels shown in consequence. According to this help file (https://doc.sccode.org/Classes/ServerOptions.html), it is possible to create different instances of server options, and then change the parameters.

CONTROL BUSSES: Synths can send control signals to each other via a single global array of control busses. Busses are indexed by integers beginning by zero.

BUFFERS: Buffers are arrays of 32 bit floating point values with a small descriptive header. Buffers are stored in a single global array indexed by integers beginning by zero. Buffers may be safely allocated, loaded and freed while synthesis is running, even while unit generators are using them. Buffers are used for wave tables, sample buffers, delay lines, envelopes, or for any other need which can use an array of floating point values. Sound files may be loaded into or written from buffers.

UNIT GENERATOR DEFINITIONS: Unit Generator Definitions are plug-ins loaded automatically when the program starts. They are binary code libraries that are used as building blocks by Synths to build synthesis algorithms. Unit Generator Definitions have names that match the names of SuperCollider language classes used in building Synth Definitions.
*/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//IN.AR: In is the UGen that reads the signals located in the audio and control channels. These signals are produced by synths or by the hardware inputs. In and Out UGens will allow us to route signals between several SynthDefs. Separating synthesis and processing procedures into different SynthDefs can allow us to control all links of the synthesis chain.

In.ar(bus, numChannels) //For audio channels.
In.kr(bus, numChannels) //For control channels.

//Regarding the arguments: "bus" is the index of the channels from which In will read the signals / "numChannels" is the number of channels to read from the indicated index. For example:
In.ar(0, 1) //From channel 0, it will read 1 channel.
In.ar(30, 2) //From channel 30, it will read 2 channels (30 and 31).
In.ar(40, 10) //From channel 40, it will read 10 channels (40 to 49).

(//Example of SynthDef using In and Out: producing a noise and filtering:
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

//WHY THIS DOES NOT SOUND? --> See the node tree: the filter is above the noise, hence we need to flip them in order to hear the noise (noise = what sounds / filter = listens to the noise):
a = Synth(\noise, [\out, 4,]) //The noise is sent to channel 4, a private channel (thus, it does not sound).
b = Synth(\filter, [\out, 0, \in, 4, \freq, 600]) //The filter takes the noise from channel 4, filters it, and sends the result through channel 0 (out left).

//Here is the correct version: we need to indicate that the noise should be on top (head) of the filter (tail). 'addToHead' is the message by default in all Synths. We tell this to "s", which is the audio server of SuperCollider:

a = Synth(\noise, [\out, 4], s, \addToHead)
b = Synth(\filter, [\out, 0, \in, 4, \freq, 600], s, \addToTail)
s.scope //Visualize the signal now.
//Review again the node tree to check the change.

//These two Synths can be evaluated at the same time (never the SynthDef and the Synth though), but they need parenthesis and a semicolon between them:

(
a = Synth(\noise, [\out, 4], s, \addToHead);
b = Synth(\filter, [\out, 0, \in, 4, \freq, 600], s, \addToTail)
)

//At the end of this document, an alternative to this is given based on the creation of different groups in the node tree (one for systhesis or \noise, the other for processing or \filter, in the previous case).

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//When mixing different audio interfaces that might not share the same number of inputs and outputs, indicating the busses with integers (in In/Out relationships when using private channels to share signals) might be problematic because of the necessity of adjusting numbers. The class Bus allows SC to handle the allocation of busses for you:
~reverbBus = Bus.audio(s, 1) //Creating a reference to an audio bus (local server "s", and 1 channel) and storing the result in a global variable. You can see the bus index when evaluating the expression: SC will always choose the lowest available bus that does not conflict with hardware busses (therefore, only private busses). Here, by default, we have 2 output channels and 2 input channels, to the next available spot is index 4.
~reverbBus.index //Returns the bus index.

//Now in any system with In/Out connections (having assigned the Bus class to a variable before the SynthDef), ~reverbBus can replace the integer assigned to In/Out without thinking about which bus to use (the method .index is not necessary since Synth will interpret any Bus UGen as an index automatically). Remember that this bus number correspond to the private channel we use to communicate two or more SynthDefs through In/Out classes, but the sound needs to come out through one of the hardware outputs (normally 0, 1).
//When receiving a multichannel signal (stereo onwards), Bus will reserve as many adjacent bus indexes as needed instead of creating a "multichannel bus", which in SC does not exist.
//There is a useful tutorial on this in here: https://doc.sccode.org/Tutorials/Getting-Started/11-Busses.html. It includes an example on how to interconnect up to three SynthDefs and how to apply the UGen Bus.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//POSSIBLE APPLICATIONS OF IN.KR: we can track values that are constantly changing and keep a specific one to use later on: for example, it is useful to fix values from amplitude or frequency trackers and save them in a control channel (this can also be done without the In UGen, as the previously-mentioned tutorial shows at the end). This is possible because of the fact that, unlike audio rate busses, control rate busses hold their last value until something new is written.

//In this example, 4 SynthDefs are created: a sine wave (at audio rate), and three kinds of frequency modulators (another sine wave, a sawtooth wave and an LFDNoise, at control rate). These will be evaluated at the same time (the program will read them from top to bottom in fact, but the order of execution is not important when using .kr, a control structure:

(
SynthDef(
	\sine,
	{| in, amp = 0.1 |
		var input, signal;

		input = In.kr(in, 1);
		signal = SinOsc.ar(input * [1, 1.1], 0, amp); //The array will create a slight freq deviation (and the subsequent two signals).
		Out.ar(0, signal)
}).add;
SynthDef(
	\controlSine,
	{| out = 0, freq = 1 |
		var signal;

		signal = SinOsc.kr(freq, 0, 500, 1000);
		Out.kr(out, signal)
}).add;
SynthDef(
	\controlSaw,
	{| out = 1, freq = 1 |
		var signal;

		signal = LFSaw.kr(freq, 0, 500, 1000);
		Out.kr(out, signal)
}).add;
SynthDef(
	\controlNoise,
	{| out = 2, freq = 1 |
		var signal;

		signal = LFDNoise3.kr(freq, 500, 1000);
		Out.kr(out, signal)
}).add;
)

a = Synth(\sine, [\in, 0, \amp, 0.1]) //This runs the sine wave, and listens to the control channel 0, but there is nothing there yet.

b = Synth(\controlSine, [\out, 0, \freq, 1]) //Now we hear the sine wave being controlled by the control sine wave (the sine wave listens to control 0 (in), and control sine wave goes out through control 0, thus we don't hear the static sine way, but its modulation. Now, if we stop the modulation and evaluate "a" again, the last value where we stopped the modulation will be still there, sounding as a static sine wave, as that is the signal of that SynthDef.

c = Synth(\controlSaw, [\out, 1, \freq, 1]) //We can evaluate "a" and "c", then set in = 1 to "a" in order to hear the modulation of the Saw wave (out = 1).
a.set(\in, 1)
a = Synth(\sine, [\in, 1, \amp, 0.1]) //When stopping the modulation, the new frequency from channel 1 is tracked (in = 1).

d = Synth(\controlNoise, [\out, 2, \freq, 1]) //We can evaluate "a" and "d", then set in = 2 to "a" in order to hear the LFDNoise modulation (out = 2).
a.set(\in, 2)
a = Synth(\sine, [\in, 2, \amp, 0.1]) //When stopping the modulation, the new frequency from channel 2 is tracked (in = 2).

//With .choose it is possible to choose between the three modulation options (we need to evaluate b, c and d before):

(
a = Synth(\sine, [\in, [0, 1, 2].choose, \amp, 0.1]);
b = Synth(\controlSine, [\out, 0, \freq, 1]);
c = Synth(\controlSaw, [\out, 1, \freq, 1]);
d = Synth(\controlNoise, [\out, 2, \freq, 1])
)

a.set(\in, [0, 1, 2].choose) //Once the previous block is evaluated, the modulation can be randomly changed setting a different "in" to "a").

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SENDING ARRAYS AS ARGUMENTS: we can send an array to the argument of a SynthDef by using an array of literals. This kind of array is preceded by a #. It is created at compile time and can't be altered at run time. This is, once again, why we can't modify its size once the SynthDef is compiled (more information can be found in the "Arrays" chapter of this link: https://doc.sccode.org/Reference/Literals.html):
(
SynthDef(
	\bank,
	{ arg freq = #[0, 0]; //We write an array as the argument using # and a fixed number of elements (their value here is not meaningful, they are dummy values):

		var signal;

		signal = SinOsc.ar(freq, 0, 0.1);
		Out.ar(0, signal)
}).add
)

Synth(\bank, [\freq, [1000, 1001]]) //Now we can send two frequency values at the same time, each one of them will go through one channel. Be careful with the sum of amplitudes.
s.scope //You can see them here.

//An example with four values: four frequencies require multichannel expansion (Mix) unless we have four speakers:
(
SynthDef(
	\bank,
	{ arg freq = #[0, 0, 0, 0];

		var signal;

		signal = Mix(SinOsc.ar(freq, 0, 0.3/4)); //The amplitude is divided into the 4 sine waves in order to compensate.
		Out.ar(0, signal)
}).add
)

Synth(\bank, [\freq, { exprand(500, 4000) } !4]) //Now we have four different pitches (different ones each time the Synth is run).

/////////////////////////////////////////////////////////////////////////////////////
//RANDOMNESS AND CHOICE WITHIN A SYNTHDEF:

//Apart from ExpRand and Rand instead of their "method" version, other methods for randomness and choice cannot be used within a SynthDef unless they can be run like a UGen.
//Some of those methods we need an alternative for are: .scramble and .choose:

//TCHOOSE ( = .choose): it chooses a value each time it receives a trigger. It is placed within the parameter whose values we want to choose randomly among. Arguments: trigger (an impulse is commonly used), and the array of values between which we want to choose. It is used at control rate (.kr), both TChoose and the UGen used for its trigger argument.
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

//SELECT (can be used for .scramble, or .choose): argument "which" (the index of the element we want from the given array, which can be random for .scramble, for instance) and the array of signals or values.
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

//The sound by default is index 0, then without stopping the synth, we can change the index, and hence the signal:
a.set(\which, 1) //Here, the argument "which" can be changed without stopping the server.
a.set(\which, 2) //Next signal.
a.set(\which, 0) //Back to the original.
a.set(\which, {rrand(0, 2)}) //Random choice.

//It is necessary to reflect on which processes should be carried out within the SynthDef and which are to be done on the client side. Regarding randomness, a solution might be to carry out the random choice within the Synth (client) in order not to fix the randomness:

SynthDef(\chance, { [1, 2, 3, 4].choose.poll; Out.ar(0, DC.ar) }).add //Silent SynthDef, just to test (DC.ar's argument "in" is a constant amplitude signal: by default is 0, so it will output silence): .choose is an operation happening only in the language, so there is only an initial choice when the language is interpreted, and that choice is compiled (all instances of the SynthDef will carry the same value).
Synth(\chance) //All instances feature the same value unless the SynthDef is compiled again.

//The solution in this case is to carry out the random choice in the language (through an argument):
SynthDef(\chance, { arg chance; chance.poll(5); Out.ar(0, DC.ar) }).add
x = Synth(\chance, [\chance, 2]) //Get the synth running.
x.set(\chance, [1, 2, 3, 4].choose) //Set a different value for the created SynthDef instance "x" (execute several times while running).

y = Synth(\chance, [\chance, 1]) //Other instances can be created (in different variables).
y.set(\chance, [5, 6, 7, 8].choose)

x.free //Different instances can be freed separately
y.free

//Message style might be easier to use over object syle for addressing nodes in real time:
s.sendMsg(\s_new, \chance, 1011, 1, 1) //Addressing a specific node with \s_new, "new synth" (if evaluated twice, an error will be returned about not being able to overwrite the already-existing node).
s.sendMsg(\n_set, 1011, \chance, 1) //New values can be assigned at running time with \n_set, "set node".
s.sendMsg(\n_free, 1011) //Free the synth with \n_free, "free node".

//Let's study the message style in more detail:

/////////////////////////////////////////////////
//MESSAGE STYLE VS OBJECT STYLE (SYNTHDEFS):
//This is only useful when planning to use the server from a different machine, or in case the synthesis is performed in SC, and then a different software is going to play around with whatever is created throuhg SC.
//All the information is in the Help Document: Server Command Reference: all commands and information about the arquitecture of groups and server overall.

//Ctrl + T allows you to see in the postwindow all the groups created.

//These are the two grammars for the Synth, in message and object style, respectively:

s.sendMsg //This method sends OSC messages to the server.
s.sendMsg(\s_new, \synthDefName, s.nextNodeID, 1, 1, \listOfArgs, values); //Message style: new synth's name, identifier (nextNodeID), position in the group (1 = addToTail), and group (1 = default). Thus, the entire message style syntax is WHAT (what is created and from which SynthDef), WHERE (nodeID, position, group), and HOW (argument-value pairs).

Synth(\synthDefName, [\listOfArgs, values], target, action); //Object style as studied before: the target is the name of the group (s = default group, 0 = root group, etc.), and action could be 'addToTail' or 'addToHead' (remember, on the top what is heard, on the bottom, what affects what is heard).

Group.new(s, 'addToTail') //to create a new group. Execute it and get the node (if getting 1001, for example, we would need to write 1001 instead of 1 in the message style). NodeIDs over 1000 for synths are kind of a historical convention.
//In fact, when using In/Out relationships between SynthDefs (for example, one for synthesis, one for processing), you can create different groups for each procedure instead of adding the action 'addToTail' / 'addToHead' directly to each Synth.
//For example (from our first In/Out SynthDef relationship in this file):
a = Synth(\noise, [\out, 4], ~noiseGroup)
b = Synth(\filter, [\out, 0, \in, 4, \freq, 600], ~filterGroup)

~noiseGroup = Group.new
~filterGroup = Group.after(~noiseGroup) //Equivalent to 'addToTail': putting filter group after the noise group in the node tree.
//As long as the synths are added to the correct group, there is no need to worry about the order of the synths.
//This is beneficial when, for example, using iteration on a Synth, creating several instances of a Synth in a same group: then, messages can be sent to all synths within the group at the same time like this (for instance):
~noiseGroup.set(\amp, 0.1)
~noiseGroup.freeAll //And turning off all synths within a group at the same time.

//New groups can be also created in message style:
s.sendMsg(\g_new, 2, 1, 1) //Creating a new group through message style (message (create new group), nodeID (don't overwrite 0 or 1), position (1 = tail), location (1 = default group): create a new group with nodeID of 2, at the tail of the group 1. All new groups should be inside group 1 (or inside a group that in inside group 1 eventually) so that all primitive functions in group 0 can apply to them).
s.queryAllNodes //This method allow us to print the node tree in the post-window (also with ctrl + T). See the new architecture of the server after creating the previous group.
s.plotTree //The node tree has a graphical representation too.
//Eventually, we should be able to create different groups for signals and FX or processing, in order to ease the order of execution: https://doc.sccode.org/Guides/Order-of-execution.html.
s.sendMsg(\n_set, 2, \amp, 0) //Messages can be set to the whole group so that all nodes and inner groups receive a new value, for example, here an amplitude value. It is also advisable, for this reason, to keep a certain cosistency regarding the name of certain common arguments (freq, amp, masterVolume, pan, etc.), so that SynthDefs within a group are addressed at the same time.
s.sendMsg(\n_free, 2) //Synths and groups need to be freed by sending the message \n_free instead of using ctrl + period!! (which would clean all nodes at the same time and mess up the architecture of the server).

//More on this topic in the following links:
//https://doc.sccode.org/Tutorials/Getting-Started/12-Groups.html (about groups - tutorial).
//https://doc.sccode.org/Classes/Group.html (about groups - help file).
//https://doc.sccode.org/Reference/Server-Command-Reference.html (all information about message style commands).

//STRUCTURE OF THE SERVER TREE SUMMARY: GROUP, NODE, BUS: the architecture is organized in groups of nodes (points in the server: a node can be a synth or a group of synths). The first node is the Root Group (nodeID = 0): recording, monitoring, and other primitive functions; then the second one is the default group (nodeID = 1), is the user group, inside which the new nodes (synths and groups) are created; then third level comprises all the other groups you can create (from 2 to inf), and so on. The synths and processes need to be organized (from the bottom to the top, which is the one that is heard).
