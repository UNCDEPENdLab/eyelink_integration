function sendScreenEL(screen_export)
% This function sends information about stimuli being currently presented
% to an .edf file. Also sets up area of interest info for static areas of interest.
%
% There are no outputs per se in this function as this function simply executes a series of commands that embeds task-relevant info into a .edf file.
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


%take screenshot, write, then send to EDF file for data viewer compatibility
img=Screen('GetImage', screen_export{1}, [0 0 screen_export{3} screen_export{4}]);

imwrite(img, sprintf('screenshots/on_%s.jpeg', screen_export{2}));
finfo = imfinfo(sprintf('screenshots/on_%s.jpeg', screen_export{2}));

%finfo.Filename;  %just spits out file name, kinda useless
%Sends Image to Data Viewer
Eyelink('Message', '!V IMGLOAD CENTER %s %d %d', finfo.Filename, screen_export{3}/2, screen_export{4}/2);

Eyelink('command', 'ImageTransfer', finfo.Filename)

%if no AOIs are passed in, just return from the function
if length(screen_export) < 5, return; end

%% create interest area depending on dimensions of input
n_aois=size(screen_export{5}, 1); %number of AOIs we need to draw, should match length of aoi_labs

status = (length(screen_export{6})==n_aois);

if status ~= 0
    for aoi=1:n_aois
        these_dims = screen_export{5}(aoi,:);
        Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', aoi, these_dims(1), these_dims(2), these_dims(3), these_dims(4), screen_export{6}{aoi});
    end
else
    error('aois df length does not match labels!')
end


end
