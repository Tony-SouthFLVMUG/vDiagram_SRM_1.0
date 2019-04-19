<# 
.SYNOPSIS 
   vDiagram SRM Visio Drawing Tool

.DESCRIPTION
   vDiagram SRM Visio Drawing Tool

.NOTES 
   File Name	: vDiagram_SRM_1.0.1.ps1 
   Author		: Tony Gonzalez
   Author		: Jason Hopkins
   Based on		: vDiagram by Alan Renouf
   Version		: 1.0.1

.USAGE NOTES
	Ensure to unblock files before unzipping
	Ensure to run as administrator
	Required Files:
		PowerCLI or PowerShell 5.0 with PowerCLI Modules installed
		Active connection to vCenter to capture data
		MS Visio

.CHANGE LOG
	- 04/16/2019 - v1.0.1
		Initial build
#>

#region ~~< Constructor >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void][System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework")
#endregion ~~< Constructor >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#region ~~< Post-Constructor Custom Code >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< About >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DateTime = (Get-Date -format "yyyy_MM_dd-HH_mm")
$MyVer = "1.0.1"
$LastUpdated = "April 16, 2019"
$About = 
@"

	vDiagram SRM $MyVer
	
	Contributors:	Tony Gonzalez
			Jason Hopkins
	
	Description:	vDiagram SRM $MyVer - Based off of Alan Renouf's vDiagram
	
	Created:		April 16, 2019
	
	Last Updated:	$LastUpdated                   

