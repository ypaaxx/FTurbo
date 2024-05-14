import os
import sys
import math

import clr
clr.AddReferenceToFileAndPath(r'C:/Users/fura/Documents/ACT/FTurbo/FTurbo/for_testing/FTurboNative')
# clr.AddReference("FTurboNative.dll")
from FTurboNative import FCascade

def main(task):
    ExtAPI.Log.WriteMessage('main')

def update(task, R):
    obj = None
    ExtAPI.Log.WriteMessage('startet') 
    container = task.InternalObject
    activeDir = task.ActiveDirectory
    context = ExtAPI.DataModel.Context

    c_3m = task.Parameters[0].Value
    ExtAPI.Log.WriteMessage('c_3m = ' + str(c_3m))
    H_t = task.Parameters[1].Value
    ExtAPI.Log.WriteMessage('H_t = ' + str(H_t))
    K_k = task.Parameters[2].Value
    ExtAPI.Log.WriteMessage('K_k = ' + str(K_k))
    tau = task.Parameters[3].Value
    ExtAPI.Log.WriteMessage('tau = ' + str(tau))
    attack = task.Parameters[4].Value / (180/3.1416)
    ExtAPI.Log.WriteMessage('attack = ' + str(attack))
    m_f = task.Parameters[5].Value
    ExtAPI.Log.WriteMessage('m_f = ' + str(m_f))

    obj = FCascade()
    # FCascade.artikel_3b_R_func(activeDir, 0.5, 0.3, 0.0, 1.0, 1.12, 1.2)
    ExtAPI.Log.WriteMessage(activeDir)
    ExtAPI.Log.WriteMessage("matlabt")
    if R == 1:
        if c_3m == 0:
            res = obj.artikel_3b_R_func(activeDir, 0.5, 0.3, 0.0, 1.0, 1.12, 1.2)
        else:
            res = obj.artikel_3b_R_func(activeDir, c_3m, H_t, attack, math.sqrt(m_f), K_k, tau)
    elif R == 0:
        if c_3m == 0:
            res = obj.artikel_3b_S_func(activeDir, 0.5, 0.3, 0.0, 1.0, 1.12, 1.2)
        else:
            res = obj.artikel_3b_S_func(activeDir, c_3m, H_t, attack, math.sqrt(m_f), K_k, tau)

    del obj
    obj = None
    filePath = System.IO.Path.Combine(activeDir, "Inf.inf")
    fileRef = RegisterFile(FilePath=filePath)
    fileRef = None
    isRegistered = IsFileRegistered(FilePath=filePath)
    if isRegistered == True:
        fileRef = GetRegisteredFile(filePath)
    else:
        fileRef = RegisterFile(FilePath=filePath)
        AssociateFileWithContainer(fileRef, container)

    ExtAPI.Log.WriteMessage("zum ANSYS bringt") 
    outputRefs = container.GetOutputData()
    outputSet = outputRefs["TurboGeometry"]
    TurboGeometry = outputSet[0]
    TurboGeometry.INFFilename = fileRef

    ExtAPI.Log.WriteMessage("toll")

    return 0

def rotor_update(task):
    update(task, 1) 

def stator_update(task):
    update(task, 0)

if __name__ == "__main__":
    ExtAPI.Log.WriteMessage("Hello, World!")