// start the machine!
"Samplematic.scd".loadRelative;

// the first parameter is always the track number, the second
// parameter is usualy the value of the parameter

// stop playing
~stoplooper.value(0);
~stoplooper.value(1);
~stoplooper.value(2);
// start playing
~playlooper.value(0);
~playlooper.value(1);
~playlooper.value(2);
// choose a given sound, by index (order of file in the folder)
~looperbuf.value(0, 0);
~looperbuf.value(0, 1);
// change playing rate (1 is normal, negative numbers is backwards, 0 is stop)
~looperrate.value(0, 0.5); // half speed
~looperrate.value(0, 2); // double speed
~looperrate.value(0, -1); // backwards, normal speed
~looperrate.value(0, 2.rand2); // who knows -- if you hear nothing it might be 0, hit it again until you hear something!
~looperrate.value(0, 1); // back to normal
// if the sample gets to the end before the loop does, start over (1) or not (0)
// if you hear weird repetitions it might be the looper re-triggering the sample and the end of 'dur'
~looperloop.value(0, 1);
~looperloop.value(0, 0);
// change loop duration - time in secons until loop starts again
~looperdur.value(0, 4);
// change loop legato - how long it sounds (% of dur)
~looperlegato.value(0, 0.2); // if shorter than 'dur' you'll hear a silence
// ~looperlegato.value(0,1); // if longer than 'dur' you should hear one sound stepping over another one
// set where in the sample will the sound start (0 is beginning, 1 is the end)
~looperstart.value(0, 0.5);
// an envelope for the sample
~looperattack.value(0, 0.01);
~loopersustain.value(0, 1); // same as 'amp'
~looperrelease.value(0, 2);
// change volume
~looperamp.value(0, 0.2);
// balance between left and right (-1 is L, 1 is R, and 0 is centered)
~looperpan.value(0, -1);
~looperpan.value(0, 1);
~looperpan.value(0, 0.5);
~looperpan.value(0, 0);
// out channel ( don't worry too much about this )
~looperout.value(0, 0);
// let the machine do the thinkinig for a given track
~looperrand.value(0);

~loopers[0][\synth].set(\rate, -1)
~loopers[0][\rate] = 1