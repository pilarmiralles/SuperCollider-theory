//2 - VARIABLES, FUNCTIONS, ARRAYS, METHODS

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//VARIABLES:
//Variables are data containers. The data is asigned to a variable, which will represent such data. Then, we can apply transformations and processes to such data.

a = 1 //"a" contains a number 1 when the code is evaluated.
a = 2 * 1 //The value of "a" is reasigned when evaluating a new value for the variable. Now "a" contains the multiplication 2 * 1.

//Each variable can contain only one value at a time.
//Variables "a" to "z" are not declared variables and can be used wherever in the code. It is best, though, to declare variables within a block of code, which will only work inside such block. The declared variables can receive a specific (and more descriptive) name. "s" can't be used as a variable because it contains the server by default (if its value is reasigned, the communication with the audio server would be lost).

//Non-declared variables (if used elsewhere in the code, their value would be reasigned and its function within this block would change):

(
a = 2;
b = 16;
c = a ** b //We only get the result of the last line of the entire block.
)

//Declared variables (they contain values only within this block of code, thus, its value cannot be reasigned from the outside):

(
var value1, value2, power;

value1 = 2;
value2 = 16;
power = value1 ** value2 //Same result.
)

//Non-declared variables can receive a descriptive name different than a letter. For this, we use the following character. It could be useful to use this kind of non-declared variables, but for now it is better to control their use and to declare the variables as much as possible and within the smallest possible portion of code:

~variable //This would have the same function as a letter, but we write the name as we wish.


//###########################################
//"this" --> communication with the interpreter. Use "this.dump" to see what it is asigned to each variable in the code (the state of the interpreter).
//--> Note for myself: reminder of other informative methods:
s.meter //Inputs and outputs.
{LFTri.ar(440, mul: 0.1)}.scope //Plays + shows the signal.
{LFTri.ar(SinOsc.ar(1/3, 0.5pi, 250, 550).poll(5), mul: 0.1)}.scope //.poll prints the live values of a signal (here is the frequency of the LFTri, which is being modulated by the SinOsc. It prints 10 values per second by default. Here there is 5 values per second (as defined in its argument between parenthesis). The phase is changed in the modulating signal, because the "carrier" (the LFTri) is reproduced at audio rate (with a freq between 300 and 800 Hz).
//###########################################


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//FUNCTIONS:
//They are blocks of code carrying out a specific task + they are written between square brackets (braces). They need to be evaluated through the message (method) ".value", and a list of arguments for the function can be sent through this method.

//Useless function (because of fixed result) as an example:

a = {1 + 1} //Run this line to compile the function.
a.value //Run this line to evaluate the function and obtain its result.

//A function is more useful when there are variable values, sent as arguments through the method .values:

(
a = {
	arg value1 = 1, value2 = 5; //Default value.
	var result;

	result = value1 + value2
}
)

a.value(2, 3) //Those are the arguments in order.

//Another example:

(
b = {
	arg secondValue = 2, mul = 20;
	var result;

	result = 1 + secondValue;
	result * mul //Here the value of the variable "result" is reasigned (overwritten).
}
)

b.value(1, 10)

//There is an alternative grammar for writing the arguments, as it can be seen here. I suggest to choose and stick to one of them. This function creates a cluster using pitch classes from 0 by default (notice the use of the module 12 to keep the pitch classes between 0 and 11):

(
c = {
	| fundamental = 0 | //Alternative way of writing the arguments.

	fundamental + [0, 1, 2] % 12
}
)

c.value(7) //Da [7,8,9], clúster de tres notas desde la nota 7 en pitch class

//Another example: function that chooses random numbers within a uniform distribution (rrand).

(
f = {
	arg bottomValue = 0.0, topValue = 1.0;

	rrand (bottomValue, topValue) //The use of "exprand" in here would choose numbers within an exponential distribution, which would suit better the work, for instance, with frequencies. When using exponential distributions, the value 0 must be excluded.
}
)

