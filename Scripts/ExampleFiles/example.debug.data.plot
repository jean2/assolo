set title "AverageProbingRate_0.5_mbps.debug.data" 
set xlabel "Time"
set ylabel "Packet"
 
set style line 1 lt 2 lw 0.5 linecolor rgb "black"
set style line 2 lt 2 lw 0.5 linecolor rgb "gray"
set style line 3 lt 1 lw 1   linecolor rgb "green"
set style line 4 lt 1 lw 1   linecolor rgb "orange"
set style line 5 lt 1 lw 1   linecolor rgb "red"
set style line 6 lt 1 lw 1   linecolor rgb "blue"
 
plot "example.debug.data" using 4:1 title 'Packet send' w l ls 1, "example.debug.data" using 5:1 title 'Packet received' w l ls 2, "example.debug.data" using 4:1:8 title 'Delay caused by Network (Sender)' w xerrorbars ls 5, "example.debug.data" using 5:1:8 title 'Delay caused by Network (Receiver)' w xerrorbars ls 6 
