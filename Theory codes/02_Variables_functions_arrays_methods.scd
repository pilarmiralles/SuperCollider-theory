//2 - VARIABLES, FUNCTIONS, ARRAYS, METHODS

/////////////////////////////////////////////////////////////////////
//VARIABLES:
//Variables are data containers. They represent the data that is assigned to them. Then, operations can be applied to the data through the variables.

//Each variable can contain one value at a time only:
a = 1 //"a" contains an integer when the line is executed.
a = 2 * 1 //"a" can be reassigned to a new value. Now "a" contains the product 2 * 1.

//Variables "a" to "z" are global (non-declared)variables, which can be called from anywhere in the code. The server is assigned to variable "s" by default, so this letter should be avoided in order not to lose the communication with the server.
a = 1
a //"a" alone returns 1 in the post window.

this.dump //Prints (shows in the post window) the "instance of the interpreter": "this" is the keyword normally used for the current instance of something (in instance methods, it refers to the instance itself, in class methods, it refers to the class itself, and here -out of context- it refers to the current instance of the interpreter); the method .dump "prints a detailed low-level representation of the receiver to the post window". What is important from this is that the current instance of the interpreter includes all global variables and the values currently assigned to them (if nothing else, up to this moment it will show that "a" contains integer 1 and "s" contains an instance of the server).

//Declared variables or local variables can only be called within the portion of code they are declared in. They are preceded by the keyword "var", and named with any combination of characters and underscores (beginning with a lower-case letter). Get used to write descriptive names for declared variables, so that your code is understandable for someone else.
(
var value1, value2, power;

value1 = 2; //If we try to evaluate this single line, SC will tell us that the variable "value1" is not defined.
value2 = 16;
power = value1 ** value2 //When executing the entire block, only the result of the last line is shown in the post window.
)

//As mentioned before, the interpreter in SC offers variables a-z as global variables. These variables are, nonetheless, very easy to overwrite accidentally, although they are useful for simple codes and examples. There is another option for global variables that can receive a descriptive name. These variables are not stored in the interpreter but in an environment called "currentEnvironment", a place where global data can be stored. Without getting into detail just now, an environment is a special type of collection containing pairs of keys (tags) and their value (key -> value).
//We can create global variables in the currentEnvironment with the symbol ~ and the variable name we wish to assign:
~variable1 = 1 //(alt gr-4-space in my keyboard for ~).
~variable1 //Contains 1 now.
//(The symbol ~ is indeed a shortcut of this:)
currentEnvironment.put(\variable1, 1);

currentEnvironment //This line prints the current state of the currentEnvironment, which is empty by default and which should show the association variable1 -> 1 by now.
currentEnvironment.clear //With this command, we can clear all the variables created in the currentEnvironment.

//In SC, you can actually create you own environment (IdentityDictionary) with customized key-value associations. More information here: https://doc.sccode.org/Classes/Environment.html


/////////////////////////////////////////////////////////////////////
//FUNCTIONS

//A function is an expression which defines operations that are performed when it is sent the .value and a list of arguments in the order they are declared within the function. The arguments of a function are input values (given from the outside) that make the function flexible (and thus reusable). Functions are expressed between curly brackets. All operations or instructions (separated by semicolons) within a function are executed at once from top to bottom (eager evaluation). The result obtained in the post window will correspond to the last line of code in the function.

//Functions actually have a compilation limit. If they contain more than 256 selectors (class and method names, or functions within the function delimited by curly brackets), they will print an error, but this may refer to a code composed by several thousand lines, which would obviously work better if made “modular”.

//Useless example of a function (because of fixed result):
a = {1 + 1} //When running this line, the function is compiled and assigned to the variable "a". The post window says this is "a Function".
a. value //Now, when applying the method .value to "a", we obtain the result of the function.

//Let's write a less useless example including some arguments. Arguments can be declared within the function by using the keyword "arg" followed by a list of names and values, or by surrounding the list with vertical bars | | (newer syntax). Arguments are always declared before local variables:
( //An entire block of code can be selected at one by double-clicking next to the first / last parenthesis.
f = { |value1 = 1, value2 = 5, deviation = 0.9| //List of argument and their default values (to be replaced by those sent from .value).
	//arg value1 = 1, value2 = 5, deviation = 0.9; //This is the alternative syntax for the list of arguments, outdated, but still widely in use.
	var result; //Declared variable.

	result = value1 + value2;
	result.postln; //We can return the previous line only if applying printing methods, like .postln, which prints and introduces a new line afterwards.
	result = result * deviation //The semicolon is often avoided in the last line of a function, as this is indicating that this line is the last instruction.
}
)

f.value(2, 3, 0.09) //Evaluating the function and sending values to its arguments.
f.value(deviation: 0.99) //Keyword assignment: specifying the arguments in any order. Those that are not specified keep their default value.
f.value(3, value2: 6) //You can mix normal arguments (in order) and keyword arguments.

//Another example: a function to calculate the area of a trapezoid A = ((a + b) / 2) * h:
(
{ |shortBase = 2, longBase = 3, height = 2|
	var area;

	area = shortBase + longBase / 2; //Remember that there is no hierarchy regarding the operations in SC: they will be performed from left to right.
	area = area * height //We could have included this product in the previous line already, but sometimes splitting the operations clarifies the code.

}.value(1, 2, 2) //Method .value applied to the block of code directly because there is no global variable. Functions are usually assigned to variables and called from somewhere else in the code though.
)

//Other examples:
(//This function creates a cluster using pitch classes starting from 0 by default (notice the use of the module 12 to keep the pitch classes between 0 and 11):
c = {
	| fundamental = 0 | //Alternative way of writing the arguments.

	fundamental + [0, 1, 2] % 12 //This will create a three-note cluster.
}
)

