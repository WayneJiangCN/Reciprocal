debImport "-f" "filelist.f"
debLoadSimResult \
           /anlab/stuhome/zngz17/Lab_work/Float_point/pds_ip_10_27/ipcore/flt_pds2/flt_pds2.fsdb
wvCreateWindow
srcHBSelect \
           "ipm_distributed_shiftregister_wrapper_v1_3.u_ipm_distributed_shiftregister" \
           -win $_nTrace1
verdiDockWidgetSetCurTab -dock widgetDock_<Decl._Tree>
srcTBBTreeSelect -win $_nTrace1 -path "reci"
srcTBBTreeSelect -win $_nTrace1 -path "reci"
srcTBTreeAction -win $_nTrace1 -path "reci"
srcDeselectAll -win $_nTrace1
srcSelect -signal "Rst" -line 45 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_X_fir_rre" -line 42 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_X_fir_rrre" -line 43 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "FLT_WIDTH" -line 43 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "X_simlar" -line 82 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_X_fir_rrre" -line 74 -pos 1 -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "i_X_fir_rre" -line 86 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvZoomIn -win $_nWave2
wvSetCursor -win $_nWave2 5109219.152801 -snap {("G1" 1)}
wvSetCursor -win $_nWave2 5109416.486617 -snap {("G1" 2)}
wvSetCursor -win $_nWave2 5109317.819709 -snap {("G1" 3)}
wvSetCursor -win $_nWave2 5109663.153886 -snap {("G2" 0)}
