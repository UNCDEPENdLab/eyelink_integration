function [id_str] = start_recording_block(super, trial, block, stim, custom)

if nargin < 5 || isempty(custom);
    id_str=sprintf('%s_%d_%d_%s', super, trial, block, stim);
else
    id_str=sprintf('%s_%d_%d_%s_%s', super, trial, block,stim, custom);
end
 
%  sendMessage('TRIALID shroom_on', 'ins', nt, approach_str, el)
EyeLink('Message', 'TRIALID %s', id_str)

Eyelink('command', 'record_status_message "TRIAL %s"', id_str);

Eyelink('command', 'set_idle_mode');
Eyelink('command', 'clear_screen_%d',0);

status=Eyelink('StartRecording');
    if status~=0
        error('startrecording error, status: ',status)
    end
    
    % mark zero-plot time in data file
    Eyelink('Message', 'SYNCTIME');
  WaitSecs(.1)
end