Add-Type -AssemblyName PresentationFramework

function Install-SelectedPackages {

    # Set Chocolatey path
    $chocoPath = [Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
    if (-not $chocoPath) {
        $chocoPath = "C:\ProgramData\chocolatey"
    }
    $chocoExe = "$chocoPath\choco.exe"
    
    # Check if Chocolatey is installed
    if (-not (Test-Path $chocoExe)) {
        $result = [System.Windows.MessageBox]::Show(
            "Chocolatey is not installed. Do you want to install it now?",
            "Chocolatey Required",
            [System.Windows.MessageBoxButton]::YesNo,
            [System.Windows.MessageBoxImage]::Question
        )
        
        if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
                
                # Verify if the installation succeeded
                if (-not (Test-Path $chocoExe)) {
                    throw "Chocolatey installation failed"
                }
            }
            catch {
                [System.Windows.MessageBox]::Show("Failed to install Chocolatey. Error: $($_.Exception.Message)", "Installation Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
                return
            }
        } else {
            return
        }
    }

    # Collect selected packages
    $selectedPackages = @()
    for ($i = 1; $i -le 50; $i++) {
        $checkbox = $window.FindName("Checkbox$i")
        if ($checkbox -and $checkbox.IsChecked -eq $true) {
            Write-Output "Selected for installation: $($checkbox.Tag)"
            $selectedPackages += $checkbox.Tag
        }
    }

    # Install selected packages
    if ($selectedPackages.Count -gt 0) {
        $installedPackages = @()
        try {
            foreach ($package in $selectedPackages) {
                Write-Output "Installing package: $package"
                $process = Start-Process -FilePath $chocoExe -ArgumentList "install $package -y" -NoNewWindow -Wait -PassThru
                
                if ($process.ExitCode -ne 0) {
                    throw "Installation of $package failed with exit code $($process.ExitCode)"
                } else {
                    $installedPackages += $package
                }
            }
            $installedPackagesList = $installedPackages -join ", "
            [System.Windows.MessageBox]::Show("Selected packages have been installed successfully: $installedPackagesList", "Installation Complete", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)
        }
        catch {
            [System.Windows.MessageBox]::Show("An error occurred during installation: $($_.Exception.Message)", "Installation Error", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Error)
        }
    } else {
        [System.Windows.MessageBox]::Show("No packages were selected for installation.", "No Selection", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning)
    }
}

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ChocoView" Height="500" Width="700" Background="#1E1E1E">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#1D4ED8"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Margin" Value="10"/>
            <Setter Property="Padding" Value="10,5"/>
            <Setter Property="FontSize" Value="14"/>
            <Setter Property="BorderBrush" Value="Transparent"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="Margin" Value="5"/>
            <Setter Property="Padding" Value="5,3"/>
            <Setter Property="FontSize" Value="14"/>
        </Style>
        <Style TargetType="TabItem">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontWeight" Value="Bold"/>
            <Setter Property="MinWidth" Value="125"/>
            <Setter Property="Padding" Value="10"/>
            <Setter Property="Background" Value="#374151"/>
            <Setter Property="BorderBrush" Value="Transparent"/>
            <Setter Property="Margin" Value="5"/>
            <Style.Triggers>
                <Trigger Property="IsSelected" Value="True">
                    <Setter Property="Foreground" Value="Black"/>
                    <Setter Property="Background" Value="#FFFFFF"/>
                </Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="TextBlock">
            <Setter Property="Foreground" Value="White"/>
            <Setter Property="FontSize" Value="16"/>
            <Setter Property="FontWeight" Value="Bold"/>
        </Style>
