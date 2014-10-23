# -*- coding: utf-8 -*-
"""
Created on Tue Jun 25 13:53:43 2013

@author: RLH
"""
# Link data to excel spreadsheet through data nitro
# Import required libraries
import os, sys
import re
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
from numpy import genfromtxt
from StringIO import StringIO
from mpl_toolkits.mplot3d import axes3d
from matplotlib import cm
from scipy.optimize import curve_fit
from scipy import optimize
from scipy.interpolate import *

###
# Subset to extract range of wave periods
def getPeriods(mydata):
    data1Dir = mydata[mydata[:,6] == mydata[0,6]]
    wavePeriod = np.unique(data1Dir[:,8])
    return wavePeriod

# Subset to extract range of wave directions
def getDirs(mydata):
    data1Period = mydata[mydata[:,8] == mydata[0,8]]
    waveDirs = np.unique(data1Period[:,6])
    return waveDirs
    
# Subset to extract range of wave heights
def getHeights(mydata):
    data1Period = mydata[mydata[:,8] == mydata[0,8]]
    waveHeights = np.unique(data1Period[:,5])
    return waveHeights

# Subset to extract all data for interpolation 
def subsetPeriod(mydata,wave_period,wave_direction):
    # Given a wave period and direction, subset all data for interpolation
    # extrapolation of Hm0 to the limiting criteria
    subset01 = mydata[mydata[:,8] == wave_period]
    subset02 = subset01[subset01[:,6] == wave_direction]
    return subset02

# Subset to extract all data for a given tested wave height
def subsetHeights(mydata,wave_height,variable):
    # Given a wave period and direction, subset all data for interpolation
    # extrapolation of Hm0 to the limiting criteria
    subset01 = mydata[mydata[:,5] == wave_height]
    subset02 = subset01[:,variable]
    return subset02
 
# Expontential function
def funcExp(x,a,b,c):
    # Function for curve fit
    return a*np.exp(b*x)+c
    
# Linear function
def funcLine(x,a,b):
    # Function for linear curve fit
    return a*x+b
    
#Power function
def funcPow(x,a,b,c):
    # Function for curve fit for motions
    return a*(x**b)+c
    
# Polynomial
def funcPoly2(x,a,b,c):
    # Function for curve fit for mooting lines and fenders
    return a*(x**2) + b*x + 0

# Linspace function
def linspace(start,stop,n):
    if n == 1:
        yield stop
        return
    h = (stop - start) / (n -1)
    for i in range(n):
        yield start + h * i

# Def linear interpolate
def linInterp(x,y,ylim):
    mytmpfunc = (interp1d(x,y,kind='linear'))
    xn = linspace(min(x),max(x),1000)
    for myx in xn:
        yp = mytmpfunc(myx)
        if (yp <= ylim +0.01*(max(y)-min(y)) and yp >= ylim - 0.01*(max(y)-min(y))):
            return myx
            break    
# Define new function to process wave conditions and return counter
def LimitingConditions(Hm0,Tp,MWD,LimitVariable):
    mylimitHm0 = rbf(MWD,Tp)
    if (Hm0 >= mylimitHm0):
        return 1.
    else:
        return 0.
# Get working directory and change to working directory
def SetWorkingDirectory():
    RootFolder = str((CellRange("Run Files","WORKING_DIRECTORY").value)[0])
    RootFolder = RootFolder.upper()
    os.chdir(RootFolder)

def GetNumFend():
    # Get number of lines and fenders
    Num_Fend = int((CellRange("Run Files","NUM_FEND").value)[0])
    return Num_Fend

def GetNumLines():
    # Get number of lines and fenders
    Num_Lines = int((CellRange("Run Files","NUM_LINES").value)[0])
    return Num_Lines

