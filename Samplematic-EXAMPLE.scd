(
// boot samplematic
"Samplematic.scd".loadRelative;

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

// autoplay
~autoplay.value;
// stop autoplay
~autoplaystop.value;
// or
~autoplay.value(false);
// randomize first player
~randomizeplayer.value(0);
// randomize all
~randomizeall.value;

// post first players parameteres
~postplayer.value(0);
// post all players parameters
~postall.value;
