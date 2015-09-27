function [channel,sn_channel] = get_user_input(max_ch)

    prompt = 'How many UUTs were connected during testing? ';
    channel = input(prompt);
    while (channel > max_ch) || (channel == 0)
        prompt = ['Exceeded UUT limitation. Please enter a valid number between 1-', num2str(max_ch),': '];
        channel = input(prompt);
    end
    for i = 1:channel
        prompt = ['What is the UUT serial number for CH ', num2str(i), '? '];
        sn_channel(i) = input(prompt); 
    end 

end 