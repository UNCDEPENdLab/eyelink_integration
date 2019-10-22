function el_send_messages(messages)
% pass cell arbitrary vector of messages to Eyelink

if isempty(messages), return; end

if ~iscell(messages), error('messages must be a cell vector'); end

nmessages = length(messages);

for i = 1:nmessages
    %add 5ms delay after every 5 messages to avoid messaging overload
    if i > 1 && mod(i-1, 5) == 0
        WaitSecs(0.005);
        %fprintf('WaitSecs(0.005)\n');
    end
    
    message_value = messages{i};
    if isnumeric(message_value), message_value = num2str(message_value); end
    
    Eyelink('Message', '%s', message_value);
    %fprintf('Message %s\n', message_value);
end

end