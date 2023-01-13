//SYMMETRIC DIFFERENCE - ALGORITHMIC PRACTICE
/////////////////////////////////////////////////

//The symmetric difference of two sets (or disjunctive union) is the set of elements which are in either of the sets, but not in their intersection. In SuperCollider, there is a method for this, applicable to sets: from the help file, "Return the set of all items which are not elements of both this and that", but it does not work with more than two sets (and can't find a method for it):

a = Set[1, 2, 3];
b = Set[2, 3, 4, 5];
symmetricDifference(a, b);
a -- b // shorter syntax

//The objective is to create a function fulfilling the task of the symmetricDifference method, but applicable to Array (instead of Set). Next, the aim would be to create a function capable of calculating the symmetric difference of more than two arrays.
///////////////////////////////////////////////////////////////////////////////////////////

//FIRST MODEL: this function compares two arrays and gives back an array containing all elements only present in one of the arrays (this function was already presented in the theory file 2, concerning functions, arrays and methods). For example, comparing [1, 2, 3, 4] and [2, 3, 4, 5], the result would be [1, 5].
//The approach here was to ask the second array how many instances of each element of the first array were in there. If no instances, that element goes into the resulting array. The process has to be carried out for both arrays, and then the resulting arrays are concatenated:

(
{
	arg array1, array2;
	var result1, result2, finalArray, addition, utmostArray;

	//Instances of the elements of array1 in array2:
	result1 = array1.select({ //The method select receives a collection and features a function and two arguments (item and index). The method answers a collection consisting of all items in the receiver for which its function answers "true".
		arg item;
		array2.occurrencesOf(item) == 0 //OccurrencesOf(item) refers to the number of repetitions of the given item within a collection.
	});

	//Instances of the elements of array 2 in array1:
	result2 = array2.select({
		arg item;
		array1.occurrencesOf(item) == 0
	});

	finalArray = result1 ++ result2;
	finalArray.postln; //Printing the resulting array (there are repeated values).

	//Filtering repetitions:

	finalArray = finalArray.as(Set); //Set eliminate the repeated values.
	finalArray = finalArray.as(Array) //Converting the Set into an array (without the repeated values).
}.value([1, 2, 3, 3, 6, 7, 7], [5, 2, 1, 4, 6, 8, 1]) //The result should be [3, 7, 5, 4, 8].
)

//////////////////////////////////////////////////////////////////////////////////////////////

//SECOND MODEL: Next objective is to create a function for symmetric different in which we can compare more than two arrays. The first difference with respect to the previous code is that we cannot know how manny arrays we will have as an input. Therefore, the arrays cannot be placed in different arguments because we would need to adapt the code for different number of arrays. The solution for this is to create a single argument consisting of an array of the arrays we want to compare:[[arry1], [arry2], [array3]...]. This way we will access the inner arrays using indexes and not separate arguments.
//The problem with this code is that it returns not only the values present in just one of the arrays, but also those present in two of the three arrays:

(
{
	arg generalArray;
	var resultForth, resultBack, uniqueItemsForth, uniqueItemsBack, generalArrayReverse, finalResults;

	//Comparing the first array with all arrays after it in the general array (the argument). Last item (last array) cannot be compared, so we need to repeat the process backwards (see next select function):
	resultForth = generalArray[..(generalArray.lastIndex - 1)].collect({ arg smallArray, i; //We use .collect to loop the process for each instance of the general array.
				uniqueItemsForth = smallArray.select({
					arg item;
					generalArray[i + 1].occurrencesOf(item) == 0

		})

	});

	//Inverting the order of the arrays within the general array:
	generalArrayReverse = generalArray.reverse;

	//Comparing the last array (now first) with the rest of the arrays in the reverse general array:
	resultBack = generalArrayReverse[..(generalArrayReverse.lastIndex - 1)].collect({ arg smallArray, i;
				uniqueItemsBack = smallArray.select({
					arg item;
					generalArrayReverse[i + 1].occurrencesOf(item) == 0

		})

	});

	//Concatenation of both resulting arrays:
	finalResults = resultForth ++ resultBack;

	finalResults = finalResults.flat.as(Set);
	finalResults.as(Array)

}.value([[2, 2, 3, 3, 6, 7, 7], [5, 2, 1, 4, 6, 8, 1], [2, 1, 5, 6, 6, 9, 1]]) //Array of as many arrays we want to compare (in this example, the solution should be [7, 8, 4, 3, 9], but it also returns 1 and 5, values that are present in two of the three arrays).
)