c.value(7) //The result is a semitonal cluster of three pitches, [7, 8, 9] in pitch class. The result will be an array, we will study later why.

(//This function calculates the Pythagorean theorem:
{
	arg sideA = 1, sideB = 1;
	var hypotenuse;

	hypotenuse = (sideA.pow(2) + sideB.pow(2)).sqrt

}.value(5, 4)
)

//##############################################################
//Advanced examples:

(//This function calculates the add and mul for the modulation of a parameter between two values. We will study this later on:
d = { arg bottomValue, topValue;
	var mul, add;

	mul = topValue - bottomValue /2;
	add = mul + bottomValue;
	[mul, add] //Using an array here allows to print several results at one within an array.
}
)

d.value(500, 1000) //For instance, a modulation between 500 and 1000 Hz for a sine wave.

(//Applying the former function within a more complex block of code, including the modulation itself. In order to make sound, we need to boot up the server with the key combination Ctrl-B:
{
	var function, mulAdd, freqs;

	//First, a function calculates the mul and add (the variable "function" contains the array with the mul and add values):
	function = { arg bottom, top;
		var mul, add;

		mul = top - bottom /2;
		add = mul + bottom;
		[mul, add]
	};

	//The former function is applied to a real modulation within the same code:
	freqs = Array.fill(2, { rrand(30, 16000) }).sort; //Two random frequencies are created.
	mulAdd = function.value(freqs[0], freqs[1]); //The bottom and top frequencies are applied to the previous function as arguments. The variable mulAdd contains the function's evaluation.
	SinOsc.ar(SinOsc.ar(10, 0, mulAdd[0], mulAdd[1]), 0, 0.1) //The mul and add values are taken from the resulting array of "function" using the index of each one, and applied to a SinOsc whose frequency is being modulated by another SinOsc.

}.play
)

(//This function receives the an overtone number within the overtone series (n) and output the frequency of that overtone in Hz and MIDI based on a fundamental frequency input value (in MIDI). MIDI values are normally based on A = 440 in equal intonation. This is why the results of this function are approximate:
{ arg n, fundFrecMidi = 24; //Fundamental frequency by default = C1 (24 MIDI).
	var hz, midi;

	hz = n * fundFrecMidi.midicps; //Converting the fundamental freq into Hz so that the frequency of the overtone can be calculated as "n * fund freq".
	midi = hz.cpsmidi.round(1); //Converting back the result in Hz (just intonation): the value will need to be rounded when converted back into MIDI.

	[hz, midi]

}.value(8) //Here, as an example, calculating the C4 (8th overtone of the C1 series, hence n = 8).
)

(//This function checks out whether a word (a string of letters) is a palindrome or not:
f = { arg word;
		var original, reverse;

		original = word;

		reverse = word.reverse;

	original == reverse; //Checking equality (same series of characters in the same order).
	}
)

f.value("lol") //The result will be either true or false, as the function consists of a boolean expression.
f.value("tacocat")
f.value("dog")

//The last example is called symmetric difference (see theory about Set later on in this document for a method that performs this same function). It compares two arrays and returns an array containing only the unique elements of each array: for example, comparing [1, 2, 3, 4] and [2, 3, 4, 5], the result should be [1, 5].
//My approach: comparing each element of the first array: asking the second array how many instances are in there of each element of the first array (if no instances, it passes to the final array). The same is done to the other array. Both results are concatenated (united in one single array) at the end, filtering any repeated values:
(
a = { arg array1, array2;
	var result1, result2, finalArray, addition, utmostArray;

	//Comparing the arrays and obtaining the unique values of each:

	result1 = array1.select({ //The method select receives a collection and features a function and two arguments (item and index). The method answers a collection consisting of all items in the receiver for which its function answers "true".
		arg item; //The argument item refers to each element in the collection.
		array2.occurrencesOf(item) == 0 //OccurrencesOf(item) refers to the number of repetitions of the given item within the collection.
	});

	result2 = array2.select({
		arg item;
		array1.occurrencesOf(item) == 0
	});

	finalArray = result1 ++ result2; //Concatenating both results.
	finalArray.postln; //Printing the result at this point just for testing.

	//Filtering repetitions:

	finalArray = finalArray.as(Set); //See theory about Set (this kind of collection does not accept repeated values.
	finalArray = finalArray.as(Array)
}
)

a.value([1, 2, 3, 3, 6, 7, 7], [5, 2, 1, 4, 6, 8, 1]) //The solution should be [3, 7, 5, 4, 8]. It works!
//You could try to create a similar function in which the number of compared arrays is flexible and not just two. See "Symmetric difference algorithmic practice" in the folder of "Codes for specific tasks" for a solution.

//##############################################################


/////////////////////////////////////////////////////////////////////
//METHODS

//As introduced in the previous theory file, a message is a request for an object (the receiver)to perform one of its operations. The way in which this operation is performed is defined by the object's class. Messages represent the way to change an object's state since its implementation is hidden from the client. Messages consist of a message selector (name of the operation) and, in some cases, a list of arguments (input values) which give additional information about the operation (for example, if creating an oscillator, its frequency). A message always returns a result on the post window (by default, the receiver itself).

//Methods are descriptions of the operations necessary to implement a message for a particular class: they tell how to implement messages sent to the instances of a class. In a class, there is a method definition for each message to which the instances of that class respond to: when an object is sent a message, the method whose name matches the message selector in the receiver’s class is executed. Methods may inquire about some property of the receiver, ask the receiver to change its internal state, or ask the receiver to return some computed value.

//There are two main types of methods: class methods are sent to class objects to create instance objects of that class; instance methods are sent to an instance object to modify it or inquire information about it.

//This link might be useful again for the next explanation: https://doc.sccode.org/Guides/WritingClasses.html. Let's see how classes, methods and messages work together:

//Let's imagine these Classes exist:
Sandwich
Ham

