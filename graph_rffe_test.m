function graph_rffe_test(file)

    % Make dir
    mkdir('rffe_plot')
    main_dir = 'rffe_plot/';

    % File Columns
    rffe_ts_col = 1;
    rffe_ch_col = 2;
    rffe_current_col = 3;
    rffe_voltage_col = 4;
    rffe_result_col = 5;

    % Get row count
    fileID = fopen(file);
    nLines = 0;
    while (fgets(fileID) ~= -1),
      nLines = nLines+1;
    end
    cycle = (nLines-1) - 3; % take out the other 3 channel data 
    fclose(fileID); 

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
        rffe_ch(i) = str2num(C_data{1,i}{rffe_ch_col,1});
        rffe_current(i) = str2num(C_data{1,i}{rffe_current_col,1});
        rffe_voltage(i) = str2num(C_data{1,i}{rffe_voltage_col,1});
        %rffe_result(i) = str2num(C_data{1,i}{rffe_result_col,1});
        rffe_ts = textscan(C_data{1,i}{rffe_ts_col,1},formatSpec,'Delimiter','T');
        rffe_ts_ymd = textscan(rffe_ts{1,1}{1,1},formatSpec,'Delimiter','-');
        rffe_ts_yr(i) = str2num(rffe_ts_ymd{1,1}{1,1});
        rffe_ts_month(i) = str2num(rffe_ts_ymd{1,1}{2,1});
        rffe_ts_day(i) = str2num(rffe_ts_ymd{1,1}{3,1});
        rffe_ts_hms = textscan(rffe_ts{1,1}{2,1},formatSpec,'Delimiter',':');
        rffe_ts_hr(i) = str2num(rffe_ts_hms{1,1}{1,1});
        rffe_ts_min(i) = str2num(rffe_ts_hms{1,1}{2,1});
        rffe_ts_sec(i) = str2num(rffe_ts_hms{1,1}{3,1});
        
    end 

    fclose(fileID);

    % Make new folder using file name
    input = textscan(file,'%s','Delimiter','.');
    mkdir(strcat(main_dir,input{1}{1}))

    % Get time ticks
    formatin = 'yyyy,mm,dd,HH,MM,SS';
    for i = 1:cycle
        rffe_time(i) = datenum(strcat([num2str(rffe_ts_yr(i)),',',num2str(rffe_ts_month(i)),',',num2str(rffe_ts_day(i)),',',num2str(rffe_ts_hr(i)),',',num2str(rffe_ts_min(i)),',',num2str(round(rffe_ts_sec(i)))]),formatin);
    end 

    % Get rffe time range in string
    %rffe_timestring = strcat(['Start Time: ', num2str(rffe_ts_yr(1)), '-', num2str(rffe_ts_month(1)), '-', num2str(rffe_ts_day(1)), '  ',num2str(rffe_ts_hr(1)), ':', num2str(rffe_ts_min(1)),':' , num2str(rffe_ts_sec(1)), '      End Time: ', num2str(rffe_ts_yr(cycle)), '-', num2str(rffe_ts_month(cycle)), '-', num2str(rffe_ts_day(cycle)), '  ', num2str(rffe_ts_hr(cycle)), ':', num2str(rffe_ts_min(cycle)), ':' , num2str(rffe_ts_sec(cycle))]);
    %temp_string = strcat(['Cold Start = ', num2str(cold_temp), 'C, Ambient Temp = ', num2str(ambient_temp), 'C, Hot Temp = ', num2str(hot_temp), 'C, Soak Time = ', num2str(soak_time), ' min']);

    figure(1)

    subplot(1,2,1)
  
    plot(rffe_time, rffe_current)
    datetick('x','HH:MM:SS');
    grid on
    xlabel('TimeStamp')
    ylabel('RFFE Current (A)')
    
    subplot(1,2,2)
  
    plot(rffe_time, rffe_voltage)
    datetick('x','HH:MM:SS');
    grid on
    xlabel('TimeStamp')
    ylabel('RFFE Voltage (V)')
    

end 