def GetLimitingCriteria():
    Num_Fend = GetNumFend()
    Num_Lines = GetNumLines()
    #Get limiting criteria
    # Get column and row for surge limit
    LimitRow = Cell("Run Files","SURGE_LIM").row
    LimitCol = Cell("Run Files","SURGE_LIM").col
    # Run through all variables to extract limiting criteria
    myLimitingCriteria = []
    myLimitRange = 6 + Num_Fend + Num_Lines
    for ii in range(0,myLimitRange):
        # Run on local sheet
        tmpLimitCriteria = Cell("Run Files",LimitRow,LimitCol+ii).value
        myLimitingCriteria.append(tmpLimitCriteria)
    return myLimitingCriteria

def GetLimitVariables():
    Num_Fend = GetNumFend()
    Num_Lines = GetNumLines()
    #Get limiting criteria
    # Get column and row for surge limit
    LimitRow = Cell("Run Files","SURGE_LIM").row
    LimitCol = Cell("Run Files","SURGE_LIM").col
    # Run through all variables to extract limiting criteria
    myLimitingVariables = []
    myLimitRange = 6 + Num_Fend + Num_Lines
    for ii in range(0,myLimitRange):
        # Run on local sheet
        tmpLimitVariables = Cell("Run Files",LimitRow+1,LimitCol+ii).value
        myLimitingVariables.append(tmpLimitVariables)
    return myLimitingVariables
def GetAllVariableNames():
    #Get limiting criteria
    Num_Fend = GetNumFend()
    Num_Lines = GetNumLines()
    # Get column and row for surge limit
    LimitRow = Cell("Run Files","START_RUNS").row
    LimitCol = Cell("Run Files","START_RUNS").col
    # Run through all variables to extract all variable names
    AllVariables = []
    myLimitRange = 9 + 6 + Num_Fend + Num_Lines # Need to count!!
    for ii in range(0,myLimitRange):
        # Run on local sheet
        tmpAllVariables = Cell("Run Files",LimitRow,LimitCol+ii).value
        AllVariables.append(tmpAllVariables)
    return AllVariables

def GetIndexForVariable(myVariables):
    myindex = []
    ii = 0
    for ii in range(len(myVariables)):
        myindex.append(ii)
        ii = ii +1
    tmpDict =  dict(zip(myVariables,myindex))
    return tmpDict

# Array for limitng wave heights
def getHlimits(array_new_data,start,end,LimitCriteria):
    myLimitHm0 = []
    # Range of directions    
    Dirs = getDirs(array_new_data)
    # Range of periods
    Periods = getPeriods(array_new_data)
    myperiods = []
    mydirs = []
    for ii in range(0,len(Dirs)):
        for jj in range(0,len(Periods)):
            tmpSub = subsetPeriod(array_new_data,Periods[jj],Dirs[ii])#x)
            # Loop through all results for a given period and direction
            myTmpLimitHm0 = []
            for i in range(start,end,1):
                # Loop through all motions in order to get x (Hm0) y (Variable) this is a test
                myX = tmpSub[:,5]  # Variable          
                myY = tmpSub[:,9+i]  # Hm0
                limitVal = LimitCriteria[i]
                # If limiting value falls in range of results then interpolate for Hlim
                if (limitVal <= max(myY) and limitVal >= min(myY)):                
                    hlim = linInterp(myX,myY,limitVal)
                    myTmpLimitHm0.append(hlim)
                # If Limiting value falls outside of range of results use linear eaxtrapolation
                elif (limitVal >= max(myY)):
                    if (myY[1]==0.):
                        hlim = 100.
                        myTmpLimitHm0.append(hlim)
                    else:
                        pars,covar = curve_fit(funcPoly2,myX,myY)
                        xn = np.arange(0.,100.,0.1)
                        # Extrapolate
                        for myx in xn:
                            tmplimY = funcPoly2(myx,*pars)
                            if (tmplimY >= (limitVal+0.1)):
                                hlim = myx
                                myTmpLimitHm0.append(hlim)
                                break
                tt = min(myTmpLimitHm0)
            myLimitHm0.append(tt)
    return myLimitHm0