f.value //Random numbers between 0.0 and 1.0 (floats, due to float input in rrand).
f.value (0, 10) //Random numbers between 0 and 10, integers (due to integer input in rrand).
f.value (0, 5.2) //Random numbers between 0 and 5.2 --> if only one of the numbers is a float, the result will be always float anyways.
f.value (topValue: 2) //Changing only the second argument thanks to the use of the key-word assignment.

//The message ".value" can be directly applied to the block of code of the function this way (putting the function into a non-declared and detaching the .value method allows us, nontheless, to evaluate the function anywhere in the code. This choice depends on the task of the function):

(
{
	arg sideA = 1, sideB = 1;
	var calculation;

	calculation = (sideA + sideB).sqrt

}.value(5, 4) //Here the .value method is applied directly to the block of code of the function.s
)

//Other examples of functions:

//Calculates the mul and add for a modulation:
(
d = {arg bottomValue, topValue;
	var mul, add;

	mul = topValue - bottomValue /2;
	add = mul + bottomValue;
	[mul, add] //It returns as a result the mul and add at the same time within an array.
}
)

d.value(500, 1000) //It is calculated here, for instance, a modulation between 500 and 1000 Hz.

//Applying the former function in a more complex block of code:
(
{
	var function, mulAdd, freqs;

	//A first function calculates the mul and add (the variable "function" contains the array with the mul and add):
	function = {arg bottom, top;
		var mul, add;

		mul = top - bottom /2;
		add = mul + bottom;
		[mul, add]
	};

	//The former function is applied to a real modulation:
	freqs = Array.fill(2, { rrand (30, 16000)}).sort; //A series of random frequencies in order is created.
	mulAdd = function.value(freqs[0], freqs[1]); //The bottom and top frequencies are applied to the mulAdd function.
	SinOsc.ar(SinOsc.ar(10, 0, mulAdd[0], mulAdd[1]), 0, 0.1) //The mul and add are taken from the resulting array of "function" using the index of each one, and applied to a SinOsc modulated by another SinOsc.

}.play
)

//Create a function that receives the overtone number within the series (n) and which gives back the pitch of that overtone in Hz and Midi.
(
{
	arg n, fundFrecMidi = 24; //Fundamental frequency by default = C1 (24 midi): using Midi as it is easier to choose a specific frequency.
	var hz, midi;

	hz = n * fundFrecMidi.midicps; //Converting the fundamental freq into Hz so the Hz of the overtone is = n * fund freq.
	midi = hz.cpsmidi.round(1); //Now using the result of Hz, so the value is coming from the natural temperament, although when converting into midi, there are decimals, which will be rounded in order to obtain an integer for the midi value.

	[hz, midi]

}.value(8) //Here, as an example, calculating the C4 (8th overtone of the C1 series).
)

//This function checks out whether a word (a string of letters) is a palindrome or not):
(
f = {
		arg word;
		var original, reverse;

		original = word;

		reverse = word.reverse;

		original == reverse; //Better than the ===, although those also work because you are comparing the same string and not two different strings with the same content.
	}
)

f.value("lol")
f.value("tacocat")
f.value("dog")

//I think this is called symmetric (see "Set" theory for a method equal to this function): compares two arrays and gives back an array featuring all elements only present in one of the arrays: for example, comparing [1, 2, 3, 4] and [2, 3, 4, 5], the result should be [1, 5]
//Approach: comparing each element of the first array: asking the second array how many instances are in there of each element of the first array (if no instances, it passes to the final array) + same viceversa + concatenate both results at the end:

(
a = {
	arg array1, array2;
	var result1, result2, finalArray, addition, utmostArray;

	//Comparing the array and obtaining the unique values of each:

	result1 = array1.select({ //The method select receives a collection and features a function and two arguments (item and index), and answers a collection consisting of all items in the receiver for which its function answers "true".
		arg item;
		array2.occurrencesOf(item) == 0 //OccurrencesOf(item) refers to the number of repetitions of the given item within a collection.
	});

	result2 = array2.select({
		arg item;
		array1.occurrencesOf(item) == 0
	});

	finalArray = result1 ++ result2;
	finalArray.postln;

	//Filtering repetitions:

	finalArray = finalArray.as(Set); //See theory about Set.
	finalArray = finalArray.as(Array)
}
)

