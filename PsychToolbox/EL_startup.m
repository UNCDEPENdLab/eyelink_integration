function [el] = EL_startup(window, dummy_mode, edf_file, init_msg, calibration_type, create_file, sample_rate, run_calibration)
% This function initializes a connection with the EyeLink 1000 tracker and
% gets the PTB environment ready for recording eye position and pupil data.
%
% inputs:
%   - edf_file: filename of EDF file to create. Limit 8 chars. Default: 'eldemo'
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
if nargin < 3, edf_file='eldemo'; end %default edf_file
if nargin < 4, init_msg=sprintf('EL_setup executed: %s', char(datetime)); end
if nargin < 5, calibration_type='HV9'; end %default to hv9 calibration
if nargin < 6, create_file=true; end %open an edf file on the EyeLink computer
if nargin < 7, sample_rate=1000; end %sampling rate for acquisition
if nargin < 8, run_calibration=true; end %whether to run calibration step after initialization

default_targets = true; %no alternative at present, but this controls whether to draw calibration targets at custom positions

%address file name length concerns. EL limits to 8 chars since it runs on DOS
edf_file = char(edf_file); %just to make sure it's not a cell
[~, edf_file, ~] = fileparts(edf_file); %strip off path and suffix
if length(edf_file) > 8
    fprintf('edf_file %s > 8 chars Shortening to %s.\n', edf_file, edf_file(1:8));
    edf_file = edf_file(1:8);
end

% Provide Eyelink with details about the graphics environment
% and perform some initializations. The information is returned
% in a structure that also contains useful defaults
% and control codes (e.g. tracker state bit and Eyelink key values).
% make necessary changes to calibration structure parameters and pass
% it to EyelinkUpdateDefaults for changes to take affect
el = EyelinkInitDefaults(window);

%populate a few supplemental fields of the el structure for our purposes
el.edf_file=edf_file;
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

%TODO try to make sure that we use the window's background and color scheme in the el color fields
%suggestion from here: https://psadil.gitlab.io/psadil/post/eyetracking-init/
% Use the PTB window to define these feature in EL
% override default gray background of eyelink, otherwise runs end
% up gray! also, probably best to calibrate with same colors of
% background / stimuli as participant will encounter
el.backgroundcolour = BlackIndex(el.window);
el.foregroundcolour = WhiteIndex(el.window);
el.msgfontcolour  = WhiteIndex(el.window);
el.imgtitlecolour = WhiteIndex(el.window);
el.calibrationtargetcolour = WhiteIndex(el.window);

el.targetbeep = 0; %don't beep for calibration targets

% transmit update settings to EyeLink
EyelinkUpdateDefaults(el);

% Initialization of the connection with the Eyelink
% exit program if this fails.
if ~EyelinkInit(dummy_mode)
    error('Eyelink Init aborted');
end

%we could use these commands to reduce the FOV for calibration/validation if the extremes of the screen are not needed
%Eyelink('command','calibration_area_proportion = 0.5 0.5');
%Eyelink('command','validation_area_proportion = 0.48 0.48');

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
if status ~= 1, error('could not init connection to Eyelink'); end

%set calibration type
Eyelink('command', ['calibration_type = ', calibration_type]);

% you must send this command with value NO for custom calibration
% you must also reset it to YES for subsequent experiments
if default_targets, Eyelink('command', 'generate_default_targets = YES'); end

%set sampling rate for acquisition
Eyelink('command', 'sample_rate = %d', sample_rate);

% set link data (used for gaze cursor)
status = Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,INPUT');
if status~=0, error('file_event_filter error, status: %d',status); end

status = Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON,FIXUPDATE,INPUT');
if status~=0, error('link_event_filter error, status: %d', status); end

%set EDF file contents using file_sample_data and file_event_filter
status = Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,HREF,GAZERES,AREA,HTARGET,STATUS,INPUT');
if status~=0, error('file_sample_data error, status: %d',status); end

status = Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,HREF,GAZERES,AREA,HTARGET,STATUS,INPUT');
if status~=0, error('link_sample_data error, status: %d', status); end

if run_calibration
    % Calibrate the eye tracker using the standard calibration routines
    EyelinkDoTrackerSetup(el);
    
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrect(el);
end

end