# Pull summary of AQWA data into file
# Slurp
def GetAqwaData(RootFile,SummaryFile):
    f = open(SummaryFile,'r')
    tmpdata = f.read()
    f.close()
    # Open file and read data into array
    my_data = genfromtxt(StringIO(tmpdata),delimiter=',',dtype="|S100")
    # Convert all data into np.arrays.
    runs = np.array([float(x) for x in my_data[:,0]])
    #runs = np.array([char(x) for x in my_data[:,0]])
    windSpeed = np.array([float(x) for x in my_data[:,1]])
    windDirection = np.array([float(x) for x in my_data[:,2]])
    currentSpeed = np.array([float(x) for x in my_data[:,3]])
    currentDirection = np.array([float(x) for x in my_data[:,4]])
    waveHeight = np.array([float(x) for x in my_data[:,5]])
    waveDirectionTN = np.array([float(x) for x in my_data[:,6]])
    waveDirectionVessel = np.array([float(x) for x in my_data[:,7]])
    wavePeriod = np.array([float(x) for x in my_data[:,8]])
    surge = np.array([float(x) for x in my_data[:,9]])
    sway = np.array([float(x) for x in my_data[:,10]])
    heave = np.array([float(x) for x in my_data[:,11]])
    roll = np.array([float(x) for x in my_data[:,12]])
    pitch = np.array([float(x) for x in my_data[:,13]])
    yaw = np.array([float(x) for x in my_data[:,14]])
    # Line tension and fender reactions as empty arrays
    lineTension = []
    fenderReaction = []
    # Add line tension
    Num_Lines = GetNumLines()
    Num_Fend = GetNumFend()
    for i in range(1,Num_Lines + 1):
        lineTension.append(np.array(my_data[:,14+i]))
    # Add fender reaction
    for i in range(1,Num_Fend + 1):
        fenderReaction.append(np.array(my_data[:,14+Num_Lines+i]))
    # Convert to kN
    # lines
    for i in range(0,len(lineTension)):
        for j in range(0,len(lineTension[1])):
            lineTension[i][j] = 0.001*float(lineTension[i][j])
        lineTension[i] = np.array([float(x) for x in lineTension[i]])
    
    # fenders
    for i in range(0,len(fenderReaction)):
        for j in range(0,len(fenderReaction[1])):
            fenderReaction[i][j] = 0.001*float(fenderReaction[i][j])
        fenderReaction[i] = np.array([float(x) for x in fenderReaction[i]])

    # Combined all data 
    my_new_data = [runs,windSpeed,windDirection,currentSpeed,currentDirection,
                   waveHeight,waveDirectionTN,waveDirectionVessel,wavePeriod,
                   surge,sway,heave,roll,pitch,yaw]

    # Add line tension and fender compression to combined data
    # Append number of line and number of fenders
    for i in range(0,Num_Lines):
        my_new_data.append(lineTension[i])

    for i in range(0,Num_Fend):
        my_new_data.append(fenderReaction[i])
    array_new_data = np.transpose(np.array(my_new_data))
    return array_new_data

# Convert to numpy array

def GetWaveData(RootFolder,WaveFile,ColNames):
    WaveFile = RootFolder+WaveFile
    # Pass wave file to a Pandas time series and split into relevant columns
    ts = pd.read_csv(WaveFile,delimiter='\t',skiprows=3,names=ColNames,parse_dates=True)
    return ts


def getLimitSurface(array_new_data,myLimits):
    Dirs = getDirs(array_new_data)
    Periods = getPeriods(array_new_data)
    
    myperiods = []
    mydirs = []
    for ii in range(0,len(Dirs)):
        for jj in range(0,len(Periods)):
            myperiods.append(Periods[jj])
            mydirs.append(Dirs[ii])
    
    # Get desciption of surface
    rbf = Rbf(mydirs, myperiods, myLimits, function='linear')
    return rbf

