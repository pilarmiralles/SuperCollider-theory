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
//When searching for a method's help file, the help browser will show a list of the classes that can respond to that message, and thus lead to how the method is implemented in each of them.


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

//The duplication of "n" times (!n) of a function is equivalent to Array.fill (more on duplicating functions in the next theory file):
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


//Array.geom: creates a geometric series within an array. Its arguments determine the size of the array, the starting value and the grow (a valued by which each element of the series is multiplied):

Array.geom(5, 220, 2) //Series of five octaves from 220 Hz, if applied to sound. Array.geom is quite useful when working with ratios such as musical intervals.
//Array.geom is also very useful for processes of speeding up and slowing down, or for any kind of process of increasing or decreasing some kind of value exponentially.

//Let's visualize the geometric series as well:
y = Array.geom(10, 1, 1.5)
y.plot(discrete: true)
y.plot //Continuous by default.


//Some other class methods for Array (see the complete list at: https://doc.sccode.org/Classes/Array.html):
Array.interpolation(5, 3.2, 20.5) //Size, start, end: covers the given range in the indicated number of steps (interpolated values between start and end).
Array.rand(8, 1, 100) //Size, minVal, maxVal: creates an array with a number (size) of random values (uniform distribution) between the minVal and maxVal.
Array.rand2(8, 100) //Size, val: random values from -val to val.
Array.linrand(8, 1, 100) //Size, minVal, maxVal: linear distribution.
Array.exprand(8, 1, 100) //Size, minVal, maxVal: exponential distribution (cannot depart from or cross 0 in its range values).
Array.fib(5) //Array of fibonacci series: size, a, b, where "b" is the starting value and "a" is the starting step value so that the second value will be a + b (default values are a = 0 and b = 1).


//INSTANCE METHODS: instance methods for arrays modify arrays that have been already created. These are only a few examples of them:

z = Array.series(12, 0, 1) //Creating an array assigned to a global variable.
z.reverse //Retrograded series.
z = z.reverse //Reassigned to the variable.
z.scramble //Random change of the order of the elements.
z = z.scramble.keep(5) //Reassigning a scrambled series and keeping only the first 5 elements. When receiving a negative value, keeps the "n" last elements.
z.sort //Values in upward order.
z.sort.reverse //Values in downward order.
z.mirror //Original and retrograded series put together.

z = Array.series(12, 0, 1) //Let's refresh.
z.drop(1) //Deteles the first element.
z = z.drop(1) //Deletes successively from the first element.
z.drop(-1) //Deletes the last element.
z = z.drop(-2) //Deleting two elements successively from the last element.

Array.series(200, 0, 1) //Very long array: cannot see all elements when printed.
Array.series(200, 0, 1).asCompileString //The array will be entirely printed (also shortcut .cs). Need to be careful with this tho, as SC saves memory for a reason.
Array.series(200, 0, 1).last //We can ask to see just the last element.
Array.series(200, 0, 1).lastIndex //Shows the index of the last element (in this case, same value).

[0, 1, 2, 3].choose //Chooses one random element from the collection.
[0, 1, 2, 3].wchoose([0.2, 0.3, 0.49, 0.01]) //Chooses one random element according to the probability shown in the argument "weights" (total sum of 1). The weights arguments needs a probability value for each element in the array.
[0, 1, 2, 3].wchoose([5, 8, 4, 2].normalizeSum) //Using the method .normalizeSum to turn any values into ratios between 0 and 1.
h = [0, 1, 2, 3].rotate(1) //Rotate elements one space to the right, assigned to variable "h".
h = h.rotate(-2) //Rotate elements two spaces to the left successively.
[1, 2, 3, 4, 5].sum //Addition of the elements of an homogeneous array. Could be used to sum an array of signals into one channel, for example (beware the amplitude).
[3, 4, 1, 1].integrate //Returns a collection with the incremental sums of all elements.
[3, 4, 1, 1].differentiate //Returns a collection with the pairwise difference between all elements (so 3, 4-3, 1-4 and 1-1, the first one remains untouched).
[3, 4, 1, 1].neg //Many unary operator methods can be applied to an array and will be applied to each of its elements (.neg, .reciprocal, .abs, .asFloat, .asInteger, .floor, .squared, .cubed, .sqrt, .midicps, .midiratio, .dbamp, .log, .sin, .cos, .tanh, .distort, .even, .odd, .isPositive, .isNegative, .magnitude, etc.)
//See other mathematical methods and functions in the Help file of SequenciableCollection.

