function el_send_screen(screen_export, send_to_host)
% This function sends information about stimuli being currently presented
% to an .edf file. Also sets up area of interest info for static areas of interest.
%
% There are no outputs of this function. It simply executes a series of commands
% that embeds task-relevant stimulus info into a .edf file and transfers the stimulus
% display to the host PC.
%
% inputs:
%   - screen_export: a 6-element cell array, structured such that
%             {1}: PTB window
%             {2}: a string to identify what is on the screen
%             {3}: width of the screen
%             {4}: height of the screen
%             {5}: aoi coordinates that are stored as an AOIs x 4 matrix. Each row must contain
%                     [x0,y0,x1,y1] coordinates for data viewer to recognize them
%             {6}: aoi labels that are stored in a cell of the same length as {5}
%
%   - send_to_host: a boolean (true/false) indicating whether to transfer the stimulus display
%        to the host PC. This requires the tracker to be in offline/idle mode! Default: false.

if nargin < 2, send_to_host = false; end %whether to send the stimulus image to the host PC

%take screenshot, write, then send to EDF file for data viewer compatibility
%omit rect argument to grab entire window. Otherwise, we only get a partial screen on Retina/high DPI displays
img=Screen('GetImage', screen_export{1}); %, [0 0 screen_export{3} screen_export{4}]);

imwrite(img, sprintf('screenshots/%s.jpg', screen_export{2}));
finfo = imfinfo(sprintf('screenshots/%s.jpg', screen_export{2}));

%Sends image file location to Data Viewer
Eyelink('Message', '!V IMGLOAD CENTER %s %d %d', finfo.Filename, screen_export{3}/2, screen_export{4}/2);

if send_to_host
    % Must be in offline mode to transfer image to Host PC
    % NB. This means we cannot be recording eye data! Thus, to have this work,
    % we would need to transfer the image before start recording, which could work 
    
    Eyelink('Command', 'set_idle_mode');
    % clear tracker display
    Eyelink('Command', 'clear_screen %d', 0);
    
    status = Eyelink('ImageTransfer', finfo.Filename);
    if status ~= 0, fprintf('Image to host transfer failed\n'); end
    
    WaitSecs(0.05);    
end

%if no AOIs are passed in, just return from the function
if length(screen_export) < 5, return; end

%% create interest area depending on dimensions of input
aoi_rects = screen_export{5};

%if aoi_rects is a cell vector (one rect per cell), convert to AOIs x 4 matrix
if iscell(aoi_rects), aoi_rects = vertcat(aoi_rects{:}); end

aoi_labs = screen_export{6};

n_aois=size(aoi_rects, 1); %number of AOIs we need to draw, should match length of aoi_labs
if n_aois ~= length(aoi_labs)
    error('aoi_rects length does not match labels!')
end

if size(aoi_rects, 2) ~= 4
    error('aoi_rects matrix does not have four columns -- invalid rectangle specification?');
end

for aoi=1:n_aois
    these_dims = aoi_rects(aoi,:);
    %fprintf('!V IAREA RECTANGLE %d %d %d %d %d %s\n', aoi, these_dims(1), these_dims(2), these_dims(3), these_dims(4), aoi_labs{aoi});
    Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', aoi, these_dims(1), these_dims(2), these_dims(3), these_dims(4), aoi_labs{aoi});
end


end
