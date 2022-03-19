//QUESTIONS:

//I want to apply a plot in here to see the actual steps of the Triangular wave:

({
	a = LFTri.ar(1, 0, 500, 1500); //A triangular wave between moves in the graph between 1000 and 2000 Hz each second (up and down).
	a = a.round(125); //This creates little steps of 125 hz within the continuous movement of the wave (1000 / 125 = 8 levels, 7 steps as in a scale from one octave to its higher octave). Without this, the sound of the SinOsc would be continuous. If the modulating wave was another SinOsc instead of a LFTri, the steps would not sound regular (try it).
	c = SinOsc.ar(a, 0, 0.3) //The frequency of the sine wave is modulated by the triangular wave (we can hear now the steps).
}.play
)

//Stupid question about the pulse wave:

{ SinOsc.ar(440) * LFPulse.ar(1) }.play //Non-filtered version: produces 1 pulsation per second with a 50% of width.

{ SinOsc.ar(440) * Pulse.ar(1) }.play //Filtered version (not really prepared for modulations), for some reason it produces 2 pulsations per second.

