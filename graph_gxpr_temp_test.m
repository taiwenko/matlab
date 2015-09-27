% Copyright 2014 Google, Inc.
% Routines for post processing the logs generated from the GXPR temp test
% Author: TaiWen Ko
% Date: 2014-12-09

% Change Log: 

function graph_gxpr_temp_test(file)

    % Make dir
    mkdir('gxpr_plot')
    main_dir = 'gxpr_plot/';

    % Temperature Profile
    cold_start = -35;
    cold_temp = -20;
    ambient_temp = 20;
    hot_temp = 50;
    soak_time = 20;
    
    % Convert to kelvin
    kelvin = 273.15;
    cold_startk = cold_start + kelvin;
    cold_tempk = cold_temp + kelvin;
    ambient_tempk = ambient_temp + kelvin;
    hot_tempk = hot_temp + kelvin;
    
    % Temp String
    temp_string1 = (['Cold Start = ', num2str(cold_start) 'C (', num2str(cold_startk), 'k), Cold Temp = ', num2str(cold_temp), 'C (', num2str(cold_tempk) ,'k), Ambient Temp = ', num2str(ambient_temp) ,'C (', num2str(ambient_tempk) ,'k)']);
    temp_string2 = (['Hot Temp = ', num2str(hot_temp) ,'C (', num2str(hot_tempk) ,'k), Soak Time = ', num2str(soak_time), 'min.']);
        
    % File Column
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
    
    decoder_col = 58; 
    timing_col = 76;
    delay_col = 28;
    droop_col = 110;
    reply_col = 67;
    jitter_col = 115;
    ratio_col = 89;
    sls_col = 98;
    
    % Limits
    cap = 0;
    tolerance = 0.05;
    fpga_core_rail_volt_min = 1.2 * (1 - tolerance);
    fpga_core_rail_volt_max = 1.2 * (1 + tolerance);
    fpga_logic_rail_volt_min = 3.3 * (1 - tolerance);
    fpga_logic_rail_volt_max = 3.3 * (1 + tolerance);
    driver_rail_volt_min = 6.26 * (1 - tolerance);
    driver_rail_volt_max = 6.26 * (1 + tolerance);
    pa_rail_volt_min = 29 * (1 - tolerance);
    pa_rail_volt_max = 29 * (1 + tolerance);
    vin_rail_volt_min = 20 * (1 - tolerance);
    vin_rail_volt_max = 20 * (1 + tolerance);
    
    % show all losses from setup
    cable_loss = 2*0.8; % 2 cables
    attenuator_loss = 18;
    switch_loss = 0.6;
    %coupler_erp = 2.4;
    %coupler_mtl = -2;
    % According to IFR 6000 manual 
    insterp_min_passing = 48.5;
    insterp_max_passing = 57;
    instmtl_min_passing = -77;
    instmtl_max_passing = -69;
    instmtl_relieve = -1.5; % for UUTs with slightly higher ERP
    insterp_loss = cable_loss + attenuator_loss + switch_loss; %+ coupler_erp;  
    insterp_min = insterp_min_passing - insterp_loss;
    insterp_max = insterp_max_passing - insterp_loss;
    instmtl_min = instmtl_min_passing + insterp_loss + instmtl_relieve;
    instmtl_max = instmtl_max_passing + insterp_loss + instmtl_relieve;
    %instmtl_min = (-54+coupler_mtl) * (1 + tolerance);
    %instmtl_max = (-54+coupler_mtl) * (1 - tolerance);

    % Get info from file name
    input = textscan(file,'%s','Delimiter',{'temptest-'});
    ppsn = input{1,1}{2,1};
    psn = textscan(ppsn,'%s','Delimiter','.');
    bridge_sn = psn{1,1}{1,1};

    % Get row count
    fileID = fopen(file);
    cycle = 0;
    while (fgets(fileID) ~= -1),
      cycle = cycle+1;
    end
    cycle = cycle-1;

    % Get column count
    fileID = fopen(file);
    tline = fgetl(fileID);
    fclose(fileID);
    N = length(find(tline==','))+1;

    % Parse out headers
    fileID = fopen(file);
    formatSpec = '%s';
    C = textscan(fileID,formatSpec,N,'Delimiter',',');

    % Parse out each channel data
    for i = 1:cycle
        C_data(i) = textscan(fileID,formatSpec,N,'Delimiter',',');
        gxpr_sys_state(i) = str2double(C_data{1,i}{gxpr_sys_state_col,1});
        gxpr_sys_error(i) = str2double(C_data{1,i}{gxpr_sys_error_col,1});
        gxpr_sn = str2double(C_data{1,i}{gxpr_sn_col,1});
        fpga_core_rail_volt(i) = str2double(C_data{1,i}{fpga_core_rail_volt_col,1});
        fpga_logic_rail_volt(i) = str2double(C_data{1,i}{fpga_logic_rail_volt_col,1});
        driver_rail_volt(i) = str2double(C_data{1,i}{driver_rail_volt_col,1});
        pa_rail_volt(i) = str2double(C_data{1,i}{pa_rail_volt_col,1});
        vin_rail_volt(i) = str2double(C_data{1,i}{vin_rail_volt_col,1});
        gxpr_tx_temp(i) = str2double(C_data{1,i}{gxpr_tx_temp_col,1});
        gxpr_mode_a_interr(i) = str2double(C_data{1,i}{gxpr_mode_a_interr_col,1});
        gxpr_mode_c_interr(i) = str2double(C_data{1,i}{gxpr_mode_c_interr_col,1});
        gxpr_mode_a_tx(i) = str2double(C_data{1,i}{gxpr_mode_a_tx_col,1});
        gxpr_mode_c_tx(i) = str2double(C_data{1,i}{gxpr_mode_c_tx_col,1});
        gxpr_baro_heater_setpoint(i) = str2double(C_data{1,i}{gxpr_baro_heater_setpoint_col,1});
        insterp_value(i) = str2double(C_data{1,i}{insterp_value_col,1});
        instmtl_value(i) = str2double(C_data{1,i}{instmtl_value_col,1});

        decoder_value(i) = strcmp((C_data{1,i}{decoder_col,1}),'PASS');
        timing_value(i) = strcmp((C_data{1,i}{timing_col,1}),'PASS');
        delay_value(i) = strcmp((C_data{1,i}{delay_col,1}),'PASS');
        droop_value(i) = strcmp((C_data{1,i}{droop_col,1}),'PASS');
        reply_value(i) = strcmp((C_data{1,i}{reply_col,1}),'PASS');
        jitter_value(i) = strcmp((C_data{1,i}{jitter_col,1}),'PASS');
        ratio_value(i) = strcmp((C_data{1,i}{ratio_col,1}),'PASS');
        sls_value(i) = strcmp((C_data{1,i}{sls_col,1}),'PASS');

        bridge_ts = textscan(C_data{1,i}{bridge_ts_col,1},formatSpec,'Delimiter','T');
        bridge_ts_ymd = textscan(bridge_ts{1,1}{1,1},formatSpec,'Delimiter','-');
        bridge_ts_yr(i) = str2double(bridge_ts_ymd{1,1}{1,1});
        bridge_ts_month(i) = str2double(bridge_ts_ymd{1,1}{2,1});
        bridge_ts_day(i) = str2double(bridge_ts_ymd{1,1}{3,1});
        bridge_ts_hms = textscan(bridge_ts{1,1}{2,1},formatSpec,'Delimiter',':');
        bridge_ts_hr(i) = str2double(bridge_ts_hms{1,1}{1,1});
        bridge_ts_min(i) = str2double(bridge_ts_hms{1,1}{2,1});
        bridge_ts_sec(i) = str2double(bridge_ts_hms{1,1}{3,1});
        
        gxpr_ts = textscan(C_data{1,i}{gxpr_ts_col,1},formatSpec,'Delimiter','T');
        gxpr_ts_ymd = textscan(gxpr_ts{1,1}{1,1},formatSpec,'Delimiter','-');
        gxpr_ts_yr(i) = str2double(gxpr_ts_ymd{1,1}{1,1});
        gxpr_ts_month(i) = str2double(gxpr_ts_ymd{1,1}{2,1});
        gxpr_ts_day(i) = str2double(gxpr_ts_ymd{1,1}{3,1});
        gxpr_ts_hms = textscan(gxpr_ts{1,1}{2,1},formatSpec,'Delimiter',':');
        gxpr_ts_hr(i) = str2double(gxpr_ts_hms{1,1}{1,1});
        gxpr_ts_min(i) = str2double(gxpr_ts_hms{1,1}{2,1});
        gxpr_ts_sec(i) = str2double(gxpr_ts_hms{1,1}{3,1});
    end 
    fclose(fileID);

    % Make new folder using file name  
    %mkdir(strcat(main_dir,num2str(gxpr_sn)))
    t = datestr(now, 'yyyymmddHHMMSS');
    bridge_sn_date = strcat( num2str(bridge_sn),'-', t);
    mkdir(strcat(main_dir, bridge_sn_date))

    % Write results.txt header
    %fileID = fopen(strcat(main_dir,num2str(gxpr_sn),'/results.txt'),'w');
    fileID = fopen(strcat(main_dir,num2str(bridge_sn_date),'/results.txt'),'w');
    fprintf(fileID,'GXPR Temperature Testing\r');
    fprintf(fileID,strcat('File:',file,'\r'));
    fprintf(fileID,strcat('Start Time: ', num2str(bridge_ts_yr(1)), '-', num2str(bridge_ts_month(1)), '-', num2str(bridge_ts_day(1)),'-',num2str(bridge_ts_hr(1)), ':', num2str(bridge_ts_min(1)),':' , num2str(bridge_ts_sec(1)), '\r'));
    fprintf(fileID,strcat('End Time: ', num2str(bridge_ts_yr(cycle)), '-', num2str(bridge_ts_month(cycle)), '-', num2str(bridge_ts_day(cycle)),'-', num2str(bridge_ts_hr(cycle)), ':', num2str(bridge_ts_min(cycle)), ':' , num2str(bridge_ts_sec(cycle)),'\r\r'));
    fprintf(fileID,'Temperature Profile:\r');
    fprintf(fileID,strcat('Cold Start = ', num2str(cold_start), 'C\r'));
    fprintf(fileID,strcat('Cold Temperature =  ', num2str(cold_temp), 'C\r'));
    fprintf(fileID,strcat('Ambient Temperature =  ', num2str(ambient_temp), 'C\r'));
    fprintf(fileID,strcat('Hot Temperature =  ', num2str(hot_temp), 'C\r'));
    fprintf(fileID,strcat('Soak Time = ', num2str(soak_time), 'min.\r\r'));
    fprintf(fileID,'GXPR Bridge Serial Number: \r');
    fprintf(fileID, strcat(num2str(bridge_sn),'\r\r'));
    fprintf(fileID,'GXPR Serial Number: \r');
    %fprintf(fileID, strcat(num2str(gxpr_sn),'\r\r'));
    fprintf(fileID, strcat(num2str(bridge_sn_date),'\r\r'));
    fprintf(fileID,strcat('A test will fail if it violates the limits this many times:  ', num2str(cap), '\r\r'));

    figure(1)
    % Get time ticks
    formatin = 'yyyy,mm,dd,HH,MM,SS';
    for i = 1:cycle
        bridge_time(i) = datenum(strcat([num2str(bridge_ts_yr(i)),',',num2str(bridge_ts_month(i)),',',num2str(bridge_ts_day(i)),',',num2str(bridge_ts_hr(i)),',',num2str(bridge_ts_min(i)),',',num2str(round(bridge_ts_sec(i)))]),formatin);
    end 

    % Get bridge time range in string
    bridge_timestring = strcat(['Start Time: ', num2str(bridge_ts_yr(1)), '-', num2str(bridge_ts_month(1)), '-', num2str(bridge_ts_day(1)), '  ',num2str(bridge_ts_hr(1)), ':', num2str(bridge_ts_min(1)),':' , num2str(bridge_ts_sec(1)), '      End Time: ', num2str(bridge_ts_yr(cycle)), '-', num2str(bridge_ts_month(cycle)), '-', num2str(bridge_ts_day(cycle)), '  ', num2str(bridge_ts_hr(cycle)), ':', num2str(bridge_ts_min(cycle)), ':' , num2str(bridge_ts_sec(cycle))]);

    % Plot Voltage
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
    legend('FPGA Core Rail Volt','FPGA Logic Rail Volt','Driver Rail Volt','Location','best','Orientation','vertical')
    %title({['GXPR Serial Number: ', num2str(gxpr_sn),'     GXPR Bridge Serial Number: ', num2str(bridge_sn)],''})
    title({['GXPR Bridge Serial Number: ', num2str(bridge_sn)],''})
    
    subplot(2,2,2)
    scatter(gxpr_tx_temp, fpga_core_rail_volt,'r')
    hold on
    scatter(gxpr_tx_temp, fpga_logic_rail_volt,'b')
    hold on
    scatter(gxpr_tx_temp, driver_rail_volt,'g');
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('GXPR Low Voltages (V)')
    legend('FPGA Core Rail Volt','FPGA Logic Rail Volt','Driver Rail Volt','Location','best','Orientation','vertical')

    subplot(2,2,3)
    plot(bridge_time, pa_rail_volt,'c')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, vin_rail_volt,'m')
    datetick('x','HH:MM');
    grid on
    xlabel('TimeStamp')
    ylabel('GXPR High Voltages (V)')
    legend('PA Rail Volt','Vin Rail Volt','Location','best','Orientation','vertical')
    title({bridge_timestring,'',''})

    subplot(2,2,4)
    scatter(gxpr_tx_temp, pa_rail_volt,'c')
    hold on
    scatter(gxpr_tx_temp, vin_rail_volt,'m')
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('GXPR High Voltages (V)')
    legend('PA Rail Volt','Vin Rail Volt','Location','best','Orientation','vertical')
    title({temp_string1,temp_string2,''});

    % Check voltage data
    result = checkdata(fpga_core_rail_volt,fpga_core_rail_volt_min,fpga_core_rail_volt_max,cap,fileID);
    fpga_core_rail_volt_result = strcat('fpga_core_rail_volt........[',result,']\r');
    fprintf(fpga_core_rail_volt_result);
    fprintf(fileID,fpga_core_rail_volt_result);

    result = checkdata(fpga_logic_rail_volt,fpga_logic_rail_volt_min,fpga_logic_rail_volt_max,cap,fileID);
    fpga_logic_rail_volt_result = strcat('fpga_logic_rail_volt........[',result,']\r');
    fprintf(fpga_logic_rail_volt_result);
    fprintf(fileID,fpga_logic_rail_volt_result); 

    result = checkdata(driver_rail_volt,driver_rail_volt_min,driver_rail_volt_max,cap,fileID);
    driver_rail_volt_result = strcat('driver_rail_volt........[',result,']\r');
    fprintf(driver_rail_volt_result); 
    fprintf(fileID,driver_rail_volt_result); 

    result = checkdata(pa_rail_volt,pa_rail_volt_min,pa_rail_volt_max,cap,fileID);
    pa_rail_volt_result = strcat('pa_rail_volt........[',result,']\r');
    fprintf(pa_rail_volt_result);
    fprintf(fileID,pa_rail_volt_result); 

    result = checkdata(vin_rail_volt,vin_rail_volt_min,vin_rail_volt_max,cap,fileID);
    vin_rail_volt_result = strcat('vin_rail_volt........[',result,']\r');
    fprintf(vin_rail_volt_result);
    fprintf(fileID,vin_rail_volt_result); 
    
    set(figure(1), 'PaperPosition', [0 0 18 12]);
    set(figure(1)   , 'PaperSize', [40 40]);
    %saveas(figure(1), strcat(main_dir,num2str(gxpr_sn),'/Voltage.jpg')); 
    saveas(figure(1), strcat(main_dir,num2str(bridge_sn_date),'/Voltage.jpg')); 
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
    %title({['GXPR Serial Number: ', num2str(gxpr_sn),'     GXPR Bridge Serial Number: ', num2str(bridge_sn)],''})
    title({['GXPR Bridge Serial Number: ', num2str(bridge_sn)],''})
    
    subplot(2,2,2)
    scatter(gxpr_tx_temp, gxpr_sys_state,'rx')
    hold on
    scatter(gxpr_tx_temp, gxpr_sys_error,'b')
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('Bit')
    legend('GXPR System State','GXPR System Error','Location','west','Orientation','vertical')

    subplot(2,2,3)
    plot(bridge_time, gxpr_mode_a_interr,'r-x')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, gxpr_mode_c_interr,'b-x')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, gxpr_mode_a_tx,'c--o')
    datetick('x','HH:MM');
    hold on
    plot(bridge_time, gxpr_mode_c_tx,'g--o')
    datetick('x','HH:MM');
    grid on
    xlabel('TimeStamp')
    ylabel('GXPR Interrogation Count(V)')
    legend('Mode A Int','Mode C Int', 'Mode A Tx', 'Mode C Tx', 'Location','west','Orientation','vertical')
    title({bridge_timestring,'',''})

    subplot(2,2,4)
    scatter(gxpr_tx_temp, gxpr_mode_a_interr,'r','x')
    hold on
    scatter(gxpr_tx_temp, gxpr_mode_c_interr,'b','x')
    hold on
    scatter(gxpr_tx_temp, gxpr_mode_a_tx,'c','o')
    hold on
    scatter(gxpr_tx_temp, gxpr_mode_c_tx,'g','o')
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('GXPR Interrogation Count(V)')
    legend('Mode A Int','Mode C Int', 'Mode A Tx', 'Mode C Tx','Location','west','Orientation','vertical')
    title({temp_string1,temp_string2,''});
    
    set(figure(2), 'PaperPosition', [0 0 18 12]);
    set(figure(2)   , 'PaperSize', [40 40]);
    %set(figure(2), 'PaperPosition', [0 0 9 6]);
    %set(figure(2)   , 'PaperSize', [10 10]);
    %saveas(figure(2),strcat(main_dir,num2str(gxpr_sn),'/State&Count.jpg'));
    saveas(figure(2),strcat(main_dir,num2str(bridge_sn_date),'/State&Count.jpg')); 

    figure(3)

    % Get time ticks
    for i = 1:cycle
        gxpr_time(i) = datenum(strcat([num2str(gxpr_ts_yr(i)),',',num2str(gxpr_ts_month(i)),',',num2str(gxpr_ts_day(i)),',',num2str(gxpr_ts_hr(i)),',',num2str(gxpr_ts_min(i)),',',num2str(round(gxpr_ts_sec(i)))]),formatin);
    end 
  
    % Get gxpr time range in string
    gxpr_timestring = strcat(['Start Time: ', num2str(gxpr_ts_yr(1)), '-', num2str(gxpr_ts_month(1)), '-', num2str(gxpr_ts_day(1)), '  ',num2str(gxpr_ts_hr(1)), ':', num2str(gxpr_ts_min(1)),':' , num2str(gxpr_ts_sec(1)), '      End Time: ', num2str(gxpr_ts_yr(cycle)), '-', num2str(gxpr_ts_month(cycle)), '-', num2str(gxpr_ts_day(cycle)), '  ', num2str(gxpr_ts_hr(cycle)), ':', num2str(gxpr_ts_min(cycle)), ':' , num2str(gxpr_ts_sec(cycle))]);

    % Plot insterp_value
    subplot(2,2,1)
    plot(gxpr_time, insterp_value);
    datetick('x','HH:MM');
    % Check ERP data
    result = checkdata(insterp_value,insterp_min,insterp_max,cap,fileID);
    insterp_result = strcat('insterp........[',result,']\r');
    fprintf(insterp_result);
    fprintf(fileID,insterp_result);
    grid on
    xlabel('TimeStamp')
    ylabel('Instant ERP (dBm)')
    %title({['GXPR Serial Number: ', num2str(gxpr_sn),'     GXPR Bridge Serial Number: ', num2str(bridge_sn)],''})
    title({['GXPR Bridge Serial Number: ', num2str(bridge_sn)],''})
    
    subplot(2,2,2)
    scatter(gxpr_tx_temp, insterp_value);
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('Instant ERP (dBm)')
    title({['Losses(dB):  Cables: ', num2str(cable_loss),', RF Switch: ', num2str(switch_loss),', Attenuators: ', num2str(attenuator_loss)],''})

    % Plot instmtl_value
    subplot(2,2,3)
    plot(gxpr_time, instmtl_value);
    datetick('x','HH:MM');
    % Check ERP data
    result = checkdata(instmtl_value,instmtl_min,instmtl_max,cap,fileID);
    instmtl_result = strcat('instmtl........[',result,']\r');
    fprintf(instmtl_result);
    fprintf(fileID,instmtl_result);
    grid on
    xlabel('TimeStamp')
    ylabel('Instant MTL (dBm)')
    title({gxpr_timestring,'',''})

    subplot(2,2,4)
    scatter(gxpr_tx_temp, instmtl_value);
    grid on
    xlabel('GXPR TX Temperature (k)')
    ylabel('Instant MTL (dBm)')
    title({temp_string1,temp_string2,''});
    
    set(figure(3), 'PaperPosition', [0 0 18 12]);
    set(figure(3)   , 'PaperSize', [40 40]);
    %set(figure(3), 'PaperPosition', [0 0 9 6]);
    %set(figure(3)   , 'PaperSize', [10 10]);
    %saveas(figure(3),strcat(main_dir,num2str(gxpr_sn),'/ERP&MTL.jpg'));
    saveas(figure(3),strcat(main_dir,num2str(bridge_sn_date),'/ERP&MTL.jpg'));
    
    pf_min = 0.900; 
    pf_max = 1.100;

    % Check decoder data
    result = checkdata(decoder_value,pf_min,pf_max,cap,fileID);
    decoder_result = strcat('decoder........[',result,']\r');
    fprintf(decoder_result);
    fprintf(fileID,decoder_result);
    
    % Check timing data
    result = checkdata(timing_value,pf_min,pf_max,cap,fileID);
    timing_result = strcat('timing........[',result,']\r');
    fprintf(timing_result);
    fprintf(fileID,timing_result);
    
    % Check delay data
    result = checkdata(delay_value,pf_min,pf_max,cap,fileID);
    delay_result = strcat('delay........[',result,']\r');
    fprintf(delay_result);
    fprintf(fileID,delay_result);
    
    % Check droop data
    result = checkdata(droop_value,pf_min,pf_max,cap,fileID);
    droop_result = strcat('droop........[',result,']\r');
    fprintf(droop_result);
    fprintf(fileID,droop_result);
    
    % Check reply data
    result = checkdata(reply_value,pf_min,pf_max,cap,fileID);
    reply_result = strcat('reply........[',result,']\r');
    fprintf(reply_result);
    fprintf(fileID,reply_result);
    
    % Check jitter data
    result = checkdata(jitter_value,pf_min,pf_max,cap,fileID);
    jitter_result = strcat('jitter........[',result,']\r');
    fprintf(jitter_result);
    fprintf(fileID,jitter_result);
    
    % Check ratio data
    result = checkdata(ratio_value,pf_min,pf_max,cap,fileID);
    ratio_result = strcat('ratio........[',result,']\r');
    fprintf(ratio_result);
    fprintf(fileID,ratio_result);
    
    % Check sls data
    result = checkdata(sls_value,pf_min,pf_max,cap,fileID);
    sls_result = strcat('sls........[',result,']\r');
    fprintf(sls_result);
    fprintf(fileID,sls_result);
    
    fclose(fileID);
    
    % Copy CSV to folder
    %copyfile(file,strcat(main_dir,num2str(gxpr_sn)))
    copyfile(file,strcat(main_dir,num2str(bridge_sn_date)))
    
    close all
    
end 


