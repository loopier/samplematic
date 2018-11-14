(
s.plotTree; // node tree (Synth order)
s.meter; // VU meter

w = Window.new("Samplematic").front;
w.bounds = Rect(w.bounds.left, w.bounds.top, 800, (~numtracks + 1) * 100);
w.view.decorator = FlowLayout(w.view.bounds);
w.view.decorator.gap=2@2;


~btnbounds = 45@90;
~knobbounds = 60@90;
~menubounds = 300@22;

~trackCtls = List.new;

w.view.decorator.nextLine;

// Player controls
~numtracks.do {
	arg i;
	var playCtl, resetCtl, rateCtl, phaseCtl, startposCtl, ampCtl, durCtl, samplesMenu, randCtl;
	var ctlDict;

	playCtl =	Button(w, ~btnbounds)
	.states_( [
		["Play", Color.white, Color.green(0.27)],
		["Stop", Color.white, Color.red(0.7)],
	])
	.action_({ arg view;
		if (view.value == 1)
		{ ~loopplay.value(i); }
		{ ~loopstop.value(i); }
	})
	.valueAction_(1);

	// resetCtl =	Button(w, ~btnbounds)
	// .states_( [
	// 	["Reset", Color.white, Color.gray(0.27)],
	// ])
	// .action_({ ~resetplayer.value(i); });

	rateCtl =	EZKnob(w, ~knobbounds,
		"Rate",
		ControlSpec(-2.0, 2.0, default:1),
		{ arg ez; ~looprate.value(i, ez.value) }
	);

	phaseCtl =	EZKnob(w, ~knobbounds,
		"Phase",
		ControlSpec(-1.0, 1.0, default:0),
		{ arg ez; ~loopphase.value(i, ez.value) }
	);

	startposCtl =	EZKnob(w, ~knobbounds,
		"Start",
		ControlSpec(0.0, 1.0, default:0),
		{ arg ez; ~loopstart.value(i, ez.value) }
	);

	durCtl =	EZKnob(w, ~knobbounds,
		"Dur",
		ControlSpec(0.01, 1.0),
		{ arg ez; ~loopdur.value(i, ez.value) }
	).valueAction_(1);

/*	ampCtl =	EZKnob(w, ~knobbounds,
		"Vol",
		\amp,
		{ arg ez; ~playeramp.value(i, ez.value) }
	).valueAction_(1);*/

	samplesMenu = EZPopUpMenu.new(w, ~menubounds, "Samples: ");
	~bufs[i].size.do({|n|
		samplesMenu.addItem(
			PathName(~bufs[i][n].path).fileName.asSymbol, {
				arg ez; ~loopbuf.value(i, n);
		});
	});
	// samplesMenu.valueAction = ~bufs[i].size.rand;

	randCtl =	Button(w, ~btnbounds)
	.states_( [
		["Rand", Color.white, Color.gray(0.27)],
	])
	.action_({
		~randomizeplayer.value(i);
		~updategui.value;
	});

	ctlDict = Dictionary.new;
	ctlDict.put(\play, playCtl);
	ctlDict.put(\reset, resetCtl);
	ctlDict.put(\rate, rateCtl);
	ctlDict.put(\phase, phaseCtl);
	ctlDict.put(\start, startposCtl);
	ctlDict.put(\amp, ampCtl);
	ctlDict.put(\dur, durCtl);
	ctlDict.put(\buf, samplesMenu);
	~trackCtls.add(ctlDict);

	w.view.decorator.nextLine;
};

// General controls
/*~syncBtn=	Button(w, ~btnbounds)
.states_( [
	["Sync", Color.white, Color.gray(0.27)],
])
.action_({ ~syncall.value; });*/

// ~autoplayBtn=	Button(w, ~btnbounds)
// .states_( [
// 	["Auto\nOn", Color.white, Color.green(0.27)],
// 	["Auto\nOff", Color.white, Color.red(0.7)],
// ])
// .action_({ arg e;
// 	if (e.value.asBoolean )
// 	{ ~autoplay.value }
// 	{ ~autoplaystop.value };
// });

/*~volumeCtl =	EZKnob(w, ~knobbounds,
	"Volume",
	\amp,
	{ |ez| ~mastervolume.value(ez.value)}
).valueAction_(0.3);*/

// ~loopdurCtl =	EZKnob(w, ~knobbounds,
// 	"LoopDur",
// 	ControlSpec(0.01, 1.0),
// 	{ |ez| ~loopdur.value(ez.value) }
// );

/*~playBtn=	Button(w, ~btnbounds)
.states_( [
	["Play", Color.white, Color.green(0.27)],
	["Stop", Color.white, Color.red(0.7)],
])
.action_({ arg e;
	if (e.value.asBoolean )
	{}
	{ ~stopall.value };
})
.valueAction_(1);*/

// ~randBtn =	Button(w, ~btnbounds)
// .states_( [
// 	["Rand", Color.white, Color.gray(0.27)],
// ])
// .action_({
// 	~randomizeall.value;
// 	~updategui.value
// });

// ~resetallBtn =	Button(w, ~btnbounds)
// .states_( [
// 	["Reset", Color.white, Color.gray(0.27)],
// ])
// .action_({
// 	~resetall.value;
// 	~updategui.value;
// });

~updategui = {
	~currentstate.do {
		arg player, i;
		~trackCtls[i][\rate].value = player.at(\rate).asFloat;
		~trackCtls[i][\phase].value = player.at(\phase).asFloat;
		~trackCtls[i][\start].value = player.at(\phase).asFloat;
		~trackCtls[i][\amp].value = player.at(\amp).asFloat;
		~trackCtls[i][\dur].value = player.at(\dur).asFloat;
		~trackCtls[i][\buf].value = player.at(\buf).asInt;
	};
};
)


// w.view.onClose_({
// 	// s.freeAll;
// });