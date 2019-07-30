<#
---------------------------------------------------------------------------------------------------------------
TITRE : Module de fonctions externes 
VERSION : 1.0
DATE CREATION : 20.06.2019

DESCRIPTION :


LISTE DES FONCTIONS DE CE MODULE : 

 - Configure-NTP 
 - Configure-SSH
 - Configure-DNS

---------------------------------------------------------------------------------------------------------------
#>


function Configure-NTP {

    $vms = Get-VM | where {$_.PowerState -eq "PoweredOn" -and $_.GuestId -match "Windows"}|Sort-Object -Unique
    #$vms = Get-VM | where {$_.PowerState -eq "PoweredOn" }|Sort-Object -Unique
    $total=$vms.Count
    $compteur=0
 
    Show-Messages "Statut service NTP pour $total VM :" "titre" $true

    ForEach ($vm in $vms){
        $compteur=$compteur+1;
	    Show-Messages "`n[$compteur] $vm :" "titre" $false
	    Write-host " |_[-] Serveur NTP: " -BackgroundColor $fnd_soustitre -ForegroundColor $col_soustitre -NoNewline
            
        try {
            w32tm /query /computer:$vm /source        
            }
        catch {
            $messageErreur=$_.Exception.Message -replace "\(",""
            $messageErreur=$messageErreur -replace "\)",""
            $messageErreur=$messageErreur -replace "Exception de HRESULT","`n             - Code erreur"
            Show-Messages "Erreur:  - $messageErreur" "erreur" $true
            Show-Messages "Astuce:  - $msg_astuce_ntp" "warning" $true
            }
        }#foreach

    Set-Header $msg_section_en_dev $col_warning $fnd_warning
}

function Disable-SSH-ESX {

    $fichier_temp="./tmp_sshoff.log";
    $ligne=0    
    $compteur=0    
    #debug
    Get-View -ViewType HostSystem -Property Name|format-table -property Name > $fichier_temp

    Show-Messages "Désactivation du SSH sur les ESX :" "titre" $true
    
    ForEach ($esx in Get-Content ($fichier_temp)){
        $ligne++
        if ( ($esx.length -gt 0) -and ($ligne -gt 3) ) {
            $compteur++
            Show-Messages "`n[$compteur] $esx :" "titre" $false
	        Write-host " |_[-] Désactivation du service SSH: " -BackgroundColor $fnd_soustitre -ForegroundColor $col_soustitre 
        
            try {
                $req_status=get-VMHostService -VMHost $esx | where-object Key -eq 'TSM-SSH' | Stop-VMHostService -Confirm:$false
	            Write-host " |_[OK] Service SSH désactivé " -BackgroundColor $fnd_soustitre -ForegroundColor $col_soustitre 
                }
            catch {
                $messageErreur=$_.Exception.Message -replace "\(",""
                $messageErreur=$messageErreur -replace "\)",""
                $messageErreur=$messageErreur -replace "Exception de HRESULT","`n             - Code erreur"
                #Show-Messages "      |_[X] Erreur:  - $messageErreur" "erreur" $true
                #Show-Messages "      |_[X] Astuce:  - $msg_astuce_ssh" "warning" $true
                }
            }#if
        }#foreach

    #Résumé
    Check-SSH-2
    rm $fichier_temp

}
function Check-SSH {

    <#
    Test-NetConnection
    [[-ComputerName] <String>]
    [-TraceRoute]
    [-Hops <Int32>]
    [-InformationLevel <String>]
    [<CommonParameters>]
    #>
    

    $vms = Get-VM | where {$_.PowerState -eq "PoweredOn" }|Sort-Object -Unique
    $total=$vms.Count
    $compteur=0
 
    Show-Messages "$total VM à verifier :" "titre" $true

    ForEach ($vm in $vms){
        $compteur=$compteur+1;
	    Show-Messages "`n[$compteur] $vm :" "titre" $false
	    Write-host " |_[-] Test du service SSH: " -BackgroundColor $fnd_soustitre -ForegroundColor $col_soustitre 
        
        try {
            $fichier_temp="./tmp_cssh.log";
            Test-NetConnection -ComputerName "$vm.$lan_domain_name" -Port 22 2>&1 | format-list -property RemoteAddress, PingSucceeded, TcpTestSucceeded 2>&1  >$fichier_temp
            $nb_ligne=0

            ForEach ( $ligne in Get-Content ($fichier_temp) ) {
                $ligne=$ligne -replace "^ *$",""
                if ($ligne.length -gt 0) {
                    $nb_ligne++
                    #formattage des entetes
                    $ligne=$ligne -replace "RemoteAddress ","IP  "
                    $ligne=$ligne -replace "PingSucceeded","Ping réussi "
                    $ligne=$ligne -replace "TcpTestSucceeded","SSH activé "
                    $ligne=$ligne -replace "AVERTISSEMENT : .*",""
                    $ligne=$ligne -replace "True","Oui " 
                    $ligne=$ligne -replace "False","Non "       
                    show-Messages " |_[-] $ligne" "soustitre" $false
                    }#if
                }#foreach

            rm $fichier_temp
            }
        catch {
            $messageErreur=$_.Exception.Message -replace "\(",""
            #$messageErreur=$messageErreur -replace "\)",""
            #$messageErreur=$messageErreur -replace "Exception de HRESULT","`n             - Code erreur"
            #Show-Messages "      |_[X] Erreur:  - $messageErreur" "erreur" $true
            #Show-Messages "      |_[X] Astuce:  - $msg_astuce_ssh" "warning" $true
            }
        }#foreach

    Set-Header $msg_section_en_dev $col_warning $fnd_warning

}

function Check-SSH-2 {

    $fichier_temp="./tmp_cssh2.log";
    $ligne=0    
    $compteur=0
     
    Write-host "" 
    Get-View -ViewType HostSystem -Property Name| get-VMHostService -VMHost {$_.Name}| where-object Key -eq 'TSM-SSH'|format-table VMHost, Policy > $fichier_temp
    ForEach ($lignetexte in Get-Content ($fichier_temp)){
         if ( $lignetexte.length -gt 0) {
            $compteur++
            if ($compteur -le 2 ) {
                $lignetexte=$lignetexte -replace "VMHost","ESX   "
                $lignetexte=$lignetexte -replace "Policy","SSH   "
                Show-Messages $lignetexte "titre" $false    
                }#if
            else {
                $lignetexte=$lignetexte -replace "Off","Désactivé"
                $lignetexte=$lignetexte -replace "On","Activé"
                Show-Messages $lignetexte "soustitre" $false    
                }#if
            }#if
        }#foreach
    rm  $fichier_temp
}

function Configure-DNS {

    Set-Header $msg_section_en_dev $col_warning $fnd_warning

}