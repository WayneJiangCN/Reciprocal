compile:
	vcs -R -full64 +v2k -sverilog -debug_acc+all \
		-fsdb \
		+notimingcheck +nospecify \
		+define+FSDB \
		-timescale=1ns/100ps \
		-f filelist.f\
		-o sim \
		-l sim.log
verdi:
	verdi -f filelist.f -ssf fma_64.fsdb &
