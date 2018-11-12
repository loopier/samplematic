(
~samplespath = PathName(thisProcess.nowExecutingPath).parentPath++"samplebanks/";
~numtracks = 3;
~seqsize = 4;

// use this for directories containing sample files
~loadbufs = {
	arg path;
	var bufs = ();
	PathName(path).entries.do{
		arg file, i;
		bufs.put( i, Buffer.read(s, file.fullPath); );
	};
	bufs
};

// use this for directories containing subfolders with sample files
~loadbufsubfolders = {
	arg path;
	var bufs = ();
	PathName(path).entries.do{
		arg subdir, i;
		bufs.put(
			i,
			Array.fill(subdir.entries.size, { |x| Buffer.read(s, subdir.entries.at(x).fullPath) });
		);
	};
	bufs
};

s.waitForBoot({
	SynthDef(\playbufm, { |out=0, amp=0.5, pan=0, buf, rate=1, t_trig=1, start=0, attack=0.01, sustain=1, release=0.01|
		var sig, end, startpos, isForward, frames;
		isForward = (rate < 0);
		frames = BufFrames.kr(buf);
		startpos = abs( (frames * isForward) - (frames * start) ) - (2 * isForward);
		sig = PlayBuf.ar(1, Mix.ar(buf), BufRateScale.kr(buf) * rate, 1, startpos);
		sig = sig * EnvGen.kr(Env.linen(attack, sustain, release), t_trig, doneAction:2);
		sig = sig * amp;
		sig = Pan2.ar(sig, pan);
		Out.ar(out, sig);
	}).add;

	// ~bufs = ~loadbufs.value(~samplespath);
	~bufs = ~loadbufsubfolders.value(~samplespath);
});

s.plotTree;
s.meter;

// makes a sequencer
~maketrack = {
	arg name, bufs, size=4, dur=1, rate=1, legato=1, start=0, phase=0, out=0;
	var seq = Array.rand(size, 0, bufs.size-1);
	// PathName(buf.path).fileName.postln;
	Pbindef(name.asSymbol,
		\instrument, \playbuf,
		\buf, Pseq(bufs[seq],inf),
		\dur, dur,
		\rate, rate,
		\legato, legato,
		\start, start,
		\phase, phase,
		\out, out,
	).play;
	Pbindef(name.asSymbol).quant = 0;
};

~setparam = { arg name, param, value;
	Pbindef(name.asSymbol, param.asSymbol, value);
	(name++" "++param++": "++value).postln;
};
~setloopsequence = { arg name, size;
	var bufs = ~bufs.choose; //FIX: !!! choosing a random directory until I find a way to
	var seq = Array.rand(size, 0, bufs.size-1);
	Pbindef(name.asSymbol,
		\buf, Pseq(bufs[seq], inf,
	));
};

~init = {
	arg numtracks=~numtracks;
	numtracks.size.postln;
	numtracks.do { arg i;
		~maketrack.value("track"++i, ~bufs.choose);
	};
};

~loopsize = { arg tracknum, value; ~setloopsequence.value("track"++tracknum, value.ceil); }; // rounds up floats
~loopbuf = { arg tracknum, value; ~setparam.value("track"++tracknum, \buf, ~bufs[value]); };
~loopdur = { arg tracknum, value; ~setparam.value("track"++tracknum, \dur, value); };
~looprate = { arg tracknum, value; ~setparam.value("track"++tracknum, \rate, value); };
~looplegato = { arg tracknum, value; ~setparam.value("track"++tracknum, \legato, value);};
~loopstart = { arg tracknum, value; ~setparam.value("track"++tracknum, \start, value);};
~loopphase = { arg tracknum, value; ~setparam.value("track"++tracknum, \phase, value);};
~loopplay = { arg tracknum; Pbindef(("track"++tracknum).asSymbol).play };
~loopstop = { arg tracknum; Pbindef(("track"++tracknum).asSymbol).stop };
)
// ~maketrack.value("track1", ~bufs.choose)
// PdefGui(Pdef(\track1))