//Arithmetic operations between arrays of different sizes:
[1, 2, 3, 4, 5] + [1, 2, 3] //Next line is equal to this one:
[1, 2, 3, 4, 5] + [1, 2, 3, 1, 2] //The values in the short array are looped to cover all values in the long array.

a = [0, 1, 2, 3, 4]
a.first //Simply asks for the first element of the collection.
a.last //Returns the last element of the collection.
a = a.add(1000) //Adds a new element at the end of the collection. Reassigning the variable.
a[1] = 2000 //Method "put", replaces a new element at the indicated index, removing the previous one.
a.put(1, 2000) //Another option for the method .put (arguments are the index and the new element). There is also .putFirst and .putLast.
a.indexOf(2000) //Returns the index of the indicated element (lots of other methods to specify this further).
b = a.removeAt(1) //Removes the element at the indicated index and returns it on the post window. Now assigned to "b".
b //"b" contains 2000.
a //"a" does not contain 2000 anymore.
y = [7, 8, 7, 6, 5, 6, 7, 6, 7, 8, 9]
y.findAll([7, 6]) //Returns an array with all the indexes at which the specific sequency is found.
y = y.swap(1, 2) //Swaps the elements in the indicated indexes and return the new collection.

//Concatenation of arrays:
k = [1, 2, 3]
l = [100, 200, 300]
k ++ l //Concatenation (an array containing all elements of the two arrays).

//Nested arrays:
n = [0, [1, 2, 3], 4, [5, 6]]
n[1] //Contains array [1, 2, 3].
n[1][1] //Contains second index (2) of array [1, 2, 3].
n[3][1] //Contains second index (6) of the array [5, 6].
n.flat //Unifies nested arrays into a single array.

m = [0, [1, [3, 4], 2, 3], 4, [5, 6]]
m.flatten(1) //Unifies nested arrays by levels (from outer to inner).
m = m.flatten(2) //All levels cleared. Reassigning the variable.
m.clump(3) //Opposite of .flat: groupes elements of an array into smaller inner arrays (the argument indicates the number of elements per array).
m.stutter(2) //Repeats each element of the array as many times as indicated in its argument.

//Shortcuts for arrays and operations:
(0..20) //Array from 0 to 20 (step of 1).
(60, 60.25..65) //Array from 60 to 65 (step of 0.25).
(rrand(10, 15)..rrand(16, 20)) //Array between a random value between 10 and 15, and a random value between 16 and 20 (step of 1).
pow((0..1000), 2).plot //Applying the power of 2 to an array from 0 to 1000, then visualizing it (exponential curve).
sin((0, 0.1..20)).plot //Applying a sin function (values from -1 to 1). There are two leyers of parenthesis, one for the array, the other, for the sin function.

//Indexes:
j = [1, 2, 3, 4, 5] //Given this array:
j[3..] //Taking indexes from fourth element to the last (including the fourth).
j[..3] //Taking indexes from the first element up to the fourth (including the fourth).
//Example of a function using the index notation (advanced, using booleans): given an array of integers, return the middle to the end (if two middle numbers, that is, if even number of elements, take the second):
(
f = {
	arg array;
	var size, middle;

	size = array.size;

	if (size.odd, {middle = (size / 2).roundUp - 1}, {middle = size / 2}); //The result of this is an index.

	array[middle.asInt..]
}
)