//And let's imagine we can apply the following methods to them:
Sandwich
* prepare //Class method (creates the sandwich), indicated with an asterisk.
heat
Up //Instance methods (modify the sandwich):
cut

Ham
* marinate //Class method (creates the ham).
fry //Instance method (modifies the ham).

//The syntax is object - method: receiver.message(arguments):
Sandwich.prepare //The message "prepare" is sent to the class "Sandwich".

//Example of a real class:
s.boot //Remember to boot the server before performing any audio synthesis.
{ SinOsc.ar(440, 0, 0.1, 0) }.play //The class SinOsc receives the message .ar, whose corresponding method asks it to create an audio rate sinewave oscillator signal (class method). It also receives a list of arguments specifying the frequency, phase, and amplitude of the oscillator. The signal is then placed into a function to which the message .play is sent. The method .play, when sent to a function, plays a synth from UGens returned by the function (instance method). When executing the line, we can see in the post window that a synth, an instance of a synth definition, which is a single sound producing unit that runs in the audio server, has been created.

//Now let's see how our imaginary objects would be written in SC's implementation:

//Defining imaginary arguments:
Sandwich{

	//Class method:
	*prepare{ //List of arguments and default values:
		arg extraIngredients = ['tomato', 'cheese'], bread = 'baguette', meat = 'chicken';
	}

	//Instance methods:
	heatUp{ arg temp = 50, time = 120;
	}

	cut{ arg numPieces = 2;
	}
}

SinOsc //Press ctrl + i (and double click on SinOsc in the list): source code of SinOsc (resembling our imaginary example).

//Applying our imaginary methods to our imaginary classes:
Sandwich.prepare(['tomato'], 'baguette', 'tofu')
Sandwich.prepare(meat: 'tofu') //Remember that the keyword assignment allow us to specify any argument in any order by naming it and adding a colon (the rest of the will receive their default value).

//Now adding the other class:
a = Sandwich.prepare(
	['pepper'],
	'baguette',

	Ham.marinate.fry(260) //First argument of the method .fry is temp (for instance): the Help file of the class Ham should indicate what is the unit of temp (just like when applying .ar to SinOsc, it is indicated that the unit of frequency is the Hz).
)

//Applying instance methods:
a = a.heatUp //Now that "a" contains the prepared sandwich, we can heat it up.
a = a.cut(4) //The argument of of .cut is the number of pieces. Here we are cutting the sandwich we prepared and heated up.

//Remember from last theory file the word polymorphism. This is a very important feature of SC and consists of the capacity of different classes to respond to the same message in different ways. For instance, we have seen that the method .ar is used to generate audio rate signals: when sent to SinOsc, it will create a sine oscillator at audio rate, but when sent to LFTri, it will create a triangle oscillator at audio rate instead.


/////////////////////////////////////////////////////////////////////
//COLLECTIONS (ARRAY)

//Collection is an abstract class, meaning that we don't create direct instances of it, but instead we create instances of the many types of collections (subclasses). A collection is always an object containing a series of objects, the elements of the collection. Array is the most used type of collection. It is so common that its class does not need to be written: instead of Array[1, 2, 3], we can just write [1, 2, 3], which will be interpreted as an array by default.
//An array is written between square brackets and its elements are separated by commas. The elements contained within an array can be indexed (meaning that their order matter). The index of each element is an integer starting by 0, which can be used to access this element. Arrays can contain any kind of object and the same obect might appear several times (other collections such as Set do not allow repetition of equal objects). Arrays can be homogeneous (when they contain the same kind of elements, for example, integers) or heterogeneous (when they contain different kinds of elements):

//Homogeneous array of integers:
[1, 2, 3, 4, 5]

//Heterogemeous array (symbol, integer, string and sine oscillator function):
[\symbol, 67, "string", { SinOsc.ar(mul: 0.1) }]

//An array assigned to a global variable:
a = [1, 2, 3, 4, "hello", { SinOsc.ar(mul: 0.1) }]

//Now we can address each element using its index (remember that the first element's index is always 0):
a[0] //= 1
a[4] //= "hello"
a[5].play //Applying the method .play to the function at index 5 (remember to boot the server).
a.at(0) //Method .at: equivalent to a[0]: = 1 again.

//Let's review some class and instance methods that can be applied to arrays:


//CLASS METHODS: class methods for arrays create arrays. These are only the main class methods for arrays:
//Array.fill: creates an array with a specific size by evaluating a function as many times as the size value:

Array.fill(6, { rrand(0, 11) }) //Six random numbers from 0 to 11.

Array.fill(6, { |i| i }) //The function passes an argument, which is the index of each element in the array. We will normally use "i" for this argument, but any name can be given to it. This function just prints the indexes (0 to 5 because the size is 6).

Array.fill(6, { |i| [i, rrand(0, 11)] }) //Array of six arrays containing the index number and a random number from 0 to 11.

//The duplication of "n" times (!n) of a function is equivalent to Array.fill:
({ |i| [i, rrand(0, 11)] } !6) //equal to:
Array.fill(6, { |i| [i, rrand(0, 11)] }) //and it is also equal to the method .dup:
{ |i| [i, rrand(0, 11)] }.dup(6)

//Example of the use of Array.fill in a function: this function provides the frequency of an overtone series for which we can establish the root in Hz and the number of overtones (slots):
(
f = { arg root = 50, slots = 7; //Default values.

	Array.fill(slots, {

		| i |

		(i + 1) * root //Adding 1 to i so that 0 is avoided. This way, we start with the root as first overtone. We can add any number to start from a different overtone in the series.
	});
}
)

f.value(110, 16) //The 16 first overtones of the series from 110 Hz are calculated.

