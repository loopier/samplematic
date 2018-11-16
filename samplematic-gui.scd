(
w = Window.new("Samplematic").front;
w.bounds = Rect(w.bounds.left, w.bounds.top, 1024, (~numtracks + 1) * 100);
w.view.decorator = FlowLayout(w.view.bounds);
w.view.decorator.gap=2@2;


~btnbounds = 45@90;
~knobbounds = 60@90;
~menubounds = 300@22;

~loopCtls = List.new;

w.view.decorator.nextLine;

// loop controls
~loops.size.do {
	arg i;
	var playCtl, loopCtl, resetCtl, rateCtl, legatoCtl, phaseCtl, startposCtl, ampCtl, panCtl, durCtl, samplesMenu, randCtl;
	var ctlDict;

	playCtl =	Button(w, ~btnbounds)
	.states_( [
		["Play", Color.white, Color.green(0.27)],
		["Stop", Color.white, Color.red(0.7)],
	])
	.action_({ arg view;
		if (view.value == 1) {
			~playloop.value(i);
		} {
			~stoploop.value(i);
		};
	})
	.valueAction_(0);

/*	loopCtl =	Button(w, ~btnbounds)
	.states_( [
		["Loop\nOff", Color.white, Color.red(0.7)],
		["Loop\nOn", Color.white, Color.green(0.27)],
	])
	.action_({ arg view;
		~looploop.value(view.value);
		view.value.postln;
	});*/

	resetCtl =	Button(w, ~btnbounds)
	.states_( [
		["Reset", Color.white, Color.gray(0.27)],
	])
	.action_({
		~resetloop.value(i);
		~updategui.value;
	});

	rateCtl =	EZKnob(w, ~knobbounds,
		"Rate",
		ControlSpec(-2.0, 2.0, default:1),
		{ arg ez; ~looprate.value(i, ez.value) }
	);

/*	phaseCtl =	EZKnob(w, ~knobbounds,
		"Phase",
		ControlSpec(-1.0, 1.0, default:0),
		{ arg ez; ~loopphase.value(i, ez.value) }
	);*/

	startposCtl =	EZKnob(w, ~knobbounds,
		"Start",
		ControlSpec(0.0, 1.0, default:0),
		{ arg ez; ~loopstart.value(i, ez.value) }
	);

	durCtl =	EZKnob(w, ~knobbounds,
		"Dur",
		ControlSpec(0.01, 4.0),
		{ arg ez; ~loopdur.value(i, ez.value) }
	).valueAction_(2);

	legatoCtl =	EZKnob(w, ~knobbounds,
		"Legato",
		ControlSpec(0.01, 2, default:1),
		{ arg ez; ~looplegato.value(i, ez.value) }
	).valueAction_(1);

	panCtl =	EZKnob(w, ~knobbounds,
		"Balance",
		ControlSpec(-1.0, 1.0, default:1),
		{ arg ez; ~looppan.value(i, ez.value) }
	);

	ampCtl =	EZKnob(w, ~knobbounds,
		"Vol",
		\amp,
		{ arg ez; ~loopamp.value(i, ez.value) }
	).valueAction_(0.3);

	samplesMenu = EZPopUpMenu.new(w, ~menubounds, "Samples: ");
	~bufs[i].do { arg buf, n;
		samplesMenu.addItem(
			(n +":"+PathName(buf.path).fileName),
			{ arg ez; ~loopbuf.value(i, ez.value); ez.value.postln; }
		);
	};
	// samplesMenu.valueAction = 4;

	randCtl =	Button(w, ~btnbounds)
	.states_( [
		["Rand", Color.white, Color.gray(0.27)],
	])
	.action_({
		~looprand.value(i);
		~updategui.value;
	});

	ctlDict = Dictionary.new;
	ctlDict.put(\play, playCtl);
	// ctlDict.put(\reset, resetCtl);
	ctlDict.put(\rate, rateCtl);
	// ctlDict.put(\phase, phaseCtl);
	ctlDict.put(\start, startposCtl);
	ctlDict.put(\amp, ampCtl);
	ctlDict.put(\dur, durCtl);
	ctlDict.put(\legato, legatoCtl);
	ctlDict.put(\pan, panCtl);
	ctlDict.put(\buf, samplesMenu);
	~loopCtls.add(ctlDict);

	w.view.decorator.nextLine;
};

// General controls
/*
~syncBtn=	Button(w, ~btnbounds)
.states_( [
	["Sync", Color.white, Color.gray(0.27)],
])
.action_({ ~syncall.value; });

~autoplayBtn=	Button(w, ~btnbounds)
.states_( [
	["Auto\nOn", Color.white, Color.green(0.27)],
	["Auto\nOff", Color.white, Color.red(0.7)],
])
.action_({ arg e;
	if (e.value.asBoolean )
	{ ~autoplay.value }
	{ ~autoplaystop.value };
});

~volumeCtl =	EZKnob(w, ~knobbounds,
	"Volume",
	\amp,
	{ |ez| ~mastervolume.value(ez.value)}
).valueAction_(0.3);

~loopdurCtl =	EZKnob(w, ~knobbounds,
	"LoopDur",
	ControlSpec(0.01, 1.0),
	{ |ez| ~loopdur.value(ez.value) }
);
*/
~startBtn=	Button(w, ~btnbounds)
.states_( [
	["Start", Color.white, Color.green(0.27)],
	["Stop", Color.white, Color.red(0.7)],
])
.action_({ arg ez;
	if (ez.value == 1 )
	{
		~playall.value;
		// update the GUI manually
		~loops.size.do { arg i;
			~loopCtls[i][\play].value = 1;
		};
	}{
		~stopall.value;
		// update the GUI manually
		~loops.size.do { arg i;
			~loopCtls[i][\play].value = 0;
		};
	};
});

~randBtn =	Button(w, ~btnbounds)
.states_( [
	["Rand", Color.white, Color.gray(0.27)],
])
.action_({
	~randomall.value;
	~updategui.value;
});

~resetallBtn =	Button(w, ~btnbounds)
.states_( [
	["Reset", Color.white, Color.gray(0.27)],
])
.action_({
	~resetall.value;
	~updategui.value;
});

~updategui = {
	~loops.do {
		arg loop, i;
		("Gui: "+i).postln;
		loop.postln;
		~loopCtls[i][\rate].value = loop.at(\rate).asFloat;
		// ~loopCtls[i][\phase].value = loop.at(\phase).asFloat;
		~loopCtls[i][\start].value = loop.at(\start).asFloat;
		~loopCtls[i][\amp].value = loop.at(\amp).asFloat;
		~loopCtls[i][\pan].value = loop.at(\pan).asFloat;
		~loopCtls[i][\dur].value = loop.at(\dur).asFloat;
		~loopCtls[i][\legato].value = loop.at(\legato).asFloat;
		~loopCtls[i][\buf].value = ~getbufindex.value(i, loop.at(\buf));
	};
};

// get the sample file index in the folder to update the GUI
~getbufindex = { arg track, buf;
	var index = -1;
	var bufs = ~bufs[track];
	bufs.do {
		arg bufinarray, i;
		if (buf == bufinarray) {
			buf.postln;
			bufinarray.postln;
			i.postln;
			index = i;
		}
	};
	index;
};
)

// w.view.onClose_({
// 	// s.freeAll;
// });
