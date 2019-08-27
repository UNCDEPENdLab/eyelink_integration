function sendScreenEL(stim, block, trial, approach, el, wd, width, height, stimondelay, aois, aoi_labs, clear_stim, end_trial)
 id_str=sprintf('%s_%s_%d_%s', stim, block, trial, approach) 
     
 %take screenshot, write, then send to EDF file for data viewer compatibility   
 img=Screen('GetImage', wd, [0 0 1920 1080]);
  
    imwrite(img, sprintf('screenshots/on_%s.jpeg', id_str));
    finfo = imfinfo(sprintf('screenshots/on_%s.jpeg', id_str));
    finfo.Filename;  %just spits out file name, kinda useless 
    %Sends Image to Data Viewer
    Eyelink('Message', '!V IMGLOAD CENTER %s %d %d', finfo.Filename, width/2, height/2);
    
    Eyelink('command', 'ImageTransfer', finfo.Filename)
    WaitSecs(stimondelay)
    
%     if(clear_stim);
%      % Clear the display
%         Screen('FillRect', wd, el.backgroundcolour);
%         Screen('Flip', wd);
%     end
%         %send messages regardless, since the next time we send the screen 
%         if end_trial
%             Eyelink('Message', 'ENDTIME');
%         end
%      Status = Eyelink('ImageTransfer', finfo.Filename);
%          if transferStatus ~= 0
%              fprintf('Image to host transfer failed\n');
%          end
%         WaitSecs(0.1);
       % Eyelink('command', 'draw_box_%d_%d_%d_%d', width/2-50, height/2-50, width/2+50, height/2+50)  
        %%draw areas of interest. Flexible to number of rectangles. Just pass a
    %%n_aoi x 4 double in as aois, make sure aoi_labs== rows of aois (i.e.
    %%number of aois)
    
    dims=size(aois);
    n_aois=dims(1); %number of AOIs we need to draw, should match length of aoi_labs
    %aoi_labs = {'fractal'}

    %N.B. important when only one AOI is being passed in that it is a
    %single-cell array
%     dim_labs = size(aoi_labs);
%     n_labs = dim_labs(1)
    
    status=length(aoi_labs)==n_aois;
    if aois~=0    
    if status ~= 0 
        for aoi=1:n_aois
            these_dims = aois(aoi,:)
            Eyelink('Message', '!V IAREA RECTANGLE %d %d %d %d %d %s', aoi, these_dims(1), these_dims(2), these_dims(3), these_dims(4), aoi_labs{aoi}); 
%             WaitSecs(.1);
%             Eyelink('Message', '%s_%d_%d_%d_%d_%d ', aoi_labs{aoi}, trial, these_dims(1), these_dims(2), these_dims(3), these_dims(4));
            
        end
    else
        error('aois df does not match labels!')
    end
    end
    
%     WaitSecs(.1) 
%     
%     if end_trial;
%         Eyelink('Message', 'TRIAL_RESULT 0')
%         Eyelink('StopRecording');
%     end
      
end

