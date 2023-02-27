//1 - INTRODUCTION AND DATA TYPES:

/* -- STARTUP FILE NEEDS --

s.recSampleFormat = "int24";
s.options.memSize = 2 ** 16;
s.options.numWireBufs = 256;

Safety(s).enable; // --> SafetyNet is a very useful limiter. It is an extension which can be downloaded from the site: https://github.com/adcxyz/SafetyNet. When installed, this line will enable the extension and the postwindow will show the addition of the synth 'safeClip' whenever the server stops running a code.

Server.local.latency = 0.05;
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Online SuperCollider guide: https://doc.sccode.org/Help.html: open source --> lots of ways of doing the same thing and alternative grammar for a same process, so better to focus on one of the options and on the selected procedures we consider the most useful for our own usual practice (although all experimentation and discovering beyond it is always good).

/* Other resources:
https://supercollider.github.io/tutorials/
https://doc.sccode.org/Help.html
https://scsynth.org/
https://github.com/madskjeldgaard/awesome-supercollider
http://sccode.org/

cmd+d // Documentation same than help
cmd+i //implementations

https://blog.alexdevero.com/6-simple-tips-writing-clean-code/
https://medium.com/coding-skills/clean-code-101-meaningful-names-and-functions-bf450456d90c
https://scsynth.org/t/some-notes-on-writing-supercollider-code-for-non-programmers/1940
*/

/* According to SC's guide, SuperCollider is an audio server, programming language, and IDE (Integrated Development Environment) for sound synthesis and algorithmic composition. This means that we have three different software:

- The IDE (for Mac / Windows / Linux, it is the circle icon of the program), which consists of the text editor, the upper menu bar, the help window (which can be detached and recalled with ctrl+D), the post window (showing all the information about our code and the result of compiling and running the code), the status bar (below, showing satatus of the interpreter and the server: click to show all the options + beware of the CPU percentage), and the LANGUAGE itself (object-oriented, based on Smalltalk language, belonging the the C family) --> the syntax of the language is the set of rules and symbols that must be followed and used for a language to be properly structured.

- The interpreter (it is the cube icon of the program): if the language is the letter, the interpreter is the mailer (both together are sclang, the client). It is the interpreter for the SuperCollider programming language, that is to say, it allows the user to write code in the programming language and interactively execute the resulting commands (run the code), for example to control the audio server.
--> Running the code (compile + run): shift + enter.

- The audio server:
--> Boot up the server: ctrl + B.

SuperCollider's architecture is based on the relationship Client-Server: the client is formed by the language and the interpreter. The client (sclang) and the server (scsynth) communicate via OSC protocol (Open Sound Control --> a protocol to interconnect multimedia devices, more efficient than MIDI in a certain sense). Here the graphs: https://doc.sccode.org/Guides/ClientVsServer.html

Client and Server are two distinct, autonomous components. Thus, the server can be controlled by other "clients" which could provide for OSC messaging, such as Java, Python, Max/MSP, but sclang is the client providing us with the expressive power of SuperCollider language, and it specifically fits the musical needs (and purposes) of the server.


--> Note for myself: an object-oriented programming language (OOP) is a programming paradigm (clasification, pattern or model, for a series of different programming languages, for example) based on the concept of "objects", which can contain data and code: data in the form of attributes (in SC = classes), and code, in the form of procedures (often known as methods). See in the help guide how, for example this filter (https://doc.sccode.org/Classes/Allpass1.html), is comming from different bigger categories up to the most general one, which is simply called "Object"(the root class of all other classes). See the entire class-tree here: https://doc.sccode.org/Overviews/ClassTree.html.
--> Note for myself: "running" the code means to compile and run the code: the compiling is done automatically (the interpreter translates the text to ones and zeros so the computer can understand the language), then the functions are run (when pressing Shift + Enter).
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/* Recommendations for a good grammar: https://github.com/supercollider/supercollider/wiki/Code-style-guidelines
- Readable code: clear names for variable (what it is, what it does, short and clear --> separate words with caps + use just letters and numbers): for example, filterComb1.
- Choose one way of doing things and keep it consistently.
- Use comments for clarifications (and for you to remember information about your own code) --> // (for single lines) VS /* */ (for entire blocks, like this one).
- The spaces do not mean anything in SC, but for the sake of clarity, they should be kept (for example, as they will in these documents).
- The indentation: separating the lines of the code for clarity (unlike in so many of the SC help files examples). There are no rules for this, but conventions for the sake of clarity. Follow the auto indentation + when already having a block of code, select the block, then go to edit in the menu bar, and press "autoindent line or region", just to check and fix the indentation. Try to keep at the same indentation level what belongs to its own group, class, etc.).
- The semicolon ; is ised to separate each of the different instructions of the code that will be interpreted separately by the interpreter and sent to the server.
- The recording system in SC is in the status bar bellow, click on the bar and "start recording". To stop recording, either "pause recording" there, or stop running the code with ctrl + . The recording will be saved in AIFF format in the folder "SuperCollider" --> "Recordings" (at least in Windows).
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//DATA TYPES: different ways of representing and interpreting the data (information) and its value. They are usually represented as Literals: https://doc.sccode.org/Reference/Literals.html; they have different colors.

