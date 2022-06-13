//NRT SYNTH - NON REAL TIME SYNTHESIS
//////////////////////////////////////////////

//EXAMPLE FROM HELP (see the link at the end of the code), see the code from line 47 for YOUR VERSION:
(
var server = Server(\nrt,
    options: ServerOptions.new
    .numOutputBusChannels_(2)
    .numInputBusChannels_(2)
),
defaultGroup = Group.basicNew(server);

var time = 0;

x = Score([
    [0.0, ['/d_recv',
        SynthDef(\singrain, { |out, freq = 440, time = 0.1, amp = 0.1|
            var eg = EnvGen.kr(Env.perc(0.01, time), doneAction: 2),
            sig = SinOsc.ar(freq) * amp;
            Out.ar(out, (sig * eg).dup);
        }).asBytes
    ]],
    [0.0, defaultGroup.newMsg]
]);

100.do {
    x.add([time, Synth.basicNew(\singrain, server)
        .newMsg(g, [freq: exprand(200, 800), time: exprand(0.1, 1.0)])
    ]);
    time = time + exprand(0.02, 0.25)
};

x.recordNRT(
    outputFilePath: "~/Desktop/nrt-gendy-demoHUH-stereo.wav".standardizePath,
    sampleRate: 44100,
    headerFormat: "AIFF",
    sampleFormat: "int16",
    options: server.options,
    duration: x.endTime + 1
);

server.remove;
)

//Now it is a matter of adjusting the times (so it is actually "overlap"), and randomizing more parameters other than the times and the frequency, and finally enhancing the code (make it yours): for example, there are two different variables called "time" and that is confusing and dangerous + no doubts at all about what is in there + applying this code to other synths and routines (more complex ones), ALSO INCLUDING MORE INSTANCES n.do, that will be done whenever the first one is over:

(
var server = Server(\nrt,
    options: ServerOptions.new
    .numOutputBusChannels_(2)
    .numInputBusChannels_(2)
	.sampleRate_(48000)
),

defaultGroup = Group.basicNew(server); //Within the list of vars.

var time = 0; //Why this var separated.

//////////////

x = Score([

	    [0.0, ['/d_recv',
        SynthDef(
            \overlap,
            {arg out = 0, freq1 = 16, freq2 = 23, mul = 0.3, trem = 0.031, transitionTime, sustainTime, density;
                var signal, env, amps = 0.5, signalOut;

                signal = Pan2.ar(
                    Mix(
                        Gendy3.ar(
                            ampdist: 5,
                            durdist: 3,
                            adparam: 1.0,
                            ddparam: 1.0,
                            freq: [Array.geom(4, freq1.midicps, 12.midiratio) * Array.fill(4, { Rand(0.98, 1.02) }), Array.geom(4, freq2.midicps, 12.midiratio) * Array.fill(4, { Rand(0.98, 1.02) }) ].flat,
                            ampscale: trem,
                            durscale: 0.005,
                            initCPs: 12,
                            knum: LFDNoise3.ar(0.5, 4.5, 7.5),
                            mul: Array.geom(8, 0.2, 0.85)) //MATCH THE NUMBER OF FREQS.
                    ) * mul,
                    0.0);

                env = EnvGen.ar(
                    Env(
                        [0, 1, 1, 0] * amps,
                        [ transitionTime, sustainTime, transitionTime ],
                        \sine
                    ),
                    doneAction: 2
                );

                signalOut = signal * env;

                Out.ar(out, signalOut)
        }).asBytes
    ]],

    [0.0, defaultGroup.newMsg]
]);

100.do {
    x.add([time, Synth.basicNew(\overlap, server) //No s.nextNodeID after the server
		.newMsg(g, [ //What is that "g" at the beginning?? (+ no arg: ?)
			freq: n = [16, 20, 22].wchoose([6, 2, 3].normalizeSum),
			freq2: case
            { n == 16 } { 23 }
            { n == 20 } { 27 }
            { n == 22 } { 29 },
			mul: 0.5,
            trem: 0.031,
            transitionTime: 2.5,
			sustainTime: exprand(3.5, 5.0), //Maybe better just rand? + BE CAREFUL WITH THE VOLUME AND DENSITY (since there is no density controlling the amps anymore).
			]),
    ]);
	time = time + exprand(5.0, 8.5) //THIS CREATES ROUGHLY 10 MINUTES OF MUSIC IN 4-5 seconds (+ maybe just rand as well?)
};

 //[20.0, x.freeMsg] //Not needed.

//////////////

x.recordNRT(
    outputFilePath: "~/Desktop/nrt-gendy-demo3-stereo.wav".standardizePath, //CHANGE THE NAME! (do not overwrite!)
    headerFormat: "wav",
    sampleFormat: "int16",
    options: server.options,
    //duration: 20.0, //MATCH THE TOTAL TIME OF THE INSTANCES ABOVE.
	duration: x.endTime + 1,
    action: { "done".postln },

);

server.remove;
)

/////////////////////////////////////////////////////////////////////////////////////////////////
//Still things to check out in here: https://doc.sccode.org/Guides/Non-Realtime-Synthesis.html
