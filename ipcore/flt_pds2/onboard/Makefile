

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
	verdi -f filelist.f -ssf flt_pds2_onboard.fsdb &

compile_cov:
	vcs -R -full64 +v2k -sverilog -debug_acc+all \
		-fsdb \
		+notimingcheck +nospecify \
		-f filelist.f \
		-cm line+tgl+cond+branch+assert \
		-cm_noconst \
		-l com.log

verdi_cov:
	verdi -f filelist.f -ssf flt_pds2_onboard.fsdb -cov -covdir simv.vdb/ -workMode coverageAnalysis &