def bilinear_interpolation(x, y, points):
    '''Interpolate (x,y) from values associated with four points.

    The four points are a list of four triplets:  (x, y, value).
    The four points can be in any order.  They should form a rectangle.

        >>> bilinear_interpolation(12, 5.5,
        ...                        [(10, 4, 100),
        ...                         (20, 4, 200),
        ...                         (10, 6, 150),
        ...                         (20, 6, 300)])
        165.0

    '''
    # See formula at:  http://en.wikipedia.org/wiki/Bilinear_interpolation

    points = sorted(points)               # order points by x, then by y
    (x1, y1, q11), (_x1, y2, q12), (x2, _y1, q21), (_x2, _y2, q22) = points

    if x1 != _x1 or x2 != _x2 or y1 != _y1 or y2 != _y2:
        raise ValueError('points do not form a rectangle')
    if not x1 <= x <= x2 or not y1 <= y <= y2:
        raise ValueError('(x, y) not within the rectangle')

    return (q11 * (x2 - x) * (y2 - y) +
            q21 * (x - x1) * (y2 - y) +
            q12 * (x2 - x) * (y - y1) +
            q22 * (x - x1) * (y - y1)
           ) / ((x2 - x1) * (y2 - y1) + 0.0)

def VariableResults(array_new_data,H,variable):
    myLimitValues = []
    # Range of directions    
    Dirs = getDirs(array_new_data)
    # Range of periods
    Periods = getPeriods(array_new_data)
    myperiods = []
    mydirs = []
    for ii in range(0,len(Dirs)):
        for jj in range(0,len(Periods)):
            tmpSub = subsetPeriod(array_new_data,Periods[jj],Dirs[ii])#x)
            # Loop through all results for a given period and direction
            myTmpLimitHm0 = []
            for i in range(start,end,1):
                # Loop through all motions in order to get x (Hm0) y (Variable) this is a test
                myX = tmpSub[:,5]  # Variable          
                myY = tmpSub[:,9+i]  # Hm0
                limitVal = LimitCriteria[i]
                # If limiting value falls in range of results then interpolate for Hlim
                if (limitVal <= max(myY) and limitVal >= min(myY)):                
                    hlim = linInterp(myX,myY,limitVal)
                    myTmpLimitHm0.append(hlim)
                # If Limiting value falls outside of range of results use linear eaxtrapolation
                elif (limitVal >= max(myY)):
                    if (myY[1]==0.):
                        hlim = 100.
                        myTmpLimitHm0.append(hlim)
                    else:
                        pars,covar = curve_fit(funcPoly2,myX,myY)
                        xn = np.arange(0.,100.,0.1)
                        # Extrapolate
                        for myx in xn:
                            tmplimY = funcPoly2(myx,*pars)
                            if (tmplimY >= (limitVal+0.1)):
                                hlim = myx
                                myTmpLimitHm0.append(hlim)
                                break
                tt = min(myTmpLimitHm0)
            myLimitHm0.append(tt)
    return myLimitHm0

def getInterpolatedValues(array_new_data,Hm0,Tp,MWD,index):
    Hm0Upper = 0.0
    Hm0Lower = 0.0
    TestedWaveHeights = getHeights(array_new_data)
    if Hm0 < min(TestedWaveHeights):
        Hm0 = min(TestedWaveHeights)
    TestedWavePeriods = getPeriods(array_new_data)
    TestedWaveDirs = getDirs(array_new_data)
    for ii in range(len(TestedWaveHeights)):
        Hm0Upper = TestedWaveHeights[ii+1]
        Hm0Lower = TestedWaveHeights[ii]
        if ((Hm0 >= Hm0Lower)and(Hm0 <= Hm0Upper)):
            break
    
    ArrayVariableUpper = subsetHeights(array_new_data,Hm0Upper,index)
    ArrayVariableLower = subsetHeights(array_new_data,Hm0Lower,index)
    rbfUpper = getLimitSurface(array_new_data,ArrayVariableUpper)
    rbfLower = getLimitSurface(array_new_data,ArrayVariableLower)
    ValUpper = rbfUpper(MWD,Tp)
    ValLower = rbfLower(MWD,Tp)
    #print ValUpper,ValLower
    xp = [Hm0Lower,Hm0Upper]
    #print xp
    yp = [ValLower,ValUpper]
    #print yp
    myInterpolatedValues = np.interp(Hm0,xp,yp)
    # Interpolate for Hm0Upper
    #print myInterpolatedValues
    return myInterpolatedValues
    #return ValUpper
  
