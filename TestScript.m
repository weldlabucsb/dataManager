%% TEST SCRIPT

T = readtable('RunInfoTable.csv','Format',repmat('%s',[1,10]),'TextType','char','Delimiter',',');
citadelDir = '/Volumes/WeldLab';

testRunInfo = RunInfo(T(1,:),citadelDir);

testFnc(1);

if any((testRunInfo.s915LattDepths<1)&(testRunInfo.s915LattDepths>0))
    disp('yo')
end

testTable = testRunInfo.conditionalConstructionTable({'s915LattDepths','0to0.01','RunFolder','16'});

testStruct = testRunInfo.conditionalInfo({'s915LattDepths','0to0.01','RunFolder','16788'});

reGenRunInfo = RunInfo(testTable,citadelDir);

nonZeroSub = testRunInfo.checkForNonZeroSubset({'s915LattDepths','0.008','RunFolder','16'});


testSubRun = RunInfoSubset(testRunInfo,{'s915LattDepths','0to0.01','RunFolder','16'});

array = {testRunInfo,testSubRun};

% testRunData = RunData(testRunInfo);
