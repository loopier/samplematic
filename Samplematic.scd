// TODO: !!! Add banks of samples

(
s.waitForBoot({
	~numbufs = 4;

	"Samplematic server started".postln;

	~sync = Ndef(\sync, {|loopdur=4| Impulse.kr(TempoClock.default.tempo / loopdur)});

	~bufs = ();
	~bufs = Loopier.loadSamplesArray("/Users/roger/Dropbox/++PROJECTS/LOOPIER/code/SAMPLEMATIC/samples");
	// ~bufs = Loopier.loadSampleDirectories("/Users/roger/Dropbox/++PROJECTS/LOOPIER/code/SAMPLEMATIC/samples");
	// "bufs: "++~bufs.size.postln;
	~players = ();
	~numbufs.do({|i|
		~players.put(i, Ndef(\players++i, {|buf, rate=1, startpos=0, endloop=1, phase=0, t_reset=0, filterfreq=440, sync=0|
			var sig, pos, env;
			t_reset = Select.kr(sync, [t_reset, ~sync.kr]);
			startpos = BufFrames.kr(buf) * startpos;
			endloop = BufFrames.kr(buf) * endloop;
			pos = Phasor.ar(t_reset, rate * BufRateScale.kr(buf), startpos, endloop);
			sig = BufRd.ar(2, buf, pos, 1);
			// sig = BPF.ar(sig, filterfreq, 1);
			sig = sig * \amp.kr;
		}));
		// ~players[i].set(\buf, ~bufs[i.asString][0]); // SAMPLE BANKS
		~players[i].set(\buf, ~bufs[i]); // SAMPLES ARRAY
	});
	// "players: "++~players.size.postln;
});

~play = {|player| player.play};
~stop = {|player| player.stop};
~resetPlayer = {|player| player.set(\t_reset, 1)};
~setPlayerSync = {|player, value| player.set(\sync, value)};
~setPlayerFilterfreq = {|player, value| player.set(\filterfreq, value)};
~setPlayerRate = {|player, value| player.set(\rate, value)};
~setPlayerPhase = {|player, value| player.quant(4, value)};
~setPlayerStartpos = {|player, value| player.set(\startpos, value)};
~setPlayerEndloop = {|player, value| player.set(\endloop, value)};
~setPlayerAmp = {|player, value| player.set(\amp, value)};
~setPlayerBuf = {|player, buf| player.set(\buf, buf)};

~setMasterVolume = {|value| ~players.do({|player| ~setPlayerAmp.value(player, value)})};
~setMasterRate = {|value| ~players.do({|player| ~setPlayerRate.value(player, value)})};
~setMasterLoopDur = {|value| ~sync.set(\loopdur, value)};
~resetAll = { ~players.do({|player| ~resetPlayer.value(player) })};
~setBpm = {|value| TempoClock.default.tempo =  value/60};

)


(
var metrogui = true;

// GUI
w = Window.new("Samplematic").front;
w.bounds = Rect(w.bounds.left, w.bounds.top, 800, (~players.size + 1) * 100);
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
			~play.value(player);
		} {
			"stop".postln;
			~stop.value(player);
		}
	};

	syncBtn = Button(w, 45@90);
	syncBtn.states = [
		["Free", Color.white, Color.yellow(0.4)],
		["Sync", Color.white, Color.yellow(0.7)],
	];
	syncBtn.action = {|view|
		~setPlayerSync.value(player, view.value);
		"sync: "++view.value.postln;
	};
	syncBtn.valueAction = 1;

	resetBtn = Button(w, 45@90);
	resetBtn.states = [
	["Reset", Color.black, Color.gray]
	];
	resetBtn.action = {|view|
		~resetPlayer.value(player);
	};

	filterCtl = EZKnob(w, 60@90, "filter", \freq, {|ez|
		~setPlayerFilterfreq.value(player, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln;
	});

	startposCtl = EZKnob(w, 60@90, "start", \startpos, {|ez|
		~setPlayerStartpos.value(player, ez.value);
		if (ez.value > endloopCtl.value) {
			endloopCtl.value = ez.value + 0.01;
			};
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
		});

	endloopCtl = EZKnob(w, 60@90, "end", \endloop, {|ez|
		~setPlayerEndloop.value(player, ez.value);
		if (ez.value < startposCtl.value) {
			startposCtl.value = ez.value - 0.01;
			};
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
		});

	rateCtl = EZKnob(w, 60@90, "rate", \rate, {|ez|
		~setPlayerRate.value(player, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln;
		});

	phaseCtl = EZKnob(w, 60@90, "phase", \phase, {|ez|
		~setPlayerPhase.value(player, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
		});

	ampCtl = EZKnob(w, 60@90, "amp", \amp, {|ez|
		~setPlayerAmp.value(player, ez.value);
		(ez.label ++ "-" ++ i ++ ": " ++ez.value.asString).postln
		});

	samplesMenu = EZPopUpMenu.new(w, 200@22, "Samples: ");
	~bufs.do({|buf|
		// buf.postln;
		samplesMenu.addItem(PathName(buf.path).fileName, {~setPlayerBuf.value(player,buf)});
	});
	samplesMenu.valueAction = index;
	// use with SAMPLESBANKS
	// ~bufs[index.asString].do({|buf|
	// 	buf.postln;
	// 	samplesMenu.addItem(PathName(buf.path).fileName.postln, {~setPlayerBuf.value(player,buf)});
	// });
		// samplesMenu.addItem(~

	w.view.decorator.nextLine;
});

// General GUI
~syncBtn = Button(w, 90@90)
.states_([["Panic", Color.white, Color.red(0.7)],["Panic", Color.white, Color.gray(0.7)]])
.action_({|view| ~resetAll.value });
EZKnob(w, 60@90, "Volume", \amp, {|ez| ~setMasterVolume.value(ez.value)});
EZKnob(w, 60@90, "Rate", \rate, {|ez| ~setMasterRate.value(ez.value)});
EZKnob(w, 60@90, "LoopDur", ControlSpec(0.25, 8, 'linear', 0.25, 4, ""), {|ez| ~setMasterLoopDur.value(ez.value)});
EZKnob(w, 60@90, "BPM", ControlSpec(1,400, step:1, default:60), {|ez| ~setBpm.value(ez.value)});

// Metronome
~metroText =	EZText(w, 45@90, textWidth:60).setColors(Color.gray, Color.white, Color.gray, Color.black)
.font_(Font(size:45, bold:true))
.enabled_(false);

{
	while { w.isClosed.not } {
		~metroText.textField.value = (TempoClock.default.beatInBar.asInt+1).asString;
		TempoClock.default.beatInBar.postln;
		(TempoClock.default.beatDur/4).wait;
	}
}.fork(AppClock);

w.view.onClose_({
	s.freeAll;
});
)