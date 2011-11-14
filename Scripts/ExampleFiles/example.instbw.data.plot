set title "AverageProbingRate_0.5_mbps.instbw.data" 
set xlabel "Time (s)"
set ylabel  "Bandwith (Mbps)"
 plot 'example.instbw.data' using 1:2 title "example.instbw.data" w points lt 3, 'example.instbw.data' using 1:3 title "example.instbw.data (avg 5 samples)" w lines lt 3
