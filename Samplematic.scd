(
s.waitForBoot({
	~numbufs = 5;
	~loopdur = 4; // seconds

	"Samplematic server started".postln;

	~bufs = ();
	~bufs = Loopier.loadSampleFiles("/Users/roger/Dropbox/++PROJECTS/LOOPIER/code/SAMPLEMATIC/samples/1");
	~players = ();
	~bufs.size.do({|i|
		~players.put(i,
			NodeProxy.new.play;
		);
		~players[i].source = {
				| buf, filterfreq=440, t_trig=0, startpos=0, endloop=1, rate=1, phase=0, amp=0.2, loop=1, pan=0 |
				var sig, trig, pos;
			buf = ~bufs[i];
			startpos = BufFrames.kr(buf) * startpos;
			endloop = BufFrames.kr(buf) * endloop;
			pos = Phasor.ar(t_trig, rate * BufRateScale.kr(buf), startpos, endloop);
			sig = BufRd.ar(2, buf, pos, 1);
			sig = sig * \gate.kr;
				Pan2.ar(sig * amp);
			};
		~players[i].set(\gate, 0);
	});
	~players.size.postln;
	~bufs.size.postln;
	});
)
(

w = Window.new("Samplematic").front;
w.bounds = Rect(w.bounds.left, w.bounds.top, 500, ~bufs.size * 100);
w.view.decorator = FlowLayout(w.view.bounds);
w.view.decorator.gap=2@2;

// Control buffer players
ControlSpec.specs[\rate] = ControlSpec(-4, 4, 'lin', 0.25, 1, ""); // overrides default \rate.asSpec
ControlSpec.specs[\phase] = ControlSpec(-1, 1, 'lin', 0, 0, ""); // overrides default \phase.asSpec
ControlSpec.specs[\startpos] = ControlSpec(0, 0.99, \lin, 0, 0, ""); // start loop at this position (normalized)
ControlSpec.specs[\endloop] = ControlSpec(0.01, 1, \lin, 0, 1, ""); // loop duration (normalized)
ControlSpec.specs[\amp] = ControlSpec(0, 1, 'linear', 0, 0.2, "");

~players.size.do({|i|
	var filterCtl, startposCtl, endloopCtl, rateCtl, phaseCtl, ampCtl;
	var startBtn, resetBtn;
	var node; // synth

	node = ~players[i];
	// node.gui;

	startBtn = Button(w, 90@90);
	startBtn.states = [
		["Play", Color.white, Color.green(0.27)],
		["Stop", Color.white, Color.red(0.7)],
	];
	startBtn.action = {|view|
		node.set(\gate, view.value);
	};

	resetBtn = Button(w, 20@20);
	resetBtn.states = [
		["Reset", Color.black, Color.gray]
	];
	resetBtn.action = {|view|
		node.reset;
	};

	filterCtl = EZKnob(w, 60@90, "filter", \freq, {|ez| (ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln});

	startposCtl = EZKnob(w, 60@90, "start", \startpos, {|ez|
		node.set(\startpos, ez.value);
		if (ez.value > endloopCtl.value) {
			endloopCtl.value = ez.value + 0.01;
		};
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
	});

	endloopCtl = EZKnob(w, 60@90, "end", \endloop, {|ez|
		node.set(\endloop, ez.value);
		if (ez.value < startposCtl.value) {
			startposCtl.value = ez.value - 0.01;
		};
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
	});

	rateCtl = EZKnob(w, 60@90, "rate", \rate, {|ez|
		node.set(\rate, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln;
	});

	phaseCtl = EZKnob(w, 60@90, "phase", \phase, {|ez|
		node.set(\phase, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
	});

	ampCtl = EZKnob(w, 60@90, "amp", \amp, {|ez|
		node.set(\amp, ez.value);
		 (ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
	});

	w.view.decorator.nextLine;
});

w.view.onClose_({
	s.freeAll;
});
)