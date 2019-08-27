function [el] = EL_startup(window, dummy_mode, edf_name, init_msg, calibration_type, create_file, sample_rate)
% This function initializes a connection with the EyeLink 1000 tracker and 
% gets the PTB environment ready for recording eye position and pupil data.
%
% inputs:
%   - edf_name: filename of EDF file to create. Limit 8 chars. Default: 'eldemo'
%   - init_msg: message to prepend at top of EDF file using add_file_preamble_text
%   - calibration_type: configuration for calibration. Default 'HV9'
%
% output:
%   The function outputs a struct object, 'el', that contains all of the configuration
%   details and the connection details to the eyetracker.
%
% Sources of inspiration:
%   http://download.sr-support.com/dispdoc/simple_template.html
%   http://download.sr-support.com/dispdoc/page8.html
%   https://en.wikibooks.org/wiki/MATLAB_Programming/Psychtoolbox/eyelink_toolbox

if nargin < 1, window=[]; end %window from PTB OpenWindow command
if nargin < 2, dummy_mode=0; end %default to real EyeLink session
if nargin < 3, edf_name='eldemo'; end %default edf_name
if nargin < 4, init_msg=sprintf('EL_setup executed: %s', char(datetime)); end
if nargin < 5, calibration_type='HV9'; end %default to hv9 calibration
if nargin < 6, create_file=true; end %open an edf file on the EyeLink computer
if nargin < 7, sample_rate=1000; end %sampling rate for acquisition
    
default_targets = true; %no alternative at present, but this controls whether to draw calibration targets at custom positions

%address file name length concerns. EL limits to 8 chars since it runs on DOS
edf_name = char(edf_name); %just to make sure it's not a cell
[~, edf_name, ~] = fileparts(edf_name); %strip off path and suffix
if length(edf_name) > 8
    fprintf('edf_name %s > 8 chars Shortening to %s.\n', edf_name, edf_name(1:8));
    edf_name = edf_name(1:8);
end


% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
% make necessary changes to calibration structure parameters and pass
% it to EyelinkUpdateDefaults for changes to take affect
el = EyelinkInitDefaults(window);
el.edf_name=edf_name;
el.init_msg=init_msg;
el.calibration_type=calibration_type;

%pass in ws as argument for window from OpenWindow

% edf 09.19.06: adapted from http://psychtoolbox.org/eyelinktoolbox/EyelinkToolbox.pdf
% and http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html
% (also available in local install at Psychtoolbox/ProgrammingTips.html)

% see also
% Psychtoolbox/PsychHardware/EyelinkToolbox/EyelinkDemos/Short demos/EyelinkExample.m
% which calls some functions that do not work on the windows openGL ptb

