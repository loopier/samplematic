(
s.waitForBoot({
	~numbufs = 5;

	"".postln;
	"Samplematic server started".postln;

	~bufs = ();
	// ~numbufs.do({|i| ~bufs.put(i,Buffer.alloc(s, s.sampleRate * 4))});
	~bufs = Loopier.loadSampleFiles("/Users/roger/Dropbox/++PROJECTS/LOOPIER/code/SAMPLEMATIC/samples/1");
	~players = ();
	~bufs.size.do({|i| ~players.put(i, {Synth(\playbufm, ~bufs[i])})});
	~players;
// });

	SynthDef(\playbuf, {| buf, filterfreq=440, startpos=0, endloop=1, rate=1, trig=1, phase=0, amp=0.2, loop=1, out=0, pan=0 |
		var sig;
		startpos = BufFrames.kr(buf) * startpos;
		endloop = BufFrames.kr(buf) * endloop;
		/*sig = PlayBuf.ar(
			numChannels: 2,
			bufnum: buf,
			rate: rate,
			trigger: Impulse.kr(loopdur),
			startPos: (BufFrames.kr(buf) * startpos).poll,
			loop: loop,
			doneAction: 2);*/
		sig = LoopBuf.ar(numChannels:2, bufnum:buf, rate:rate, gate:trig, startPos:startpos, startLoop:startpos, endLoop:endloop);
		Out.ar(out, Pan2.ar(sig * amp));
	}).add;
})
)

(
w = Window.new("Samplematic").front;
w.bounds = Rect(w.bounds.left, w.bounds.top, 500, ~bufs.size * 100);
w.view.decorator = FlowLayout(w.view.bounds);
w.view.decorator.gap=2@2;

// ControlSpec.specs[\slice] = ControlSpec(-4, 4, \lin, 1, 0, "secs");
ControlSpec.specs[\rate] = ControlSpec(-4, 4, 'lin', 0.25, 1, ""); // overrides default \rate.asSpec
ControlSpec.specs[\endloop] = ControlSpec(0.01, 1, \lin, 0, 1, ""); // loop duration (normalized)
ControlSpec.specs[\startpos] = ControlSpec(0, 0.99, \lin, 0, 0, ""); // start loop at this position (normalized)
ControlSpec.specs[\amp] = ControlSpec(0, 1, 'linear', 0, 0.2, "");

~players.size.do({|i|
	var filterCtl, startposCtl, endloopCtl, rateCtl, phaseCtl, ampCtl;
	var startBtn;
	var node; // synth

	startBtn = Button(w, 90@90);
	startBtn.states = [
		["Play", Color.white, Color.green(0.27)],
		["Stop", Color.white, Color.red(0.7)],
	];
	startBtn.action = {|view|
		if (view.value == 1) {
			"index "++i.value.postln;
			~bufs[i].postln;
			node = Synth(\playbuf, [
				buf: ~bufs[i],
				filterfreq: filterCtl.value,
				startpos: startposCtl.value,
				endloop: endloopCtl.value,
				// trig:1,
				// loop:1,
				rate: rateCtl.value,
				phase: phaseCtl.value,
				amp: ampCtl.value
			]);
		} {
			// node.set(\loop, 0);
			// node.set(\trig, 0);
			// node.release;
			node.free;
		};
		"".postln;
	};
	filterCtl = EZKnob(w, 60@90, "filter", \freq, {|ez| (ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln});
	startposCtl = EZKnob(w, 60@90, "start", \startpos, {|ez|
		node.set(\startpos, ez.value);
		if (ez.value > endloopCtl.value) {
			endloopCtl.value = ez.value + 0.01;
		};
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln});
	endloopCtl = EZKnob(w, 60@90, "end", \endloop, {|ez|
		node.set(\endloop, ez.value);
		if (ez.value < startposCtl.value) {
			startposCtl.value = ez.value - 0.01;
		};
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln});
	rateCtl = EZKnob(w, 60@90, "rate", \rate, {|ez|
		node.set(\rate, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln;});
	phaseCtl = EZKnob(w, 60@90, "phase", \phase, {|ez|
		node.set(\phase, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln});
	ampCtl = EZKnob(w, 60@90, "amp", \amp, {|ez|
		node.set(\amp, ez.value);
		 (ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln});
	w.view.decorator.nextLine;
	// g.setColors(Color.gray, Color.white);
});
)