"@
#endregion ~~< About >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< TestShapes >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TestShapes = [System.Environment]::GetFolderPath('MyDocuments') + "\My Shapes\vDiagram_SRM_" + $MyVer + ".vssx"
if (!(Test-Path $TestShapes))
{
	$CurrentLocation = Get-Location
	$UpdatedShapes = "$CurrentLocation" + "\vDiagram_SRM_" + "$MyVer" + ".vssx"
	copy $UpdatedShapes $TestShapes
	Write-Host "Copying Shapes File to My Shapes"
}
$shpFile = "\vDiagram_SRM_" + $MyVer + ".vssx"
#endregion ~~< TestShapes >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Set_WindowStyle >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Set_WindowStyle
{
param(
    [Parameter()]
    [ValidateSet('FORCEMINIMIZE', 'HIDE', 'MAXIMIZE', 'MINIMIZE', 'RESTORE', 
                 'SHOW', 'SHOWDEFAULT', 'SHOWMAXIMIZED', 'SHOWMINIMIZED', 
                 'SHOWMINNOACTIVE', 'SHOWNA', 'SHOWNOACTIVATE', 'SHOWNORMAL')]
    $Style = 'SHOW',
    [Parameter()]
    $MainWindowHandle = (Get-Process -Id $pid).MainWindowHandle
)
    $WindowStates = @{
        FORCEMINIMIZE   = 11; HIDE            = 0
        MAXIMIZE        = 3;  MINIMIZE        = 6
        RESTORE         = 9;  SHOW            = 5
        SHOWDEFAULT     = 10; SHOWMAXIMIZED   = 3
        SHOWMINIMIZED   = 2;  SHOWMINNOACTIVE = 7
        SHOWNA          = 8;  SHOWNOACTIVATE  = 4
        SHOWNORMAL      = 1
    }
    Write-Verbose ("Set Window Style {1} on handle {0}" -f $MainWindowHandle, $($WindowStates[$style]))

    $Win32ShowWindowAsync = Add-Type –memberDefinition @” 
    [DllImport("user32.dll")] 
    public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
“@ -name “Win32ShowWindowAsync” -namespace Win32Functions –passThru

    $Win32ShowWindowAsync::ShowWindowAsync($MainWindowHandle, $WindowStates[$Style]) | Out-Null
}
Set_WindowStyle MINIMIZE
#endregion ~~< Set_WindowStyle >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< About_Config >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function About_Config 
{
	$About

    # Add objects for About
    $AboutForm = New-Object System.Windows.Forms.Form
    $AboutTextBox = New-Object System.Windows.Forms.RichTextBox
    
    # About Form
    $AboutForm.Icon = $Icon
    $AboutForm.AutoScroll = $True
    $AboutForm.ClientSize = New-Object System.Drawing.Size(464,500)
    $AboutForm.DataBindings.DefaultDataSourceUpdateMode = 0
    $AboutForm.Name = "About"
    $AboutForm.StartPosition = 1
    $AboutForm.Text = "About vDiagram SRM $MyVer"
    
    $AboutTextBox.Anchor = 15
    $AboutTextBox.BackColor = [System.Drawing.Color]::FromArgb(255,240,240,240)
    $AboutTextBox.BorderStyle = 0
    $AboutTextBox.Font = "Tahoma"
    $AboutTextBox.DataBindings.DefaultDataSourceUpdateMode = 0
    $AboutTextBox.Location = New-Object System.Drawing.Point(13,13)
    $AboutTextBox.Name = "AboutTextBox"
    $AboutTextBox.ReadOnly = $True
    $AboutTextBox.Size = New-Object System.Drawing.Size(440,500)
    $AboutTextBox.Text = $About
        
    $AboutForm.Controls.Add($AboutTextBox)
    $AboutForm.Show() | Out-Null
}
#endregion ~~< About_Config >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Post-Constructor Custom Code >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#region ~~< Form Creation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< vDiagram >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMvDiagram = New-Object System.Windows.Forms.Form
$SRMvDiagram.ClientSize = New-Object System.Drawing.Size(1008, 661)
$CurrentLocation = Get-Location
$Icon = "$CurrentLocation" + "\vDiagram.ico"
$SRMvDiagram.Icon = $Icon
$SRMvDiagram.Text = "vDiagram SRM $MyVer"
$SRMvDiagram.BackColor = [System.Drawing.Color]::DarkCyan
#region ~~< MainMenu >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$MainMenu = New-Object System.Windows.Forms.MenuStrip
$MainMenu.Location = New-Object System.Drawing.Point(0, 0)
$MainMenu.Size = New-Object System.Drawing.Size(1008, 24)
$MainMenu.TabIndex = 1
$MainMenu.Text = "MainMenu"
#region ~~< ToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< File >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< FileToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FileToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$FileToolStripMenuItem.Size = New-Object System.Drawing.Size(37, 20)
$FileToolStripMenuItem.Text = "File"
#endregion ~~< FileToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ExitToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ExitToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$ExitToolStripMenuItem.Size = New-Object System.Drawing.Size(92, 22)
$ExitToolStripMenuItem.Text = "Exit"
$ExitToolStripMenuItem.Add_Click({$SRMvDiagram.Close()})
#endregion ~~< ExitToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FileToolStripMenuItem.DropDownItems.AddRange([System.Windows.Forms.ToolStripItem[]](@($ExitToolStripMenuItem)))
#endregion ~~< File >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Help >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< HelpToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$HelpToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$HelpToolStripMenuItem.Size = New-Object System.Drawing.Size(44, 20)
$HelpToolStripMenuItem.Text = "Help"
#endregion ~~< HelpToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< AboutToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$AboutToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$AboutToolStripMenuItem.Size = New-Object System.Drawing.Size(107, 22)
$AboutToolStripMenuItem.Text = "About"
$AboutToolStripMenuItem.Add_Click({About_Config})
#endregion ~~< AboutToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$HelpToolStripMenuItem.DropDownItems.AddRange([System.Windows.Forms.ToolStripItem[]](@($AboutToolStripMenuItem)))
#endregion ~~< Help >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$MainMenu.Items.AddRange([System.Windows.Forms.ToolStripItem[]](@($FileToolStripMenuItem, $HelpToolStripMenuItem)))
#endregion ~~< ToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< MainTab >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$MainTab = New-Object System.Windows.Forms.TabControl
$MainTab.Font = New-Object System.Drawing.Font("Tahoma", 8.25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$MainTab.ItemSize = New-Object System.Drawing.Size(85, 20)
$MainTab.Location = New-Object System.Drawing.Point(10, 30)
$MainTab.Size = New-Object System.Drawing.Size(990, 166)
$MainTab.TabIndex = 0
$MainTab.Text = "MainTabs"
#region ~~< Prerequisites >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Prerequisites = New-Object System.Windows.Forms.TabPage
$Prerequisites.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$Prerequisites.Location = New-Object System.Drawing.Point(4, 24)
$Prerequisites.Padding = New-Object System.Windows.Forms.Padding(3)
$Prerequisites.Size = New-Object System.Drawing.Size(982, 70)
$Prerequisites.TabIndex = 0
$Prerequisites.Text = "Prerequisites"
$Prerequisites.BackColor = [System.Drawing.Color]::LightGray
#region ~~< Powershell >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowershellLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PowershellLabel = New-Object System.Windows.Forms.Label
$PowershellLabel.Location = New-Object System.Drawing.Point(10, 15)
$PowershellLabel.Size = New-Object System.Drawing.Size(110, 20)
$PowershellLabel.TabIndex = 1
$PowershellLabel.Text = "Powershell:"
#endregion ~~< PowershellLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowershellInstalled >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PowershellInstalled = New-Object System.Windows.Forms.Label
$PowershellInstalled.Location = New-Object System.Drawing.Point(128, 15)
$PowershellInstalled.Size = New-Object System.Drawing.Size(600, 20)
$PowershellInstalled.TabIndex = 2
$PowershellInstalled.Text = ""
$PowershellInstalled.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< PowershellInstalled >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Powershell >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowerCli >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowerCliLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PowerCliLabel = New-Object System.Windows.Forms.Label
$PowerCliLabel.Location = New-Object System.Drawing.Point(10, 40)
$PowerCliLabel.Size = New-Object System.Drawing.Size(110, 20)
$PowerCliLabel.TabIndex = 5
$PowerCliLabel.Text = "PowerCLI:"
#endregion ~~< PowerCliLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowerCliInstalled >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PowerCliInstalled = New-Object System.Windows.Forms.Label
$PowerCliInstalled.Location = New-Object System.Drawing.Point(128, 40)
$PowerCliInstalled.Size = New-Object System.Drawing.Size(600, 20)
$PowerCliInstalled.TabIndex = 6
$PowerCliInstalled.Text = ""
$PowerCliInstalled.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< PowerCliInstalled >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< PowerCli >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowerCli Module >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowerCliModuleLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PowerCliModuleLabel = New-Object System.Windows.Forms.Label
$PowerCliModuleLabel.Location = New-Object System.Drawing.Point(10, 65)
$PowerCliModuleLabel.Size = New-Object System.Drawing.Size(110, 20)
$PowerCliModuleLabel.TabIndex = 3
$PowerCliModuleLabel.Text = "PowerCLI Module:"
#endregion ~~< PowerCliModuleLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowerCliModuleInstalled >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PowerCliModuleInstalled = New-Object System.Windows.Forms.Label
$PowerCliModuleInstalled.Location = New-Object System.Drawing.Point(128, 65)
$PowerCliModuleInstalled.Size = New-Object System.Drawing.Size(600, 20)
$PowerCliModuleInstalled.TabIndex = 4
$PowerCliModuleInstalled.Text = ""
$PowerCliModuleInstalled.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< PowerCliModuleInstalled >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< PowerCli Module >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Visio >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< VisioLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$VisioLabel = New-Object System.Windows.Forms.Label
$VisioLabel.Location = New-Object System.Drawing.Point(10, 90)
$VisioLabel.Size = New-Object System.Drawing.Size(110, 20)
$VisioLabel.TabIndex = 7
$VisioLabel.Text = "Visio:"
#endregion ~~< VisioLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< VisioInstalled >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$VisioInstalled = New-Object System.Windows.Forms.Label
$VisioInstalled.Location = New-Object System.Drawing.Point(128, 90)
$VisioInstalled.Size = New-Object System.Drawing.Size(600, 20)
$VisioInstalled.TabIndex = 8
$VisioInstalled.Text = ""
$VisioInstalled.BackColor = [System.Drawing.Color]::LightGray
$Prerequisites.Controls.Add($PowershellLabel)
$Prerequisites.Controls.Add($PowershellInstalled)
$Prerequisites.Controls.Add($PowerCliModuleLabel)
$Prerequisites.Controls.Add($PowerCliModuleInstalled)
$Prerequisites.Controls.Add($PowerCliLabel)
$Prerequisites.Controls.Add($PowerCliInstalled)
$Prerequisites.Controls.Add($VisioLabel)
$Prerequisites.Controls.Add($VisioInstalled)
#endregion ~~< VisioInstalled >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Visio >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$MainTab.Controls.Add($Prerequisites)
#endregion ~~< Prerequisites >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< InfrastructureInfo >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$InfrastructureInfo = New-Object System.Windows.Forms.TabPage
$InfrastructureInfo.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$InfrastructureInfo.Location = New-Object System.Drawing.Point(4, 24)
$InfrastructureInfo.Padding = New-Object System.Windows.Forms.Padding(3)
$InfrastructureInfo.Size = New-Object System.Drawing.Size(982, 70)
$InfrastructureInfo.TabIndex = 0
$InfrastructureInfo.Text = "Infrastructure Info"
$InfrastructureInfo.BackColor = [System.Drawing.Color]::LightGray
#region ~~< ProtectedSite >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteVcenterLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteVcenterLabel = New-Object System.Windows.Forms.Label
$ProtectedSiteVcenterLabel.Location = New-Object System.Drawing.Point(8, 16)
$ProtectedSiteVcenterLabel.Size = New-Object System.Drawing.Size(160, 30)
$ProtectedSiteVcenterLabel.TabIndex = 1
$ProtectedSiteVcenterLabel.Text = "Protected Site vCenter:"
$InfrastructureInfo.Controls.Add($ProtectedSiteVcenterLabel)
#endregion ~~< ProtectedSiteVcenterLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteVcenterTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteVcenterTextBox = New-Object System.Windows.Forms.TextBox
$ProtectedSiteVcenterTextBox.Location = New-Object System.Drawing.Point(170, 8)
$ProtectedSiteVcenterTextBox.Size = New-Object System.Drawing.Size(300, 21)
$ProtectedSiteVcenterTextBox.TabIndex = 2
$ProtectedSiteVcenterTextBox.Text = ""
$InfrastructureInfo.Controls.Add($ProtectedSiteVcenterTextBox)
#endregion ~~< ProtectedSiteVcenterTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteSrmServerLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteSrmServerLabel = New-Object System.Windows.Forms.Label
$ProtectedSiteSrmServerLabel.Location = New-Object System.Drawing.Point(483, 16)
$ProtectedSiteSrmServerLabel.Size = New-Object System.Drawing.Size(160, 20)
$ProtectedSiteSrmServerLabel.TabIndex = 3
$ProtectedSiteSrmServerLabel.Text = "Protected Site SRM Server:"
$InfrastructureInfo.Controls.Add($ProtectedSiteSrmServerLabel)
#endregion ~~< ProtectedSiteSrmServerLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteSrmServerTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteSrmServerTextBox = New-Object System.Windows.Forms.TextBox
$ProtectedSiteSrmServerTextBox.Location = New-Object System.Drawing.Point(664, 8)
$ProtectedSiteSrmServerTextBox.Size = New-Object System.Drawing.Size(300, 21)
$ProtectedSiteSrmServerTextBox.TabIndex = 4
$ProtectedSiteSrmServerTextBox.Text = ""
$InfrastructureInfo.Controls.Add($ProtectedSiteSrmServerTextBox)
#endregion ~~< ProtectedSiteSrmServerTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteConnectButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteConnectButton = New-Object System.Windows.Forms.Button
$ProtectedSiteConnectButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$ProtectedSiteConnectButton.Location = New-Object System.Drawing.Point(8, 100)
$ProtectedSiteConnectButton.Size = New-Object System.Drawing.Size(460, 30)
$ProtectedSiteConnectButton.TabIndex = 13
$ProtectedSiteConnectButton.Text = "Connect to Protected Site"
$ProtectedSiteConnectButton.UseVisualStyleBackColor = $true
$InfrastructureInfo.Controls.Add($ProtectedSiteConnectButton)
#endregion ~~< ProtectedSiteConnectButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< ProtectedSite >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteVcenterLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteVcenterLabel = New-Object System.Windows.Forms.Label
$RecoverySiteVcenterLabel.Location = New-Object System.Drawing.Point(8, 46)
$RecoverySiteVcenterLabel.Size = New-Object System.Drawing.Size(160, 30)
$RecoverySiteVcenterLabel.TabIndex = 5
$RecoverySiteVcenterLabel.Text = "Recovery Site vCenter:"
$InfrastructureInfo.Controls.Add($RecoverySiteVcenterLabel)
#endregion ~~< RecoverySiteVcenterLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteVcenterTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteVcenterTextBox = New-Object System.Windows.Forms.TextBox
$RecoverySiteVcenterTextBox.Location = New-Object System.Drawing.Point(170, 44)
$RecoverySiteVcenterTextBox.Size = New-Object System.Drawing.Size(300, 16)
$RecoverySiteVcenterTextBox.TabIndex = 6
$RecoverySiteVcenterTextBox.Text = ""
$InfrastructureInfo.Controls.Add($RecoverySiteVcenterTextBox)
#endregion ~~< RecoverySiteVcenterTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteSrmServerLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteSrmServerLabel = New-Object System.Windows.Forms.Label
$RecoverySiteSrmServerLabel.Location = New-Object System.Drawing.Point(483, 46)
$RecoverySiteSrmServerLabel.Size = New-Object System.Drawing.Size(160, 30)
$RecoverySiteSrmServerLabel.TabIndex = 7
$RecoverySiteSrmServerLabel.Text = "Recovery Site SRM Server:"
$InfrastructureInfo.Controls.Add($RecoverySiteSrmServerLabel)
#endregion ~~< RecoverySiteSrmServerLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteSrmServerTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteSrmServerTextBox = New-Object System.Windows.Forms.TextBox
$RecoverySiteSrmServerTextBox.Location = New-Object System.Drawing.Point(664, 44)
$RecoverySiteSrmServerTextBox.Size = New-Object System.Drawing.Size(300, 16)
$RecoverySiteSrmServerTextBox.TabIndex = 8
$RecoverySiteSrmServerTextBox.Text = ""
$InfrastructureInfo.Controls.Add($RecoverySiteSrmServerTextBox)
#endregion ~~< RecoverySiteSrmServerTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteConnectButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteConnectButton = New-Object System.Windows.Forms.Button
$RecoverySiteConnectButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$RecoverySiteConnectButton.Location = New-Object System.Drawing.Point(483, 100)
$RecoverySiteConnectButton.Size = New-Object System.Drawing.Size(480, 30)
$RecoverySiteConnectButton.TabIndex = 14
$RecoverySiteConnectButton.Text = "Connect to Recovery Site"
$RecoverySiteConnectButton.UseVisualStyleBackColor = $true
$InfrastructureInfo.Controls.Add($RecoverySiteConnectButton)
#endregion ~~< RecoverySiteConnectButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< RecoverySite >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Login >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< UserNameLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$UserNameLabel = New-Object System.Windows.Forms.Label
$UserNameLabel.Location = New-Object System.Drawing.Point(8, 81)
$UserNameLabel.Size = New-Object System.Drawing.Size(160, 30)
$UserNameLabel.TabIndex = 9
$UserNameLabel.Text = "User Name:"
$InfrastructureInfo.Controls.Add($UserNameLabel)
#endregion ~~< UserNameLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< UserNameTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$UserNameTextBox = New-Object System.Windows.Forms.TextBox
$UserNameTextBox.Location = New-Object System.Drawing.Point(170, 75)
$UserNameTextBox.Size = New-Object System.Drawing.Size(300, 21)
$UserNameTextBox.TabIndex = 10
$UserNameTextBox.Text = ""
$InfrastructureInfo.Controls.Add($UserNameTextBox)
#endregion ~~< UserNameTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PasswordLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PasswordLabel = New-Object System.Windows.Forms.Label
$PasswordLabel.Location = New-Object System.Drawing.Point(483, 81)
$PasswordLabel.Size = New-Object System.Drawing.Size(160, 30)
$PasswordLabel.TabIndex = 11
$PasswordLabel.Text = "Password:"
$InfrastructureInfo.Controls.Add($PasswordLabel)
#endregion ~~< PasswordLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PasswordTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PasswordTextBox = New-Object System.Windows.Forms.TextBox
$PasswordTextBox.Location = New-Object System.Drawing.Point(664, 75)
$PasswordTextBox.Size = New-Object System.Drawing.Size(300, 21)
$PasswordTextBox.TabIndex = 12
$PasswordTextBox.Text = ""
$PasswordTextBox.UseSystemPasswordChar = $true
$InfrastructureInfo.Controls.Add($PasswordTextBox)
#endregion ~~< PasswordTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Login >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$MainTab.Controls.Add($InfrastructureInfo)
#endregion  ~~< InfrastructureInfo >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$MainTab.SelectedIndex = 0
$SRMvDiagram.Controls.Add($MainTab)
#endregion ~~< MainTab >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SubTab >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SubTab = New-Object System.Windows.Forms.TabControl
$SubTab.Font = New-Object System.Drawing.Font("Tahoma", 8.25, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$SubTab.Location = New-Object System.Drawing.Point(10, 204)
$SubTab.Size = New-Object System.Drawing.Size(990, 452)
$SubTab.TabIndex = 0
$SubTab.Text = "SubTabs"
#region ~~< TabDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabDirections = New-Object System.Windows.Forms.TabPage
$TabDirections.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$TabDirections.Location = New-Object System.Drawing.Point(4, 22)
$TabDirections.Padding = New-Object System.Windows.Forms.Padding(3)
$TabDirections.Size = New-Object System.Drawing.Size(982, 486)
$TabDirections.TabIndex = 0
$TabDirections.Text = "Directions"
$TabDirections.UseVisualStyleBackColor = $true
#region ~~< Prerequisites >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PrerequisitesHeading >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PrerequisitesHeading = New-Object System.Windows.Forms.Label
$PrerequisitesHeading.Font = New-Object System.Drawing.Font("Tahoma", 11.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$PrerequisitesHeading.Location = New-Object System.Drawing.Point(8, 8)
$PrerequisitesHeading.Size = New-Object System.Drawing.Size(149, 23)
$PrerequisitesHeading.TabIndex = 0
$PrerequisitesHeading.Text = "Prerequisites Tab"
$TabDirections.Controls.Add($PrerequisitesHeading)
#endregion ~~< PrerequisitesHeading >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PrerequisitesDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PrerequisitesDirections = New-Object System.Windows.Forms.Label
$PrerequisitesDirections.Location = New-Object System.Drawing.Point(8, 32)
$PrerequisitesDirections.Size = New-Object System.Drawing.Size(900, 30)
$PrerequisitesDirections.TabIndex = 1
$PrerequisitesDirections.Text = "1. Verify that prerequisites are met on the "+[char]34+"Prerequisites"+[char]34+" tab."+[char]13+[char]10+"2. If not please install needed requirements."
$TabDirections.Controls.Add($PrerequisitesDirections)
#endregion ~~< PrerequisitesDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Prerequisites >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< vCenter >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< vCenterInfoHeading >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$vCenterInfoHeading = New-Object System.Windows.Forms.Label
$vCenterInfoHeading.Font = New-Object System.Drawing.Font("Tahoma", 11.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$vCenterInfoHeading.Location = New-Object System.Drawing.Point(8, 72)
$vCenterInfoHeading.Size = New-Object System.Drawing.Size(149, 23)
$vCenterInfoHeading.TabIndex = 2
$vCenterInfoHeading.Text = "vCenter Info Tab"
$TabDirections.Controls.Add($vCenterInfoHeading)
#endregion ~~< vCenterInfoHeading >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< vCenterInfoDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$vCenterInfoDirections = New-Object System.Windows.Forms.Label
$vCenterInfoDirections.Location = New-Object System.Drawing.Point(8, 96)
$vCenterInfoDirections.Size = New-Object System.Drawing.Size(900, 70)
$vCenterInfoDirections.TabIndex = 3
$vCenterInfoDirections.Text = "1. Click on "+[char]34+"Infrastructure Info"+[char]34+" tab."+[char]13+[char]10+"2. Enter name of vCenter."+[char]13+[char]10+"3. Enter name of SRM server."+[char]13+[char]10+"4. Enter User Name and Password (password will be hashed and not plain text)."+[char]13+[char]10+"5. Click on "+[char]34+"Connect to vCenter"+[char]34+" button for each site."
$TabDirections.Controls.Add($vCenterInfoDirections)
#endregion ~~< vCenterInfoDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< vCenter >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Capture >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureCsvHeading >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureCsvHeading = New-Object System.Windows.Forms.Label
$SRMCaptureCsvHeading.Font = New-Object System.Drawing.Font("Tahoma", 11.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$SRMCaptureCsvHeading.Location = New-Object System.Drawing.Point(8, 176)
$SRMCaptureCsvHeading.Size = New-Object System.Drawing.Size(216, 23)
$SRMCaptureCsvHeading.TabIndex = 4
$SRMCaptureCsvHeading.Text = "Capture CSVs for Visio Tab"
$TabDirections.Controls.Add($SRMCaptureCsvHeading)
#endregion ~~< SRMCaptureCsvHeading >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureDirections = New-Object System.Windows.Forms.Label
$SRMCaptureDirections.Location = New-Object System.Drawing.Point(8, 200)
$SRMCaptureDirections.Size = New-Object System.Drawing.Size(900, 65)
$SRMCaptureDirections.TabIndex = 5
$SRMCaptureDirections.Text = "1. Click on "+[char]34+"Capture CSVs for Visio"+[char]34+" tab."+[char]13+[char]10+"2. Click on "+[char]34+"Select Output Folder"+[char]34+" button and select folder where you would like to output the CSVs to."+[char]13+[char]10+"3. Select items you wish to grab data on."+[char]13+[char]10+"4. Click on "+[char]34+"Collect CSV Data"+[char]34+" button."
$TabDirections.Controls.Add($SRMCaptureDirections)
#endregion ~~< SRMCaptureDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Capture >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMDrawHeading >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMDrawHeading = New-Object System.Windows.Forms.Label
$SRMDrawHeading.Font = New-Object System.Drawing.Font("Tahoma", 11.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$SRMDrawHeading.Location = New-Object System.Drawing.Point(8, 264)
$SRMDrawHeading.Size = New-Object System.Drawing.Size(149, 23)
$SRMDrawHeading.TabIndex = 6
$SRMDrawHeading.Text = "Draw Visio Tab"
$TabDirections.Controls.Add($SRMDrawHeading)
#endregion ~~< SRMDrawHeading >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMDrawDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMDrawDirections = New-Object System.Windows.Forms.Label
$SRMDrawDirections.Location = New-Object System.Drawing.Point(8, 288)
$SRMDrawDirections.Size = New-Object System.Drawing.Size(900, 130)
$SRMDrawDirections.TabIndex = 7
$SRMDrawDirections.Text = "1. Click on "+[char]34+"Select Input Folder"+[char]34+" button and select location where CSVs can be found."+[char]13+[char]10+"2. Click on "+[char]34+"Check for CSVs"+[char]39+" button to validate presence of required files."+[char]13+[char]10+"3. Click on "+[char]34+"Select Output Folder"+[char]34+" button and select where location where you would like to save the Visio drawing."+[char]13+[char]10+"4. Select drawing that you would like to produce."+[char]13+[char]10+"5. Click on "+[char]34+"Draw Visio"+[char]34+" button."+[char]13+[char]10+"6. Click on "+[char]34+"Open Visio Drawing"+[char]34+" button once "+[char]34+"Draw Visio"+[char]34+" button says it has completed."
$TabDirections.Controls.Add($SRMDrawDirections)
#endregion ~~< SRMDrawDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Draw >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SubTab.Controls.Add($TabDirections)
#endregion ~~< TabDirections >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< TabCaptureSRM >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabCaptureSRM = New-Object System.Windows.Forms.TabPage
$TabCaptureSRM.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$TabCaptureSRM.Location = New-Object System.Drawing.Point(4, 22)
$TabCaptureSRM.Padding = New-Object System.Windows.Forms.Padding(3)
$TabCaptureSRM.Size = New-Object System.Drawing.Size(982, 486)
$TabCaptureSRM.TabIndex = 3
$TabCaptureSRM.Text = "Capture CSVs for Visio"
$TabCaptureSRM.UseVisualStyleBackColor = $true
#region ~~< CSV >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureCsvOutputLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureCsvOutputLabel = New-Object System.Windows.Forms.Label
$SRMCaptureCsvOutputLabel.Font = New-Object System.Drawing.Font("Tahoma", 15.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$SRMCaptureCsvOutputLabel.Location = New-Object System.Drawing.Point(10, 10)
$SRMCaptureCsvOutputLabel.Size = New-Object System.Drawing.Size(210, 25)
$SRMCaptureCsvOutputLabel.TabIndex = 0
$SRMCaptureCsvOutputLabel.Text = "CSV Output Folder:"
#endregion ~~< SRMCaptureCsvOutputLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureCsvOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureCsvOutputButton = New-Object System.Windows.Forms.Button
$SRMCaptureCsvOutputButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$SRMCaptureCsvOutputButton.Location = New-Object System.Drawing.Point(220, 10)
$SRMCaptureCsvOutputButton.Size = New-Object System.Drawing.Size(750, 25)
$SRMCaptureCsvOutputButton.TabIndex = 0
$SRMCaptureCsvOutputButton.Text = "Select Output Folder"
$SRMCaptureCsvOutputButton.UseVisualStyleBackColor = $false
$SRMCaptureCsvOutputButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< SRMCaptureCsvOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureCsvBrowse >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureCsvBrowse = New-Object System.Windows.Forms.FolderBrowserDialog
$SRMCaptureCsvBrowse.Description = "Select a directory"
$SRMCaptureCsvBrowse.RootFolder = [System.Environment+SpecialFolder]::MyComputer
#endregion ~~< SRMCaptureCsvBrowse >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabCaptureSRM.Controls.Add($SRMCaptureCsvOutputLabel)
$TabCaptureSRM.Controls.Add($SRMCaptureCsvOutputButton)
#endregion ~~< CSV >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSitevCenterInfoCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSitevCenterInfoCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSitevCenterInfoCsvCheckBox.Checked = $true
$ProtectedSitevCenterInfoCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSitevCenterInfoCsvCheckBox.Location = New-Object System.Drawing.Point(10, 40)
$ProtectedSitevCenterInfoCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$ProtectedSitevCenterInfoCsvCheckBox.TabIndex = 1
$ProtectedSitevCenterInfoCsvCheckBox.Text = "Export Protected Site vCenter Info"
$ProtectedSitevCenterInfoCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSitevCenterInfoCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSitevCenterInfoValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSitevCenterInfoValidationComplete = New-Object System.Windows.Forms.Label
$ProtectedSitevCenterInfoValidationComplete.Location = New-Object System.Drawing.Point(325, 40)
$ProtectedSitevCenterInfoValidationComplete.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSitevCenterInfoValidationComplete.TabIndex = 26
$ProtectedSitevCenterInfoValidationComplete.Text = ""
#endregion ~~< ProtectedSitevCenterInfoValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteSrmInfoCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteSrmInfoCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSiteSrmInfoCsvCheckBox.Checked = $true
$ProtectedSiteSrmInfoCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSiteSrmInfoCsvCheckBox.Location = New-Object System.Drawing.Point(10, 60)
$ProtectedSiteSrmInfoCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$ProtectedSiteSrmInfoCsvCheckBox.TabIndex = 1
$ProtectedSiteSrmInfoCsvCheckBox.Text = "Export Protected Site SRM Info"
$ProtectedSiteSrmInfoCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSiteSrmInfoCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteSrmInfoValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteSrmInfoValidationComplete = New-Object System.Windows.Forms.Label
$ProtectedSiteSrmInfoValidationComplete.Location = New-Object System.Drawing.Point(325, 60)
$ProtectedSiteSrmInfoValidationComplete.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteSrmInfoValidationComplete.TabIndex = 26
$ProtectedSiteSrmInfoValidationComplete.Text = ""
#endregion ~~< ProtectedSiteSrmInfoValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteRecoveryPlanCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteRecoveryPlanCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSiteRecoveryPlanCsvCheckBox.Checked = $true
$ProtectedSiteRecoveryPlanCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSiteRecoveryPlanCsvCheckBox.Location = New-Object System.Drawing.Point(10, 80)
$ProtectedSiteRecoveryPlanCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$ProtectedSiteRecoveryPlanCsvCheckBox.TabIndex = 2
$ProtectedSiteRecoveryPlanCsvCheckBox.Text = "Export Protected Site Recovery Plan Info"
$ProtectedSiteRecoveryPlanCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSiteRecoveryPlanCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteRecoveryPlanCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteRecoveryPlanCsvValidationComplete = New-Object System.Windows.Forms.Label
$ProtectedSiteRecoveryPlanCsvValidationComplete.Location = New-Object System.Drawing.Point(325, 80)
$ProtectedSiteRecoveryPlanCsvValidationComplete.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteRecoveryPlanCsvValidationComplete.TabIndex = 27
$ProtectedSiteRecoveryPlanCsvValidationComplete.Text = ""
#endregion ~~< ProtectedSiteRecoveryPlanCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteProtectionGroupCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteProtectionGroupCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSiteProtectionGroupCsvCheckBox.Checked = $true
$ProtectedSiteProtectionGroupCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSiteProtectionGroupCsvCheckBox.Location = New-Object System.Drawing.Point(10, 100)
$ProtectedSiteProtectionGroupCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$ProtectedSiteProtectionGroupCsvCheckBox.TabIndex = 3
$ProtectedSiteProtectionGroupCsvCheckBox.Text = "Export Protected Site Protection Group Info"
$ProtectedSiteProtectionGroupCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSiteProtectionGroupCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteProtectionGroupCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteProtectionGroupCsvValidationComplete = New-Object System.Windows.Forms.Label
$ProtectedSiteProtectionGroupCsvValidationComplete.Location = New-Object System.Drawing.Point(325, 100)
$ProtectedSiteProtectionGroupCsvValidationComplete.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteProtectionGroupCsvValidationComplete.TabIndex = 28
$ProtectedSiteProtectionGroupCsvValidationComplete.Text = ""
#endregion ~~< ProtectedSiteProtectionGroupCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteVMCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteVMCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSiteVMCsvCheckBox.Checked = $true
$ProtectedSiteVMCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSiteVMCsvCheckBox.Location = New-Object System.Drawing.Point(10, 120)
$ProtectedSiteVMCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$ProtectedSiteVMCsvCheckBox.TabIndex = 4
$ProtectedSiteVMCsvCheckBox.Text = "Export Protected Site VM Info"
$ProtectedSiteVMCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSiteVMCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteVMCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteVMCsvValidationComplete = New-Object System.Windows.Forms.Label
$ProtectedSiteVMCsvValidationComplete.Location = New-Object System.Drawing.Point(325, 120)
$ProtectedSiteVMCsvValidationComplete.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteVMCsvValidationComplete.TabIndex = 29
$ProtectedSiteVMCsvValidationComplete.Text = ""
#endregion ~~< ProtectedSiteVMCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteDatastoreCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteDatastoreCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSiteDatastoreCsvCheckBox.Checked = $true
$ProtectedSiteDatastoreCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSiteDatastoreCsvCheckBox.Location = New-Object System.Drawing.Point(10, 140)
$ProtectedSiteDatastoreCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$ProtectedSiteDatastoreCsvCheckBox.TabIndex = 5
$ProtectedSiteDatastoreCsvCheckBox.Text = "Export Protected Site Datastore (ABR) Info"
$ProtectedSiteDatastoreCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSiteDatastoreCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteDatastoreCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteDatastoreCsvValidationComplete = New-Object System.Windows.Forms.Label
$ProtectedSiteDatastoreCsvValidationComplete.Location = New-Object System.Drawing.Point(325, 140)
$ProtectedSiteDatastoreCsvValidationComplete.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteDatastoreCsvValidationComplete.TabIndex = 30
$ProtectedSiteDatastoreCsvValidationComplete.Text = ""
#endregion ~~< ProtectedSiteDatastoreCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabCaptureSRM.Controls.Add($ProtectedSitevCenterInfoCsvCheckBox)
$TabCaptureSRM.Controls.Add($ProtectedSitevCenterInfoValidationComplete)
$TabCaptureSRM.Controls.Add($ProtectedSiteSrmInfoCsvCheckBox)
$TabCaptureSRM.Controls.Add($ProtectedSiteSrmInfoValidationComplete)
$TabCaptureSRM.Controls.Add($ProtectedSiteRecoveryPlanCsvCheckBox)
$TabCaptureSRM.Controls.Add($ProtectedSiteRecoveryPlanCsvValidationComplete)
$TabCaptureSRM.Controls.Add($ProtectedSiteProtectionGroupCsvCheckBox)
$TabCaptureSRM.Controls.Add($ProtectedSiteProtectionGroupCsvValidationComplete)
$TabCaptureSRM.Controls.Add($ProtectedSiteVMCsvCheckBox)
$TabCaptureSRM.Controls.Add($ProtectedSiteVMCsvValidationComplete)
$TabCaptureSRM.Controls.Add($ProtectedSiteDatastoreCsvCheckBox)
$TabCaptureSRM.Controls.Add($ProtectedSiteDatastoreCsvValidationComplete)
#endregion ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySitevCenterInfoCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySitevCenterInfoCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySitevCenterInfoCsvCheckBox.Checked = $true
$RecoverySitevCenterInfoCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySitevCenterInfoCsvCheckBox.Location = New-Object System.Drawing.Point(483, 40)
$RecoverySitevCenterInfoCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$RecoverySitevCenterInfoCsvCheckBox.TabIndex = 1
$RecoverySitevCenterInfoCsvCheckBox.Text = "Export Recovery Site SRM Info"
$RecoverySitevCenterInfoCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySitevCenterInfoCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySitevCenterInfoValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySitevCenterInfoValidationComplete = New-Object System.Windows.Forms.Label
$RecoverySitevCenterInfoValidationComplete.Location = New-Object System.Drawing.Point(798, 40)
$RecoverySitevCenterInfoValidationComplete.Size = New-Object System.Drawing.Size(290, 20)
$RecoverySitevCenterInfoValidationComplete.TabIndex = 26
$RecoverySitevCenterInfoValidationComplete.Text = ""
#endregion ~~< RecoverySitevCenterInfoValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteSrmInfoCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteSrmInfoCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySiteSrmInfoCsvCheckBox.Checked = $true
$RecoverySiteSrmInfoCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySiteSrmInfoCsvCheckBox.Location = New-Object System.Drawing.Point(483, 60)
$RecoverySiteSrmInfoCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$RecoverySiteSrmInfoCsvCheckBox.TabIndex = 1
$RecoverySiteSrmInfoCsvCheckBox.Text = "Export Recovery Site SRM Info"
$RecoverySiteSrmInfoCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySiteSrmInfoCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteSrmInfoValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteSrmInfoValidationComplete = New-Object System.Windows.Forms.Label
$RecoverySiteSrmInfoValidationComplete.Location = New-Object System.Drawing.Point(798, 60)
$RecoverySiteSrmInfoValidationComplete.Size = New-Object System.Drawing.Size(290, 20)
$RecoverySiteSrmInfoValidationComplete.TabIndex = 26
$RecoverySiteSrmInfoValidationComplete.Text = ""
#endregion ~~< RecoverySiteSrmInfoValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteRecoveryPlanCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteRecoveryPlanCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySiteRecoveryPlanCsvCheckBox.Checked = $true
$RecoverySiteRecoveryPlanCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySiteRecoveryPlanCsvCheckBox.Location = New-Object System.Drawing.Point(483, 80)
$RecoverySiteRecoveryPlanCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$RecoverySiteRecoveryPlanCsvCheckBox.TabIndex = 2
$RecoverySiteRecoveryPlanCsvCheckBox.Text = "Export Recovery Site Recovery Plan Info"
$RecoverySiteRecoveryPlanCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySiteRecoveryPlanCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteRecoveryPlanCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteRecoveryPlanCsvValidationComplete = New-Object System.Windows.Forms.Label
$RecoverySiteRecoveryPlanCsvValidationComplete.Location = New-Object System.Drawing.Point(798, 80)
$RecoverySiteRecoveryPlanCsvValidationComplete.Size = New-Object System.Drawing.Size(290, 20)
$RecoverySiteRecoveryPlanCsvValidationComplete.TabIndex = 27
$RecoverySiteRecoveryPlanCsvValidationComplete.Text = ""
#endregion ~~< RecoverySiteRecoveryPlanCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteProtectionGroupCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteProtectionGroupCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySiteProtectionGroupCsvCheckBox.Checked = $true
$RecoverySiteProtectionGroupCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySiteProtectionGroupCsvCheckBox.Location = New-Object System.Drawing.Point(483, 100)
$RecoverySiteProtectionGroupCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$RecoverySiteProtectionGroupCsvCheckBox.TabIndex = 3
$RecoverySiteProtectionGroupCsvCheckBox.Text = "Export Recovery Site Protection Group Info"
$RecoverySiteProtectionGroupCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySiteProtectionGroupCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteProtectionGroupCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteProtectionGroupCsvValidationComplete = New-Object System.Windows.Forms.Label
$RecoverySiteProtectionGroupCsvValidationComplete.Location = New-Object System.Drawing.Point(798, 100)
$RecoverySiteProtectionGroupCsvValidationComplete.Size = New-Object System.Drawing.Size(290, 20)
$RecoverySiteProtectionGroupCsvValidationComplete.TabIndex = 28
$RecoverySiteProtectionGroupCsvValidationComplete.Text = ""
#endregion ~~< RecoverySiteProtectionGroupCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteVMCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteVMCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySiteVMCsvCheckBox.Checked = $true
$RecoverySiteVMCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySiteVMCsvCheckBox.Location = New-Object System.Drawing.Point(483, 120)
$RecoverySiteVMCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$RecoverySiteVMCsvCheckBox.TabIndex = 4
$RecoverySiteVMCsvCheckBox.Text = "Export Recovery Site VM Info"
$RecoverySiteVMCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySiteVMCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteVMCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteVMCsvValidationComplete = New-Object System.Windows.Forms.Label
$RecoverySiteVMCsvValidationComplete.Location = New-Object System.Drawing.Point(798, 120)
$RecoverySiteVMCsvValidationComplete.Size = New-Object System.Drawing.Size(290, 20)
$RecoverySiteVMCsvValidationComplete.TabIndex = 29
$RecoverySiteVMCsvValidationComplete.Text = ""
#endregion ~~< RecoverySiteVMCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteDatastoreCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteDatastoreCsvCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySiteDatastoreCsvCheckBox.Checked = $true
$RecoverySiteDatastoreCsvCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySiteDatastoreCsvCheckBox.Location = New-Object System.Drawing.Point(483, 140)
$RecoverySiteDatastoreCsvCheckBox.Size = New-Object System.Drawing.Size(300, 20)
$RecoverySiteDatastoreCsvCheckBox.TabIndex = 5
$RecoverySiteDatastoreCsvCheckBox.Text = "Export Recovery Site Datastore (ABR) Info"
$RecoverySiteDatastoreCsvCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySiteDatastoreCsvCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteDatastoreCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteDatastoreCsvValidationComplete = New-Object System.Windows.Forms.Label
$RecoverySiteDatastoreCsvValidationComplete.Location = New-Object System.Drawing.Point(798, 140)
$RecoverySiteDatastoreCsvValidationComplete.Size = New-Object System.Drawing.Size(290, 20)
$RecoverySiteDatastoreCsvValidationComplete.TabIndex = 30
$RecoverySiteDatastoreCsvValidationComplete.Text = ""
#endregion ~~< RecoverySiteDatastoreCsvValidationComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabCaptureSRM.Controls.Add($RecoverySitevCenterInfoCsvCheckBox)
$TabCaptureSRM.Controls.Add($RecoverySitevCenterInfoValidationComplete)
$TabCaptureSRM.Controls.Add($RecoverySiteSrmInfoCsvCheckBox)
$TabCaptureSRM.Controls.Add($RecoverySiteSrmInfoValidationComplete)
$TabCaptureSRM.Controls.Add($RecoverySiteRecoveryPlanCsvCheckBox)
$TabCaptureSRM.Controls.Add($RecoverySiteRecoveryPlanCsvValidationComplete)
$TabCaptureSRM.Controls.Add($RecoverySiteProtectionGroupCsvCheckBox)
$TabCaptureSRM.Controls.Add($RecoverySiteProtectionGroupCsvValidationComplete)
$TabCaptureSRM.Controls.Add($RecoverySiteVMCsvCheckBox)
$TabCaptureSRM.Controls.Add($RecoverySiteVMCsvValidationComplete)
$TabCaptureSRM.Controls.Add($RecoverySiteDatastoreCsvCheckBox)
$TabCaptureSRM.Controls.Add($RecoverySiteDatastoreCsvValidationComplete)
#endregion ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Buttons >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureUncheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureUncheckButton = New-Object System.Windows.Forms.Button
$SRMCaptureUncheckButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$SRMCaptureUncheckButton.Location = New-Object System.Drawing.Point(8, 215)
$SRMCaptureUncheckButton.Size = New-Object System.Drawing.Size(200, 25)
$SRMCaptureUncheckButton.TabIndex = 23
$SRMCaptureUncheckButton.Text = "Uncheck All"
$SRMCaptureUncheckButton.UseVisualStyleBackColor = $false
$SRMCaptureUncheckButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< SRMCaptureUncheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureCheckButton = New-Object System.Windows.Forms.Button
$SRMCaptureCheckButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$SRMCaptureCheckButton.Location = New-Object System.Drawing.Point(228, 215)
$SRMCaptureCheckButton.Size = New-Object System.Drawing.Size(200, 25)
$SRMCaptureCheckButton.TabIndex = 24
$SRMCaptureCheckButton.Text = "Check All"
$SRMCaptureCheckButton.UseVisualStyleBackColor = $false
$SRMCaptureCheckButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< SRMCaptureCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureButton = New-Object System.Windows.Forms.Button
$SRMCaptureButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$SRMCaptureButton.Location = New-Object System.Drawing.Point(448, 215)
$SRMCaptureButton.Size = New-Object System.Drawing.Size(200, 25)
$SRMCaptureButton.TabIndex = 25
$SRMCaptureButton.Text = "Collect CSV Data"
$SRMCaptureButton.UseVisualStyleBackColor = $false
$SRMCaptureButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< SRMCaptureButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< OpenCaptureButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OpenCaptureButton = New-Object System.Windows.Forms.Button
$OpenCaptureButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$OpenCaptureButton.Location = New-Object System.Drawing.Point(668, 215)
$OpenCaptureButton.Size = New-Object System.Drawing.Size(200, 25)
$OpenCaptureButton.TabIndex = 83
$OpenCaptureButton.Text = "Open CSV Output Folder"
$OpenCaptureButton.UseVisualStyleBackColor = $false
$OpenCaptureButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< OpenCaptureButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabCaptureSRM.Controls.Add($SRMCaptureUncheckButton)
$TabCaptureSRM.Controls.Add($SRMCaptureCheckButton)
$TabCaptureSRM.Controls.Add($SRMCaptureButton)
$TabCaptureSRM.Controls.Add($OpenCaptureButton)
#endregion ~~< Buttons >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SubTab.Controls.Add($TabCaptureSRM)
#endregion ~~< TabCaptureSRM >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< TabDrawSRM >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabDrawSRM = New-Object System.Windows.Forms.TabPage
$TabDrawSRM.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
$TabDrawSRM.Location = New-Object System.Drawing.Point(4, 22)
$TabDrawSRM.Padding = New-Object System.Windows.Forms.Padding(3)
$TabDrawSRM.Size = New-Object System.Drawing.Size(982, 486)
$TabDrawSRM.TabIndex = 2
$TabDrawSRM.Text = "Draw Visio"
$TabDrawSRM.UseVisualStyleBackColor = $true
#region ~~< Input >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< CSV >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMDrawCsvInputLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMDrawCsvInputLabel = New-Object System.Windows.Forms.Label
$SRMDrawCsvInputLabel.Font = New-Object System.Drawing.Font("Tahoma", 15.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$SRMDrawCsvInputLabel.Location = New-Object System.Drawing.Point(10, 10)
$SRMDrawCsvInputLabel.Size = New-Object System.Drawing.Size(190, 25)
$SRMDrawCsvInputLabel.TabIndex = 0
$SRMDrawCsvInputLabel.Text = "CSV Input Folder:"
#endregion ~~< SRMDrawCsvInputLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMDrawCsvInputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMDrawCsvInputButton = New-Object System.Windows.Forms.Button
$SRMDrawCsvInputButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$SRMDrawCsvInputButton.Location = New-Object System.Drawing.Point(220, 10)
$SRMDrawCsvInputButton.Size = New-Object System.Drawing.Size(750, 25)
$SRMDrawCsvInputButton.TabIndex = 1
$SRMDrawCsvInputButton.Text = "Select CSV Input Folder"
$SRMDrawCsvInputButton.UseVisualStyleBackColor = $false
$SRMDrawCsvInputButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< SRMDrawCsvInputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawCsvBrowse >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawCsvBrowse = New-Object System.Windows.Forms.FolderBrowserDialog
$DrawCsvBrowse.Description = "Select a directory"
$DrawCsvBrowse.RootFolder = [System.Environment+SpecialFolder]::MyComputer
#endregion ~~< DrawCsvBrowse >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabDrawSRM.Controls.Add($SRMDrawCsvInputLabel)
$TabDrawSRM.Controls.Add($SRMDrawCsvInputButton)
#endregion ~~< CSV >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSitevCenterCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSitevCenterCsvValidation = New-Object System.Windows.Forms.Label
$ProtectedSitevCenterCsvValidation.Location = New-Object System.Drawing.Point(10, 40)
$ProtectedSitevCenterCsvValidation.Size = New-Object System.Drawing.Size(270, 20)
$ProtectedSitevCenterCsvValidation.TabIndex = 2
$ProtectedSitevCenterCsvValidation.Text = "Protected Site vCenter CSV File:"
#endregion ~~< ProtectedSitevCenterCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSitevCenterCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSitevCenterCsvValidationCheck = New-Object System.Windows.Forms.Label
$ProtectedSitevCenterCsvValidationCheck.Location = New-Object System.Drawing.Point(287, 40)
$ProtectedSitevCenterCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSitevCenterCsvValidationCheck.TabIndex = 3
$ProtectedSitevCenterCsvValidationCheck.Text = ""
#endregion ~~< ProtectedSitevCenterCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteSrmCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteSrmCsvValidation = New-Object System.Windows.Forms.Label
$ProtectedSiteSrmCsvValidation.Location = New-Object System.Drawing.Point(10, 60)
$ProtectedSiteSrmCsvValidation.Size = New-Object System.Drawing.Size(270, 20)
$ProtectedSiteSrmCsvValidation.TabIndex = 2
$ProtectedSiteSrmCsvValidation.Text = "Protected Site SRM CSV File:"
#endregion ~~< ProtectedSiteSrmCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteSrmCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteSrmCsvValidationCheck = New-Object System.Windows.Forms.Label
$ProtectedSiteSrmCsvValidationCheck.Location = New-Object System.Drawing.Point(287, 60)
$ProtectedSiteSrmCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteSrmCsvValidationCheck.TabIndex = 3
$ProtectedSiteSrmCsvValidationCheck.Text = ""
#endregion ~~< ProtectedSiteSrmCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteRecoveryPlanCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteRecoveryPlanCsvValidation = New-Object System.Windows.Forms.Label
$ProtectedSiteRecoveryPlanCsvValidation.Location = New-Object System.Drawing.Point(10, 80)
$ProtectedSiteRecoveryPlanCsvValidation.Size = New-Object System.Drawing.Size(270, 20)
$ProtectedSiteRecoveryPlanCsvValidation.TabIndex = 4
$ProtectedSiteRecoveryPlanCsvValidation.Text = "Protected Site Recovery Plan CSV File:"
#endregion ~~< ProtectedSiteRecoveryPlanCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteRecoveryPlanCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteRecoveryPlanCsvValidationCheck = New-Object System.Windows.Forms.Label
$ProtectedSiteRecoveryPlanCsvValidationCheck.Location = New-Object System.Drawing.Point(287, 80)
$ProtectedSiteRecoveryPlanCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteRecoveryPlanCsvValidationCheck.TabIndex = 5
$ProtectedSiteRecoveryPlanCsvValidationCheck.Text = ""
#endregion ~~< ProtectedSiteRecoveryPlanCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteProtectionGroupCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteProtectionGroupCsvValidation = New-Object System.Windows.Forms.Label
$ProtectedSiteProtectionGroupCsvValidation.Location = New-Object System.Drawing.Point(10, 100)
$ProtectedSiteProtectionGroupCsvValidation.Size = New-Object System.Drawing.Size(270, 20)
$ProtectedSiteProtectionGroupCsvValidation.TabIndex = 6
$ProtectedSiteProtectionGroupCsvValidation.Text = "Protected Site Protection Group CSV File:"
#endregion ~~< ProtectedSiteProtectionGroupCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteProtectionGroupCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteProtectionGroupCsvValidationCheck = New-Object System.Windows.Forms.Label
$ProtectedSiteProtectionGroupCsvValidationCheck.Location = New-Object System.Drawing.Point(287, 100)
$ProtectedSiteProtectionGroupCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteProtectionGroupCsvValidationCheck.TabIndex = 7
$ProtectedSiteProtectionGroupCsvValidationCheck.Text = ""
#endregion ~~< ProtectedSiteProtectionGroupCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteVmCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteVmCsvValidation = New-Object System.Windows.Forms.Label
$ProtectedSiteVmCsvValidation.Location = New-Object System.Drawing.Point(10, 120)
$ProtectedSiteVmCsvValidation.Size = New-Object System.Drawing.Size(270, 20)
$ProtectedSiteVmCsvValidation.TabIndex = 8
$ProtectedSiteVmCsvValidation.Text = "Protected Site VM CSV File:"
#endregion ~~< ProtectedSiteVmCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteVmCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteVmCsvValidationCheck = New-Object System.Windows.Forms.Label
$ProtectedSiteVmCsvValidationCheck.Location = New-Object System.Drawing.Point(287, 120)
$ProtectedSiteVmCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteVmCsvValidationCheck.TabIndex = 9
$ProtectedSiteVmCsvValidationCheck.Text = ""
#endregion ~~< ProtectedSiteVmCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteDatastoreCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteDatastoreCsvValidation = New-Object System.Windows.Forms.Label
$ProtectedSiteDatastoreCsvValidation.Location = New-Object System.Drawing.Point(10, 140)
$ProtectedSiteDatastoreCsvValidation.Size = New-Object System.Drawing.Size(270, 20)
$ProtectedSiteDatastoreCsvValidation.TabIndex = 10
$ProtectedSiteDatastoreCsvValidation.Text = "Protected Site Datastore (ABR) CSV File:"
#endregion ~~< ProtectedSiteDatastoreCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteDatastoreCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteDatastoreCsvValidationCheck = New-Object System.Windows.Forms.Label
$ProtectedSiteDatastoreCsvValidationCheck.Location = New-Object System.Drawing.Point(287, 140)
$ProtectedSiteDatastoreCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$ProtectedSiteDatastoreCsvValidationCheck.TabIndex = 11
$ProtectedSiteDatastoreCsvValidationCheck.Text = ""
#endregion ~~< ProtectedSiteDatastoreCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabDrawSRM.Controls.Add($ProtectedSitevCenterCsvValidation)
$TabDrawSRM.Controls.Add($ProtectedSitevCenterCsvValidationCheck)
$TabDrawSRM.Controls.Add($ProtectedSiteSrmCsvValidation)
$TabDrawSRM.Controls.Add($ProtectedSiteSrmCsvValidationCheck)
$TabDrawSRM.Controls.Add($ProtectedSiteRecoveryPlanCsvValidation)
$TabDrawSRM.Controls.Add($ProtectedSiteRecoveryPlanCsvValidationCheck)
$TabDrawSRM.Controls.Add($ProtectedSiteProtectionGroupCsvValidation)
$TabDrawSRM.Controls.Add($ProtectedSiteProtectionGroupCsvValidationCheck)
$TabDrawSRM.Controls.Add($ProtectedSiteVmCsvValidation)
$TabDrawSRM.Controls.Add($ProtectedSiteVmCsvValidationCheck)
$TabDrawSRM.Controls.Add($ProtectedSiteDatastoreCsvValidation)
$TabDrawSRM.Controls.Add($ProtectedSiteDatastoreCsvValidationCheck)
#endregion ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySitevCenterCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySitevCenterCsvValidation = New-Object System.Windows.Forms.Label
$RecoverySitevCenterCsvValidation.Location = New-Object System.Drawing.Point(483, 40)
$RecoverySitevCenterCsvValidation.Size = New-Object System.Drawing.Size(240, 20)
$RecoverySitevCenterCsvValidation.TabIndex = 12
$RecoverySitevCenterCsvValidation.Text = "Recovery Site vCenter CSV File:"
#endregion ~~< RecoverySitevCenterCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySitevCenterCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySitevCenterCsvValidationCheck = New-Object System.Windows.Forms.Label
$RecoverySitevCenterCsvValidationCheck.Location = New-Object System.Drawing.Point(730, 40)
$RecoverySitevCenterCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$RecoverySitevCenterCsvValidationCheck.TabIndex = 13
$RecoverySitevCenterCsvValidationCheck.Text = ""
#endregion ~~< RecoverySitevCenterCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteSrmCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteSrmCsvValidation = New-Object System.Windows.Forms.Label
$RecoverySiteSrmCsvValidation.Location = New-Object System.Drawing.Point(483, 60)
$RecoverySiteSrmCsvValidation.Size = New-Object System.Drawing.Size(240, 20)
$RecoverySiteSrmCsvValidation.TabIndex = 12
$RecoverySiteSrmCsvValidation.Text = "Recovery Site SRM CSV File:"
#endregion ~~< RecoverySiteSrmCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteSrmCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteSrmCsvValidationCheck = New-Object System.Windows.Forms.Label
$RecoverySiteSrmCsvValidationCheck.Location = New-Object System.Drawing.Point(730, 60)
$RecoverySiteSrmCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$RecoverySiteSrmCsvValidationCheck.TabIndex = 13
$RecoverySiteSrmCsvValidationCheck.Text = ""
#endregion ~~< RecoverySiteSrmCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteRecoveryPlanCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteRecoveryPlanCsvValidation = New-Object System.Windows.Forms.Label
$RecoverySiteRecoveryPlanCsvValidation.Location = New-Object System.Drawing.Point(483, 80)
$RecoverySiteRecoveryPlanCsvValidation.Size = New-Object System.Drawing.Size(240, 20)
$RecoverySiteRecoveryPlanCsvValidation.TabIndex = 14
$RecoverySiteRecoveryPlanCsvValidation.Text = "Recovery Site Recovery Plan CSV File:"
#endregion ~~< RecoverySiteRecoveryPlanCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteRecoveryPlanCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteRecoveryPlanCsvValidationCheck = New-Object System.Windows.Forms.Label
$RecoverySiteRecoveryPlanCsvValidationCheck.Location = New-Object System.Drawing.Point(730, 80)
$RecoverySiteRecoveryPlanCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$RecoverySiteRecoveryPlanCsvValidationCheck.TabIndex = 15
$RecoverySiteRecoveryPlanCsvValidationCheck.Text = ""
#endregion ~~< RecoverySiteRecoveryPlanCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteProtectionGroupCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteProtectionGroupCsvValidation = New-Object System.Windows.Forms.Label
$RecoverySiteProtectionGroupCsvValidation.Location = New-Object System.Drawing.Point(483, 100)
$RecoverySiteProtectionGroupCsvValidation.Size = New-Object System.Drawing.Size(240, 20)
$RecoverySiteProtectionGroupCsvValidation.TabIndex = 16
$RecoverySiteProtectionGroupCsvValidation.Text = "Recovery Site Protection Group CSV File:"
#endregion ~~< RecoverySiteProtectionGroupCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteProtectionGroupCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteProtectionGroupCsvValidationCheck = New-Object System.Windows.Forms.Label
$RecoverySiteProtectionGroupCsvValidationCheck.Location = New-Object System.Drawing.Point(730, 100)
$RecoverySiteProtectionGroupCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$RecoverySiteProtectionGroupCsvValidationCheck.TabIndex = 17
$RecoverySiteProtectionGroupCsvValidationCheck.Text = ""
#endregion ~~< RecoverySiteProtectionGroupCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteVmCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteVmCsvValidation = New-Object System.Windows.Forms.Label
$RecoverySiteVmCsvValidation.Location = New-Object System.Drawing.Point(483, 120)
$RecoverySiteVmCsvValidation.Size = New-Object System.Drawing.Size(240, 20)
$RecoverySiteVmCsvValidation.TabIndex = 18
$RecoverySiteVmCsvValidation.Text = "Recovery Site VM CSV File:"
#endregion ~~< RecoverySiteVmCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteVmCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteVmCsvValidationCheck = New-Object System.Windows.Forms.Label
$RecoverySiteVmCsvValidationCheck.Location = New-Object System.Drawing.Point(730, 120)
$RecoverySiteVmCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$RecoverySiteVmCsvValidationCheck.TabIndex = 19
$RecoverySiteVmCsvValidationCheck.Text = ""
#endregion ~~< RecoverySiteVmCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteDatastoreCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteDatastoreCsvValidation = New-Object System.Windows.Forms.Label
$RecoverySiteDatastoreCsvValidation.Location = New-Object System.Drawing.Point(483, 140)
$RecoverySiteDatastoreCsvValidation.Size = New-Object System.Drawing.Size(240, 20)
$RecoverySiteDatastoreCsvValidation.TabIndex = 20
$RecoverySiteDatastoreCsvValidation.Text = "Recovery Site Datastore (ABR) CSV File:"
#endregion ~~< RecoverySiteDatastoreCsvValidation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteDatastoreCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteDatastoreCsvValidationCheck = New-Object System.Windows.Forms.Label
$RecoverySiteDatastoreCsvValidationCheck.Location = New-Object System.Drawing.Point(730, 140)
$RecoverySiteDatastoreCsvValidationCheck.Size = New-Object System.Drawing.Size(90, 20)
$RecoverySiteDatastoreCsvValidationCheck.TabIndex = 21
$RecoverySiteDatastoreCsvValidationCheck.Text = ""
#endregion ~~< RecoverySiteDatastoreCsvValidationCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabDrawSRM.Controls.Add($RecoverySitevCenterCsvValidation)
$TabDrawSRM.Controls.Add($RecoverySitevCenterCsvValidationCheck)
$TabDrawSRM.Controls.Add($RecoverySiteSrmCsvValidation)
$TabDrawSRM.Controls.Add($RecoverySiteSrmCsvValidationCheck)
$TabDrawSRM.Controls.Add($RecoverySiteRecoveryPlanCsvValidation)
$TabDrawSRM.Controls.Add($RecoverySiteRecoveryPlanCsvValidationCheck)
$TabDrawSRM.Controls.Add($RecoverySiteProtectionGroupCsvValidation)
$TabDrawSRM.Controls.Add($RecoverySiteProtectionGroupCsvValidationCheck)
$TabDrawSRM.Controls.Add($RecoverySiteVmCsvValidation)
$TabDrawSRM.Controls.Add($RecoverySiteVmCsvValidationCheck)
$TabDrawSRM.Controls.Add($RecoverySiteDatastoreCsvValidation)
$TabDrawSRM.Controls.Add($RecoverySiteDatastoreCsvValidationCheck)
#endregion ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCsvValidationButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCsvValidationButton = New-Object System.Windows.Forms.Button
$SRMCsvValidationButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$SRMCsvValidationButton.Location = New-Object System.Drawing.Point(8, 160)
$SRMCsvValidationButton.Size = New-Object System.Drawing.Size(200, 25)
$SRMCsvValidationButton.TabIndex = 22
$SRMCsvValidationButton.Text = "Check for CSVs"
$SRMCsvValidationButton.UseVisualStyleBackColor = $false
$SRMCsvValidationButton.BackColor = [System.Drawing.Color]::LightGray
$TabDrawSRM.Controls.Add($SRMCsvValidationButton)
#endregion ~~< SRMCsvValidationButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Input >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Output >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< VisioOutput >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< VisioOutputLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$VisioOutputLabel = New-Object System.Windows.Forms.Label
$VisioOutputLabel.Font = New-Object System.Drawing.Font("Tahoma", 15.0, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Point, ([System.Byte](0)))
$VisioOutputLabel.Location = New-Object System.Drawing.Point(10, 200)
$VisioOutputLabel.Size = New-Object System.Drawing.Size(215, 25)
$VisioOutputLabel.TabIndex = 46
$VisioOutputLabel.Text = "Visio Output Folder:"
#endregion ~~< VisioOutputLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< VisioOpenOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$VisioOpenOutputButton = New-Object System.Windows.Forms.Button
$VisioOpenOutputButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$VisioOpenOutputButton.Location = New-Object System.Drawing.Point(230, 200)
$VisioOpenOutputButton.Size = New-Object System.Drawing.Size(740, 25)
$VisioOpenOutputButton.TabIndex = 47
$VisioOpenOutputButton.Text = "Select Visio Output Folder"
$VisioOpenOutputButton.UseVisualStyleBackColor = $false
$VisioOpenOutputButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< VisioOpenOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< VisioBrowse >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$VisioBrowse = New-Object System.Windows.Forms.FolderBrowserDialog
$VisioBrowse.Description = "Select a directory"
$VisioBrowse.RootFolder = [System.Environment+SpecialFolder]::MyComputer
#endregion ~~< VisioBrowse >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabDrawSRM.Controls.Add($VisioOutputLabel)
$TabDrawSRM.Controls.Add($VisioOpenOutputButton)
#endregion ~~< VisioOutput >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~
$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Checked = $true
$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Location = New-Object System.Drawing.Point(10, 230)
$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.TabIndex = 48
$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Text = "Create Combo Recovery Plan to Protection Group Drawing"
$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox >~~~~~~~~~~~~~~~~~~
#region ~~< Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete >~~~~~~~~~~~~~~~~~~~~~
$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete = New-Object System.Windows.Forms.Label
$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.Location = New-Object System.Drawing.Point(400, 230)
$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.TabIndex = 49
$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = ""
#endregion ~~< Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete >~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Combined_ProtectionGroup_to_VM_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$Combined_ProtectionGroup_to_VM_DrawCheckBox.Checked = $true
$Combined_ProtectionGroup_to_VM_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$Combined_ProtectionGroup_to_VM_DrawCheckBox.Location = New-Object System.Drawing.Point(10, 250)
$Combined_ProtectionGroup_to_VM_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$Combined_ProtectionGroup_to_VM_DrawCheckBox.TabIndex = 50
$Combined_ProtectionGroup_to_VM_DrawCheckBox.Text = "Create Combo Protection Group to VM Drawing"
$Combined_ProtectionGroup_to_VM_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< Combined_ProtectionGroup_to_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Combined_ProtectionGroup_to_VM_DrawComplete = New-Object System.Windows.Forms.Label
$Combined_ProtectionGroup_to_VM_DrawComplete.Location = New-Object System.Drawing.Point(400, 250)
$Combined_ProtectionGroup_to_VM_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$Combined_ProtectionGroup_to_VM_DrawComplete.TabIndex = 51
$Combined_ProtectionGroup_to_VM_DrawComplete.Text = ""
#endregion ~~< Combined_ProtectionGroup_to_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_Datastore_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~
$Combined_ProtectionGroup_to_Datastore_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.Checked = $true
$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.Location = New-Object System.Drawing.Point(483, 230)
$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.TabIndex = 52
$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.Text = "Create Combo Protection Group to Datastore (ABR) Drawing"
$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< Combined_ProtectionGroup_to_Datastore_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_Datastore_DrawComplete >~~~~~~~~~~~~~~~~~~~~~~~~
$Combined_ProtectionGroup_to_Datastore_DrawComplete = New-Object System.Windows.Forms.Label
$Combined_ProtectionGroup_to_Datastore_DrawComplete.Location = New-Object System.Drawing.Point(875, 230)
$Combined_ProtectionGroup_to_Datastore_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$Combined_ProtectionGroup_to_Datastore_DrawComplete.TabIndex = 53
$Combined_ProtectionGroup_to_Datastore_DrawComplete.Text = ""
#endregion ~~< Combined_ProtectionGroup_to_Datastore_DrawComplete >~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_VR_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~
$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.Checked = $true
$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.Location = New-Object System.Drawing.Point(483, 250)
$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.TabIndex = 54
$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.Text = "Create Combo Protection Group to VR Replicated VM Drawing"
$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< Combined_ProtectionGroup_to_VR_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_VR_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~~~~~
$Combined_ProtectionGroup_to_VR_VM_DrawComplete = New-Object System.Windows.Forms.Label
$Combined_ProtectionGroup_to_VR_VM_DrawComplete.Location = New-Object System.Drawing.Point(875, 250)
$Combined_ProtectionGroup_to_VR_VM_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$Combined_ProtectionGroup_to_VR_VM_DrawComplete.TabIndex = 55
$Combined_ProtectionGroup_to_VR_VM_DrawComplete.Text = ""
#endregion ~~< Combined_ProtectionGroup_to_VR_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~~
$TabDrawSRM.Controls.Add($Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox)
$TabDrawSRM.Controls.Add($Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete)
$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_VM_DrawCheckBox)
$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_VM_DrawComplete)
$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_Datastore_DrawCheckBox)
$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_Datastore_DrawComplete)
$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_VR_VM_DrawCheckBox)
$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_VR_VM_DrawComplete)
#endregion ~~< Combined >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox >~~~~~~~~~~~~~~~~
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Checked = $true
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Location = New-Object System.Drawing.Point(10, 270)
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.TabIndex = 56
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Text = "Create PSite Recovery Plan to Protection Group Drawing"
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox >~~~~~~~~~~~~~
#region ~~< ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete >~~~~~~~~~~~~~~~~
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete = New-Object System.Windows.Forms.Label
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Location = New-Object System.Drawing.Point(400, 270)
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.TabIndex = 57
$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = ""
#endregion ~~< ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete >~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.Checked = $true
$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.Location = New-Object System.Drawing.Point(10, 290)
$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.TabIndex = 58
$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.Text = "Create PSite Protection Group to VM Drawing"
$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSite_ProtectionGroup_to_VM_DrawComplete = New-Object System.Windows.Forms.Label
$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.Location = New-Object System.Drawing.Point(400, 290)
$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.TabIndex = 59
$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.Text = ""
#endregion ~~< ProtectedSite_ProtectionGroup_to_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox >~~~~~~~~~~~~~~~~~~~
$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.Checked = $true
$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.Location = New-Object System.Drawing.Point(10, 310)
$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.TabIndex = 60
$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.Text = "Create PSite Protection Group to Datastore (ABR) Drawing"
$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox >~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete >~~~~~~~~~~~~~~~~~~~
$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete = New-Object System.Windows.Forms.Label
$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.Location = New-Object System.Drawing.Point(400, 310)
$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.TabIndex = 61
$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.Text = ""
#endregion ~~< ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete >~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.Checked = $true
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.Location = New-Object System.Drawing.Point(10, 330)
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.TabIndex = 62
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.Text = "Create PSite Protection Group to VR Replicated VM Drawing"
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox >~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete = New-Object System.Windows.Forms.Label
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.Location = New-Object System.Drawing.Point(400, 330)
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.TabIndex = 63
$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.Text = ""
#endregion ~~< ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete >~~~~~~~~~~~~~~~~
$TabDrawSRM.Controls.Add($ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox)
$TabDrawSRM.Controls.Add($ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete)
$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox)
$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_VM_DrawComplete)
$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox)
$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete)
$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox)
$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete)
#endregion ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox >~~~~~~~~~~~~~~~~~
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Checked = $true
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Location = New-Object System.Drawing.Point(483, 270)
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.TabIndex = 64
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Text = "Create RSite Recovery Plan to Protection Group Drawing"
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox >~~~~~~~~~~~~~~
#region ~~< RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete >~~~~~~~~~~~~~~~~~
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete = New-Object System.Windows.Forms.Label
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Location = New-Object System.Drawing.Point(875, 270)
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.TabIndex = 65
$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = ""
#endregion ~~< RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete >~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.Checked = $true
$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.Location = New-Object System.Drawing.Point(483, 290)
$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.TabIndex = 66
$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.Text = "Create RSite Protection Group to VM Drawing"
$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySite_ProtectionGroup_to_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySite_ProtectionGroup_to_VM_DrawComplete = New-Object System.Windows.Forms.Label
$RecoverySite_ProtectionGroup_to_VM_DrawComplete.Location = New-Object System.Drawing.Point(875, 290)
$RecoverySite_ProtectionGroup_to_VM_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$RecoverySite_ProtectionGroup_to_VM_DrawComplete.TabIndex = 67
$RecoverySite_ProtectionGroup_to_VM_DrawComplete.Text = ""
#endregion ~~< RecoverySite_ProtectionGroup_to_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~
$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.Checked = $true
$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.Location = New-Object System.Drawing.Point(483, 310)
$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.TabIndex = 68
$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.Text = "Create RSite Protection Group to Datastore (ABR) Drawing"
$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox >~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_Datastore_DrawComplete >~~~~~~~~~~~~~~~~~~~~
$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete = New-Object System.Windows.Forms.Label
$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.Location = New-Object System.Drawing.Point(875, 310)
$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.TabIndex = 69
$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.Text = ""
#endregion ~~< RecoverySite_ProtectionGroup_to_Datastore_DrawComplete >~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~~~~
$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox = New-Object System.Windows.Forms.CheckBox
$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.Checked = $true
$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = [System.Windows.Forms.CheckState]::Checked
$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.Location = New-Object System.Drawing.Point(483, 330)
$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.Size = New-Object System.Drawing.Size(385, 20)
$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.TabIndex = 70
$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.Text = "Create RSite Protection Group to VR Replicated VM Drawing"
$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.UseVisualStyleBackColor = $true
#endregion ~~< RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox >~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete >~~~~~~~~~~~~~~~~~~~~
$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete = New-Object System.Windows.Forms.Label
$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.Location = New-Object System.Drawing.Point(875, 330)
$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.Size = New-Object System.Drawing.Size(80, 20)
$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.TabIndex = 71
$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.Text = ""
#endregion ~~< RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete >~~~~~~~~~~~~~~~~~
$TabDrawSRM.Controls.Add($RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox)
$TabDrawSRM.Controls.Add($RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete)
$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_VM_DrawCheckBox)
$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_VM_DrawComplete)
$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox)
$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_Datastore_DrawComplete)
$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox)
$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete)
#endregion ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Buttons >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawIndividualCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawIndividualCheckButton = New-Object System.Windows.Forms.Button
$DrawIndividualCheckButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$DrawIndividualCheckButton.Location = New-Object System.Drawing.Point(8, 360)
$DrawIndividualCheckButton.Size = New-Object System.Drawing.Size(175, 25)
$DrawIndividualCheckButton.TabIndex = 80
$DrawIndividualCheckButton.Text = "Individual Drawings Only"
$DrawIndividualCheckButton.UseVisualStyleBackColor = $false
$DrawIndividualCheckButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< DrawIndividualCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawCombinedCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawCombinedCheckButton = New-Object System.Windows.Forms.Button
$DrawCombinedCheckButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$DrawCombinedCheckButton.Location = New-Object System.Drawing.Point(191, 360)
$DrawCombinedCheckButton.Size = New-Object System.Drawing.Size(175, 25)
$DrawCombinedCheckButton.TabIndex = 81
$DrawCombinedCheckButton.Text = "Combined Drawings Only"
$DrawCombinedCheckButton.UseVisualStyleBackColor = $false
$DrawCombinedCheckButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< DrawCombinedCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawUncheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawUncheckButton = New-Object System.Windows.Forms.Button
$DrawUncheckButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$DrawUncheckButton.Location = New-Object System.Drawing.Point(374, 360)
$DrawUncheckButton.Size = New-Object System.Drawing.Size(175, 25)
$DrawUncheckButton.TabIndex = 82
$DrawUncheckButton.Text = "Uncheck All"
$DrawUncheckButton.UseVisualStyleBackColor = $false
$DrawUncheckButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< DrawUncheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawCheckButton = New-Object System.Windows.Forms.Button
$DrawCheckButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$DrawCheckButton.Location = New-Object System.Drawing.Point(557, 360)
$DrawCheckButton.Size = New-Object System.Drawing.Size(175, 25)
$DrawCheckButton.TabIndex = 83
$DrawCheckButton.Text = "Check All"
$DrawCheckButton.UseVisualStyleBackColor = $false
$DrawCheckButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< DrawCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawButton = New-Object System.Windows.Forms.Button
$DrawButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$DrawButton.Location = New-Object System.Drawing.Point(8, 390)
$DrawButton.Size = New-Object System.Drawing.Size(175, 25)
$DrawButton.TabIndex = 84
$DrawButton.Text = "Draw Visio"
$DrawButton.UseVisualStyleBackColor = $false
$DrawButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< DrawButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< OpenVisioButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OpenVisioButton = New-Object System.Windows.Forms.Button
$OpenVisioButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Popup
$OpenVisioButton.Location = New-Object System.Drawing.Point(191, 390)
$OpenVisioButton.Size = New-Object System.Drawing.Size(175, 25)
$OpenVisioButton.TabIndex = 85
$OpenVisioButton.Text = "Open Visio Drawing"
$OpenVisioButton.UseVisualStyleBackColor = $false
$OpenVisioButton.BackColor = [System.Drawing.Color]::LightGray
#endregion ~~< OpenVisioButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TabDrawSRM.Controls.Add($DrawUncheckButton)
$TabDrawSRM.Controls.Add($DrawCheckButton)
$TabDrawSRM.Controls.Add($DrawButton)
$TabDrawSRM.Controls.Add($OpenVisioButton)
#endregion ~~< Buttons >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Output >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SubTab.Controls.Add($TabDrawSRM)
#endregion ~~< TabDrawSRM >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SubTab.ForeColor = [System.Drawing.SystemColors]::ControlText
$SubTab.SelectedIndex = 0
$SRMvDiagram.Controls.Add($SubTab)
#endregion ~~< SubTab >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMvDiagram.Controls.Add($MainMenu)
#endregion ~~< MainMenu >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< vDiagram >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Form Creation >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#region ~~< Custom Code >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowershellCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PowershellCheck = $PSVersionTable.PSVersion
if ($PowershellCheck.Major -ge 4)
{
	$PowershellInstalled.Forecolor = "Green"
	$PowershellInstalled.Text = "Installed Version $PowershellCheck"
}
else
{
	$PowershellInstalled.Forecolor = "Red"
	$PowershellInstalled.Text = "Not installed or Powershell version lower than 4"
}
#endregion ~~< PowershellCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowerCliModuleCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PowerCliModuleCheck = (Get-Module VMware.PowerCLI -ListAvailable | where-object { $_.Name -eq "VMware.PowerCLI" })
$PowerCliModuleVersion = ($PowerCliModuleCheck.Version)
if ($PowerCliModuleCheck -ne $null)
{
	$PowerCliModuleInstalled.Forecolor = "Green"
	$PowerCliModuleInstalled.Text = "Installed Version $PowerCliModuleVersion"
}
else
{
	$PowerCliModuleInstalled.Forecolor = "Red"
	$PowerCliModuleInstalled.Text = "Not Installed"
}
#endregion ~~< PowerCliModuleCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< PowerCliCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if ((Get-PSSnapin -registered | where-object { $_.Name -eq "VMware.VimAutomation.Core" }) -ne $null)
{
	$PowerCliInstalled.Forecolor = "Green"
	$PowerCliInstalled.Text = "PowerClI Installed"
}
elseif ($PowerCliModuleCheck -ne $null)
{
	$PowerCliInstalled.Forecolor = "Green"
	$PowerCliInstalled.Text = "PowerCLI Module Installed"
}
else
{
	$PowerCliInstalled.Forecolor = "Red"
	$PowerCliInstalled.Text = "PowerCLI or PowerCli Module not installed"
}
#endregion ~~< PowerCliCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< VisioCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if ((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where-object {$_.DisplayName -like "*Visio*" -and $_.DisplayName -notlike "*Visio View*"} | Select-Object DisplayName) -or (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where-object {$_.DisplayName -like "*Visio*" -and $_.DisplayName -notlike "*Visio View*"} | Select-Object DisplayName) -ne $null)
{
	$VisioInstalled.Forecolor = "Green"
	$VisioInstalled.Text = "Installed"
}
else
{
	$VisioInstalled.Forecolor = "Red"
	$VisioInstalled.Text = "Visio is Not Installed"
}
#endregion ~~< VisioCheck >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Button Actions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< MainTab InfrastructureInfo >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteConnectButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProtectedSiteConnectButton.Add_MouseClick({ $Connected = Get-View $global:DefaultVIServers.ExtensionData.Client.ServiceContent.SessionManager ;
	if ($Connected -eq $null)
	{
		$ProtectedSiteConnectButton.Forecolor = [System.Drawing.Color]::Red ; $ProtectedSiteConnectButton.Text = "Unable to Connect"
	}
	else
	{
		$ProtectedSiteConnectButton.Forecolor = [System.Drawing.Color]::Green ; $ProtectedSiteConnectButton.Text = "Connected to $ProtectedSiteVC and $ProtectedSiteSRM" }
	}
)
$ProtectedSiteConnectButton.Add_Click({ Connect_Protected_vCenter ; Connect_Protected_SRM})
#endregion ~~< ProtectedSiteConnectButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteConnectButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$RecoverySiteConnectButton.Add_MouseClick({ $Connected = Get-View $global:DefaultVIServers.ExtensionData.Client.ServiceContent.SessionManager ; 
	if ($Connected -eq $null)
	{
		$RecoverySiteConnectButton.Forecolor = [System.Drawing.Color]::Red ; $RecoverySiteConnectButton.Text = "Unable to Connect"
	}
	else
	{
		$RecoverySiteConnectButton.Forecolor = [System.Drawing.Color]::Green ; $RecoverySiteConnectButton.Text = "Connected to $RecoverySiteVC and $RecoverySiteSRM" }
	}
)
$RecoverySiteConnectButton.Add_Click({ Connect_Recovery_vCenter ; Connect_Recovery_SRM })
#endregion ~~< RecoverySiteConnectButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< MainTab InfrastructureInfo >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SubTab Capture >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureCsvOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureCsvOutputButton.Add_Click( { Find_SRMCaptureCsvFolder ;
	if ($SRMCaptureCsvFolder -eq $null)
	{
		$SRMCaptureCsvOutputButton.Forecolor = [System.Drawing.Color]::Red ; $SRMCaptureCsvOutputButton.Text = "Folder Not Selected"
	}
	else
	{
		$SRMCaptureCsvOutputButton.Forecolor = [System.Drawing.Color]::Green ; $SRMCaptureCsvOutputButton.Text = $SRMCaptureCsvFolder
	}
