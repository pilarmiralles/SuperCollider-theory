//1 - INTRODUCTION TO SUPERCOLLIDER AND DATA TYPES

///////////////////////////////////////////////////////////////////////

//Download the SuperCollider application here: https://supercollider.github.io/downloads.html (current version Dec 2023 SC 3.13 for Mac / Win / Linux)
//SuperCollider plugins (additional unit generators that run on scsynth) and how to install: https://supercollider.github.io/sc3-plugins/
//SuperCollider quarks (packages of classes, extension methods and server UGen plugins) and how to install: https://github.com/supercollider-quarks/quarks

/*
Some useful links:
https://doc.sccode.org/Tutorials/Getting-Started/00-Getting-Started-With-SC.html (wondrous introduction)
https://ccrma.stanford.edu/~ruviaro/texts/A_Gentle_Introduction_To_SuperCollider.pdf (really nice introduction in pdf)
https://doc.sccode.org/Help.html (online SC guide) --> Can be opened from SC with the key combination Ctrl-D
https://scsynth.org/ (new community forum)
https://github.com/madskjeldgaard/awesome-supercollider (tutorials, plugins, quarks and whatnot)
http://sccode.org/ (another forum)
https://github.com/supercollider/supercollider (SuperCollider repo, including links to sources about learning, discussing and contributing)
https://github.com/supercollider/supercollider/wiki/Code-style-guidelines (code style guidelines)
//I have included some extra links for general matters at the very end of this document.

//Some more online articles about how to write clean code:
https://blog.alexdevero.com/6-simple-tips-writing-clean-code/
https://medium.com/coding-skills/clean-code-101-meaningful-names-and-functions-bf450456d90c
https://scsynth.org/t/some-notes-on-writing-supercollider-code-for-non-programmers/1940
*/

//SC is an open source: anyone can contribute with the creation of new plugins, extensions, etc., and with the enhancement of the existing ones, and there is an active and helpful community of users and contributors (https://supercollider.github.io/#community).
//SC is free to use, light on your computer, easy to get some sound out of it.
//There is an overwhelming amount of tools and resources, and different ways of doing the same thing (shortcuts, alternative syntaxes, etc.): stick to the basics, keep consistency, and, after acquiring a solid ground, experiment, seek your own way to attain your objectives, etc.
//The learning curve can be quite exponential (slow at the beginning, faster later on). The order in which things are learnt can be really different from one course to another, from a series of tutorials to another, and this affects how things are understood as many things are intertwined and intermingled.

//OOP
//SC is an OOP (object-oriented programming language), a programming paradigm (specific style or way of programming) based on the concept of "object". All entities in the language are objects. An object contains data about its state and the set of operations that can be performed with the object.
//--> To execute code (that is to say, to compile and run the code. The compiling is done automatically by the interpreter): shift-enter

//Classes:
//A class is an object containing the description of the object's data and operations (like a blueprint). Objects are always instances (versions, realizations) of a class. The name of a class always starts with a capital letter. Classes are themselves objects: they are organized according to a hierarchy in which they inherit implementations (share properties) from the upper class, and which can be seen in the class tree: https://doc.sccode.org/Overviews/ClassTree.html. Observe how all classes branch from a single class called "Object".
CombC //Open the Help file (ctrl + D) and observe how, for instance, CombC comes from CombN --> PureUGen --> UGen --> AbstractFunction --> Object
//More information on classes here: https://doc.sccode.org/Guides/WritingClasses.html
//More inforation about inheritance in the last paragraph of this tutorial: https://doc.sccode.org/Tutorials/Getting-Started/12-Groups.html

