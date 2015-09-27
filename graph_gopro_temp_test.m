function graph_gopro_temp_test(file)

    % User input
    max_channel = 8; % for GoPro channels
    [channel, device2switch] = get_user_input(max_channel);

    % Make dir
    mkdir('gopro_plot')
    main_dir = 'gopro_plot/';

    % Temp Profile 
    cold_temp = -50; 
    ambient_temp = 20;
    hot_temp = 50; 
    soak_time = 10;

    % File Columns
    gopro_ts0_col = 1;
    chamber_temp_col = 2;
    gopro_target_video_on_col = 3;
    gopro_video_on_col = 4;
    gopro_voltage_5v_col = 5;
    gopro_current_5v_col = 6; 
    version_hash__gopro_col = 7; 
    gopro_ts1_col = 36;

    % Limits
    current_cap = 10;
    voltage_cap = 3;
    onoff_cap = 5;
    tolerance = 0.05;
    gopro_current_min = 0.375 * (1 - tolerance*5);
    gopro_current_max = 0.375 * (1 + tolerance*5);
    gopro_voltage_min = 5 * (1 - tolerance);
    gopro_voltage_max = 5 * (1 + tolerance);
    gopro_video_on_min = 1 * (1 - tolerance);
    gopro_video_off_max = 1 * (1 + tolerance);

    % Get row count
    fileID = fopen(file);
    nLines = 0;
    while (fgets(fileID) ~= -1),
      nLines = nLines+1;
    end
    cycle = (nLines-1); 
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
        gopro_target_video_on(i) = str2num(C_data{1,i}{gopro_target_video_on_col,1});
        chamber_temp(i) = str2num(C_data{1,i}{chamber_temp_col,1});
        gopro_ts = textscan(C_data{1,i}{gopro_ts0_col,1},formatSpec,'Delimiter','T');
        gopro_ts_ymd = textscan(gopro_ts{1,1}{1,1},formatSpec,'Delimiter','-');
        gopro_ts_yr(i) = str2num(gopro_ts_ymd{1,1}{1,1});
        gopro_ts_month(i) = str2num(gopro_ts_ymd{1,1}{2,1});
        gopro_ts_day(i) = str2num(gopro_ts_ymd{1,1}{3,1});
        gopro_ts_hms = textscan(gopro_ts{1,1}{2,1},formatSpec,'Delimiter',':');
        gopro_ts_hr(i) = str2num(gopro_ts_hms{1,1}{1,1});
        gopro_ts_min(i) = str2num(gopro_ts_hms{1,1}{2,1});
        gopro_ts_sec(i) = str2num(gopro_ts_hms{1,1}{3,1});

        j = gopro_video_on_col;

        for k = 1:channel

            gopro_video_on(i,k) = str2num(C_data{1,i}{j,1});
            gopro_voltage_5v(i,k) = str2num(C_data{1,i}{j+1,1});
            gopro_current_5v(i,k) = str2num(C_data{1,i}{j+2,1});
            j = gopro_video_on_col + (k*4);

        end
    end 

    fclose(fileID);

    % Make new folder using file name
    input = textscan(file,'%s','Delimiter','.');
    mkdir(strcat(main_dir,input{1}{1}))

    cc = hsv(channel);
    ss = cellstr(['<';'o';'*';'.';'x';'s';'d';'^';'v']);
    sc = cellstr(['-r<';'-go';'-b*';'-c.';'-mx';'-ys';'-bd';'-r^';'-bv']);

    % Get time ticks
    formatin = 'yyyy,mm,dd,HH,MM,SS';
    for i = 1:cycle
        gopro_time(i) = datenum(strcat([num2str(gopro_ts_yr(i)),',',num2str(gopro_ts_month(i)),',',num2str(gopro_ts_day(i)),',',num2str(gopro_ts_hr(i)),',',num2str(gopro_ts_min(i)),',',num2str(round(gopro_ts_sec(i)))]),formatin);
    end 

    % Get gopro time range in string
    gopro_timestring = strcat(['Start Time: ', num2str(gopro_ts_yr(1)), '-', num2str(gopro_ts_month(1)), '-', num2str(gopro_ts_day(1)), '  ',num2str(gopro_ts_hr(1)), ':', num2str(gopro_ts_min(1)),':' , num2str(gopro_ts_sec(1)), '      End Time: ', num2str(gopro_ts_yr(cycle)), '-', num2str(gopro_ts_month(cycle)), '-', num2str(gopro_ts_day(cycle)), '  ', num2str(gopro_ts_hr(cycle)), ':', num2str(gopro_ts_min(cycle)), ':' , num2str(gopro_ts_sec(cycle))]);
    temp_string = strcat(['Cold Start = ', num2str(cold_temp), 'C, Ambient Temp = ', num2str(ambient_temp), 'C, Hot Temp = ', num2str(hot_temp), 'C, Soak Time = ', num2str(soak_time), ' min']);

    % Write results.txt header
    fileID = fopen(strcat(main_dir,input{1}{1},'/results.txt'),'w');
    fprintf(fileID,'GoPro Temperature Testing\r');
    fprintf(fileID,strcat('File:',file,'\r'));
    fprintf(fileID,strcat('Start Time: ', num2str(gopro_ts_yr(1)), '-', num2str(gopro_ts_month(1)), '-', num2str(gopro_ts_day(1)),'-',num2str(gopro_ts_hr(1)), ':', num2str(gopro_ts_min(1)),':' , num2str(gopro_ts_sec(1)), '\r'));
    fprintf(fileID,strcat('End Time: ', num2str(gopro_ts_yr(cycle)), '-', num2str(gopro_ts_month(cycle)), '-', num2str(gopro_ts_day(cycle)),'-', num2str(gopro_ts_hr(cycle)), ':', num2str(gopro_ts_min(cycle)), ':' , num2str(gopro_ts_sec(cycle)),'\r\r'));
    fprintf(fileID,'Temperature Profile:\r');
    fprintf(fileID,strcat('Cold Temperature =  ', num2str(cold_temp), 'C\r'));
    fprintf(fileID,strcat('Ambient Temperature =  ', num2str(ambient_temp), 'C\r'));
    fprintf(fileID,strcat('Hot Temperature =  ', num2str(hot_temp), 'C\r'));
    fprintf(fileID,strcat('Soak Time = ', num2str(soak_time), 'min.\r\r'));
    fprintf(fileID,'UUT Serial Number: \r');
    for i = 1:channel
        fprintf(fileID,strcat('Channel ', num2str(i), ':', num2str(device2switch(i)), '\r')); 
    end 

    figure(1)

    subplot(1,2,1)
    fprintf(fileID,strcat('\r\rA current test will fail if it violates the limits this many times:  ', num2str(current_cap), '\r'));
    for i = 1:channel
        plot(gopro_time, gopro_current_5v(:,i),sc{i})
        datetick('x','HH:MM');
        % Check current data
        result = checkdata(gopro_current_5v(:,i),gopro_current_min,gopro_current_max,current_cap,fileID);
        gopro_current_result = strcat('CH',num2str(i),' gopro_current........[',result,']\r');
        fprintf(gopro_current_result);
        fprintf(fileID,gopro_current_result);
        hold on
    end 
    grid on
    xlabel('TimeStamp')
    ylabel('GoPro Current (A)')
    dynamic_legend(channel,device2switch);
    title({gopro_timestring,''});

    subplot(1,2,2)
    for i = 1:channel
        scatter(chamber_temp, gopro_current_5v(:,i),[],cc(i,:),ss{i})
        hold on
    end 
    grid on
    xlabel('Chamber Temperature (C)')
    ylabel('GoPro Current (A)')
    dynamic_legend(channel,device2switch); 
    title({temp_string,''})

    saveas(figure(1), strcat(main_dir,input{1}{1},'/Current.jpg')); 

    figure(2)

    subplot(1,2,1)
    fprintf(fileID,strcat('\r\rA voltage test will fail if it violates the limits this many times:  ', num2str(voltage_cap), '\r'));
    for i = 1:channel
        plot(gopro_time, gopro_voltage_5v(:,i),sc{i})
        datetick('x','HH:MM');
        % Check voltage data
        result = checkdata(gopro_voltage_5v(:,i),gopro_voltage_min,gopro_voltage_max,voltage_cap,fileID);
        gopro_voltage_result = strcat('CH',num2str(i),' gopro_voltage........[',result,']\r');
        fprintf(gopro_voltage_result);
        fprintf(fileID,gopro_voltage_result);
        hold on
    end 
    grid on
    xlabel('TimeStamp')
    ylabel('GoPro Voltage (V)')
    dynamic_legend(channel,device2switch);
    title({gopro_timestring,''});

    subplot(1,2,2)
    for i = 1:channel
        scatter(chamber_temp, gopro_voltage_5v(:,i),[],cc(i,:),ss{i})
        hold on
    end 
    grid on
    xlabel('Chamber Temperature (C)')
    ylabel('GoPro Voltage (V)')
    dynamic_legend(channel,device2switch); 
    title({temp_string,''})

    saveas(figure(2), strcat(main_dir,input{1}{1},'/Voltage.jpg')); 

    figure(3)

    subplot(1,2,1)
    fprintf(fileID,strcat('\r\rA on/off test will fail if it violates the limits this many times:  ', num2str(onoff_cap), '\r'));
    for i = 1:channel
        plot(gopro_time, gopro_video_on(:,i),sc{i})
        datetick('x','HH:MM');
        % Check voltage data
        result = checkdata(gopro_video_on(:,i),gopro_video_on_min,gopro_video_off_max,onoff_cap,fileID);
        gopro_video_on_result = strcat('CH',num2str(i),' gopro_video_on_........[',result,']\r');
        fprintf(gopro_video_on_result);
        fprintf(fileID,gopro_video_on_result);
        hold on
    end 
    grid on
    xlabel('TimeStamp')
    ylim([0 2]);
    ylabel('Video On = 1,  Video Off = 0')
    dynamic_legend(channel,device2switch);
    title({gopro_timestring,''});

    subplot(1,2,2)
    for i = 1:channel
        scatter(chamber_temp, gopro_video_on(:,i),[],cc(i,:),ss{i})
        hold on
    end 
    grid on
    xlabel('Chamber Temperature (C)')
    ylim([0 2]);
    ylabel('Video On = 1,  Video Off = 0')
    dynamic_legend(channel,device2switch); 
    title({temp_string,''})

    saveas(figure(3), strcat(main_dir,input{1}{1},'/VideoOnOff.jpg')); 

    fclose(fileID);
    
end 