//NUMBERS: they can be integers or floats (floating-point numbers). Integers are 32-bit (this is related to the range of numbers that the language can interpret (-2147483648 to 2147483647, anything out of those limits is wrapped and returned within them --> 2147483647 + 1= -2147483648. Floats are 64-bit, so you can use floats to make calculations up to ± 9007199254740992. Floats in programming can behave in unexpected ways due the infinite amount of them (which is obviously discontinuous in a machine - there are points, although really close, but nothing in between, but this is all very complex and there are thousands of articles about that explaining it better than me):

2147483647 + 1 //See what happens when crossing the limit (it goes to the negative side).

//About the limitation of float representation: the limit of number that a program manages depends of its processor, it is usually a power of 2. The program tries to divide the gap between 0 and 1 so many times, but in such division, it can be that an integer is not represented (as in the case of 0.1):

(-1, -0.8..1) //For example: there is no zero here. In SC there are so many numbers but not all of them (that is why the strange number is its best approximation to zero in that progression). BUT it is not a problem, perceptually, it is a zero.
(0, 0.2..1) //There is zero, but as a float.

(0.1 ! 10).sum == 1.0 //It's "false" (but the array itself is 1.0.
(0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1) //But this is 1.0.
//This "error" is related to the representation of float values in SC (not every number is in the program).

//You can always use math rounding methods in order to solution this float issue, common in all programming languages.

//////////
//Other notation of numbers supported by SuperCollider:

1.2e4 //exponential
0.5pi //pi as a floating point constant (you can try evaluating it by itself).s
inf //special literal for infinite

//CHARACTERS: The following are the recognized escape characters in SuperCollider. A backslash before any other character will simply produce that character (they can simply replace the characters, but I have never used them before):
$A   // the letter A?
$\t  // tab (horizontal tab)
$\f  // form feed
$\v  // vertical tab
$\n  // newline (linefeed)
$\r  // return
$\\  // backslash

//STRINGS (Collections: e.g. Array): it is a series of characters, written in double quotes. You can apply methods to an string (not to a symbol (see next point), for example). A string is a type of collection (superior category), so is an array (see document 2 in the theory folder - "Functions, arrays and methods").

"string"
"string".scramble

//SYMBOLS: you can't apply methods to a symbol. It is used to point to something, to represent a block of code, or a process. It can be writen in simple quotes or with a backslash. Unlike strings, two symbols with exactly the same characters will be the exact same object. Symbols are best used for identifiers or tags to call blocks of code, whereas you should use a string when your characters are really processed as text data. For the name of symbols, use only alphanumeric characters and underscores (_).

//Two different syntaxes:
\symbol
'symbol'

//Equality and Identity in SuperCollider (symbols VS strings):
\abc == \abc //True
\abc === \abc //True

"abc" == "abc" //True
"abc" === "abc" //False