a.value([1, 2, 3, 3, 6, 7, 7], [5, 2, 1, 4, 6, 8, 1]) //--> The solution should be [3, 7, 5, 4, 8]. It works!
//You could try to create a similar function in which the number of compared arrays is flexible.

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//METHODS
//The transformation and process of objects created by Classes are defined by the methods. They can be (as shown is the document 1), instance of class methods (class methods create objects / instance methods apply transformations and processes to objects already created by classes).

/* Definition of "message" and "method" according to SC guide:
MESSAGE: A request for an object to perform an operation (the operation itself and the act of assigning the operation to an object, the request).
METHOD: A description of the operations necessary to implement a message for a particular class (the word of the message and its arguments, the text itself, the "physical" form of the message.
*/

//Practical/utopical example of how the objects, classes, messages (methods) work in SC:

//These two are our Classes (capital letter)
Sandwich
Ham

//These are our methods:
Sandwich
* prepare //Class method (creates the sandwich)
hitUp //Instance methods (modify the sandwich)
  cut

Ham
* marinate
  fry

//Syntax object-message --> class-method:

Sandwich.prepare

//Real example in SuperCollider:

{SinOsc.ar}.play //.ar is a class method, .play is an instance method.

//Defining arguments for the methods within out Sandwich Class:

Sandwich {

	*prepare{ arg extraIngredients = [ 'tomato', 'cheese'], //Our class method "prepare" (with the *) and its arguments and default values.
		bread = 'baguette', //These names would be specific things (these just examples).
		meat = 'chicken';
		...
		...
	}

	hitUp{ arg temp = 50, time = 120; //Instance method and its arguments and default values.
	}

	cut { arg numPieces = 2;
	}
}

//Now we can define its arguments:

Sandwich.prepare(['tomato'], 'baguette', 'tofu')
Sandwich.prepare(meat: 'tofu')  //Key-word assignment, changing just the third argument (rest of them by default).

//Another example, using the rest of out methods for the Sandwich Class

a = Sandwich.prepare(
	[ 'pepper'],
	'baguette',

	Ham.marinate.fry(260) //First argument of the method .fry is the temperature.
)

a = a.hitUp
a = a.cut(4) //Argument of the method .cut is the number of pieces.


/////////////////////////////////////////////////////////////////////////////////////////////////////////
//ARRAYS:
//A collection is an object which contains a group of objects: the elements of the collection. An array is a type of collection (the most used one), containing a specific number of literals between square brakets and separated by commas:

//An array is written between square brackets and the elements inside it are separated by commas. They can contain homogeneous (same kind of elements, for example, numbers), or heterogeneous (different kind of elements). The elements are put into a collection so they can be accessed using indexes.

[ 1, 2, 3, 4, 5 ] //Homogeneous collection (integers).

[ \symbol, 67, "string", {SinOsc.ar(mul: 0.1)} ] //Heterogeneous collection (symbol, integer, string and sine wave).

a = [ 1, 2, 3, 4, "hello", {SinOsc.ar(mul: 0.1)} ] //A collection assigned to a global variable.

//The index indicates the position of the element within the collection, starting by 0 (IMPORTANT: THE 1st ELEMENT WILL BE INDEX 0).

a[0] //This will be equal to 1.
a[4] //This will be equal to te string "hello".
a[5].play //This will directly play the sine wave

//Instance / class methods can be applied to arrays.
//CLASS METHODS: they create arrays:

//ARRAY.FILL:
//Array.fill(size, function): it creates an array with a specific size (1st argument). Then, it will evaluate the given function (2nd argument) as many times as stated in the size argument. Remember that the function should always be written between curly brackets. First exception for the spaces: avoid the space between Array.fill and the parenthesis:

