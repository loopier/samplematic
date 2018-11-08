(
w = Window.new("Samplematic").front;
w.bounds = Rect(w.bounds.left, w.bounds.top, 800, (~numplayers + 1) * 100);
w.view.decorator = FlowLayout(w.view.bounds);
w.view.decorator.gap=2@2;

~btnbounds = 45@90;
~knobbounds = 60@90;
~menubounds = 200@22;

w.view.decorator.nextLine;

// Player controls
~players.size.do {
	arg i;
	var playCtl, resetCtl, rateCtl, phaseCtl, startposCtl, ampCtl,
	samplesMenu;

	playCtl =	Button(w, ~btnbounds)
	.states_( [
		["Play", Color.white, Color.green(0.27)],
		["Stop", Color.white, Color.red(0.7)],
	])
	.action_({ arg view; ~playplayer.value(i, view.value); })
	.valueAction_(1);

	resetCtl =	Button(w, ~btnbounds)
	.states_( [
		["Reset", Color.white, Color.gray(0.27)],
	])
	.action_({ ~resetplayer.value(i); });

	rateCtl =	EZKnob(w, ~knobbounds,
		"Rate",
		ControlSpec(-2.0, 2.0, default:1),
		{ arg ez; ~playerrate.value(i, ez.value) }
	);

	phaseCtl =	EZKnob(w, ~knobbounds,
		"Phase",
		ControlSpec(-1.0, 1.0, default:0),
		{ arg ez; ~playerphase.value(i, ez.value) }
	);

	startposCtl =	EZKnob(w, ~knobbounds,
		"Start",
		ControlSpec(0.0, 1.0, default:0),
		{ arg ez; ~playerstartpos.value(i, ez.value) }
	);

	ampCtl =	EZKnob(w, ~knobbounds,
		"Vol",
		\amp,
		{ arg ez; ~playeramp.value(i, ez.value) }
	).valueAction_(0.25);

	samplesMenu = EZPopUpMenu.new(w, ~menubounds, "Samples: ");
	~bufs.do({|buf|
		// buf.postln;
		samplesMenu.addItem(
			PathName(buf.path).fileName.asSymbol, {
				arg ez; ~playerbuf.value(i, buf);
		});
	});
	samplesMenu.valueAction = i;

	w.view.decorator.nextLine;
};

// General controls
~syncBtn=	Button(w, ~btnbounds)
	.states_( [
		["Sync", Color.white, Color.gray(0.27)],
	])
	.action_({ ~syncAll.value; });

~volumeCtl =	EZKnob(w, ~knobbounds,
	"Volume",
	\amp,
	{ |ez| ~mastervolume.value(ez.value)}
).valueAction_(0.3);

~loopdurCtl =	EZKnob(w, ~knobbounds,
	"LoopDur",
	ControlSpec(0.01, 4.0),
	{ |ez| ~loopdur.value(ez.value) }
).valueAction_(4);

w.view.onClose_({
	s.freeAll;
});
)