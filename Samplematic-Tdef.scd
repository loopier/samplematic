(
s.waitForBoot({
	"../synthdefs/SYNTHDEF.playbuf.scd".loadRelative;
	s.plotTree;
	s.meter;
});

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
)
(
~samplespath = PathName(thisProcess.nowExecutingPath).parentPath++"samplebanks/";
~bufs = ();
~bufs = ~loadbufsubfolders.value(~samplespath);
~looper = Dictionary.new;
~looper.put(\buf, ~bufs[0][0]);
~looper.put(\dur, 1);
~looper.put(\legato, 1);

~seq = Pseq((0..19),inf).asStream;
~durs = Pseq([1,0.95], inf).asStream;
)
(
Tdef(\track1, {
	inf.do { |i|
		Synth(\playbufexperimental, [
			buf: ~looper[\buf],
			legato: ~looper[\legato],
			dur: ~looper[\dur]]);
		i.postln;
		~looper[\dur].wait;
	};
}).play;
)