Array.fill(6, { rrand (0, 11)}) //Creates an array with random numbers between 0 and 11.

Array.fill(6, {arg i; i}) //The argument "i" (index) = number of the index of each element of the array, as seen before (any name can be used for the index arg).

Array.fill(6, {arg i; [i, rrand(0, 11)]}) //Here creating separate arrays containing the index and a random number from 0 to 11.

//Using Array.fill to obtain 30 sine waves, which will be the overtones of the fundamental frequency 440Hz:
(
{
	{
		Mix( //"Mix" will mix all frequencies in a single channel. This is why the entire function needs to be duplicated in order to get a stereo sound.
			Array.fill (30, {
				arg n;
				var overtone;

				overtone = n + 1; //This will add 1 to every index number. This avoids the first zero of the series.

				SinOsc.ar((440 * overtone).postln, 0, 0.01/overtone) //Mul is divided into each index number, so each frequency is weaker as it goes up in frequency (it is now a bit too quiet, but the resulting sound is also quite piercing, aking to a sawtooth wave).

			})
		)
	} !2
}.play
)

//Same function, now changing the size of the array and the root of the overtone series (this function only gives the frequencies, it doesn't include the sine wave and the .play function):
(
{
	arg root = 50, slots = 7; //Default values.

	Array.fill(slots, {

		arg i;

		(i + 1) * root //Adding 1 to avoid the 0 (any other number could be added to start from a different point of the overtone series).

	});

}.value(50, 8) //50 Hz for the root freq, and 8 overtones (the first one is the root freq) calculated.
)

//Duplicate is equivalent to Array.fill:

//Equal functions:
({arg i; [ i, rrand(0, 11) ]} !6)

Array.fill(6, {arg i; [i, rrand(0, 11)]})

//ARRAY.SERIES:
//The second class method for arrays is Array.series(size, start, step): it creates an aritmetic series:

Array.series(12, 0, 1) //Series from 0 to 11 (12 values, starting by 0, 1 step between each).

Array.series(24, 60, 0.5) //Scale within an octave, in tone-quarters, from midi 60 (central C).

//It can be assigned to a variable and visualized on a chart:

x = Array.series(50, 0, 5)
x.plot(discrete:true) //Discontinuous points.
x.plot(discrete: false) //Continuous line (but this is a series of "points").

//ARRAY.GEOM:
//The third class method for arrays is Array.geom(size, start, grow): it creates a geometric series. The arguments are the same as in Array.series (size and start), but the third argument is grow, is the product (multiplication) for the geometric series, as the step would be for the aritmetic series (but in there, it is just a sum, and not a product):

//It is really useful to calculate frequencies based on a certain interval, using the ratios of each interval (that would work according to the natural or Pitagoric tuning):
Array.geom(5, 220, 2) //For example, the 2 would mean octaves (regarding frequency in Hz) --> Five octaves from the A3, counting the A3 itself.

//As a brief reminder of the ratios for the intervals (useful for the upcoming noise filters):

//It is also useful for accelerando and diminuendo, (speeding up and down processes, for example, applied to rhythms), lowering or raising the amplitude in an exponential way. It should be used with caution as the values can grow really fast (depending on the grow argument). Be careful, especially with frequencies and amplitude.

//Here inside a variable and plotted to see the exponential line:
f = Array.geom(10, 1, 2)
f.plot(discrete: true)

//INSTANCE METHODS: they are applied to the arrays that already exist:

y = Array.series(12, 0, 1) //An array in a variable.
y.reverse //Retrograded series.
y = y.reverse //Now the variable is reasigned to the retrograded series.
y.scramble //Changes the order of the elements randomly.
y = y.scramble.keep(5) //Trick to choose 5 random numbers from a series withour repeating them.
y.sort //Puts the values in upward order (if they are numbers).
y.sort.reverse //Puts the values in opposite order (downwards).