def PlotResults(x,y,filename):
    # Set axis range
    xmin = x.min()
    xmax = x.max()
    ymin = y.min()
    ymax = y.max()
    # Plot data
    plt.hexbin(x,y,cmap=plt.cm.YlOrRd_r)
    plt.title("Scatter Plot of Wave Data")
    cb = plt.colorbar()
    cb.set_label('Counts')
    plt.savefig(filename)

### End of user functions
###
### Get wave time series files
# Set from spreadsheet
# Specify column names
WaveFileVariable = re.split(',',str((CellRange("DowntimeInputs","ColArray").value)[0]))
Hm0Index = int((CellRange("DowntimeInputs","Hm0Index").value)[0])
TpIndex = int((CellRange("DowntimeInputs","TpIndex").value)[0])
MWDIndex = int((CellRange("DowntimeInputs","MWDIndex").value)[0])
RootFolder = str((CellRange("DowntimeInputs","WaveRootDir").value)[0])
#RootFolder = RootFolder.upper()
WaveFile = str((CellRange("DowntimeInputs","WaveFile").value)[0])
WaveFile = "\\"+WaveFile
# Pandas object for plotting of forces
waveInputConditions = GetWaveData(RootFolder,WaveFile,WaveFileVariable)
# Pandas object for highlighting failure
FailureFlags = GetWaveData(RootFolder,WaveFile,WaveFileVariable)
# Get data regarding number of years
NumYears = int((CellRange("DowntimeInputs","NumYears").value)[0])
NumMonths = int((CellRange("DowntimeInputs","NumMonths").value)[0])


### Open AQWA summary results file
SetWorkingDirectory()
# Summary file
RootFile = str((CellRange("Run Files","ROOT_FILE").value)[0])
StatsType = str((CellRange("Run Files","STATS_TYPE").value)[0])
if (StatsType == "Significant"):
    SummaryFile = RootFile + "_DRFT_Significant_Summary.csv"
elif (StatsType == "Max PtoP"):
    SummaryFile = RootFile + "_DRFT_Maximum_PtoP_Summary.csv"

### Get all results into a data object
LookUpTableData = GetAqwaData(RootFile,SummaryFile)




### Get list of limit variables i.e. surge, sway, etc 
LimitVariables = GetLimitVariables()
### Get list of all variables from spreadsheet
AllVariables = GetAllVariableNames()
### Index all variables into a dictionary
DictAllVariables = GetIndexForVariable(AllVariables)
### Get limiting criteria for all variables
LimitCriteria = GetLimitingCriteria()
DictLimitCriteria = dict(zip(LimitVariables,LimitCriteria))

### Test for limiting curve extraction
### Get limitng wave conditions
#tmp = getHlimits(LookUpTableData,0,17,LimitCriteria)
#stoprighthere

### Add list of all limit variables to the time series for extraction of interpolated results specifying zeros
for cols in LimitVariables:
    waveInputConditions[cols] = None

### Add list of failure criteria to pandas object
for cols in LimitVariables:
    FailureFlags[cols] = None