//Messages:
//A message is a request for an object (the receiver) to perform one of its operations. The way in which this operation is performed is defined by the object's class. The implementation of the object (its source code) is hidden from the client (we'll talk later about this), being only able to change the object's state by sending messages (the source code can be opened from SC by pressing Ctrl-I on any object). A message consists of a message selector (name of the operation) and, in some cases, a list of arguments (input values) that give additional information about the operation. A message always returns a result (by default, the receiver itself is returned).
//A method is a description of the operations necessary to implement a message for a particular class: they tell how to implement messages sent to the instances of a class. In a class, there is a method definition for each message to which the instances of that class can respond to: when an object is sent a message, the method whose name matches the message selector in the receiver's class is executed. Methods may inquire about some property of the receiver, ask the receiver to change its internal state, or ask the receiver to return some computed value. There are two main types of methods: class methods are sent to class objects to create instance objects of that class; instance methods are sent to an instance object to modify it or inquire information about it.
//A very important feature in SC is "polymorphism": Objects of different classes can respond to the same message in different ways according to their class. This ability for different objects to react differently to the same message is called polymorphism. For example, all objects can understand the message “value”: many will just return themselves, and others such as functions or streams will evaluate themselves and return the result of that evaluation. We'll see examples of this throughout the tutorials. More information here: https://doc.sccode.org/Guides/Polymorphism.html

//As mentioned before, there are usually many different ways to express the same thing in SuperCollider. Each of these ways is a syntax. It is best to keep consistency with the way we write our code. Messages, for instance, can be expressed in many ways:
! @ % & * - + = | < > ? ///As binary operators.
10 rrand: 100 //As binary operations (identifier followed by a colon).
rrand(10, 100) //As functional notation messages.
10.rrand(100) //As receiver notation messages.

/*
LANGUAGE ARCHITECTURE: https://doc.sccode.org/Guides/ClientVsServer.html
SC application is three programs: a text editor, also called IDE (Integrated Development Environment), the language, called sclang (also known as the client app), and the server, which carries out the synthesis and calculation of audio, and which can be scsynth (by default), supernova (used for parallel processing, so that your own computer is not the limit of the audio engine. More here: https://madskjeldgaard.dk/posts/supernova-intro/), or any other audio engine. Scsynth is, nonetheless, one of the most finely tuned and efficient synthesis engines out there. The client and server applications normally run in the same machine, but they can also run in different machines.

- The IDE is the environment we see here, the text editor, menu bars, post window (where SC will send us information), status bar, etc. (https://doc.sccode.org/Guides/SCIde.html).

- The client is in charge of sending OSC messages (Open Sound Control, the communication protocol used between client and server) to the server. The client is both the "paper sheet" and the "mailer" to send these messages to the server. The client also features the interpreter, which allow us to write the code in the language of SC and execute it. As OSC messages are low-level language (difficult to write and understand by a human), the object-oriented language (higher level) of the SC client allows much more expressive power than OSC messages (although it is possible to write raw OSC messages in the syntax). The interpreter translates the SC language into OSC messages for the server.

- The server doesn’t know anything about the SC language, doesn’t know what’s an object or what the code means: the server only understands OSC messages. The server can receive OSC messages from other apps different from SC client (for example Max/MSP), but keep in mind that sclang is specifically designed to obtain all the expressive power of the SC language and to fit the server’s needs. The default server is the local server (assigned to global variable “s”). We'll look into this later on.
The server can be booted by pressing Ctrl-B or by executing s.boot.

Due to the client-server architecture in SC, it is crucial to remember that there is a distinction between the actual things like nodes, busses, buffers or servers, and the objects that represent them in the language app (in the form of instances of the classes Node, Bus, Buffer, Server, etc.). For example, a Buffer object is a client-side abstraction of a server-side buffer: it is a representation of the buffer in the server containing its common tasks, OSC messages, capabilities, etc. The abstraction objects are used to control from the language the actual objects in the server.
*/

