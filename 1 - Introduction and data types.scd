//1 - INTRODUCTION AND DATA TYPES:

/* -- STARTUP FILE NEEDS --

s.recSampleFormat = "int24";
s.options.memSize = 2 ** 16;
s.options.numWireBufs = 256;

Safety(s).enable;

Server.local.latency = 0.05;
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Online SuperCollider guide: https://doc.sccode.org/Help.html: open source --> lots of ways of doing the same thing and alternative grammar for a same process, so better to focus on one of the options and on the selected procedures we consider the most useful for our own usual practice (although all experimentation and discovering beyond is always good).

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

- The IDE (for Mac / Windows / Linux), which consists of the text editor, the upper menu bar, the help window (which can be detached and recalled with ctrl+D), the post window (showing all the information about our code and the result of compiling and running the code), the status bar (below, showing satatus of the interpreter and the server: click to show all the options + beware of the CPU percentage), and the LANGUAGE itself (object-oriented, based on Smalltalk language, belonging the the C family) --> the syntax of the language is the set of rules and symbols that must be followed and used for a language to be properly structured.

- The interpreter: if the language is the letter, the interpreter is the mailer (both together are sclang, the client). It is the interpreter for the SuperCollider programming language, that is to say, it allows to the user to write code in the programming language and interactively execute the resulting commands (run the code), for example to control the audio server.
--> Running the code (compile + run): shift + enter.

- The audio server:
--> Boot up the server: ctrl + B.

SuperCollider's architecture is based on the relationship Client-Server: the client is comformed by the language and the interpreter. The client (sclang) and the server (scsynth) communicate via OSC protocol (Open Sound Control --> a protocol to interconnect multimedia devices, more efficient than MIDI in a certain sense). Here the graphs: https://doc.sccode.org/Guides/ClientVsServer.html

Client and Server are two distinct, autonomous, components. Thus, the server can be controlled by other "clients" which could provide for OSC messaging, such as Java, Python, Max/MSP, but sclang is the client providing us with the expressive power of SuperCollider language, and it specifically fit the musical needs (and purposes) of the server.


--> Note for myself: an object-oriented programming language (OOP) is a programming paradigm (clasification, pattern or model, for a series of different programming languages, for example) based on the concept of "objects", which can contain data and code: data in the form of attributes (in SC = classes), and code, in the form of procedures (often known as methods). See in the help guide how, for example this filter (https://doc.sccode.org/Classes/Allpass1.html), is comming from different bigger categories up to the most general one, which is simple called "Object"(the root class of all other classes). See the entire class-tree here: https://doc.sccode.org/Overviews/ClassTree.html.
--> Note for myself: "running" the code means to compile and run the code: the compiling is done automatically (the interpreter translates the text to ones and zeros so the computer can understand the language), then the function (or whichever process) is run (when pressing Shift + Enter).
*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/* Recommendations for a good grammar: https://github.com/supercollider/supercollider/wiki/Code-style-guidelines
- Readable code: clear names for variable (what it is, what it does, short and clear --> separate words with caps + use just letters and numbers): for example, filterComb1.
- Choose one way of doing things and keep it consistently.
- Use comments for clarifications (and for you to remember information about your own code) --> // VS /* */
- The spaces do not mean anything in SC, but for the sake of clarity, they should be kept (for example, as they will in these documents).
- The indentation: separating the lines of the code for clarity (unlike in so many of the SC help files examples). There are no rules for this, but conventions for the sake of clarity. Follow the auto indentation + when already having a block of code, select the block, then go to edit in the menu bar, and press autoindent line or region, just to check and fix the indentation. Try to keep at the same indentation level what belongs to its own group, class, etc.).
- The semicolon ; is ised to separate each of the different instructions of the code that will be interpreted separately by the interpreter and sent to the server.
- The recording system in SC is in the status bar bellow, click and "start recording". To stop recording, either "pause recording" there, or stop running the code with ctrl + . The recording will be saved in AIFF format in the folder SuperCollider --> Recordings (at least in Windows).
*/

//Throughout all this document we are not using the server (not working with audio, yet)///////////////////////////////////////////////

//DATA TYPES: different ways of representing and interpreting the data (information) and its value. They are usually represented as Literals: https://doc.sccode.org/Reference/Literals.html; they have different colors.

