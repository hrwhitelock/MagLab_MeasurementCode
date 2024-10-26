% Ian Leahy
% April 15, 2018
% Funciton to frame data in a plot nicely. Given plot axes, ha, this
% function searches all the minz and maxz in x or y or both directions,
% then sets the limits to the found value with some user defined
% percentage. pv (percent value) should be between 0 and 1. 

function FramePlot(ha,pv)

ch=ha.Children;


for i=1:length(ch)
    
    if i==1
        x_minval=min(ch(i).XData);
        y_minval=min(ch(i).YData);
        x_maxval=max(ch(i).XData);
        y_maxval=max(ch(i).YData);
    else
        x_minval=min([ch(i).XData,x_minval]);
        y_minval=min([ch(i).YData,y_minval]);
        x_maxval=max([ch(i).XData,x_maxval]);
        y_maxval=max([ch(i).YData,y_maxval]);
    end
    
end
xlim([x_minval*(1-pv) x_maxval*(1+pv)]);
ylim([y_minval*(1-pv) y_maxval*(1+pv)]);

end
