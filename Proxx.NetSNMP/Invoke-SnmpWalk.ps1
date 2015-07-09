Function Invoke-SnmpWalk { 
	<#
		.SYNOPSIS
			Invoke-SnmpGet returnes a object with the results from snmp

		.DESCRIPTION
			Invoke-SnmpGet returnes a object with the results from snmp

		.PARAMETER  IpAddress
			This parameter contains the node address of the agent.

		.PARAMETER  OID
			this variable contains the OID (Object IDentifier)

		.EXAMPLE
			PS C:\> "192.168.1.100" | Invoke-SnmpWalk -OID 1.3.6.1.2.1.1 -WithinSubTree | ft -AutoSize

			Node         OID               Type        Value                                                                                  
			----         ---               ----        -----                                                                                  
			192.168.1.100 1.3.6.1.2.1.1.1.0 OctetString HP ETHERNET
			192.168.1.100 1.3.6.1.2.1.1.2.0 ObjectId    1.3.6.1.4.1.11.2.3.9.1                                                                 
			192.168.1.100 1.3.6.1.2.1.1.3.0 TimeTicks   9d 0h 11m 24s 730ms         

		.EXAMPLE
			PS C:\> "192.168.1.100", "192.168.1.104", "192.168.1.94" | Invoke-SnmpWalk -OID 1.3.6.1.2.1.1.1 -WithinSubTree | ft -AutoSize

			Node          OID               Type        Value                                                                                  
			----          ---               ----        -----                                                                                  
			192.168.1.100 1.3.6.1.2.1.1.1.0 OctetString HP ETHERNET
			192.168.1.104 1.3.6.1.2.1.1.1.0 OctetString SonicWALL NSA
			192.168.1.94  1.3.6.1.2.1.1.1.0 OctetString Digi Connect 

		.INPUTS
			System.String

		.OUTPUTS
			Object

		.LINK
			http://www.proxx.nl

	#>
	Param(
		[String]$Community = "public",
		[Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
		[Alias("Address","ComputerName","IP","Node")]
		[String[]]$IpAddress,
		[Parameter(Mandatory=$true, Position=1)]
		[String]$OID,
		[int] $Port=161,
		[int] $Retry =  1,
		[int] $TimeOut = 2000,
		[ValidateSet("1","2")]
		[String]$Version="2",
		[Switch]$WithinSubTree
	)
	
	Begin { 
		if ($WithinSubTree) { [SnmpSharpNet.Oid]$RootOID = $OID }

		$SimpleSnmp = New-Object -TypeName SnmpSharpNet.SimpleSnmp
		$SimpleSnmp.Community = $Community
		$SimpleSnmp.Retry = $Retry
		$SimpleSnmp.PeerPort = $Port
		$SimpleSnmp.Timeout = $TimeOut
		
		Switch($Version) {
			1 {$Ver = [SnmpSharpNet.SnmpVersion]::Ver1 }
			2 {$Ver = [SnmpSharpNet.SnmpVersion]::Ver2 }
			default {$Ver = [SnmpSharpNet.SnmpVersion]::Ver2 }
		}
	}
	Process {
		ForEach($Node in $IpAddress) {
			$LastOID = $OID
			$SimpleSnmp.PeerIP = $Node
			$SimpleSnmp.PeerName = $Node
			While($null -ne $LastOID) {
				$Response = $simplesnmp.GetNext($Ver,$LastOID)
				if ($Response) {
					if ($Response.Count -gt 0) {
						ForEach($var in $Response.GetEnumerator()) {
							$Object = [PSCustomObject] @{
								Node = $Node
								OID = $var.Key.ToString()
								Type = [snmpsharpnet.SnmpConstants]::GetTypeName($var.Value.Type)
								Value = $var.Value.ToString()
							}
							if ($WithinSubTree) {
								if ($RootOID.IsRootOf($var.Key)) { $LastOID = $var.Key.ToString() } Else { $LastOID = $null;Break }
							} Else { $LastOID = $var.Key.ToString() }
							Write-Output -InputObject $Object
						}
					} Else { $LastOID = $null } #end of MIB
				} Else { Write-Error -Message "Error: OID returned Null $LastOID"; $LastOID = $null }
			}
		}
	}
}