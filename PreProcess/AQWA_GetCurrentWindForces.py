#!/usr/bin/env python
"""
RLH 2013-01-09
Dictionary of values for wind and current coefficients
"""
import sys
import numpy as np
from scipy import interpolate
import math
import warnings
import matplotlib.pyplot as plt
import rpy2

# Get data from excel spreadsheet for Data Nitro

# Get constants - check variable
VesselType = "Bulk" #str((CellRange("Vessel Data","VesselType").value)[0])
Loading = "Loaded" #str((CellRange("Freqs","LoadingCondition").value)[0])
LateralArea = "" #float(CellRange("Vessel Data",Loading + "_Lateral_Area").value[0])
rho_air = "" #float(CellRange("Vessel Data","Density_Air").value[0])
rho_water = 1025 #float(CellRange("Vessel Data","Density_Water").value[0])
Lpp = float(CellRange("Vessel Data","Lpp").value[0])
Draft = float(CellRange("Vessel Data",Loading + "Draft").value[0])
WaterDepth = float(CellRange("Vessel Data","Water_Depth").value[0])

# Read array of required coefficients and angles
NumDirections = 37 #int(Cell("B2").value)
#startRow = Cell("B4").row
#startCol = Cell("B4").col
#aqwaCoefficientsRow = startRow
#aqwaCoefficientsCol = startCol
#angle  = Cell(startRow,startCol).value
#coefficient = str(Cell(aqwaCoefficientsRow,aqwaCoefficientsCol).value)
angles = np.array()

def DepthCorrectionFactor(waterDepth,Draft):
    # Water depth correction factor for longitudinal current forces on container ships
    # From BS 6349-1:2000 pg 98
    d_dm = waterDepth/Draft
    x = (1.1,1.2,1.5,2.0)
    y = (1.75,1.50,1.38,1.25)
    if d_dm > 2.0:
        correctionFactor = 1
    else:
        f = interpolate.interp1d(x,y)
        correctionFactor = f(d_dm)
    return float(correctionFactor)