Check_SRMCaptureCsvFolder } )
#endregion ~~< SRMCaptureCsvOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureUncheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureUncheckButton.Add_Click({ $ProtectedSitevCenterInfoCsvCheckBox.CheckState = "UnChecked" ;
	$ProtectedSiteSrmInfoCsvCheckBox.CheckState = "UnChecked" ;
	$ProtectedSiteRecoveryPlanCsvCheckBox.CheckState = "UnChecked" ;
	$ProtectedSiteProtectionGroupCsvCheckBox.CheckState = "UnChecked" ;
	$ProtectedSiteVMCsvCheckBox.CheckState = "UnChecked" ;
	$ProtectedSiteDatastoreCsvCheckBox.CheckState = "UnChecked" ;
	$RecoverySitevCenterInfoCsvCheckBox.CheckState = "UnChecked" ;
	$RecoverySiteSrmInfoCsvCheckBox.CheckState = "UnChecked" ;
	$RecoverySiteRecoveryPlanCsvCheckBox.CheckState = "UnChecked" ;
	$RecoverySiteProtectionGroupCsvCheckBox.CheckState = "UnChecked" ;
	$RecoverySiteVMCsvCheckBox.CheckState = "UnChecked" ;
	$RecoverySiteDatastoreCsvCheckBox.CheckState = "UnChecked" })
