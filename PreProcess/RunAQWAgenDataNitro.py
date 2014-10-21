# Set of functions for calling deck inputs
# Subprocess for calling perl from python
import subprocess
import os, sys
def getSimulationData(datafile,SimType,RootFolder,templateFile,RootFile):
    def makeLINE(templateFile):
        #deck00 = ["0","2",templateFile, #Default options for all
        deck00 = ["0","2",templateFile, #Default options for all 
                  # Basic LINE options always expects 2
                  "LINE","NONE",
                  # Title
                  "Solved",
                  # Solver options 4 in total expected parsed to perl as none if
                  # No options in the slot
                  "REST","GOON","AQTF","CQTF",
                  # Restart values
                  "1","3","Line Teset"]
        deck01 = ["1","1",templateFile]
        deck02 = ["2","1",templateFile]
        deck03 = ["3","1",templateFile]
        deck04 = ["4","1",templateFile]
        deck05 = ["5","1",templateFile]
        deck06 = ["6","2",templateFile]
        #deck06 = ["6","1",templateFile]
        deck07 = ["7","1",templateFile]
        #deck08 = ["8","0"]
        deck08 = ["8","0"]
        lineInputs = [deck00,deck01,deck02,deck03,deck04,deck05,deck06,deck07,deck08]
        return lineInputs
    # All inputs for loading an AQWA librium run
    def makeLIBR (templateFile,restartFile):
        Cell("G1").value = templateFile
        deck00 = ["0","2",templateFile, #Default options for all 
                  # Basic LINE options always expects 2
                  "LIBR","NONE",
                  # Title
                  "Solved",
                  # Solver options 4 in total expected parsed to perl as none if
                  # No options in the slot
                  "REST","PBIS","NOBL","NONE",
                  # Restart values
                  "4","5",restartFile]
        deck09 = ["9","0",templateFile,restartFile,"1"]
        # Preliminary results taken from analysis
        deck10 = ["10","1",templateFile]
        deck11 = ["11","1",templateFile,
                  str((CellRange("flagSPEC").value)[0]),
                  str((CellRange("flagType").value)[0]),
                  str((CellRange("Vessel Data","Current_Speed").value)[0]),
                  str((CellRange("Vessel Data","Current_Direction").value)[0]),
                  str((CellRange("Vessel Data","Wind_Speed").value)[0]),
                  str((CellRange("Vessel Data","Wind_Direction").value)[0]),
                  str((CellRange("Vessel Data","Wind_ref_height").value)[0])]
        deck12 = ["12","1",templateFile]
        deck13 = ["13","1",templateFile,
                  str((CellRange("flagSPEC").value)[0]),
                  str((CellRange("flagType").value)[0]),
                  str((CellRange("SPDN").value)[0]),
                  str((CellRange("Current_Speed").value)[0]),
                  str((CellRange("Current_Direction").value)[0]),
                  str((CellRange("Wind_Speed").value)[0]),
                  str((CellRange("Wind_Direction").value)[0]),
                  str((CellRange("Wind_Spectrum").value)[0]),
                  str((CellRange("Wind_ref_height").value)[0]),
                  str((CellRange("GAMMA").value)[0]),
                  str((CellRange("HS").value)[0]),
                  str(1/(CellRange("TP").value)[0]),
                  str((CellRange("WaveFile").value)[0]),
                  str((CellRange("SPREAD_N").value)[0]),
                  str((CellRange("SPREAD_THETA").value)[0])]
        #Cell("G2").value = str((CellRange("WaveFile").value)[0])
        deck14 = ["14","2",templateFile,
                  templateFile,
                  str((CellRange("LINE_LENGTH_FLAG").value)[0]),
                  str("FALSE"), #$lineBreakFlag default on
                  str(0.75*(CellRange("MBL").value)[0]), #$breakingStrength break at 75 % of "MBL"
                  str((CellRange("L_POLYA").value)[0]),
                  str((CellRange("L_POLYB").value)[0]),
                  str((CellRange("L_POLYC").value)[0]),
                  str((CellRange("MBL").value)[0]),
                  str((CellRange("Pretension").value)[0]),
                  str((CellRange("F_POLYA").value)[0]),
                  str((CellRange("F_POLYB").value)[0]),
                  str((CellRange("F_POLYC").value)[0]),
                  str((CellRange("F_POLYD").value)[0]),
                  str((CellRange("F_POLYE").value)[0]),
                  str((CellRange("IS_MOORING_FILE").value)[0]),
                  str((CellRange("MOORING_FILE").value)[0])]
        deck15 = ["15","1",templateFile]
        deck16 = ["16","2",templateFile,
                  str((CellRange("SolverType").value)[0]),
                  str((CellRange("solverPar01").value)[0]),
                  str((CellRange("solverPar02").value)[0]),
                  str((CellRange("solverPar03").value)[0])]
        deck17 = ["17","0",templateFile]
        deck18 = ["18","0"] #No printing for librium conditions
        librInputs = [deck00, deck09,deck10,deck11,deck12,deck13,
                      deck14,deck15,deck16,deck17,deck18]
        return librInputs
    # Drift inputs
    def makeDRIFT (templateFile,restartFile):
        deck00 = ["0","2",templateFile, #Default options for all 
                  # Basic LINE options always expects 2
                  "DRFT","WFRQ",
                  # Title
                  "Solved",
                  # Solver options 4 in total expected parsed to perl as none if
                  # No options in the slot
                  "REST","PBIS","NOBL","RDEP",
                  # Restart values
                  "4","5",restartFile]
        deck09 = ["9","0",templateFile,restartFile,"1"]
        # Preliminary results taken from analysis - by default use structure 1
        deck10 = ["10","1",templateFile]
        deck11 = ["11","1",templateFile,
                  str((CellRange("flagSPEC").value)[0]),
                  str((CellRange("flagType").value)[0]),
                  str((CellRange("Vessel Data","Current_Speed").value)[0]),
                  str((CellRange("Vessel Data","Current_Direction").value)[0]),
                  str((CellRange("Vessel Data","Wind_Speed").value)[0]),
                  str((CellRange("Vessel Data","Wind_Direction").value)[0]),
                  str((CellRange("Vessel Data","Wind_ref_height").value)[0])]
        deck12 = ["12","1",templateFile]
        deck13 = ["13","1",templateFile,
                  str((CellRange("flagSPEC").value)[0]),
                  str((CellRange("flagType").value)[0]),
                  str((CellRange("SPDN").value)[0]),
                  str((CellRange("Current_Speed").value)[0]),
                  str((CellRange("Current_Direction").value)[0]),
                  str((CellRange("Wind_Speed").value)[0]),
                  str((CellRange("Wind_Direction").value)[0]),
                  str((CellRange("Wind_Spectrum").value)[0]),
                  str((CellRange("Wind_ref_height").value)[0]),
                  str((CellRange("GAMMA").value)[0]),
                  str((CellRange("HS").value)[0]),
                  str(1/(CellRange("TP").value)[0]),
                  str((CellRange("WaveFile").value)[0]),
                  str((CellRange("SPREAD_N").value)[0]),
                  str((CellRange("SPREAD_THETA").value)[0])]
        deck14 = ["14","1",templateFile,
                  templateFile,
                  str((CellRange("LINE_LENGTH_FLAG").value)[0]),
                  str("FALSE"), #$lineBreakFlag default on
                  str(0.75*(CellRange("MBL").value)[0]), #$breakingStrength break at 75 % of "MBL"
                  str((CellRange("L_POLYA").value)[0]),
                  str((CellRange("L_POLYB").value)[0]),
                  str((CellRange("L_POLYC").value)[0]),
                  str((CellRange("MBL").value)[0]),
                  str((CellRange("Pretension").value)[0]),
                  str((CellRange("F_POLYA").value)[0]),
                  str((CellRange("F_POLYB").value)[0]),
                  str((CellRange("F_POLYC").value)[0]),
                  str((CellRange("F_POLYD").value)[0]),
                  str((CellRange("F_POLYE").value)[0]),
                  str((CellRange("IS_MOORING_FILE").value)[0]),
                  str((CellRange("MOORING_FILE").value)[0])]
        deck15 = ["15","1",templateFile]
        deck16 = ["16","2",templateFile,
                  str((CellRange("SolverType").value)[0]),
                  str((CellRange("solverPar01").value)[0]),
                  str((CellRange("solverPar02").value)[0]),
                  str((CellRange("solverPar03").value)[0])]
        deck17 = ["17","1",templateFile]
        deck18 = ["18","1",templateFile,"DRIFT_MIN"] #No printing for librium conditions
        #Cell("G2").value = deck18
        librInputs = [deck00, deck09,deck10,deck11,deck12,deck13,
                      deck14,deck15,deck16,deck17,deck18]
        return librInputs
    # Inputs for FER analysis
    def makeFER (templateFile,restartFile):
        deck00 = ["0","2",templateFile, #Default options for all 
                  # Basic LINE options always expects 2
                  "FER","NONE",
                  # Title
                  "Solved",
                  # Solver options 4 in total expected parsed to perl as none if
                  # No options in the slot
                  "REST","PPRP","CRAO","FQTF",
                  # Restart values
                  "4","5",restartFile]
        deck09 = ["9","1",templateFile,restartFile,"1"]#,
                  # Nominal slow drift values - see ]
        # Preliminary results taken from analysis - by default use structure 1
        deck10 = ["10","1",templateFile]
        deck11 = ["11","0",templateFile]
        deck12 = ["12","1",templateFile]
        deck13 = ["13","2",templateFile,
                  str((CellRange("flagSPEC").value)[0]),
                  str((CellRange("flagType").value)[0]),
                  str((CellRange("SPDN").value)[0]),
                  str((CellRange("Current_Speed").value)[0]),
                  str((CellRange("Current_Direction").value)[0]),
                  str((CellRange("Wind_Speed").value)[0]),
                  str((CellRange("Wind_Direction").value)[0]),
                  str((CellRange("Wind_Spectrum").value)[0]),
                  str((CellRange("Wind_ref_height").value)[0]),
                  str((CellRange("GAMMA").value)[0]),
                  str((CellRange("HS").value)[0]),
                  str(1/(CellRange("TP").value)[0]),
                  str((CellRange("WaveFile").value)[0]),
                  str((CellRange("SPREAD_N").value)[0]),
                  str((CellRange("SPREAD_THETA").value)[0])]
        deck14 = ["14","2",templateFile,
                  templateFile,
                  str((CellRange("LINE_LENGTH_FLAG").value)[0]),
                  str("FALSE"), #$lineBreakFlag default on
                  str(0.75*(CellRange("MBL").value)[0]), #$breakingStrength break at 75 % of "MBL"
                  str((CellRange("L_POLYA").value)[0]),
                  str((CellRange("L_POLYB").value)[0]),
                  str((CellRange("L_POLYC").value)[0]),
                  str((CellRange("MBL").value)[0]),
                  str((CellRange("Pretension").value)[0]),
                  str((CellRange("F_POLYA").value)[0]),
                  str((CellRange("F_POLYB").value)[0]),
                  str((CellRange("F_POLYC").value)[0]),
                  str((CellRange("F_POLYD").value)[0]),
                  str((CellRange("F_POLYE").value)[0]),
                  str((CellRange("IS_MOORING_FILE").value)[0]),
                  str((CellRange("MOORING_FILE").value)[0])]
        deck15 = ["15","0",templateFile]
        deck16 = ["16","0",templateFile]
        deck17 = ["17","0",templateFile]
        deck18 = ["18","0",templateFile] #No printing for librium conditions
        #Cell("G2").value = deck18
        ferInputs = [deck00, deck09,deck10,deck11,deck12,deck13,
                      deck14,deck15,deck16,deck17,deck18]
        return ferInputs  
    # Get control parameters from excel spreadsheet to generate
    # Get individual deck input data
    if "LINE" in SimType:
        moduleArgs = makeLINE(templateFile)
    elif "LIBR" in SimType:
        moduleArgs = makeLIBR(templateFile,restartFile)
    elif "DRFT" in SimType:
        moduleArgs = makeDRIFT(templateFile,restartFile)
    elif "FER" in SimType:
        moduleArgs = makeFER (templateFile,restartFile)
    # Process module specific args and send them to perl script for *.dat generation

    for myargs in moduleArgs:
        #Cell("G2").value = myargs
        myargs.reverse()
        myargs.append(datafile)
        myargs.reverse()
        myargs = [str(i) for i in myargs]
        # Required to add trailing whitespace in order to pass arrays completely to perl
        myargs = [e+' ' for e in myargs]
        # Open a subprocess pipe to perl and parse all arguments
        #Cell("G2").value = myargs
        pipe = subprocess.Popen(["C:\\Perl\\bin\\perl.exe",
                                 "C:\\Users\\rlh.PRDW\\Documents\\Projects\\Mozambique (1118) Northern Port BFS\\Programs\\WriteAQWA_Files_Rev01.pl",
                                 myargs], stdout=subprocess.PIPE)
        result = pipe.stdout.read()
