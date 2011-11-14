set title "Summary Bandwidth Estimation (Last Estimation of each Test)" 
set xlabel "Testnumber"
set ylabel "Estimated Bandwidth (MBit/s)"
 
plot "summary_bandwidthestimation.data" w linespoints
