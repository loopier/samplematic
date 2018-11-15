(
~samplespath = PathName(thisProcess.nowExecutingPath).parentPath++"samplebanks/";
// ~samplespath = "/Users/roger/Dropbox/++PROJECTS/LOOPIER/samples/";
~numtracks = 3;
~seqsize = 4;

~currentbufs = List();

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
	// SynthDef(\playbufm, { |out=0, amp=0.5, pan=0, buf, rate=1, t_trig=1, start=0, attack=0.01, sustain=1, release=0.01|
	// 	var sig, end, startpos, isForward, frames;
	// 	isForward = (rate < 0);
	// 	frames = BufFrames.kr(buf);
	// 	startpos = abs( (frames * isForward) - (frames * start) ) - (2 * isForward);
	// 	sig = PlayBuf.ar(1, buf, BufRateScale.kr(buf) * rate, 1, startpos);
	// 	sig = sig * EnvGen.kr(Env.linen(attack, sustain, release), t_trig, doneAction:2);
	// 	sig = Mix.ar(sig) * amp;
	// 	sig = Pan2.ar(sig, pan);
	// 	Out.ar(out, sig);
	// }).add;

	"../synthdefs/SYNTHDEF.playbuf.scd".loadRelative;

	// ~bufs = ~loadbufs.value(~samplespath);
	~bufs = ~loadbufsubfolders.value(~samplespath);
});

s.plotTree;
s.meter;

// makes a sequencer
~maketrack = {
	arg name, bufs, size=1, dur=1, rate=1, legato=1, start=0, phase=0, out=0;
	// Make an array of random samples
	var seq = Array.rand(size, 0, bufs.size-1);
	// Save it in a pattern
	var buf = Pseq(bufs[seq],inf); // buf: current buf in the pattern
	// var channels = buf.numChannels;
	Pbindef(name.asSymbol,
		\instrument, \playbufm,
		\buf, buf,
		\channels, buf.numChannels,
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
~setloopsequence = { arg tracknum, size, buf=nil;
	var seq, bufs;
	bufs = ~bufs[tracknum];
	seq = Array.rand(size, 0,  bufs.size-1);
	if (buf != nil) { seq = [buf] };
	Pbindef(("track"++tracknum).asSymbol,
		\buf, Pseq(bufs[seq],inf)
	);
	seq
};

~init = {
	arg numtracks=~numtracks;
	numtracks.size.postln;
	numtracks.do { arg i;
		var bufs = ~bufs[i].choose;
		~currentbufs.add(i, bufs);
		~currentbufs.postln;
		~maketrack.value("track"++i, ~bufs.choose);
	};
};

~loopsize = { arg tracknum, size; ~setloopsequence.value(tracknum, size); }; // rounds up floats
~loopbuf = { arg tracknum, buf; ~setloopsequence.value(tracknum, 1, buf); };
~loopdur = { arg tracknum, value; ~setparam.value("track"++tracknum, \dur, value); };
~looprate = { arg tracknum, value; ~setparam.value("track"++tracknum, \rate, value); };
~looplegato = { arg tracknum, value; ~setparam.value("track"++tracknum, \legato, value);};
~loopstart = { arg tracknum, value; ~setparam.value("track"++tracknum, \start, value);};
~loopphase = { arg tracknum, value; ~setparam.value("track"++tracknum, \phase, value);};
~loopplay = { arg tracknum; Pbindef(("track"++tracknum).asSymbol).play };
~loopstop = { arg tracknum; Pbindef(("track"++tracknum).asSymbol).stop };
)
// PdefGui(Pdef(\track1))