# Run with argument
RootFile = str((CellRange("RootFile").value)[0])
SimType = str((CellRange("SimType").value)[0])
RunNum = str((CellRange("RunNum").value)[0])
WBFILE = str((CellRange("WBFILE").value)[0])
tmpWBFILE = WBFILE.zfill(2)

# Automatically obtained from the excel spreadsheet
RootFolder = str((CellRange("RootFolder").value)[0])
RootFolder = RootFolder.upper()
# Change root directory to working directory
os.chdir(RootFolder)

if "LINE" in SimType:
    datafile = RootFile + '_'+ SimType + '_' + RunNum.zfill(3) + '.dat'
    templateFile = "analysis.dat"
    templateFile = '"' + '..\\WB\\' + tmpWBFILE + '_files\\dp0\\AQW\\AQW\\AQ\\Analysis' + '\\' + templateFile + '"'
    restartFile = "NONE"
elif "LIBR" in SimType:
    datafile = RootFile + '_' + SimType + '_' + RunNum.zfill(3) + '.dat'
    templateFile = "TimeResponse_EQ.dat"
    templateFile = '"' + '..\\WB\\' + tmpWBFILE + '_files\\dp0\\AQW-1\\AQW\\AQ\\Analysis' + '\\' + templateFile + '"'
    restartFile = RootFile + '_' + 'LINE'#'"' + '.\\' + tmpWBFILE + '_files\\dp0\\AQW\\AQW\\AQ\\Analysis\\Analysis' + '"'
    #Cell("G4").value = templateFile
elif "DRFT" in SimType:
    datafile = RootFile + '_' + SimType + '_' + RunNum.zfill(3) + '.dat'
    templateFile = "TimeResponse_EQ.dat"
    templateFile = '"' + '..\\WB\\' + tmpWBFILE + '_files\\dp0\\AQW-1\\AQW\\AQ\\Analysis' + '\\' + templateFile + '"'
    restartFile = RootFile + '_LIBR_' + RunNum.zfill(3)
elif "FER" in SimType:
    datafile = RootFile + '_' + SimType + '_' + RunNum.zfill(3) + '.dat'
    templateFile = "TimeResponse_EQ.dat"
    templateFile = '"' + '..\\WB\\' + tmpWBFILE + '_files\\dp0\\AQW-1\\AQW\\AQ\\Analysis' + '\\' + templateFile + '"'
    restartFile = RootFile + '_LIBR_' + RunNum.zfill(3)

#Cell("C1").value = getSimulationData(datafile,SimType,RootFolder,templateFile,RootFile)
getSimulationData(datafile,SimType,RootFolder,templateFile,RootFile)
    
    
    
    
    