f.value([1, 2, 3, 4, 5, 6])


//###############################################################################
//EXERCISES WITH ARRAYS AND METHODS (AND SOLUTIONS):

//1) Write an array of 11 elements of different type (heterogeneous) and assign the array to a variable "a":
a = [\hi, 5, 68.midicps, {PinkNoise.ar(0.2)}, 0.1, "hello".scramble, 127, {SinOsc.ar(PinkNoise.ar(180, 270), 0, 0.5)}, 0.00002, {BPF.ar(in: BrownNoise.ar(0.5), rq: 0.05, mul: 1.5)}, \end] //(Very random)

//2) Assign to the variable "b" the second element of "a":
b = a[1]

//3) Assign the first element of "a" to the variable "b":
b = a[0]

//4) Assign to the variable "c" an array containing 24 random values between the range 1 to 12:
c = Array.fill(24, { rrand (1, 12) })

//5) Assign to the variable "d" an array containing an arithmetic series of 31 integers, starting from 1000 and going up by steps of 111:
d = Array.series(31, 1000, 111)

//6) Rotate the former series three slots to the right and reassign the value to "d":
d = d.rotate(3)

//7) Reassign to "d" the retrograded version of "d":
d = d.reverse

//8) Assign to "d" the elements of "d", but changing the order randomly:
d = d.scramble

//9) Assign to "e" a geometric series of 16 values, starting from 33 and with a growing factor of 1.5 (series of Pitagoric fifths, if applied as intervals):
e = Array.geom(16, 33, 1.5)

//10) Apply to "e" the method .plot and observe:
e.plot

//11) Assign to "f" an arithmetic series of 16 integers. The two first values of the series must be 24 and 31:
f = Array.series(16, 24, 7)

//12) Assign to "f" the mirrored version of "f". Then, apply a plotter to the result:
f = f.mirror
f.plot

//13) Apply the method .plot to "f", obtaining a discontinuous line in the graph:
f.plot(discrete: true)

//14) Change the order of the elements in "f" randomly and apply a plotter to its values obtaining a continuous and a discontinuous line in the graph:
f = f.scramble
f.plot(discrete: true)
f.plot(discrete: false)//The graph would be continuous by default.

//15) Create an array of 101 random values chosen from the elements of an array of integers 1 to 5. Each element should have a different probability of been chosen (several options):
Array.fill(101, { [1, 2, 3, 4 ,5].wchoose([0.6, 0.01, 0.29, 0.04, 0.06]) }) //First option, directly writing the 1-5 array within the outer array as an argument.

Array.fill(101, { Array.series(5, 1, 1).wchoose([0.6, 0.01, 0.29, 0.04, 0.06]) }) //Second option, the 1-5 array is created using Array.series.

g = [1, 2, 3, 4, 5]
Array.fill(101, { g.wchoose([0.6, 0.01, 0.29, 0.04, 0.06]) }) //Third option, the 1-5 array is assigned to a variable, and then used inside the outer array.

//###############################################################################

//See more about methods and other types of collections after the following section, at the end of this document.


/////////////////////////////////////////////////////////////////////
//FIRST UGEN: SINE WAVE OSCILLATOR (SinOsc)

//In the previous theory file we learnt that Unit Generators (UGens) are classes that represent calculations with signals, that is to say, they create or process signals. Signals are created by sending one of the following class methods to a UGen: .ar for audio rate signals, .kr for control rate signals or, sometimes, .ir for initial rate signals, returning a new instance of the UGen class that calculates the signal at audio or control rate, or only once at initalization (some UGens create signals when responding to the method .new). The input parameters of a UGen, that is, its arguments, are given in the documentation of its class (help file).
//Find some basic concepts here: https://doc.sccode.org/Guides/UGens-and-Synths.html

//https://doc.sccode.org/Guides/Tour_of_UGens.html (guide of most common UGens, useful to find resources).
UGen //Open the help file (Ctrl-D).

