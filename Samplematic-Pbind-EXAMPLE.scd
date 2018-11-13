
// boot samplematic
"Samplematic-Pbind.scd".loadRelative;

// initialize with samples in a folder named "samples" in the same directory as this file
~init.value; // default 3 tracks
~init.value(4); // 4 tracks
~init.value(1); // 1 track

// initialize with a custom path to the samples directory -- e.g. "~/samples/" in the home directory
// ~init.value(path:"~/samples/");

// initialize with a custom number of players (tracks) -- defaults to 4
// ~init.value(players: 3);

// initialize both, the path to the samples folder and the number of players (tracks)
// ~init.value(path:"~/samples/", players: 3);

// initialize with a dialog asking for a folder
// FileDialog.new( { |path| ~init.value(path[0]++"/") }, fileMode: 2);

// use the GUI
"samplematic-gui.scd".loadRelative;
// use KORG's Nano-Kontrol
"samplematic-NanoKtl.scd".loadRelative;

// change the number of samples to play in sequence
~loopsize.value(0, 8);
// choose the samples to play (index of folder)
~loopbuf.value(0, 1);
~loopbuf.value(1, 3.rand);
~loopbuf.value(2, 3.rand);
// change playback parameters
~loopdur.value(0, 0.15);
~loopdur.value(1, 0.125);
~loopdur.value(2, 0.125);
~looprate.value(0, 2);
~looplegato.value(0, 0.5);
~loopstart.value(0, 0.5);
~loopphase.value(0, 0.5);
// play and stop -- It's not immediate, it waits until next iteration of the loop
~loopplay.value(0);
~loopstop.value(0);

~bufs[1]
