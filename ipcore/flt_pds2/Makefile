

compile:
	vcs -R -full64 +v2k -sverilog -debug_acc+all \
		-fsdb \
		+notimingcheck +nospecify \
		+define+FSDB \
		-timescale=1ns/100ps \
		-f filelist.f\
		-o sim \
		-l sim.log

	((python3 fp_test.py 12 \
		1 \
		0 \
		0) \
< \
		"flt_pds2_input_output.txt") \
		> \
		flt_pds2_compare.txt

verdi:
	verdi -f filelist.f -ssf flt_pds2.fsdb &

compile_cov:
	vcs -R -full64 +v2k -sverilog -debug_acc+all \
		-fsdb \
		+notimingcheck +nospecify \
		-f filelist.f \
		-cm line+tgl+cond+branch+assert \
		-cm_noconst \
		-l com.log

	((python3 fp_test.py 12 \
		1 \
		0 \
		0) \
< \
		"flt_pds2_input_output.txt") \
		> \
		flt_pds2_compare.txt

verdi_cov:
	verdi -f filelist.f -ssf flt_pds2.fsdb -cov -covdir simv.vdb/ -workMode coverageAnalysis &
