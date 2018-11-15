(
SynthDef(\playbuf, { |out=0, amp=0.5, pan=0, buf, rate=1, t_trig=1, dur=1, legato=1, start=0, loop=0, attack=0.01, sustain=1, release=0.01, doneAction=2|
	var sig, end, startpos, isForward, frames;
	isForward = (rate < 0);
	frames = BufFrames.kr(buf);
	startpos = abs( (frames * isForward) - (frames * start) ) - (2 * isForward);
	sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf) * rate, 1, startpos, loop);
	sig = sig * EnvGen.kr(Env.new([0,sustain,sustain,0],[attack, dur * legato, release]), t_trig, doneAction:doneAction);
	sig = Mix.ar(sig) * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(out, sig);
}).add;
)