//Let's delve into one of the most essential UGens: SinOsc, the sine wave oscillator (simplest oscillatory pattern, equivalent to a spring or a pendulum):
SinOsc

//Visualization of a sine wave at 440 (one cycle: try out a different number of cycles). For now, this is a mono signal:
{ SinOsc.ar(440) }.plot(1/440) //(Executing this line will boot up the server).

//.ar and .kr: audio rate signals run by default at 44100 samples per second (sample rate), whereas control rate signals generate one sample value for every 64 sample values of an audio rate signals (they use fewer computational resources than audio rate signals):
{ [SinOsc.ar(1000), SinOsc.kr(1000)] }.plot(0.01) //The .kr signal suffers from downsampling.

//Arguments of .ar method, that is to say, parameters or input values of the instance created by sending that method to its class:
//Those are: freq, phase, mul and add.
SinOsc.ar(67.midicps, 0, 0.2, 0)
/*
- Freq: the frequency is 440 Hz by default. It is calculated in Hz, but we can apply conversion methods if wanting to specify it, for instance, in MIDI (see the example above).
- Phase: the phase is measured in radians (0 = center, 0.5pi = 90º = top, 1pi = 180º = center or half cycle, 1.5pi = 270º = bottom, 2pi = 360º = back to center, start of new cycle, and everything in between these values). The phase is normally significant only when using the signal as an LFO (for modulations, which will be explained later on). Otherwise, changes in the phase do not modify what we hear (except for phase cancellation situations).
- Mul: the mul value is 1 by default. This values is a constant value by which the output of the UGen is multiplied, corresponding to scaling its amplitude in the case of a signal that is meant to be heard. 1 is usually the limit before saturation. When lowering the mul, the shape of the sound wave is vertically narrower.
- Add: the add value is 0 by default. This value is a constant value added to the output of the UGen. It affects the position of the sound wave with respect to the "y" axis (DC offset or mean amplitude value). When the signal is meant to produce sound, this value is usually kept at 0.
*/

//Remember that the arguments can be specified in a different order by using the keyword assignment:
SinOsc.ar(mul: 0.1, freq: 330)

//Some more demonstration of the concept of phase and phase inversion (LFSaw will be studied later, but it is just a sawtooth wave oscillator):
{ LFSaw.ar(40, 0, [1, -1]) }.plot(0.1) //Inverting the phase means multiplying every sample by -1. Here, one sawtooth wave is inverted and the other one is not, which would bring about phase cancellation.
{ LFSaw.ar(40, 0, [1, -1]).sum }.plot(0.1) //If both signals are added, there is nothing left in the graph, and no sound.

//Calculating the phase in degrees rather than radians:
2pi.magnitude.raddeg //0 to 6.28 with magnitude (0-2pi) which is the value itself (2 * 3.14...), then converting it to degrees (360 degrees).
360.degrad //And vice-versa, degrees to floats (we won't obtain "2pi", but the magnitude float is equivalent).

//Comparison: change of mul and change of add:
(
{
	[
		SinOsc.ar(440, 0, 1), //Different mul: the function is narrower/wider.
		SinOsc.ar(440,0, 4),
	]
}.plot(1/440, minval: -5, maxval: 5) //Displaying one cycle of the sine wave within amplitude values -5 to 5.
)

(
{
	[
		SinOsc.ar(440, 0, 1, 0), //Same mul different add: the function moves upward (DC offset).
		SinOsc.ar(440, 0, 1, 2)
	]
}.plot(1/440, minval: -3, maxval: 3) //Displaying one cycle of the sine wave within amplitude values -3 to 3.
)

