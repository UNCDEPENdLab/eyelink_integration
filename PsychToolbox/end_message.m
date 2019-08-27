
function end_message(block, trial, approach, el, wd);

%         Eyelink('Message', sprintf('End_trial_%s_%d_%s', block, trial, approach));
        
        % Send an integration message so that an image can be loaded as 
        % overlay backgound when performing Data Viewer analysis.  This 
        % message can be placed anywhere within the scope of a trial (i.e.,
        % after the 'TRIALID' message and before 'TRIAL_RESULT')
        % See "Protocol for EyeLink Data to Viewer Integration -> Image 
        % Commands" section of the EyeLink Data Viewer User Manual.
%       Eyelink('Message', '!V IMGLOAD CENTER %s %d %d', finfo.Filename, width/2, height/2); 
%       Eyelink('command', 'ImageTransfer', finfo.Filename)     
%         stopkey=KbName('space');
%  
        
%         
        % STEP 7.6
        % Clear the display
        Screen('FillRect', wd, el.backgroundcolour);
     	Screen('Flip', wd);
        Eyelink('Message', 'BLANK_SCREEN');
        % adds 100 msec of data to catch final events
        WaitSecs(0.1);
%         Eyelink('Message', 'TRIAL_RESULT 0')
        
        % stop the recording of eye-movements for the current trial
        Eyelink('StopRecording');
end
%         
%         
%         % STEP 7.7
%         % Send out necessary integration messages for data analysis
%         % Send out interest area information for the trial
%         % See "Protocol for EyeLink Data to Viewer Integration-> Interest 
%         % Area Commands" section of the EyeLink Data Viewer User Manual
%         % IMPORTANT! Don't send too many messages in a very short period of
%         % time or the EyeLink tracker may not be able to write them all 
%         % to the EDF file.
%         % Consider adding a short delay every few messages.
% 
%         % Please note that  floor(A) is used to round A to the nearest
%         % integers less than or equal to A
% 
%         WaitSecs(0.001);
%         Eyelink('Message', '!V IAREA ELLIPSE %d %d %d %d %d %s', 1, floor(width/2)-50, floor(height/2)-50, floor(width/2)+50, floor(height/2)+50,'center');
%         Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 2, floor(width/4)-50, floor(height/2)-50, floor(width/4)+50, floor(height/2)+50,'left');
%         Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 3, floor(3*width/4)-50, floor(height/2)-50, floor(3*width/4)+50, floor(height/2)+50,'right');
%         Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 4, floor(width/2)-50, floor(height/4)-50, floor(width/2)+50, floor(height/4)+50,'up');
%         Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', 5, floor(width/2)-50, floor(3*height/4)-50, floor(width/2)+50, floor(3*height/4)+50,'down');
% 
% 
%         % Send messages to report trial condition information
%         % Each message may be a pair of trial condition variable and its
%         % corresponding value follwing the '!V TRIAL_VAR' token message
%         % See "Protocol for EyeLink Data to Viewer Integration-> Trial
%         % Message Commands" section of the EyeLink Data Viewer User Manual
%         WaitSecs(0.001);
%         Eyelink('Message', '!V TRIAL_VAR index %d', i)        
%         Eyelink('Message', '!V TRIAL_VAR imgfile %s', imgfile)               
%         
%         % STEP 7.8
%         % Sending a 'TRIAL_RESULT' message to mark the end of a trial in 
%         % Data Viewer. This is different than the end of recording message 
%         % END that is logged when the trial recording ends. The viewer will
%         % not parse any messages, events, or samples that exist in the data 
%         % file after this message.
        %Eyelink('Message', 'TRIAL_RESULT 0')