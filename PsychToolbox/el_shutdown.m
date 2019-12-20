function el_shutdown()
% close data file and shut down tracker
% inspired by: EyelinkPictureCustomCalibration.m
% inspired by: https://psadil.gitlab.io/psadil/post/eyetracking-in-psychtoolbox-oop/

global el;

%only work on shutting down eyetracker if we are eyetracking in the first place (i.e., el is not empty)
if isempty(el), return; end

%Only stop recording and try to receive file if we are connected
connection_status = Eyelink('IsConnected');
if connection_status <= 0
    fprintf('Eyelink is not connected (disconnected or dummy mode).\n');
    Eyelink('Shutdown');
    return;
end

% stop active recording (this should be done trialwise, but we may get here if an error is thrown and recording is ongoing)
% only try to stop recording if recording is in progress (status 0)
recording_status = Eyelink('CheckRecording');
if recording_status == 0
    Eyelink('StopRecording');
    WaitSecs(0.2); % Slack to let stop definitely happen
end

%set to idle mode and wait for mode switch to take effect
%alternative that I think does the same thing: Eyelink('Command', 'set_idle_mode');
Eyelink('SetOfflineMode'); 
WaitSecs(0.2);

Eyelink('CloseFile');
WaitSecs(0.2);

try
    %receive file from eye tracker    
    fprintf('Receiving data file ''%s''\n', el.edf_file);
    
    fulledf = fullfile(pwd, 'eye_data', el.edf_file);
    if exist(fulledf, 'file') == 2
        fprintf('Eye data file already exists: ''%s''\n.  Moving to a backup file!\n', fulledf);
        %move the existing edf file out of the way before transferring eye data
        movefile(fulledf, strrep(fulledf, '.edf', ['_', datestr(now, 'ddmmmyyyy_HHMMSS'), '.edf']));
    end
    
    %put the edf in the current working directory
    status = Eyelink('ReceiveFile', el.edf_file, fullfile(pwd, 'eye_data'), 1);
    WaitSecs(0.2);

    if status > 0, fprintf('ReceiveFile transferred %d bytes\n', status); end
        
    if exist(el.edf_file, 'file') == 2
        fprintf('Data file ''%s'' can be found in ''%s''\n', el.edf_file, pwd);
    end
catch
    fprintf('Problem receiving data file ''%s''\n', el.edf_file);
end

% Shutdown Eyelink:
Eyelink('Shutdown');

end
