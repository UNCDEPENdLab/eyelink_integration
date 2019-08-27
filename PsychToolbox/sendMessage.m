function sendMessage(mess, block, trial, approach, el);
       
        % STEP 7.1 
        % Sending a 'TRIALID' message to mark the start of a trial in Data 
        % Viewer.  This is different than the start of recording message 
        % START that is logged when the trial recording begins. The viewer
        % will not parse any messages, events, or samples, that exist in 
        % the data file prior to this message. 
        Eyelink('Message', '%s_%s_%d_%s', mess, block, trial, approach);

        % This supplies the title at the bottom of the eyetracker display
  %Eyelink('command', 'record_status_message "TRIAL %s %d %s"', block, trial, approach); 
        % Before recording, we place reference graphics on the host display
        % Must be offline to draw to EyeLink screen
        %Eyelink('Command', 'set_idle_mode');
%         % clear tracker display and draw box at center
        %Eyelink('Command', 'clear_screen 0')
        %Eyelink('command', 'draw_box %d %d %d %d 15', width/2-50, height/2-50, width/2+50, height/2+50);
end
