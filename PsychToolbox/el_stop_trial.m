function el_stop_trial(outcome, trial_info, wd, el, clear_display, stop_recording, messages, progress_block)
% Finalizes a recording block and conveys task-relevant information about
% what happened during the recording block of interest.
%
%
% inputs:
%   - outcome: task-specific code that denotes what happened during the
%       trial (e.g. 0_1 could denote that an incorrect stimulus was chosen (0)
%   - trial_info: A numeric code indicating the outcome of the trial. A value of 1 will result in a TRIAL OK message.
%       Any other value will result in a TRIAL RESULT <trial_info> message.
%   - wd: the handle to the PTB window
%   - el: the eyelink object created by el_startup
%   - clear_display: a boolean (true/false) indicating whether clear the screen and send a BLANK_SCREEN message.
%       Default: true
%   - stop_recording: a boolean (true/false) indicating whether to stop recording eye data after sending trial outcome
%       info. Default: true.
%   - progress_block: a boolean (true/false) used for global incrementing? (not sure what this does)

if nargin < 5, clear_display = true; end
if nargin < 6, stop_recording = true; end %default not to stopping the eye position recording
if nargin < 8, progress_block = true; end %not sure what this does

%read in global variables
global block;

if isempty(el), return; end %don't even run this function if we have no el structure setup

el_send_messages(messages); %pass any supplementary messages

% display information about what happened during the trial. The
% argument outcome will denote a task-specific string conveying
% info on what just happened in the preceding recording block.
Eyelink('Message', 'TRIAL_OUTCOME %s', outcome);

% Clear the display
if clear_display
    Screen('FillRect', wd, el.backgroundcolour);
    Screen('Flip', wd);
    
    Eyelink('Message', 'BLANK_SCREEN');
end

if stop_recording
    % adds 100 msec of data to catch final measurements before closing
    WaitSecs(0.1);

    %A custom message indicating that we have stopped recording
    Eyelink('Message', 'END_RECORDING');
    
    % stop the recording of eye-movements for the current trial
    Eyelink('StopRecording');
    
end

% Convey terminal message for trial to let data viewer know how to carve up trial data and messages.
% TRIAL OK or TRIAL_RESULT messages mark the end of a trial in Data Viewer. This is different than 
% the end of recording message END that is logged when the trial recording ends. The viewer will
% not parse any messages, events, or samples that exist in the data file after this message.

if trial_info == 1
    Eyelink('Message', 'TRIAL OK'); %valid trial
else
    %something went wrong, code passed to trial_info should denote the nature of what went wrong if applicable
    Eyelink('Message', 'TRIAL_RESULT %s', num2str(trial_info));
end

if progress_block, block = block + 1; end

end