//Function.play: as mentioned in the previous theory file, UGens only work within a UGen function. Therefore, in order to produce sound, we can apply the method .play to a function containing our UGen ({}.play creates a synthesizer, as the help file explains: the method .play, when applied to a function, "plays a Synth from UGens returned by the function. The function arguments become controls that can be set afterwards"). See information about the arguments of .play in the Funcion help file --> .play:
{ SinOsc.ar(67.midicps, 0, 0.2, 0) }.play //(Remember to boot up the server by pressing Ctrl-B).


//Low frequency modulation (below 20 Hz): a modulation is the periodic or aperiodic modification of a parameter of a signal, the carrier signal (normally, by using another signal, the modulating signal):
(
{ var modulating, carrier;

	modulating = SinOsc.ar(1, 0, 500, 1500); //If the center (add) is 1500, the range of the modulation will be 1000 to 2000 (1500 - 500 and 1500 + 500). The modulation between this range is produced 1 time per second (for a 2-second long modulation, for instance, the frequency would be 1/2, which means 1 cycle in 2 seconds).
	modulating = modulating.round(125); //Splitting the range of modulation into "steps" of 125 using .round (when this method's argument is above 1, it rounds to the multiples of this number). This will produce 8 steps (peak-to-peak amplitude = 1000, 1000/125 when being round = 8).

	carrier = SinOsc.ar(modulating, 0, 0.2, 0) //The modulating signal is applied to the frequency of the carrier, thus its values are frequency in Hz (one octave of range).

}.play
)
//The duration of each step is not equal because of the curve of the sine wave that is the modulating signal. If we used a triangle wave, the wave shape would be completely linear and each step would feature the same duration. In addition to this, steps of equal number of Hz mean that in higher frequencies there is a smaller freq difference between steps and in lower frequencies there is a larger difference (as frequency in Hz behaves exponentially: for instance, each octave is calculated by multiplying the current frequency by 2).

//Stereo signal two ways: these are a couple of quick solutions for now in order to get a stereo signal:
(
{ var modulating, carrier;

	modulating = SinOsc.ar(1, 0, 500, 1500);
	modulating = modulating.round(125);

	carrier = SinOsc.ar(modulating, 0, 0.2 !2, 0) //Duplicator (applied to the mul argument).
	//carrier = SinOsc.ar(modulating, 0, 0.2, 0).dup(2) //The method .dup would be equal to the previous option.

}.play
)

(
{ var modulating, carrier;

	modulating = SinOsc.ar(1, 0, 500, 1500);
	modulating = modulating.round(125);

	carrier = Pan2.ar(SinOsc.ar(modulating, 0, 0.2, 0), 0) //Pan2, "a two channel equal power pan" (arguments: "in" is the input signal, "pos" is the position within the stereo field: 0 = center, -1 = left, 1 = right, and everything in between). A possition of 0 allows us to obtain a stereo signal (in the center).

}.play
)

//Calculation of mul / add for modulations (example 440-880 Hz):
/*
mul = high limit - low limit / 2 (in our example, = 220).
add = mul + low limit (in our example, = 660).
*/
//There are methods that calculate the range (method .range), but understanding how this is actually calculated is very useful to understand how signals work.

//Former range calculation applied to signals: observe the numbers printed by .poll to check the low and high limits of the modulation (440-880). The method .poll prints the output of a current running signal (in this case, its frequency). Its first argument is the number of values printed per second (10 is the default):
(
{
	SinOsc.ar(
		SinOsc.ar(1/2, 0, 220, 660).poll(10), //As this is a low frequency modulation, we can perceive differences when changing the phase value (offset of the modulation: 0.5pi will start the modulation at 880 Hz, 1pi will start at 660, but going downwards first, 1.5pi will start the modulation at 440 Hz, etc.).
		0,
		0.2 !2,
		0
	)
}.play
)

//Alternative: method .range: same result:
(
{
	SinOsc.ar(
		SinOsc.ar(1/2, 0).range(440, 880).poll(10),
		0,
		0.2 !2,
		0
	)
}.play
)

