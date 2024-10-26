% Ian Leahy
% Function to Rotate a y-label easily.
% Sept 10, 2018

% Input a set of axes.
function Rotate_YLabel(inax)
ylp = get(inax.YLabel, 'Position');
ext=get(inax.YLabel,'Extent');
set(inax.YLabel, 'Rotation',270, 'Position',ylp+[ext(3) 0 0]);
end