//NUMBERS: they can be integers or floats (floating-point numbers). Integers are 32-bit (this is related to the range of numbers that the language can interpret (-2147483648 to 2147483647, anything out of those limits is wrapped and returned within them --> 2147483647 + 1= -2147483648. Floats are 64-bit, so you can use floats to make calculations up to ± 9007199254740992. Floats in programming can behave in unexpected ways due the infinite amount of them (which is obviously discontinuous in a machine - there are points, although really close, but nothing in between, but this is all very complex and there are thousands of articles about that).

2147483647 + 1 //See what happens when crossing the limit.

//About the limitation of float representation: the limit of number that a program manages depends of its processor, it usually is a power of 2. The program tries to divide the gap between 0 and 1 so many times, but in such division, it can be that an integer is not represented (as in the case of 0.1):

(-1, -0.8..1) //For example: there is no zero. In SC there are so many numbers but not all of them (that is why the strange number is its best approximation to zero in that progression). BUT it is not a problem, perceptually, it is a zero.
(0, 0.2..1) //There is zero, but as a float.

(0.1 ! 10).sum == 1.0 //It's "false" (but the array itself is 1.0.
(0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1 + 0.1) //But this is 1.0.
//This "error" is related to the representation of float values in SC (not every number is in the program).

//Other notation of numbers supported by SuperCollider:

1.2e4 //exponential
0.5pi //pi as a floating point constant
inf //special literal for infinite

//CHARACTERS: The following are the recognized escape characters in SuperCollider. A backslash before any other character will simply produce that character (they can simply replace the characters):
$A   // the letter A?
$\t  // tab (horizontal tab)
$\f  // form feed
$\v  // vertical tab
$\n  // newline (linefeed)
$\r  // return
$\\  // backslash`

//STRINGS (Collections: e.g. Array): it is a series of characters, written in double quotes. You can apply methods to an string (not to a symbol, for example). A string is a type of collection (superior category), so an array is (see document 2 - Functions, arrays and methods).

"string"
"string".scramble

//SYMBOLS: you can't apply methods to a symbol. It is use to point to something, to represent a block of code, or a process. It can be writen in simple quotes or with a backslash. Unlike strings, two symbols with exactly the same characters will be the exact same object. Symbols are optimized for recreating the same symbol over and over again. In practice, this means that symbols are best used for identifiers or tags that are only meaningful within your program, whereas you should use a string when your characters are really processed as text data. Use symbols to name things, use strings for input and output. For the name of symbols, use only alphanumeric characters and underscores (_).

\symbol
'symbol'

//Equality and Identity
\abc == \abc //True
\abc === \abc //True

"abc" == "abc" //True
"abc" === "abc" //False

//BOOLEAN: true, false, nil. Those are special values for boolean expressions.

//IDENTIFIERS: method, variable. Methods are applied to objects that are called "receivers". The name of methods and variables start by a lower-case letter to distinguish them from classes. They also use only alphanumeric and underscore as characters (for the name).

var hello, filter_func; //Examples of variable names.
.play, .midicps, .round; //Examples of method names.

//The arguments also send information about a class, and this information can be sent from the outside of a code. The variables contain data, but they work inside a code.
/* There are two types of methods:
- Class methods: they are applied to a class to create objects (for example: .ar).
- Instance methods: they are applied to what a class has created to modify it (for example: .round, applied to a number that already exists).

Ctrl + i --> This will show the source code of SC. It can be seen that the class methods are marked with a *, whereas the instance methods do not have the asterisc.
*/

//CLASSES (and UGENS): classes' names always start by a Capital letter. They create objects and the arguments are applied to them in order to define and modify these objects.

Server
SinOsc
HPF

//A UGen is a program (.exec) that runs in the server at a specific rate (.ar, .kr or .ir). All the UGens are a class, but there are other classes (for example, Pattern, Stream, Arraw, etc.). Go to the SC files and search for the UGen folder (the files are "executables", or .exec, so they are programs). Types of rates:

