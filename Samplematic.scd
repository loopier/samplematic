(
s.waitForBoot({
	~numbufs = 5;
	~loopdur = 4; // seconds

	"Samplematic server started".postln;

/*	SynthDef(\bufrd, {
		| buf, filterfreq=440, t_trig=1, startpos=0, endloop=1, rate=1, phase=0, amp=0.3, loop=1, pan=0, out=0, attack=0.01, sustain=1, release=0.01 |
		var sig, pos, env;
		startpos = BufFrames.kr(buf) * startpos;
		endloop = BufFrames.kr(buf) * endloop;
		pos = Phasor.ar(1, rate * BufRateScale.kr(buf), startpos, endloop);
		sig = BufRd.ar(2, buf, pos, 1);
		sig = sig * EnvGen.kr(Env.linen(attack, sustain, release), t_trig, doneAction:2);
		sig = Pan2.ar(sig, pan);
		sig = sig * amp;
		Out.ar(out, sig);
		}).add;*/
/*	SynthDef(\playbuf, { |out=0, amp=0.5, pan=0, buf, rate=1, t_trig=1, start=0, attack=0.01, sustain=1, release=0.01|
	var sig, end, startpos, isForward, frames;
	isForward = (rate < 0);
	frames = BufFrames.kr(buf);
	startpos = abs( (frames * isForward) - (frames * start) ) - (2 * isForward);
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, 1, startpos);
	sig = sig * EnvGen.kr(Env.linen(attack, sustain, release), t_trig, doneAction:2);
	sig = Pan2.ar(sig, pan);
	sig = sig * amp;
	Out.ar(out, sig);
}).add;*/

	~bufs = ();
	~bufs = Loopier.loadSampleFiles("/Users/roger/Dropbox/++PROJECTS/LOOPIER/code/SAMPLEMATIC/samples/1");

	~players = ();
	~bufs.size.do({|i|
		~players.put(i, Ndef(\players++i, {|rate=1, startpos=0, endloop=1, t_reset=0, filterfreq=440|
			var sig, pos, env, buf;
			buf = ~bufs[i];
			startpos = BufFrames.kr(buf) * startpos;
			endloop = BufFrames.kr(buf) * endloop;
			pos = Phasor.ar(t_reset, rate * BufRateScale.kr(buf), startpos, endloop);
			sig = BufRd.ar(2, buf, pos, 1);
			// sig = BPF.ar(sig, filterfreq, 1);
		}));
	});
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

~players.do({|player|
	var filterCtl, startposCtl, endloopCtl, rateCtl, phaseCtl, ampCtl;
	var startBtn, resetBtn;

	startBtn = Button(w, 90@90);
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
	// TODO: ha d'anar a través d'un proxy que el silenciï, si no, va fent fins que acaba aquest event
			player.stop;
		}
	};

	resetBtn = Button(w, 20@20);
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

	w.view.decorator.nextLine;
});

w.view.onClose_({
	s.freeAll;
});
)