//Modulating the amplitude at low frequency:
(
{
	SinOsc.ar(
		SinOsc.ar(1/10,1.5pi, 100, 400), //Low frequency modulation applied to frequency (between 300 and 500 Hz).
		0,
		SinOsc.ar(2, 0, 0.25 !2, 0.25) //Low frequency modulation applied to amplitude (values should be still between 0 and 1, here between 0 and 0.5).
	) * 0.5
}.play
)

//In a low frequency modulation, the objective is not to create new frequency spectrums. When modulating a signal at a frequency of over 20 Hz, a new spectrum starts to be perceptible (in FM, AM, ring modulation, etc.):
{ SinOsc.ar(SinOsc.ar(80, 0, 1200, 1000), 0, 0.1 !2) }.play //Frequency modulation (FM performed at 80 Hz).
{ SinOsc.ar(1000 + SinOsc.ar(80, 0, 1200), 0, 0.1 !2) }.play //Equal to the previous expression (frequency modulation will be studied later on).

//Adding more levels of modulation:
(
{
	SinOsc.ar( //Carrier signal.
		SinOsc.ar( //Low frequency modulation of the frequency (between 440-880 Hz).
			SinOsc.ar(1/5, 0, 2, 3), //Modulating the frequency at which the modulation occurs (1-5 times per second). This modulation takes place over 5 seconds.
			0.5pi,
			220,
			660),
		0,
		0.1 !2,
		0
	)
}.play
)


/////////////////////////////////////////////////////////////////////
//MORE ON COLLECTIONS AND METHODS (ADVANCED)

//There are too many classes within the superclass Collection. These are some of the ones I have used so far:
SequenceableCollection //Superclass of integer indexable collections, such as ARRAY, LIST, SORTED LIST, etc. (STRING is a RawArray of Characters).
Dictionary //Associative collection mapping keys to values (no order, thus no indexable as Array). IdentityDictionary: same definition, but only symbols as a key -> identity instead of equality.
Dictionary -> IdentityDictionary -> Environment (name space for functions) -> Event (environment that represents an action) //Used for Pbind.
Set //A Set is s collection of objects, no two of which are equal. The elements in Set are unordered.

//LIST
//List uses an array in its implementation and is in many cases interchangeable with one.

//Some more instance methods:
List[1, 2, 3, 4].size; //Answers the number of objects contained in the Collection.
List[].isEmpty; //Answers whether the receiver contains no objects (true / false).
List[1, 2].add(3); //Adds an Object to the receiver (last position).
List[1, 2].addAll(List[3, 4]); //Adds all items in a Collection to the receiver (last position).

//#################################
//The mess of the "remove" method:
(
var a;
a = List[1, 2, 3, 4];
a.remove(3);
a;
) //Removes an Object from the receiver. Returns the new collection.

List[1, 2, 3, 4].removeAll(List[2, 3]); //Removes all items in a Collection from the receiver. Returns the new collection.s

List[1, 2, 3, 2, 3, 2, 3, 4].removeEvery(List[2, 3]); //Removes all occurrences of the items in a Collection from the receiver. Returns the new collection.

(
var a;
a = List[1, 2, 3, 4];
a.removeAllSuchThat({ arg item, i; item < 3 });
a;
) //Removes all items in the receiver for which function answers true. The function is passed two arguments, the item and an integer index. Returns the objects which have been removed.
//#################################

(
y = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
y = y.putEach([4, 7], [\yup, \yip]);
y.putEach([2, 3, 5, 6], \yep); //It wraps, meaning \yep will be applied to all elements of the array of numbers in .putEach (when in the previous one, there was an object for each of the numbers appointed in the first array).
) //Puts the values in the corresponding indexes given by keys. If one of the two argument arrays is longer then it will wrap.

(
y = [\a, \b, \c];
y.atAll([0, 2]);
) //Returns a collection of all the items at the indicated indexes.

