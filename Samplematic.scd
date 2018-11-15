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
	var looper = ~loopers[trackindex];
	Tdef((\track++trackindex).asSymbol, {
		inf.do {
			looper[\synth] = Synth(\playbuf, [
				buf: looper[\buf],
				// buf: ~bufs[0][~seq.next.mod(~bufs[0].size)],
				dur: looper[\dur],
				legato: looper[\legato],
				start: looper[\start],
				rate: looper[\rate],
				lopp: looper[\loop],
				attack: looper[\attack],
				sustain: looper[\sustain],
				release: looper[\release],
				amp: looper[\amp],
				pan: looper[\pan],
				out: looper[\out],
			]);
			looper[\rate].postln;
			looper[\dur].wait;
		};
	}).play;
};

~makeloopers = {
	~loopers = Array.newClear;
	~loopers = Array.fill(~numtracks, { arg i;
		// each looper is a dictionary
		var bufs, looper;
		looper = Dictionary.new;
		bufs = ~bufs[i];
		looper.postln;
		looper.put(\synth, nil); // this will hold the instance of the Synth so we can stop it immediately
		looper.put(\buf, bufs.choose); // choose a buffer randomly
		looper.put(\dur, 2);
		looper.put(\legato, 1);
		looper.put(\start, 0);
		looper.put(\rate, 1);
		looper.put(\loop, 1);
		looper.put(\attack, 0.01);
		looper.put(\sustain, 1);
		looper.put(\release, 0.1);
		looper.put(\amp, 0.3);
		looper.put(\pan, 0);
		looper.put(\out, 0);
	});
};

// 3. Functions to modify looper parameters

// most of the functions to modify the synth parameters use this method, so I put it together here.
~setparam = { arg looper, paramname, value;
	("Track "+looper+" - "+paramname+": "+value).postln;
	~loopers[looper].put(paramname.asSymbol, value);
	~loopers[looper][\synth].set(paramname.asSymbol, value);
};

~playlooper = { arg looper; Tdef((\track++looper).asSymbol).play;  };
~stoplooper = { arg looper;
	Tdef((\track++looper).asSymbol).stop;
	~loopers[looper][\synth].free;
};

~looperbuf = { arg looper, bufnum; ~setparam.value(looper, \buf, ~bufs[looper][bufnum]); };
~looperdur = { arg looper, value; ~setparam.value(looper, \dur, value); };
~looperstart = { arg looper, value; ~setparam.value(looper, \start, value); };
~looperrate = { arg looper, value; ~setparam.value(looper, \rate, value); };
~looperloop = { arg looper, value; ~setparam.value(looper, \loop, value); };
~looperlegato = { arg looper, value; ~setparam.value(looper, \legato, value); };
~looperattack = { arg looper, value; ~setparam.value(looper, \attack, value); };
~loopersustain = { arg looper, value; ~setparam.value(looper, \sustain, value); };
~looperrelease = { arg looper, value; ~setparam.value(looper, \release, value); };
~looperamp = { arg looper, value; ~setparam.value(looper, \amp, value); };
~looperpan = { arg looper, value; ~setparam.value(looper, \pan, value); };
~looperout = { arg looper, value; ~setparam.value(looper, \out, value); };

//  do whatever you want with a track
~looperrand = { arg looper;
	~looperbuf.value(looper, (~bufs[looper].size-1).rand);
	~looperrate.value(looper, 2.0.rand2);
	~looperdur.value(looper, [0.25, 0.5, 1, 2, 3, 4].choose);
	~looperlegato.value(looper, rrand(0.1, 1.3));
	~looperstart.value(looper, 1.0.rand);
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
	~makeloopers.value;
	// initialize the tracks
	~loopers.size.do { arg i;  ~maketrack.value(i); };


	s.plotTree;
	s.meter;
});
)
