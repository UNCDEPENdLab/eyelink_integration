function drawfixation(wd, txtsize, bgcol)

%global txtsize wd;
%avoid screen color changes
% Screen('FillRect',wd,ones(1,3)*bgcol(1));
% Screen('Flip',wd)
% 

oldFontSize=Screen(wd, 'TextSize', txtsize +30)%, subject.fixation_fontsize);
DrawFormattedText(wd, '+', 'center', 'center', [0 0 0]);
Screen(wd,'TextSize', oldFontSize);
Screen('Flip', wd);

end