//Iteration methods (see more in the help doc). Evaluate each method to see the result:
List[1, 2, 3, 4].do({ arg item, i; item.postln }); //do (always returns the receiver).
List[1, 2, 3, 4].collect({ arg item, i; item + 10 }); //collect (like .do, but collects the results within an array).
List[1, 2, 3, 4].reject({ arg item, i; item.even }); //reject (CONTRARY of .select, see .select at the end of this list).
List[1, 2, 3, 4].detect({ arg item, i; item.even }); //detect (also .detectIndex), returns only the first item for which the function answers true.
List[1, 2, 3, 4].any({ arg item, i; item.even }); //any (checks for any occurences of the function's condition).
List[1, 2, 3, 4].every({ arg item, i; item.even }); //every (checks if every element meets the function's condition).
List[1, 2, 3, 4].count({ arg item, i; item.even }); //count (return the number of elements meeting the function's condition).
List[1, 2, 3, 3, 4, 3, 4, 3].occurrencesOf(3); //occurrencesOf (returns the number of occurrences of a specific item in the collection).
List[1, 2, 3, 4].sum; //Addition of the items of the collection. Also allows a function, in which case, will return the sum of the results of function evaluated for each item in the receiver:
(0..8).sum({ arg item, i; 1 / (2 ** item) });
//Method .select: retunrs a new collection which consists of all items in the receiver for which the function answers true. The function is passed two arguments, the item and an integer index:
List[1, 2, 3, 4].select({ arg item, i; item.even });

//Example of .select applied to algorithmic composition: two sections of a series of sections are randomly chosen and gradually eliminated:
(
var structure, index;

structure = [ "a", "b", "c", "b", "a", "d", "c", "e", "c", "d" ]; //Sections of a piece, for instance.

(structure.size.div(2) - 1).do({ //To calculate the number of iterations of .do so it is adapted to any series in the variable "structure": the size of the array of "structure" is asked and divided by 2 (just because in this case, the number of elements of "structure" are going to be deleted 2 by 2), and 1 is subtracted so that there is a last element of the series that is not eliminated (avoiding the last iteration of .do according to the size of the array).
	//Note: this works for an even number of sections, but when odd, the -1 shouldn't be applied. This could be adapted by using a conditional for the receiver of .do.

	index = Array.series(structure.size).scramble.keep(2); //A series with the indexes of the array is created, then the order is changed randomly, and two elements from that random order are chosen (.keep).

	index.do({| i | structure[i] = nil }); //"nil" ("empty") is assigned to the chosen indexes (to the element of the array in those indexes, which will be the indexes of "structure").

	structure = structure.select({| item | item.notNil }).postln //.select returns the elements answering true in its function. In this case, only the elements that are "notNil" are returned. Then, the variable "structure" is reassigned without the elements that were turned into a "nil".
})
)

//SET
//Set is a collection of objects, no two of which are equal. It is also an unordered collection (there is a different class for ordered sets, OrderedIdentitySet). Also, all elements in the set, or from outside when applying methods, are checked for equality (not for identity):

Set[1, 3, 7, 4, 1] //This is a set. As 1 is repeated, it returns the collection with one occurrence of that item only.

