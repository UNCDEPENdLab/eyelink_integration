function end_recording_block(outcome, ok, screen_export)

%% passes specific info about what happened during trial (what button
%%pressed, number of button presses, was button press rewarded, was correct
%/incorrect response made, etc.). 

%%The 'outcome' argument should be a trial-specific string with conventions specific to the task being analyzed.  
Eyelink('Message', 'TRIAL_OUTCOME %s', outcome)

%% 'ok' argument should be set to 1 if nothing wrong happened during the block, otherwise ok should be set to a digit representing task-specific error/timeout/etc messages that can be handled on the backend. 
if ok
    Eyelink('Message', 'TRIAL OK')
else
    Eyelink('Message', 'TRIAL RESULT %d', ok)
end

%% Send screen and AOI info (coordinates and labels) to .edf file to be verified in SR data vieweer. 

% screen export should be a cell containing:
% 1. window 
% 2. id_str from the start_block_recording.m function
% 3. Screen width
% 4. Screen height
% 5. AOIs
% 6. AOI labels

sendScreenEL(screen_export)

%% padded stoprecording message
 WaitSecs(.1) 
 Eyelink('StopRecording');
 WaitSecs(.1) 
 
end