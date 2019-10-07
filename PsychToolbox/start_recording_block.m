function [id_str] = start_recording_block(super, trial, block, stim, custom)
% This recording TRIALID scheme follows the Lab Eyelink Message Conventions document
%
% inputs:
%   - super:  this should correspond to the superordinate structure of the task being administered.
%             For example, different blocked conditions in an fMRI study (e.g., low working memory load
%             block versus high load block). More generally, this field denote trials grouping at the highest 
%             level such as instrumental, pavlovian, and pit in a three-phase PIT paradigm.
%   - trial:  this number denotes the repetition of the super (condition) currently being run.
%   - block:  this is a number enumerating the sub-part of the trial. The use of 'block' in EyeLink conventions
%             is a bit peculiar, but it basically refers to sub-parts of a given trial that should be marked 
%             separately. For example, in a single trial, we might have cue (1), anticipation (2), and outcome (3)
%             blocks that should be marked individually in the EDF file.
%   - stim:   this is a string denoting what stimulus is displayed on the screen. It could be a general description of,
%             or elaboration on, the block (e.g., 'pavcue') or could be more specific (e.g., 'pavcue_12_red').
%   - custom: (optional) argument allowing any other string to be tacked onto the message for later parsing
%
%   Example:
%      start_recording_block('insphase', 1, 2, 'cueon', 'custominfohere');

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
EyeLink('Message', 'TRIALID %s', id_str);

%send the trial info to the tracker for display on the Host PC (in EyeLink window)
%this helps the RA monitor experiment progress
Eyelink('command', 'record_status_message "TRIAL %s"', id_str);

% http://download.sr-support.com/dispdoc/simple_template.html
% Must be offline/idle mode to draw to EyeLink screen
Eyelink('command', 'set_idle_mode');

% clear host PC screen to black (0)
Eyelink('command', 'clear_screen 0');

% begin acquiring eye data
status=Eyelink('StartRecording');
if status~=0, error('startrecording error, status: %d', status); end

WaitSecs(0.1); %wait 100ms after we start recording so we don't lose samples

% mark zero-plot time in data file
Eyelink('Message', 'SYNCTIME');

end