//For very long arrays, in order to see all the elements (for example, if needed to see the last one), we can use:
Array.series(200, 0, 1) //It shows etc... because it is too long, but we can't know the last value.
Array.series(200, 0, 1).asCompileString //This will show all the elements.
Array.series(200, 0, 1).last //This will show just the last element (thus, this line is no longer an array, but just ONE value).

e = Array.series(4, 60, 10) //New series.
e = e.mirror //This includes the original + the retrograded (mirror) series.
e.plot(discrete: true) //Sort of triangle in the graph

[ 0, 1, 2, 3 ].choose //Chooses one random element from the collection.
[ 0, 1, 2, 3 ].wchoose([ 0.2, 0.3, 0.49, 0.01 ]) //Chooses one random elements from the collection according to the probability (out of 1) for each element stated in the second array (which is its argument, an array of ratios for probability). They have to sum 1 in total (100%) and there has to be one value per element in the first array (other wise, the values are going to rotate for the values in the first array).
[ 0, 1, 2, 3 ].wchoose([ 5, 8, 4, 2 ].normalizeSum) //NormalizeSum converts other values into ratios from 0 to 1.
[ 0, 1, 2, 3 ].rotate(1) //Rotation of the elements to the right. If using a negative number, they rotate to the left. If using a different number other than 1, they rotate those many slots within the series.

//When applaying aritmetic operations using arrays of different size: the values of the small array rotate to be applied to the big array:
//Hence these operations are equal:

[1, 2, 3, 4, 5] + [1, 2, 3]
[1, 2, 3, 4, 5] + [1, 2, 3, 1, 2]

//Other methods:

a = [0, 1, 2, 3, 4]
a = a.add(1000) //Adds the value between parenthesis.
a //Now "a" contains a 1000 at the end of the collection.

a = [0, 1, 2, 3, 4, 1000]
a[1] = 2000 //This is the method "put": it puts the indicated value into the indicated index (subsequently removing what was there first).
a[0] = 0.5

b = a.removeAt(1) //Removes the second index (which is index 1, as stated between parenthesis) and returns it in the post-window. "b" is just a 1 then.
a //"a" is lacking the second element now.

[1, 2, 3, 4, 5].sum //Addition of the elements of the array (only with homogeneous array). Could be applied to an array of signals to put them together into the same channel.

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

a = [\hi, 5, 68.midicps, PinkNoise.ar(0.2), 0.1, "hello".scramble, 127, SinOsc.ar(PinkNoise.ar(50,70), 0, 0.2), 0.00002, BPF.ar(in: BrownNoise.ar(0.5), mul: 0.5), \end] //(Very random)

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

//12 - Assign to "f" the mirror of "f" and apply a plotter to the result (separate processes):

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

//.SELECT: Answer a new collection which consists of all items in the receiver for which function answers True. The function is passed two arguments, the item and an integer index:
List[1, 2, 3, 4].select({ arg item, i; item.even });

(//Your example from the Ustvolskaya codes:
var structure, index;

structure = [ "a", "b", "c", "b", "a", "d", "c", "e", "c", "d" ]; //Sections of a piece, for example (for algorithmic composition).s

(structure.size.div(2)-1).do({ //To calculate the number of iterations of .do so it is adapted to any series in the variable "structure": the size of the array of "structure" is asked and divided by 2 (just because in this case, the number of elements of "structure" are going to be deleted 2 by 2), and 1 is substracted so there is a last element of the series that is not eliminated (avoiding the last iteration of .do according to the size of the array).

	index = Array.series(structure.size).scramble.keep(2); //A series with the indexes of the array is created, then the order is changed randomly, and two elements from that random order are chosen (.keep).

	index.do({| i | structure[i] = nil }); //"nil" ("empty") is assigned to the chosen indexes (to the element of the array in those indexes, which will be the indexes of "structure").

	structure = structure.select({| item | item.notNil }).postln //.select returns the elements answering true in its function. In this case, only the elements that are "notNil" are returned. Then, the variable "structure" is reassigned without the elements that were turned into a "nil".
})
)

