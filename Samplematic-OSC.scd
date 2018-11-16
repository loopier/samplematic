(
~oscreceive = NetAddr.localAddr;
~oscsend = NetAddr.localAddr;
~oscmsgaddr = "/samplematic";
~notes = Array.newClear(128);
~osc.free; // make sure there's only one instance of OSCFunc
~osc= OSCFunc( {
	arg msg, time, addr, port;
	var action = msg[1];
	var track = msg[2].asInt;
	var value = msg[3];
	("msg: "+msg).postln;
	switch ( action,
		"play", ~playloop.value(track),
		"stop", ~stoploop.value(track),
		"reset", ~resetloop.value(track),
		"rand", ~looprand.value(track),
		"buf", ~loopbuf.value(track, value),
		"dur", ~loopdur.value(track, value),
		"start", ~loopstart.value(track, value),
		"rate", ~looprate.value(track, value),
		"loop", ~looploop.value(track, value),
		"legato", ~looplegato.value(track, value),
		"attack", ~loopattack.value(track, value),
		"sustain", ~loopsustain.value(track, value),
		"release", ~looprelease.value(track, value),
		"amp", ~loopamp.value(track, value),
		"pan", ~looppan.value(track, value),
		"out", ~loopout.value(track, value),

		"randomall", ~randomall.value,
		"playall", ~playall.value,
		"stopall", ~stopall.value,
		"resetall", ~resetall.value,

		"init", ~init.value
	);
	},
	~oscmsgaddr, ~oscreceive);


)

~oscsend.sendMsg(~oscmsgaddr, "init")
~oscsend.sendMsg(~oscmsgaddr, "randomall")
~oscsend.sendMsg(~oscmsgaddr, "stopall")
~oscsend.sendMsg(~oscmsgaddr, "playall")
~oscsend.sendMsg(~oscmsgaddr, "resetall")

~oscsend.sendMsg(~oscmsgaddr, "play", 0)
~oscsend.sendMsg(~oscmsgaddr, "stop", 0)
~oscsend.sendMsg(~oscmsgaddr, "reset", 0)
~oscsend.sendMsg(~oscmsgaddr, "rand", 0)
~oscsend.sendMsg(~oscmsgaddr, "buf", 0, 3.rand)
~oscsend.sendMsg(~oscmsgaddr, "dur", 0, 3.0.rand)
~oscsend.sendMsg(~oscmsgaddr, "start", 0, 1.0.rand)
~oscsend.sendMsg(~oscmsgaddr, "rate", 0, 2.0.rand2)
~oscsend.sendMsg(~oscmsgaddr, "loop", 0, 1)
~oscsend.sendMsg(~oscmsgaddr, "attack", 0, 1.0.rand)
~oscsend.sendMsg(~oscmsgaddr, "sustain", 0, 1.0.rand)
~oscsend.sendMsg(~oscmsgaddr, "release", 0, 1.0.rand)
~oscsend.sendMsg(~oscmsgaddr, "amp", 0, 0.5.rand)
~oscsend.sendMsg(~oscmsgaddr, "pan", 0, 1.0.rand2)