//With this line we can hear the previous overtones, no need to understand the code just yet:
{ SinOsc.ar( EnvGen.ar(Env([110, f.value(110, 16)].flat, 1, \step).circle), 0, 0.1) }.play //The first value needs to be repeated because of the step envelope that is changing the frequency of the sine oscillator, which jumps directly to the second value. We will study envelopes later on.


//Array.series: creates an arithmetic series within an array. Its arguments determine the size of the array, the starting value and the step (a value added to each element of the series, or the distance between the "steps"):

Array.series(12, 0, 1) //Series from 0 to 11 with a step of 1.

Array.series(24, 60, 0.5) //Series representing a scale of quarter tones within an octave from 60 MIDI (for instance, if applied to sound. 0.5 MIDI is equivalent to a quarter tone).

//Visualizing arrays:
x = Array.series(50, 0, 5)
x.plot(discrete: true) //.plot will create a chart. Discontinuous points (discrete).
x.plot(discrete: false) //Continuous line (although the content of the array is still a series of "points"), by default, no need to indicate.
//Key "m" in the keyboard changes the type of graph between the available options.


//Array.geom: The third class method for arrays is Array.geom(size, start, grow): it creates a geometric series. The arguments are the same as in Array.series (size and start), but the third argument is grow, the product (multiplication) for the geometric series, as the step (sum) would be for the arithmetic series.

//It is really useful to calculate frequencies based on a certain interval, using the ratios (numeral relationship between overtones within the overtone series) of each interval (for natural or Pitagoric tuning):
Array.geom(5, 220, 2) //For example, grow = 2 will create octaves (regarding frequency in Hz) --> Five octaves from A3, counting the A3 itself.

//The ratios for each interval in natural tuning can be found in document 4 (with regard to banks of filters), but they can be easily calculated looking at the overtone series.

//It is also useful for speeding up and down processes (for example, applied to rhythms or rates), or for lowering and raising the amplitude in an exponential way. It should be used with caution as the values can grow really fast (depending on the grow argument). Be careful, especially with frequencies and amplitude (always check the content of the array).

//Here inside a variable and plotted to see the exponential line:
f = Array.geom(10, 1, 2)
f.plot(discrete: true)

//INSTANCE METHODS: applied to arrays that already exist:

y = Array.series(12, 0, 1) //An array in a variable.
y.reverse //Retrograded series.
y = y.reverse //Now the variable is reasigned to the retrograded series.
y.scramble //Changes the order of the elements randomly.
y = y.scramble.keep(5) //Trick to choose 5 random numbers from a series without repeating them.
y.sort //Puts the values in upward order (if they are numbers).
y.sort.reverse //Puts the values in opposite order (downwards).

//For very long arrays, in order to see all the elements (for example, if needed to see the last one), we can use:
Array.series(200, 0, 1) //It shows etc... because it is too long, but we can't know the last value.
Array.series(200, 0, 1).asCompileString //This will show all elements (if needed).
Array.series(200, 0, 1).last //This will show just the last element (thus, this line is no longer an array, but just its last value).

e = Array.series(4, 60, 10) //New series.
e = e.mirror //This includes the original + the retrograded (mirror) series.
e.plot(discrete: true) //Sort of triangle in the graph representing the mirror series.

[ 0, 1, 2, 3 ].choose //Chooses one random element from the collection.
[ 0, 1, 2, 3 ].wchoose([ 0.2, 0.3, 0.49, 0.01 ]) //Chooses one random element from the collection according to the probability (out of 1) for each element stated in the second array (which is its argument, an array of ratios for probability). They have to sum 1 in total (100% probability) and there has to be one value per element in the first array (if having fewer elements in the array of weights (probabilities), their values would rotate when applied to the first array until all elements receive a weight value).
[ 0, 1, 2, 3 ].wchoose([ 5, 8, 4, 2 ].normalizeSum) //NormalizeSum converts other values into ratios from 0 to 1, so probability can be calculated easier without summing 1.
[ 0, 1, 2, 3 ].rotate(1) //Rotation of the elements to the right. If using a negative number, they rotate to the left. If using a different number other than 1, they rotate those many slots within the series.

//When applaying arithmetic operations using arrays of different size, as commented before, the values of the small array rotate to be applied to the big array:
//Hence these operations are equal:

[1, 2, 3, 4, 5] + [1, 2, 3]
[1, 2, 3, 4, 5] + [1, 2, 3, 1, 2]

//Other methods:

a = [0, 1, 2, 3, 4]
a = a.add(1000) //Adds the value between parenthesis.
a //Now "a" contains 1000 at the end of the collection.

a = [0, 1, 2, 3, 4, 1000]
a[1] = 2000 //This is the method "put": it puts the indicated value into the indicated index (subsequently removing what was there first).
a[0] = 0.5

b = a.removeAt(1) //Removes the second index (which is index 1, as stated between parenthesis) and returns it in the post-window. "b" is just that index then.
a //"a" is lacking the second element now.

[1, 2, 3, 4, 5].sum //Addition of the elements of the array (only with homogeneous arrays). Could be applied to an array of signals to put them together into the same channel (beware of the sum of amplitudes when adding signals).

//Concatenation of arrays:
k = [1, 2, 3]
l = [100, 200, 300]
k ++ l //The "++" creates a new array putting together the elements of the two former arrays.

//Nested arrays:
n = [0, [1, 2, 3], 4, [5, 6]]

n[1] //Contains the array [1, 2, 3]
n[1][1] //Contains the second index (2) of the array [1, 2, 3], which is the second index of the bigger array.
n[3][1] //Contains the second index (6) of the array [5, 6], which is the fourth index of the bigger array.

//EXERCISES APPLYING METHODS (AND THEIR SOLUTIONS):
//1 - Write an array of 11 elements of different type (heterogeneous) and assign the array to a variable "a":

