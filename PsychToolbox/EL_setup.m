% Short MATLAB example program that uses the Eyelink and Psychophysics
% Toolboxes to create a real-time gaze-dependent display.

% edf 09.19.06: adapted from http://psychtoolbox.org/eyelinktoolbox/EyelinkToolbox.pdf
% and http://www.kyb.tuebingen.mpg.de/bu/people/kleinerm/ptbosx/ptbdocu-1.0.5MK4R1.html
% (also available in local install at Psychtoolbox/ProgrammingTips.html)

% see also
% Psychtoolbox/PsychHardware/EyelinkToolbox/EyelinkDemos/Short demos/EyelinkExample.m
% which calls some functions that do not work on the windows openGL ptb

% note eyelink functions are documented in
% C:\Program Files\SR Research\EyeLink\Docs\*.pdf

%function out = EL_setup(rect, wd)
format longG
KbName('UnifyKeyNames') %enables cross-platform key id's

doDisplay=1; %use ptb
createFile=1; %record eyetracking data on the remote (eyetracking) computer and suck over the file when done
mouseInsteadOfGaze=0; %control gaze cursor using mouse instead of gaze (for testing, in case calibration isn't worked out yet)
textOut=1; %write reports from tracker to stdout

%edfFile='demo.edf'; %name of remote data file to create
screenNum = 1; % use main screen

% STEP 1
% Initialization of the connection with the Eyelink Gazetracker.
% exit program if this fails.

    edf_out = [namestringeye,'.edf'];   

    el_rectx0 = 1920%rect(3);
    el_rectx = 1920%rect(3);
    el_recty0 = 1080%(rect(4));
    el_recty = 1080%(rect(4));
    
    
    if dumm;
        EyelinkInit(1);
        el = EyelinkInitDefaults(wd); % need to look into if any of these need to be changed
    else
        EyelinkInit(0);
        el = EyelinkInitDefaults(wd); % need to look into if any of these need to be changed
    end
    
    
%     el.backgroundcolour = BlackIndex(el.window);
    el.backgroundcolour = bgcol(1);
    el.msgfontcolour  = WhiteIndex(el.window);
    el.imgtitlecolour = WhiteIndex(el.window);
%    el.msgfontcolour  = WhiteIndex(bgcol(1));
%     el.imgtitlecolour = WhiteIndex(bgcol(1));
    el.targetbeep = 0;
%     el.calibrationtargetcolour = WhiteIndex(el.window);
    el.calibrationtargetcolour = bgcol(1);
    
    EyelinkUpdateDefaults(el);
    
    %%%open EDF file to record
    % open file to record data to (just an example, not required)
    if createFile
        status=Eyelink('openfile',edf_out);
        if status~=0
            error('openfile error, status: ',status)
        end
    end

    
    
    %Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', el_rectx0,el_recty0,el_rectx-1, el_recty-1); % 0, 0, SCREEN_X-1, SCREEN_Y-1
    Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0,0,  el_rectx0, el_recty0); % 0, 0, SCREEN_X-1, SCREEN_Y-1
    Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', el_rectx0,el_recty0,el_rectx-1, el_recty-1);
 
    %%check connection to eyelink
 status=Eyelink('IsConnected');
if status==0
    error('could not init connection to Eyelink')
end

try
    % STEP 2
    % Open a graphics window on the main screen
    % using the PsychToolbox's SCREEN function.

    priority = MaxPriority('KbCheck');
    oldPriority = Priority();

    
    %N.B. may want to step through and compare code with our implementation
    %earlier in script. for now, assume graphics are set up correctly.
    
   
    [scrWidth, scrHeight]=Screen('WindowSize', wd);
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

    % STEP 3
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    if doDisplay
        el=EyelinkInitDefaults(wd);
    else
        el=EyelinkInitDefaults();
    end
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
        error('link_event_filter error, status: ',status)
    end
        Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,GAZERES,AREA,STATUS,INPUT,HTARGET');
    if status~=0
        error('link_sample_data error, status: ',status)
    end
    
    % STEP 4
    if doDisplay && strcmp(el.computer,'MAC')==1 % OSX
        % Calibrate the eye tracker using the standard calibration routines
        Eyelink('command', 'calibration_type = HV5')
        EyelinkDoTrackerSetup(el); %fails on win, see header comments
    
        % do a final check of calibration using driftcorrection
        EyelinkDoDriftCorrect(el); %fails on win, see header comments        
    else
%         warning('cannot do calibration/drift correction unless on OSX
%         with an open ptb window')  % this does not appear to be the
%         case.... unless we're missing something. NH & SP 5/27/19
    Eyelink('command', 'calibration_type = HV5')
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
%         vbl = Screen('Flip', wd); %Initially synchronize with retrace, take base time in vbl
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
%                             [x,y,buttons] = GetMouse(wd);
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
%                         Screen('FrameOval', wd, white, gazeRect,penSize,penSize);
%                     end
%                 else
%                     % if data is invalid (e.g. during a blink), clear display
%                     if doDisplay
%                         Screen('FillRect', wd,black);
%                     end
% 
%                     disp('blink! (x or y is missing or pupil size<=0)')
%                 end
% 
%                 if doDisplay
%                     Screen('DrawingFinished', wd);
%                     vbl = Screen('Flip', wd, vbl + 0.5*ifi);
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
    cleanup(createFile, oldPriority, edf_out);
    ers=lasterror
    ers.stack.file
    ers.stack.name
    ers.stack.line
    rethrow(lasterror)

    
end