//////////////////////////////////////////////////////////////////////////////////////////////

//THIRD MODEL: solving the problem of the former code with a new approach. Within the single collect function, we separate each of the inner arrays (smallArray) and we remove it from the bigger array and flatten this one, creating two arrays to compare in each iteration. This process is performed for each of the inner arrays, giving back the elements of smallArray for which there are no occurrences in the flattened bigger array:

(
{
	arg generalArray;
	var results;

	results = generalArray.collect({
		arg item, i;
		var smallArray, flatArray, remove, selected;

		smallArray = item; //smallArray will be each of the items of the collection of generalArray (each item is one of the inner arrays, the input of our argument).
		flatArray = [generalArray].flatten(1); //Here we copy the generalArray (see solution for this below, concerning debugging) and we need to flatten only one of the levels of the resulting array (hence, using the method .flatten(1)). If flattening the entire array, the separation of the inner arrays would disappear, and we would not be able to retrieve the inner array that we need to remove.
		flatArray.removeAt(i); //Removing the inner array that we are comparing with the rest in each iteration, which is equal to the argument "i".

		//Comparing each of the inner arrays with the rest of the arrays (now flattened into a single array):
		selected = smallArray.select({
			arg item;
			flatArray.flat.occurrencesOf(item) == 0

		});

		"selected".postln; //Testing selected values in each iteralion.
		selected.postln;

		selected //Repeating the variable "selected" so that it is the last line of the function, for it to be printed as the final result.

	});


	results = results.flat; //Unifying all results into a single array so it can be turned into a Set to eliminate the repeated values (if not flattening before, Set is applied to the items of the bigger array, eliminating repeated arrays and not repeated values within each inner array).
	results = results.as(Set);
	results.as(Array)

}.value([[2, 2, 3, 3, 6, 7, 7], [5, 2, 1, 4, 6, 8, 1], [2, 1, 5, 6, 6, 9, 1]]) //Array of as many arrays we want (in this example, the solution should be [7, 8, 4, 3, 9]).
)

//This code showed the importance of debugging, as it kept failing for certain reasons. In order to debug, is it important to print as many results as possible for each of the operations and tasks within the function. This is why we print "selected".postln and selected.postln (first, we indicate what we are printing using a string, and then, we print the variable itself). This can be done with all variable (in this function, for example, it was useful to print the content of flatArray and smallArray). Another important solution for debugging is testing specific operations out of the function, for example, in order to understand the behavior of .removeAt():

a = [1, 2, 3, 4]
a.remove(1)
a //We need to use another variable so we don't affect the general array permanently:

a = [1, 2, 3, 4]
b = a.remove(1)
a //But in here the general array is still being affected.
b //"b" only contains the removed value.

a = [1, 2, 3, 4]
b = [a].flat //We need a copy of the array in "a" (creating a new array, and flattening the extra square brackets (more efficient way of copying an array?).
b.removeAt(1) //Now we affect the copy of the array and not the array itself.
b //"b" contains the new array without the second element.
a //"a" contains the original array.


//////////////////////////////////////////////////////////////////////////////////////////////

//FOURTH MODEL: a shorter version pursuing the same solution as in the previous code:
(
{
	arg generalArray;
	var generalSet;

	//First, I need to eliminate the repeated values in each of the inner arrays. Each inner array (item) of the general array are turned into a Set, eliminating the repeated values, and then turned back into an array:
	generalSet = generalArray.collect({
		arg item, i;
		var set, array;

		set = generalArray[i].as(Set);
		array = set.as(Array)
	});

	//When each inner array does not contain any repeated values, we can flatten them all into one single array:
	generalSet = generalSet.flat;

	//Now we just need to find the values within this big array that are just there once (.occurrencesOf each item of the generalSet == 1):
	generalSet.select({ arg item;

		generalSet.occurrencesOf(item) == 1
	})

}.value([[2, 2, 3, 3, 6, 7, 7], [5, 2, 1, 4, 6, 8, 1], [2, 1, 5, 6, 6, 9, 1]]) //The result is the same, but the code is shorter (= more efficient? Not necessarily, but perhaps).
)
