
KbName('UnifyKeyNames'); %not sure if this is needed right now...

el_rectx0 = rect(3);
el_rectx = rect(3);
el_recty0 = (rect(4));
el_recty = (rect(4));
    
    EyelinkInit(0);
el = EyelinkInitDefaults(wd); % need to look into if any of these need to be changed

Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', el_rectx0,el_recty0,el_rectx-1, el_recty-1); % 0, 0, SCREEN_X-1, SCREEN_Y-1
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', el_rectx0,el_recty0,el_rectx-1, el_recty-1);

%open file to record data to
Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA') 
edf_out = [namestringeye,'.edf']
Eyelink('openfile', edf_out);

%setup tracker and calibrate, including drift correction
%Eyelink('trackersetup');
EyelinkDoTrackerSetup(el);

Eyelink('dodriftcorrect');

Eyelink('startrecording');
WaitSecs(0.1);
Eyelink('message', 'SYNCTIME');
stopkey = KbName('space');
eye_used = -1;

%%add step 6 stuff from the cornellison paper
% priority = MaxPriority('KbCheck');
% 
%   Priority(priority);
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
% 
%     % wait a while to record a few more samples
%     WaitSecs(0.1);