# Loop through all time series of data frame
Hm0 = waveInputConditions.ix[:,WaveFileVariable[Hm0Index - 1]]
Tp = waveInputConditions.ix[:,WaveFileVariable[TpIndex - 1]]
MWD = waveInputConditions.ix[:,WaveFileVariable[MWDIndex - 1]]
for i in waveInputConditions.index:
    # Take out wave parameters for testing
    for myvar in LimitVariables:
        myVarIndex = DictAllVariables[myvar]
        myVarLimit = DictLimitCriteria[myvar]
        myinterpval = getInterpolatedValues(LookUpTableData,Hm0[i],Tp[i],MWD[i],myVarIndex)
        waveInputConditions.ix[i,myvar] = myinterpval
        # Set failure flags
        print i
        if (myinterpval <= myVarLimit):
            flag = 0
        else:
            flag = 1
        FailureFlags.ix[i,myvar] = flag
###

###
### Plot the wave conditions used
Hm0 = waveInputConditions.ix[:,WaveFileVariable[Hm0Index - 1]]
Tp = waveInputConditions.ix[:,WaveFileVariable[TpIndex - 1]]
PlotResults(Hm0,Tp,"ScatterPlot.png")

motions = ["Surge","Sway","Heave","Roll","Pitch","Yaw"]

### Sum all motions failures  
FailureFlags["Motions"] = (FailureFlags.filter(motions)).sum(axis=1).apply(lambda x: 1 if x !=0 else 0)
FailureFlags["LinesMooringFailure"] = (FailureFlags.filter(regex="Line")).sum(axis=1).apply(lambda x: 1 if x != 0 else 0)
FailureFlags["FendersMooringFailure"] = (FailureFlags.filter(regex="Fend")).sum(axis=1).apply(lambda x: 1 if x != 0 else 0)
FailureFlags["Moorings"] = (FailureFlags.filter(["LinesMooringFailure","FendersMooringFailure"])).sum(axis=1).apply(lambda x: 1 if x != 0 else 0)
FailureFlags["TotalFailure"] = (FailureFlags.filter(["Motions","Moorings"])).sum(axis=1)
FailureFlags["Conditional"] = FailureFlags["TotalFailure"].apply(lambda x: 1 if x != 0 else 0)
waveInputConditions.to_csv("InterpolatedValues.csv",sep=",",header=True,index=True)
FailureFlags.to_csv("Failures.csv",sep=",",header=True,index=True)

#okstophere

### Sumarry of all failures
### Initiate start row and column
FailRowStart = Cell("Failures","FAILSTART").row
FailColStart = Cell("Failures","FAILSTART").col
### Temporary object for lines
tmpLine = FailureFlags.filter(regex="Line0")
for i in range(GetNumLines()):
    tmp = tmpLine.ix[:,i].sum()
    Cell("Failures",FailRowStart + 1 + i,FailColStart).value = tmp
    
tmpFend = FailureFlags.filter(regex="Fend0")
for i in range(GetNumFend()):
    tmp = tmpFend.ix[:,i].sum()
    Cell("Failures",FailRowStart + 1 + GetNumLines() + i,FailColStart).value = tmp

SurgeFailure = (FailureFlags.ix[:,"Surge"]).sum()
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 1,FailColStart).value = SurgeFailure

SwayFailure = (FailureFlags.ix[:,"Sway"]).sum()
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 2,FailColStart).value = SwayFailure

YawFailure = (FailureFlags.ix[:,"Yaw"]).sum()
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 3,FailColStart).value = YawFailure

MooringLinesFailures = (FailureFlags.ix[:,"LinesMooringFailure"]).sum()
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 3 + 2,FailColStart).value = MooringLinesFailures

FendersFailures = (FailureFlags.ix[:,"FendersMooringFailure"]).sum()
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 3 + 3,FailColStart).value = FendersFailures

MotionsFailures = (FailureFlags.ix[:,"Motions"]).sum()
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 3 + 4,FailColStart).value = MotionsFailures

TotalFailures = (FailureFlags.ix[:,"Conditional"]).sum()
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 3 + 5,FailColStart).value = TotalFailures