def LateralDepthCorrectionFactor(waterDepth,Draft,VesselType):
    # Water depth correction factor for lateral current forces on container ships and tankers
    DIRS = np.linspace(0,180,37)
    DIRS = DIRS.tolist()
    d_dm = waterDepth/Draft
    Cd_dm = 0
    if d_dm < 1.15:
        Cd_dm = '11'
    elif 1.15 <= d_dm < 1.35:
        Cd_dm = '12'
    elif 1.35 <= d_dm < 1.75:
        Cd_dm = '15'
    elif 1.75 <= d_dm <= 2.5:
        Cd_dm = '20'
    elif 2.5 < d_dm:
        Cd_dm = '20'    
        # COEFICIENTES LATERALES DE CORRIENTE
    # CORRECCION POR PROFUNDIDAD - DEPTH CORRECTION
    # CONTAINERS
    CT11 = (10.00,10.00,10.00,9.90,9.80,9.40,9.00,8.78,8.55,8.55,8.55,8.53,8.50,8.42,8.34,8.23,8.11,8.14,
           8.17,8.15,8.12,8.26,8.39,8.47,8.55,8.58,8.60,8.61,8.61,8.88,9.15,9.48,9.80,9.90,10.00,10.00,10.00)
    CT12 = (9.30,8.90,8.50,7.75,7.00,6.75,6.50,6.45,6.40,6.52,6.64,6.72,6.80,6.83,6.86,6.81,6.75,6.73,6.70,
           6.73,6.75,6.82,6.88,6.88,6.87,6.76,6.65,6.54,6.42,6.48,6.53,6.82,7.10,8.05,9.00,9.15,9.30)
    CT15 = (5.10,4.80,4.50,3.95,3.40,3.25,3.10,3.12,3.13,3.17,3.20,3.23,3.25,3.28,3.30,3.32,3.33,3.33,3.33,
           3.33,3.33,3.32,3.30,3.30,3.30,3.29,3.27,3.20,3.13,3.12,3.10,3.30,3.50,3.78,4.05,4.13,4.20)
    CT20 = (2.00,2.00,2.00,2.00,2.00,1.95,1.90,1.90,1.90,1.95,2.00,2.03,2.05,2.06,2.07,2.09,2.10,2.10,
           2.10,2.10,2.09,2.08,2.07,2.05,2.02,2.01,2.00,1.98,1.95,1.93,1.90,1.94,1.98,2.00,2.02,2.01,2.00)
    # OIL CARRIER (TANKERS)
    OC11 = (8.00,7.95,7.90,7.60,7.30,6.65,6.00,5.60,5.20,5.03,4.85,4.78,4.70,4.71,4.72,4.76,4.80,4.84,4.87,
            4.85,4.83,4.72,4.60,4.53,4.45,4.44,4.43,4.52,4.60,4.80,5.00,5.40,5.80,5.90,6.00,6.05,6.10)
    OC12 = (7.00,6.95,6.90,6.60,6.30,5.75,5.20,4.85,4.50,4.30,4.10,4.00,3.90,3.90,3.90,3.90,3.90,3.90,3.90,
            3.87,3.83,3.81,3.78,3.74,3.70,3.77,3.83,3.94,4.05,4.23,4.40,4.60,4.80,4.85,4.90,4.95,5.00)
    OC15 = (4.80,4.70,4.60,4.40,4.20,4.02,3.83,3.67,3.50,3.38,3.25,3.15,3.05,2.99,2.93,2.92,2.90,2.90,2.90,
            2.93,2.95,2.97,2.99,3.06,3.13,3.27,3.40,3.58,3.75,3.88,4.00,4.13,4.25,4.30,4.35,4.38,4.40)
    OC20 = (1.90,1.85,1.80,1.77,1.73,1.70,1.67,1.65,1.62,1.61,1.60,1.63,1.65,1.67,1.69,1.71,1.72,1.72,1.72,
            1.71,1.70,1.69,1.68,1.69,1.69,1.71,1.72,1.76,1.79,1.82,1.85,1.90,1.95,1.98,2.00,2.00,2.00)
    # Return values for interpolation
    VesselTypes = {'Bulk':'OC','Container':'CT','Tanker':'OC'}
    CorrectionDB = {'CT11':CT11,
                    'CT12':CT12,
                    'CT15':CT15,
                    'CT20':CT20,
                    'OC11':OC11,
                    'OC12':OC12,
                    'OC15':OC15,
                    'OC20':OC20}
    CODE = VesselTypes[VesselType] + Cd_dm
    tmpCoefficients = CorrectionDB[CODE]
    return (DIRS,tmpCoefficients)
def MakeCode(CoefficientType,VesselType,LoadCondition,Position,CTCL):
    VesselTypes = {'Bulk':'GC','Container':'CT','Tanker':'OC'}
    LoadingConditions = {'Loaded':'L','Ballasted':'B','Current':'X'}
    CoefficientTypes = {'Wind':'W','Current':'C','Correction':'O'}
    if 'Current' in CoefficientType:
        LoadCondition = 'Current'
    else:
        LoadCondition = LoadCondition
    myCoefficientCode = LoadingConditions[LoadCondition] + CTCL + CoefficientTypes[CoefficientType] + Position + VesselTypes[VesselType] 
    return myCoefficientCode