a = [\hi, 5, 68.midicps, {PinkNoise.ar(0.2)}, 0.1, "hello".scramble, 127, {SinOsc.ar(PinkNoise.ar(180, 270), 0, 0.5)}, 0.00002, {BPF.ar(in: BrownNoise.ar(0.5), rq: 0.05, mul: 1.5)}, \end] //(Very random)

//2 - Assign to the variable "b" the second element of "a":

b = a[1]

//3 - Assign the first element of "a" to the variable "b":

b = a[0]

//4 - Assign to the variable "c" an array containing 24 random values between the range 1 to 12:

c = Array.fill(24, { rrand (1, 12)})

//5 - Assign to the variable "d" an array containing an arithmetic series of 31 numbers, starting by 1000 and growing by 111 steps.

d = Array.series(31, 1000, 111)

//6 - Rotate the former series three slots to the right and reassign the value of "d":

d = d.rotate(3)

//7 - Reassign to "d" the retrograded "d":

d = d.reverse

//8 - Assign to "d" the elements of "d", but changing the order randomly:

d = d.scramble

//9 - Assign to "e" a geometric series of 16 elements, starting by 33, and with a growing factor of 1.5 (series of Pitagoric fifths):

e = Array.geom(16, 33, 1.5)

//10 - Apply to "e" the method .plot (exponential graph):

e.plot

//11 - Assign to "f" an arithmetic series of 16 numbers. The two first numbers of the series must be 24 and 31:

f = Array.series(16, 24, 7)

//12 - Assign to "f" the mirror of "f" and apply a plotter to the result:

f = f.mirror
f.plot

//13 - Apply the method .plot to "f", obtaining a discontinuous line in the graph:

f.plot(discrete: true)

//14 - Change the order of the elements in "f" randomly and apply a plotter to its values, obtaining a continuous and a discontinuous line in the graph:

f = f.scramble
f.plot(discrete:true)
f.plot(discrete:false)//The graph would be continuous by default.

//15 - Create an array of 101 random elements chosen from the elements of an array of the numbers 1 to 5. Each element should have a different probability of been chosen (several options):

Array.fill(101, {[1, 2, 3, 4 ,5].wchoose([0.6, 0.01, 0.29, 0.04, 0.06])}) //First option, directly writing the 1-5 array inside the bigger array as an argument.

Array.fill(101, {Array.series(5, 1, 1).wchoose([0.6, 0.01, 0.29, 0.04, 0.06])}) //Second option, the 1-5 array is created using Array.series.

g = [1, 2, 3, 4, 5]
Array.fill(101, {g.wchoose([0.6, 0.01, 0.29, 0.04, 0.06])}) //Third option, the 1-5 array is written inside a variable, and then used inside the bigger array.

Array.fill(101, {[1, 2, 3, 4 ,5].wchoose([0.6, 0.01, 0.29, 0.04, 0.06])}).histo.plot //Using .histo.plot, we can visualize the probabilities of each value.

//REGARDING COLLECTIONS (ADVANCED)/////////////////////////////////////////

//.SELECT: Answer a new collection which consists of all items in the receiver for which the function answers True. The function is passed two arguments, the item and an integer index:
List[1, 2, 3, 4].select({ arg item, i; item.even });

(//Your example from the Ustvolskaya codes:
var structure, index;

structure = [ "a", "b", "c", "b", "a", "d", "c", "e", "c", "d" ]; //Sections of a piece, for example (for algorithmic composition).

(structure.size.div(2) - 1).do({ //To calculate the number of iterations of .do so it is adapted to any series in the variable "structure": the size of the array of "structure" is asked and divided by 2 (just because in this case, the number of elements of "structure" are going to be deleted 2 by 2), and 1 is substracted so there is a last element of the series that is not eliminated (avoiding the last iteration of .do according to the size of the array).

	index = Array.series(structure.size).scramble.keep(2); //A series with the indexes of the array is created, then the order is changed randomly, and two elements from that random order are chosen (.keep).

	index.do({| i | structure[i] = nil }); //"nil" ("empty") is assigned to the chosen indexes (to the element of the array in those indexes, which will be the indexes of "structure").

	structure = structure.select({| item | item.notNil }).postln //.select returns the elements answering true in its function. In this case, only the elements that are "notNil" are returned. Then, the variable "structure" is reassigned without the elements that were turned into a "nil".
})
)

//there are too many classes within the superclass Collection: THESE are the ones that interest us for now:
SequenceableCollection //Superclass of integer indexable collections, such as ARRAY, LIST, SORTED LIST, etc. (STRING is a RawArray of Characters).
Dictionary //Associative collection mapping keys to values (no order, thus no indexable as Array) = IdentityDictionary (same definition, but only symbols as a key -> identity instead of equality).
Dictionary -> IdentityDictionary -> Environment (name space for functions) -> Event (environment that represents an action) //Used for Pbind.

//INSTANCE METHODS:

List[1, 2, 3, 4].size; //Answers the number of objects contained in the Collection.
List[].isEmpty; //Answer whether the receiver contains no objects.
List[1, 2].add(3); //Add an Object to the receiver (last position).
List[1, 2].addAll(List[3, 4]); //Add all items in a Collection to the receiver.

//The mess of the "remove" method:
(
var a;
a = List[1, 2, 3, 4];
a.remove(3);
a;
) //Remove an Object from the receiver. Returns the new collection.
List[1, 2, 3, 4].removeAll(List[2, 3]); //Remove all items in a Collection from the receiver
List[1, 2, 3, 2, 3, 2, 3, 4].removeEvery(List[2, 3]); //Remove all occurrences of the items in a Collection from the receiver.
(
var a;
a = List[1, 2, 3, 4];
a.removeAllSuchThat({ arg item, i; item < 3 });
a;
) //Remove all items in the receiver for which function answers True. The function is passed two arguments, the item and an integer index. Answers the objects which have been removed.

