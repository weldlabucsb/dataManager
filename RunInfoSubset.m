classdef RunInfoSubset<RunInfo
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fullRunInfo
    end
    
    methods
        function obj = RunInfoSubset(runInfo,conditions)
            %Generate an object of run info for the subclass
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

