(
s.waitForBoot({
	"../synthdefs/SYNTHDEF.playbuf.scd".loadRelative;
	s.plotTree;
	s.meter;
	~oscsend = NetAddr.localAddr;
	~oscrecieve = NetAddr.localAddr;
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
~oscmsgaddr = "/samplematic";
~notes = Array.newClear(128);
~osc.free; // make sure there's only one instance of OSCFunc
~osc= OSCFunc(
	{ arg msg, time, addr, port;
		var buf, num;
		("msg: "+msg).postln;
/*		("time: "+time).postln;
		("addr: "+addr).postln;
		("port: "+port).postln;*/
		num = msg[1].mod(~bufs[0].size);
		buf = ~bufs[0][num];
	(num + "(" + veloc + ")" + ": " + PathName(buf.path).fileName).postln;
	~notes[num] = Synth(\playbuf, [
		\buf, buf,
		\t_trig, 1
	]);
	},
	~oscmsgaddr, ~oscreceive);
)
~oscsend.sendMsg(~oscmsgaddr, "thee", 12, 1.2)
(
var buf = Pseq((0..19),inf).asStream;
Pbindef(\osc,
	\type, \midi,
	\msg, Pfunc({~oscsend.sendMsg(~oscmsgaddr, buf.next)})
).play
)