%TODO cleanup unused flags here
%doDisplay=1; %use ptb
%mouseInsteadOfGaze=0; %control gaze cursor using mouse instead of gaze (for testing, in case calibration isn't worked out yet)

% STEP 1
% Initialization of the connection with the Eyelink Gazetracker.
% Exit program if this fails.

%add edf suffix back to file
edf_file = [edf_file,'.edf'];

rect=Screen('Rect', window);

el_rect_min_x = rect(RectLeft);
el_rect_max_x = rect(RectRight);
el_rect_min_y = rect(RectTop);
el_rect_max_y = rect(RectBottom);

% TODO: figure out best way for passing in window/msg settings
el.backgroundcolour = BlackIndex(el.window);
el.msgfontcolour  = WhiteIndex(el.window);
el.imgtitlecolour = WhiteIndex(el.window);
el.targetbeep = 0; %don't beep for calibration targets
el.calibrationtargetcolour = WhiteIndex(el.window);

% transmit update settings to EyeLink
EyelinkUpdateDefaults(el);

% Initialization of the connection with the Eyelink
% exit program if this fails.
if ~EyelinkInit(dummy_mode)
    error('Eyelink Init aborted');
end

% make sure that we get gaze data from the Eyelink
% this usually falls here in examples, but below in SP and NH's approach
% Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');

% open EDF file for recording data
if create_file
    status=Eyelink('openfile', edf_file);
    if status~=0
        error('openfile error, status: %d', status)
    end
end

%add header file information
%http://download.sr-support.com/dispdoc/cmds4.html
Eyelink('command', ['add_file_preamble_text ''', init_msg, '''']);

%EyeLink Tracker Configuration: http://download.sr-support.com/dispdoc/simple_template.html
%Set display resolution. Subtract 1 from max x and max y since we have zero-based screen coordinated
Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', el_rect_min_x, el_rect_min_y, el_rect_max_x-1, el_rect_max_y-1);

%Add display resolution to EDF file. Shoudl match screen_pixel_coords exactly
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', el_rect_min_x, el_rect_min_y, el_rect_max_x-1, el_rect_max_y-1);

%%check connection to eyelink
status=Eyelink('IsConnected');
if status==0
    error('could not init connection to Eyelink')
end

%set calibration type
Eyelink('command', ['calibration_type = ', calibration_type]);

% you must send this command with value NO for custom calibration
% you must also reset it to YES for subsequent experiments
if default_targets, Eyelink('command', 'generate_default_targets = YES'); end

%set sampling rate for acquisition
Eyelink('command', 'sample_rate = %d', sample_rate);


%TODO Remove try catch approach
try
    % STEP 2
    % Open a graphics window on the main screen
    % using the PsychToolbox's SCREEN function.
    
    priority = MaxPriority('KbCheck');
    oldPriority = Priority();
    
    
    %N.B. may want to step through and compare code with our implementation
    %earlier in script. for now, assume graphics are set up correctly.
    
    [scrWidth, scrHeight]=Screen('WindowSize', window);
    xRange = [0 scrWidth]; %range of gaze estimates over display, which probably come in terms of the ptb stim display
    yRange = [0 scrHeight];
    
    dotHeight = 7;
    dotWidth = 7;
    
    %     if doDisplay
    %         AssertOpenGL
    %         window = Screen('OpenWindow', screenNum, 0, [], 32, 2);
    %         HideCursor;
    %         Priority(priority);
    %         ifi = Screen('GetFlipInterval', window, 200);
    %         Priority(oldPriority);
    %
    %         white=WhiteIndex(window);
    %         black=BlackIndex(window);
    %
    %         [scrWidth, scrHeight]=Screen('WindowSize', window);
    %
    %         xRange = [0 scrWidth]; %range of gaze estimates over display, which probably come in terms of the ptb stim display
    %         yRange = [0 scrHeight];
    %
    %         dotHeight = 7;
    %         dotWidth = 7;
    %     end
    
    % make sure that we get gaze data from the Eyelink
    %     status=Eyelink('command','link_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT');
    %     if status~=0
    %         error('link_sample_data error, status: ',status)
    %     end
    %     status=Eyelink('command','link_event_filter = LEFT,RIGHT,FIXATION, SACCADE, BLINK, MESSAGE, BUTTON, INPUT');
    %     if status~=0
    %         error('link_sample_data error, status: ',status)
    %     end
    %     status=Eyelink('command','file_sample_data = LEFT,RIGHT,GAZE,AREA,GAZERES,HREF,PUPIL,STATUS,INPUT');
    %     if status~=0
    %         error('link_sample_data error, status: ',status)
    %     end
    
    status=Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
    if status~=0
        error('file_event_filter error, status: ',status)
    end
    status=Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,AREA,GAZERES,STATUS,INPUT,HTARGET');
    if status~=0
        error('file_sample_data error, status: ',status)
    end
    % set link data (used for gaze cursor)
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
    if status~=0
        error('link_event_filter error, status: %d', status)
    end
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
    if status~=0
        error('link_sample_data error, status: %d', status)
    end
    
    % STEP 4
    if doDisplay && strcmp(el.computer,'MAC')==1 % OSX
        % Calibrate the eye tracker using the standard calibration routines
        EyelinkDoTrackerSetup(el); %fails on win, see header comments
        
        % do a final check of calibration using driftcorrection
        EyelinkDoDriftCorrect(el); %fails on win, see header comments
    else
        %         warning('cannot do calibration/drift correction unless on OSX
        %         with an open ptb window')  % this does not appear to be the
        %         case.... unless we're missing something. NH & SP 5/27/19
        EyelinkDoTrackerSetup(el);
        EyelinkDoDriftCorrect(el);
    end
    
    %     % STEP 5
    
    %%%this simply needs to be executed at the time of stimulus presentation
    
    %     % start recording eye position
    %     status=Eyelink('startrecording');
    %     if status~=0
    %         error('startrecording error, status: ',status)
    %     end
    %     % record a few samples before we actually start displaying
    %     WaitSecs(0.1);
    %     % mark zero-plot time in data file
    %     status=Eyelink('message','record_start');
    %     if status~=0
    %         error('message error, status: ',status)
    %     end
    
    stopkey=KbName('space');
    eye_used = -1; %just an initializer to remind us to ask tracker which eye is tracked
    
    %     % STEP 6
    %     % show gaze-dependent display
    %
    %     Priority(priority);
    %     if doDisplay
    %         vbl = Screen('Flip', window); %Initially synchronize with retrace, take base time in vbl
    %     end
    %
    
    %     while 1 % loop till error or space bar is pressed
    %
    %         % Check recording status, stop display if error
    %         err=Eyelink('checkrecording');
    %         if(err~=0)
    %             error('checkrecording problem, status: ',err)
    %             break;
    %         end
    %
    %         % check for presence of a new sample update
    %         status = Eyelink('newfloatsampleavailable');
    %         if  status> 0
    %             % get the sample in the form of an event structure
    %             evt = Eyelink('newestfloatsample');
    %
    %             if textOut
    %                 evt
    %             end
    %
    %             if eye_used ~= -1 % do we know which eye to use yet?
    %                 % if we do, get current gaze position from sample
    %                 x = evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
    %                 y = evt.gy(eye_used+1);
    %
    %                 % do we have valid data and is the pupil visible?
    %                 if (x~=el.MISSING_DATA & y~=el.MISSING_DATA & evt.pa(eye_used+1)>0) || mouseInsteadOfGaze
    %
    %                     if mouseInsteadOfGaze
    %                         if doDisplay
    %                             [x,y,buttons] = GetMouse(window);
    %                         else
    %                             [x,y,buttons] = GetMouse(screenNum);
    %                         end
    %                     else
    %                         x=scrWidth*((x-min(xRange))/range(xRange));
    %                         y=scrHeight*((y-min(yRange))/range(yRange));
    %                     end
    %
    %                     % if data is valid, draw a circle on the screen at current gaze position
    %                     % using PsychToolbox's SCREEN function
    %                     if doDisplay
    %                         gazeRect=[ x-dotWidth/2 y-dotHeight/2 x+dotWidth/2 y+dotHeight/2];
    %                         penSize=6;
    %                         Screen('FrameOval', window, white, gazeRect,penSize,penSize);
    %                     end
    %                 else
    %                     % if data is invalid (e.g. during a blink), clear display
    %                     if doDisplay
    %                         Screen('FillRect', window,black);
    %                     end
    %
    %                     disp('blink! (x or y is missing or pupil size<=0)')
    %                 end
    %
    %                 if doDisplay
    %                     Screen('DrawingFinished', window);
    %                     vbl = Screen('Flip', window, vbl + 0.5*ifi);
    %                 end
    %
    %             else % if we don't, first find eye that's being tracked
    %                 eye_used = Eyelink('eyeavailable'); % get eye that's tracked
    %
    %                 switch eye_used
    %                     case el.BINOCULAR
    %                         disp('tracker indicates binocular, we''ll use right')
    %                         eye_used = el.RIGHT_EYE;
    %                     case el.LEFT_EYE
    %                         disp('tracker indicates left eye')
    %                     case el.RIGHT_EYE
    %                         disp('tracker indicates right eye')
    %                     case -1
    %                         error('eyeavailable returned -1')
    %                     otherwise
    %                         error('uninterpretable result from eyeavailable: ',eye_used)
    %                 end
    %             end
    %         else
    %             disp(sprintf('no sample available, status: %d',status))
    %         end % if sample available
    %
    %         % check for keyboard press
    %         [keyIsDown,secs,keyCode] = KbCheck;
    %         % if spacebar was pressed stop display
    %         if keyCode(stopkey)
    %             break;
    %         end
    %     end % main loop
    
    % wait a while to record a few more samples
    WaitSecs(0.1);
    
catch
    cleanup(create_file, oldPriority, edf_file);
    ers=lasterror
    ers.stack.file
    ers.stack.name
    ers.stack.line
    rethrow(lasterror)
    
    
end

end
