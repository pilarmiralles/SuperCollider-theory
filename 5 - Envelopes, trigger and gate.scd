//5 - ENVELOPES, TRIGGER AND GATE
////////////////////////////////////////////////

//Envelopes



















//ENVOLVENTES: describen eventos que cambian en el tiempo. Las vamos a crear con dos clases: EnvGen (UGen) y Env (nos permite especificar las características de la envolvente que EnvGen creará). EnvGen.ar es una señal (de un solo canal)

//Env: métodos

Env.new //Env.new(levels, times, curve), no usar los otros argumentos. Levels = puntos en la "y" en un array (por ejemplo [0, 1, 1, 0], pueden ser frecuencias, intensidad, etc), Times = cuánto dura cada uno de esos puntos en el tiempo en segundos en un array (del primero al segundo, del segundo al tercero, etc, por ejemplo [1, 3, 2]), siempre hay una duración menos que niveles, Curve = cómo se mueve de un valor a otro (línea recta, línea exponencial, senoidal, etc), cuando se va de un nivel al mismo nivel, da igual lo que se ponga de interpolación (Curvas ya definidas: \linear (por defecto), \exponential, \sine, \step (sin interpolación), float positivo o negativo que da el valor de la curvatura de los segmentos (el grado del polinomio), o un array con cualesquiera de las opciones anteriores).

//CON LINEAR
Env(curve: \linear) //Esto ya es .new (en todas las clases igual, no hay que ponerlo), solo sirve para crear una nueva instancia

(
Env(
	[0, 0.5, 0.1, 0.5, 0], //niveles
	[1, 1, 1, 1], //duraciones (en segundos)
	\linear
).plot
)

//Para que suene solo hay que multiplicar la señal por la envolvente
(
{
	var senal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], [1, 1, 1, 1], \linear); //Se puede quitar el array de unos si son todos el mismo número y poner solo 1 (por la suma de arrays)
	envGen = EnvGen.ar(env);

	senal = SinOsc.ar;

	senal * envGen
}.play
)

//CON EXPONENTIAL (no funciona desde 0, por eso 0.001 inicio y final)
Env(curve: \exponential)

(
Env(
	[0.001, 0.5, 0.1, 0.5, 0.001], //niveles
	[1, 1, 1, 1], //duraciones
	\exponential
).plot
)

//Resultado sonoro
(
{
	var senal, env, envGen;

	env = Env([0.001, 0.5, 0.1, 0.5, 0.001], 1, \exponential); //Sin el array, como se dijo antes
	envGen = EnvGen.ar(env);

	senal = SinOsc.ar;

	senal * envGen
}.play
)

//STEP (NO INTERPOLACIÓN)
Env(curve: \step)

(
Env(
	[0, 0.5, 0.1, 0.5, 0], //niveles
	[1, 1, 1, 1], //duraciones
	\step
).plot
)

//Resultado sonoro (click al inicio y cambios abruptos)
(
{
	var senal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, \step);
	envGen = EnvGen.ar(env);

	senal = SinOsc.ar;

	senal * envGen
}.play
)

//CON FLOATS (para dibujar la linea como queramos si no nos vale linear o exponential (curve). NEGATIVOS: ESTIRAN HACIA LA IZQ, POSITIVOS: ESTIRAN HACIA LA DER. Cuanto más grande es el número (+ o -), más se acentúa hasta casi parecerse a una onda cuadrada (encendido y apagado)
(
Env(
	[0, 0.5, 0.1, 0.5, 0], //niveles
	[1, 1, 1, 1], //duraciones
	4 //Cuatro es un número bueno para envolventes
).plot
)

//Resultado sonoro
(
{
	var senal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, -4);
	envGen = EnvGen.ar(env);

	senal = SinOsc.ar;

	senal * envGen
}.play
)

//se pueden mezclar en un array positivos y negativos: aquí para que suba rápido y baje rápido
(
{
	var senal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, [4, -4]); //Cercano a una exponential
	envGen = EnvGen.ar(env);

	senal = SinOsc.ar;

	senal * envGen
}.play
)

//CON ARRAY DE PARÁMETROS
(
Env(
	[0, 0.5, 0.1, 0.5, 0], //niveles
	1,
	[8, -4, \exponential, 0]
).plot
)

//resultado sonoro
(
{
	var senal, env, envGen;

	env = Env([0, 0.5, 0.1, 0.5, 0], 1, [8, -4, \exponential, 0]);
	envGen = EnvGen.ar(env);

	senal = SinOsc.ar;

	senal * envGen
}.play
)

