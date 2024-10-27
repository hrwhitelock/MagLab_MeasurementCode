%%
 figure (5); clf; hold on; box on;grid on;
 xlabel ('field'); ylabel ('approx HC')
plot(bfield036_20K, ApproxHC036_20K);
plot(bfield028_16K, ApproxHC028_16K);
plot(bfield029_16K, ApproxHC029_16K);
 plot (bfield030_12K,ApproxHC030_12K);
  plot (bfield031_10K,ApproxHC031_10K);
    plot (bfield032_08K,ApproxHC032_08K);
     plot (bfield033_06K,ApproxHC033_06K);
     plot (bfield034_04K,ApproxHC034_04K);
      plot (bfield035_02K,ApproxHC035_02K);
 legend ('20K,77 Hz','16K,23Hz','16K,117Hz', '12K,117Hz', '10K,131Hz', '08K,131Hz',...
     '6K,151Hz', '4K,171Hz','2K,171Hz')
 hold off;
 %%
 figure(6) ;clf;
 xlabel ('field'); ylabel ('approx Tosc');hold on;grid on; box on;
plot(bfield036_20K, ApproxTosc036_20K);
plot(bfield028_16K, ApproxTosc028_16K);
plot(bfield029_16K, ApproxTosc029_16K);
 plot (bfield030_12K,ApproxTosc030_12K);
  plot (bfield031_10K,ApproxTosc031_10K);
    plot (bfield032_08K,ApproxTosc032_08K);
     plot (bfield033_06K,ApproxTosc033_06K);
     plot (bfield034_04K,ApproxTosc034_04K);
      plot (bfield035_02K,ApproxTosc035_02K);
 legend ('20K,77Hz,100uA','16K,23Hz','16K,117Hz', '12K,117Hz', '10K,131Hz', '08K,131Hz,80uA',...
     '6K,151Hz,70uA', '4K,171Hz,60uA','2K,171Hz,55uA')
 hold off;