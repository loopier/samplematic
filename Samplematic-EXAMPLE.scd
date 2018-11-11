(
// boot samplematic
"Samplematic.scd".loadRelative;
~init.value(serverGui:true);
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