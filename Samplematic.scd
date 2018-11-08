(
~syncbus = Bus.control(s,1);
~clock = TempoClock.default;
~numplayers = 4;
~players = ();
~mixerbusses = ();

~samplespath = PathName(thisProcess.nowExecutingPath).parentPath++"samples/";


// utils
~loadbufs = {
	arg path;
	var bufs = ();
	PathName(path).entries.do{
		arg file, i;
		bufs.put( i, Buffer.read(s, file.fullPath); );
	};
	bufs
};

~makebusses = {
	arg numbusses;
	var busses = ();
	numbusses.do {
		arg i;
		busses.put(i, Bus.audio(s, 1));
	};
	busses
};

// boot sequence

~mixerbusses = ~makebusses.value(~numplayers);
s.options.numOutputBusChannels = s.options.numOutputBusChannels
+ ~mixerbusses[~mixerbusses.size-1].index  // last bus index
+ 1; // extra one for ~sync bus

s.waitForBoot({
	SynthDef(\sync, {
		arg dur=4, out=~syncbus;
		var freq;
		freq = 1 / dur;
		Out.kr(out, Impulse.kr(freq));
	}).add;

	SynthDef(\bpbuf,
		{
			arg buf,
			rate=1, startpos=0, endloop=1, phase=0, loop=1, t_reset=1, filterfreq=440,
			out, pan=0, amp=1,
			sync=4, attack=0, sustain=1.0, release=0.0,
			dur = 1;
			var sig, pos, env, trig;
			// phase = BufDur.kr(buf) * phase;
			phase = BufFrames.kr(buf) * phase;
			endloop = BufFrames.kr(buf) * endloop;
			rate = BufRateScale.kr(buf) * rate;
			// startpos = BufFrames.kr(buf) * abs({rate < 0} - startpos); // FIX!!!
			// startpos = BufFrames.kr(buf) * startpos;
			startpos = BufFrames.kr(buf) * (abs(rate*2) - 1 + startpos);
			dur = (BufDur.kr(buf) * dur) - attack;
			// trig = DelayN.kr(In.kr(sync), 4, phase) + t_reset + Impulse.kr(1/dur);
			trig = Impulse.kr(1/dur) + t_reset;

			pos = Phasor.ar(trig, rate, startpos, endloop, startpos);
			sig = BufRd.ar(1, Mix.ar(buf), pos + phase, loop);
			sig = sig * amp;

			// env = EnvGen.ar(
			// 	envelope: Env.new([0,1,1,0],[attack,dur,release]),
			// 	gate: trig,
			// 	doneAction:0
			// );
			// sig = PlayBuf.ar(
			// 	numChannels:2,
			// 	bufnum:Mix.ar(buf),
			// 	rate:rate,
			// 	trigger: trig,
			// 	startPos:startpos,
			// 	doneAction:0
			// );
			// sig = sig * amp * env;

			// sig = BPF.ar(sig, filterfreq, 1);
			Out.ar(out, Mix.ar(sig));
	}).add;

	SynthDef(\mixer, {
		arg in0, in1, in2, in3,
		 amp0=1, amp1=1, amp2=1, amp3=1,
		amp = 0.3,
		out=0;
		var ins, amps;
		ins = In.ar([in0, in1, in2, in3]);
		amps = [amp0, amp1, amp2, amp3];
		Out.ar(out, Splay.ar(ins * amps * amp, 0.25));
	}).add;

	~bufs = ~loadbufs.value(~samplespath);

	s.sync;
	~mixer = Synth(\mixer);
	~sync = Synth(\sync, [out: ~syncbus]);
	s.sync;
	~numplayers.do {
		arg i;
		var defaultbuf, defaultdur, outbus;
		defaultbuf = ~bufs[0];
		defaultdur = defaultbuf.duration;
		outbus = ~mixerbusses[i];
		~players.put( i, Synth(\bpbuf, [
			sync: ~syncbus,
			buf: defaultbuf,
			dur: defaultdur,
			out: outbus
		]));
		~stopplayer.value(i);
		~mixer.set(\in++(i.asSymbol), outbus);
	};

	~mixerbusses.do { arg bus, i;
		var name = \in++(i);
		(i+": "+bus.index).postln;
		~mixer.set(name, bus);
		~mixer.get(name, {arg v; (name+":: "+v).postln});
	};

	s.plotTree;
	s.meter;
	"samplematic-gui.scd".loadRelative;
});

~playplayer = {arg player, value=1; ~players[player].set(\amp, value);};
~stopplayer = {arg player; ~playplayer.value(player, 0);};
~resetplayer = {arg player; ~players[player].set(\t_reset, 1);};
~playerbuf = {arg player, buf; ~players[player].set(\buf, buf);};
~playerdur = {arg player, value; ~players[player].set(\dur, value);};
~playerrate = {arg player, value;
	~players[player].set(\rate, value);
	// value = if (value < 0, {1 - abs(value)}, {abs(value)});
	// ~playerstartpos.value(player, abs(1 - value));
};
~playerphase = {arg player, value; ~players[player].set(\phase, value);};
~playerstartpos= {arg player, value; ~players[player].set(\startpos, value);};
~playeramp = {arg player, value; ~mixer.set(\amp++player.asSymbol, value)};

~mastervolume = {arg value; ~mixer.set(\amp, value);};
~loopdur = {arg value;
	~sync.set(\dur, value);
	~players.size.do{ arg i;
		~playerdur.value(i);
		~resetplayer.value(i); };
};
~syncAll = {~players.size.do{ arg player; ~resetplayer.value(player) };};
)