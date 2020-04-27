function outCell = convertNumArray2CellString(numArray,delimiter)
    if nargin<2
        delimiter=';';
    end
    
    cellString = '';
    if ~isempty(numArray)
        cellString = num2str(numArray(1));
    end
    for ii=2:length(numArray)
        cellString = [cellString delimiter num2str(numArray(ii))];
    end
    outCell = {cellString};
end
