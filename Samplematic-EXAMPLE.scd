// start the machine!
"Samplematic.scd".loadRelative;
// if you want to use the gui
"samplematic-gui.scd".loadRelative;

// the first parameter is always the track number, the second
// parameter is usualy the value of the parameter

// stop playing
~stoploop.value(0);
~stoploop.value(1);
~stoploop.value(2);
// start playing
~playloop.value(0);
~playloop.value(1);
~playloop.value(2);
// choose a given sound, by index (order of file in the folder)
~loopbuf.value(0, 0);
~loopbuf.value(0, 1);
// change playing rate (1 is normal, negative numbers is backwards, 0 is stop)
~looprate.value(0, 0.5); // half speed
~looprate.value(0, 2); // double speed
~looprate.value(0, -1); // backwards, normal speed
~looprate.value(0, 2.rand2); // who knows -- if you hear nothing it might be 0, hit it again until you hear something!
~looprate.value(0, 1); // back to normal
// if the sample gets to the end before the loop does, start over (1) or not (0)
// if you hear weird repetitions it might be the loop re-triggering the sample and the end of 'dur'
~looploop.value(0, 1);
~looploop.value(0, 0);
// change loop duration - time in secons until loop starts again
~loopdur.value(0, 0.25);
~loopdur.value(0, 2);
// change loop legato - how long it sounds (% of dur)
~looplegato.value(0, 0.2); // if shorter than 'dur' you'll hear a silence
~looplegato.value(0, 1);
// ~looplegato.value(0,1); // if longer than 'dur' you should hear one sound stepping over another one
// set where in the sample will the sound start (0 is beginning, 1 is the end)
~loopstart.value(0, 0.5);
~loopstart.value(0, 0);
~loopstart.value(0, 0.99); // won't hear anything unless loop is on
// an envelope for the sample
~loopattack.value(0, 0.7);
~loopsustain.value(0, 1); // same as 'amp'
~looprelease.value(0, 0.8);
// change volume
~loopamp.value(0, 0.2);
// balance between left and right (-1 is L, 1 is R, and 0 is centered)
~looppan.value(0, -1);
~looppan.value(0, 1);
~looppan.value(0, 0.5);
~looppan.value(0, 0);
// out channel ( don't worry too much about this )
~loopout.value(0, 0);
// let the machine do the thinkinig for a given track
~looprand.value(0);

~loops[0][\synth].set(\rate, -1)
~loops[0][\rate] = 1