//there are too many classes within the superclass Collection: THESE are the ones that interest us:
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
y.putEach([2, 3, 5, 6], \wotsits); //It wraps.
) //Put the values in the corresponding indices given by keys. If one of the two argument arrays is longer then it will wrap.
(
y = [\a, \b, \c];
y.atAll([0, 2]);
) //Return a collection of all the items for the keys.

//FOR ITERATION (see more in the help doc):
//We saw .select above. There are also:
List[1, 2, 3, 4].do({ arg item, i; item.postln }); //do
List[1, 2, 3, 4].collect({ arg item, i; item + 10 }); //collect
List[1, 2, 3, 4].reject({ arg item, i; item.even }); //reject (CONTRARY of .select)
List[1, 2, 3, 4].detect({ arg item, i; item.even }); //detect (also .detectIndex)
List[1, 2, 3, 4].any({ arg item, i; item.even }); //any
List[1, 2, 3, 4].every({ arg item, i; item.even }); //every
List[1, 2, 3, 4].count({ arg item, i; item.even }); //count
List[1, 2, 3, 3, 4, 3, 4, 3].occurrencesOf(3); //occurrencesOf
List[1, 2, 3, 4].sum; //Addition. Two examples:
(0..8).sum { |i| 1 / (2 ** i) };


/* Other methods:

- .asInteger (or .asInt): turns a float into an integer (rounding it down).
- .flat: unifies nested arrays into a single array containing all the elements.
- .asStream: sent to objects that are not streams to turn them into streams (patters, envelopes, etc.). Should be used in combination with .next.
- .clump(n): opposite of .flat. Its argument indicates the number of elements (n) that are going to be clumped into nested arrays within a bigger array.
- .stutter(n): its argument indicates the number of repetitions (n) of each element of a given collection.
- .normalizeSum: converts an array of numbers into ratios from 0 to 1 (so the total addition would be equal to 1). Used with .wchoose or Pwrand, etc.
- .odd, .even, 0.5.coin (for instance), .isNil, .notNil, .and, .or, etc.: methods for boolean expressions.
- .postln, .plot, .poll, .histo, .trace: they represent values in different ways: POSTLN prints values that are not signals (applied to a signal or any other "alive" thing in the server, it will just indicate that there is a pattern or a synth) / PLOT shows a graph (it needs to be applied to a function, not to a signal without the {} / POLL prints values from signals (that are running in the server) / HISTO shows a graph of probabilities / TRACE prints the values given by a pattern (they are "alive", but not like a UGen (which uses .poll instead).
Note that .poll can be used alongside a label, so when printing many different values at a time, you can tell which one is from which UGen. Example: { LFNoise1.kr.poll(3, "a value"); LFNoise1.kr.poll(5, "another value"); }.play;
- .mod(12): module 12 of all values of a given collection.
- .div(2): divides by 2 (for instance), rounding the result down (always returns integers).
- .min y .max: .min returns only the values below the number given as its argument / .max returns only the values above.
- .lastIndex: indicates which one is the index of the last element of a collection (.size would indicate one more number because it starts by 1, instead of by 0, as with the index).
- .range: calculates the mul / add needed for a modulation (without the studied calculations, although it is better to understand how it is calculated). For example: LFDNoise3.ar(0.1).range(400, 1200)
- .fork: it is a wraper, a Routine + .play (none of those have to be stated because they are contained within .fork, but it is still necessary to use .wait or .yield).
- .linlin is for mapping (y.linlin(-1, 1, 40, 80) = converts the range -1 to 1 of "y" into 40 to 80, with a linear interpolation.
- .linexp is for mapping from linear to exponential (y.linexp(0, 127, 30, 8000), for example, would convert the linearity of the MIDI values from 0 to 127, mapping them into exponential values of frequency between 30 and 8000 Hz), just for instance.
- .drop(-1): eliminates an element of a collection. If the collection is reassigned to its variable, it will diminished: */

