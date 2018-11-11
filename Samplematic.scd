// TODO: Add button to randomize every param in a buffer, and one to get a random bank of 4 randomized buffers with randomized params
// TODO: Add chopper
(
~numplayers = 4;
~players;
~mixerbusses = ();
~syncbus = Bus.control(s, 1);

// used to save or post the parameters of what is currently playing
~currentstate = Array.fill(~numplayers, {Dictionary.new});

// utils functions
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

~makeplayers = {
	Array.fill(~numplayers, {
		arg i;
		var defaultbuf, outbus;
		defaultbuf = ~bufs[0];
		outbus = ~mixerbusses[i]; // patch output to mixer bus
		Synth(\bpbufrd, [
			buf: defaultbuf,
			out: outbus,
			syncbus: ~syncbus; // path clock input from clock bus
		]);
	});
};

// boot sequence
// prepare control and audio busses
~mixerbusses = ~makebusses.value(~numplayers);
s.options.numOutputBusChannels = s.options.numOutputBusChannels
+ ~mixerbusses[~mixerbusses.size-1].index  // last bus index
+ 1; // extra one for ~sync bus

~init = {
	arg
	path = PathName(thisProcess.nowExecutingPath).parentPath++"samples/",
	numplayers =4;
	~numplayers = numplayers;
	~samplespath = path;
	s.waitForBoot({
		// Clock
		SynthDef(\sync, { arg dur=4; Out.kr(~syncbus, Impulse.kr(1/dur)); }).add;
		// Samples player
		SynthDef(\bpbufrd, {
			arg buf, rate=1.0, start=0.0, dur=1.0, t_reset=0, phase=0.0, amp=1, out=0, syncbus=2;
			var sig, pos, end, resetpos, sync;
			sync = In.kr(syncbus);
			dur = BufDur.kr(buf) * dur;
			rate = BufRateScale.kr(buf) * rate;
			resetpos = BufFrames.kr(buf) * start;
			end = BufFrames.kr(buf) * (1-start * dur);
			// phase = BufFrames.kr(buf) * phase;
			pos = Phasor.ar(
				trig: Impulse.kr(1/dur, phase) + t_reset + sync,
				rate: rate,
				start: resetpos,
				end: end,
				resetPos:resetpos
			);
			sig = BufRd.ar(2, buf, pos, 0);
			sig = Mix.ar(sig) * amp;
			Out.ar(out, Mix.ar(sig));
		}).add;
		// Mixer
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

		// load samples to buffers
		~bufs = ~loadbufs.value(~samplespath);

		s.sync;
		// setup clock
		~mixer = Synth(\mixer);
		s.sync;
		// setup players
		~players = ~makeplayers.value;
		// path player outputs to mixer inputs
		~numplayers.do { arg i; ~mixer.set(\in++(i.asSymbol), ~mixerbusses[i]); };
	});
};
//
~gui = { "samplematic-gui.scd".loadRelative };

// randomize parameters of one player
// @param   Int    Index of player
~randomizeplayer = {
	arg player, verbose=false;
	var buf, dur, start, phase, rate, amp;
	buf = (~bufs.size-1).rand;
	dur = rrand(0.1,1);
	start = rrand(0.1,1);
	phase = rrand(0.1,1);
	rate = rrand(0.1,1.0) * [-1,1].choose;
	amp = rrand(0.0,1.0);
	~playerbuf.value(player, buf);
	~playerdur.value(player, dur);
	~playerstartpos.value(player, start);
	~playerphase.value(player, phase);
	~playerrate.value(player, rate);
	~playeramp.value(player, amp);
	~currentstate[player].put(\sample, ~bufsamplename.value(buf));
	~currentstate[player].put(\buf, buf);
	~currentstate[player].put(\rate, rate.asStringPrec(2));
	~currentstate[player].put(\dur, dur.asStringPrec(2));
	~currentstate[player].put(\start ,start.asStringPrec(2));
	~currentstate[player].put(\phase, phase.asStringPrec(2));
	~currentstate[player].put(\amp, amp.asStringPrec(2));
	~postplayer.value(player);
};

~bufsamplename = { arg bufindex; PathName(~bufs[bufindex].path).fileName; };

// randomize all players at once
~randomizeall = { ~players.size.do{ arg i;  ~randomizeplayer.value(i); }; };

// Auto-play
Tdef(\autoplay, {
	inf.do {
		var seconds, numchanges;
		seconds = (Array.geom(5, 1, 2).choose); // seconds until next change
		~players.size.do {
			arg player;
			var buf, dur, start, phase, rate, amp, change;
			change = ((player+2)/(~players.size*2)).coin;
			if (change) {
				// [player, change].postln;
				~randomizeplayer.value(player);
			} {
				[player, change].postln;
			};
		};
		seconds.postln;
		seconds.wait;
		"".postln;
	};
});

// samplematic functions to control players
~playplayer = {arg player, value=1;
	~playeramp.value(player, value);
	("play "++player++": "++value).postln;

};
~stopplayer = {arg player; ~playplayer.value(player, 0);};
~resetplayer = {arg player;
	~players[player].set(\t_reset, 1);
	("reset "+player).postln;
};
~playerbuf = {arg player, buf;
	~currentstate[player][\buf] = PathName(~bufs[buf].path).fileNameWithoutExtension;
	~players[player].set(\buf, ~bufs[buf]);
	// ("buf "++player++": "++PathName(buf.path).fileNameWithoutExtension).postln;
};
~playerdur = {arg player, value;
	if (value > 0.99) {value = 1} {value};
	// ~currentstate[player][\dur] = value.asStringPrec(2).asFloat;
	~players[player].set(\dur, value);
	// ("dur "++player++": "++value.asStringPrec(2)).postln;
};
~playerrate = {arg player, value;
	// ~currentstate[player][\rate] = value.asStringPrec(2).asFloat;
	~players[player].set(\rate, value);
	// ("rate "++player++": "++value.asStringPrec(2)).postln;

};
~playerphase = {arg player, value;
	// ~currentstate[player][\phase] = value.asStringPrec(2).asFloat;
	~players[player].set(\phase, value);
	// ("phase "++player++": "++value.asStringPrec(2)).postln;

};
~playerstartpos= {arg player, value;
	// ~currentstate[player][\start] = value.asStringPrec(2).asFloat;
	~players[player].set(\start, value);
	// ("start "++player++": "++value.asStringPrec(2)).postln;

};
~playeramp = {arg player, value;
	// ~currentstate[player][\amp] = value.asStringPrec(2).asFloat;
	~mixer.set(\amp++player.asSymbol, value);
	// ("amp "++player++": "++value.asStringPrec(2)).postln;
};

~resetplayerparams = {arg player;
	~playeramp.value(player, 1);
	~playerrate.value(player, 1);
	~playerdur.value(player, 1);
	~playerstartpos.value(player, 0);
	~playerphase.value(player, 0);
};

~mastervolume = {arg value; ~mixer.set(\amp, value);};
~loopdur = {arg value;
	~sync.set(\dur, value);
	~players.size.do{ arg i;
		~playerdur.value(i);
		~resetplayer.value(i); };
};
~syncall = {~players.size.do{ arg player; ~resetplayer.value(player) };};
~stopall = { s.freeAll };
~resetall = { ~players.size.do { arg i; ~resetplayerparams.value(i);};};

~autoplay = { arg bPlay=true;
	if (bPlay)
	{ Tdef(\autoplay).play }
	{ Tdef(\autoplay).stop };
};
~autoplaystop = { ~autoplay.value(false); };

// Execute this when you like the sound of it, to save the current
// parameters in a file
~savecomposition = {
	var file, filename, compositionstring;
	filename = ~logpath++"radiomatic."++Date.getDate.asSortableString++".txt";
	File.use(filename, "w", { arg f;
		~currentstate.do({ arg dic, i;
			f.write(([i]++dic.asArray).asString);
			f.write("\n");
		})
	});
};
// post parameters for one player
~postplayer = { arg player;
	// ~currentstate[player].asArray.postln;
	[
		("player: "+player),
		("buf: "+~currentstate[player][\buf]),
		("sample: "+~currentstate[player][\sample]),
		("rate: "+~currentstate[player][\rate]),
		("dur: "+~currentstate[player][\dur]),
		("phase: "+~currentstate[player][\phase]),
		("start: "+~currentstate[player][\start]),
		("amp: "+~currentstate[player][\amp])
	].postln;
};
// post current parameters
~postall = {
	// ~currentstate.do({ arg dic, i;
	// 	([i]++dic.asArray).asString.postln;
// });
	~players.size.do { arg i;
		~postplayer.value(i);
	};
};
)