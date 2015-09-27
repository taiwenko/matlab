function graph_gxpr(file, channel, sn)

    for i = 1:length(sn)
        gxpr2switch(i) = sn(i); 
    end 

    % Hardcoded Values
    N = 120;
    bridge_ts_col = 1;
    gxpr_sys_state_col = 4;
    gxpr_sys_error_col = 5;
    gxpr_sn_col = 8;
    fpga_core_rail_volt_col = 10; 
    fpga_logic_rail_volt_col = 11; 
    driver_rail_volt_col = 12; 
    pa_rail_volt_col = 13;
    vin_rail_volt_col = 14;
    gxpr_tx_temp_col = 15;
    gxpr_mode_a_interr_col = 16;
    gxpr_mode_a_tx_col = 17;
    gxpr_mode_c_interr_col = 18;
    gxpr_mode_c_tx_col = 19;
    gxpr_baro_heater_setpoint_col = 21;
    gxpr_ts_col = 25;
    insterp_value_col = 39;
    instmtl_value_col = 45;

    input = textscan(file,'%s','Delimiter','-');
    year = input{1,1}{1,1};
    month = input{1,1}{2,1};
    day = input{1,1}{3,1};
    set = input{1,1}{4,1};
    type = input{1,1}{5,1};
    ppsn = input{1,1}{6,1};
    psn = textscan(ppsn,'%s','Delimiter','.');
    bridge_sn = psn{1,1}{1,1};

    % Get row count
    fileID = fopen(file);
    nLines = 0;
    while (fgets(fileID) ~= -1),
      nLines = nLines+1;
    end
    % Calculate number of cycle and total measurement 
    cycle = floor((nLines-1)/channel);
    total = channel * cycle; 
    fclose(fileID); 


    fileID = fopen(file);
    formatSpec = '%s';
    %parse out headers
    C = textscan(fileID,formatSpec,N,'Delimiter',',');

    %parse out each channel data
    for j = 0:(cycle-1)
        for k = 1:channel
            i = (j*channel)+k;
            C_data(i) = textscan(fileID,formatSpec,N,'Delimiter',',');
            gxpr_sys_state(i) = str2num(C_data{1,i}{gxpr_sys_state_col,1});
            gxpr_sys_error(i) = str2num(C_data{1,i}{gxpr_sys_error_col,1});
            gxpr_sn = str2num(C_data{1,i}{gxpr_sn_col,1});
            fpga_core_rail_volt(i) = str2num(C_data{1,i}{fpga_core_rail_volt_col,1});
            fpga_logic_rail_volt(i) = str2num(C_data{1,i}{fpga_logic_rail_volt_col,1});
            driver_rail_volt(i) = str2num(C_data{1,i}{driver_rail_volt_col,1});
            pa_rail_volt(i) = str2num(C_data{1,i}{pa_rail_volt_col,1});
            vin_rail_volt(i) = str2num(C_data{1,i}{vin_rail_volt_col,1});
            gxpr_tx_temp(i) = str2num(C_data{1,i}{gxpr_tx_temp_col,1});
            gxpr_mode_a_interr(i) = str2num(C_data{1,i}{gxpr_mode_a_interr_col,1});
            gxpr_mode_c_interr(i) = str2num(C_data{1,i}{gxpr_mode_c_interr_col,1});
            gxpr_mode_a_tx(i) = str2num(C_data{1,i}{gxpr_mode_a_tx_col,1});
            gxpr_mode_c_tx(i) = str2num(C_data{1,i}{gxpr_mode_c_tx_col,1});
            gxpr_baro_heater_setpoint(i) = str2num(C_data{1,i}{gxpr_baro_heater_setpoint_col,1});
            insterp_value(i) = str2num(C_data{1,i}{insterp_value_col,1});
            instmtl_value(i) = str2num(C_data{1,i}{instmtl_value_col,1});

            bridge_ts = textscan(C_data{1,i}{bridge_ts_col,1},formatSpec,'Delimiter','T');
            bridge_ts_ymd = textscan(bridge_ts{1,1}{1,1},formatSpec,'Delimiter','-');
            bridge_ts_yr(i) = str2num(bridge_ts_ymd{1,1}{1,1});
            bridge_ts_month(i) = str2num(bridge_ts_ymd{1,1}{2,1});
            bridge_ts_day(i) = str2num(bridge_ts_ymd{1,1}{3,1});
            bridge_ts_hms = textscan(bridge_ts{1,1}{2,1},formatSpec,'Delimiter',':');
            bridge_ts_hr(i) = str2num(bridge_ts_hms{1,1}{1,1});
            bridge_ts_min(i) = str2num(bridge_ts_hms{1,1}{2,1});
            bridge_ts_sec(i) = str2num(bridge_ts_hms{1,1}{3,1});

            gxpr_ts = textscan(C_data{1,i}{gxpr_ts_col,1},formatSpec,'Delimiter','T');
            gxpr_ts_ymd = textscan(gxpr_ts{1,1}{1,1},formatSpec,'Delimiter','-');
            gxpr_ts_yr(i) = str2num(gxpr_ts_ymd{1,1}{1,1});
            gxpr_ts_month(i) = str2num(gxpr_ts_ymd{1,1}{2,1});
            gxpr_ts_day(i) = str2num(gxpr_ts_ymd{1,1}{3,1});
            gxpr_ts_hms = textscan(gxpr_ts{1,1}{2,1},formatSpec,'Delimiter',':');
            gxpr_ts_hr(i) = str2num(gxpr_ts_hms{1,1}{1,1});
            gxpr_ts_min(i) = str2num(gxpr_ts_hms{1,1}{2,1});
            gxpr_ts_sec(i) = str2num(gxpr_ts_hms{1,1}{3,1});

        end
    end 

    fclose(fileID);

    figure(1)

    % Get time ticks
    formatin = 'yyyy,mm,dd,HH,MM,SS';
    for i = 1:total
        bridge_time(i) = datenum(strcat([num2str(bridge_ts_yr(i)),',',num2str(bridge_ts_month(i)),',',num2str(bridge_ts_day(i)),',',num2str(bridge_ts_hr(i)),',',num2str(bridge_ts_min(i)),',',num2str(round(bridge_ts_sec(i)))]),formatin);
    end 

    % Get bridge time range in string
    bridge_timestring = strcat(['Start Time: ', num2str(bridge_ts_yr(1)), '-', num2str(bridge_ts_month(1)), '-', num2str(bridge_ts_day(1)), '  ',num2str(bridge_ts_hr(1)), ':', num2str(bridge_ts_min(1)),':' , num2str(bridge_ts_sec(1)), '      End Time: ', num2str(bridge_ts_yr(total)), '-', num2str(bridge_ts_month(total)), '-', num2str(bridge_ts_day(total)), '  ', num2str(bridge_ts_hr(total)), ':', num2str(bridge_ts_min(total)), ':' , num2str(bridge_ts_sec(total))]);

    subplot(2,2,1)
    plot(bridge_time, fpga_core_rail_volt,'r')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, fpga_logic_rail_volt,'b')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, driver_rail_volt,'g')
    datetick('x','HH:MM');
    grid on
    xlabel('TimeStamp')
    ylabel('GXPR Low Voltages (V)')
    legend('FPGA Core Rail Volt','FPGA Logic Rail Volt','Driver Rail Volt','Location','east','Orientation','vertical')
    title(['GXPR Serial Number: ', num2str(gxpr_sn),'     GXPR Bridge Serial Number: ', num2str(bridge_sn)])

    subplot(2,2,2)
    scatter(gxpr_tx_temp, fpga_core_rail_volt,'r')
    hold on
    scatter(gxpr_tx_temp, fpga_logic_rail_volt,'b')
    hold on
    scatter(gxpr_tx_temp, driver_rail_volt,'g');
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('GXPR Low Voltages (V)')
    legend('FPGA Core Rail Volt','FPGA Logic Rail Volt','Driver Rail Volt','Location','east','Orientation','vertical')
    temp_profile_title()

    subplot(2,2,3)
    plot(bridge_time, pa_rail_volt,'c')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, vin_rail_volt,'m')
    datetick('x','HH:MM');
    grid on
    xlabel('TimeStamp')
    ylabel('GXPR High Voltages (V)')
    legend('PA Rail Volt','Vin Rail Volt','Location','east','Orientation','vertical')
    title(bridge_timestring)

    subplot(2,2,4)
    scatter(gxpr_tx_temp, pa_rail_volt,'c')
    hold on
    scatter(gxpr_tx_temp, vin_rail_volt,'m')
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('GXPR High Voltages (V)')
    legend('PA Rail Volt','Vin Rail Volt','Location','east','Orientation','vertical')

    figure(2)

    subplot(2,2,1)
    plot(bridge_time, gxpr_sys_state,'r')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, gxpr_sys_error,'b')
    datetick('x','HH:MM');
    grid on
    xlabel('TimeStamp')
    ylabel('Bit')
    legend('GXPR System State','GXPR System Error','Location','west','Orientation','vertical')
    title(['GXPR Serial Number: ', num2str(gxpr_sn),'     GXPR Bridge Serial Number: ', num2str(bridge_sn)])

    subplot(2,2,2)
    scatter(gxpr_tx_temp, gxpr_sys_state,'r')
    hold on
    scatter(gxpr_tx_temp, gxpr_sys_error,'b')
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('Bit')
    legend('GXPR System State','GXPR System Error','Location','west','Orientation','vertical')
    temp_profile_title()

    subplot(2,2,3)
    plot(bridge_time, gxpr_mode_a_interr,'r')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, gxpr_mode_c_interr,'b')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, gxpr_mode_a_tx,'c--o')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, gxpr_mode_c_tx,'m--o')
    datetick('x','HH:MM');
    grid on
    xlabel('TimeStamp')
    ylabel('GXPR Interrogation Count(V)')
    legend('Mode A Int','Mode C Int', 'Mode A Tx', 'Mode C Tx', 'Location','west','Orientation','vertical')
    title(bridge_timestring)

    subplot(2,2,4)
    scatter(gxpr_tx_temp, gxpr_mode_a_interr,'r','x')
    hold on
    scatter(gxpr_tx_temp, gxpr_mode_c_interr,'b','x')
    hold on
    scatter(gxpr_tx_temp, gxpr_mode_a_tx,'c','o')
    hold on
    scatter(gxpr_tx_temp, gxpr_mode_c_tx,'m','o')
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('GXPR Interrogation Count(V)')
    legend('Mode A Int','Mode C Int', 'Mode A Tx', 'Mode C Tx','Location','west','Orientation','vertical')

    figure(3)

    for i = 1:total
        gxpr_time(i) = datenum(strcat([num2str(gxpr_ts_yr(i)),',',num2str(gxpr_ts_month(i)),',',num2str(gxpr_ts_day(i)),',',num2str(gxpr_ts_hr(i)),',',num2str(gxpr_ts_min(i)),',',num2str(round(gxpr_ts_sec(i)))]),formatin);
    end 

    for i = 1:channel
        k = i;    
        for j = 1:cycle
            insterp(i,j) = insterp_value(k);
            instmtl(i,j) = instmtl_value(k);
            gxpr_tx_temp_qtr(i,j) = gxpr_tx_temp(k);
            k = k + channel; 
        end
    end 

    cc = hsv(channel);
    ss = cellstr(['+';'o';'*';'.';'x';'s';'d';'^';'v']);
    sc = cellstr(['-r<';'-go';'-b*';'-c.';'-mx';'-ys';'-bd';'-r^';'-bv']);

    for i = 1:cycle

        %graph insterp_value
        subplot(2,2,1)
        for j = 1:channel
            plot(insterp(j,:),sc{j});
            hold on
        end 
        grid on
        title('IFR6000 Readings')
        xlabel('# of IFR Measurement (4 per temp cycle)')
        xlim([1 cycle])
        ylabel('Instant ERP (dBm)')
        dynamic_legend(channel,gxpr2switch);

        subplot(2,2,2)
        for j = 1:channel
            scatter(gxpr_tx_temp_qtr(j,:), insterp(j,:),[],cc(j,:),ss{j});
            hold on
        end 
        grid on
        xlabel('GXPR TX Temperature (k)')
        ylabel('Instant ERP (dBm)')
        temp_profile_title()
        dynamic_legend(channel,gxpr2switch);

        %graph instmtl_value
        subplot(2,2,3)
         for j = 1:channel
            plot(instmtl(j,:),sc{j});
            hold on
        end 
        grid on
        xlabel('# of IFR Measurement (4 per temp cycle)')
        xlim([1 cycle])
        ylabel('Instant MTL (dBm)')
        title(['Start Time: ', num2str(gxpr_ts_yr(1)), '-', num2str(gxpr_ts_month(1)), '-', num2str(gxpr_ts_day(1)), '  ', num2str(gxpr_ts_hr(1)), ':', num2str(gxpr_ts_min(1)),':' , num2str(gxpr_ts_sec(1)), '      End Time: ', num2str(gxpr_ts_yr(total)), '-', num2str(gxpr_ts_month(total)), '-', num2str(gxpr_ts_day(total)), '  ' , num2str(gxpr_ts_hr(total)), ':', num2str(gxpr_ts_min(total)), ':' , num2str(gxpr_ts_sec(total))])
        dynamic_legend(channel,gxpr2switch);

         subplot(2,2,4)
         for j = 1:channel
            scatter(gxpr_tx_temp_qtr(j,:), instmtl(j,:),[],cc(j,:),ss{j});
            hold on
        end 
        grid on
        xlabel('GXPR TX Temperature (k)')
        ylabel('Instant MTL (dBm)')
        dynamic_legend(channel,gxpr2switch);
    end 
end