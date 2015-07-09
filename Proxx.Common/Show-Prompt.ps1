Function Show-Prompt {
<#
	.SYNOPSIS
		Function to display a Simple Yes or No Prompt.

	.DESCRIPTION
		Displays Yes or No Pompt with or without help text.

	.PARAMETER  Yes
		Set default to Yes.

	.PARAMETER  Title
		Title of Question
		
	.PARAMETER  HelpYes
		Help text for Yes action
		
	.PARAMETER  HelpNo
		Help text for No action
	
	.EXAMPLE
		PS C:\> Show-Prompt "Continue?" -yes -HelpYes "Continue the script" -HelpNo "Abort the script"
		
		Continue?
		[N] No  [Y] Yes  [?] Help (default is "Y"): ?
		N - Abort the script
		Y - Continue the script
		
		[N] No  [Y] Yes  [?] Help (default is "Y"): Y
		
		True

	.EXAMPLE
		PS C:\> "Continue?" | Show-Prompt
		
		Continue?
		[N] No  [Y] Yes  [?] Help (default is "Y"): ?
		

	.INPUTS
		System.String

	.OUTPUTS
		System.Boolean

	.LINK
		www.Proxx.nl/Wiki/Show-Prompt

#>

	Param(
		[switch] $Yes,
		[string] $Title="",
		[Parameter(Position=0,ValueFromPipeline=$true)][string] $Message="",
		[string] $HelpYes="",
		[string] $HelpNo=""
	)
	
	Function SwitchYN($Object) {
		Switch($Object) {
			$true 	{ Return 1 }
			$false 	{ Return 0 } 
			1 		{ return $true }
			0 		{ return $false }
		}
	}
	$Y = New-Object System.Management.Automation.Host.ChoiceDescription("&Yes", $HelpYes)
	$N = New-Object System.Management.Automation.Host.ChoiceDescription("&No", $HelpNo)
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($N, $Y)
	$result = $host.ui.PromptForChoice($Title, $Message, $options, (SwitchYN($Yes)))
	Return SwitchYN($result)
}