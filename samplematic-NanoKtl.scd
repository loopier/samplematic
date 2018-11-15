"Samplematic.scd".loadRelative;
~init.value;
(
MIDIClient.init;
MIDIIn.connectAll;

m.free;
m = MIDIFunc.cc( { arg val, ccnumber, channel, sourceid;
	[val, ccnumber, channel, sourceid].postln;
	switch (ccnumber)
	{23} {~playloop.value(0,1);}
	{33} {~stoploop.value(0);}
	{24} {~resetloop.value(0,1);}
	{14} {~loopbuf.value(0, val.linlin(0,127, 0, ~bufs.size-1).floor.asInt);}
	{3} {~loopamp.value(0,val.linlin(0,127, 0.0, 1.0));}
	{2} {~looprate.value(0,val.linlin(0,127, -2.0, 2.0));}
	{15} {~looplegato.value(0,val.linlin(0,127, 0.0, 1.0));}
	{16} {~loopstart.value(0,val.linlin(0,127, 0.0, 1.0));}
	{4} {~loopdur.value(0,val.linlin(0,127, 0.0, 4.0));}

	{26} {~playloop.value(1,1);}
	{36} {~stoploop.value(1);}
	{27} {~resetloop.value(1,1);}
	{17} {~loopbuf.value(1, val.linlin(0,127, 0, ~bufs.size-1).floor.asInt);}
	{6} {~loopamp.value(1,val.linlin(0,127, 0.0, 1.0));}
	{5} {~looprate.value(1,val.linlin(0,127, -2.0, 2.0));}
	{18} {~looplegato.value(1,val.linlin(0,127, 0.0, 1.0));}
	{19} {~loopstart.value(1,val.linlin(0,127, 0.0, 1.0));}
	{8} {~loopdur.value(1,val.linlin(1,127, 0.0, 4.0));}

	{29} {~playloop.value(2,1);}
	{39} {~stoploop.value(2);}
	{30} {~resetloop.value(2,1);}
	{20} {~loopbuf.value(2, val.linlin(0,127, 0, ~bufs.size-1).floor.asInt);}
	{12} {~loopamp.value(2,val.linlin(0,127, 0.0, 1.0));}
	{9} {~looprate.value(2,val.linlin(0,127, -2.0, 2.0));}
	{21} {~looplegato.value(2,val.linlin(0,127, 0.0, 1.0));}
	{22} {~loopstart.value(2,val.linlin(0,127, 0.0, 1.0));}
	{13} {~loopdur.value(2,val.linlin(1,127, 0.0, 4.0));}

	{44} {~syncAll.value;}
	{45} {"Samplematic.scd".loadRelative;}
	{46} {s.freeAll;}
	{49} {s.quit; "Samplematic.scd".loadRelative;}
});
)