//BOOLEAN: these are special values for boolean expressions:
true
false
nil //(empty)
inf //(infinite)

//IDENTIFIERS: methods and variables. Methods are applied to objects that are called "receivers". Variables are data containers. The name of methods and variables start by a lower-case letter to distinguish them from classes. They also use only alphanumerics and underscores as characters:

var hello, filter_func; //Examples of variables.
.play, .midicps, .round; //Examples of methods.

//The arguments also send information about a class, and this information can be sent from the outside of a code. The variables contain data, but they work inside a single code.

/* There are two types of methods:
- Class methods: they are applied to a class to create objects (for example: .ar, which creates an audio signal).
- Instance methods: they are applied to what a class has created to modify it (for example: .round, applied to a number that already exists, to round it to a certain number of decimals).

Ctrl + i --> This will show the source code of SC. It can be seen that the class methods are marked with a *, whereas the instance methods do not have the asterisc.
*/

//CLASSES (and UGENS): classes' names always start by a Capital letter. They create objects and the arguments are applied to them in order to define and modify these objects. Examples:

Server
SinOsc
HPF

//A UGen (unit generator) is a program (.exec) that runs in the server at a specific rate (audio .ar, control .kr or initial .ir rate, as shown below). All the UGens are classes, but there are other classes that are not UGens (for example, Pattern, Stream, Array, etc.). Go to SC files and search for the UGen folder (the files are "executables", or .exec, meaning that they are programs). Types of rates:

.ir //Initial rate: it is only executed once (for example, a value info).
.kr //Control rate (64/seg): for slow processes (mathematical operations, work with MIDI values, etc.).
.ar //Audio rate (sample rate = 44100 Hz/s by default --> see Nyquist theorem to understand why the sample rate is a bit more than two times the human limit of audition of frequencies --> avoiding the aliasing): for audio processes, which are faster (lots of values).

//Ugens create signals (oscillators, filters, noise generators, delays, envelopes, limiters and compressors, chaos generators, impulse generators, reverberation, triggers, FFT, etc.). See our first Ugen in document 2, SinOsc.
//The Class UGen is included within the Class Function.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SOME BASIC MATHS that could be useful:

//Randomness:

10.rand //From 0 to 9.
333.rand + 100 //For example for freqs: freqs from 100 to 432 Hzs.
10.rand + 1 //To exclude 0.
5.xrand;//excludes 0 by default.
5.xrand(1);//exclude 1 (and 0, by default).
5.xrand2 //Includes negative values.
10.rand2 //Includes negative values (-10 to 10, including 0)
rrand(0.1, 4) //Random numbers within a range with uniform distribution (if both numbers are int, all random numbers will be int when evaluated; if at least one of them is float, all output numbers will be floats).
exprand(1, 4)//Random numbers within a range with exponential distribution (all results will be floats regardless of the type of input)
//This quality of rrand and exprand is called polymorphism ("the ability for different kinds of objects to respond differently to the same message").

//Other calculations:

5.numBits; //Number of bits (points of resolution of the Y axis --> 16 bits = 2 ** 16 points of resolution in the axis).
13.nextPowerOfTwo; //Next power of 2 from that number onwards.
44.nextPrime; //Next prime number from that number onwards.
4.nthPrime; //The fourth prime number of the series of prime numbers.
2.sqrt //Squared root of two.
21.mod(12) //Module 12 of 21.
21%12 //Also module 12 of 21.
(0..24)%7 //Example of how the module 7 of 24 functions (objective: keeping values between 0 and 6, as with the pitch classes, between 0 and 11 using module 12, for instance).

//It is not possible to calculate the "x" root of a number other than .sqrt (squared) and .cbrt (cubed). The way to do this is to express the root as a power: "m" root of "a" to the "n" = "a" to the "m / n". Thus, the 12th root of 7 is:
7.pow(1/12)

1 + 1 //Addition / substraction (-).
1 * 2 //Multiplication
5 / 2 //Division
2 ** 7 // Power
34.61946.round(0.01) //Rounding to two decimals (rounding up until 5, down from 4).