//Some instance methods:
Set[1, 2, 3].add(4) //Adds an item to the Set. An item which is equal to an item already in the Set will not be added. The position of the item does not matter.
Set[1, 2, 3].remove(3)//Removes an item from the Set.
Set[1, 2, 3].includes(2) //Returns true if the specified item is present in the Set, and false otherwise.
Set[1, 2, 3].findMatch(3) //Returns the item, if it is present in the set. Otherwise returns nil.
Set[1, 2, 3, 300].do({ arg item, i; item.postln }); //Evaluates the function for each item in the Set. The function is passed two arguments, the item and an integer index (although the index is not deterministic in a Set).
a = Set[1, 2, 3]; b = Set[2, 3, 4, 5];
sect(a, b); //Returns the Set theoretical intersection of this and that. The function searches for items occurring in both sets and returns a new Set containing those.
a = Set[1, 2, 3]; b = Set[2, 3, 4, 5];
union(a, b); //Returns the Set theoretical union of this and that. The function combines the two sets into one without duplicates.
a = Set[1, 2, 3]; b = Set[2, 3, 4, 5];
difference(a, b); //Returns the Set of all items which are elements of this, but not of that.
a = Set[1, 2, 3]; b = Set[2, 3, 4, 5];
symmetricDifference(a, b); //Returns the Set of all items which are not elements of both this and that.
a = Set[1, 2, 3, 4]; //Returns true if all elements of this are also elements of that. Since Set is an unordered collection, order doesn't matter in this comparison:
Set[1, 2].isSubsetOf(a); // true
Set[1, 5].isSubsetOf(a); // false
// you can use Set to efficiently remove duplicates from an array, although the order can suffer modifications:
a = [1, 2, 3, 4, 3, 5, 5, 2, 2, 1];
a.as(Set); // convert to set (and remove duplicates).
a.as(Set).as(Array); // and convert back (order matters again).

//Account of methods for printing values:
/*
.postln: prints a string representation of the receiver followed by a new line. It is most useful when applied to operations that are not running in the server (if applied to a signal, it will just acknowledge the object).
.plot: shows a graph (GUI, graphical user interface) when sent to a Ugen or Array of UGens function. The plot is calculated in real time, and the duration represented by the plot can be specified in its first argument.
.poll: polls the output of a UGen (signals running in the server) every interval seconds and posts the result. Its first argument is the number of results printed per second, which is 10 by default. The second argument is a label, a string that can help identifying values if printing several different values at the same time.
.histo: applied to a collection, shows a graph of probabilities (histogram) by counting the number of values that fall into each of the steps subdivisions, being the default 100, between min and max values (those values can be specified or left by default as the smallest and largest values in the collection). It needs to be plotted for visualization.
.trace: prints out the results of a stream while returning the original values, especially useful when working with patterns.
*/
//Examples:
//.postln:
"hello".postln; "hello".postln; "" //The double quotes at the end avoid the repetition of the receiver, which is always returned at the end.
//.plot:
{ {|i| SinOsc.ar(1 + i) }.dup(7) }.plot(1) //Seven instances of a sine wave, using the iteration argument to add it to its frequency successively. Plotting 1 sec of the signal (it takes 1 sec for SC to generate the graph).
//.poll:
{ LFNoise1.kr.poll(3, "a value"); LFNoise1.kr.poll(5, "another value") }.play; //Polling at different intervals of time and with different labels.
//.histo (+ .plot):
{ 1.0.linrand }.dup(10000).histo(1000).plot(discrete: true) //10000 random values between 0 and 1 according to linear distribution. The histogram needs to be plotted.
//.trace:
p = Pseq([1, 2, 3], inf).asStream.trace; { inf.do({ p.next; 1.wait }) }.fork //The result in the function of .do is not being printed. It is the values from the stream that .trace is returning what the post window shows (a .postln in p.next would print the same values).


//##############################################################
//Some extra remarks on style guidelines and issues with arguments syntax:

//Arguments keyword (arg) vs | | when an argument receives an array as default value: I found an example in which the keyword arg and the currently recommended syntax | | behave differently when the argument is sent an array as default value.
//The last examples shows a possible solution (using an array of literals instead, that is, an array preceded by #, which is created at compile time and can't be altered at run time. More on this in the "Arrays" chapter of this link: https://doc.sccode.org/Reference/Literals.html. In fact, in that example, an array bigger than the one by default is sent to the argument. Nonetheless, this is not a problem because the function is "compiled" each time, adjusting the size of the fixed array. This cannot be changed at run time, for example, after a SynthDef has been compiled).

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
//##############################################################


///////////////////////////////////////////////////////////////////////
//For some reason I don't seem to be able to avoid the markdown in this file at GitHub. I'll think about something soon :')