def DataBase(CODE):
    DIRS = np.linspace(0,180,37)
    DIRS = DIRS.tolist()
    # CURRENT DRAG FORCE COEFFIENTS
    # COEFICIENTES DE CORRIENTE
    #BCTWAFTGC
    XCTCAFTGC = (0.00,0.04,0.07,0.11,0.15,0.22,0.29,0.37,0.45,0.54,0.63,0.72,0.81,0.89,0.97,1.05,1.12,1.18,
            1.23,1.26,1.29,1.28,1.27,1.22,1.17,1.09,1.00,0.91,0.81,0.70,0.59,0.49,0.38,0.29,0.20,0.10,0.00)
    XCTCFWDGC = (0.00,0.09,0.17,0.27,0.36,0.47,0.58,0.70,0.82,0.91,1.00,1.09,1.18,1.23,1.28,1.29,1.30,1.27,
            1.23,1.17,1.10,1.03,0.95,0.88,0.80,0.71,0.61,0.53,0.44,0.36,0.28,0.22,0.15,0.11,0.07,0.04,0.01)
    XCLCLATGC = (0.05,0.13,0.20,0.18,0.15,0.14,0.13,0.11,0.09,0.06,0.03,-0.01,-0.05,-0.08,-0.10,-0.14,-0.18,
            -0.20,-0.21,-0.21,-0.21,-0.20,-0.19,-0.18,-0.16,-0.15,-0.14,-0.14,-0.13,-0.14,-0.14,-0.15,-0.15,-0.15,-0.15,-0.10,-0.05)
    XCTCAFTCT = (0.00,-0.03,-0.06,-0.01,0.04,0.22,0.40,0.57,0.73,0.94,1.14,1.35,1.55,1.77,1.98,2.14,2.30,2.40,
              2.50,2.54,2.57,2.53,2.49,2.36,2.23,2.07,1.90,1.72,1.53,1.32,1.10,0.83,0.55,0.38,0.20,0.10,0.00)
    XCTCFWDCT = (0.00,0.10,0.20,0.40,0.60,0.85,1.10,1.32,1.53,1.72,1.90,2.06,2.21,2.36,2.50,2.54,2.58,2.54,
              2.50,2.40,2.30,2.14,1.97,1.75,1.53,1.32,1.10,0.91,0.72,0.56,0.40,0.25,0.10,0.03,-0.05,-0.03,0.00)
    XCLCLATCT = (0.04,0.05,0.05,0.05,0.05,0.05,0.04,0.04,0.03,0.03,0.03,0.03,0.03,0.03,0.02,0.02,0.01,0.01,
              0.00,0.00,0.00,-0.01,-0.01,-0.02,-0.02,-0.02,-0.02,-0.03,-0.03,-0.03,-0.03,-0.04,-0.04,-0.04,-0.04,-0.04,-0.04)
    XCTCAFTOC = (0.00,0.05,0.09,0.15,0.21,0.31,0.40,0.51,0.62,0.73,0.84,0.95,1.06,1.16,1.25,1.34,1.43,1.50,
              1.57,1.61,1.65,1.67,1.68,1.65,1.62,1.56,1.50,1.40,1.30,1.17,1.03,0.88,0.72,0.55,0.37,0.19,0.00)
    XCTCFWDOC = (0.00,0.15,0.30,0.45,0.60,0.72,0.84,0.97,1.10,1.20,1.30,1.38,1.45,1.48,1.51,1.51,1.51,1.47,
              1.43,1.36,1.28,1.19,1.10,1.00,0.90,0.80,0.70,0.58,0.45,0.36,0.27,0.20,0.13,0.09,0.04,0.02,0.00)
    XCLCLATOC = (0.42,0.38,0.33,0.23,0.13,-0.04,-0.21,-0.33,-0.44,-0.44,-0.43,-0.31,-0.18,-0.04,0.10,0.13,0.16,
              0.08,0.00,0.00,0.00,0.07,0.14,0.18,0.22,0.23,0.24,0.20,0.15,0.02,-0.11,-0.21,-0.30,-0.37,-0.43,-0.47,-0.50)
    # COEFICIENTES LONGITUDINALES DE CORRIENTE 
    # CORRECCION POR PROFUNDIDAD
    #ddmC = {1.1:1.75,1.2:1.50,1.5:1.38,2.0:1.25}
    # WIND DRAG FORCE COEFFICIENTS
    # BALLAST CONDITIONS
    BCTWAFTGC = (0.00,0.10,0.20,0.30,0.41,0.56,0.70,0.86,1.02,1.15,1.28,1.39,1.50,1.58,1.67,1.74,1.80,
                 1.85,1.90,1.94,1.97,1.99,2.00,2.00,1.99,1.94,1.89,1.79,1.68,1.54,1.40,1.21,1.02,0.70,0.37,0.19,0.00)
    BCTWFWDGC = (0.00,0.23,0.46,0.66,0.86,1.06,1.25,1.42,1.59,1.67,1.75,1.80,1.84,1.85,1.86,1.85,1.83,
                 1.79,1.75,1.68,1.60,1.51,1.42,1.33,1.24,1.14,1.04,0.93,0.82,0.71,0.59,0.46,0.33,0.22,0.11,0.06,0.00)
    BCLWLATGC = (0.85,0.81,0.76,0.76,0.77,0.76,0.75,0.69,0.64,0.56,0.49,0.43,0.36,0.31,0.26,0.23,0.21,0.20,
                 0.19,0.00,-0.19,-0.26,-0.33,-0.39,-0.44,-0.49,-0.53,-0.57,-0.60,-0.62,-0.63,-0.63,-0.63,-0.62,-0.61,-0.59,-0.58)
    BCTWAFTCT = (-0.06,0.09,0.24,0.43,0.62,0.85,1.07,1.32,1.56,1.75,1.95,2.10,2.24,2.37,2.50,2.60,2.70,
                 2.78,2.85,2.91,2.97,3.01,3.05,3.07,3.09,3.03,2.96,2.77,2.57,2.31,2.04,1.72,1.41,1.07,0.74,0.43,0.13)
    BCTWFWDCT = (0.00,0.29,0.58,0.88,1.18,1.49,1.80,2.07,2.34,2.52,2.70,2.82,2.94,2.99,3.04,3.02,3.01,
                 2.95,2.90,2.81,2.73,2.61,2.48,2.34,2.19,2.01,1.83,1.64,1.45,1.23,1.01,0.78,0.56,0.37,0.19,0.07,-0.06)
    BCLWLATCT = (0.64,0.64,0.63,0.63,0.64,0.63,0.62,0.59,0.55,0.46,0.38,0.34,0.31,0.32,0.34,0.35,0.37,
                 0.35,0.34,0.31,0.28,0.23,0.19,0.13,0.07,-0.01,-0.09,-0.19,-0.28,-0.38,-0.47,-0.53,-0.59,-0.61,-0.64,-0.60,-0.57)
    BCTWAFTOC = (0.00,0.11,0.22,0.38,0.54,0.72,0.90,1.08,1.26,1.43,1.60,1.75,1.90,2.06,2.21,2.33,2.45,
                 2.53,2.62,2.67,2.72,2.73,2.74,2.73,2.71,2.65,2.58,2.41,2.25,2.02,1.80,1.54,1.29,0.99,0.69,0.35,0.00)
    BCTWFWDOC = (0.00,0.22,0.45,0.69,0.93,1.17,1.40,1.63,1.87,2.06,2.26,2.35,2.44,2.44,2.45,2.40,2.35,
                 2.26,2.17,2.04,1.91,1.77,1.62,1.46,1.29,1.12,0.96,0.82,0.67,0.53,0.40,0.30,0.20,0.14,0.07,0.04,0.00)
    BCLWLATOC = (1.20,1.11,1.03,0.94,0.85,0.75,0.65,0.55,0.45,0.37,0.29,-0.05,-0.38,-0.51,-0.64,-0.64,
                 -0.64,-0.51,-0.38,-0.26,-0.14,-0.18,-0.22,-0.30,-0.37,-0.43,-0.50,-0.56,-0.63,-0.68,-0.73,-0.77,-0.81,-0.82,-0.84,-0.82,-0.80)
    # LOADED CONDITIONS
    LCTWAFTGC = (0.00,0.13,0.26,0.39,0.52,0.66,0.79,0.93,1.06,1.19,1.32,1.40,1.49,1.55,1.61,1.66,1.71,1.74,
                 1.78,1.82,1.86,1.89,1.92,1.93,1.94,1.90,1.86,1.75,1.64,1.52,1.39,1.20,1.01,0.69,0.37,0.18,0.00)
    LCTWFWDGC = (0.00,0.18,0.35,0.52,0.68,0.85,1.02,1.17,1.33,1.43,1.52,1.57,1.62,1.64,1.65,1.65,1.64,1.61,
                 1.58,1.53,1.48,1.42,1.36,1.27,1.19,1.09,0.99,0.89,0.79,0.67,0.55,0.42,0.29,0.19,0.09,0.05,0.00)
    LCLWLATGC = (1.18,1.12,1.05,1.05,1.04,1.06,1.07,1.06,1.06,1.02,0.98,0.89,0.80,0.69,0.58,0.46,0.34,0.20,
                 0.07,-0.12,-0.31,-0.39,-0.47,-0.52,-0.57,-0.60,-0.64,-0.69,-0.73,-0.77,-0.81,-0.83,-0.85,-0.83,-0.81,-0.76,-0.71)
    LCTWAFTCT = (0.06,0.15,0.25,0.38,0.52,0.71,0.90,1.14,1.38,1.58,1.79,1.95,2.10,2.23,2.35,2.44,2.54,2.60,
                 2.67,2.72,2.76,2.79,2.81,2.82,2.83,2.77,2.71,2.51,2.31,2.02,1.72,1.40,1.08,0.78,0.49,0.28,0.08)
    LCTWFWDCT = (0.00,0.23,0.45,0.68,0.91,1.24,1.56,1.84,2.13,2.35,2.58,2.71,2.84,2.84,2.85,2.80,2.76,2.66,
                 2.57,2.46,2.36,2.25,2.14,2.02,1.89,1.74,1.58,1.42,1.26,1.05,0.84,0.62,0.40,0.25,0.09,0.01,-0.07)
    LCLWLATCT = (0.54,0.56,0.59,0.60,0.61,0.62,0.62,0.59,0.55,0.48,0.42,0.39,0.36,0.37,0.38,0.39,0.40,0.40,
                 0.40,0.36,0.33,0.25,0.16,0.04,-0.09,-0.24,-0.38,-0.50,-0.62,-0.69,-0.77,-0.69,-0.61,-0.56,-0.50,-0.51,-0.51)
    LCTWAFTOC = (0.00,0.11,0.21,0.37,0.54,0.71,0.89,1.07,1.25,1.39,1.53,1.63,1.74,1.82,1.91,1.97,2.04,2.09,
                 2.14,2.17,2.21,2.23,2.25,2.25,2.25,2.22,2.19,2.11,2.03,1.85,1.66,1.44,1.21,0.94,0.67,0.34,0.00)
    LCTWFWDOC = (0.00,0.07,0.13,0.23,0.32,0.44,0.56,0.68,0.80,0.89,0.97,1.04,1.10,1.14,1.18,1.19,1.20,1.18,
                 1.15,1.09,1.04,0.98,0.92,0.86,0.80,0.73,0.66,0.59,0.52,0.45,0.39,0.32,0.26,0.20,0.14,0.07,0.00)
    LCLWLATOC = (1.82,1.77,1.72,1.65,1.58,1.48,1.39,1.28,1.18,1.05,0.92,0.79,0.65,0.52,0.38,0.26,0.14,0.04,
                 -0.06,-0.15,-0.24,-0.31,-0.39,-0.47,-0.54,-0.63,-0.72,-0.83,-0.93,-1.06,-1.19,-1.29,-1.39,-1.42,-1.45,-1.42,-1.39)
    DictDatabase = {'XCTCAFTGC':XCTCAFTGC,
                       'XCTCFWDGC':XCTCFWDGC,
                       'XCLCLATGC':XCLCLATGC,
                       'XCTCAFTCT':XCTCAFTCT,
                       'XCTCFWDCT':XCTCFWDCT,
                       'XCLCLATCT':XCLCLATCT,
                       'XCTCAFTOC':XCTCAFTOC,
                       'XCTCFWDOC':XCTCFWDOC,
                       'XCLCLATOC':XCLCLATOC,
                       'BCTWAFTGC':BCTWAFTGC,
                       'BCTWFWDGC':BCTWFWDGC,
                       'BCLWLATGC':BCLWLATGC,
                       'BCTWAFTCT':BCTWAFTCT,
                       'BCTWFWDCT':BCTWFWDCT,
                       'BCLWLATCT':BCLWLATCT,
                       'BCTWAFTOC':BCTWAFTOC,
                       'BCTWFWDOC':BCTWFWDOC,
                       'BCLWLATOC':BCLWLATOC,
                       'LCTWAFTGC':LCTWAFTGC,
                       'LCTWFWDGC':LCTWFWDGC,
                       'LCLWLATGC':LCLWLATGC,
                       'LCTWAFTCT':LCTWAFTCT,
                       'LCTWFWDCT':LCTWFWDCT,
                       'LCLWLATCT':LCLWLATCT,
                       'LCTWAFTOC':LCTWAFTOC,
                       'LCTWFWDOC':LCTWFWDOC,
                       'LCLWLATOC':LCLWLATOC}
    tmpCoefficients = DictDatabase[CODE]
    return (DIRS,tmpCoefficients)
