# DataManager

## Getting Started
1. Clone this repository to your local machine, then add the DataManager folder to your MatLab path.
2. Run "autoLibGen" from the MatLab command line and follow the instructions to generate a RunDataLibrary.
    - Once you've chosen the dates in autoLibGen, click the checkboxes of the runs you'd like to load.
        - It is recommended that you do this __once__ for all the data that you might like to work with, as it can be a bit cumbersome sorting through so many runs more than a few times. Sorting this afterward is made much easier by the selectRuns app included with [DataAnalysis](https://github.com/weldlabucsb/DataAnalysis).
    - It is recommended that you __do not change__ the "Include Vars" and "Exclude Vars" fields until you familiarize yourself with how library construction works. See the next section for directions on how to learn about library generation.
    - To allow multiple checkboxes to be checked at once is apparently nontrivial. The workaround to toggle ranges of checkboxes is as follows:
        - Click on the __border__ around the checkbox at the beginning of a range you'd like to select. The box will now be highlighted blue.
            - Note: clicking the run titles to highlight rows also works, and may be easier.
        - While holding shift, click on the border around the checkbox at the end of the range you'd like to select. The entire range you are trying to select should now be highlighted blue.
        - Click the "Switch All Highlighted Entries" button. This will toggle all of the checkboxes in the selected range to the __opposite value of the first checkbox you clicked__.
3. Poke around at the structure of the RunDataLibrary, accessing its fields like a struct: myRunDataLib.fieldname. Key notes:
    - RunDatas contains a list of RunData objects. These have all the information about a particular run corresponding to one atomdata.
    - The atomdata for each run is contained in each RunData object as RunData.Atomdata (note capitalization!).
    - Each RunData has a struct attached, RunData.vars. This contains a list of variables from the atomdata within. You can likely save yourself some time (and array"fun") by using the variable values here, rather than pulling them from atomdata.
    - The RunData.RunID is a unique identifier for that run. The RunDataLibrary contains the full list of RunIDs under RunDataLibrary.RunIDs.

To make your life easier dealing with RunData objects, see [the DataAnalysis repo](https://github.com/weldlabucsb/DataAnalysis).

## About DataManager
DataManager includes a number of classes which make dealing with atomdatas much less painful. Their structure, discussed in the previous section, should be enough to get you started once you have a RunDataLibrary to work with.

It is highly recommended that when starting out, you use the autoLibGen app to generate your RunDataLibrary. However, you can generate a RunDataLibrary with more control by utilizing the RunDataLibrary's construct methods.

The first thing you need is a runInfoTable. This is a csv which contains rows of information about the run folders (on the Citadel, where the atomdatas are located) and a few other things. You can get fancy here and add all sorts of columns, but the basic set is:
    - Year
    - Month
    - Day
    - SeriesID (can be left blank): A character which labels different types of runs. Arbitrary, but useful for sorting at a glance.
    - RunType (can be left blank): A name for that type of run. Also arbitrary, yet useful for the same reason as SeriesID.
    - RunFolder (wherever atomdata is)
Take a look at AutoConstrTestTable.csv for an example. Ignore the last two columns for now.

Once you have your RunInfoTable, you will feed it (with some optional arguments) to RunDataLibrary.libraryConstruct(). See the section "Autogenerating RunDataLibrary" in ExampleScript.mlx for a detailed look at how this works. If all you care about is getting a RunDataLibrary from your table, you can use the __GetRunDatas__ function by calling it from the MatLab command window.