(
y = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
y.putEach([4, 7], [\smelly, \head]);
y.putEach([2, 3, 5, 6], \wotsits); //It wraps, meaning \wotsits will be applied to all elements of the array of numbers in .putEach (when in the previous one, there was an object for each of the numbers appointed in the first array).
) //Put the values in the corresponding indexes given by keys. If one of the two argument arrays is longer then it will wrap.
(
y = [\a, \b, \c];
y.atAll([0, 2]);
) //Return a collection of all the items for the keys.

//FOR ITERATION (see more in the help doc):
//We saw .select above. There are also (evaluate each to see the effect, and read the help document for clarificationss):
List[1, 2, 3, 4].do({ arg item, i; item.postln }); //do
List[1, 2, 3, 4].collect({ arg item, i; item + 10 }); //collect
List[1, 2, 3, 4].reject({ arg item, i; item.even }); //reject (CONTRARY of .select)
List[1, 2, 3, 4].detect({ arg item, i; item.even }); //detect (also .detectIndex)
List[1, 2, 3, 4].any({ arg item, i; item.even }); //any
List[1, 2, 3, 4].every({ arg item, i; item.even }); //every
List[1, 2, 3, 4].count({ arg item, i; item.even }); //count
List[1, 2, 3, 3, 4, 3, 4, 3].occurrencesOf(3); //occurrencesOf
List[1, 2, 3, 4].sum; //Addition. Also allows a function:
(0..8).sum({ arg item, i; 1 / (2 ** item) });


/* Other methods:

- .asInteger (or .asInt): turns a float into an integer (rounding it down).
- .flat: unifies nested arrays into a single array containing all the elements of the nested arrays.
- .flatten(1): unified a specific number of levels of nested arrays (the argument is the number of unified levels).
- .asStream: sent to objects that are not streams to turn them into streams (patters, envelopes, etc.). Should be used in combination with .next.
- .clump(n): opposite of .flat. Its argument indicates the number of elements (n) that are going to be clumped into nested arrays within a bigger array.
- .stutter(n): its argument indicates the number of repetitions (n) of each element of a given collection.
- .normalizeSum: converts an array of numbers into ratios from 0 to 1 (so the total addition would be always equal to 1). Used with .wchoose or Pwrand, etc.
- .odd, .even, .coin, .isNil, .notNil, .and, .or, etc.: methods for boolean expressions.
- .postln, .plot, .poll, .histo, .trace: they represent values in different ways: POSTLN prints values that are not signals (applied to a signal or any other "alive" thing in the server, it will just indicate that there is a pattern or a synth) / PLOT shows a graph (it needs to be applied to a function, not to a signal without curly brackets / POLL prints values from signals (that are running in the server) at a specific rate (10 values per second by default, can be changed as an argument) / HISTO shows a graph of probabilities / TRACE prints the values given by a pattern (they are "alive", but not like a signal, which uses .poll instead).
Note that .poll can be used alongside a label, so when printing many different values at a time, you can tell which one is from which UGen. Example:
{ LFNoise1.kr.poll(3, "a value"); LFNoise1.kr.poll(5, "another value"); }.play;
- .mod(12): module 12 of all values of a given collection.
- .div(2): divides by 2 (for instance), rounding the result down (always returns integers).
- .min y .max: .min returns only the values below the number given as its argument / .max returns only the values above.
- .lastIndex: indicates which one is the index of the last element of a collection (.size would indicate one more number because it starts by 1, instead of by 0 as the index does).
- .range: calculates the mul / add (or any other value range) needed for a modulation (without the studied calculations, although it is better to understand how it is calculated). For example: LFDNoise3.ar(0.1).range(400, 1200)
- .fork: it is a wraper, that is to say, a Routine + .play (none of those have to be stated because they are contained within .fork, but it is still necessary to use .wait or .yield).
- .linlin is for mapping (y.linlin(-1, 1, 40, 80) = converts the range -1 to 1 of "y" into 40 to 80, with a linear interpolation.
- .linexp is for mapping from linear to exponential (y.linexp(0, 127, 30, 8000), for example, would convert the linearity of the MIDI values from 0 to 127, mapping them into exponential values of frequency between 30 and 8000 Hz), just for instance.
- .drop(-1): eliminates an element from a collection each time it is evaluated. If the collection is reassigned to its variable, it will become smaller: */

~structure = [ "a", "b", "c", "d", "e" ]
~structure = ~structure.drop(-1) //Deletes the elements from the last to the first.
~structure = ~structure.drop(1) //Deletes the elements from the first to the last.
~structure = ~structure.drop(2) //Deletes the elements two by two from the first the last.

//ARRAYS SHORTCUTS:
(0..20) //Array with numbers from 0 to 20.
(60, 60.25..65) //Array with numbers from 60 to 65 with a step of 0.25 between each number.
(10, 10.1..20).cs //.cs (compile string) avoids the .etc in the postwindow when the lists are too big, in case we need to visualize all the values (but be careful because SC saves memory from this with the .etc for a reason).
(rrand(10, 15)..rrand(16, 20)) //Series between numbers from 10 to 20. The low and high limits of the series will be random, from the minimum range (2 possible values from 15 to 16) to the maximum range (11 possible values from 10 to 20).
(rrand(10, 15)..rrand(16, 20)).plot  //Former example, visualized in a graph.
//Some operations can be applied to these arrays as normally. For instance:
pow((0..1000), 2).plot //Series from 0 to 1000 to the power of 2 (plotter = exponential curve, see the graph).
sin((0, 0.1..20)).plot //Sin function (values from -1 to 1 (20 numbers with a step of 0.1 = 2 units from -1 to 1). Two layers of parenthesis are needed for the plot to work (because of the sin function).

