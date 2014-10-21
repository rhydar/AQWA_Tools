#!/usr/bin/env python
"""
RLH 2013-01-08: Python script to calculate polynomial coefficients for a composite rope
"""
import sys
import numpy as np
import math
    
def GetMaxElongation(A,B,C):
    A = float(A)
    B = float(B)
    C = float(C)
    maxElongation = 0.01*(-1.*B + math.sqrt((math.pow(B,2)-4.*A*(-100.+C))))/(2.*A)
    return maxElongation

def GetPolyCoefficients(x,y,n):
    x = np.array(x)
    y = np.array(y)
    z = np.polyfit(x,y,n)
    return z

def GetChangeInLength(x,y,Pretension):
    # Return the extension in [m] for a given pretension
    delLength = np.interp(Pretension,y,x)
    return delLength
    
def GenerateValues(A,B,C,Length,MaxBreakForce,Pretension):
    delLength = float(Length*GetMaxElongation(A,B,C)*1./10)
    x = np.linspace(0,10*delLength,11)
    x = x.tolist()
    y = []
    for i in range(len(x)):
        y.append((A*math.pow((x[i]/Length*100.),2)+
                   B*(x[i]/Length*100.)+
                   C)*MaxBreakForce/100.)
    PolyCoefficients = GetPolyCoefficients(x,y,2)
    delLength =  GetChangeInLength(x,y,Pretension)
    return (delLength,PolyCoefficients)

A = float(sys.argv[1])
B = float(sys.argv[2])
C = float(sys.argv[3])
Length = float(sys.argv[4])
MBF = 1000*float(sys.argv[5])
Pretension = 1000*float(sys.argv[6])

Outputs = GenerateValues(A,B,C,Length,MBF,Pretension)
print Outputs[0]
print Outputs[1][0]
print Outputs[1][1]
print Outputs[1][2]


    