SimulatedCases = (FailureFlags.ix[:,"Conditional"]).count()
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 3 + 7,FailColStart).value = SimulatedCases

NonAvailability = float(TotalFailures)/float(SimulatedCases)
Cell("Failures",FailRowStart + GetNumFend() + GetNumLines() + 3 + 8,FailColStart).value = NonAvailability


# Generate pivot table
#Hm0Bins = pd.cut(np.array(Hm0),bins=[0.,.25,.5,.75,1.,1.25,1.5,1.75,2.,2.25,2.5,2.75,3.,3.25,3.5,3.75,4.,4.25,4.5,4.75,5.,5.25,5.5])
#TpBins = pd.cut(np.array(Tp),bins=[0.,2.,4.,6.,8.,10.,12.,14.,16.,18.,20.,22.,24.])
#Table = pd.pivot_table(FailureFlags,values='Conditional',rows = FailureFlags.ix[:,3],cols = FailureFlags.ix[:,6],aggfunc = np.sum)
#GroupedTable = Table.groupby([Hm0Bins,TpBins]).size().fillna(0)
#Cell("D3").value = GroupedTable.size()
#thisisawesome
# Calculate downtime based on the following criteria:
# Set array of downtime events
TotalDowntime = []

# Loop through variables and count
SumOfVariableDT = (FailureFlags.ix[:,"Conditional"]).sum()
TotalDowntime.append(SumOfVariableDT.sum())
    
# Group results by year and month
by = lambda x: lambda y: getattr(y,x)
# Run through each variable and 
# d = s.groupby(lambda x: x.date()).aggregate(lambda x: sum(x) if len(x) >= 40 else np.nan)
# Options loop through variables and keep track of downtime for each variable
# Sum across columns in order to get total failure criteria
# Motions downtime vs mooring failure downtime vs total downtime
# Need to loop thorugh each variable - gives errors
SeasonLimits = []
AnnualLimits = []
SeasonCount = []
AnnualCount = []
#LimitVariables = ["Surge"]

# 
# Extract each limiting variable and determine the seasonal downtime
temp = FailureFlags.ix[:,"Conditional"] # Time series of donwtime events
SeasonalDTVar = temp.groupby([by('year'), by('month')]).apply(lambda x: np.sum(x)) # Get year and month data
SeasonalCountVar = temp.groupby([by('year'), by('month')]).apply(lambda x: np.size(x)) # Get year and month data
AnnualDTVar = temp.groupby([by('year')]).apply(lambda x: np.sum(x))
AnnualCountVar = temp.groupby([by('year')]).apply(lambda x: np.size(x))
SeasonLimits.append(SeasonalDTVar) # Append to seasonal values
AnnualLimits.append(AnnualDTVar)    
SeasonCount.append(SeasonalCountVar)
AnnualCount.append(AnnualCountVar)
print AnnualCountVar
    
AnnualLimitsNP = np.array(AnnualLimits)
AnnualCountNP = np.array(AnnualCount)

# Get data table with np.meshgrid Year - Months
Counter = 0
for i in range(NumYears):
    for j in range(NumMonths):
        Cell("Downtime",i+2,j+2).value = (100*SeasonLimits[0][Counter])/(SeasonCount[0][Counter])
        Counter = Counter + 1

Counter = 0
for i in range(NumYears):
    Cell("Downtime",i+2,NumMonths+2).value = (100*AnnualLimitsNP[0][Counter])/(AnnualCountNP[0][Counter])
    Counter = Counter + 1

TotalFailures = float(sum(AnnualLimits[0]))
TotalCases = float(sum(AnnualCount[0]))

Cell("Downtime",2,NumMonths+5).value = TotalFailures
Cell("Downtime",3,NumMonths+5).value = TotalCases
Cell("Downtime",4,NumMonths+5).value = TotalFailures/TotalCases
