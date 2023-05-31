var radar_fc = compat_failure_modes.set_unserviceable("instrumentation/radar");
FailureMgr.add_failure_mode("instrumentation/radar", "Radar", radar_fc);

var rwr_fc = compat_failure_modes.set_unserviceable("instrumentation/rwr");
FailureMgr.add_failure_mode("instrumentation/rwr", "RWR", rwr_fc);


## FLARES
var flareCount = -1;
var flareStart = -1;

var loop_flare = func {
    # Flare/chaff release
    if (getprop("ai/submodels/submodel[0]/flare-release-snd") == nil) {
        setprop("ai/submodels/submodel[0]/flare-release-snd", 0);
        setprop("ai/submodels/submodel[0]/flare-release-out-snd", 0);
    }
    var flareOn = getprop("ai/submodels/submodel[0]/flare-release-cmd");
    var flareOnA = getprop("ai/submodels/submodel[0]/flare-auto-release-cmd") != nil and getprop("ai/submodels/submodel[0]/flare-auto-release-cmd") > rand() and getprop("instrumentation/rwr/auto-cm") and getprop("ai/submodels/submodel[0]/flare-release-cmd") == 0;
    flareOn = flareOn or flareOnA;
    if (flareOn == 1 and getprop("ai/submodels/submodel[0]/flare-release") == 0
            and getprop("ai/submodels/submodel[0]/flare-release-out-snd") == 0
            and getprop("ai/submodels/submodel[0]/flare-release-snd") == 0) {
        flareCount = getprop("ai/submodels/submodel[0]/count");
        flareStart = getprop("sim/time/elapsed-sec");
        setprop("ai/submodels/submodel[0]/flare-release-cmd", 0);
        if (flareCount > 0) {
            # release a flare
            setprop("ai/submodels/submodel[0]/flare-release-snd", 1);
            setprop("ai/submodels/submodel[0]/flare-release", 1);
            setprop("rotors/main/blade[3]/flap-deg", flareStart);
            setprop("rotors/main/blade[3]/position-deg", flareStart);
            damage.flare_released();
        } else {
            # play the sound for out of flares
            setprop("ai/submodels/submodel[0]/flare-release-out-snd", 1);
        }
    }
    if (getprop("ai/submodels/submodel[0]/flare-release-snd") == 1 and (flareStart + 1) < getprop("sim/time/elapsed-sec")) {
        setprop("ai/submodels/submodel[0]/flare-release-snd", 0);
        setprop("rotors/main/blade[3]/flap-deg", 0);
        setprop("rotors/main/blade[3]/position-deg", 0);#MP interpolates between numbers, so nil is better than 0.
    }
    if (getprop("ai/submodels/submodel[0]/flare-release-out-snd") == 1 and (flareStart + 1) < getprop("sim/time/elapsed-sec")) {
        setprop("ai/submodels/submodel[0]/flare-release-out-snd", 0);
    }
    if (flareCount > getprop("ai/submodels/submodel[0]/count")) {
        # A flare was released in last loop, we stop releasing flares, so user have to press button again to release new.
        setprop("ai/submodels/submodel[0]/flare-release", 0);
        flareCount = -1;
    }
}
var flaretimer = maketimer(0.1, loop_flare);
flaretimer.start();