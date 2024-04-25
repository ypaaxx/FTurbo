import os
import math

import clr
clr.AddReference("FTurboNative")
from FTurboNative import *

def main(task):
    ExtAPI.Log.WriteMessage('main')

def Macher_update(task):

    ExtAPI.Log.WriteMessage('startet') 
    container = task.InternalObject
    activeDir = task.ActiveDirectory

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
    ExtAPI.Log.WriteMessage(activeDir)
    ExtAPI.Log.WriteMessage("matlabt")
    if c_3m == 0:
        obj.artikel_3b_R_func(activeDir, 0.5, 0.3, 0.0, 1.2, 1.12, 1.6)
    else:
        obj.artikel_3b_R_func(activeDir, c_3m, H_t, attack, math.sqrt(m_f), K_k, tau)
    del obj

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

    # reload(FTurboNative)
    return 0

if __name__ == "__main__":
    print("Hello, World!")