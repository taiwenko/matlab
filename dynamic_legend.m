function y=dynamic_legend(channel,sn2channel)

 if channel == 1
        
     legend(strcat('CH1:',num2str(sn2channel(1))),'Location','best','Orientation','vertical')
        
 elseif channel == 2
     
     legend(strcat('CH1:',num2str(sn2channel(1))),strcat('CH2:',num2str(sn2channel(2))),'Location','best','Orientation','vertical')
     
 elseif channel == 3
     
     legend(strcat('CH1:',num2str(sn2channel(1))),strcat('CH2:',num2str(sn2channel(2))),strcat('CH3:',num2str(sn2channel(3))),'Location','best','Orientation','vertical')
     
 elseif channel == 4
     
     legend(strcat('CH1:',num2str(sn2channel(1))),strcat('CH2:',num2str(sn2channel(2))),strcat('CH3:',num2str(sn2channel(3))),strcat('CH4:',num2str(sn2channel(4))),'Location','best','Orientation','vertical')
     
 elseif channel == 5
     
     legend(strcat('CH1:',num2str(sn2channel(1))),strcat('CH2:',num2str(sn2channel(2))),strcat('CH3:',num2str(sn2channel(3))),strcat('CH4:',num2str(sn2channel(4))),strcat('CH5:',num2str(sn2channel(5))),'Location','best','Orientation','vertical')
     
 elseif channel == 6
     
     legend(strcat('CH1:',num2str(sn2channel(1))),strcat('CH2:',num2str(sn2channel(2))),strcat('CH3:',num2str(sn2channel(3))),strcat('CH4:',num2str(sn2channel(4))),strcat('CH5:',num2str(sn2channel(5))),strcat('CH6:',num2str(sn2channel(6))),'Location','best','Orientation','vertical')
     
 elseif channel == 7
     
     legend(strcat('CH1:',num2str(sn2channel(1))),strcat('CH2:',num2str(sn2channel(2))),strcat('CH3:',num2str(sn2channel(3))),strcat('CH4:',num2str(sn2channel(4))),strcat('CH5:',num2str(sn2channel(5))),strcat('CH6:',num2str(sn2channel(6))),strcat('CH7:',num2str(sn2channel(7))),'Location','best','Orientation','vertical')
     
 elseif channel == 8
     
     legend(strcat('CH1:',num2str(sn2channel(1))),strcat('CH2:',num2str(sn2channel(2))),strcat('CH3:',num2str(sn2channel(3))),strcat('CH4:',num2str(sn2channel(4))),strcat('CH5:',num2str(sn2channel(5))),strcat('CH6:',num2str(sn2channel(6))),strcat('CH7:',num2str(sn2channel(7))),strcat('CH8:',num2str(sn2channel(8))),'Location','best','Orientation','vertical')
     
 elseif channel == 9
     
     legend(strcat('CH1:',num2str(sn2channel(1))),strcat('CH2:',num2str(sn2channel(2))),strcat('CH3:',num2str(sn2channel(3))),strcat('CH4:',num2str(sn2channel(4))),strcat('CH5:',num2str(sn2channel(5))),strcat('CH6:',num2str(sn2channel(6))),strcat('CH7:',num2str(sn2channel(7))),strcat('CH8:',num2str(sn2channel(8))),strcat('CH9:',num2str(sn2channel(9))),'Location','best','Orientation','vertical')
     
 end
