(
s.waitForBoot({
	~numbufs = 5;
	~loopdur = 4; // seconds

	"Samplematic server started".postln;

	~sync = Ndef(\sync, {Impulse.kr(TempoClock.default.tempo / ~loopdur)});

	~bufs = ();
	// ~bufs = Loopier.loadSampleFiles("/Users/roger/Dropbox/++PROJECTS/LOOPIER/code/SAMPLEMATIC/samples/1");
	~bufs = Loopier.loadSampleDirectories("/Users/roger/Dropbox/++PROJECTS/LOOPIER/code/SAMPLEMATIC/samples");
	// "bufs: "++~bufs.size.postln;
	~players = ();
	~bufs.size.do({|i|
		~players.put(i, Ndef(\players++i, {|buf, rate=1, startpos=0, endloop=1, t_reset=0, filterfreq=440, sync=0|
			var sig, pos, env;
			t_reset = Select.kr(sync, [t_reset, ~sync.kr]);
			startpos = BufFrames.kr(buf) * startpos;
			endloop = BufFrames.kr(buf) * endloop;
			pos = Phasor.ar(t_reset, rate * BufRateScale.kr(buf), startpos, endloop);
			sig = BufRd.ar(2, buf, pos, 1);
			// sig = BPF.ar(sig, filterfreq, 1);
			sig = sig * \amp.kr;
		}));
		~players[i].set(\buf, ~bufs[i.asString][0]);
	});
	"players: "++~players.size.postln;
});

)
(

w = Window.new("Samplematic").front;
w.bounds = Rect(w.bounds.left, w.bounds.top, 800, ~bufs.size * 100);
w.view.decorator = FlowLayout(w.view.bounds);
w.view.decorator.gap=2@2;

// Player's GUI
ControlSpec.specs[\rate] = ControlSpec(-4, 4, 'lin', 0.25, 1, ""); // overrides default \rate.asSpec
ControlSpec.specs[\phase] = ControlSpec(-1, 1, 'lin', 0, 0, ""); // overrides default \phase.asSpec
ControlSpec.specs[\startpos] = ControlSpec(0, 0.99, \lin, 0, 0, ""); // start loop at this position (normalized)
ControlSpec.specs[\endloop] = ControlSpec(0.01, 1, \lin, 0, 1, ""); // loop duration (normalized)
ControlSpec.specs[\amp] = ControlSpec(0, 1, 'linear', 0, 0.2, "");

~players.do({|player, index|
	var filterCtl, startposCtl, endloopCtl, rateCtl, phaseCtl, ampCtl;
	var startBtn, resetBtn, syncBtn;
	var samplesMenu;
	player.set(\amp, 0.2);

	startBtn = Button(w, 45@90);
	startBtn.states = [
		["Play", Color.white, Color.green(0.27)],
		["Stop", Color.white, Color.red(0.7)],
	];
	startBtn.action = {|view|
		if ( view.value == 1) {
			"play ".post;player.postln;
			player.play;
		} {
			"stop".postln;
			player.stop;
		}
	};

	syncBtn = Button(w, 45@90);
	syncBtn.states = [
		["Free", Color.white, Color.yellow(0.4)],
		["Sync", Color.white, Color.yellow(0.7)],
	];
	syncBtn.action = {|view|
		player.set(\sync, view.value);
		"sync: "++view.value.postln;
	};

	resetBtn = Button(w, 45@90);
	resetBtn.states = [
	["Reset", Color.black, Color.gray]
	];
	resetBtn.action = {|view|
		player.set(\t_reset, 1);
	};

	filterCtl = EZKnob(w, 60@90, "filter", \freq, {|ez|
		player.set(\filterfreq, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln;
	});

	startposCtl = EZKnob(w, 60@90, "start", \startpos, {|ez|
		player.set(\startpos, ez.value);
		if (ez.value > endloopCtl.value) {
			endloopCtl.value = ez.value + 0.01;
			};
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
		});

	endloopCtl = EZKnob(w, 60@90, "end", \endloop, {|ez|
		player.set(\endloop, ez.value);
		if (ez.value < startposCtl.value) {
			startposCtl.value = ez.value - 0.01;
			};
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
		});

	rateCtl = EZKnob(w, 60@90, "rate", \rate, {|ez|
		player.set(\rate, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln;
		});

	phaseCtl = EZKnob(w, 60@90, "phase", \phase, {|ez|
		player.set(\phase, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
		});

	ampCtl = EZKnob(w, 60@90, "amp", \amp, {|ez|
		player.set(\amp, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
		});

	samplesMenu = EZPopUpMenu.new(w, 200@22, "Samples: ");
	~bufs[index.asString].do({|buf|
		buf.postln;
		samplesMenu.addItem(PathName(buf.path).fileName.postln, {player.set(\buf, buf)});
	});
		// samplesMenu.addItem(~

	w.view.decorator.nextLine;
});

// General GUI

w.view.onClose_({
	s.freeAll;
});
)