#endregion ~~< SRMCaptureUncheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureCheckButton.Add_Click({ $ProtectedSitevCenterInfoCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteSrmInfoCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteRecoveryPlanCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteProtectionGroupCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteVMCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteDatastoreCsvCheckBox.CheckState = "Checked" ;
	$RecoverySitevCenterInfoCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteSrmInfoCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteRecoveryPlanCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteProtectionGroupCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteVMCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteDatastoreCsvCheckBox.CheckState = "Checked" })
#endregion ~~< SRMCaptureCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCaptureButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCaptureButton.Add_Click({
	if($SRMCaptureCsvFolder -eq $null)
	{
		$SRMCaptureButton.Forecolor = [System.Drawing.Color]::Red; $SRMCaptureButton.Text = "Folder Not Selected"
	}
	else
	{ 
		if ($ProtectedSitevCenterInfoCsvCheckBox.Checked -eq "True")
		{
			$ProtectedSitevCenterInfoValidationComplete.Forecolor = "Blue"
			$ProtectedSitevCenterInfoValidationComplete.Text = "Processing ....."
			ProtectedSitevCenter_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $ProtectedSiteSRM
			$ProtectedSitevCenterServerExportFileComplete = $CsvCompleteDir + "-ProtectedSitevCenterServerExport.csv"
			$ProtectedSitevCenterServerCsvComplete = Test-Path $ProtectedSitevCenterServerExportFileComplete
			if ($ProtectedSitevCenterServerCsvComplete -eq $True)
			{
				$ProtectedSitevCenterInfoValidationComplete.Forecolor = "Green"
				$ProtectedSitevCenterInfoValidationComplete.Text = "Complete"
			}
			else
			{
				$ProtectedSitevCenterInfoValidationComplete.Forecolor = "Red"
				$ProtectedSitevCenterInfoValidationComplete.Text = "Not Complete"
			}
		}
		if ($ProtectedSiteSrmInfoCsvCheckBox.Checked -eq "True")
		{
			$ProtectedSiteSrmInfoValidationComplete.Forecolor = "Blue"
			$ProtectedSiteSrmInfoValidationComplete.Text = "Processing ....."
			ProtectedSiteSRM_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $ProtectedSiteSRM
			$ProtectedSiteSrmServerExportFileComplete = $CsvCompleteDir + "-ProtectedSiteSrmServerExport.csv"
			$ProtectedSiteSrmServerCsvComplete = Test-Path $ProtectedSiteSrmServerExportFileComplete
			if ($ProtectedSiteSrmServerCsvComplete -eq $True)
			{
				$ProtectedSiteSrmInfoValidationComplete.Forecolor = "Green"
				$ProtectedSiteSrmInfoValidationComplete.Text = "Complete"
			}
			else
			{
				$ProtectedSiteSrmInfoValidationComplete.Forecolor = "Red"
				$ProtectedSiteSrmInfoValidationComplete.Text = "Not Complete"
			}
		}
		if ($ProtectedSiteRecoveryPlanCsvCheckBox.Checked -eq "True")
		{
			$ProtectedSiteRecoveryPlanCsvValidationComplete.Forecolor = "Blue"
			$ProtectedSiteRecoveryPlanCsvValidationComplete.Text = "Processing ....."
			ProtectedSiteRecoveryPlan_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $ProtectedSiteSRM
			$ProtectedSiteRecoveryPlanExportFileComplete = $CsvCompleteDir + "-ProtectedSiteRecoveryPlanExport.csv"
			$ProtectedSiteRecoveryPlanCsvComplete = Test-Path $ProtectedSiteRecoveryPlanExportFileComplete
			if ($ProtectedSiteRecoveryPlanCsvComplete -eq $True)
			{
				$ProtectedSiteRecoveryPlanCsvValidationComplete.Forecolor = "Green"
				$ProtectedSiteRecoveryPlanCsvValidationComplete.Text = "Complete"
			}
			else
			{
				$ProtectedSiteRecoveryPlanCsvValidationComplete.Forecolor = "Red"
				$ProtectedSiteRecoveryPlanCsvValidationComplete.Text = "Not Complete"
			}
		}
		if ($ProtectedSiteProtectionGroupCsvCheckBox.Checked -eq "True")
		{
			$ProtectedSiteProtectionGroupCsvValidationComplete.Forecolor = "Blue"
			$ProtectedSiteProtectionGroupCsvValidationComplete.Text = "Processing ....."
			ProtectedSiteProtectionGroup_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $ProtectedSiteSRM
			$ProtectedSiteProtectionGroupExportFileComplete = $CsvCompleteDir + "-ProtectedSiteProtectionGroupExport.csv"
			$ProtectedSiteProtectionGroupCsvComplete = Test-Path $ProtectedSiteProtectionGroupExportFileComplete
			if ($ProtectedSiteProtectionGroupCsvComplete -eq $True)
			{
				$ProtectedSiteProtectionGroupCsvValidationComplete.Forecolor = "Green"
				$ProtectedSiteProtectionGroupCsvValidationComplete.Text = "Complete"
			}
			else
			{
				$ProtectedSiteProtectionGroupCsvValidationComplete.Forecolor = "Red"
				$ProtectedSiteProtectionGroupCsvValidationComplete.Text = "Not Complete"
			}
		}
		if ($ProtectedSiteVMCsvCheckBox.Checked -eq "True")
		{
			$ProtectedSiteVMCsvValidationComplete.Forecolor = "Blue"
			$ProtectedSiteVMCsvValidationComplete.Text = "Processing ....."
			ProtectedSiteVM_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $ProtectedSiteSRM
			$ProtectedSiteVMExportFileComplete = $CsvCompleteDir + "-ProtectedSiteVMExport.csv"
			$ProtectedSiteVMCsvComplete = Test-Path $ProtectedSiteVMExportFileComplete
			if ($ProtectedSiteVMCsvComplete -eq $True)
			{
				$ProtectedSiteVMCsvValidationComplete.Forecolor = "Green"
				$ProtectedSiteVMCsvValidationComplete.Text = "Complete"
			}
			else
			{
				$ProtectedSiteVMCsvValidationComplete.Forecolor = "Red"
				$ProtectedSiteVMCsvValidationComplete.Text = "Not Complete"
			}
		}
		if ($ProtectedSiteDatastoreCsvCheckBox.Checked -eq "True")
		{
			$ProtectedSiteDatastoreCsvValidationComplete.Forecolor = "Blue"
			$ProtectedSiteDatastoreCsvValidationComplete.Text = "Processing ....."
			ProtectedSiteDatastore_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $ProtectedSiteSRM
			$ProtectedSiteDatastoreExportFileComplete = $CsvCompleteDir + "-ProtectedSiteDatastoreExport.csv"
			$ProtectedSiteDatastoreCsvComplete = Test-Path $ProtectedSiteDatastoreExportFileComplete
			if ($ProtectedSiteDatastoreCsvComplete -eq $True)
			{
				$ProtectedSiteDatastoreCsvValidationComplete.Forecolor = "Green"
				$ProtectedSiteDatastoreCsvValidationComplete.Text = "Complete"
			}
			else
			{
				$ProtectedSiteDatastoreCsvValidationComplete.Forecolor = "Red"
				$ProtectedSiteDatastoreCsvValidationComplete.Text = "Not Complete"
			}
		}
		if ($RecoverySitevCenterInfoCsvCheckBox.Checked -eq "True")
		{
			$RecoverySitevCenterInfoValidationComplete.Forecolor = "Blue"
			$RecoverySitevCenterInfoValidationComplete.Text = "Processing ....."
			RecoverySitevCenter_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $RecoverySiteSRM
			$RecoverySitevCenterServerExportFileComplete = $CsvCompleteDir + "-RecoverySitevCenterServerExport.csv"
			$RecoverySitevCenterServerCsvComplete = Test-Path $RecoverySitevCenterServerExportFileComplete
			if ($RecoverySitevCenterServerCsvComplete -eq $True)
			{
				$RecoverySitevCenterInfoValidationComplete.Forecolor = "Green"
				$RecoverySitevCenterInfoValidationComplete.Text = "Complete"
			}
			else
			{
				$RecoverySitevCenterInfoValidationComplete.Forecolor = "Red"
				$RecoverySitevCenterInfoValidationComplete.Text = "Not Complete"
			}
		}
		if ($RecoverySiteSrmInfoCsvCheckBox.Checked -eq "True")
		{
			$RecoverySiteSrmInfoValidationComplete.Forecolor = "Blue"
			$RecoverySiteSrmInfoValidationComplete.Text = "Processing ....."
			RecoverySiteSRM_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $RecoverySiteSRM
			$RecoverySiteSrmServerExportFileComplete = $CsvCompleteDir + "-RecoverySiteSrmServerExport.csv"
			$RecoverySiteSrmServerCsvComplete = Test-Path $RecoverySiteSrmServerExportFileComplete
			if ($RecoverySiteSrmServerCsvComplete -eq $True)
			{
				$RecoverySiteSrmInfoValidationComplete.Forecolor = "Green"
				$RecoverySiteSrmInfoValidationComplete.Text = "Complete"
			}
			else
			{
				$RecoverySiteSrmInfoValidationComplete.Forecolor = "Red"
				$RecoverySiteSrmInfoValidationComplete.Text = "Not Complete"
			}
		}
		if ($RecoverySiteRecoveryPlanCsvCheckBox.Checked -eq "True")
		{
			$RecoverySiteRecoveryPlanCsvValidationComplete.Forecolor = "Blue"
			$RecoverySiteRecoveryPlanCsvValidationComplete.Text = "Processing ....."
			RecoverySiteRecoveryPlan_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $RecoverySiteSRM
			$RecoverySiteRecoveryPlanExportFileComplete = $CsvCompleteDir + "-RecoverySiteRecoveryPlanExport.csv"
			$RecoverySiteRecoveryPlanCsvComplete = Test-Path $RecoverySiteRecoveryPlanExportFileComplete
			if ($RecoverySiteRecoveryPlanCsvComplete -eq $True)
			{
				$RecoverySiteRecoveryPlanCsvValidationComplete.Forecolor = "Green"
				$RecoverySiteRecoveryPlanCsvValidationComplete.Text = "Complete"
			}
			else
			{
				$RecoverySiteRecoveryPlanCsvValidationComplete.Forecolor = "Red"
				$RecoverySiteRecoveryPlanCsvValidationComplete.Text = "Not Complete"
			}
		}
		if ($RecoverySiteProtectionGroupCsvCheckBox.Checked -eq "True")
		{
			$RecoverySiteProtectionGroupCsvValidationComplete.Forecolor = "Blue"
			$RecoverySiteProtectionGroupCsvValidationComplete.Text = "Processing ....."
			RecoverySiteProtectionGroup_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $RecoverySiteSRM
			$RecoverySiteProtectionGroupExportFileComplete = $CsvCompleteDir + "-RecoverySiteProtectionGroupExport.csv"
			$RecoverySiteProtectionGroupCsvComplete = Test-Path $RecoverySiteProtectionGroupExportFileComplete
			if ($RecoverySiteProtectionGroupCsvComplete -eq $True)
			{
				$RecoverySiteProtectionGroupCsvValidationComplete.Forecolor = "Green"
				$RecoverySiteProtectionGroupCsvValidationComplete.Text = "Complete"
			}
			else
			{
				$RecoverySiteProtectionGroupCsvValidationComplete.Forecolor = "Red"
				$RecoverySiteProtectionGroupCsvValidationComplete.Text = "Not Complete"
			}
		}
		if ($RecoverySiteVMCsvCheckBox.Checked -eq "True")
		{
			$RecoverySiteVMCsvValidationComplete.Forecolor = "Blue"
			$RecoverySiteVMCsvValidationComplete.Text = "Processing ....."
			RecoverySiteVM_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $RecoverySiteSRM
			$RecoverySiteVMExportFileComplete = $CsvCompleteDir + "-RecoverySiteVMExport.csv"
			$RecoverySiteVMCsvComplete = Test-Path $RecoverySiteVMExportFileComplete
			if ($RecoverySiteVMCsvComplete -eq $True)
			{
				$RecoverySiteVMCsvValidationComplete.Forecolor = "Green"
				$RecoverySiteVMCsvValidationComplete.Text = "Complete"
			}
			else
			{
				$RecoverySiteVMCsvValidationComplete.Forecolor = "Red"
				$RecoverySiteVMCsvValidationComplete.Text = "Not Complete"
			}
		}
		if ($RecoverySiteDatastoreCsvCheckBox.Checked -eq "True")
		{
			$RecoverySiteDatastoreCsvValidationComplete.Forecolor = "Blue"
			$RecoverySiteDatastoreCsvValidationComplete.Text = "Processing ....."
			RecoverySiteDatastore_Export
			$CsvCompleteDir = $SRMCaptureCsvFolder + "\" + $RecoverySiteSRM
			$RecoverySiteDatastoreExportFileComplete = $CsvCompleteDir + "-RecoverySiteDatastoreExport.csv"
			$RecoverySiteDatastoreCsvComplete = Test-Path $RecoverySiteDatastoreExportFileComplete
			if ($RecoverySiteDatastoreCsvComplete -eq $True)
			{
				$RecoverySiteDatastoreCsvValidationComplete.Forecolor = "Green"
				$RecoverySiteDatastoreCsvValidationComplete.Text = "Complete"
			}
			else
			{
				$RecoverySiteDatastoreCsvValidationComplete.Forecolor = "Red"
				$RecoverySiteDatastoreCsvValidationComplete.Text = "Not Complete"
			}
		}
		Disconnect_SRM
		Disconnect_vCenter
		$ProtectedSiteConnectButton.Forecolor = [System.Drawing.Color]::Red
		$ProtectedSiteConnectButton.Text = "Disconnected"
		$RecoverySiteConnectButton.Forecolor = [System.Drawing.Color]::Red
		$RecoverySiteConnectButton.Text = "Disconnected"
		$SRMCaptureButton.Forecolor = [System.Drawing.Color]::Green ; $SRMCaptureButton.Text = "CSV Collection Complete"
	}
})
#endregion ~~< SRMCaptureButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< CaptureOpenOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OpenCaptureButton.Add_Click({Open_Capture_Folder;
	$ProtectedSiteVcenterTextBox.Text = "" ;
	$RecoverySiteVcenterTextBox.Text = "" ;
	$ProtectedSiteSrmServerTextBox.Text = "" ;
	$RecoverySiteSrmServerTextBox.Text = "" ;
	$UserNameTextBox.Text = "" ;
	$PasswordTextBox.Text = "" ;
	$PasswordTextBox.UseSystemPasswordChar = $true ;
	$ProtectedSiteConnectButton.Forecolor = [System.Drawing.Color]::Black ;
	$ProtectedSiteConnectButton.Text = "Connect to Protected Site" ;
	$RecoverySiteConnectButton.Forecolor = [System.Drawing.Color]::Black ;
	$RecoverySiteConnectButton.Text = "Connect to Recovery Site" ;
	$SRMCaptureCsvOutputButton.Forecolor = [System.Drawing.Color]::Black ;
	$SRMCaptureCsvOutputButton.Text = "Select Output Folder" ;
	$SRMCaptureButton.Forecolor = [System.Drawing.Color]::Black ;
	$SRMCaptureButton.Text = "Collect CSV Data" ;
	$ProtectedSitevCenterInfoCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSitevCenterInfoValidationComplete.Text = "" ;
	$ProtectedSiteSrmInfoCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteSrmInfoValidationComplete.Text = "" ;
	$ProtectedSiteRecoveryPlanCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteRecoveryPlanCsvValidationComplete.Text = "" ;
	$ProtectedSiteProtectionGroupCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteProtectionGroupCsvValidationComplete.Text = "" ;
	$ProtectedSiteVMCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteVMCsvValidationComplete.Text = "" ;
	$ProtectedSiteDatastoreCsvCheckBox.CheckState = "Checked" ;
	$ProtectedSiteDatastoreCsvValidationComplete.Text = "" ;
	$RecoverySitevCenterInfoCsvCheckBox.CheckState = "Checked" ;
	$RecoverySitevCenterInfoValidationComplete.Text = "" ;
	$RecoverySiteSrmInfoCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteSrmInfoValidationComplete.Text = "" ;
	$RecoverySiteRecoveryPlanCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteRecoveryPlanCsvValidationComplete.Text = "" ;
	$RecoverySiteProtectionGroupCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteProtectionGroupCsvValidationComplete.Text = "" ;
	$RecoverySiteVMCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteVMCsvValidationComplete.Text = "" ;
	$RecoverySiteDatastoreCsvCheckBox.CheckState = "Checked" ;
	$RecoverySiteDatastoreCsvValidationComplete.Text = ""
})
#endregion ~~< CaptureOpenOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< SubTab Capture >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SubTab Draw >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMDrawCsvInputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMDrawCsvInputButton.Add_MouseClick({ Find_SRMDrawCsvFolder ;
	if ($SRMDrawCsvFolder -eq $null)
	{
		$SRMDrawCsvInputButton.Forecolor = [System.Drawing.Color]::Red ; $SRMDrawCsvInputButton.Text = "Folder Not Selected"
	}
	else
	{
		$SRMDrawCsvInputButton.Forecolor = [System.Drawing.Color]::Green ; $SRMDrawCsvInputButton.Text = $SRMDrawCsvFolder
	}
} )
$TabDrawSRM.Controls.Add($SRMDrawCsvInputButton)
#endregion ~~< SRMDrawCsvInputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< SRMCsvValidationButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SRMCsvValidationButton.Add_Click(
{
	$ProtectedCsvInputDir = $SRMDrawCsvFolder + "\" + $ProtectedSiteSrmServerTextBox.Text
	$ProtectedSitevCenterServerExportFile = $ProtectedCsvInputDir + "-ProtectedSitevCenterServerExport.csv"
	$ProtectedSitevCenterServerCsvExists = Test-Path $ProtectedSitevCenterServerExportFile
	$TabDrawSRM.Controls.Add($ProtectedSitevCenterCsvValidationCheck)
	if ($ProtectedSitevCenterServerCsvExists -eq $True)
	{
							
		$ProtectedSitevCenterCsvValidationCheck.Forecolor = "Green"
		$ProtectedSitevCenterCsvValidationCheck.Text = "Present"
	}
	else
	{
		$ProtectedSitevCenterCsvValidationCheck.Forecolor = "Red"
		$ProtectedSitevCenterCsvValidationCheck.Text = "Not Present"
	}
	
	$ProtectedSiteSrmServerExportFile = $ProtectedCsvInputDir + "-ProtectedSiteSrmServerExport.csv"
	$ProtectedSiteSrmServerCsvExists = Test-Path $ProtectedSiteSrmServerExportFile
	$TabDrawSRM.Controls.Add($ProtectedSiteSrmCsvValidationCheck)
	if ($ProtectedSiteSrmServerCsvExists -eq $True)
	{
							
		$ProtectedSiteSrmCsvValidationCheck.Forecolor = "Green"
		$ProtectedSiteSrmCsvValidationCheck.Text = "Present"
	}
	else
	{
		$ProtectedSiteSrmCsvValidationCheck.Forecolor = "Red"
		$ProtectedSiteSrmCsvValidationCheck.Text = "Not Present"
	}	
	
	$ProtectedSiteRecoveryPlanExportFile = $ProtectedCsvInputDir + "-ProtectedSiteRecoveryPlanExport.csv"
	$ProtectedSiteRecoveryPlanCsvExists = Test-Path $ProtectedSiteRecoveryPlanExportFile
	$TabDrawSRM.Controls.Add($ProtectedSiteRecoveryPlanCsvValidationCheck)
	if ($ProtectedSiteRecoveryPlanCsvExists -eq $True)
	{
							
		$ProtectedSiteRecoveryPlanCsvValidationCheck.Forecolor = "Green"
		$ProtectedSiteRecoveryPlanCsvValidationCheck.Text = "Present"
	}
	else
	{
		$ProtectedSiteRecoveryPlanCsvValidationCheck.Forecolor = "Red"
		$ProtectedSiteRecoveryPlanCsvValidationCheck.Text = "Not Present"
	}
	
	$ProtectedSiteProtectionGroupExportFile = $ProtectedCsvInputDir + "-ProtectedSiteProtectionGroupExport.csv"
	$ProtectedSiteProtectionGroupCsvExists = Test-Path $ProtectedSiteProtectionGroupExportFile
	$TabDrawSRM.Controls.Add($ProtectedSiteProtectionGroupCsvValidationCheck)
	if ($ProtectedSiteProtectionGroupCsvExists -eq $True)
	{
							
		$ProtectedSiteProtectionGroupCsvValidationCheck.Forecolor = "Green"
		$ProtectedSiteProtectionGroupCsvValidationCheck.Text = "Present"
	}
	else
	{
		$ProtectedSiteProtectionGroupCsvValidationCheck.Forecolor = "Red"
		$ProtectedSiteProtectionGroupCsvValidationCheck.Text = "Not Present"
	}
	
	$ProtectedSiteVmExportFile = $ProtectedCsvInputDir + "-ProtectedSiteVmExport.csv"
	$ProtectedSiteVmCsvExists = Test-Path $ProtectedSiteVmExportFile
	$TabDrawSRM.Controls.Add($ProtectedSiteVmCsvValidationCheck)
	if ($ProtectedSiteVmCsvExists -eq $True)
	{
							
		$ProtectedSiteVmCsvValidationCheck.Forecolor = "Green"
		$ProtectedSiteVmCsvValidationCheck.Text = "Present"
	}
	else
	{
		$ProtectedSiteVmCsvValidationCheck.Forecolor = "Red"
		$ProtectedSiteVmCsvValidationCheck.Text = "Not Present"
	}
	
	$ProtectedSiteDatastoreExportFile = $ProtectedCsvInputDir + "-ProtectedSiteDatastoreExport.csv"
	$ProtectedSiteDatastoreCsvExists = Test-Path $ProtectedSiteDatastoreExportFile
	$TabDrawSRM.Controls.Add($ProtectedSiteDatastoreCsvValidationCheck)
	if ($ProtectedSiteDatastoreCsvExists -eq $True)
	{
							
		$ProtectedSiteDatastoreCsvValidationCheck.Forecolor = "Green"
		$ProtectedSiteDatastoreCsvValidationCheck.Text = "Present"
	}
	else
	{
		$ProtectedSiteDatastoreCsvValidationCheck.Forecolor = "Red"
		$ProtectedSiteDatastoreCsvValidationCheck.Text = "Not Present"
	}
	
	$RecoveryCsvInputDir = $SRMDrawCsvFolder + "\" + $RecoverySiteSrmServerTextBox.Text
	$RecoverySitevCenterServerExportFile = $RecoveryCsvInputDir + "-RecoverySitevCenterServerExport.csv"
	$RecoverySitevCenterServerCsvExists = Test-Path $RecoverySitevCenterServerExportFile
	$TabDrawSRM.Controls.Add($RecoverySitevCenterCsvValidationCheck)
	if ($RecoverySitevCenterServerCsvExists -eq $True)
	{
							
		$RecoverySitevCenterCsvValidationCheck.Forecolor = "Green"
		$RecoverySitevCenterCsvValidationCheck.Text = "Present"
	}
	else
	{
		$RecoverySitevCenterCsvValidationCheck.Forecolor = "Red"
		$RecoverySitevCenterCsvValidationCheck.Text = "Not Present"
	}
	
	$RecoverySiteSrmServerExportFile = $RecoveryCsvInputDir + "-RecoverySiteSrmServerExport.csv"
	$RecoverySiteSrmServerCsvExists = Test-Path $RecoverySiteSrmServerExportFile
	$TabDrawSRM.Controls.Add($RecoverySiteSrmCsvValidationCheck)
	if ($RecoverySiteSrmServerCsvExists -eq $True)
	{
							
		$RecoverySiteSrmCsvValidationCheck.Forecolor = "Green"
		$RecoverySiteSrmCsvValidationCheck.Text = "Present"
	}
	else
	{
		$RecoverySiteSrmCsvValidationCheck.Forecolor = "Red"
		$RecoverySiteSrmCsvValidationCheck.Text = "Not Present"
	}	
	
	$RecoverySiteRecoveryPlanExportFile = $RecoveryCsvInputDir + "-RecoverySiteRecoveryPlanExport.csv"
	$RecoverySiteRecoveryPlanCsvExists = Test-Path $RecoverySiteRecoveryPlanExportFile
	$TabDrawSRM.Controls.Add($RecoverySiteRecoveryPlanCsvValidationCheck)
	if ($RecoverySiteRecoveryPlanCsvExists -eq $True)
	{
							
		$RecoverySiteRecoveryPlanCsvValidationCheck.Forecolor = "Green"
		$RecoverySiteRecoveryPlanCsvValidationCheck.Text = "Present"
	}
	else
	{
		$RecoverySiteRecoveryPlanCsvValidationCheck.Forecolor = "Red"
		$RecoverySiteRecoveryPlanCsvValidationCheck.Text = "Not Present"
	}
	
	$RecoverySiteProtectionGroupExportFile = $RecoveryCsvInputDir + "-RecoverySiteProtectionGroupExport.csv"
	$RecoverySiteProtectionGroupCsvExists = Test-Path $RecoverySiteProtectionGroupExportFile
	$TabDrawSRM.Controls.Add($RecoverySiteProtectionGroupCsvValidationCheck)
	if ($RecoverySiteProtectionGroupCsvExists -eq $True)
	{
							
		$RecoverySiteProtectionGroupCsvValidationCheck.Forecolor = "Green"
		$RecoverySiteProtectionGroupCsvValidationCheck.Text = "Present"
	}
	else
	{
		$RecoverySiteProtectionGroupCsvValidationCheck.Forecolor = "Red"
		$RecoverySiteProtectionGroupCsvValidationCheck.Text = "Not Present"
	}
	
	$RecoverySiteVmExportFile = $RecoveryCsvInputDir + "-RecoverySiteVmExport.csv"
	$RecoverySiteVmCsvExists = Test-Path $RecoverySiteVmExportFile
	$TabDrawSRM.Controls.Add($RecoverySiteVmCsvValidationCheck)
	if ($RecoverySiteVmCsvExists -eq $True)
	{
							
		$RecoverySiteVmCsvValidationCheck.Forecolor = "Green"
		$RecoverySiteVmCsvValidationCheck.Text = "Present"
	}
	else
	{
		$RecoverySiteVmCsvValidationCheck.Forecolor = "Red"
		$RecoverySiteVmCsvValidationCheck.Text = "Not Present"
	}
	
	$RecoverySiteDatastoreExportFile = $RecoveryCsvInputDir + "-RecoverySiteDatastoreExport.csv"
	$RecoverySiteDatastoreCsvExists = Test-Path $RecoverySiteDatastoreExportFile
	$TabDrawSRM.Controls.Add($RecoverySiteDatastoreCsvValidationCheck)
	if ($RecoverySiteDatastoreCsvExists -eq $True)
	{
							
		$RecoverySiteDatastoreCsvValidationCheck.Forecolor = "Green"
		$RecoverySiteDatastoreCsvValidationCheck.Text = "Present"
	}
	else
	{
		$RecoverySiteDatastoreCsvValidationCheck.Forecolor = "Red"
		$RecoverySiteDatastoreCsvValidationCheck.Text = "Not Present"
	}
} )
$SRMCsvValidationButton.Add_MouseClick({ $SRMCsvValidationButton.Forecolor = [System.Drawing.Color]::Green ;
	$SRMCsvValidationButton.Text = "CSV Validation Complete"
} )
$TabDrawSRM.Controls.Add($SRMCsvValidationButton)
#endregion ~~< SRMCsvValidationButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< VisioOpenOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$VisioOpenOutputButton.Add_MouseClick({Find_SRMDrawVisioFolder; 
	if($VisioFolder -eq $null)
	{
		$VisioOpenOutputButton.Forecolor = [System.Drawing.Color]::Red ;
		$VisioOpenOutputButton.Text = "Folder Not Selected"
	}
	else
	{
		$VisioOpenOutputButton.Forecolor = [System.Drawing.Color]::Green ;
		$VisioOpenOutputButton.Text = $VisioFolder
	}
})
$TabDrawSRM.Controls.Add($VisioOpenOutputButton)
#endregion ~~< VisioOpenOutputButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< IndividualCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawIndividualCheckButton.Add_Click({$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "UnChecked" ;
	$Combined_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "UnChecked" ;
	$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked"	}) 
