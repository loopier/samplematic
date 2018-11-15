(
// 1. Global variables
// number of tracks
~numtracks = 3;
// Path to the directory of the samples.
// Samples should be in subfolders.
// There should be one subfolder per track.
// Put the samples you want in each track to the corresponding subfolder
~samplespath = PathName(thisProcess.nowExecutingPath).parentPath++"samplebanks/";

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

// 2. Global funcitons
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

~maketrack = { arg trackindex;
	var loop = ~loops[trackindex];
	Tdef((\track++trackindex).asSymbol, {
		inf.do {
			loop[\synth] = Synth(\playbuf, [
				buf: loop[\buf],
				// buf: ~bufs[0][~seq.next.mod(~bufs[0].size)],
				dur: loop[\dur],
				legato: loop[\legato],
				start: loop[\start],
				rate: loop[\rate],
				lopp: loop[\loop],
				attack: loop[\attack],
				sustain: loop[\sustain],
				release: loop[\release],
				amp: loop[\amp],
				pan: loop[\pan],
				out: loop[\out],
			]);
			loop[\rate].postln;
			loop[\dur].wait;
		};
	}).play;
};

~makeloops = {
	~loops = Array.newClear;
	~loops = Array.fill(~numtracks, { arg i;
		// each loop is a dictionary
		var bufs, loop;
		loop = Dictionary.new;
		bufs = ~bufs[i];
		loop.postln;
		loop.put(\synth, nil); // this will hold the instance of the Synth so we can stop it immediately
		loop.put(\buf, bufs.choose); // choose a buffer randomly
		loop.put(\dur, 2);
		loop.put(\legato, 1);
		loop.put(\start, 0);
		loop.put(\rate, 1);
		loop.put(\loop, 1);
		loop.put(\attack, 0.01);
		loop.put(\sustain, 1);
		loop.put(\release, 0.1);
		loop.put(\amp, 0.3);
		loop.put(\pan, 0);
		loop.put(\out, 0);
	});
};

// 3. Functions to modify loop parameters

// most of the functions to modify the synth parameters use this method, so I put it together here.
~setparam = { arg loop, paramname, value;
	("Track "+loop+" - "+paramname+": "+value).postln;
	~loops[loop].put(paramname.asSymbol, value);
	~loops[loop][\synth].set(paramname.asSymbol, value);
};

~playloop = { arg loop; Tdef((\track++loop).asSymbol).play;  };
~stoploop = { arg loop;
	Tdef((\track++loop).asSymbol).stop;
	~loops[loop][\synth].free;
};

~loopbuf = { arg loop, bufnum; ~setparam.value(loop, \buf, ~bufs[loop][bufnum]); };
~loopdur = { arg loop, value; ~setparam.value(loop, \dur, value); };
~loopstart = { arg loop, value; ~setparam.value(loop, \start, value); };
~looprate = { arg loop, value; ~setparam.value(loop, \rate, value); };
~looploop = { arg loop, value; ~setparam.value(loop, \loop, value); };
~looplegato = { arg loop, value; ~setparam.value(loop, \legato, value); };
~loopattack = { arg loop, value; ~setparam.value(loop, \attack, value); };
~loopsustain = { arg loop, value; ~setparam.value(loop, \sustain, value); };
~looprelease = { arg loop, value; ~setparam.value(loop, \release, value); };
~loopamp = { arg loop, value; ~setparam.value(loop, \amp, value); };
~looppan = { arg loop, value; ~setparam.value(loop, \pan, value); };
~loopout = { arg loop, value; ~setparam.value(loop, \out, value); };

//  do whatever you want with a track
~looprand = { arg loop;
	~loopbuf.value(loop, (~bufs[loop].size-1).rand);
	~looprate.value(loop, 2.0.rand2);
	~loopdur.value(loop, [0.25, 0.5, 1, 2, 3, 4].choose);
	~looplegato.value(loop, rrand(0.1, 1.3));
	~loopstart.value(loop, 1.0.rand);
};

// randomize everything!
~random = {
	~loops.size.do { arg i;
		~looprand.value(i);
	};
};

~seq = Pseq((0..19),inf).asStream;
~durs = Pseq([1,0.95], inf).asStream;


// 4. Server boot sequence
s.waitForBoot({
	// get synth definitions from another file
	"samplematic-synthdefs.scd".loadRelative;

	// load sample files into buffer arrays
	~bufs = ();
	~bufs = ~loadbufsubfolders.value(~samplespath);
	s.sync; // wait for buffers to be loaded

	// initialize loop players
	~makeloops.value;
	// initialize the tracks
	~loops.size.do { arg i;  ~maketrack.value(i); };


	s.plotTree;
	s.meter;
});
)
