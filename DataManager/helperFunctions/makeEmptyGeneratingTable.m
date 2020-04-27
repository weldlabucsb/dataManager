function outTable = makeEmptyGeneratingTable()
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    tableElements = {'Year','Month','Day','SeriesID','RunType','RunFolder','Comments'};
    outTable=table('Size',size(tableElements),...
        'VariableType',repelem({'cellstr'},length(tableElements)),...
        'VariableNames',tableElements);
end