~structure = [ "a", "b", "c", "d", "e" ]
~structure = ~structure.drop(-1) //Deletes the elements from the last to the first.
~structure = ~structure.drop(1) //Deletes the elements from the first to the last.
~structure = ~structure.drop(2) //Deletes the elements two by two from the first the last.

//ARRAYS SHORTCUTS:
(0..20) //Array with numbers from 0 to 20.
(60, 60.25..65) //Array with numbers from 60 to 65 with a step of 0.25 between each number.
(10, 10.1..20).cs //.cs avoid the .etc in the postwindow when the lists are too big, in case we need to visualize all the values (but be careful because SC saves memory from this with the .etc for a reason).
(rrand(10, 15)..rrand(16, 20)) //Series between numbers from 10 to 20. The low and high limits of the series will be random, from the minimum range (2 possible values from 15 to 16) to the maximum range (11 possible values from 10 to 20).
(rrand(10, 15)..rrand(16, 20)).plot  //Former example, visualized in a graph.
//Some operations can be applied to these arrays as normally. For instance:
pow((0..1000), 2).plot //Series from 0 to 1000 to the power of 2 (plotter = exponential curve, see the graph).
sin((0, 0.1..20)).plot //Sin function (values from -1 to 1 (20 numbers with a step of 0.1 = 2 units from -1 to 1). Two layers of parenthesis are needed for the plot to work (because of the sin function).

//Indexes:
a = [1, 2, 3, 4, 5] //Given this array, you can take part of its indexes only:
a[3..] //From index 3 to last index (remember, it's the index, not the content of the index), including index 3.
a[..3] //From first index to index 3, including index 3.
//Example of function playing with this: Given an array of numbers, return the middle to the end (if two middle, take the second):

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

Set[1, 3, 7, 4] //This is a set. Methods:

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
a.as(Set); // convert to set
a.as(Set).as(Array); // and convert back

/////////////////////////////////////////////////////////////////////////////////////////////////////////
//THE FIRST UGEN: SinOsc:

SinOsc //The simplest oscillatory pattern, equivalent to a dock or a pendulum:

{SinOsc.ar(440, 0, 0.3, 0)}.plot(1/440) //Here the graph (one cycle).

//Arguments:
//1st argument = frequency in Hz. The frequency could be written in Midi, for instance, applying the proper conversion method:

SinOsc.ar(69.midicps, 0, 0.4, 0)

//2nd argument = phase (starting position in the wave): 0 (0) = beginning / 90º (0.5pi) = top point / 180º (1pi) = half period / 270º (1.5pi) = bottom point / 360º (0) = back to the beginning. This is only perceptible when the sine wave is not played at sample rate, but slow enough to hear its shape (for example, when used for a modulation).
//3rd argument = mul (from multiplication). The amplitude of the signal is multiplied by that value. Default value is 1, but that is the limit before saturation (distortion). Thus, it is best to write a value below 1 (exceptions will be shown later on). When lowering the mul, the shape of the wave is morizontally narrower, the amplitude changes, but not the timbre.
//4th argument = add. It is the vertical position of the wave. It will be useful later on (when modulating).

//The arguments can be changed in a different order (or without needing to specify all of them if the default values suit our needs). We use then the keyword assignment:

SinOsc.ar(mul: 0.1, freq: 330) //The name of the argument is written as a "key" (name:). If using this grammar, all arguments should be written as keys.

//Modulation of arguments (3rd and 4th arguments of SinOsc, or any other signal with mul and add):

({
	a = LFTri.ar(1, 0, 500, 1500); //A triangular wave between moves in the graph between 1000 and 2000 Hz each second (up and down).
	a = a.round(125); //This creates little steps of 125 hz within the continuous movement of the wave (1000 / 125 = 8 levels, 7 steps as in a scale from one octave to its higher octave). Without this, the sound of the SinOsc would be continuous. If the modulating wave was another SinOsc instead of a LFTri, the steps would not sound regular (try it).
	c = SinOsc.ar(a, 0, 0.3) //The frequency of the sine wave is modulated by the triangular wave (we can hear now the steps).
}.play
)

