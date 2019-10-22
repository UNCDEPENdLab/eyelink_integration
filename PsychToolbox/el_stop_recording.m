function el_stop_recording(messages)
% This function stops the collection of eye data from the Eyelink tracker.
% It does not, however, transmit end of trial information. This function is intended to support
% a start/stop recording approach where the eye tracker collects continuously over many trials,
% rather than starting and stopping with each trial. This avoids the ~100ms delay needed with starting
% and stopping, which makes eye-tracking more workable for fMRI (where we don't want timing delays accumulating).
%
%   - messages: optional cell vector of messages to send using Eyelink messaging functionality. Each element 
%        should be a string, which will be passed using Eyelink('Message').
%        Example: {'PIT BLOCK START', 'SUBJECT ID 12'}

el_send_messages(messages); %pass any supplementary messages

% adds 100 msec of data to catch final measurements before closing
WaitSecs(0.1);

%A custom message indicating that we have stopped recording
Eyelink('Message', 'END_RECORDING');

% stop the recording of eye-movements for the current trial
Eyelink('StopRecording');
    
end
