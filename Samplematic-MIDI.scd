(
s.waitForBoot({
	"../synthdefs/SYNTHDEF.playbuf.scd".loadRelative;
	s.plotTree;
	s.meter;
	MIDIClient.init;
	MIDIIn.connectAll;
	~midiout  = MIDIOut(0);

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
~bufs = ~loadbufsubfolders.value(~samplespath);
~notes = Array.newClear(128);
~midiin.free;
~midiin = MIDIFunc.noteOn( {arg veloc, num, chan, src;
	var buf;
	// ("num: "+num).postln;
	// ("veloc: "+veloc).postln;
	// ("chan: "+chan).postln;
	// ("src: "+src).postln;
	buf = ~bufs[0][num.mod(~bufs[0].size)];
	(num + "(" + veloc + ")" + ": " + PathName(buf.path).fileName).postln;
	~notes[num] = Synth(\playbuf, [
		\buf, buf,
		\t_trig, 1
	]);
});
Pbindef(\a).stop;
Pbindef(\a).play;
)
(
Pbindef(\a,
	\type, \midi,
	\midiout, ~midiout,
	\degree, 10,//Pseq((0..10),inf),
	\dur, 1,
	\veloc, Prand((0..127), inf), // no xuta
);
)
