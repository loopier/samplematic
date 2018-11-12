(
// boot samplematic
"Samplematic-Pbind.scd".loadRelative;

// initialize with samples in a folder named "samples" in the same directory as this file
~init.value;

// initialize with a custom path to the samples directory -- e.g. "~/samples/" in the home directory
// ~init.value(path:"~/samples/");

// initialize with a custom number of players (tracks) -- defaults to 4
// ~init.value(players: 3);

// initialize both, the path to the samples folder and the number of players (tracks)
// ~init.value(path:"~/samples/", players: 3);

// initialize with a dialog asking for a folder
// FileDialog.new( { |path| ~init.value(path[0]++"/") }, fileMode: 2);
)
// use the GUI
"samplematic-gui.scd".loadRelative;
// use KORG's Nano-Kontrol
"samplematic-NanoKtl.scd".loadRelative;

// first parameter is the track number, the second parameter is the value
// change the number of samples to play in sequence
~loopsize.value(1, 2);
// choose the samples to play (index of folder)
~loopbuf.value(1, 3);
// change playback parameters
~loopdur.value(1, 0.25);
~looprate.value(1, 0.5);
~looplegato.value(1, 0.5);
~loopstart.value(1, 0.5);
~loopphase.value(1, 0.5);
// play and stop -- It's not immediate, it waits until next iteration of the loop
~loopplay.value(1);
~loopstop.value(1);
