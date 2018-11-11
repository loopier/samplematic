(
"Samplematic.scd".loadRelative;
MIDIClient.init;
MIDIIn.connectAll;

m.free;
m = MIDIFunc.cc( { arg val, ccnumber, channel, sourceid;
	[val, ccnumber, channel, sourceid].postln;
	switch (ccnumber)
	{23} {~playplayer.value(0,1);}
	{33} {~stopplayer.value(0);}
	{24} {~resetplayer.value(0,1);}
	{14} {~playerbuf.value(0, val.linlin(0,127, 0, ~bufs.size-1).floor.asInt);}
	{3} {~playeramp.value(0,val.linlin(0,127, 0.0, 1.0));}
	{2} {~playerrate.value(0,val.linlin(0,127, -2.0, 2.0));}
	{15} {~playerphase.value(0,val.linlin(0,127, 0.0, 1.0));}
	{16} {~playerstartpos.value(0,val.linlin(0,127, 0.0, 1.0));}
	{4} {~playerdur.value(0,val.linlin(0,127, 0.0, 1.0));}

	{26} {~playplayer.value(1,1);}
	{36} {~stopplayer.value(1);}
	{27} {~resetplayer.value(1,1);}
	{17} {~playerbuf.value(1, val.linlin(0,127, 0, ~bufs.size-1).floor.asInt);}
	{6} {~playeramp.value(1,val.linlin(0,127, 0.0, 1.0));}
	{5} {~playerrate.value(1,val.linlin(0,127, -2.0, 2.0));}
	{18} {~playerphase.value(1,val.linlin(0,127, 0.0, 1.0));}
	{19} {~playerstartpos.value(1,val.linlin(0,127, 0.0, 1.0));}
	{8} {~playerdur.value(1,val.linlin(1,127, 0.0, 1.0));}

	{29} {~playplayer.value(2,1);}
	{39} {~stopplayer.value(2);}
	{30} {~resetplayer.value(2,1);}
	{20} {~playerbuf.value(2, val.linlin(0,127, 0, ~bufs.size-1).floor.asInt);}
	{12} {~playeramp.value(2,val.linlin(0,127, 0.0, 1.0));}
	{9} {~playerrate.value(2,val.linlin(0,127, -2.0, 2.0));}
	{21} {~playerphase.value(2,val.linlin(0,127, 0.0, 1.0));}
	{22} {~playerstartpos.value(2,val.linlin(0,127, 0.0, 1.0));}
	{13} {~playerdur.value(2,val.linlin(1,127, 0.0, 1.0));}

	{44} {~syncAll.value;}
	{45} {"Samplematic.scd".loadRelative;}
	{46} {s.freeAll;}
	{49} {s.quit; "Samplematic.scd".loadRelative;}
});
)