//GLISS. CON ENVOLVENTES: EnvGen para modular frecuencia
({
	var senal, frec;

	frec = EnvGen.ar(
		Env([39, 61, 50], 2, \linear) //Podemos poner linear, pero ya viene por defecto + cambiar tiempo de cambio entre cada nota
	).midicps;

	SinOsc.ar(frec, 0, 0.3)
}.play
)

//Aquí con método "circle" (se repite en loop todo el rato)
({
	var senal, frec;

	frec = EnvGen.ar(
		Env([39, 61, 50], 2, \linear).circle //No interpolación entre el último valor y el primero de nuevo en el "loop", por lo que sigue se sigue necesitando un valor menos de tiempos y de curvas (no se completa el loop, sino que simplemente se repite la envolvente y el paso entre una y otra es un step).
	).midicps;

	SinOsc.ar(frec, 0, 0.3)
}.play
)

//Con un array para notas al azar en las frecuencia (cambia cada vez que se evalúa)

//MODULACIONES + MEZCLAR CON TODO LO VISTO (+ las envolventes se pueden aplicar a la estructura de una obra, a densidades como en el dust, etc)
//Modular la velocidad con la que cambia de una frecuencia a otra (bucle y cambia la velocidad)
({
	var frec;

	frec = EnvGen.ar(
		Env(Array.fill (5, {rrand (36, 84)}),
			LFDNoise3.ar(0.5, 0.5, 0.6),
			\linear
		).circle
	).midicps;

	SinOsc.ar(frec, 0, 0.3)
}.play
)

//Aplicación, por ejemplo, en un banco de filtros (aquí en la variable root definimos los movimientos de semitonos que se hacen entre cada nota de la envolvente). Se mueven en paralelo los 10 BPF creados (ejemplo del otro archivo)

(
{
	var root, freqs;

	root = EnvGen.ar(
		Env([30, 31, 29.5], [4, 2]).circle
	).midicps;
	freqs = Array.geom(10, root.poll(4), 7/4); //.poll para imprimir en la postwindow los valores de las frecuencias

{
		Mix(
			BPF.ar(
				PinkNoise.ar,
				freqs,
				0.01,
				1
		))
	} !2
}.play
)

//También se puede modular el intervalo (todos los nombres de variables son lo que queramos). CUIDADO CON QUITAR MIDICPS AQUÍ. (Probar [1, 1] en velocidad con .circle)

(
{
	var grow, freqs;

	grow = EnvGen.ar(
		Env([2/1, 3/2, 7/4], [8, 4]).circle
	);
	freqs = Array.geom(10, 35, grow); //.poll para imprimir en la postwindow los valores de las frecuencias

{
		Mix(
			BPF.ar(
				PinkNoise.ar,
				freqs,
				0.01,
				1
		))
	} !2
}.play
)

//ENVOLVENTES PRE-HECHAS (métodos de conveniencia): .TRIANGLE, .SINE, .PERC, posibles con Env.new, pero más cómodo de esta forma (ver con ctrl + i código fuente, ver cómo provienen de Env.new igual)

Env.triangle //Argumentos dur y level
Env.triangle(1, 0.3).plot

{SinOsc.ar * EnvGen.ar(Env.triangle(1, 0.3))}.play
{SinOsc.ar * EnvGen.ar(Env.triangle(1, 0.3).circle)}.play //Con .circle

Env.sine //Argumentos dur y level. PARA SÍNTESIS GRANULAR
Env.sine(1, 0.3).plot

{SinOsc.ar * EnvGen.ar(Env.sine(1, 0.3))}.play

Env.perc //Argumentos attackTime, releaseTime, level y curve + NO PUEDE SER EXPONENTIAL (porque en las envolventes percusivas siempre se parte de cero.
Env.perc(0.01, 0.25, 0.3, -4).plot

{SinOsc.ar * EnvGen.ar(Env.perc(0.01, 0.25, 0.3, -4))}.play

//SEGUNDO ARGUMENTO DE ENVGEN (PRIMERO ES LA ENV): gate (como trigger o disparador), valor por defecto 1 (solo un impulso), pero con un Impulse como en ejemplo (alterna entre positivo y no positivo), vuelve a arrancar la envolvente desde el inicio una vez por segundo. Si el tiempo del trigger es menor que el tiempo que dura la envolvente, se vuelve a impulsar desde ahí al mismo punto (como si repitiéramos la nota en un piano con el sustain pulsado).
//Gate es el segundo argumento de EnvGen, este argumento recibe una señal, y cuando ésta es mayor que cero, EnvGen inicia o reinicia la envolvente.

(
{
	var trigger, senal, env;

	trigger = Impulse.ar(1);
	senal = SinOsc.ar;
	env = EnvGen.ar(Env.perc (0.01, 0.5, 0.3), trigger);
	senal * env
}.play
)

