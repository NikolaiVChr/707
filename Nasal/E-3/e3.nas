var radar_fc = compat_failure_modes.set_unserviceable("instrumentation/radar");
FailureMgr.add_failure_mode("instrumentation/radar", "Radar", radar_fc);

var rwr_fc = compat_failure_modes.set_unserviceable("instrumentation/rwr");
FailureMgr.add_failure_mode("instrumentation/rwr", "RWR", rwr_fc);