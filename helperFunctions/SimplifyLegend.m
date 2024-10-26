% Ian Leahy
% Function to eliminate certain entries from a legend.
% January 8, 2018

function SimplifyLegend(keepinds)
ax_children=get(gca,'children');
turntheseoff=setdiff(1:length(ax_children),(length(ax_children)+1-keepinds));
for i=1:length(turntheseoff)
    set(get(get(ax_children(turntheseoff(i)),'Annotation')','LegendInformation'),'IconDisplayStyle','off')
end
legend('off'); legend('show');
end