def InterpolateCoefficients(x,y,angle):
    z = np.polyfit(x,y,5)
    p = np.poly1d(z)
    #f = interpolate.interp1d(x,y)
    #f = np.piecewise(x,y)
    value = float(p(angle))
    return value
def AQWA_Coefficients (AQWA_REF):
    AQWA_FORCE = {'WIFX':('CL','LAT'),'WIFY':('CT','FWD','AFT'),'WIFZ':('ZERO'),'WIRX':('ZERO'),'WIRY':('ZERO'),'WIRZ':('CT','FWD','AFT'),
        'CUFX':('CL','LAT'),'CUFY':('CT','FWD','AFT'),'CUFZ':('ZERO'),'CURX':('ZERO'),'CURY':('ZERO'),'CURZ':('CT','FWD','AFT')}
    return AQWA_FORCE[AQWA_REF]
def CalculateWindCurrentForces(AQWA_REF,angle):
    VesselRefAngle = 180
    #angle = VesselRefAngle - angle
    AQWA_CF = AQWA_Coefficients(AQWA_REF)
    if AQWA_REF == 'WIFX':
        type = 'Wind'
        CODE = MakeCode(type,VesselType,Loading,AQWA_CF[1],AQWA_CF[0])
        (x,y) = DataBase(CODE)
        tmpCoefficients = InterpolateCoefficients(x,y,angle)
        ForceCoefficient = tmpCoefficients*rho_air*LateralArea/10
    elif AQWA_REF == 'WIFY':
        type = 'Wind'
        CODEFWD = MakeCode(type,VesselType,Loading,AQWA_CF[1],AQWA_CF[0])
        CODEAFT = MakeCode(type,VesselType,Loading,AQWA_CF[2],AQWA_CF[0])
        (xfwd,yfwd) = DataBase(CODEFWD)
        (xaft,yaft) = DataBase(CODEAFT)
        fwdCoefficient = InterpolateCoefficients(xfwd,yfwd,angle)
        aftCoefficient = InterpolateCoefficients(xaft,yaft,angle)
        tmpCoefficients = fwdCoefficient + aftCoefficient
        ForceCoefficient = tmpCoefficients*rho_air*LateralArea/10
    elif AQWA_REF == 'WIFZ':
        ForceCoefficient = 0.0
    elif AQWA_REF == 'WIRX':
        ForceCoefficient = 0.0
    elif AQWA_REF == 'WIRY':
        ForceCoefficient = 0.0
    elif AQWA_REF == 'WIRZ':
        type = 'Wind'
        CODEFWD = MakeCode(type,VesselType,Loading,AQWA_CF[1],AQWA_CF[0])
        CODEAFT = MakeCode(type,VesselType,Loading,AQWA_CF[2],AQWA_CF[0])
        (xfwd,yfwd) = DataBase(CODEFWD)
        (xaft,yaft) = DataBase(CODEAFT)
        fwdCoefficient = InterpolateCoefficients(xfwd,yfwd,angle)
        aftCoefficient = InterpolateCoefficients(xaft,yaft,angle)
        tmpCoefficients = fwdCoefficient - aftCoefficient
        ForceCoefficient = -1*(tmpCoefficients*rho_air*LateralArea/10)*(Lpp/2)
    elif AQWA_REF == 'CUFX':
        type = 'Current'
        CODE = MakeCode(type,VesselType,Loading,AQWA_CF[1],AQWA_CF[0])
        (x,y) = DataBase(CODE)
        tmpCoefficients = InterpolateCoefficients(x,y,angle)
        DepthCorrection = DepthCorrectionFactor(WaterDepth,Draft)
        ForceCoefficient = DepthCorrection*tmpCoefficients*rho_water*Draft*Lpp/10
    elif AQWA_REF == 'CUFY':
        type = 'Current'
        CODEFWD = MakeCode(type,VesselType,Loading,AQWA_CF[1],AQWA_CF[0])
        CODEAFT = MakeCode(type,VesselType,Loading,AQWA_CF[2],AQWA_CF[0])
        (xfwd,yfwd) = DataBase(CODEFWD)
        (xaft,yaft) = DataBase(CODEAFT)
        fwdCoefficient = InterpolateCoefficients(xfwd,yfwd,angle)
        aftCoefficient = InterpolateCoefficients(xaft,yaft,angle)
        tmpCoefficients = fwdCoefficient + aftCoefficient
        #Water depth correction factors for lateral current forces
        (x,y) = LateralDepthCorrectionFactor(WaterDepth,Draft,VesselType)
        DepthCorrection = InterpolateCoefficients(x,y,angle)
        ForceCoefficient = DepthCorrection*tmpCoefficients*rho_water*Draft*Lpp/10
    elif AQWA_REF == 'CUFZ':
        ForceCoefficient = 0.0
    elif AQWA_REF == 'CURX':
        ForceCoefficient = 0.0
    elif AQWA_REF == 'CURY':
        ForceCoefficient = 0.0
    elif AQWA_REF == 'CURZ':
        type = 'Current'
        CODEFWD = MakeCode(type,VesselType,Loading,AQWA_CF[1],AQWA_CF[0])
        CODEAFT = MakeCode(type,VesselType,Loading,AQWA_CF[2],AQWA_CF[0])
        (xfwd,yfwd) = DataBase(CODEFWD)
        (xaft,yaft) = DataBase(CODEAFT)
        fwdCoefficient = InterpolateCoefficients(xfwd,yfwd,angle)
        aftCoefficient = InterpolateCoefficients(xaft,yaft,angle)
        tmpCoefficients = fwdCoefficient - aftCoefficient
        #Water depth correction factors for lateral current forces
        (x,y) = LateralDepthCorrectionFactor(WaterDepth,Draft,VesselType)
        DepthCorrection = InterpolateCoefficients(x,y,angle)
        ForceCoefficient = -1*(DepthCorrection*tmpCoefficients*rho_water*Draft*Lpp/10)*Lpp/2
    return ForceCoefficient


# Increment row numbers
for ii in range(1,NumDirections + 1):
    angle =angles[ii] # float(Cell(startRow + ii,startCol).value)
    for jj in range(1,13):
        coefficient = str(Cell(aqwaCoefficientsRow,aqwaCoefficientsCol + jj).value)
        if angle < 0.0:
            if 'X' in coefficient:
                Cell(startRow + ii,startCol + jj).value = CalculateWindCurrentForces(coefficient,abs(angle))
            else:
                Cell(startRow + ii,startCol + jj).value = -1*CalculateWindCurrentForces(coefficient,abs(angle))
        else:
            Cell(startRow + ii,startCol + jj).value = CalculateWindCurrentForces(coefficient,abs(angle))
        #Cell(startRow + ii,startCol + jj).value = VesselType
    ii = ii + 1
    
    

