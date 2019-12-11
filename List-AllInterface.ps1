function List-AllInterface {
    <#
        .SYNOPSIS
           Obtem informação das placas de rede.
    #>
    $server_name = $(Get-ItemProperty -Path HKLM:\SYSTEM\ControlSet001\Services\Tcpip\Parameters).hostname
    $server_domain = $(Get-ItemProperty -Path HKLM:\SYSTEM\ControlSet001\Services\Tcpip\Parameters).domain

    $net_adapter = @{ }
    Get-NetAdapter | ForEach-Object {
        $net_adapter[[int]$_.ifIndex] = $_
    }

    $net_ipaddress = @{ }
    Get-NetIPAddress | ForEach-Object {
        $net_ipaddress[[int]$_.ifIndex] = $_
    } 

    $interface_List = Get-NetIPInterface | Where-Object { ($_.AddressFamily -eq "IPv4") -and ($_.InterfaceAlias -notmatch "Loopback") } | Select-Object @{N = "Hostname"; E = { $server_name } },
    @{N = "Domain"; E = { $server_domain } },
    @{Name = "Name"; Expression = { $net_adapter[[int]$_.ifIndex].Name } },
    @{Name = "IPAddress"; Expression = { $net_ipaddress[[int]$_.ifIndex].IPAddress } },
    @{Name = "InterfaceDescription"; Expression = { $net_adapter[[int]$_.ifIndex].InterfaceDescription } },
    @{Name = "DriverProvider"; Expression = { $net_adapter[[int]$_.ifIndex].DriverProvider } },
    @{Name = "DriverVersion"; Expression = { $net_adapter[[int]$_.ifIndex].DriverVersion } },
    @{Name = "LinkSpeed"; Expression = { $net_adapter[[int]$_.ifIndex].LinkSpeed } },
    @{Name = "MacAddress"; Expression = { $net_adapter[[int]$_.ifIndex].MacAddress } },
    InterfaceIndex,
    InterfaceAlias,
    Dhcp,
    ConnectionState,
    NlMtu 
    $interface_List = $interface_List | Where-Object { ($_.InterfaceDescription -notmatch "Loopback" ) }
    $info_out = [pscustomobject]@{
        "Interfaces" = $interface_List
    }
    return $info_out
}

$interface_List = List-AllInterface
$interface_List.Interfaces