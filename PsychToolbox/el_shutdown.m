function el_shutdown()
% close data file and shut down tracker
% inspired by: EyelinkPictureCustomCalibration.m
% inspired by: https://psadil.gitlab.io/psadil/post/eyetracking-in-psychtoolbox-oop/

global el;

%only work on shutting down eyetracker if we are eyetracking in the first place (i.e., el is not empty)
if isempty(el), return; end

% stop active recording (this should be done trialwise, but we may get here if an error is thrown and recording is ongoing)

Eyelink('StopRecording');
WaitSecs(0.2); % Slack to let stop definitely happen

%set to idle mode and wait for mode switch to take effect
%alternative that I think does the same thing: Eyelink('Command', 'set_idle_mode');
Eyelink('SetOfflineMode'); 
WaitSecs(0.2);

Eyelink('CloseFile');
WaitSecs(0.2);

% TODO: Make sure that we can't overwrite and existing file!
try
    %receive file from eye tracker    
    fprintf('Receiving data file ''%s''\n', el.edf_file);
    
    %put the edf in the current working directory
    status = Eyelink('ReceiveFile', el.edf_file, fullfile(pwd, el.edf_file), 1);
    WaitSecs(0.2);

    if status > 0, fprintf('ReceiveFile transferred %d bytes\n', status); end
        
    if 2==exist(el.edf_file, 'file')
        fprintf('Data file ''%s'' can be found in ''%s''\n', el.edf_file, pwd);
    end
catch %#ok<*CTCH>
    fprintf('Problem receiving data file ''%s''\n', el.edf_file);
end

% Shutdown Eyelink:
Eyelink('Shutdown');

end