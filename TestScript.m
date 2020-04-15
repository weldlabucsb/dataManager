%% TEST SCRIPT

T = readtable('RunInfoTable.csv','Format',repmat('%s',[1,10]),'TextType','char','Delimiter',',');
citadelDir = '/Volumes/WeldLab';

testRunInfo = RunInfo(T(1,:),citadelDir);

testFnc(1);

if any((testRunInfo.s915LattDepths<1)&(testRunInfo.s915LattDepths>0))
    disp('yo')
end

testTable = testRunInfo.conditionalConstructionTable({'s915LattDepths','0-0.01,0.04','RunFolder','16'});

testStruct = testRunInfo.conditionalInfo({'s915LattDepths','0-0.01,0.04','RunFolder','16788'});

reGenRunInfo = RunInfo(testTable,citadelDir);


thing = split('123,342-400,5452',',');
split(thing{2},'-')