.ir //Initial rate: it is only executed once (for example, a value info).
.kr //Control rate (64/seg): for slow processes (those where you don't need so much values).
.ar //Audio rate (sample rate = 44100 Hz/s by default --> see Nyquist theorem to understand why the sample rate is a bit more than two times the human limit of audition of frequencies --> avoiding the aliasing): for audio processes, fast (lots of values).

//Ugens create signals (oscillators, filters, noise generators, delays, envelopes, limiters and compressors, chaos generators, impulse generators, reverberation, triggers, FFT, etc.). See our first Ugen in document 2: SinOsc.
//The Class UGen is included within the Class Function.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//SOME BASIC MATHS that could be useful:

//Randomness:

10.rand //From 0 to 9.
333.rand + 100 //For example for freqs: freqs from 100 to 432 Hzs.
10.rand + 1 //To exclude 0.
5.xrand;//exclude 0, default.
5.xrand(1);//exclude 1
5.xrand2 //Including negatives
10.rand2 //To include negative numbers as well (-10 to 10, including 0)
rrand(0.1, 4) //Random with a range (if both numbers are int, all numbers will be int; if at least one of them is float, all the results will be floats). In exprand, all results will be floats regardless it receives floats or ints. This quality is called polymorphism ("the ability for different kinds of objects to respond differently to the same message").

//Other calculations:

5.numBits; //Numer of bits (points of resolution of the Y axis --> 16 bits = 2 ** 16 points of resolution in the axis).
13.nextPowerOfTwo; //Next power of 2 from that number onwards.
44.nextPrime; //Next prime number from that number onwards.
4.nthPrime; //The fourth prime number of the series of prime numbers.
2.sqrt //Squared root of two.
21.mod(12) //Module 12 of 21 --> example of hour of a day for the module 12 (or whichever).
21%12 //Also module 12 of 21
(0..24)%7 //Example of how the module 7 of 24 functions (objective: keeping values between 0 and 6, as with the pitch classes, between 0 and 11).

//It is not possible to calculate the "x" root of a number other than .sqrt (squared) and .cbrt (cubed). The way to do this is to express the root as a power: "m" root of "a" to the "n" = "a" to the "m / n". Thus, the 12th root of 7 is:
7.pow(1/12)

1 + 1 //Addition / substraction
1 * 2 //Multiplication
5 / 2 //Division
2 ** 7 // Power
34.61946.round(0.01) //Rounding to two decimals

//Other basic methods:

440.midicps //Midi to Hz conversor
69.cpsmidi //Hz to midi conversor
//--> MIDI tip: the piano ranges in Midi numbers are 21 (A0) to 108 (C8). Decimals in Midi numbers indicate cents (microintervals, 1 cent = 0.01 semitones, 100 parts).


//See all unary (applied to one number, like a square root) and binary (need two numbers, like a sum) operations in the library (SC help).

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//TYPES OF BRACKETS: and their function:

//PARENTHESIS or round brackets: two functions:
//Sending arguments (see document 2), or for methods or events:

SinOsc.ar(freq: 440);

//Grouping together a block of code broken into different lines (double click at the top / bottom parenthesis to select the entire block and run the code):

(
var string;

string = "hello";

"hello".scramble
)

//SQUARE BRACKETS: used for arrays (see document 2), lists or collections:

[ 1, 2, 3, 4, 5 ]

//CURLY BRACKETS or braces: they contain functions (see document 2):

SinOsc.ar(440, 0, 0.2, 0).play;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ACOUSTICS
//It would be essential to remember the basics of acoustics before continuing:
//Two frequencies at 1000 and 1010 Hz will produce 10 oscillations per second (the difference --> Psychoacoustics).

(
{
	var osc1, osc2;

	osc1 = SinOsc.ar(1000, 0, 0.2, 0);
	osc2 = SinOsc.ar(1005, 0, 0.2, 0);

	osc1 + osc2
}.play
)

//The sum of two oscillations in phase is constuctive --> the amplitudes are added.
//The sum of two oscillations anti phase is destructive --> the two oscillations cancel each other.

//Seek proper definitions of: sound, sound source, vibration (air pressure changing patterns), sound wave, waveshape, periodic wave (types of), cycle (wave), period (time), frequency, Hz (cycles per second), hearing limits, amplitude (vertical distance, positive or negative), peak to peak amplitude, etc.