//The "mul" argument's value is 1 by default. The soundwave will move vertically from -1 to 1 regarding the amplitude. On the other hand, "add" (the 4th argument), is a, addition to the mul. It will move vertically the soundwave: the center is 0 by default. If "add" is changed, "mul" will conserve its value, but the vertical point were the soundwave is situated will vary. "Add" is only used when using a signal in a modulation.
/*In order to modulate a sine wave, for instance, from 440 to 880 Hz, we use a signal in its frequency argument, and calculate the mul and add of such signal as it follows:

1 - Calculate the peak to peak amplitude: top freq - bottom freq: 880 - 440 = 440.
2 - Mul will be equal to the peak to peak amplitude / 2: 440 / 2 = 220.
3 - Add will be equal to mul + bottom freq: 220 + 440 = 660.
*/

//This would be the resulting signal of our calculations: a sinewave modulating from 440 to 880 (back and forth) each 2 seconds (for instance):

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

//Side note: another option to hear the signal through both channels: this is a UGen for panning (a "panner"). It's first argument is our signal, and its second argument is the position (-1 = left / 1 = right / 0 = center). It automatically turns the signal into a stereo signal:

(
{ Pan2.ar(
	SinOsc.ar(440, 0, 0.1),
	0 //Panned to the center, the signal comes through both sides of the stereo equally (center).
)
}.play
)

//Remember that the phase argument (the 2nd one) will only be noticeable when changing it in the modulating signal (for example, in here, if needing to start from 880 instead of 440, which is the top frequency, the soundwave should start with a phase = 0.5pi).

//The mul of the "carrier" signal should still be between 0 and 1. Here is a different way to control the mul: the mul is equal to 1 (by default), but the whole signal is multiplied by 0.1, so the mul will drop to that value:
(
{
	SinOsc.ar(
		SinOsc.ar(1/2, 0.5pi, 220, 660),
		0,
		1 !2,
		0
	) * 0.1 //This changes the amplitude of the whole signal.
}.play
)

//Here, you can actually visualise what happens to the soundwave when moving the add:
({
	[
		SinOsc.ar(440, 0, 1), //Modifying the mul only: the amplitude changes.
		SinOsc.ar(440,0, 4),
	]
}.plot(1/440, minval: -5, maxval: 5)
)

({
	[
		SinOsc.ar(440, 0, 50, 0), //Now same mul, but different add: the soundwave is displaced upwards.
		SinOsc.ar(440, 0, 50, 100)
	]
}.plot(1/440, minval: -150, maxval: 150)
)

//Now we can modulate other parameters apart from the frequency: here, the amplitude is also modulates from 0 to 0.5 mul:

(
{SinOsc.ar
	(SinOsc.ar(1/10,1.5pi, 100, 400),
		0, //It is useless to modify the phase of the "carrier" signal.
	SinOsc.ar(2, 0, 0.25, 0.25)
	)
}.play
)

//The frequency of the modulating signal has to be below 20 Hz. Otherwise, it would become a frequency modulation or FM. The same happens with the amplitude modulation, which would bring about AM (or Ring modulation).

{SinOsc.ar(SinOsc.ar(880, 1.5pi, 100, 400), 0, 0.1 !2)}.play //Quick example of frequency modulation (there can be heard more than one frequency).

//Last but not least, it is possible to modulate the frequency of the modulating signal (although this is already a bit of a mess and a bit advance), but just as an example:

(
{
	SinOsc.ar(
		SinOsc.ar(
			SinOsc.ar(2, 0, 2, 3), //Between 1 and 5 seconds: applying the mul-add calcutalions. Then, this frequency modulation of the modulation will happen each 2 seconds.
			0.5pi,
			220,
			660).poll,
		0,
		0.1 !2,
		0
	)
}.play
)
