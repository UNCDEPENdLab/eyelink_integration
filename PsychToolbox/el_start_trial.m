function [id_str] = el_start_trial(super, trial, block, stim, custom, start_recording, messages, trial_var)
% This recording TRIALID scheme follows the Lab Eyelink Message Conventions document
%
% inputs:
%   - super:  this should correspond to the superordinate structure of the task being administered.
%             For example, different blocked conditions in an fMRI study (e.g., low working memory load
%             block versus high load block). More generally, this field denote trials grouping at the highest 
%             level such as instrumental, pavlovian, and pit in a three-phase PIT paradigm.
%   - trial:  this number denotes the repetition of the super (condition) currently being run.
%   - block:  this is a number enumerating the sub-part of the trial. The use of 'block' in Eyelink conventions
%             is a bit peculiar, but it basically refers to sub-parts of a given trial that should be marked 
%             separately. For example, in a single trial, we might have cue (1), anticipation (2), and outcome (3)
%             blocks that should be marked individually in the EDF file.
%   - stim:   this is a string denoting what stimulus is displayed on the screen. It could be a general description of,
%             or elaboration on, the block (e.g., 'pavcue') or could be more specific (e.g., 'pavcue_12_red').
%   - custom: (optional) argument allowing any other string to be tacked onto the message for later parsing
%   - start_recording: boolean (true/false) indicating whether to start recording eye samples as part of the trial
%             initiation. This will add 100ms of timing delay to prevent samples from being missed.
%   - trial_var: (optional) cell vector used to transmit trial details to Data Viewer via TRIAL_VAR messages.
%                This argument should contain paired strings, alternating between trial_var names and values.
%                Example: {'var1', '20', 'var2', 'hello'}
%
%   Example:
%      el_start_trial('insphase', 1, 2, 'cueon', 'custominfohere', true); %begin trial and start eye recording
%
%   Example with trial_var messages:
%      el_start_trial('insphase', 1, 2, 'cueon', 'custominfohere', true, [], {'trialvar_msg1', 'cue_display'});
% 
%   Example in which we assume eye recording is handled upstream, and with messages and trial_var messages:
%      el_start_trial('pitphase', 1, 2, 'feedback', 'custominfohere', false, {'message 1 is here'}, {'trial_varmsg2', 'feedback_display'});


if nargin < 6, start_recording = true; end % default to passing the StartRecording command

if ~isnumeric(trial), error('in start_recording_block, trial must be a number'); end
if ~isnumeric(block), error('in start_recording_block, block must be a number'); end

if isnumeric(super),  super=num2str(super); end   % to ensure that sprintf gives the right result for numeric super
if isnumeric(stim),   stim=num2str(stim);   end   % to ensure that sprintf gives the right result for numeric stim

super = strrep(super, '_', '-'); %replace any underscores with hyphens in the super so that it doesn't break split on underscore convention
stim  = strrep(stim,  '_', '-'); %replace any underscores with hyphens in the stimulus so that it doesn't break split on underscore convention

if nargin < 5 || isempty(custom)
    id_str=sprintf('%s_%d_%d_%s', super, trial, block, stim);
else
    if isnumeric(custom), custom=num2str(custom); end % to ensure that sprintf gives the right result for numeric custom
    custom = strrep(custom,  '_', '-'); %replace any underscores with hyphens in the custom so that it doesn't break underscore convention
    id_str=sprintf('%s_%d_%d_%s_%s', super, trial, block, stim, custom);
end

%add the trial ID to the EDF file for later parsing
Eyelink('Message', 'TRIALID %s', id_str);

%send the trial info to the tracker for display on the Host PC (in Eyelink window)
%this helps the RA monitor experiment progress
Eyelink('command', 'record_status_message "TRIAL %s"', id_str);

el_send_messages(messages); %pass supplementary messages

% Whether we start recording of eye data, or leave this to a superordinate function.
% Using start_recording is useful here if we plan to start and stop on every trial, which
% allows drift corrects to be added after each trial. On the other hand, if we need to 
% minimize timing delays (e.g., in fMRI), it is preferable to start/stop recording at the block level
% (outside of the trial loop), and then pass messages for each trial

if start_recording
    
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
    if status~=0, error('startrecording error, status: %d', status); end
    
    WaitSecs(0.1); %wait 100ms after we start recording so we don't lose samples
    
end

% mark zero-plot time in data file
% TODO: unify use of this call with DISPLAY ON
Eyelink('Message', 'SYNCTIME');

% Optional: tag trial with various attributes in Data Viewer
% Send messages to report trial condition information
% Each message may be a pair of trial condition variable and its
% corresponding value follwing the '!V TRIAL_VAR' token message
% See "Protocol for EyeLink Data to Viewer Integration -> Trial
% Message Commands" section of the EyeLink Data Viewer User Manual

if ~isempty(trial_var)
    if ~iscell(trial_var), error('trial_var must be a cell vector'); end
    if mod(length(trial_var), 2) ~= 0, error('trial_var must be even in length'); end
    
    nmessages = length(trial_var)/2;
    nremaining = nmessages;
    i = 1;
    while nremaining > 0
        %add 5ms delay after every 5 messages to avoid messaging overload
        if i > 1 && mod(i-1, 10) == 0 && nremaining > 1
            WaitSecs(0.005); 
            %fprintf('WaitSecs(0.005)\n'); 
        end
        
        message_name = trial_var{i};
        
        message_value = trial_var{i+1};
        if isnumeric(message_value), message_value = num2str(message_value); end
        
        Eyelink('Message', '!V TRIAL_VAR %s %s', message_name, message_value);
        %fprintf('Message !V TRIAL_VAR %s %s\n', message_name, message_value);
       
        nremaining = nremaining - 1;
        i = i + 2; %increment counter
        
    end
end


end