/*
//Additional recommendations:
- The Help window on the right side can be detached by choosing that option in the little square on the left of the window. I like detaching it to have a full-sized post window. The Help window can be called from anywhere in the code by pressing Ctrl-D over any object.
- There is an option called "Autoindent line or region" in the "Edit" menu that comes in handy when the indentation (the empty spaces at the beginning of some lines that indicate that the line is contained within the upper level of indentation) of a block of code gets messy.
- The semicolon ";" is used in SC to separate instructions. Many syntax errors at the beginning might come from the lack of a semicolon. The last line of a code does not need the semicolon (and it should be stylistically avoided).
- You can make comments (like this one) in two ways: "//" at the beginning of the line for single lines, and "/*...*/" to open and close an entire block. Comments can be useful to explain or give remarks about a code.
- In the "View" menu, the option "Split to right" allows you to open two SC files on a split screen.
- Spaces don't usually matter in SC (although we'll see some examples in which they do), but there are certain conventions to follow for the sake of clarity.
- It is possible to record the output of the audio server at any moment: click the status bar below and select "Start recording". The recording can be stopped by pressing "Pause recording or with the key combination Ctrl-period. The recordings are saved in AIFF format by default, somewhere in the SuperCollider folder on your computer. The following are some options related to recording:
*/
Server.local.recHeaderFormat_("wav").recChannels_(2).recSampleFormat_("int24"); //Stablishing the type of file, num of channels and bits depth of the recording.
s.prepareForRecord("~/Desktop/wave.wav".standardizePath); //Establishing the file path (where it will be located). Example for desktop.
Server.local.record; //Start recording.
Server.local.stopRecording; //Stop recording.


//########################################################
//THE STARTUP FILE ("File" menu --> "Open startup file": https://doc.sccode.org/Reference/StartupFile.html (about).
//When we run SuperCollider, the first thing the application does is compile the "class library", where all classes and possible extensions are located. Then, SC's interpreter looks for a file called "startup" and executes all code within it. The file is, at first, empty, but writing code in it allows us to make user-specific customizations of the SC application (mainly altering the local server options, such as changing the number of default input and output channels, using specific soundcards by default, increasing the sample rate, etc.).
//You can find here all the options for the server: https://doc.sccode.org/Classes/ServerOptions.html. Here are some of the most important ones, although many of these things might not be understood yet:

s.options.memSize = 2 ** 16; //Number of kilobytes of real-time memory allocated to the server (for synths and UGens such as delays, which do not use buffers). Default is 2 ** 13 (8192).
s.options.numWireBufs = 256; //Number of buffers allocated to interconnect UGens (default is 64).
s.options.numBuffers = 1024 * 10; //Number of global sample buffers available (default is 1024).

Server.local.latency = 0.05; //Setting a new latency value (default is 0.2). Setting a very low value can lead to errors such as multiple "late" messages in the post window. More on latency here: https://depts.washington.edu/dxscdoc/Help/Guides/ServerTiming.html, and in here: https://composerprogrammer.com/teaching/supercollider/sctutorial/8.1%20Precise%20Timing%20in%20SC.html
Server.local.sampleRate_(48000); //Default sample rate is 44100. It could be raised to even 192000. Sample rate determines the number of snapshots taken to recreate the original soundwave. It affects the frequency range (the "resolution" on the "x" axis of digital audio signals).
Server.local.blockSize_(64); //Block size (number of samples in one control period, so a control rate signal will produce one sample for every 64 sample values produced by an audio rate signal). 64 is the default value. When blockSize = 1, then control rate is equal to audio rate.

Server.local.numPrivateAudioBusChannels_(1040); //Increasing the number of private audio bus channels (default is channels 4 to 127). Only needed if the following two options are greatly enlarged:
Server.local.numInputBusChannels_(32); //Numer of hardware input channels. Default is 2.
Server.local.numOutputBusChannels_(64); //Number of hardware output channels. Default is 2.
//For both of those, when executing s.meter, it should show the level of the indicated number of input and output channels.

s.recSampleFormat = "int24"; //Sets the bit depth of the audio recording to 24-bit, which is compatible with the flac format (lossless compression). The bit depth affects the dynamic range (the "resolution" of the "y" axis of digital audio signals).
s.recHeaderFormat_("wav"); //Set the recording audio format to .wav (also possible "flac", for instance). _("wav") is equal to = "wav", just different syntax.

Safety(s).enable; //An extension for limiting and clipping, protecting against dangerous signals (other extensions can be enabled in the same way). Could be useful at the beginning and when performing wild experiments (which can, indeed, become quite risky). Though limiters can color the sound synthesis. Here is the link to download: https://github.com/nhthn/supercollider-safety-limiter

Server.local.zeroConf_(false); //True by default. Setting it to false might help with delays upon server boot.
Server.local.maxNodes_(5120); //Maximum number of nodes. Default is 1024.

