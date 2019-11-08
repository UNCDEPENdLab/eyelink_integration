function el_start_recording(messages)
% This function starts the collection of eye data from the Eyelink tracker.
% It does not, however, transmit trial-related information. This function is intended to support
% a start/stop recording approach where the eye tracker collects continuously over many trials,
% rather than starting and stopping with each trial. This avoids the ~100ms delay needed with starting
% and stopping, which makes eye-tracking more workable for fMRI (where we don't want timing delays accumulating).
% 
% inputs:
%   - messages: optional cell vector of messages to send using Eyelink messaging functionality. Each element 
%        should be a string, which will be passed using Eyelink('Message').
%        Example: {'PIT BLOCK START', 'SUBJECT ID 12'}
%
%   Example:
%      el_start_recording({'PIT BLOCK START', 'SUBJECT ID 12'});
%

% http://download.sr-support.com/dispdoc/simple_template.html
% Must be offline/idle mode to draw to Eyelink screen
Eyelink('command', 'set_idle_mode');

% current SR recommendation is to wait briefly after mode switch before StartRecording
% https://www.sr-support.com/forum/eyelink/programming/52412-issues-about-startrecording-and-stoprecording
WaitSecs(0.05);

% clear host PC screen to black (0)
Eyelink('command', 'clear_screen 0');

% begin acquiring eye data
status=Eyelink('StartRecording');
if status ~= 0, error('startrecording error, status: %d', status); end

WaitSecs(0.1); %wait 100ms after we start recording so we don't lose samples

% Pass any supplementary messages. These should come after recording starts for data viewer to see them consistently
el_send_messages(messages); 

end
