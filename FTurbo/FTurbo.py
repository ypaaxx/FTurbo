import os
import math
import subprocess

def main(task):
    ExtAPI.Log.WriteMessage('main')

def update(task, R):
    obj = None
    ExtAPI.Log.WriteMessage('startet') 
    container = task.InternalObject
    activeDir = task.ActiveDirectory
    extensionDir = ExtAPI.ExtensionManager.CurrentExtension.InstallDir
    context = ExtAPI.DataModel.Context

    c_3m = task.Parameters[0].Value
    ExtAPI.Log.WriteMessage('c_3m = ' + str(c_3m))
    H_t = task.Parameters[1].Value
    ExtAPI.Log.WriteMessage('H_t = ' + str(H_t))
    K_k = task.Parameters[2].Value
    ExtAPI.Log.WriteMessage('K_k = ' + str(K_k))
    tau = task.Parameters[3].Value
    ExtAPI.Log.WriteMessage('tau = ' + str(tau))
    attack = task.Parameters[4].Value * math.pi/180
    ExtAPI.Log.WriteMessage('attack = ' + str(attack))
    m_f = task.Parameters[5].Value
    ExtAPI.Log.WriteMessage('m_f = ' + str(m_f))

    ExtAPI.Log.WriteMessage(activeDir)
    ExtAPI.Log.WriteMessage("matlabt")

    if c_3m == 0:  
            c_3m = 0.5
            H_t = 0.3
            K_k = 1.12
            tau = 1.2
            attack = -2*math.pi/180
            m_f = 1.0

    if R == 1:
        programm = extensionDir + "/artikel_3b_R_func.exe";
    elif R == 0:
        programm = extensionDir + "/artikel_3b_S_func.exe";

    args = [programm, '-c_3m', str(c_3m), '-Ht', str(H_t), '-dir', activeDir, '-k', str(K_k), '-tau', str(tau), '-i', str(attack), '-m', str(m_f)]
    subprocess.call(args)

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