Server.local.options.device_("MADIface USB (24012536)") //Connecting to an output device other than the default (example: MADIface in Erkki studio).
//########################################################


//DATA TYPES
//Data types are different ways of representing and interpreting data (information). However, in SuperCollider, all data is represented by objects, and therefore SC is not based on data types as such, but on objects. There are, nonetheless, literals, objects whose value is represented directly in the code rather than sending a message to an object, that is to say, they have a direct syntactic representation. Needless to say, each literal can be also represented by its corresponding class. These are the literals that can be represented in SC: https://doc.sccode.org/Reference/Literals.html

//NUMBERS
//The class Number represents a mathematical quantity. Literal numbers can be integers or floats (floating-point numbers):

//An integer is any series of digits, optionally preceded by a minus sign. Integers are 32-bit, which sets its representation limit at 2147483647
2147483647 + 1 //Crossing upper limit (folds into negative range).
-2147483648 - 2 //Crossing the lower limit (folds into positive range). The representation of certain numbers around the limits depends on each computer (this is why I am writing -2 instead of -1).

//A floating-point number (float) consists of one or more decimal digits followed by a decimal point and one or more decimal digits. In SC, floats are 64-bit (except for FloatArray, in which they are 32-bit). This sets their representation limit much further than that of an integer. However, because the infinite continuity of floats is still discrete in a computer, some float numbers might be represented by a very close approximation instead:
(-1, -0.8..1) //0.0 does not exist in this list of numbers (at least in my computer). Instead, some number extremely close to it is output (the difference between that number and zero is not significant for our perception).
(0, 0.2..1) //0.0 does appear in this list, nevertheless (at least in my computer).

//Another example (that happens in my computer):
(0.1 !10).sum == 1.0 //"False".
(0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1) //But equal to 1.0 in fact.
//Anyway, additional discussion on floats representation can be found here: https://www.sounddevices.com/32-bit-float-files-explained/

//Float numbers in SC support other notations:
1.2e4 //Exponential notation (for very big and very small numbers).
1.2e-4
pi //pi constant (to refer to the pi float).
0.5pi
inf //Keyword for "infinity" (also treated as an instance of Float).
-inf //There is also negative infinity.

//Other number literals:
//SC supports radices other than base 10, for instance, hexadecimal notation (1-9 and then A-Z or a-z) or binary notation (0-1). We write the base specified in base 10, followed by "r" and the value written in that radix (when executed, they are printed on the post window in base 10):
16rF //F in base 16 ( = 15 in base 10).
2r000100 //000100 in base 2 ( = 4 in base 10).
//There is also musical notation of accidentals (expressed as floats), but this might be quite useless. You can check it out in the link about literals.

//As mentioned before, any literal can be represented by its class, just to demonstrate that literals are direct representations of certain objects:
Integer
Float
SimpleNumber
//We can inspect these classes by looking at their implementations (Ctril-I)

//CHARACTERS
//Single characters are represented with a dollar sign before a character. See the Help file for examples of characters (I have never used this literal myself before).
$a //Letter "a".
$\n //New line:

(
$\n;
"Hi".postln;
$\n
)

//STRINGS
//A string is a sequence of characters between double quotes. They can contain spaces:
"string"
//Strings can be applied methods such as:
"string".scramble
"string".size
//Two strings containing the same characters do not represent the same object, that is to say, they are equal (==), but not identical (===):
"abc" == "abc" //True
"abc" === "abc" //False
//Notice that a single "=" in SC is never used for equality or identity, but to assign data to variables and arguments, as we will see.

//SYMBOLS
//A symbol is also a sequence of characters (can also contain spaces, but only if within single quotes). They can be preceded by a backslash or placed between single quotes:
\symbol
'symbol'
//Two symbols containing the same characters do represent the same object, that is to say, they are equal (==) and identical (===), and this is why they are best used as identifiers or tags.
\abc == \abc //True
\abc === \abc //True
//Strings can be converted to symbols:
"string".asSymbol

//IDENTIFIERS
//Identifiers are the names of methods and variables. They always begin with a lowercase letter to distinguish them from classes. They can only contain alphanumeric characters and underscores.

