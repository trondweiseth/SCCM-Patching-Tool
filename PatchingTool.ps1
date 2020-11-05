<# 
.NAME
    Patching tool
.NOTES
    Author: Trond Weiseth
    Version 3.0
#>

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$skabpatching                    = New-Object system.Windows.Forms.Form
$skabpatching.ClientSize         = New-Object System.Drawing.Point(270,181)
$skabpatching.text               = "SCCM Patching"
$skabpatching.TopMost            = $false
$skabpatching.BackColor          = [System.Drawing.ColorTranslator]::FromHtml("#000000")

$lbin                            = New-Object system.Windows.Forms.Button
$lbin.text                       = "lb in"
$lbin.width                      = 117
$lbin.height                     = 45
$lbin.location                   = New-Object System.Drawing.Point(11,11)
$lbin.Font                       = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$lbin.BackColor                  = [System.Drawing.ColorTranslator]::FromHtml("#4a90e2")
$lbin.Add_Click({ lb-in })

$lbout                           = New-Object system.Windows.Forms.Button
$lbout.text                      = "lb out"
$lbout.width                     = 117
$lbout.height                    = 45
$lbout.location                  = New-Object System.Drawing.Point(140,11)
$lbout.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$lbout.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("#4a90e2")
$lbout.Add_Click({ lb-out })

$cycle                           = New-Object system.Windows.Forms.Button
$cycle.text                      = "Update Cycle"
$cycle.width                     = 117
$cycle.height                    = 45
$cycle.location                  = New-Object System.Drawing.Point(140,67)
$cycle.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$cycle.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("#4a90e2")
$cycle.Add_Click({ update-cycle })

$check                           = New-Object system.Windows.Forms.Button
$check.text                      = "lb status"
$check.width                     = 117
$check.height                    = 45
$check.location                  = New-Object System.Drawing.Point(11,67)
$check.Font                      = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$check.BackColor                 = [System.Drawing.ColorTranslator]::FromHtml("#4a90e2")
$check.Add_Click({ lb-check })

$sc                              = New-Object system.Windows.Forms.Button
$sc.text                         = "Software Center"
$sc.width                        = 117
$sc.height                       = 45
$sc.location                     = New-Object System.Drawing.Point(11,123)
$sc.Font                         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$sc.BackColor                    = [System.Drawing.ColorTranslator]::FromHtml("#4a90e2")
$sc.Add_Click({ softwarecenter })

$rb                              = New-Object system.Windows.Forms.Button
$rb.text                         = "Reboot"
$rb.width                        = 117
$rb.height                       = 45
$rb.location                     = New-Object System.Drawing.Point(140,123)
$rb.Font                         = New-Object System.Drawing.Font('Microsoft Sans Serif',10)
$rb.BackColor                    = [System.Drawing.ColorTranslator]::FromHtml("#4a90e2")
$rb.Add_Click({ rboot })

$skabpatching.controls.AddRange(@($lbin,$lbout,$cycle,$check,$sc,$rb))
Function lb-in {
    (Get-Content "C:\lbroot\lbcheck.html" ).replace('out', 'in') | Set-Content "C:\lbroot\lbcheck.html"
    $lbcheck=(Get-Content "C:\lbroot\lbcheck.html")
    lb-check
}

Function lb-out {
    (Get-Content "C:\lbroot\lbcheck.html").replace('in', 'out') | Set-Content "C:\lbroot\lbcheck.html"
    $lbcheck=(Get-Content "C:\lbroot\lbcheck.html")
    lb-check
}

Function update-cycle {

    Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000108}"
    Invoke-WMIMethod  -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}"

    if ($?) {
        [System.Windows.Forms.Messagebox]::Show("Update cycle ran successfully.","Update cycle","0","64")
    } else {
        $oReturn=[System.Windows.Forms.MessageBox]::Show("Update cycle exited with an error.","Update cycle","5","16")
        while ($oReturn -ne "Cancel") {
            Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000108}"
            Invoke-WMIMethod  -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}"
            if ($?) {
                [System.Windows.Forms.Messagebox]::Show("Update cycle ran successfully.","Update cycle","0","64")
                break
            } else {
                $oReturn=[System.Windows.Forms.MessageBox]::Show("Update cycle exited with an error.","Update cycle","5","16")
            }
        }
    }
}

Function lb-check {

    $lbcheck=(Get-Content "C:\lbroot\lbcheck.html")
    if ($lbcheck -like '*out*') {
        [System.Windows.Forms.MessageBox]::Show("lbroot is set to 'out'","lb status","0","64")
    } else {
        [System.Windows.Forms.MessageBox]::Show("lbroot is set to 'in'","lb status","0","64")
    }
}

Function softwarecenter {
    c:\windows\ccm\clientux\scclient.exe
}

Function rboot {
    $oReturn=[System.Windows.Forms.MessageBox]::Show("Do you want to reboot?","Reboot","4","48")
    switch ($oReturn) {

        "Yes" {

            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing

            $form                           = New-Object System.Windows.Forms.Form
            $form.Text                      = 'Reboot comment'
            $form.Size                      = New-Object System.Drawing.Size(300,180)
            $form.StartPosition             = 'CenterScreen'

            $okButton                       = New-Object System.Windows.Forms.Button
            $okButton.Location              = New-Object System.Drawing.Point(75,100)
            $okButton.Size                  = New-Object System.Drawing.Size(75,23)
            $okButton.Text                  = 'OK'
            $okButton.DialogResult          = [System.Windows.Forms.DialogResult]::OK
            $form.AcceptButton              = $okButton
            $form.Controls.Add($okButton)

            $cancelButton                   = New-Object System.Windows.Forms.Button
            $cancelButton.Location          = New-Object System.Drawing.Point(150,100)
            $cancelButton.Size              = New-Object System.Drawing.Size(75,23)
            $cancelButton.Text              = 'Cancel'
            $cancelButton.DialogResult      = [System.Windows.Forms.DialogResult]::Cancel
            $form.CancelButton              = $cancelButton
            $form.Controls.Add($cancelButton)

            $label                          = New-Object System.Windows.Forms.Label
            $label.Location                 = New-Object System.Drawing.Point(10,20)
            $label.Size                     = New-Object System.Drawing.Size(280,20)
            $label.Text                     = 'Please select a reboot comment:'
            $form.Controls.Add($label)

            $listBox                        = New-Object System.Windows.Forms.ListBox
            $listBox.Location               = New-Object System.Drawing.Point(10,40)
            $listBox.Size                   = New-Object System.Drawing.Size(260,20)
            $listBox.Height                 = 45

            [void] $listBox.Items.Add('Restart for maintenance')
            [void] $listBox.Items.Add('Restart for patching')

            $form.Controls.Add($listBox)

            $form.Topmost = $true

            $result = $form.ShowDialog()

            if ($result -eq [System.Windows.Forms.DialogResult]::OK)
            {
                $rbc = $listBox.SelectedItem
            }
            shutdown /r /f /t 0 /c $rbc
        }
    }
}

[void]$skabpatching.ShowDialog()