//Indexes:
a = [1, 2, 3, 4, 5] //Given this array, you can take part of its indexes only:
a[3..] //From index 3 to last index (remember, it's the index, not the content of the index), including index 3.
a[..3] //From first index to index 3, including index 3.
//Example of function playing with this: Given an array of numbers, return the middle to the end (if two middle numbers, take the second):

(
f = {
	arg array = [1, 2, 3, 4, 5]; //By default, but give your array in "f" (below)
	var size, middle;

	size = array.size;

	if (size.odd, {middle = (size / 2).roundUp - 1}, {middle = size / 2}); //The result of this is an INDEX.

	array[middle.asInt..]

}
)

f.value([1, 2, 3, 4, 5, 6])

//SET (METHODS):
//According to SC help: A Set is s collection of objects, no two of which are equal. Most of its methods are inherited from Collection. The contents of a Set are unordered. You must not depend on the order of items in a set. For an ordered set, see OrderedIdentitySet. Also, all elements in the set, or from outside when applying methods, are checked for equality (not for identity):

Set[1, 3, 7, 4] //This is a set.

//Methods:
Set[1, 2, 3].add(4).postln; //Add an Object to the Set. An object which is equal to an object already in the Set will not be added.
Set[1, 2, 3].remove(3).postln; //Remove an Object from the Set.
Set[1, 2, 3].includes(2).postln; //Returns true if the specified item is present in the Set.
Set[1, 2, 3].findMatch(3).postln; //Returns the item, if it is present in the set. Otherwise returns nil.
Set[1, 2, 3, 300].do({ arg item, i; item.postln }); //Evaluates function for each item in the Set. The function is passed two arguments, the item and an integer index.
a = Set[1, 2, 3]; b = Set[2, 3, 4, 5];
sect(a, b); //Return the set theoretical intersection of this and that. The function will search for objects occurring in both sets and return a new set containing those.
a = Set[1, 2, 3]; b = Set[2, 3, 4, 5];
union(a, b); //Return the set theoretical union of this and that. The function combines the two sets into one without duplicates.
a = Set[1, 2, 3]; b = Set[2, 3, 4, 5];
difference(a, b); //Return the set of all items which are elements of this, but not of that.
a = Set[1, 2, 3]; b = Set[2, 3, 4, 5];
symmetricDifference(a, b); //Return the set of all items which are not elements of both this and that.
a = Set[1, 2, 3, 4]; //Returns true if all elements of this are also elements of that. Since Set is an unordered collection, order doesn't matter in this comparison.
Set[1, 2].isSubsetOf(a); // true
Set[1, 5].isSubsetOf(a); // false
// you can use Set to efficiently remove duplicates from an array:
a = [1, 2, 3, 4, 3, 5, 5, 2, 2, 1];
a.as(Set); // convert to set (and remove duplicates).
a.as(Set).as(Array); // and convert back (order matters again).

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//THE FIRST UGEN: SinOsc:

SinOsc //The simplest oscillatory pattern, equivalent to a spring or a pendulum:

{SinOsc.ar(440, 0, 0.3, 0)}.plot(1/440) //Here the graph (one cycle).

//Arguments:
//1st argument = frequency in Hz. The frequency could be written in Midi, for instance, applying the proper conversion method:

SinOsc.ar(69.midicps, 0, 0.4, 0)

//2nd argument = phase (starting position in the wave): 0 (0) = beginning / 90º (0.5pi) = top point / 180º (1pi) = half period / 270º (1.5pi) = bottom point / 360º (0) = back to the beginning. This is only perceptible when the sine wave is not played at sample rate, but slow enough to hear its shape (for example, when used for a modulation, as LFO).
//3rd argument = mul (from multiplication). The amplitude of the signal is multiplied by that value. Default value is 1 (which means that the amplitude or range of values if applied to a modulation will be -1 to 1), but that is the limit before saturation (distortion). Thus, it is best to write a value below 1 (exceptions will be shown later on). When lowering the mul, the shape of the wave is vertically narrower, the amplitude changes, but not the timbre.
//4th argument = add. It is the vertical position of the wave with respect to its center (by default, and for any signal at audio rate, it will be 0). This default value will be changed when, for example, modulating (using the SinOsc as a LFO).

//The arguments can be changed in a different order (or without needing to specify all of them if the default values suit our needs). We use then the keyword assignment:

SinOsc.ar(mul: 0.1, freq: 330) //The name of the argument is written as a "key" (name:). If using this syntax, all arguments should be written as keys (at least from that argument onward in the list).

//Modulation of arguments (3rd and 4th arguments of SinOsc, or any other signal with mul and add):

({
	a = LFTri.ar(1, 0, 500, 1500); //A triangular wave moves in the graph between 1000 and 2000 Hz each second (up and down).
	a = a.round(125); //This creates little steps of 125 hz within the continuous movement of the wave (1000 / 125 = 8 levels, 7 steps as in a scale from one octave to its higher octave). Without this, the sound of the SinOsc would be continuous. If the modulating wave was another SinOsc instead of a LFTri, the steps would not sound regular (try it).
	c = SinOsc.ar(a, 0, 0.3) //The frequency of the sine wave is modulated by the triangular wave (we can hear now the steps), whose frequency is not at audio rate. The LFTri is being used as a LFO (low frequency oscillator).
}.play
)

//Modulations:
/*In order to modulate a sine wave, for instance, its frequency from 440 to 880 Hz, we use a signal in its frequency argument, and calculate the mul and add of such signal as follows:

1 - Calculate the peak to peak amplitude: top freq - bottom freq: 880 - 440 = 440.
2 - Mul will be equal to the peak to peak amplitude / 2: 440 / 2 = 220.
3 - Add will be equal to mul + bottom freq: 220 + 440 = 660.
*/

//This would be the resulting signal of our calculations: a sinewave modulating from 440 to 880 (back and forth) each 2 seconds (the frequency of the modulating signal is 0.5 or 1/2, thus the modulation will happen within the span of 2 seconds):