//Examples of variables (more on variables in the Theory file 2), which are data containers:
var hello, filter_func; //Declared variables (for example, within a function).
a //Global variable, can be accessed from anywhere in the code.
~variable_a //Global, with a descriptive name.

//Examples of methods:
.play, .midicps, .round

//SPECIAL VALUES
//Other values that can be represented in SC are:
true
false
nil //Empty
//Class names are also literals.


//MATHEMATICAL OPERATIONS
//Mathematical operations with numbers can be unary (applied to single numbers, usually represented by methods) or binary (happening between two or more numbers, most commonly represented by binary operators, but also some possible with methods).
//Some operations can be written with different syntaxes as mentioned when dealing with messages. For instance, the module:
16 % 7  //Binary operator.
16 mod: 7 //Binary operation with identifier.
mod(16, 7) //Functional notation message.
16.mod(7) //Receiver notation message

//Here is a list of the most common unary and binary operators in SC: https://doc.sccode.org/Overviews/Operators.html and some other symbolic notations here: https://depts.washington.edu/dxscdoc/Help/Overviews/SymbolicNotations.html
//Basic calculations:
1 + 1 //Addition
1 - 1 //Subtraction
1 * 2 //Multiplication
5 / 2 //Division
4 / 0 // = inf (it is not a number, but the computer needs to express it somehow. Even a nan (not a number) is a number for the computer)
5.div(2) //Division, but returning only integers (rounding down)
2 ** 7 //Power
2.pow(7) //Power (applied as method)
9.sqrt //Squared root (3*3 = 9)
27.cbrt //Cubic root (3*3*3 = 27)
7.pow(1/12) //Calculating the "x" root of a number using its power equivalent ("m" root of "a" to the "n" = "a" to the "m / n"). Example = 12th root of 7
2 ** (1/12) //Frequency ratio for an equal temperament semitone (to be multiplied by the departure frequency)
2 ** (7/12) //Idem (of a fifth)
7.midiratio //Equivalent in method form
21.mod(12) //Module (also using %)
(0..24) % 7 //Demonstration of how module works (keeping 24 values within 0 - 6)

1+-2 //Spaces matter here as we cannot know if the (-) is a subtraction operation or a minus sign for the 2
1 + -2 //This is understandable.

//Operations hierarchy:
//In SC, all operations are calculated from left to right no matter the kind of operations involved:
2 + 3 * 3 //15
2 + (3 * 3) //11 (prioritizing the product by using parenthesis).

//Other calculations:
13.nextPowerOfTwo //Next power of 2 from that number onwards.
44.nextPrime //Next prime number from that number onwards.
4.nthPrime //The fourth prime number in the series of prime numbers.
34.61946.round(0.01) //Rounding to two decimals (rounding up from 5, down from 4). The argument defines the number of decimals.
72.round(30) //Keeps number within the multiples of the .round argument value (useful for overtones).
69.midicps //MIDI (Musical Instrument Digital Interface) to Hz (cycles per second) converter. MIDI is a communication protocol originally designed for digital synthesizers. Some tips: piano ranges in MIDI pitch values are 21 (A0) to 108 (C8). Decimals in MIDI pitch values indicate cents (microintervals, 1 cent = 0.01 semitones, 100 parts each half step).
440.cpsmidi //Hz to MIDI converter.
1.57.asInteger //Turns a float into an integer by rounding down (also shortcut .asInt).

//Bipolar and unipolar:
.bipolar //To convert unipolar to bipolar signals (UNIPOLAR = Signal moving from 0 o 1 regarding the amplitude --> (So with the method, the amplitude is expanded up to -1 to 1).
.unipolar //To convert bipolar to unipolar signals (BIPOLAR = Signal moving from -1 to 1 regarding the amplitude --> (With this method, the amplitude will be cut to half, from 0 to 1).