</Window.Resources>
<DockPanel>
    <TabControl Background="#2D2D30" BorderBrush="#1E1E1E" DockPanel.Dock="Top">
        <!-- Cleanup Section -->
        <TabItem Header="Cleanup">
            <StackPanel>
                <TextBlock Text="Select cleanup tools to install:" Margin="10"/>
                <CheckBox Content="CCleaner" Tag="ccleaner" x:Name="Checkbox1" 
                         ToolTip="CCleaner: A utility used to clean potentially unwanted files and invalid Windows Registry entries."/>
                <CheckBox Content="BleachBit" Tag="bleachbit" x:Name="Checkbox2" 
                         ToolTip="BleachBit: Deletes unnecessary files to free valuable disk space, maintain privacy, and remove junk."/>
            </StackPanel>
        </TabItem>

        <!-- Performance Section -->
        <TabItem Header="Performance">
            <StackPanel>
                <TextBlock Text="Select performance tools to install:" Margin="10"/>
                <CheckBox Content="Sysinternals Suite" Tag="sysinternals" x:Name="Checkbox3" 
                         ToolTip="Sysinternals Suite: A suite of tools to manage, diagnose, troubleshoot, and monitor Windows systems."/>
                <CheckBox Content="Wise Disk Cleaner" Tag="wise-disk-cleaner" x:Name="Checkbox4" 
                         ToolTip="Wise Disk Cleaner: A free, fast, and easy-to-use application developed to free up disk space by deleting junk files."/>
            </StackPanel>
        </TabItem>

        <!-- Security Section -->
        <TabItem Header="Security">
            <StackPanel>
                <TextBlock Text="Select security tools to install:" Margin="10"/>
                <CheckBox Content="Avast Free Antivirus" Tag="avastfreeantivirus" x:Name="Checkbox5" 
                         ToolTip="Avast Free Antivirus: A free antivirus program to protect against viruses and malware."/>
                <CheckBox Content="AVG Antivirus Free" Tag="avgantivirusfree" x:Name="Checkbox6" 
                         ToolTip="AVG Antivirus Free: A free antivirus solution to protect your PC against viruses, malware, and other threats."/>
                <CheckBox Content="Bitdefender" Tag="bitdefenderavfree" x:Name="Checkbox7" 
                         ToolTip="Bitdefender: A comprehensive antivirus and internet security software."/>
            </StackPanel>
        </TabItem>

        <!-- Maintenance Section -->
        <TabItem Header="Maintenance">
            <StackPanel>
                <TextBlock Text="Select maintenance tools to install:" Margin="10"/>
                <CheckBox Content="7-Zip" Tag="7zip" x:Name="Checkbox8" 
                         ToolTip="7-Zip: A file archiver with a high compression ratio."/>
                <CheckBox Content="Notepad++" Tag="notepadplusplus" x:Name="Checkbox9" 
                         ToolTip="Notepad++: A free source code editor and Notepad replacement that supports several languages."/>
                <CheckBox Content="WinSCP" Tag="winscp" x:Name="Checkbox10" 
                         ToolTip="WinSCP: A free SFTP, SCP, and FTP client for Windows."/>
            </StackPanel>
        </TabItem>

        <!-- Browsers Section -->
        <TabItem Header="Browsers">
            <StackPanel>
                <TextBlock Text="Select browsers to install:" Margin="10"/>
                <CheckBox Content="Google Chrome" Tag="googlechrome" x:Name="Checkbox11" 
                         ToolTip="Google Chrome: A fast, simple, and secure web browser built for the modern web."/>
                <CheckBox Content="Mozilla Firefox" Tag="firefox" x:Name="Checkbox12" 
                         ToolTip="Firefox: A free and open-source web browser developed by the Mozilla Foundation."/>
                <CheckBox Content="Opera" Tag="opera" x:Name="Checkbox13" 
                         ToolTip="Opera: A fast and secure web browser with a built-in ad blocker and VPN."/>
                <CheckBox Content="Microsoft Edge" Tag="microsoft-edge" x:Name="Checkbox14" 
                         ToolTip="Microsoft Edge: Microsoft Edge browser, based on the Chromium open source browser.."/>
                <CheckBox Content="Tor Browser" Tag="tor-browser" x:Name="Checkbox15" 
                         ToolTip="Tor Browser: Protect your privacy with the Tor Browser Bundle."/>
            </StackPanel>
        </TabItem>

        <!-- Development Tools Section -->
        <TabItem Header="Development Tools">
            <StackPanel>
                <TextBlock Text="Select development tools to install:" Margin="10"/>
                <CheckBox Content="Visual Studio Code" Tag="vscode" x:Name="Checkbox16" 
                         ToolTip="Visual Studio Code: A lightweight but powerful code editor for Windows."/>
                <CheckBox Content="Sublime Text" Tag="sublimetext3" x:Name="Checkbox17" 
                         ToolTip="Sublime Text: A sophisticated text editor for code, markup and prose."/>
                <CheckBox Content="PyCharm" Tag="pycharm" x:Name="Checkbox18" 
                         ToolTip="PyCharm: A Python IDE with complete set of tools for productive development with Python."/>
                <CheckBox Content="Eclipse IDE" Tag="eclipse" x:Name="Checkbox19" 
                         ToolTip="Eclipse: An IDE used primarily for Java development."/>
                <CheckBox Content="Postman" Tag="postman" x:Name="Checkbox20" 
                         ToolTip="Postman: A collaboration platform for API development."/>
            </StackPanel>
        </TabItem>

        <!-- Multimedia Section -->
        <TabItem Header="Multimedia">
            <StackPanel>
                <TextBlock Text="Select multimedia tools to install:" Margin="10"/>
                <CheckBox Content="Spotify" Tag="spotify" x:Name="Checkbox21" 
                         ToolTip="Spotify: A digital music service that gives you access to millions of songs."/>
                <CheckBox Content="Audacity" Tag="audacity" x:Name="Checkbox22" 
                         ToolTip="Audacity: A free, open source, cross-platform audio software."/>
                <CheckBox Content="GIMP" Tag="gimp" x:Name="Checkbox23" 
                         ToolTip="GIMP: A free and open-source image editor."/>
                <CheckBox Content="VLC Media Player" Tag="vlc" x:Name="Checkbox24" 
                         ToolTip="VLC Media Player: A free and open-source cross-platform multimedia player."/>
                <CheckBox Content="Blender" Tag="blender" x:Name="Checkbox25" 
                         ToolTip="Blender: A free and open-source 3D creation suite."/>
            </StackPanel>
        </TabItem>

        <!-- Office Tools Section -->
        <TabItem Header="Office Tools">
            <StackPanel>
                <TextBlock Text="Select office tools to install:" Margin="10"/>
                <CheckBox Content="LibreOffice" Tag="libreoffice-fresh" x:Name="Checkbox26" 
                         ToolTip="LibreOffice: A powerful office suite that's free and open source."/>
                <CheckBox Content="WPS Office" Tag="wps-office-free" x:Name="Checkbox27" 
                         ToolTip="WPS Office: A complete office suite with Writer, Presentation and Spreadsheet."/>
                <CheckBox Content="Foxit Reader" Tag="foxitreader" x:Name="Checkbox28" 
                         ToolTip="Foxit Reader: A fast and lightweight PDF reader."/>
                <CheckBox Content="Adobe Reader" Tag="adobereader" x:Name="Checkbox29" 
                         ToolTip="Adobe Reader: View, print, sign, and annotate PDF files."/>
                <CheckBox Content="Evernote" Tag="evernote" x:Name="Checkbox30" 
                         ToolTip="Evernote: A note-taking, organizing, task management, and archiving app."/>
            </StackPanel>
        </TabItem>

        <!-- Utilities Section -->
        <TabItem Header="Utilities">
            <StackPanel>
                <TextBlock Text="Select utilities to install:" Margin="10"/>
                <CheckBox Content="7-Zip" Tag="7zip" x:Name="Checkbox31" 
                         ToolTip="7-Zip: A file archiver with a high compression ratio."/>
                <CheckBox Content="Notepad++" Tag="notepadplusplus" x:Name="Checkbox32" 
                         ToolTip="Notepad++: A free source code editor and Notepad replacement that supports several languages."/>
                <CheckBox Content="WinSCP" Tag="winscp" x:Name="Checkbox33" 
                         ToolTip="WinSCP: A free SFTP, SCP, and FTP client for Windows."/>
                <CheckBox Content="TreeSize" Tag="treesize" x:Name="Checkbox34" 
                         ToolTip="TreeSize: A disk space management tool."/>
                <CheckBox Content="IrfanView" Tag="irfanview" x:Name="Checkbox35" 
                         ToolTip="IrfanView: A fast and compact image viewer."/>
            </StackPanel>
        </TabItem>

        <!-- Communication Section -->
        <TabItem Header="Communication">
            <StackPanel>
                <TextBlock Text="Select communication tools to install:" Margin="10"/>
                <CheckBox Content="Skype" Tag="skype" x:Name="Checkbox36" 
                         ToolTip="Skype: Instant messaging, VoIP, and video conferencing software."/>
                <CheckBox Content="Zoom" Tag="zoom" x:Name="Checkbox37" 
                         ToolTip="Zoom: Video conferencing, online meetings, and instant messaging software."/>
                <CheckBox Content="Slack" Tag="slack" x:Name="Checkbox38" 
                         ToolTip="Slack: A collaboration and communication tool for teams."/>
                <CheckBox Content="Microsoft Teams" Tag="microsoft-teams.install" x:Name="Checkbox39" 
                         ToolTip="Microsoft Teams: A collaboration platform that combines chat, meetings, notes, and attachments."/>
                <CheckBox Content="Discord" Tag="discord" x:Name="Checkbox40" 
                         ToolTip="Discord: A VoIP, instant messaging and digital distribution platform."/>
            </StackPanel>
        </TabItem>

        <!-- Games Entertainment Section -->
        <TabItem Header="Games">
            <StackPanel>
                <TextBlock Text="Select games and entertainment tools to install:" Margin="10"/>
                <CheckBox Content="Steam" Tag="steam" x:Name="Checkbox41" 
                         ToolTip="Steam: A video game digital distribution service."/>
                <CheckBox Content="Epic Games Launcher" Tag="epicgameslauncher" x:Name="Checkbox42" 
                         ToolTip="Epic Games Launcher: A video game digital distribution service."/>
                <CheckBox Content="GOG Galaxy" Tag="goggalaxy" x:Name="Checkbox43" 
                         ToolTip="GOG Galaxy: A gaming client for managing, installing and launching games."/>
                <CheckBox Content="Twitch" Tag="twitch" x:Name="Checkbox44" 
                         ToolTip="Twitch: A live streaming platform for video games."/>
                <CheckBox Content="OBS Studio" Tag="obs-studio" x:Name="Checkbox45" 
                         ToolTip="OBS Studio: Free and open source software for video recording and live streaming."/>
            </StackPanel>
        </TabItem>

        <!-- Cloud Storage Section -->
        <TabItem Header="Cloud Storage">
            <StackPanel>
                <TextBlock Text="Select cloud storage tools to install:" Margin="10"/>
                <CheckBox Content="Dropbox" Tag="dropbox" x:Name="Checkbox46" 
                         ToolTip="Dropbox: An online storage service to back up and share files."/>
                <CheckBox Content="Google Drive" Tag="googledrive" x:Name="Checkbox47" 
                         ToolTip="Google Drive: An online file storage and synchronization service."/>
                <CheckBox Content="OneDrive" Tag="onedrive" x:Name="Checkbox48" 
                         ToolTip="OneDrive: An online storage service from Microsoft."/>
                <CheckBox Content="pCloud" Tag="pcloud" x:Name="Checkbox49" 
                         ToolTip="pCloud: A secure and simple-to-use cloud storage service."/>
            </StackPanel>
        </TabItem>
        
        <!-- VPN Section -->
        <TabItem Header="VPN">
            <StackPanel>
                <TextBlock Text="Select VPN tools to install:" Margin="10"/>
                <CheckBox Content="NordVPN" Tag="nordvpn" x:Name="Checkbox50" 
                        ToolTip="NordVPN: A virtual private network service provider."/>
                <CheckBox Content="ExpressVPN" Tag="expressvpn" x:Name="Checkbox51" 
                        ToolTip="ExpressVPN: A high-speed, secure, and anonymous VPN service."/>
                <CheckBox Content="CyberGhost" Tag="cyberghost" x:Name="Checkbox52" 
                        ToolTip="CyberGhost: A VPN service that encrypts your internet connection."/>
                <CheckBox Content="Surfshark" Tag="surfshark" x:Name="Checkbox53" 
                        ToolTip="Surfshark: A VPN service that provides privacy and security."/>
            </StackPanel>
        </TabItem>

    </TabControl>
    <StackPanel DockPanel.Dock="Bottom" VerticalAlignment="Bottom" HorizontalAlignment="Center">
        <ProgressBar x:Name="InstallProgressBar" Width="300" Height="20" Margin="10" Minimum="0" Maximum="100"/>
        <Button Content="Install Selected Packages" x:Name="InstallButton" Width="300" Height="30" HorizontalAlignment="Center"/>
    </StackPanel>
</DockPanel>
</Window>
"@

$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Add event handler for Install Button
$installButton = $window.FindName("InstallButton")
$installButton.Add_Click({ Install-SelectedPackages })

# Show the window 
$null = $window.ShowDialog()