$TabDrawSRM.Controls.Add($DrawIndividualCheckButton)
#endregion ~~< IndividualCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< CombinedCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawCombinedCheckButton.Add_Click({$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "UnChecked" ;
	$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "UnChecked" ;
	$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "UnChecked" ;
	$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "UnChecked" ;
	$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "UnChecked" })
$TabDrawSRM.Controls.Add($DrawCombinedCheckButton)
#endregion ~~< CombinedCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawUncheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawUncheckButton.Add_Click({$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "UnChecked" ;
	$Combined_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "UnChecked" ;
	$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "UnChecked" ;
	$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "UnChecked" ;
	$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "UnChecked" ;
	$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "UnChecked" ;
	$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "UnChecked" ;
	$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "UnChecked" })
$TabDrawSRM.Controls.Add($DrawUncheckButton)
#endregion ~~< DrawUncheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawCheckButton.Add_Click({$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked"	})
$TabDrawSRM.Controls.Add($DrawCheckButton)
#endregion ~~< DrawCheckButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< DrawButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$DrawButton.Add_Click({if($VisioFolder -eq $null){$DrawButton.Forecolor = [System.Drawing.Color]::Red; $DrawButton.Text = "Folder Not Selected"}else{$DrawButton.Forecolor = [System.Drawing.Color]::Blue; $DrawButton.Text = "Drawing Please Wait"; Create_Visio_Base;
	if ($Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Checked -eq "True")
	{
		$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.Forecolor = "Blue"
		$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete)
		Combined_RecoveryPlan_to_ProtectionGroup
		$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.Forecolor = "Green"
		$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "Complete"
		$TabDrawSRM.Controls.Add($Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete)
	}
	if ($Combined_ProtectionGroup_to_VM_DrawCheckBox.Checked -eq "True")
	{
		$Combined_ProtectionGroup_to_VM_DrawComplete.Forecolor = "Blue"
		$Combined_ProtectionGroup_to_VM_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_VM_DrawComplete)
		Combined_ProtectionGroup_to_VM
		$Combined_ProtectionGroup_to_VM_DrawComplete.Forecolor = "Green"
		$Combined_ProtectionGroup_to_VM_DrawComplete.Text = "Complete"
		$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_VM_DrawComplete)
	}
	if ($Combined_ProtectionGroup_to_Datastore_DrawCheckBox.Checked -eq "True")
	{
		$Combined_ProtectionGroup_to_Datastore_DrawComplete.Forecolor = "Blue"
		$Combined_ProtectionGroup_to_Datastore_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_Datastore_DrawComplete)
		Combined_ProtectionGroup_to_Datastore
		$Combined_ProtectionGroup_to_Datastore_DrawComplete.Forecolor = "Green"
		$Combined_ProtectionGroup_to_Datastore_DrawComplete.Text = "Complete"
		$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_Datastore_DrawComplete)
	}
	if ($Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.Checked -eq "True")
	{
		$Combined_ProtectionGroup_to_VR_VM_DrawComplete.Forecolor = "Blue"
		$Combined_ProtectionGroup_to_VR_VM_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_VR_VM_DrawComplete)
		Combined_ProtectionGroup_to_VR_VM
		$Combined_ProtectionGroup_to_VR_VM_DrawComplete.Forecolor = "Green"
		$Combined_ProtectionGroup_to_VR_VM_DrawComplete.Text = "Complete"
		$TabDrawSRM.Controls.Add($Combined_ProtectionGroup_to_VR_VM_DrawComplete)
	}
	if ($ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Checked -eq "True")
	{
		$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Forecolor = "Blue"
		$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete)
		ProtectedSite_RecoveryPlan_to_ProtectionGroup
		$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Forecolor = "Green"
		$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "Complete"
		$TabDrawSRM.Controls.Add($ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete)
	}
	if ($ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.Checked -eq "True")
	{
		$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.Forecolor = "Blue"
		$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_VM_DrawComplete)
		ProtectedSite_ProtectionGroup_to_VM
		$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.Forecolor = "Green"
		$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.Text = "Complete"
	}
	if ($ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.Checked -eq "True")
	{
		$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.Forecolor = "Blue"
		$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete)
		ProtectedSite_ProtectionGroup_to_Datastore
		$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.Forecolor = "Green"
		$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.Text = "Complete"
	}
	if ($ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.Checked -eq "True")
	{
		$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.Forecolor = "Blue"
		$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete)
		ProtectedSite_ProtectionGroup_to_VR_VM
		$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.Forecolor = "Green"
		$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.Text = "Complete"
	}	
	if ($RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.Checked -eq "True")
	{
		$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Forecolor = "Blue"
		$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete)
		RecoverySite_RecoveryPlan_to_ProtectionGroup
		$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Forecolor = "Green"
		$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "Complete"
	}
	if ($RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.Checked -eq "True")
	{
		$RecoverySite_ProtectionGroup_to_VM_DrawComplete.Forecolor = "Blue"
		$RecoverySite_ProtectionGroup_to_VM_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_VM_DrawComplete)
		RecoverySite_ProtectionGroup_to_VM
		$RecoverySite_ProtectionGroup_to_VM_DrawComplete.Forecolor = "Green"
		$RecoverySite_ProtectionGroup_to_VM_DrawComplete.Text = "Complete"
	}
	if ($RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.Checked -eq "True")
	{
		$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.Forecolor = "Blue"
		$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_Datastore_DrawComplete)
		RecoverySite_ProtectionGroup_to_Datastore
		$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.Forecolor = "Green"
		$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.Text = "Complete"
	}
	if ($RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.Checked -eq "True")
	{
		$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.Forecolor = "Blue"
		$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.Text = "Processing ..."
		$TabDrawSRM.Controls.Add($RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete)
		RecoverySite_ProtectionGroup_to_VR_VM
		$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.Forecolor = "Green"
		$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.Text = "Complete"
	}
	$DrawButton.Forecolor = [System.Drawing.Color]::Green; $DrawButton.Text = "Visio Drawings Complete"}}
)
$TabDrawSRM.Controls.Add($DrawButton)
#endregion ~~< DrawButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< OpenVisioButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OpenVisioButton.Add_Click({Open_Final_Visio;
	$ProtectedSiteVcenterTextBox.Text = "" ;
	$RecoverySiteVcenterTextBox.Text = "" ;
	$ProtectedSiteSrmServerTextBox.Text = "" ;
	$RecoverySiteSrmServerTextBox.Text = "" ;
	$UserNameTextBox.Text = "" ;
	$PasswordTextBox.Text = "" ;
	$PasswordTextBox.UseSystemPasswordChar = $true ;
	$ProtectedSiteConnectButton.Forecolor = [System.Drawing.Color]::Black ;
	$ProtectedSiteConnectButton.Text = "Connect to Protected Site" ;
	$RecoverySiteConnectButton.Forecolor = [System.Drawing.Color]::Black ;
	$RecoverySiteConnectButton.Text = "Connect to Recovery Site" ;
	$SRMDrawCsvInputButton.Forecolor = [System.Drawing.Color]::Black ;
	$SRMDrawCsvInputButton.Text = "Select CSV Input Folder" ;
	$SRMCsvValidationButton.Forecolor = [System.Drawing.Color]::Black ;
	$SRMCsvValidationButton.Text = "Check for CSVs" ;
	$VisioOpenOutputButton.Forecolor = [System.Drawing.Color]::Black ;
	$VisioOpenOutputButton.Text = "Select Visio Output Folder" ;
	$ProtectedSitevCenterCsvValidationCheck.Text = "" ;
	$ProtectedSiteSrmCsvValidationCheck.Text = "" ;
	$ProtectedSiteRecoveryPlanCsvValidationCheck.Text = "" ;
	$ProtectedSiteProtectionGroupCsvValidationCheck.Text = "" ;
	$ProtectedSiteVmCsvValidationCheck.Text = "" ;
	$ProtectedSiteDatastoreCsvValidationCheck.Text = "" ;
	$RecoverySitevCenterCsvValidationCheck.Text = "" ;
	$RecoverySiteSrmCsvValidationCheck.Text = "" ;
	$RecoverySiteRecoveryPlanCsvValidationCheck.Text = "" ;
	$RecoverySiteProtectionGroupCsvValidationCheck.Text = "" ;
	$RecoverySiteVmCsvValidationCheck.Text = "" ;
	$RecoverySiteDatastoreCsvValidationCheck.Text = "" ;
	$Combined_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$Combined_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "" ;
	$Combined_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_VM_DrawComplete.Text = "" ;
	$Combined_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_Datastore_DrawComplete.Text = "" ;
	$Combined_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked" ;
	$Combined_ProtectionGroup_to_VR_VM_DrawComplete.Text = "" ;
	$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "" ;
	$ProtectedSite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_VM_DrawComplete.Text = "" ;
	$ProtectedSite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_Datastore_DrawComplete.Text = "" ;
	$ProtectedSite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked" ;
	$ProtectedSite_ProtectionGroup_to_VR_VM_DrawComplete.Text = "" ;
	$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_RecoveryPlan_to_ProtectionGroup_DrawComplete.Text = "" ;
	$RecoverySite_ProtectionGroup_to_VM_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_VM_DrawComplete.Text = "" ;
	$RecoverySite_ProtectionGroup_to_Datastore_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_Datastore_DrawComplete.Text = "";
	$RecoverySite_ProtectionGroup_to_VR_VM_DrawCheckBox.CheckState = "Checked" ;
	$RecoverySite_ProtectionGroup_to_VR_VM_DrawComplete.Text = "";
	$DrawButton.Forecolor = [System.Drawing.Color]::Black ;
	$DrawButton.Text = "Draw Visio"
})
#endregion ~~< OpenVisioButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< SubTab Draw >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Button Actions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Custom Code >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#region ~~< Event Loop >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Main
{
	[System.Windows.Forms.Application]::EnableVisualStyles()
	[System.Windows.Forms.Application]::Run($SRMvDiagram)
}
#endregion ~~< Event Loop >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#region ~~< Event Handlers >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Connection Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< vCenter & SRM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Connect_Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Connect_Protected_vCenter Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Connect_Protected_vCenter
{
	$global:ProtectedSiteVC = $ProtectedSiteVcenterTextBox.Text
	$global:User = $UserNameTextBox.Text
	$ProtectedSitevCenter = Connect-VIServer $ProtectedSiteVC -user $User -password $PasswordTextBox.Text
}
#endregion ~~< Connect_Protected_vCenter Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Connect_Protected_SRM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Connect_Protected_SRM
{
	$global:ProtectedSiteSRM = $ProtectedSiteSrmServerTextBox.Text
	$global:User = $UserNameTextBox.Text
	$global:SiteASrmPlugin = (Connect-SrmServer $ProtectedSiteSRM -user $User -password $PasswordTextBox.Text).ExtensionData
	$global:SiteAProtection = $SiteASrmPlugin.Protection
	$global:SiteARecovery = $SiteASrmPlugin.Recovery
	$global:SiteAContent = $SiteASrmPlugin.Content
	
}
#endregion ~~< Connect_Protected_SRM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Connect_Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Connect_Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Connect_Recovery_vCenter Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Connect_Recovery_vCenter
{
	$global:RecoverySiteVC = $RecoverySiteVcenterTextBox.Text
	$global:User = $UserNameTextBox.Text
	$RecoverySitevCenter = Connect-VIServer $RecoverySiteVC -user $User -password $PasswordTextBox.Text
}
#endregion ~~< Connect_Recovery_vCenter Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Connect_Recovery_SRM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Connect_Recovery_SRM
{
	$global:RecoverySiteSRM = $RecoverySiteSrmServerTextBox.Text
	$global:User = $UserNameTextBox.Text
	$global:SiteBSrmPlugin = (Connect-SrmServer $RecoverySiteSRM -user $User -password $PasswordTextBox.Text).ExtensionData
	$global:SiteBProtection = $SiteBSrmPlugin.Protection
	$global:SiteBRecovery = $SiteBSrmPlugin.Recovery
	$global:SiteBContent = $SiteBSrmPlugin.Content
}
#endregion ~~< Connect_Recovery_SRM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Connect_Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Disconnect >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Disconnect_SRM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Disconnect_SRM
{
	$DisconnectSRM = Disconnect-SRMServer * -Confirm:$false
}
#endregion ~~< Disconnect_SRM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Disconnect_vCenter Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Disconnect_vCenter
{
	$DisconnectVC = Disconnect-ViServer * -Confirm:$false
}
#endregion ~~< Disconnect_vCenter Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Disconnect >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< vCenter & SRM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Connection Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Folder Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Find_SRMCaptureCsvFolder Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Find_SRMCaptureCsvFolder
{
	$SRMCaptureCsvBrowseLoop = $True
	while ($SRMCaptureCsvBrowseLoop)
	{
		if ($SRMCaptureCsvBrowse.ShowDialog() -eq "OK")
		{
			$SRMCaptureCsvBrowseLoop = $False
		}
		else
		{
			$SRMCaptureCsvBrowseRes = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
			if ($SRMCaptureCsvBrowseRes -eq "Cancel")
			{
				return
			}
		}
	}
	$global:SRMCaptureCsvFolder = $SRMCaptureCsvBrowse.SelectedPath
}
#endregion ~~< Find_SRMCaptureCsvFolder Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Check_SRMCaptureCsvFolder Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Check_SRMCaptureCsvFolder
{
	$CheckContentPath = $SRMCaptureCsvFolder + "\"
	$CheckContentDir = $CheckContentPath + "*.csv"
	$CheckContent = Test-Path $CheckContentDir
	if ($CheckContent -eq "True")
	{
		$CheckContents_SRMCaptureCsvFolder =  [System.Windows.MessageBox]::Show("Files where found in the folder. Would you like to delete these files? Click 'Yes' to delete and 'No' move files to a new folder.","Warning!","YesNo","Error")
		switch ($CheckContents_SRMCaptureCsvFolder)
		{ 
			'Yes' 
			{
				del $CheckContentDir
			}
			'No'
			{
				$CheckContentCsvBrowse = New-Object System.Windows.Forms.FolderBrowserDialog
				$CheckContentCsvBrowse.Description = "Select a directory to copy files to"
				$CheckContentCsvBrowse.RootFolder = [System.Environment+SpecialFolder]::MyComputer
				$CheckContentCsvBrowse.ShowDialog()
				$global:NewContentCsvFolder = $CheckContentCsvBrowse.SelectedPath
				copy-item -Path $CheckContentDir -Destination $NewContentCsvFolder
				del $CheckContentDir
			}
		}
	}
}
#endregion ~~< Check_SRMCaptureCsvFolder Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Find_SRMDrawCsvFolder Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Find_SRMDrawCsvFolder {
	$DrawCsvBrowseLoop = $True
	while ($DrawCsvBrowseLoop)
	{
		if ($DrawCsvBrowse.ShowDialog() -eq "OK")
		{
			$DrawCsvBrowseLoop = $False
		}
		else
		{
			$DrawCsvBrowseRes = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
			if ($DrawCsvBrowseRes -eq "Cancel")
			{
				return
			}
		}
	}
	$global:SRMDrawCsvFolder = $DrawCsvBrowse.SelectedPath
}
#endregion ~~< Find_SRMDrawCsvFolder Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Find_SRMDrawVisioFolder Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Find_SRMDrawVisioFolder
{
	$VisioBrowseLoop = $True
	while ($VisioBrowseLoop)
	{
		if ($VisioBrowse.ShowDialog() -eq "OK")
		{
			$VisioBrowseLoop = $False
		}
		else
		{
			$VisioBrowseRes = [System.Windows.Forms.MessageBox]::Show("You clicked Cancel. Would you like to try again or exit?", "Select a location", [System.Windows.Forms.MessageBoxButtons]::RetryCancel)
			if ($VisioBrowseRes -eq "Cancel")
			{
				return
			}
		}
	}
	$global:VisioFolder = $VisioBrowse.SelectedPath
}
#endregion ~~< Find_SRMDrawVisioFolder Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Folder Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Export Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSitevCenter_Export Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSitevCenter_Export
{
	$ProtectedSitevCenterServerExportFile = "$SRMCaptureCsvFolder\$ProtectedSiteSRM-ProtectedSitevCenterServerExport.csv"
	$global:DefaultVIServers | where {$_.Name -eq $ProtectedSiteVC} |
	Select-Object @{ N = "Name" ; E = { $_.Name } }, 
	@{ N = "Version" ; E = { $_.Version } }, 
	@{ N = "Build" ; E = { $_.Build } },
	@{ N = "OsType" ; E = { $_.ExtensionData.Content.About.OsType } } | Export-Csv $ProtectedSitevCenterServerExportFile -Append -NoTypeInformation
}
#endregion ~~< ProtectedSitevCenter_Export Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteSRM_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSiteSRM_Export
{
	$ProtectedSiteSRMServerExportFile = "$SRMCaptureCsvFolder\$ProtectedSiteSRM-ProtectedSiteSRMServerExport.csv"
	$SiteAContent.About | 
	Select-Object @{ N = "Name" ; E = { $ProtectedSiteSRM } },
	@{ N = "vCenter" ; E = { $ProtectedSiteVC } },
	@{ N = "Product" ; E = { $_.Name } },
	@{ N = "Vendor" ; E = { $_.Vendor  } },
	@{ N = "Version" ; E = { $_.Version  } },
	@{ N = "Build" ; E = { $_.Build  } },
	@{ N = "OsType" ; E = { $_.OsType  } } | Export-CSV $ProtectedSiteSRMServerExportFile -Append -NoTypeInformation
}
#endregion ~~< ProtectedSiteSRM_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteRecoveryPlan_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSiteRecoveryPlan_Export
{
	$ProtectedSiteRecoveryPlanExportFile = "$SRMCaptureCsvFolder\$ProtectedSiteSRM-ProtectedSiteRecoveryPlanExport.csv"
	$SiteARecovery.ListPlans() | foreach-object {
		$ProtectedSiteRecoveryListPlan = $_
		$ProtectedSiteRecoveryListPlanInfo = $ProtectedSiteRecoveryListPlan.GetInfo() | where {$_.State -ne "Ready"}
		$ProtectedSiteRecoveryListPlanInfo | foreach-object {
			$ProtectedSiteProtectionGroups = $ProtectedSiteRecoveryListPlanInfo.ProtectionGroups.GetInfo().Name | sort
			$ProtectedSiteRecoveryListPlanOutput = "" | select Name, 
			State, 
			Description, 
			ProtectionGroups
			$ProtectedSiteRecoveryListPlanOutput.Name = $ProtectedSiteRecoveryListPlanInfo.Name
			$ProtectedSiteRecoveryListPlanOutput.State = $ProtectedSiteRecoveryListPlanInfo.State
			$ProtectedSiteRecoveryListPlanOutput.Description = $ProtectedSiteRecoveryListPlanInfo.Description
			$ProtectedSiteRecoveryListPlanOutput.ProtectionGroups = [string]::Join(", ", ($ProtectedSiteProtectionGroups))
			$ProtectedSiteRecoveryListPlanOutput
		} | sort | Export-Csv $ProtectedSiteRecoveryPlanExportFile  -Append -NoTypeInformation
	}
}
#endregion ~~< ProtectedSiteRecoveryPlan_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteProtectionGroup_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSiteProtectionGroup_Export
{
		$ProtectedSiteProtectionGroupExportFile = "$SRMCaptureCsvFolder\$ProtectedSiteSRM-ProtectedSiteProtectionGroupExport.csv"
	$SiteARecovery.ListPlans() | foreach-object {
		$ProtectedSiteRecoveryListPlan = $_
		$ProtectedSiteRecoveryListPlanInfo = $ProtectedSiteRecoveryListPlan.GetInfo() | where {$_.State -ne "Ready"}
		$ProtectedSiteRecoveryListPlanInfo | foreach-object {
			$ProtectedSiteProtectionGroupsInfo = $ProtectedSiteRecoveryListPlanInfo.ProtectionGroups
			$ProtectedSiteProtectionGroupsInfo | foreach-object {
				$ProtectedSiteProtectionGroup = $_
				$ProtectedSiteVms = $ProtectedSiteProtectionGroup.ListProtectedVms()
				$ProtectedSiteVms | foreach-object { $_.Vm.UpdateViewData() }
				$ProtectedSiteDatastoresInfo = $ProtectedSiteProtectionGroup.ListProtectedDatastores().MoRef
				$ProtectedSiteDatastores = @()
				foreach ($ProtectedSiteDatastore in $ProtectedSiteDatastoresInfo)
				{
					$ProtectedSiteDatastores += Get-Datastore -Id $ProtectedSiteDatastore
				}
				
				$ProtectedSiteProtectionGroupOutput = "" | select Name, 
				vCenter, 
				SrmServer, 
				RecoveryPlan,
				ReplicationType,
				State,
				PeerState,
				Datastores,
				Vms
				$ProtectedSiteProtectionGroupOutput.Name = $ProtectedSiteProtectionGroup.GetInfo().Name
				$ProtectedSiteProtectionGroupOutput.vCenter = $ProtectedSiteVC
				$ProtectedSiteProtectionGroupOutput.SrmServer = $ProtectedSiteSRM
				$ProtectedSiteProtectionGroupOutput.RecoveryPlan = $ProtectedSiteRecoveryListPlanInfo.Name
				$ProtectedSiteProtectionGroupOutput.ReplicationType = $ProtectedSiteProtectionGroup.GetInfo().Type
				$ProtectedSiteProtectionGroupOutput.State = $ProtectedSiteProtectionGroup.GetProtectionState()
				$ProtectedSiteProtectionGroupOutput.PeerState = $ProtectedSiteProtectionGroup.GetPeer().State
				$ProtectedSiteProtectionGroupOutput.Datastores = [string]::Join(", ", (($ProtectedSiteDatastores.Name | sort )))
				$ProtectedSiteProtectionGroupOutput.Vms = [string]::Join(", ", (($ProtectedSiteVms.Vm.Name | sort )))
				$ProtectedSiteProtectionGroupOutput
			}
		} | sort Name | Export-Csv $ProtectedSiteProtectionGroupExportFile  -Append -NoTypeInformation
	}
}
#endregion ~~< ProtectedSiteProtectionGroup_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteVM_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSiteVM_Export
{
	$ProtectedSiteVMExportFile = "$SRMCaptureCsvFolder\$ProtectedSiteSRM-ProtectedSiteVMExport.csv"
	$SiteARecovery.ListPlans() | foreach-object {
		$ProtectedSiteRecoveryListPlan = $_
		$ProtectedSiteRecoveryListPlanInfo = $ProtectedSiteRecoveryListPlan.GetInfo() | where {$_.State -ne "Ready"}
		$ProtectedSiteRecoveryListPlanInfo | foreach-object {
			$ProtectedSiteProtectionGroupsInfo = $ProtectedSiteRecoveryListPlanInfo.ProtectionGroups
			$ProtectedSiteProtectionGroupsInfo | foreach-object {
				$ProtectedSiteProtectionGroup = $_
				$ProtectedSiteProtectionGroupInfo = $ProtectedSiteProtectionGroup.GetInfo()
				$ProtectedSiteVms = $ProtectedSiteProtectionGroup.ListProtectedVms()
				$ProtectedSiteVms | foreach-object { $_.Vm.UpdateViewData() }
				$ProtectedSiteVms | foreach-object	{
					$ProtectedSiteVMOutput = "" | select Name,
					vCenter, 
					SrmServer, 
					RecoveryPlan, 
					ProtectionGroup, 
					MoRef, 
					ProtectedVm, 
					PeerProtectedVm, 
					State, 
					PeerState, 
					NeedsConfiguration,
					Datacenter,
					Cluster,
					VmHost,
					DatastoreCluster,
					Datastore,
					ResourcePool,
					Os,
					Version,
					VMToolsVersion,
					ToolsVersionStatus,
					ToolsStatus,
					ToolsRunningStatus,
					Folder,
					NumCPU,
					CoresPerSocket,
					MemoryGB,
					IP,
					MacAddress,
					ProvisionedSpaceGB,
					NumEthernetCards,
					NumVirtualDisks,
					CpuReservation,
					MemoryReservation,
					ReplicationType
					
					$VmName = $_.Vm.Name
					$VM = Get-View -ViewType VirtualMachine -Filter @{ 'Name' = "$VmName" } -Property Name, Config, Config.Tools, Guest, Config.Hardware, Guest.Net, Summary.Config, Config.DatastoreUrl, Parent, Runtime.Host -Server $ProtectedSiteVC
					$Folder = Get-View -Id $VM.Parent -Property Name
					$ProtectedSiteVMOutput.Name = $_.Vm.Name
					$ProtectedSiteVMOutput.vCenter = $ProtectedSiteVC
					$ProtectedSiteVMOutput.SrmServer = $ProtectedSiteSRM
					$ProtectedSiteVMOutput.RecoveryPlan = $ProtectedSiteRecoveryListPlanInfo.Name
					$ProtectedSiteVMOutput.ProtectionGroup = $ProtectedSiteProtectionGroupInfo.Name
					$ProtectedSiteVMOutput.MoRef = $_.Vm.MoRef
					$ProtectedSiteVMOutput.ProtectedVm = $_.ProtectedVm
					$ProtectedSiteVMOutput.PeerProtectedVm = $_.PeerProtectedVm
					$ProtectedSiteVMOutput.State = $_.State
					$ProtectedSiteVMOutput.PeerState = $_.PeerState
					$ProtectedSiteVMOutput.NeedsConfiguration = $_.NeedsConfiguration
					$ProtectedSiteVMOutput.Datacenter = Get-Datacenter -VM $_.Vm.Name -Server $ProtectedSiteVC
					$ProtectedSiteVMOutput.Cluster = Get-Cluster -VM $_.Vm.Name -Server $ProtectedSiteVC
					$ProtectedSiteVMOutput.VmHost = Get-VmHost -VM $_.Vm.Name -Server $ProtectedSiteVC
					$ProtectedSiteVMOutput.DatastoreCluster = Get-DatastoreCluster -VM $_.Vm.Name -Server $ProtectedSiteVC
					$ProtectedSiteVMOutput.Datastore = [string]::Join(", ", ($VM.Config.DatastoreUrl.Name))
					$ProtectedSiteVMOutput.ResourcePool = Get-Vm $_.Vm.Name -Server $ProtectedSiteVC | Get-ResourcePool | where {$_ -NotLike "Resources"}
					$ProtectedSiteVMOutput.Os = $VM.Guest.GuestFullName
					$ProtectedSiteVMOutput.Version = $VM.Config.Version
					$ProtectedSiteVMOutput.VMToolsVersion = $VM.Guest.ToolsVersion
					$ProtectedSiteVMOutput.ToolsVersionStatus = $VM.Guest.ToolsVersionStatus
					$ProtectedSiteVMOutput.ToolsStatus = $VM.Guest.ToolsStatus
					$ProtectedSiteVMOutput.ToolsRunningStatus = (Get-VM $_.Vm.Name -Server $ProtectedSiteVC).ExtensionData.Guest.ToolsRunningStatus
					$ProtectedSiteVMOutput.Folder = $Folder.Name | select -Last 1
					$ProtectedSiteVMOutput.NumCPU = $VM.Config.Hardware.NumCPU
					$ProtectedSiteVMOutput.CoresPerSocket = $VM.Config.Hardware.NumCoresPerSocket
					$ProtectedSiteVMOutput.MemoryGB = [math]::Round([decimal]($VM.Config.Hardware.MemoryMB/1024),0)
					$ProtectedSiteVMOutput.IP = [string]::Join(", ", ($VM.Guest.Net.IpAddress))
					$ProtectedSiteVMOutput.MacAddress = [string]::Join(", ", ($VM.Guest.Net.MacAddress))
					$ProtectedSiteVMOutput.ProvisionedSpaceGB = [math]::Round([decimal]($VM.ProvisionedSpaceGB - $_.MemoryGB),0)
					$ProtectedSiteVMOutput.NumEthernetCards = $VM.Summary.Config.NumEthernetCards
					$ProtectedSiteVMOutput.NumVirtualDisks = $VM.Summary.Config.NumVirtualDisks
					$ProtectedSiteVMOutput.CpuReservation = $VM.Summary.Config.CpuReservation
					$ProtectedSiteVMOutput.MemoryReservation = $VM.Summary.Config.MemoryReservation
					$ProtectedSiteVMOutput.ReplicationType = $ProtectedSiteProtectionGroupInfo.Type
					$ProtectedSiteVMOutput
				}
			}
		} | sort ProtectionGroup, Name | Export-Csv $ProtectedSiteVMExportFile -Append -NoTypeInformation
	}
}
#endregion ~~< ProtectedSiteVM_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSiteDatastore_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSiteDatastore_Export
{
	$ProtectedSiteDatastoreExportFile = "$SRMCaptureCsvFolder\$ProtectedSiteSRM-ProtectedSiteDatastoreExport.csv"
	$SiteARecovery.ListPlans() | foreach-object {
		$ProtectedSiteRecoveryListPlan = $_
		$ProtectedSiteRecoveryListPlanInfo = $ProtectedSiteRecoveryListPlan.GetInfo() | where {$_.State -ne "Ready"}
		$ProtectedSiteRecoveryListPlanInfo | foreach-object {
			$ProtectedSiteProtectionGroupsInfo = $ProtectedSiteRecoveryListPlanInfo.ProtectionGroups
			$ProtectedSiteProtectionGroupsInfo | foreach-object {
				$ProtectedSiteProtectionGroup = $_
				$ProtectedSiteProtectionGroupInfo = $ProtectedSiteProtectionGroup.GetInfo()
				$ProtectedSiteDatastores = $ProtectedSiteProtectionGroup.ListProtectedDatastores()					
				$ProtectedSiteDatastores | foreach-object {
				$ProtectedSiteDatastoreMoRef = $_.MoRef
				$ProtectedSiteDatastore = Get-Datastore -id "$ProtectedSiteDatastoreMoRef"
				
				$ProtectedSiteDatastoreOutput = "" | select Name, 
				vCenter, 
				SrmServer, 
				RecoveryPlan, 
				ProtectionGroup, 
				CapacityGB, 
				FreeSpaceGB, 
				Type,
				FileSystemVersion,
				DiskName,
				StorageIOControlEnabled,
				Vms, 
				State
				
				if ($ProtectedSiteDatastore.Name -eq $null)
				{
					$ProtectedSiteDatastoreOutput.Name = "vSphere Replication"
				}
				else
				{
					$ProtectedSiteDatastoreOutput.Name = $ProtectedSiteDatastore.Name
				}
				$ProtectedSiteDatastoreOutput.vCenter = $ProtectedSiteVC
				$ProtectedSiteDatastoreOutput.SrmServer = $ProtectedSiteSRM
				$ProtectedSiteDatastoreOutput.RecoveryPlan = $ProtectedSiteRecoveryListPlanInfo.Name
				$ProtectedSiteDatastoreOutput.ProtectionGroup = $ProtectedSiteProtectionGroupInfo.Name
				$ProtectedSiteDatastoreOutput.CapacityGB = $ProtectedSiteDatastore.CapacityGB
				$ProtectedSiteDatastoreOutput.FreeSpaceGB = $ProtectedSiteDatastore.FreeSpaceGB
				$ProtectedSiteDatastoreOutput.Type = $ProtectedSiteDatastore.Type
				$ProtectedSiteDatastoreOutput.FileSystemVersion = $ProtectedSiteDatastore.FileSystemVersion
				$ProtectedSiteDatastoreOutput.DiskName = $ProtectedSiteDatastore.ExtensionData.Info.VMFS.Extent.DiskName
				$ProtectedSiteDatastoreOutput.StorageIOControlEnabled = $ProtectedSiteDatastore.StorageIOControlEnabled
				$ProtectedSiteDatastoreOutput.Vms = [string]::Join(", ", ( $ProtectedSiteDatastore | Get-VM | sort Name ))
				$ProtectedSiteDatastoreOutput.State = $ProtectedSiteProtectionGroup.GetProtectionState()
				$ProtectedSiteDatastoreOutput
				}
			}
		} | sort ProtectionGroup, Name | Export-Csv $ProtectedSiteDatastoreExportFile -Append -NoTypeInformation
	}
}
#endregion ~~< ProtectedSiteDatastore_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySitevCenter_Export Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySitevCenter_Export
{
	$RecoverySitevCenterServerExportFile = "$SRMCaptureCsvFolder\$RecoverySiteSRM-RecoverySitevCenterServerExport.csv"
	$global:DefaultVIServers | where {$_.Name -eq $RecoverySiteVC} |
	Select-Object @{ N = "Name" ; E = { $_.Name } }, 
	@{ N = "Version" ; E = { $_.Version } }, 
	@{ N = "Build" ; E = { $_.Build } },
	@{ N = "OsType" ; E = { $_.ExtensionData.Content.About.OsType } } | Export-Csv $RecoverySitevCenterServerExportFile -Append -NoTypeInformation
}
#endregion ~~< RecoverySitevCenter_Export Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteSRM_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySiteSRM_Export
{
	$RecoverySiteSRMServerExportFile = "$SRMCaptureCsvFolder\$RecoverySiteSRM-RecoverySiteSRMServerExport.csv"
	$SiteBContent.About | 
	Select-Object @{ N = "Name" ; E = { $RecoverySiteSRM } },
	@{ N = "vCenter" ; E = { $RecoverySiteVC } },
	@{ N = "Product" ; E = { $_.Name } },
	@{ N = "Vendor" ; E = { $_.Vendor } },
	@{ N = "Version" ; E = { $_.Version } },
	@{ N = "Build" ; E = { $_.Build } },
	@{ N = "OsType" ; E = { $_.OsType } } | Export-CSV $RecoverySiteSRMServerExportFile -Append -NoTypeInformation
}
#endregion ~~< RecoverySiteSRM_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteRecoveryPlan_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySiteRecoveryPlan_Export
{
	$RecoverySiteRecoveryPlanExportFile = "$SRMCaptureCsvFolder\$RecoverySiteSRM-RecoverySiteRecoveryPlanExport.csv"
	$SiteBRecovery.ListPlans() | foreach-object {
		$RecoverySiteRecoveryListPlan = $_
		$RecoverySiteRecoveryListPlanInfo = $RecoverySiteRecoveryListPlan.GetInfo() | where {$_.State -ne "Ready"}
		$RecoverySiteRecoveryListPlanInfo | foreach-object {
			$RecoverySiteProtectionGroups = $RecoverySiteRecoveryListPlanInfo.ProtectionGroups.GetInfo().Name | sort
			$RecoverySiteRecoveryListPlanOutput = "" | select Name, 
			State, 
			Description, 
			ProtectionGroups
			$RecoverySiteRecoveryListPlanOutput.Name = $RecoverySiteRecoveryListPlanInfo.Name
			$RecoverySiteRecoveryListPlanOutput.State = $RecoverySiteRecoveryListPlanInfo.State
			$RecoverySiteRecoveryListPlanOutput.Description = $RecoverySiteRecoveryListPlanInfo.Description
			$RecoverySiteRecoveryListPlanOutput.ProtectionGroups = [string]::Join(", ", ($RecoverySiteProtectionGroups))
			$RecoverySiteRecoveryListPlanOutput
		} | sort | Export-Csv $RecoverySiteRecoveryPlanExportFile  -Append -NoTypeInformation
	}
}
#endregion ~~< RecoverySiteRecoveryPlan_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteProtectionGroup_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySiteProtectionGroup_Export
{
	$RecoverySiteProtectionGroupExportFile = "$SRMCaptureCsvFolder\$RecoverySiteSRM-RecoverySiteProtectionGroupExport.csv"
	$SiteBRecovery.ListPlans() | foreach-object {
		$RecoverySiteRecoveryListPlan = $_
		$RecoverySiteRecoveryListPlanInfo = $RecoverySiteRecoveryListPlan.GetInfo() | where {$_.State -ne "Ready"}
		$RecoverySiteRecoveryListPlanInfo | foreach-object {
			$RecoverySiteProtectionGroupsInfo = $RecoverySiteRecoveryListPlanInfo.ProtectionGroups
			$RecoverySiteProtectionGroupsInfo | foreach-object {
				$RecoverySiteProtectionGroup = $_
				$RecoverySiteVms = $RecoverySiteProtectionGroup.ListProtectedVms()
				$RecoverySiteVms | foreach-object { $_.Vm.UpdateViewData() }
				$RecoverySiteDatastoresInfo = $RecoverySiteProtectionGroup.ListProtectedDatastores().MoRef
				$RecoverySiteDatastores = @()
				foreach ($RecoverySiteDatastore in $RecoverySiteDatastoresInfo)
				{
					$RecoverySiteDatastores += Get-Datastore -Id $RecoverySiteDatastore
				}
				
				$RecoverySiteProtectionGroupOutput = "" | select Name, 
				vCenter, 
				SrmServer, 
				RecoveryPlan,
				ReplicationType,
				State,
				PeerState,
				Datastores,
				Vms
				$RecoverySiteProtectionGroupOutput.Name = $RecoverySiteProtectionGroup.GetInfo().Name
				$RecoverySiteProtectionGroupOutput.vCenter = $RecoverySiteVC
				$RecoverySiteProtectionGroupOutput.SrmServer = $RecoverySiteSRM
				$RecoverySiteProtectionGroupOutput.RecoveryPlan = $RecoverySiteRecoveryListPlanInfo.Name
				$RecoverySiteProtectionGroupOutput.ReplicationType = $RecoverySiteProtectionGroup.GetInfo().Type
				$RecoverySiteProtectionGroupOutput.State = $RecoverySiteProtectionGroup.GetProtectionState()
				$RecoverySiteProtectionGroupOutput.PeerState = $RecoverySiteProtectionGroup.GetPeer().State
				$RecoverySiteProtectionGroupOutput.Datastores = [string]::Join(", ", (($RecoverySiteDatastores.Name | sort )))
				$RecoverySiteProtectionGroupOutput.Vms = [string]::Join(", ", (($RecoverySiteVms.Vm.Name | sort )))
				$RecoverySiteProtectionGroupOutput
			}
		} | sort Name | Export-Csv $RecoverySiteProtectionGroupExportFile  -Append -NoTypeInformation
	}
}
#endregion ~~< RecoverySiteProtectionGroup_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteVM_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySiteVM_Export
{
	$RecoverySiteVMExportFile = "$SRMCaptureCsvFolder\$RecoverySiteSRM-RecoverySiteVMExport.csv"
	$SiteBRecovery.ListPlans() | foreach-object {
		$RecoverySiteRecoveryListPlan = $_
		$RecoverySiteRecoveryListPlanInfo = $RecoverySiteRecoveryListPlan.GetInfo() | where {$_.State -ne "Ready"}
		$RecoverySiteRecoveryListPlanInfo | foreach-object {
			$RecoverySiteProtectionGroupsInfo = $RecoverySiteRecoveryListPlanInfo.ProtectionGroups
			$RecoverySiteProtectionGroupsInfo | foreach-object {
				$RecoverySiteProtectionGroup = $_
				$RecoverySiteProtectionGroupInfo = $RecoverySiteProtectionGroup.GetInfo()
				$RecoverySiteVms = $RecoverySiteProtectionGroup.ListProtectedVms()
				$RecoverySiteVms | foreach-object { $_.Vm.UpdateViewData() }
				$RecoverySiteVms | foreach-object	{
					$RecoverySiteVMOutput = "" | select Name,
					vCenter, 
					SrmServer, 
					RecoveryPlan, 
					ProtectionGroup, 
					MoRef, 
					ProtectedVm, 
					PeerProtectedVm, 
					State, 
					PeerState, 
					NeedsConfiguration,
					Datacenter,
					Cluster,
					VmHost,
					DatastoreCluster,
					Datastore,
					ResourcePool,
					Os,
					Version,
					VMToolsVersion,
					ToolsVersionStatus,
					ToolsStatus,
					ToolsRunningStatus,
					Folder,
					NumCPU,
					CoresPerSocket,
					MemoryGB,
					IP,
					MacAddress,
					ProvisionedSpaceGB,
					NumEthernetCards,
					NumVirtualDisks,
					CpuReservation,
					MemoryReservation,
					ReplicationType
					
					$VmName = $_.Vm.Name
					$VM = Get-View -ViewType VirtualMachine -Filter @{ 'Name' = "$VmName" } -Property Name, Config, Config.Tools, Guest, Config.Hardware, Guest.Net, Summary.Config, Config.DatastoreUrl, Parent, Runtime.Host -Server $RecoverySiteVC
					$Folder = Get-View -Id $VM.Parent -Property Name
					$RecoverySiteVMOutput.Name = $_.Vm.Name
					$RecoverySiteVMOutput.vCenter = $RecoverySiteVC
					$RecoverySiteVMOutput.SrmServer = $RecoverySiteSRM
					$RecoverySiteVMOutput.RecoveryPlan = $RecoverySiteRecoveryListPlanInfo.Name
					$RecoverySiteVMOutput.ProtectionGroup = $RecoverySiteProtectionGroupInfo.Name
					$RecoverySiteVMOutput.MoRef = $_.Vm.MoRef
					$RecoverySiteVMOutput.ProtectedVm = $_.ProtectedVm
					$RecoverySiteVMOutput.PeerProtectedVm = $_.PeerProtectedVm
					$RecoverySiteVMOutput.State = $_.State
					$RecoverySiteVMOutput.PeerState = $_.PeerState
					$RecoverySiteVMOutput.NeedsConfiguration = $_.NeedsConfiguration
					$RecoverySiteVMOutput.Datacenter = Get-Datacenter -VM $_.Vm.Name -Server $RecoverySiteVC
					$RecoverySiteVMOutput.Cluster = Get-Cluster -VM $_.Vm.Name -Server $RecoverySiteVC
					$RecoverySiteVMOutput.VmHost = Get-VmHost -VM $_.Vm.Name -Server $RecoverySiteVC
					$RecoverySiteVMOutput.DatastoreCluster = Get-DatastoreCluster -VM $_.Vm.Name -Server $RecoverySiteVC
					$RecoverySiteVMOutput.Datastore = [string]::Join(", ", ($VM.Config.DatastoreUrl.Name))
					$RecoverySiteVMOutput.ResourcePool = Get-Vm $_.Vm.Name -Server $RecoverySiteVC | Get-ResourcePool | where {$_ -NotLike "Resources"}
					$RecoverySiteVMOutput.Os = $VM.Guest.GuestFullName
					$RecoverySiteVMOutput.Version = $VM.Config.Version
					$RecoverySiteVMOutput.VMToolsVersion = $VM.Guest.ToolsVersion
					$RecoverySiteVMOutput.ToolsVersionStatus = $VM.Guest.ToolsVersionStatus
					$RecoverySiteVMOutput.ToolsStatus = $VM.Guest.ToolsStatus
					$RecoverySiteVMOutput.ToolsRunningStatus = (Get-VM $_.Vm.Name -Server $RecoverySiteVC).ExtensionData.Guest.ToolsRunningStatus
					$RecoverySiteVMOutput.Folder = $Folder.Name | select -Last 1
					$RecoverySiteVMOutput.NumCPU = $VM.Config.Hardware.NumCPU
					$RecoverySiteVMOutput.CoresPerSocket = $VM.Config.Hardware.NumCoresPerSocket
					$RecoverySiteVMOutput.MemoryGB = [math]::Round([decimal]($VM.Config.Hardware.MemoryMB/1024),0)
					$RecoverySiteVMOutput.IP = [string]::Join(", ", ($VM.Guest.Net.IpAddress))
					$RecoverySiteVMOutput.MacAddress = [string]::Join(", ", ($VM.Guest.Net.MacAddress))
					$RecoverySiteVMOutput.ProvisionedSpaceGB = [math]::Round([decimal]($VM.ProvisionedSpaceGB - $_.MemoryGB),0)
					$RecoverySiteVMOutput.NumEthernetCards = $VM.Summary.Config.NumEthernetCards
					$RecoverySiteVMOutput.NumVirtualDisks = $VM.Summary.Config.NumVirtualDisks
					$RecoverySiteVMOutput.CpuReservation = $VM.Summary.Config.CpuReservation
					$RecoverySiteVMOutput.MemoryReservation = $VM.Summary.Config.MemoryReservation
					$RecoverySiteVMOutput.ReplicationType = $RecoverySiteProtectionGroupInfo.Type
					$RecoverySiteVMOutput
				}
			}
		} | sort ProtectionGroup, Name | Export-Csv $RecoverySiteVMExportFile -Append -NoTypeInformation
	}
}
#endregion ~~< RecoverySiteVM_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySiteDatastore_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySiteDatastore_Export
{
	$RecoverySiteDatastoreExportFile = "$SRMCaptureCsvFolder\$RecoverySiteSRM-RecoverySiteDatastoreExport.csv"
	$SiteBRecovery.ListPlans() | foreach-object {
		$RecoverySiteRecoveryListPlan = $_
		$RecoverySiteRecoveryListPlanInfo = $RecoverySiteRecoveryListPlan.GetInfo() | where {$_.State -ne "Ready"}
		$RecoverySiteRecoveryListPlanInfo | foreach-object {
			$RecoverySiteProtectionGroupsInfo = $RecoverySiteRecoveryListPlanInfo.ProtectionGroups
			$RecoverySiteProtectionGroupsInfo | foreach-object {
				$RecoverySiteProtectionGroup = $_
				$RecoverySiteProtectionGroupInfo = $RecoverySiteProtectionGroup.GetInfo()
				$RecoverySiteDatastores = $RecoverySiteProtectionGroup.ListProtectedDatastores()					
				$RecoverySiteDatastores | foreach-object {
				$RecoverySiteDatastoreMoRef = $_.MoRef
				$RecoverySiteDatastore = Get-Datastore -id "$RecoverySiteDatastoreMoRef"
				
				$RecoverySiteDatastoreOutput = "" | select Name, 
				vCenter, 
				SrmServer, 
				RecoveryPlan, 
				ProtectionGroup, 
				CapacityGB, 
				FreeSpaceGB, 
				Type,
				FileSystemVersion,
				DiskName,
				StorageIOControlEnabled,
				Vms, 
				State
				
				if ($RecoverySiteDatastore.Name -eq $null)
				{
					$RecoverySiteDatastoreOutput.Name = "vSphere Replication"
				}
				else
				{
					$RecoverySiteDatastoreOutput.Name = $RecoverySiteDatastore.Name
				}
				$RecoverySiteDatastoreOutput.vCenter = $RecoverySiteVC
				$RecoverySiteDatastoreOutput.SrmServer = $RecoverySiteSRM
				$RecoverySiteDatastoreOutput.RecoveryPlan = $RecoverySiteRecoveryListPlanInfo.Name
				$RecoverySiteDatastoreOutput.ProtectionGroup = $RecoverySiteProtectionGroupInfo.Name
				$RecoverySiteDatastoreOutput.CapacityGB = $RecoverySiteDatastore.CapacityGB
				$RecoverySiteDatastoreOutput.FreeSpaceGB = $RecoverySiteDatastore.FreeSpaceGB
				$RecoverySiteDatastoreOutput.Type = $RecoverySiteDatastore.Type
				$RecoverySiteDatastoreOutput.FileSystemVersion = $RecoverySiteDatastore.FileSystemVersion
				$RecoverySiteDatastoreOutput.DiskName = $RecoverySiteDatastore.ExtensionData.Info.VMFS.Extent.DiskName
				$RecoverySiteDatastoreOutput.StorageIOControlEnabled = $RecoverySiteDatastore.StorageIOControlEnabled
				$RecoverySiteDatastoreOutput.Vms = [string]::Join(", ", ( $RecoverySiteDatastore | Get-VM | sort Name ))
				$RecoverySiteDatastoreOutput.State = $RecoverySiteProtectionGroup.GetProtectionState()
				$RecoverySiteDatastoreOutput
				}
			}
		} | sort ProtectionGroup, Name | Export-Csv $RecoverySiteDatastoreExportFile -Append -NoTypeInformation
	}
}
#endregion ~~< RecoverySiteDatastore_Export >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Export Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Visio Object Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Connect-VisioObjectFunction >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Connect-VisioObject($firstObj, $secondObj)
{
	$shpConn = $pagObj.Drop($pagObj.Application.ConnectorToolDataObject, 0, 0)
	$ConnectBegin = $shpConn.CellsU("BeginX").GlueTo($firstObj.CellsU("PinX"))
	$ConnectEnd = $shpConn.CellsU("EndX").GlueTo($secondObj.CellsU("PinX"))
}
#endregion ~~< Connect-VisioObjectFunction >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Add-VisioObjectVC Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Add-VisioObjectVC($mastObj, $item)
{
	$shpObj = $pagObj.Drop($mastObj, $x, $y)
	$shpObj.Text = $item.name
	return $shpObj
}
#endregion ~~< Add-VisioObjectVC Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Add-VisioObjectSRM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Add-VisioObjectSRM($mastObj, $item)
{
	$shpObj = $pagObj.Drop($mastObj, $x, $y)
	$shpObj.Text = $item.name
	return $shpObj
}
#endregion ~~< Add-VisioObjectSRM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Add-VisioObjectRecoveryPlan Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Add-VisioObjectRecoveryPlan($mastObj, $item)
{
	$shpObj = $pagObj.Drop($mastObj, $x, $y)
	$shpObj.Text = $item.name
	return $shpObj
}
#endregion ~~< Add-VisioObjectRecoveryPlan Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Add-VisioObjectProtectionGroup Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Add-VisioObjectProtectionGroup($mastObj, $item)
{
	$shpObj = $pagObj.Drop($mastObj, $x, $y)
	$shpObj.Text = $item.name
	return $shpObj
}
#endregion ~~< Add-VisioObjectProtectionGroup Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Add-VisioObjectVM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Add-VisioObjectVM($mastObj, $item)
{
	$shpObj = $pagObj.Drop($mastObj, $x, $y)
	$shpObj.Text = $item.name
	return $shpObj
}
#endregion ~~< Add-VisioObjectVM Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Add-VisioObjectDatastore Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Add-VisioObjectDatastore($mastObj, $item)
{
	$shpObj = $pagObj.Drop($mastObj, $x, $y)
	$shpObj.Text = $item.name
	return $shpObj
}
#endregion ~~< Add-VisioObjectDatastore Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Visio Object Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Visio Draw Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_ProtectedSitevCenter Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_ProtectedSitevCenter
{
	# Name
	$ProtectedSiteVCObject.Cells("Prop.Name").Formula = '"' + $ProtectedSitevCenterImport.Name + '"'
	# Version
	$ProtectedSiteVCObject.Cells("Prop.Version").Formula = '"' + $ProtectedSitevCenterImport.Version + '"'
	# Build
	$ProtectedSiteVCObject.Cells("Prop.Build").Formula = '"' + $ProtectedSitevCenterImport.Build + '"'
	# OsType
	$ProtectedSiteVCObject.Cells("Prop.OsType").Formula = '"' + $ProtectedSitevCenterImport.OsType + '"'
}
#endregion ~~< Draw_ProtectedSitevCenter Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_ProtectedSiteSRM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_ProtectedSiteSRM
{
	# Name
	$ProtectedSiteSRMObject.Cells("Prop.Name").Formula = '"' + $ProtectedSiteSrmServer.Name + '"'
	# Product
	$ProtectedSiteSRMObject.Cells("Prop.Product").Formula = '"' + $ProtectedSiteSrmServer.Product + '"'
	# Vendor
	$ProtectedSiteSRMObject.Cells("Prop.Vendor").Formula = '"' + $ProtectedSiteSrmServer.Vendor + '"'
	# Version
	$ProtectedSiteSRMObject.Cells("Prop.Version").Formula = '"' + $ProtectedSiteSrmServer.Version + '"'
	# Build
	$ProtectedSiteSRMObject.Cells("Prop.Build").Formula = '"' + $ProtectedSiteSrmServer.Build + '"'
	# OsType
	$ProtectedSiteSRMObject.Cells("Prop.OsType").Formula = '"' + $ProtectedSiteSrmServer.OsType + '"'
}
#endregion ~~< Draw_ProtectedSiteSRM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_ProtectedSiteRecoveryPlan Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_ProtectedSiteRecoveryPlan
{
	# Name
	$ProtectedSiteRecoveryPlanObject.Cells("Prop.Name").Formula = '"' + $ProtectedSiteRecoveryPlan.Name + '"'
	# State
	$ProtectedSiteRecoveryPlanObject.Cells("Prop.State").Formula = '"' + $ProtectedSiteRecoveryPlan.State + '"'
	# Description
	$ProtectedSiteRecoveryPlanObject.Cells("Prop.Description").Formula = '"' + $ProtectedSiteRecoveryPlan.Description + '"'
	# ProtectionGroups
	$ProtectedSiteRecoveryPlanObject.Cells("Prop.ProtectionGroups").Formula = '"' + $ProtectedSiteRecoveryPlan.ProtectionGroups + '"'
}
#endregion ~~< Draw_ProtectedSiteRecoveryPlan Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_ProtectedSiteProtectionGroup Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_ProtectedSiteProtectionGroup
{
	# Name
	$ProtectedSiteProtectionGroupObject.Cells("Prop.Name").Formula = '"' + $ProtectedSiteProtectionGroup.Name + '"'
	# ReplicationType
	$ProtectedSiteProtectionGroupObject.Cells("Prop.ReplicationType").Formula = '"' + $ProtectedSiteProtectionGroup.ReplicationType + '"'
	# State
	$ProtectedSiteProtectionGroupObject.Cells("Prop.State").Formula = '"' + $ProtectedSiteProtectionGroup.State + '"'
	# PeerState
	$ProtectedSiteProtectionGroupObject.Cells("Prop.PeerState").Formula = '"' + $ProtectedSiteProtectionGroup.PeerState + '"'
	# Datastores
	$ProtectedSiteProtectionGroupObject.Cells("Prop.Datastores").Formula = '"' + $ProtectedSiteProtectionGroup.Datastores + '"'
}
#endregion ~~< Draw_ProtectedSiteProtectionGroup Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_ProtectedSiteVM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_ProtectedSiteVM
{
	# Name
	$ProtectedSiteVMObject.Cells("Prop.Name").Formula = '"' + $ProtectedSiteVM.Name + '"'
	# OS
	$ProtectedSiteVMObject.Cells("Prop.OS").Formula = '"' + $ProtectedSiteVM.OS + '"'
	# Version
	$ProtectedSiteVMObject.Cells("Prop.Version").Formula = '"' + $ProtectedSiteVM.Version + '"'
	# VMToolsVersion
	$ProtectedSiteVMObject.Cells("Prop.VMToolsVersion").Formula = '"' + $ProtectedSiteVM.VMToolsVersion + '"'
	# ToolsVersionStatus
	$ProtectedSiteVMObject.Cells("Prop.ToolsVersionStatus").Formula = '"' + $ProtectedSiteVM.ToolsVersionStatus + '"'
	# ToolsStatus
	$ProtectedSiteVMObject.Cells("Prop.ToolsStatus").Formula = '"' + $ProtectedSiteVM.ToolsStatus + '"'
	# ToolsRunningStatus
	$ProtectedSiteVMObject.Cells("Prop.ToolsRunningStatus").Formula = '"' + $ProtectedSiteVM.ToolsRunningStatus + '"'
	# Folder
	$ProtectedSiteVMObject.Cells("Prop.Folder").Formula = '"' + $ProtectedSiteVM.Folder + '"'
	# NumCPU
	$ProtectedSiteVMObject.Cells("Prop.NumCPU").Formula = '"' + $ProtectedSiteVM.NumCPU + '"'
	# CoresPerSocket
	$ProtectedSiteVMObject.Cells("Prop.CoresPerSocket").Formula = '"' + $ProtectedSiteVM.CoresPerSocket + '"'
	# MemoryGB
	$ProtectedSiteVMObject.Cells("Prop.MemoryGB").Formula = '"' + $ProtectedSiteVM.MemoryGB + '"'
	# IP
	$ProtectedSiteVMObject.Cells("Prop.IP").Formula = '"' + $ProtectedSiteVM.Ip + '"'
	# MacAddress
	$ProtectedSiteVMObject.Cells("Prop.MacAddress").Formula = '"' + $ProtectedSiteVM.MacAddress + '"'
	# ProvisionedSpaceGB
	$ProtectedSiteVMObject.Cells("Prop.ProvisionedSpaceGB").Formula = '"' + $ProtectedSiteVM.ProvisionedSpaceGB + '"'
	# NumEthernetCards
	$ProtectedSiteVMObject.Cells("Prop.NumEthernetCards").Formula = '"' + $ProtectedSiteVM.NumEthernetCards + '"'
	# NumVirtualDisks
	$ProtectedSiteVMObject.Cells("Prop.NumVirtualDisks").Formula = '"' + $ProtectedSiteVM.NumVirtualDisks + '"'
	# CpuReservation
	$ProtectedSiteVMObject.Cells("Prop.CpuReservation").Formula = '"' + $ProtectedSiteVM.CpuReservation + '"'
	# MemoryReservation
	$ProtectedSiteVMObject.Cells("Prop.MemoryReservation").Formula = '"' + $ProtectedSiteVM.MemoryReservation + '"'
	# ProtectionGroup
	$ProtectedSiteVMObject.Cells("Prop.ProtectionGroup").Formula = '"' + $ProtectedSiteVM.ProtectionGroup + '"'
	# ProtectedVm
	$ProtectedSiteVMObject.Cells("Prop.ProtectedVm").Formula = '"' + $ProtectedSiteVM.ProtectedVm + '"'
	# PeerProtectedVm
	$ProtectedSiteVMObject.Cells("Prop.PeerProtectedVm").Formula = '"' + $ProtectedSiteVM.PeerProtectedVm + '"'
	# State
	$ProtectedSiteVMObject.Cells("Prop.State").Formula = '"' + $ProtectedSiteVM.State + '"'
	# PeerState
	$ProtectedSiteVMObject.Cells("Prop.PeerState").Formula = '"' + $ProtectedSiteVM.PeerState + '"'
	# NeedsConfiguration
	$ProtectedSiteVMObject.Cells("Prop.NeedsConfiguration").Formula = '"' + $ProtectedSiteVM.NeedsConfiguration + '"'
}
#endregion ~~< Draw_ProtectedSiteVM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_ProtectedSiteDatastore Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_ProtectedSiteDatastore
{
	# Name
	$ProtectedSiteDatastoreObject.Cells("Prop.Name").Formula = '"' + $ProtectedSiteDatastore.Name + '"'
	# Type
	$ProtectedSiteDatastoreObject.Cells("Prop.Type").Formula = '"' + $ProtectedSiteDatastore.Type + '"'
	# FileSystemVersion
	$ProtectedSiteDatastoreObject.Cells("Prop.FileSystemVersion").Formula = '"' + $ProtectedSiteDatastore.FileSystemVersion + '"'
	# DiskName
	$ProtectedSiteDatastoreObject.Cells("Prop.DiskName").Formula = '"' + $ProtectedSiteDatastore.DiskName + '"'
	# StorageIOControlEnabled
	$ProtectedSiteDatastoreObject.Cells("Prop.StorageIOControlEnabled").Formula = '"' + $ProtectedSiteDatastore.StorageIOControlEnabled + '"'
	# CapacityGB
	$ProtectedSiteDatastoreObject.Cells("Prop.CapacityGB").Formula = '"' + $ProtectedSiteDatastore.CapacityGB + '"'
	# FreeSpaceGB
	$ProtectedSiteDatastoreObject.Cells("Prop.FreeSpaceGB").Formula = '"' + $ProtectedSiteDatastore.FreeSpaceGB + '"'
	# Vms
	$ProtectedSiteDatastoreObject.Cells("Prop.Vms").Formula = '"' + $ProtectedSiteDatastore.Vms + '"'
	# State
	$ProtectedSiteDatastoreObject.Cells("Prop.State").Formula = '"' + $ProtectedSiteDatastore.State + '"'
}
#endregion ~~< Draw_ProtectedSiteDatastore Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_RecoverySitevCenter Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_RecoverySitevCenter
{
	# Name
	$RecoverySiteVCObject.Cells("Prop.Name").Formula = '"' + $RecoverySitevCenterImport.Name + '"'
	# Version
	$RecoverySiteVCObject.Cells("Prop.Version").Formula = '"' + $RecoverySitevCenterImport.Version + '"'
	# Build
	$RecoverySiteVCObject.Cells("Prop.Build").Formula = '"' + $RecoverySitevCenterImport.Build + '"'
	# OsType
	$RecoverySiteVCObject.Cells("Prop.OsType").Formula = '"' + $RecoverySitevCenterImport.OsType + '"'
}
#endregion ~~< Draw_RecoverySitevCenter Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_RecoverySiteSRM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_RecoverySiteSRM
{
	# Name
	$RecoverySiteSRMObject.Cells("Prop.Name").Formula = '"' + $RecoverySiteSrmServer.Name + '"'
	# Product
	$RecoverySiteSRMObject.Cells("Prop.Product").Formula = '"' + $RecoverySiteSrmServer.Product + '"'
	# Vendor
	$RecoverySiteSRMObject.Cells("Prop.Vendor").Formula = '"' + $RecoverySiteSrmServer.Vendor + '"'
	# Version
	$RecoverySiteSRMObject.Cells("Prop.Version").Formula = '"' + $RecoverySiteSrmServer.Version + '"'
	# Build
	$RecoverySiteSRMObject.Cells("Prop.Build").Formula = '"' + $RecoverySiteSrmServer.Build + '"'
	# OsType
	$RecoverySiteSRMObject.Cells("Prop.OsType").Formula = '"' + $RecoverySiteSrmServer.OsType + '"'
}
#endregion ~~< Draw_RecoverySiteSRM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_RecoverySiteRecoveryPlan Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_RecoverySiteRecoveryPlan
{
	# Name
	$RecoverySiteRecoveryPlanObject.Cells("Prop.Name").Formula = '"' + $RecoverySiteRecoveryPlan.Name + '"'
	# State
	$RecoverySiteRecoveryPlanObject.Cells("Prop.State").Formula = '"' + $RecoverySiteRecoveryPlan.State + '"'
	# Description
	$RecoverySiteRecoveryPlanObject.Cells("Prop.Description").Formula = '"' + $RecoverySiteRecoveryPlan.Description + '"'
	# ProtectionGroups
	$RecoverySiteRecoveryPlanObject.Cells("Prop.ProtectionGroups").Formula = '"' + $RecoverySiteRecoveryPlan.ProtectionGroups + '"'
}
#endregion ~~< Draw_RecoverySiteRecoveryPlan Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_RecoverySiteProtectionGroup Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_RecoverySiteProtectionGroup
{
	# Name
	$RecoverySiteProtectionGroupObject.Cells("Prop.Name").Formula = '"' + $RecoverySiteProtectionGroup.Name + '"'
	# ReplicationType
	$RecoverySiteProtectionGroupObject.Cells("Prop.ReplicationType").Formula = '"' + $RecoverySiteProtectionGroup.ReplicationType + '"'
	# State
	$RecoverySiteProtectionGroupObject.Cells("Prop.State").Formula = '"' + $RecoverySiteProtectionGroup.State + '"'
	# PeerState
	$RecoverySiteProtectionGroupObject.Cells("Prop.PeerState").Formula = '"' + $RecoverySiteProtectionGroup.PeerState + '"'
	# Datastores
	$RecoverySiteProtectionGroupObject.Cells("Prop.Datastores").Formula = '"' + $RecoverySiteProtectionGroup.Datastores + '"'
}
#endregion ~~< Draw_RecoverySiteProtectionGroup Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_RecoverySiteVM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_RecoverySiteVM
{
	# Name
	$RecoverySiteVMObject.Cells("Prop.Name").Formula = '"' + $RecoverySiteVM.Name + '"'
	# OS
	$RecoverySiteVMObject.Cells("Prop.OS").Formula = '"' + $RecoverySiteVM.OS + '"'
	# Version
	$RecoverySiteVMObject.Cells("Prop.Version").Formula = '"' + $RecoverySiteVM.Version + '"'
	# VMToolsVersion
	$RecoverySiteVMObject.Cells("Prop.VMToolsVersion").Formula = '"' + $RecoverySiteVM.VMToolsVersion + '"'
	# ToolsVersionStatus
	$RecoverySiteVMObject.Cells("Prop.ToolsVersionStatus").Formula = '"' + $RecoverySiteVM.ToolsVersionStatus + '"'
	# ToolsStatus
	$RecoverySiteVMObject.Cells("Prop.ToolsStatus").Formula = '"' + $RecoverySiteVM.ToolsStatus + '"'
	# ToolsRunningStatus
	$RecoverySiteVMObject.Cells("Prop.ToolsRunningStatus").Formula = '"' + $RecoverySiteVM.ToolsRunningStatus + '"'
	# Folder
	$RecoverySiteVMObject.Cells("Prop.Folder").Formula = '"' + $RecoverySiteVM.Folder + '"'
	# NumCPU
	$RecoverySiteVMObject.Cells("Prop.NumCPU").Formula = '"' + $RecoverySiteVM.NumCPU + '"'
	# CoresPerSocket
	$RecoverySiteVMObject.Cells("Prop.CoresPerSocket").Formula = '"' + $RecoverySiteVM.CoresPerSocket + '"'
	# MemoryGB
	$RecoverySiteVMObject.Cells("Prop.MemoryGB").Formula = '"' + $RecoverySiteVM.MemoryGB + '"'
	# IP
	$RecoverySiteVMObject.Cells("Prop.IP").Formula = '"' + $RecoverySiteVM.Ip + '"'
	# MacAddress
	$RecoverySiteVMObject.Cells("Prop.MacAddress").Formula = '"' + $RecoverySiteVM.MacAddress + '"'
	# ProvisionedSpaceGB
	$RecoverySiteVMObject.Cells("Prop.ProvisionedSpaceGB").Formula = '"' + $RecoverySiteVM.ProvisionedSpaceGB + '"'
	# NumEthernetCards
	$RecoverySiteVMObject.Cells("Prop.NumEthernetCards").Formula = '"' + $RecoverySiteVM.NumEthernetCards + '"'
	# NumVirtualDisks
	$RecoverySiteVMObject.Cells("Prop.NumVirtualDisks").Formula = '"' + $RecoverySiteVM.NumVirtualDisks + '"'
	# CpuReservation
	$RecoverySiteVMObject.Cells("Prop.CpuReservation").Formula = '"' + $RecoverySiteVM.CpuReservation + '"'
	# MemoryReservation
	$RecoverySiteVMObject.Cells("Prop.MemoryReservation").Formula = '"' + $RecoverySiteVM.MemoryReservation + '"'
	# ProtectionGroup
	$RecoverySiteVMObject.Cells("Prop.ProtectionGroup").Formula = '"' + $RecoverySiteVM.ProtectionGroup + '"'
	# ProtectedVm
	$RecoverySiteVMObject.Cells("Prop.ProtectedVm").Formula = '"' + $RecoverySiteVM.ProtectedVm + '"'
	# PeerProtectedVm
	$RecoverySiteVMObject.Cells("Prop.PeerProtectedVm").Formula = '"' + $RecoverySiteVM.PeerProtectedVm + '"'
	# State
	$RecoverySiteVMObject.Cells("Prop.State").Formula = '"' + $RecoverySiteVM.State + '"'
	# PeerState
	$RecoverySiteVMObject.Cells("Prop.PeerState").Formula = '"' + $RecoverySiteVM.PeerState + '"'
	# NeedsConfiguration
	$RecoverySiteVMObject.Cells("Prop.NeedsConfiguration").Formula = '"' + $RecoverySiteVM.NeedsConfiguration + '"'
}
#endregion ~~< Draw_RecoverySiteVM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Draw_RecoverySiteDatastore Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Draw_RecoverySiteDatastore
{
	# Name
	$RecoverySiteDatastoreObject.Cells("Prop.Name").Formula = '"' + $RecoverySiteDatastore.Name + '"'
	# Type
	$RecoverySiteDatastoreObject.Cells("Prop.Type").Formula = '"' + $RecoverySiteDatastore.Type + '"'
	# FileSystemVersion
	$RecoverySiteDatastoreObject.Cells("Prop.FileSystemVersion").Formula = '"' + $RecoverySiteDatastore.FileSystemVersion + '"'
	# DiskName
	$RecoverySiteDatastoreObject.Cells("Prop.DiskName").Formula = '"' + $RecoverySiteDatastore.DiskName + '"'
	# StorageIOControlEnabled
	$RecoverySiteDatastoreObject.Cells("Prop.StorageIOControlEnabled").Formula = '"' + $RecoverySiteDatastore.StorageIOControlEnabled + '"'
	# CapacityGB
	$RecoverySiteDatastoreObject.Cells("Prop.CapacityGB").Formula = '"' + $RecoverySiteDatastore.CapacityGB + '"'
	# FreeSpaceGB
	$RecoverySiteDatastoreObject.Cells("Prop.FreeSpaceGB").Formula = '"' + $RecoverySiteDatastore.FreeSpaceGB + '"'
	# Vms
	$RecoverySiteDatastoreObject.Cells("Prop.Vms").Formula = '"' + $RecoverySiteDatastore.Vms + '"'
	# State
	$RecoverySiteDatastoreObject.Cells("Prop.State").Formula = '"' + $RecoverySiteDatastore.State + '"'
}
#endregion ~~< Draw_RecoverySiteDatastore Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Visio Draw Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< CSV Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< CSV_Import Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function CSV_Import
{
	# Protected
	$global:ProtectedSiteVC = $ProtectedSiteVcenterTextBox.Text
	$global:ProtectedSiteSRM = $ProtectedSiteSrmServerTextBox.Text
	# ProtectedSitevCenter
	$global:ProtectedSitevCenterServerExportFile = "$CsvDir\$ProtectedSiteSRM-ProtectedSitevCenterServerExport.csv"
	$global:ProtectedSitevCenterImport = Import-Csv $ProtectedSitevCenterServerExportFile
	# ProtectedSiteSrmServer
	$global:ProtectedSiteSrmServerExportFile = "$CsvDir\$ProtectedSiteSRM-ProtectedSiteSrmServerExport.csv"
	$global:ProtectedSiteSrmServerImport = Import-Csv $ProtectedSiteSrmServerExportFile
	# ProtectedSiteRecoveryPlan
	$global:ProtectedSiteRecoveryPlanExportFile = "$CsvDir\$ProtectedSiteSRM-ProtectedSiteRecoveryPlanExport.csv"
	$global:ProtectedSiteRecoveryPlanImport = Import-Csv $ProtectedSiteRecoveryPlanExportFile
	# ProtectedSiteProtectionGroup
	$global:ProtectedSiteProtectionGroupExportFile = "$CsvDir\$ProtectedSiteSRM-ProtectedSiteProtectionGroupExport.csv"
	$global:ProtectedSiteProtectionGroupImport = Import-Csv $ProtectedSiteProtectionGroupExportFile
	# ProtectedSiteVM
	$global:ProtectedSiteVMExportFile = "$CsvDir\$ProtectedSiteSRM-ProtectedSiteVMExport.csv"
	$global:ProtectedSiteVMImport = Import-Csv $ProtectedSiteVMExportFile
	# ProtectedSiteDatastore
	$global:ProtectedSiteDatastoreExportFile = "$CsvDir\$ProtectedSiteSRM-ProtectedSiteDatastoreExport.csv"
	$global:ProtectedSiteDatastoreImport = Import-Csv $ProtectedSiteDatastoreExportFile
	# Recovery
	$global:RecoverySiteVC = $RecoverySiteVcenterTextBox.Text
	$global:RecoverySiteSRM = $RecoverySiteSrmServerTextBox.Text
	# RecoverySitevCenter
	$global:RecoverySitevCenterServerExportFile = "$CsvDir\$RecoverySiteSRM-RecoverySitevCenterServerExport.csv"
	$global:RecoverySitevCenterImport = Import-Csv $RecoverySitevCenterServerExportFile
	# RecoverySiteSrmServer
	$global:RecoverySiteSrmServerExportFile = "$CsvDir\$RecoverySiteSRM-RecoverySiteSrmServerExport.csv"
	$global:RecoverySiteSrmServerImport = Import-Csv $RecoverySiteSrmServerExportFile
	# RecoverySiteRecoveryPlan
	$global:RecoverySiteRecoveryPlanExportFile = "$CsvDir\$RecoverySiteSRM-RecoverySiteRecoveryPlanExport.csv"
	$global:RecoverySiteRecoveryPlanImport = Import-Csv $RecoverySiteRecoveryPlanExportFile
	# RecoverySiteProtectionGroup
	$global:RecoverySiteProtectionGroupExportFile = "$CsvDir\$RecoverySiteSRM-RecoverySiteProtectionGroupExport.csv"
	$global:RecoverySiteProtectionGroupImport = Import-Csv $RecoverySiteProtectionGroupExportFile
	# RecoverySiteVM
	$global:RecoverySiteVMExportFile = "$CsvDir\$RecoverySiteSRM-RecoverySiteVMExport.csv"
	$global:RecoverySiteVMImport = Import-Csv $RecoverySiteVMExportFile
	# RecoverySiteDatastore
	$global:RecoverySiteDatastoreExportFile = "$CsvDir\$RecoverySiteSRM-RecoverySiteDatastoreExport.csv"
	$global:RecoverySiteDatastoreImport = Import-Csv $RecoverySiteDatastoreExportFile
}
#endregion ~~< CSV_Import Function >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< CSV Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Visio_Shapes Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Visio_Shapes
{
	$stnPath = [system.Environment]::GetFolderPath('MyDocuments') + "\My Shapes"
	$stnObj = $AppVisio.Documents.Add($stnPath + $shpFile)
	# vCenter Object
	$global:VCObj = $stnObj.Masters.Item("Virtual Center Management Console")
	# Datacenter Object
	$global:DatacenterObj = $stnObj.Masters.Item("Datacenter")
	# Cluster Object
	$global:ClusterObj = $stnObj.Masters.Item("Cluster")
	# Host Object
	$global:HostObj = $stnObj.Masters.Item("ESX Host")
	# Microsoft VM Object
	$global:MicrosoftObj = $stnObj.Masters.Item("Microsoft Server")
	# Linux VM Object
	$global:LinuxObj = $stnObj.Masters.Item("Linux Server")
	# Other VM Object
	$global:OtherObj = $stnObj.Masters.Item("Other Server")
	# Template VM Object
	$global:TemplateObj = $stnObj.Masters.Item("Template")
	# Folder Object
	$global:FolderObj = $stnObj.Masters.Item("Folder")
	# RDM Object
	$global:RDMObj = $stnObj.Masters.Item("RDM")
	# SRM Protected VM Object
	$global:SRMObj = $stnObj.Masters.Item("SRM Protected Server")
	# Datastore Cluster Object
	$global:DatastoreClusObj = $stnObj.Masters.Item("Datastore Cluster")
	# Datastore Object
	$global:DatastoreObj = $stnObj.Masters.Item("Datastore")
	# Resource Pool Object
	$global:ResourcePoolObj = $stnObj.Masters.Item("Resource Pool")
	# VSS Object
	$global:VSSObj = $stnObj.Masters.Item("VSS")
	# VSS PNIC Object
	$global:VssPNICObj = $stnObj.Masters.Item("VSS Physical NIC")
	# VSSNIC Object
	$global:VssNicObj = $stnObj.Masters.Item("VSS NIC")
	# VDS Object
	$global:VDSObj = $stnObj.Masters.Item("VDS")
	# VDS PNIC Object
	$global:VdsPNICObj = $stnObj.Masters.Item("VDS Physical NIC")
	# VDSNIC Object
	$global:VdsNicObj = $stnObj.Masters.Item("VDS NIC")
	# VMK NIC Object
	$global:VmkNicObj = $stnObj.Masters.Item("VMKernel")
	# DRS Rule
	$global:DRSRuleObj = $stnObj.Masters.Item("DRS Rule")
	# DRS Cluster Group
	$global:DRSClusterGroupObj = $stnObj.Masters.Item("DRS Cluster group")
	# DRS Host Rule
	$global:DRSVMHostRuleObj = $stnObj.Masters.Item("DRS Host Rule")
	# SrmServer Object
	$global:SrmServerObj = $stnObj.Masters.Item("Site Recovery Manager")
	# Protection Group Object
	$global:ProtectionGroupObj = $stnObj.Masters.Item("Protection Group")
	# Recovery Plan Object
	$global:RecoveryPlanObj = $stnObj.Masters.Item("Recovery Plan")
}
#endregion ~~< Visio_Shapes Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Visio Pages Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Base Page >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Create_Visio_Base Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Create_Visio_Base
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$DocObj = $docsObj.Add("")
	$DocObj.SaveAs($Savefile)
	$AppVisio.Quit()
}
#endregion ~~< Create_Visio_Base Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Base Page >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_RecoveryPlan_to_ProtectionGroup Functions >~~~~~~~~~~~~~~~~~~~~~~~~
function Combined_RecoveryPlan_to_ProtectionGroup
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "Combined RecoveryPlan to ProtectionGroup"
	$Page = $DocsObj.Pages('Combined RecoveryPlan to ProtectionGroup')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('Combined RecoveryPlan to ProtectionGroup')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$ProtectedSiteVCObject = Add-VisioObjectVC $VCObj $ProtectedSitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($ProtectedSiteSrmServer in $ProtectedSiteSrmServerImport)
	{
		$x = 1.50
		$y += 1.50
		$ProtectedSiteSRMObject = Add-VisioObjectSRM $SrmServerObj $ProtectedSiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $ProtectedSiteVCObject $ProtectedSiteSRMObject
				
		foreach ($ProtectedSiteRecoveryPlan in ($ProtectedSiteRecoveryPlanImport | sort-object Name -Unique))
		{
			$x = 3.50
			$y += 1.50
			$ProtectedSiteRecoveryPlanObject = Add-VisioObjectRecoveryPlan $RecoveryPlanObj $ProtectedSiteRecoveryPlan
			Draw_ProtectedSiteRecoveryPlan
			Connect-VisioObject $ProtectedSiteSRMObject $ProtectedSiteRecoveryPlanObject
			$y += 1.50
			
			foreach ($ProtectedSiteProtectionGroup in ($ProtectedSiteProtectionGroupImport | sort-object Name | where-object { $_.RecoveryPlan.contains($ProtectedSiteRecoveryPlan.Name) } ))
			{
				$x += 2.50
				$ProtectedSiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($ProtectedSiteProtectionGroup)
				Draw_ProtectedSiteProtectionGroup
				Connect-VisioObject $ProtectedSiteRecoveryPlanObject $ProtectedSiteProtectionGroupObject
				$ProtectedSiteRecoveryPlanObject = $ProtectedSiteProtectionGroupObject
			}
		}
	}
	# Draw Objects
	$x = -3.00
	$y = 1.50
		
	$RecoverySiteVCObject = Add-VisioObjectVC $VCObj $RecoverySitevCenterImport
	Draw_RecoverySitevCenter
	
	foreach ($RecoverySiteSrmServer in $RecoverySiteSrmServerImport)
	{
		$x = -4.50
		$y += 1.50
		$RecoverySiteSRMObject = Add-VisioObjectSRM $SrmServerObj $RecoverySiteSrmServer
		Draw_RecoverySiteSRM
		Connect-VisioObject $RecoverySiteVCObject $RecoverySiteSRMObject
		Connect-VisioObject $ProtectedSiteSRMObject $RecoverySiteSRMObject
				
		foreach ($RecoverySiteRecoveryPlan in ($RecoverySiteRecoveryPlanImport | sort-object Name -Unique ))
		{
			$x = -6.50
			$y += 1.50
			$RecoverySiteRecoveryPlanObject = Add-VisioObjectRecoveryPlan $RecoveryPlanObj $RecoverySiteRecoveryPlan
			Draw_RecoverySiteRecoveryPlan
			Connect-VisioObject $RecoverySiteSRMObject $RecoverySiteRecoveryPlanObject
			$y += 1.50
			
			foreach ($RecoverySiteProtectionGroup in ($RecoverySiteProtectionGroupImport | sort-object Name -Descending | where-object { $_.RecoveryPlan.contains($RecoverySiteRecoveryPlan.Name) } ))
			{
				$x += -2.50
				$RecoverySiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($RecoverySiteProtectionGroup)
				Draw_RecoverySiteProtectionGroup
				Connect-VisioObject $RecoverySiteRecoveryPlanObject $RecoverySiteProtectionGroupObject
				$RecoverySiteRecoveryPlanObject = $RecoverySiteProtectionGroupObject
			}
		}
	}
	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< Combined_RecoveryPlan_to_ProtectionGroup Functions >~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Combined_ProtectionGroup_to_VM
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "Combined ProtectionGroup to VM"
	$Page = $DocsObj.Pages('Combined ProtectionGroup to VM')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('Combined ProtectionGroup to VM')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$ProtectedSiteVCObject = Add-VisioObjectVC $VCObj $ProtectedSitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($ProtectedSiteSrmServer in ( $ProtectedSiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$ProtectedSiteSRMObject = Add-VisioObjectSRM $SrmServerObj $ProtectedSiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $ProtectedSiteVCObject $ProtectedSiteSRMObject

		foreach ($ProtectedSiteProtectionGroup in ($ProtectedSiteProtectionGroupImport | sort-object Name -Unique ))
		{
			$x = 3.50
			$y += 1.50
			$ProtectedSiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($ProtectedSiteProtectionGroup)
			Draw_ProtectedSiteProtectionGroup
			Connect-VisioObject $ProtectedSiteSRMObject $ProtectedSiteProtectionGroupObject
			$y += 1.50
			
			foreach ($ProtectedSiteVM in ($ProtectedSiteVMImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($ProtectedSiteProtectionGroup.Name)} ))
			{
				$x += 2.50
				if ($ProtectedSiteVM.Os -eq "")
				{
					$ProtectedSiteVMObject = Add-VisioObjectVM $OtherObj $ProtectedSiteVM
					Draw_ProtectedSiteVM
				}
				else
				{
					if ($ProtectedSiteVM.Os.contains("Microsoft") -eq $True)
					{
						$ProtectedSiteVMObject = Add-VisioObjectVM $MicrosoftObj $ProtectedSiteVM
						Draw_ProtectedSiteVM
					}
					else
					{
						$ProtectedSiteVMObject = Add-VisioObjectVM $LinuxObj $ProtectedSiteVM
						Draw_ProtectedSiteVM
					}
				}	
				Connect-VisioObject $ProtectedSiteProtectionGroupObject $ProtectedSiteVMObject
				$ProtectedSiteProtectionGroupObject = $ProtectedSiteVMObject
			}
		}
	}
	
	# Draw Objects
	$x = -3.00
	$y = 1.50
		
	$RecoverySiteVCObject = Add-VisioObjectVC $VCObj $RecoverySitevCenterImport
	Draw_RecoverySitevCenter
	
	foreach ($RecoverySiteSrmServer in ($RecoverySiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = -4.50
		$y += 1.50
		$RecoverySiteSRMObject = Add-VisioObjectSRM $SrmServerObj $RecoverySiteSrmServer
		Draw_RecoverySiteSRM
		Connect-VisioObject $RecoverySiteVCObject $RecoverySiteSRMObject
		Connect-VisioObject $ProtectedSiteSRMObject $RecoverySiteSRMObject

		foreach ($RecoverySiteProtectionGroup in ($RecoverySiteProtectionGroupImport | sort-object Name -Unique ))
		{
			$x = -7.50
			$y += 1.50
			$RecoverySiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($RecoverySiteProtectionGroup)
			Draw_RecoverySiteProtectionGroup
			Connect-VisioObject $RecoverySiteSRMObject $RecoverySiteProtectionGroupObject
			$y += 1.50
			
			foreach ($RecoverySiteVM in ($RecoverySiteVMImport | sort-object Name -Unique -Descending | where-object {$_.ProtectionGroup.contains($RecoverySiteProtectionGroup.Name)} ))
			{
				$x += -2.50
				if ($RecoverySiteVM.Os -eq "")
				{
					$RecoverySiteVMObject = Add-VisioObjectVM $OtherObj $RecoverySiteVM
					Draw_RecoverySiteVM
				}
				else
				{
					if ($RecoverySiteVM.Os.contains("Microsoft") -eq $True)
					{
						$RecoverySiteVMObject = Add-VisioObjectVM $MicrosoftObj $RecoverySiteVM
						Draw_RecoverySiteVM
					}
					else
					{
						$RecoverySiteVMObject = Add-VisioObjectVM $LinuxObj $RecoverySiteVM
						Draw_RecoverySiteVM
					}
				}	
				Connect-VisioObject $RecoverySiteProtectionGroupObject $RecoverySiteVMObject
				$RecoverySiteProtectionGroupObject = $RecoverySiteVMObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< Combined_ProtectionGroup_to_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_Datastore Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Combined_ProtectionGroup_to_Datastore
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "Combined ProtectionGroup to Datastore (ABR)"
	$Page = $DocsObj.Pages('Combined ProtectionGroup to Datastore (ABR)')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('Combined ProtectionGroup to Datastore (ABR)')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$ProtectedSiteVCObject = Add-VisioObjectVC $VCObj $ProtectedSitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($ProtectedSiteSrmServer in ( $ProtectedSiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$ProtectedSiteSRMObject = Add-VisioObjectSRM $SrmServerObj $ProtectedSiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $ProtectedSiteVCObject $ProtectedSiteSRMObject

		foreach ($ProtectedSiteProtectionGroup in ($ProtectedSiteProtectionGroupImport | sort-object Name -Unique | where-object {$_.ReplicationType.contains("vr") -eq $False} ))
		{
			$x = 3.50
			$y += 1.50
			$ProtectedSiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($ProtectedSiteProtectionGroup)
			Draw_ProtectedSiteProtectionGroup
			Connect-VisioObject $ProtectedSiteSRMObject $ProtectedSiteProtectionGroupObject
			$y += 1.50
			
			foreach ($ProtectedSiteDatastore in ($ProtectedSiteDatastoreImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($ProtectedSiteProtectionGroup.Name)} ))
			{
				$x += 3.50
				$ProtectedSiteDatastoreObject = Add-VisioObjectVM $DatastoreObj $ProtectedSiteDatastore
				Draw_ProtectedSiteDatastore
				
				Connect-VisioObject $ProtectedSiteProtectionGroupObject $ProtectedSiteDatastoreObject
				$ProtectedSiteProtectionGroupObject = $ProtectedSiteDatastoreObject
				
			}
		}
	}
	
	# Draw Objects
	$x = -3.00
	$y = 1.50
		
	$RecoverySiteVCObject = Add-VisioObjectVC $VCObj $RecoverySitevCenterImport
	Draw_RecoverySitevCenter
	
	foreach ($RecoverySiteSrmServer in ( $RecoverySiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = -4.50
		$y += 1.50
		$RecoverySiteSRMObject = Add-VisioObjectSRM $SrmServerObj $RecoverySiteSrmServer
		Draw_RecoverySiteSRM
		Connect-VisioObject $RecoverySiteVCObject $RecoverySiteSRMObject
		Connect-VisioObject $ProtectedSiteSRMObject $RecoverySiteSRMObject

		foreach ($RecoverySiteProtectionGroup in ($RecoverySiteProtectionGroupImport | sort-object Name -Unique | where-object {$_.ReplicationType.contains("vr") -eq $False} ))
		{
			$x = -7.50
			$y += 1.50
			$RecoverySiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($RecoverySiteProtectionGroup)
			Draw_RecoverySiteProtectionGroup
			Connect-VisioObject $RecoverySiteSRMObject $RecoverySiteProtectionGroupObject
			$y += 1.50
			
			foreach ($RecoverySiteDatastore in ($RecoverySiteDatastoreImport | sort-object Name -Unique -Descending | where-object {$_.ProtectionGroup.contains($RecoverySiteProtectionGroup.Name)} ))
			{
				$x += -3.50
				$RecoverySiteDatastoreObject = Add-VisioObjectVM $DatastoreObj $RecoverySiteDatastore
				Draw_RecoverySiteDatastore
				
				Connect-VisioObject $RecoverySiteProtectionGroupObject $RecoverySiteDatastoreObject
				$RecoverySiteProtectionGroupObject = $RecoverySiteDatastoreObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< Combined_ProtectionGroup_to_Datastore Functions >~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Combined_ProtectionGroup_to_VR_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Combined_ProtectionGroup_to_VR_VM
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "Combined ProtectionGroup to VM (vSphere Replication)"
	$Page = $DocsObj.Pages('Combined ProtectionGroup to VM (vSphere Replication)')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('Combined ProtectionGroup to VM (vSphere Replication)')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$ProtectedSiteVCObject = Add-VisioObjectVC $VCObj $ProtectedSitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($ProtectedSiteSrmServer in ( $ProtectedSiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$ProtectedSiteSRMObject = Add-VisioObjectSRM $SrmServerObj $ProtectedSiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $ProtectedSiteVCObject $ProtectedSiteSRMObject

		foreach ($ProtectedSiteProtectionGroup in ($ProtectedSiteProtectionGroupImport | sort-object Name -Unique | where-object {$_.ReplicationType.contains("vr") -eq $True} ))
		{
			$x = 3.50
			$y += 1.50
			$ProtectedSiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($ProtectedSiteProtectionGroup)
			Draw_ProtectedSiteProtectionGroup
			Connect-VisioObject $ProtectedSiteSRMObject $ProtectedSiteProtectionGroupObject
			$y += 1.50
			
			foreach ($ProtectedSiteVM in ($ProtectedSiteVMImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($ProtectedSiteProtectionGroup.Name) -and $_.ReplicationType.contains("vr")} ))
			{
				$x += 2.50
				if ($ProtectedSiteVM.Os -eq "")
				{
					$ProtectedSiteVMObject = Add-VisioObjectVM $OtherObj $ProtectedSiteVM
					Draw_ProtectedSiteVM
				}
				else
				{
					if ($ProtectedSiteVM.Os.contains("Microsoft") -eq $True)
					{
						$ProtectedSiteVMObject = Add-VisioObjectVM $MicrosoftObj $ProtectedSiteVM
						Draw_ProtectedSiteVM
					}
					else
					{
						$ProtectedSiteVMObject = Add-VisioObjectVM $LinuxObj $ProtectedSiteVM
						Draw_ProtectedSiteVM
					}
				}	
				Connect-VisioObject $ProtectedSiteProtectionGroupObject $ProtectedSiteVMObject
				$ProtectedSiteProtectionGroupObject = $ProtectedSiteVMObject
			}
		}
	}
	
	# Draw Objects
	$x = -3.00
	$y = 1.50
		
	$RecoverySiteVCObject = Add-VisioObjectVC $VCObj $RecoverySitevCenterImport
	Draw_RecoverySitevCenter
	
	foreach ($RecoverySiteSrmServer in ($RecoverySiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = -4.50
		$y += 1.50
		$RecoverySiteSRMObject = Add-VisioObjectSRM $SrmServerObj $RecoverySiteSrmServer
		Draw_RecoverySiteSRM
		Connect-VisioObject $RecoverySiteVCObject $RecoverySiteSRMObject
		Connect-VisioObject $ProtectedSiteSRMObject $RecoverySiteSRMObject

		foreach ($RecoverySiteProtectionGroup in ($RecoverySiteProtectionGroupImport | sort-object Name -Unique | where-object {$_.ReplicationType.contains("vr") -eq $True} ))
		{
			$x = -7.50
			$y += 1.50
			$RecoverySiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($RecoverySiteProtectionGroup)
			Draw_RecoverySiteProtectionGroup
			Connect-VisioObject $RecoverySiteSRMObject $RecoverySiteProtectionGroupObject
			$y += 1.50
			
			foreach ($RecoverySiteVM in ($RecoverySiteVMImport | sort-object Name -Unique -Descending | where-object {$_.ProtectionGroup.contains($RecoverySiteProtectionGroup.Name) -and $_.ReplicationType.contains("vr")} ))
			{
				$x += -2.50
				if ($RecoverySiteVM.Os -eq "")
				{
					$RecoverySiteVMObject = Add-VisioObjectVM $OtherObj $RecoverySiteVM
					Draw_RecoverySiteVM
				}
				else
				{
					if ($RecoverySiteVM.Os.contains("Microsoft") -eq $True)
					{
						$RecoverySiteVMObject = Add-VisioObjectVM $MicrosoftObj $RecoverySiteVM
						Draw_RecoverySiteVM
					}
					else
					{
						$RecoverySiteVMObject = Add-VisioObjectVM $LinuxObj $RecoverySiteVM
						Draw_RecoverySiteVM
					}
				}	
				Connect-VisioObject $RecoverySiteProtectionGroupObject $RecoverySiteVMObject
				$RecoverySiteProtectionGroupObject = $RecoverySiteVMObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< Combined_ProtectionGroup_to_VR_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Combined >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_RecoveryPlan_to_ProtectionGroup Functions >~~~~~~~~~~~~~~~~~~~
function ProtectedSite_RecoveryPlan_to_ProtectionGroup
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "PS RecoveryPlan to ProtectionGroup"
	$Page = $DocsObj.Pages('PS RecoveryPlan to ProtectionGroup')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('PS RecoveryPlan to ProtectionGroup')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$ProtectedSiteVCObject = Add-VisioObjectVC $VCObj $ProtectedSitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($ProtectedSiteSrmServer in $ProtectedSiteSrmServerImport)
	{
		$x = 1.50
		$y += 1.50
		$ProtectedSiteSRMObject = Add-VisioObjectSRM $SrmServerObj $ProtectedSiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $ProtectedSiteVCObject $ProtectedSiteSRMObject
				
		foreach ($ProtectedSiteRecoveryPlan in ($ProtectedSiteRecoveryPlanImport | sort-object Name -Unique))
		{
			$x = 3.50
			$y += 1.50
			$ProtectedSiteRecoveryPlanObject = Add-VisioObjectRecoveryPlan $RecoveryPlanObj $ProtectedSiteRecoveryPlan
			Draw_ProtectedSiteRecoveryPlan
			Connect-VisioObject $ProtectedSiteSRMObject $ProtectedSiteRecoveryPlanObject
			$y += 1.50
			
			foreach ($ProtectedSiteProtectionGroup in ($ProtectedSiteProtectionGroupImport | sort-object Name | where-object { $_.RecoveryPlan.contains($ProtectedSiteRecoveryPlan.Name) } ))
			{
				$x += 2.50
				$ProtectedSiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($ProtectedSiteProtectionGroup)
				Draw_ProtectedSiteProtectionGroup
				Connect-VisioObject $ProtectedSiteRecoveryPlanObject $ProtectedSiteProtectionGroupObject
				$ProtectedSiteRecoveryPlanObject = $ProtectedSiteProtectionGroupObject
			}
		}
	}
	
	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< ProtectedSite_RecoveryPlan_to_ProtectionGroup Functions >~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSite_ProtectionGroup_to_VM
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "PS ProtectionGroup to VM"
	$Page = $DocsObj.Pages('PS ProtectionGroup to VM')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('PS ProtectionGroup to VM')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$ProtectedSiteVCObject = Add-VisioObjectVC $VCObj $ProtectedSitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($ProtectedSiteSrmServer in ( $ProtectedSiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$ProtectedSiteSRMObject = Add-VisioObjectSRM $SrmServerObj $ProtectedSiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $ProtectedSiteVCObject $ProtectedSiteSRMObject

		foreach ($ProtectedSiteProtectionGroup in ($ProtectedSiteProtectionGroupImport | sort-object Name -Unique ))
		{
			$x = 3.50
			$y += 1.50
			$ProtectedSiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($ProtectedSiteProtectionGroup)
			Draw_ProtectedSiteProtectionGroup
			Connect-VisioObject $ProtectedSiteSRMObject $ProtectedSiteProtectionGroupObject
			$y += 1.50
			
			foreach ($ProtectedSiteVM in ($ProtectedSiteVMImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($ProtectedSiteProtectionGroup.Name)} ))
			{
				$x += 2.50
				if ($ProtectedSiteVM.Os -eq "")
				{
					$ProtectedSiteVMObject = Add-VisioObjectVM $OtherObj $ProtectedSiteVM
					Draw_ProtectedSiteVM
				}
				else
				{
					if ($ProtectedSiteVM.Os.contains("Microsoft") -eq $True)
					{
						$ProtectedSiteVMObject = Add-VisioObjectVM $MicrosoftObj $ProtectedSiteVM
						Draw_ProtectedSiteVM
					}
					else
					{
						$ProtectedSiteVMObject = Add-VisioObjectVM $LinuxObj $ProtectedSiteVM
						Draw_ProtectedSiteVM
					}
				}	
				Connect-VisioObject $ProtectedSiteProtectionGroupObject $ProtectedSiteVMObject
				$ProtectedSiteProtectionGroupObject = $ProtectedSiteVMObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< ProtectedSite_ProtectionGroup_to_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_Datastore Functions >~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSite_ProtectionGroup_to_Datastore
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "PS ProtectionGroup to Datastore (ABR)"
	$Page = $DocsObj.Pages('PS ProtectionGroup to Datastore (ABR)')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('PS ProtectionGroup to Datastore (ABR)')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$ProtectedSiteVCObject = Add-VisioObjectVC $VCObj $ProtectedSitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($ProtectedSiteSrmServer in ( $ProtectedSiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$ProtectedSiteSRMObject = Add-VisioObjectSRM $SrmServerObj $ProtectedSiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $ProtectedSiteVCObject $ProtectedSiteSRMObject

		foreach ($ProtectedSiteProtectionGroup in ($ProtectedSiteProtectionGroupImport | sort-object Name -Unique | where-object {$_.ReplicationType.contains("vr") -eq $False} ))
		{
			$x = 3.50
			$y += 1.50
			$ProtectedSiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($ProtectedSiteProtectionGroup)
			Draw_ProtectedSiteProtectionGroup
			Connect-VisioObject $ProtectedSiteSRMObject $ProtectedSiteProtectionGroupObject
			$y += 1.50
			
			foreach ($ProtectedSiteDatastore in ($ProtectedSiteDatastoreImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($ProtectedSiteProtectionGroup.Name)} ))
			{
				$x += 3.50
				$ProtectedSiteDatastoreObject = Add-VisioObjectVM $DatastoreObj $ProtectedSiteDatastore
				Draw_ProtectedSiteDatastore
				
				Connect-VisioObject $ProtectedSiteProtectionGroupObject $ProtectedSiteDatastoreObject
				$ProtectedSiteProtectionGroupObject = $ProtectedSiteDatastoreObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< ProtectedSite_ProtectionGroup_to_Datastore Functions >~~~~~~~~~~~~~~~~~~~
#region ~~< ProtectedSite_ProtectionGroup_to_VR_VM Functions >~~~~~~~~~~~~~~~~~~~~~~
function ProtectedSite_ProtectionGroup_to_VR_VM
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "PS ProtectionGroup to VM (vSphere Replication)"
	$Page = $DocsObj.Pages('PS ProtectionGroup to VM (vSphere Replication)')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('PS ProtectionGroup to VM (vSphere Replication)')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$ProtectedSiteVCObject = Add-VisioObjectVC $VCObj $ProtectedSitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($ProtectedSiteSrmServer in ( $ProtectedSiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$ProtectedSiteSRMObject = Add-VisioObjectSRM $SrmServerObj $ProtectedSiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $ProtectedSiteVCObject $ProtectedSiteSRMObject

		foreach ($ProtectedSiteProtectionGroup in ($ProtectedSiteProtectionGroupImport | sort-object Name -Unique | where-object {$_.ReplicationType.contains("vr") -eq $True} ))
		{
			$x = 3.50
			$y += 1.50
			$ProtectedSiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($ProtectedSiteProtectionGroup)
			Draw_ProtectedSiteProtectionGroup
			Connect-VisioObject $ProtectedSiteSRMObject $ProtectedSiteProtectionGroupObject
			$y += 1.50
			
			foreach ($ProtectedSiteVM in ($ProtectedSiteVMImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($ProtectedSiteProtectionGroup.Name) -and $_.ReplicationType.contains("vr")} ))
			{
				$x += 2.50
				if ($ProtectedSiteVM.Os -eq "")
				{
					$ProtectedSiteVMObject = Add-VisioObjectVM $OtherObj $ProtectedSiteVM
					Draw_ProtectedSiteVM
				}
				else
				{
					if ($ProtectedSiteVM.Os.contains("Microsoft") -eq $True)
					{
						$ProtectedSiteVMObject = Add-VisioObjectVM $MicrosoftObj $ProtectedSiteVM
						Draw_ProtectedSiteVM
					}
					else
					{
						$ProtectedSiteVMObject = Add-VisioObjectVM $LinuxObj $ProtectedSiteVM
						Draw_ProtectedSiteVM
					}
				}	
				Connect-VisioObject $ProtectedSiteProtectionGroupObject $ProtectedSiteVMObject
				$ProtectedSiteProtectionGroupObject = $ProtectedSiteVMObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< ProtectedSite_ProtectionGroup_to_VR_VM Functions >~~~~~~~~~~~~~~~~~~~
#endregion ~~< Protected >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_RecoveryPlan_to_ProtectionGroup Functions >~~~~~~~~~~~~~~~~~~~~
function RecoverySite_RecoveryPlan_to_ProtectionGroup
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "RS RecoveryPlan to ProtectionGroup"
	$Page = $DocsObj.Pages('RS RecoveryPlan to ProtectionGroup')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('RS RecoveryPlan to ProtectionGroup')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$RecoverySiteVCObject = Add-VisioObjectVC $VCObj $RecoverySitevCenterImport
	Draw_RecoverySitevCenter
	
	foreach ($RecoverySiteSrmServer in $RecoverySiteSrmServerImport)
	{
		$x = 1.50
		$y += 1.50
		$RecoverySiteSRMObject = Add-VisioObjectSRM $SrmServerObj $RecoverySiteSrmServer
		Draw_RecoverySiteSRM
		Connect-VisioObject $RecoverySiteVCObject $RecoverySiteSRMObject
				
		foreach ($RecoverySiteRecoveryPlan in ($RecoverySiteRecoveryPlanImport | sort-object Name -Unique ))
		{
			$x = 3.50
			$y += 1.50
			$RecoverySiteRecoveryPlanObject = Add-VisioObjectRecoveryPlan $RecoveryPlanObj $RecoverySiteRecoveryPlan
			Draw_RecoverySiteRecoveryPlan
			Connect-VisioObject $RecoverySiteSRMObject $RecoverySiteRecoveryPlanObject
			$y += 1.50
			
			foreach ($RecoverySiteProtectionGroup in ($RecoverySiteProtectionGroupImport | sort-object Name | where-object { $_.RecoveryPlan.contains($RecoverySiteRecoveryPlan.Name) } ))
			{
				$x += 2.50
				$RecoverySiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($RecoverySiteProtectionGroup)
				Draw_RecoverySiteProtectionGroup
				Connect-VisioObject $RecoverySiteRecoveryPlanObject $RecoverySiteProtectionGroupObject
				$RecoverySiteRecoveryPlanObject = $RecoverySiteProtectionGroupObject
			}
		}
	}
	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< RecoverySite_RecoveryPlan_to_ProtectionGroup Functions >~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySite_ProtectionGroup_to_VM
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "RS ProtectionGroup to VM"
	$Page = $DocsObj.Pages('RS ProtectionGroup to VM')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('RS ProtectionGroup to VM')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$RecoverySiteVCObject = Add-VisioObjectVC $VCObj $RecoverySitevCenterImport
	Draw_RecoverySitevCenter
	
	foreach ($RecoverySiteSrmServer in ($RecoverySiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$RecoverySiteSRMObject = Add-VisioObjectSRM $SrmServerObj $RecoverySiteSrmServer
		Draw_RecoverySiteSRM
		Connect-VisioObject $RecoverySiteVCObject $RecoverySiteSRMObject

		foreach ($RecoverySiteProtectionGroup in ($RecoverySiteProtectionGroupImport | sort-object Name -Unique ))
		{
			$x = 3.50
			$y += 1.50
			$RecoverySiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($RecoverySiteProtectionGroup)
			Draw_RecoverySiteProtectionGroup
			Connect-VisioObject $RecoverySiteSRMObject $RecoverySiteProtectionGroupObject
			$y += 1.50
			
			foreach ($RecoverySiteVM in ($RecoverySiteVMImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($RecoverySiteProtectionGroup.Name)} ))
			{
				$x += 2.50
				if ($RecoverySiteVM.Os -eq "")
				{
					$RecoverySiteVMObject = Add-VisioObjectVM $OtherObj $RecoverySiteVM
					Draw_RecoverySiteVM
				}
				else
				{
					if ($RecoverySiteVM.Os.contains("Microsoft") -eq $True)
					{
						$RecoverySiteVMObject = Add-VisioObjectVM $MicrosoftObj $RecoverySiteVM
						Draw_RecoverySiteVM
					}
					else
					{
						$RecoverySiteVMObject = Add-VisioObjectVM $LinuxObj $RecoverySiteVM
						Draw_RecoverySiteVM
					}
				}	
				Connect-VisioObject $RecoverySiteProtectionGroupObject $RecoverySiteVMObject
				$RecoverySiteProtectionGroupObject = $RecoverySiteVMObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< RecoverySite_ProtectionGroup_to_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_Datastore Functions >~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySite_ProtectionGroup_to_Datastore
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "RS ProtectionGroup to Datastore (ABR)"
	$Page = $DocsObj.Pages('RS ProtectionGroup to Datastore (ABR)')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('RS ProtectionGroup to Datastore (ABR)')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$RecoverySiteVCObject = Add-VisioObjectVC $VCObj $RecoverySitevCenterImport
	Draw_RecoverySitevCenter
	
	foreach ($RecoverySiteSrmServer in ( $RecoverySiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$RecoverySiteSRMObject = Add-VisioObjectSRM $SrmServerObj $RecoverySiteSrmServer
		Draw_RecoverySiteSRM
		Connect-VisioObject $RecoverySiteVCObject $RecoverySiteSRMObject

		foreach ($RecoverySiteProtectionGroup in ($RecoverySiteProtectionGroupImport | sort-object Name -Unique | where-object {$_.ReplicationType.contains("vr") -eq $False} ))
		{
			$x = 3.50
			$y += 1.50
			$RecoverySiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($RecoverySiteProtectionGroup)
			Draw_RecoverySiteProtectionGroup
			Connect-VisioObject $RecoverySiteSRMObject $RecoverySiteProtectionGroupObject
			$y += 1.50
			
			foreach ($RecoverySiteDatastore in ($RecoverySiteDatastoreImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($RecoverySiteProtectionGroup.Name)} ))
			{
				$x += 3.50
				$RecoverySiteDatastoreObject = Add-VisioObjectVM $DatastoreObj $RecoverySiteDatastore
				Draw_RecoverySiteDatastore
			
				Connect-VisioObject $RecoverySiteProtectionGroupObject $RecoverySiteDatastoreObject
				$RecoverySiteProtectionGroupObject = $RecoverySiteDatastoreObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< RecoverySite_ProtectionGroup_to_Datastore Functions >~~~~~~~~~~~~~~~~~~~~
#region ~~< RecoverySite_ProtectionGroup_to_VR_VM Functions >~~~~~~~~~~~~~~~~~~~~~~~
function RecoverySite_ProtectionGroup_to_VR_VM
{
	$CsvDir = $SRMDrawCsvFolder
	$SaveDir = $VisioFolder
	$SaveFile = "$SaveDir" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	CSV_Import
	
	$AppVisio = New-Object -ComObject Visio.InvisibleApp
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Add() | Out-Null
	$Page = $AppVisio.ActivePage.Name = "RS ProtectionGroup to VM (vSphere Replication)"
	$Page = $DocsObj.Pages('RS ProtectionGroup to VM (vSphere Replication)')
	$pagsObj = $AppVisio.ActiveDocument.Pages
	$pagObj = $pagsObj.Item('RS ProtectionGroup to VM (vSphere Replication)')
	$AppVisio.ScreenUpdating = $False
	$AppVisio.EventsEnabled = $False
	
	# Load a set of stencils and select one to drop
	Visio_Shapes
		
	# Draw Objects
	$x = 0
	$y = 1.50
		
	$RecoverySiteVCObject = Add-VisioObjectVC $VCObj $RecoverySitevCenterImport
	Draw_ProtectedSitevCenter
	
	foreach ($RecoverySiteSrmServer in ( $RecoverySiteSrmServerImport | sort-object Name -Unique ))
	{
		$x = 1.50
		$y += 1.50
		$RecoverySiteSRMObject = Add-VisioObjectSRM $SrmServerObj $RecoverySiteSrmServer
		Draw_ProtectedSiteSRM
		Connect-VisioObject $RecoverySiteVCObject $RecoverySiteSRMObject

		foreach ($RecoverySiteProtectionGroup in ($RecoverySiteProtectionGroupImport | sort-object Name -Unique| where-object {$_.ReplicationType.contains("vr") -eq $True} ))
		{
			$x = 3.50
			$y += 1.50
			$RecoverySiteProtectionGroupObject = Add-VisioObjectProtectionGroup $ProtectionGroupObj ($RecoverySiteProtectionGroup)
			Draw_ProtectedSiteProtectionGroup
			Connect-VisioObject $RecoverySiteSRMObject $RecoverySiteProtectionGroupObject
			$y += 1.50
			
			foreach ($RecoverySiteVM in ($RecoverySiteVMImport | sort-object Name -Unique | where-object {$_.ProtectionGroup.contains($RecoverySiteProtectionGroup.Name) -and $_.ReplicationType.contains("vr")} ))
			{
				$x += 2.50
				if ($RecoverySiteVM.Os -eq "")
				{
					$RecoverySiteVMObject = Add-VisioObjectVM $OtherObj $RecoverySiteVM
					Draw_ProtectedSiteVM
				}
				else
				{
					if ($RecoverySiteVM.Os.contains("Microsoft") -eq $True)
					{
						$RecoverySiteVMObject = Add-VisioObjectVM $MicrosoftObj $RecoverySiteVM
						Draw_ProtectedSiteVM
					}
					else
					{
						$RecoverySiteVMObject = Add-VisioObjectVM $LinuxObj $RecoverySiteVM
						Draw_ProtectedSiteVM
					}
				}	
				Connect-VisioObject $RecoverySiteProtectionGroupObject $RecoverySiteVMObject
				$RecoverySiteProtectionGroupObject = $RecoverySiteVMObject
			}
		}
	}

	# Resize to fit page
	$pagObj.ResizeToFitContents()
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Quit()
}
#endregion ~~< RecoverySite_ProtectionGroup_to_VR_VM Functions >~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Recovery >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Open Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Open_Capture_Folder >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Open_Capture_Folder
{
	explorer.exe $SRMCaptureCsvFolder
}
#endregion ~~< Open_Capture_Folder >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#region ~~< Open_Final_Visio Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Open_Final_Visio
{
	$SaveFile = "$VisioFolder" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsd"
	$ConvertSaveFile = "$VisioFolder" + "\" + "VMware vDiagram SRM - " + "$DateTime" + ".vsdx"
	$AppVisio = New-Object -ComObject Visio.Application
	$docsObj = $AppVisio.Documents
	$docsObj.Open($Savefile) | Out-Null
	$AppVisio.ActiveDocument.Pages.Item(1).Delete(1) | Out-Null
	$AppVisio.Documents.SaveAs($SaveFile) | Out-Null
	$AppVisio.Documents.SaveAs($ConvertSaveFile) | Out-Null
	del $SaveFile
}
#endregion ~~< Open_Final_Visio Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Open Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Visio Pages Functions >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endregion ~~< Event Handlers >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -DefaultVIServerMode Multiple -Scope AllUsers -Confirm:$False | Out-Null
Main