(
{
	SinOsc.ar(
		SinOsc.ar(1/2, 0, 220, 660).poll(5), //Modulating signal: .poll shows the change of the frequency values from 660 to 880 to 440 and back to 660.
		0,
		0.2 !2, //This is just a trick to hear it from both sides of the headphones, duplicating the signal.
		0
	)
}.play
)

//Side note: another option to hear the signal through both channels is using Pan2, a UGen for panning. It's first argument is our signal, and its second argument is the position (-1 = left / 1 = right / 0 = center, and everything in between). It automatically turns the signal into stereo, and position = 0 will keep it in the center:

(
{ Pan2.ar(
	SinOsc.ar(440, 0, 0.1),
	0 //Panned to the center, the signal comes through both sides of the stereo equally (center).
)
}.play
)

//Remember that the phase argument (the 2nd one) will only be noticeable when changing it in the modulating signal (for example, in here, if needing to start from 880 instead of 660, which is the center frequency corresponding to phase = 0, the soundwave should start with a phase = 0.5pi).

//The mul of the "carrier" signal should still be between 0 and 1. Here is a different way to control the mul: mul is equal to 1 (by default), but the whole signal is multiplied by 0.1, so the mul will drop to that value:
(
{
	SinOsc.ar(
		SinOsc.ar(1/2, 0.5pi, 220, 660), //Starting by the top frequency as phase = 0.5pi.
		0,
		1 !2,
		0
	) * 0.1 //This changes the amplitude of the whole signal.
}.play
)

//Here, you can actually visualise what happens to the soundwave when changing the mul and add values (do not play these functions!):
({
	[
		SinOsc.ar(440, 0, 1), //Modifying the mul only: the amplitude changes.
		SinOsc.ar(440,0, 4),
	]
}.plot(1/440, minval: -5, maxval: 5) //Displaying one cycle of the sine wave within amplitude values -5 to 5.
)

({
	[
		SinOsc.ar(440, 0, 50, 0), //Now same mul, but different add: the soundwave is displaced upwards.
		SinOsc.ar(440, 0, 50, 100)
	]
}.plot(1/440, minval: -150, maxval: 150)
)

//Now we can modulate other parameters apart from the frequency: here, the amplitude is also modulated from 0 to 0.5 mul. Compare the frequencies of each modulating signal:

(
{SinOsc.ar
	(SinOsc.ar(1/10,1.5pi, 100, 400), //The modulation of the frequency is completed each 10 seconds.
		0,
	SinOsc.ar(2, 0, 0.25, 0.25) //The modulation of the amplitudes occurs two times per second.
	)
}.play
)

//The frequency of the modulating signal has to be below 20 Hz. Otherwise, it would become a frequency modulation or FM. The same happens with the amplitude modulation, which would bring about AM (or Ring modulation depending on the depth).

{SinOsc.ar(SinOsc.ar(880, 1.5pi, 100, 400), 0, 0.1 !2)}.play //Quick example of frequency modulation (there can be heard more than one frequency).

//Last but not least, it is possible to modulate the frequency of the modulating signal, so its speed, so to say, will be variable (will modulate)

(
{
	SinOsc.ar(
		SinOsc.ar(
			SinOsc.ar(1/5, 0, 2, 3), //The frequency of the modulating signal will change in the span of 5 seconds from 1 to 5 times per second.
			0.5pi,
			220,
			660).poll,
		0,
		0.1 !2,
		0
	)
}.play
)


//#############################################################################
//Some extra remarks on style guidelines and issues with arguments grammar:

//ARG vs || when and argument receives an array:
//I found an example in which arg and the recommended grammar to replace that outdated way of writing arguments, ||, behave differently when they are sent an array as default value.
//See the last example for a possible solution: using an array of literals. This kind of array is preceded by a #. It is created at compile time and can't be altered at run time (it can be used, therefore, and for instance, to send array to the arguments of a SynthDef, though these arrays can't be modified regarding their size once the SynthDef has been compiled). Find more information in the "Arrays" chapter of this link: https://doc.sccode.org/Reference/Literals.html. In fact, in the last example, we are sending a bigger array than the one stated in the arguments by default. Nonetheless this is not an issue because the function is "compiled" each time if the input argument is an array of size 10, then the fixed array will have a size of 10 as well).

//DOES NOT WORK WITH ||
(
{ |array = [1, 2, 3, 4, 5]|
	var size, middle;

	size = array.size;

	if (size.odd, {middle = (size / 2).roundUp - 1}, {middle = size / 2});

	array[middle.asInteger..]

}.value([1, 2, 3, 4, 5, 6, 7])
)

//SAME FUNCTION, DOES WORK WITH ARG
(
{ arg array = [1, 2, 3, 4, 5];
	var size, middle;

	size = array.size;

	if (size.odd, {middle = (size / 2).roundUp - 1}, {middle = size / 2});
	array[middle.asInteger..]

}.value([1, 2, 3, 4, 5, 6, 7])
)

//DOES WORK, WITH NO DEFAULT ARRAY
(
{ |array|
	var size, middle;

	size = array.size;

	if (size.odd, {middle = (size / 2).roundUp - 1}, {middle = size / 2});

	array[middle.asInteger..]

}.value([1, 2, 3, 4, 5, 6, 7])
)

//DOES WORK: USING AN ARRAY OF LITERALS
(
{ |array = #[1, 2, 3, 4, 5]|
	var size, middle;

	size = array.size;

	if (size.odd, {middle = (size / 2).roundUp - 1}, {middle = size / 2});

	array[middle.asInteger..]

}.value([1, 2, 3, 4, 5, 6, 7])
)

//#############################################################################

//IGNORE THIS:
//Bonus code (so GitHub doesn't turn my file into markdown):

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