(
{
	var trigger, senal, env;

	trigger = Impulse.ar(2); //Aquí con 2 por segundo, se manda dos veces y no llega a caer nunca el sonido (no se llega a apagar)
	senal = SinOsc.ar;
	env = EnvGen.ar(Env.perc (0.01, 0.5, 0.3), trigger);
	senal * env
}.play
)

(
{
	var trigger, senal, env;

	trigger = Dust.ar(1); //También con dust para aleatoriedad en los impulsos (se puede aplicar al código de los acordes anteriores)
	senal = SinOsc.ar;
	env = EnvGen.ar(Env.perc (0.01, 0.5, 0.3), trigger);
	senal * env
}.play
)

//EJERCICIO: utilizando \linear, \exponential, \step o float, o los métodos .triangle, .sine o .perc, y el argumento gate de EnvGen como trigger (en senal se coloca un sonido cualquiera, éste es de la anterior obra)

(
{
	var trigger, senal, env;

	trigger = Dust.ar(5);

	senal = LFPulse.ar(
		100,
		0,
		LFDNoise0.ar(500, 0.3, 0.5),
		0.1 !2
	);

	env = EnvGen.ar(Env.perc(0.05, 0.05, 0.3), trigger);

	senal * env
}.play
)





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//EnvGen: gate (gate), esto es gate como gate (puede estar abierto (1) o cerrado (0), manteniendo la parte del sustain una cantidad determinada de tiempo), en lugar de como trigger (una acción y se acabó, como un golpe de percusión, como un botón). Antes, otro tipo de envolvente para poder utilizar el argumento gate como si fuera un gate

Env.adsr (attackTime, decayTime, sustainLevel, releaseTime, peakLevel, curve) //ARGUMENTOS: attackTime: tiempo que tarda en ir del silencio a la amplitud máxima (peakLevel), decayTime: tiempo que tarda en ir de amplitud máxima a nivel de sustain, sustainLevel (no time): amplitud del segmento de sustain como proporción del nivel máximo o peakLevel (se establece en relación al peak como tú quieras, por defecto toma la mitad de su amplitud), releaseTime: tiempo que tarda en ir desde el nivel de sustain al silencio, peakLevel: amplitud máxima de la envolvente, curve: tipo de curva.

{ EnvGen.ar(Env.adsr, LFPulse.ar(1)) }.plot(2) //Ver en gráfica (valores por defecto).
{ EnvGen.ar(Env.asr, LFPulse.ar(1)) }.plot(2) //Comparar con solo asr en la gráfica.

//Ahora ya podemos usar el EnvGen: gate (gate). Con gate = 1, la función arranca sonando (valor por defecto), hace el ataque y decay, y se queda en el sustain con el nivel especificado, durante un tiempo indefinido. Esta señal está puesta en la variable a, entonces para apagar (ir al release), habrá que enviar 0 a gate (como un botón, encendido: 1, apagado: 0, evaluando la línea). Pero aunque apaguemos el gate, la señal sigue corriendo hasta que no hagamos shift y punto. Fuera, el .set es para asignar ese valor a la variable

(
a = {arg gate = 1;
	var env;

	env = EnvGen.ar(
		Env.adsr(0.1, 0.2, 0.5, 1, 0.6, -4),
		gate
	);
	SinOsc.ar * env
}.scope
)

a.set(\gate, 0)
a.set(\gate, 1)

//Otro ejemplo: período de 5 segunos: 2.5 segundos de 1 y 2.5 segundos de 0. Trigger solo arranca, gate arranca y mantiene (aquí se apaga por la SinOsc, pero es diferente de un trigger porque se pueden modificar los tiempos, con el trigger no es flexible). Lo más común es utilizar la onda cuadrada para el gate (funciona como un switch)

(
{
	var gate, senal, envolvente;

	gate = LFPulse.ar(0.2, 0, 0.5); //Son mitad y mitad de 1 y 0 por el 0.5 del width, y son 5 en total por 1/5 que son 0.2 de frecuencia de la Pulse.

	senal = SinOsc.ar;

	envolvente = EnvGen.ar(
		Env.adsr(0.01, 0.1, 0.3, 1, 0.3),
		gate
	);

	senal * envolvente
}.play
)

//Se puede controlar gate con el ratón (se queda sonando hasta que soltemos, esta es la diferencia con el trigger, que solo enviaría la acción sin mantenerla)

(
{
	var gate, senal, envolvente;

	gate = MouseButton.kr(0, 1);

	senal = SinOsc.ar;

	envolvente = EnvGen.ar(
		Env.adsr(0.01, 0.1, 0.3, 1, 0.3),
		gate
	);

	senal * envolvente
}.play
)

