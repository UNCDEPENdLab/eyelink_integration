
function end_recording_block(outcome, trial_info, wd, el, progress_block)
% Finalizes a recording block and conveys task-relevant information about
% what happened during the recording block of interest.
% 
%
% inputs:
%   - outcome: task-specific code that denotes what happened during the
%   trial (e.g. 0_1 could denote that an incorrect stimulus was chosen (0) yet )


        if nargin < 5, progress_block=1; end
        
        %read in global variables
        global block; 
%         global el;
%         global wd;
        %update: 8/30: though it is a bit clunky, seems more flexible to
        %include these as arguments rather than global variables, this
        %allows the user to name the PTB window and the eye;link variable
        %whatever works best for them.
         
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
        
        if progress_block, block = block + 1; end
end
