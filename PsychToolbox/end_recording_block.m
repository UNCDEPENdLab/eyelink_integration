
function end_recording_block(outcome, trial_info)

        % display information about what happened during the trial. The
        % argument outcome will denote a task-specific string conveying
        % info on what just happened in the preceding recording block.
         Eyelink('Message', 'TRIAL_OUTCOME %s', outcome);
         WaitSecs(0.1);
       
         if trial_info
         Eyelink('Message', 'TRIAL OK') %valid trial
         else
         %something went wrong, code passed to trial_info should denote the nature of what went wrong if applicable    
         Eyelink('Message', 'TRIAL RESULT %s', trial_info) 
         end
 
        % Clear the display
        Screen('FillRect', wd, el.backgroundcolour);
     	Screen('Flip', wd);
        Eyelink('Message', 'BLANK_SCREEN');
        % adds 100 msec of data to catch final measurements before closing
        WaitSecs(0.1);

        Eyelink('Message', 'END_RECORDING');
        % stop the recording of eye-movements for the current trial
        Eyelink('StopRecording');
end