//Randomness with numbers (examples of methods):
10.rand //From 0 to 9.
333.rand + 100 //From 100 to 432.
5.xrand //Excludes 0 (from 1 to 5).
5.xrand(1) //Excludes 1.
5.xrand2 //Includes negative values (no 0 by default).
10.rand2 //Includes negative values (including 0).
rrand(0.1, 4) //Random numbers within a range with uniform distribution (both integers --> integers only; at least one of them float --> all float results): This is one example of polymorphism as explained before in this document.
exprand(1, 4)//Random numbers within a range with exponential distribution (results will always be float regardless of the input value). The lo/hi limit cannot be zero and the range cannot cross zero.


//########################################################
//Something extra about DISTRIBUTIONS:
//All distributions can be generated from rrand (uniform distribution) by applying certain operations. Observe the graphics (with the key "M" the type of graphic can be changed). Also, here distributions are all tested out of 100000 values (the more values, the better definition of the distribution we obtain):

({ rrand(0.0, 1.0) } !100000).histo.plot(minval: 0) //Uniform distribution.
({ exprand(0.001, 1.0) } !100000).histo.plot(minval: 0) //Exponential distribution (it needs something above zero as the starting point,  cannot be 0) --> Priority to low values as a result in the distribution.
({ 1.0.linrand } !100000).histo.plot(minval: 0) //Linear distribution --> Priority to low values, but not as much as in the exponential (negative value to invert the direction, priority to high values).

//This line creates a distribution identical to .linrand, but using rrand: it chooses the minimum value of each pair of values (and then repeats the process 100000 times):
({ ({ rrand(0.0, 1.0) } !2).minItem } !100000).histo.plot(minval: 0) //Try out .maxItem instead to change the direction of the distribution (priority to high values).

//And this line creates a distribution close to .exprand, but using rrand: we need the constant "e". From the previous lower choice, "e" to the power of the resulting value will create the exponential distribution. We need, though, a bigger scope (more "time" in the "x" axis) in order to visualize the curve (0.001 to 5 for the random choice instead of 0.001 to 1).
e = 2.71828 //Defining the constant "e" (exponential).
({ var min; ({ min = rrand(0.001, 5.0) } !2).minItem; e ** min } !100000).histo.plot(minval: 0) //We need a variable "min" to move around and use the value chosen by rrand.
({ var min; ({ min = rrand(0.001, 5.0) } !2).minItem; log2(min) } !100000).histo.plot(minval: 0) //Inverted graph (y axis), applying the log2.
//For the inverted graph on the x axis (logarithmic shape), we need the log base "e" of "min" (I haven't sorted this out yet :D).

//This one creates the Gaussian distribution when calculating the "mean" value every three values:
({ ({ rrand(0.0, 1.0) } !3).mean } !100000).histo.plot(minval: 0) //Gauss "bell" shape in the distribution (priority to central values).
({ gauss(0.0, 1.0) } !100000).histo.plot(minval: 0) //Same result using method "gauss".
//########################################################


///////////////////////////////////////////////////////////////////////
//TYPES OF BRACKETS

//Round brackets or parenthesis: they are used for sending arguments to their method and grouping blocks code broken into different lines:
SinOsc.ar(440) //Sending arguments (this signal does not produce any sound because the sound function hasn't been created).
//Grouping a block of code. This entire block of code can be selected at once by double-clicking on the first or last parenthesis:
(
var string;

string = "hello";

"hello".scramble
)

//Square brackets: they are used for collections (arrays, lists, sets, etc.):
[1, 2, 3, 4, 5]

//Curly brackets: they are used for functions:
{ SinOsc.ar(440, 0, 0.1) }.play; //Now we can hear the previous signal thanks to the function.play syntax.

//Stylistic remarks: Avoid spaces before or after [] or (), but allow spaces after { and before } as recommended in the guideline.


///////////////////////////////////////////////////////////////////////
//INTRODUCTION TO UNIT GENERATORS

