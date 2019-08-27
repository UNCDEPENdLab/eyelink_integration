function [x,y] = display_fix(rect, wd)
% Draw to the external screen if avaliable
% screenNumber = max(screens);
%
% % Define black and white
% white = WhiteIndex(screenNumber);
% black = BlackIndex(screenNumber);

white =1;

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(rect);

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', wd, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);

% Flip to the screen
Screen('Flip', wd);

WaitSecs(.5)


end