//Other basic methods:

440.midicps //Midi to Hz converter.
69.cpsmidi //Hz to midi converter.
//--> MIDI tip: the piano ranges in Midi numbers are 21 (A0) to 108 (C8). Decimals in Midi numbers indicate cents (microintervals, 1 cent = 0.01 semitones, 100 parts each half step).

//Bipolar and unipolar:
.bipolar //To convert unipolar to bipolar signals (UNIPOLAR = Signal moving from 0 o 1 regarding the amplitude --> (So with the method, the amplitude is expanded up to -1 to 1).
.unipolar //To convert bipolar to unipolar signals (BIPOLAR = Signal moving from -1 to 1 regarding the amplitude --> (With this method, the amplitude will be cut to half, from 0 to 1).

//See all unary (applied to one number, like a square root) and binary (need two numbers, like a sum) operations in the library (SC help).

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//TYPES OF BRACKETS: and their function:

//PARENTHESIS or round brackets: two functions:
//Sending arguments (see document 2), or for methods or events:

SinOsc.ar(freq: 440); //This sine wave does not sound (no function for sound yet).

//Grouping together a block of code broken into different lines (double click at the top / bottom parenthesis to select the entire block and run the code):

(
var string;

string = "hello";

"hello".scramble
)

//SQUARE BRACKETS: used for arrays (see document 2), lists or collections:

[ 1, 2, 3, 4, 5 ]

//CURLY BRACKETS or braces: they contain functions (see document 2):

{SinOsc.ar(440, 0, 0.2, 0)}.play; //This sine wave produces sound now (function .play is playing it).

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//TYPES OF DISTRIBUTIONS:
//All distributions can be generated from rrand (uniform distribution) applying certain operations. Observe the graphics (with the key "M" the type of graphic can be changed). Also, here distributions are all tested out of 100000 values (the more values, the better definition of the distribution we obtain):

({ rrand(0.0, 1.0) } ! 100000).histo.plot(minval:0) //Uniform distribution.
({ exprand(0.001, 1.0) } ! 100000).histo.plot(minval:0) //Exponential distribution (it needs something above - or below - zero as the starting point): cannot be 0 --> Priority to low values as a result in the distribution.
({ 1.0.linrand } ! 100000).histo.plot(minval:0) //Linear distribution --> Priority to low values, but not as much as in the exponential.

//This line creates a distribution identical to .linrand, but using rrand: it chooses the minimum value of each pair of values:
({ ({ rrand(0.0, 1.0) } ! 2).minItem } ! 100000).histo.plot(minval:0) //Try out .maxItem instead to change the direction of the distribution (priority to high values).

//This one creates the Gaussian distribution when calculating the "mean" value every three values:
({ ({ rrand(0.0, 1.0) } ! 3).mean } ! 100000).histo.plot(minval:0)
({ gauss(0.0, 1.0) } ! 100000).histo.plot(minval:0) //Same result using method "gauss".

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ACOUSTICS
//It would be essential to remember the basics of acoustics before continuing. Here there are only a few meager notes:
//Seek proper definitions of: sound, sound source, vibration (air pressure changing patterns), sound wave, waveshape, periodic wave (types of), cycle (wave), period (time), frequency, Hz (cycles per second), hearing limits, amplitude (vertical distance, positive or negative), peak to peak amplitude (vertical distance, positiva and negative), etc.

//The sum of two oscillations in phase is constuctive --> the amplitudes are added.
//The sum of two oscillations anti phase is destructive --> the two oscillations cancel each other.

//Two frequencies at 1000 and 1005 Hz will produce 5 oscillations per second:

(
{
	var osc1, osc2;

	osc1 = SinOsc.ar(1000, 0, 0.2, 0);
	osc2 = SinOsc.ar(1005, 0, 0.2, 0);

	osc1 + osc2
}.play
)

//IGNORE THIS:
//Bonus code (so GitHub doesn't turn my file into markdown:

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

Synth(\filters)