//Unit Generators (UGens) represent calculations with signals, that is to say, they are classes that create or process signals. All UGens branch from the UGen class. All UGens respond to one or more of the following class methods:
.ar //Creates audio rate signals (by default, 44100 samples (momentary value of an analogue signal that is taken several times a second to convert the signal to digital form) per second. Audio rate signals are normally meant to be heard).
.kr //Creates control rate signals (by default, 1 sample value for every 64 sample values of an audio rate signal. Control rate signals are less computationally expensive than audio rate signals, but they are not usually meant to be heard. They are used as modulators, for instance, instead).
.ir //Creates initial rate signals (they calculate their output at the moment of creation or "initialization". That is to say, they output a single value when executed. These signals cannot be modulated).
//Then, they return a new instance of the UGen class that calculates the signal at audio or control rate, or only once at initialization. Some UGens respond to the .new method instead.
//UGens only work within a UGen function (for example, a function.play or a SynthDef, which we'll see in theory file 6). The most relevant categories of UGens and the most prominent UGens among them can be found here: https://doc.sccode.org/Guides/Tour_of_UGens.html

//All UGens responding to .ar or kr methods include the arguments "mul" and "add". Mul is a constant or signal by which the output of the UGen is multiplied (thus it often corresponds to scaling the amplitude of the UGen signal). Add is a constant or signal added to the output of the UGen (thus it often corresponds to adding a constant or DC offset to the signal). We'll study our first UGen in theory file 2, the sine wave (SinOsc).


///////////////////////////////////////////////////////////////////////
//A FEW NOTES ON ACOUSTICS (WAVE MECHANICS)

//It might be convenient to revise some basic concepts of acoustics before continuing. Some meager notes:
/*
- Vibration: pattern of air (or any other medium) pressure changes (compression-rarefaction).
- Vibration source: something that vibrates.
- Sound: vibration produced by a vibration source, propagated through a medium (such as the air) and transferred to a surface, which vibrates sympathetically (keeping the same vibration pattern).
- Waveshape: representation of the vibratory pattern of a sound in the time and amplitude (sound pressure) domains.
- Periodic / aperiodic sound wave: A periodic sound wave repeats the exact same vibratory pattern.  An aperiodic sound wave present a chaotic pattern (noise).
- Cycle: Each repetition of the pattern of a periodic wave.
- Period: Time occupied by a cycle of a periodic wave (time per cycle). This time determines the frequency. The frequency is equal to 1 / period (to the inversion of the period) and vice-versa.
- Frequency (Hz): Cycles per second (inversion of the period).
- Wavelength: Distance from peak to peak of the waveshape (distance traveled in one cycle, whichever its onset is. See "phase"). The wavelength is equal to velocity / freq (being the velocity dependent on the speed of sound in the air or in the involved medium). In the air, for instance, the wavelength of a sound with freq = 440, is 0.77 meters.
- Amplitude: The scope of sound pressure change, either positive or negative (from 0 to highest or lowest point in a waveshape).
- Peak to peak amplitude: Distance from the lowest to the highest amplitude points in a waveshape.
- Phase: in a periodic wave, point in the cycle from which the waveshape starts, that is, onset of the waveshape.
- ... and many more...
*/

//Remember that the sum of two oscillations in phase is constructive: the amplitudes are added.
//On the other hand, the sum of two oscillations of opposite phase is destructive: the two oscillations cancel each other.
//Two frequencies at 1000 and 1005 Hz (5 Hz apart) will produce 5 oscillations per second:
(
{
	var osc1, osc2;

	osc1 = SinOsc.ar(1000, 0, 0.2, 0);
	osc2 = SinOsc.ar(1005, 0, 0.2, 0);

	osc1 + osc2
}.play
)
//From 20 Hz of separation onwards, we start perceiving two different frequencies:
(
{
	var osc1, osc2;

	osc1 = SinOsc.ar(1000, 0, 0.2, 0);
	osc2 = SinOsc.ar(1020, 0, 0.2, 0);

	osc1 + osc2
}.play
)


///////////////////////////////////////////////////////////////////////
//Some extra links for general matters:
//Some discussion on volume safety when working with SC: https://scsynth.org/t/levels-and-volume-safety-protecting-yourself-from-hearing-damage-in-sc/4669
//Debugging tips: https://doc.sccode.org/Guides/Debugging-tips.html
//Understanding errors: https://doc.sccode.org/Guides/Understanding-Errors.html
//Another general guide looking good: https://thormagnusson.gitbooks.io/scoring/content/index.html
