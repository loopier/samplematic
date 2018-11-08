(
~numplayers = 4;
~players;
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
	SynthDef(\bpbufrd, {
		arg buf, rate=1.0, start=0.0, dur=1.0, t_reset=0, phase=0.0, amp=1, out=0;
		var sig, pos, end, resetpos;
		dur = BufDur.kr(buf) * dur;
		rate = BufRateScale.kr(buf) * rate;
		end = BufFrames.kr(buf);
		resetpos = BufFrames.kr(buf) * start;
		// phase = BufFrames.kr(buf) * phase;
		pos = Phasor.ar(
			trig: Impulse.kr(1/dur, phase) + t_reset,
			rate: rate,
			start: 0,
			end: end,
			resetPos:resetpos
		);
		sig = BufRd.ar(2, buf, pos, 0);
		sig = Mix.ar(sig) * amp;
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
	s.sync;
	~players = Array.fill(~numplayers, {
		arg i;
		var defaultbuf, outbus;
		defaultbuf = ~bufs[0];
		outbus = ~mixerbusses[i];
		Synth(\bpbufrd, [
			buf: defaultbuf,
			out: outbus
		]);
	});

	~players.size.postln;
	~numplayers.do { arg i; ~mixer.set(\in++(i.asSymbol), ~mixerbusses[i]); };

	s.plotTree;
	s.meter;

	// "samplematic-gui.scd".loadRelative; /// FIX: Interfears with synth set.() commands (???)
});

~playplayer = {arg player, value=1; ~playeramp.value(player, value)};
~stopplayer = {arg player; ~playplayer.value(player, 0);};
~resetplayer = {arg player; ~players[player].set(\t_reset, 1); player.postln};
~playerbuf = {arg player, buf; ~players[player].set(\buf, buf);};
~playerdur = {arg player, value;
	if (value > 0.99) {value = 1} {value};
	~players[player].set(\dur, value);
	~players[player].get(\dur, {arg v; v.postln});
};
~playerrate = {arg player, value; ~players[player].set(\rate, value); };
~playerphase = {arg player, value; ~players[player].set(\phase, value);};
~playerstartpos= {arg player, value; ~players[player].set(\start, value);};
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