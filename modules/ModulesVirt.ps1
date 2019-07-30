<#
#---------------------------------------------------------------------------------------------------------------
TITRE : Module de virtualisation  CloudMe eXplorer
VERSION : 1.0
DATE CREATION : 06.06.2019

DESCRIPTION :
Fonctions liées à l'infrastructure virtuelle

LISTE DES FONCTIONS DE CE MODULE : 

 - Connect-CloudMe
 - Get-DatastoreProvisioned
 - Get-Inventaire ($type)
 - Get-Inventaire-VM
 - Get-Inventaire-ESX
 - Get-Inventaire-Datastore
 - Get-DatastoreProvisioning
 - Check-VMTools
 - Check-Centreon 
 - Check-Centreon-2

#---------------------------------------------------------------------------------------------------------------
#>

function Connect-CloudMe {
    #---------------------------------------------------------------------------------------------------------------
    # CONNECT-CLOUDME :
    # --------------- 
    #
    # [+] Description : Se connecte au serveur Cloudme.local défini dans le module de configuration
    #
    #---------------------------------------------------------------------------------------------------------------
    try {
        write-host ""
        Show-Messages "[+] $msg_connexion_vcenter" "soustitre" $false
        Connect-VIServer $vcx_server
        Show-Messages " |_[OK] $msg_connexion_vcenter_ok" "soustitre" $false
        }
    catch {        
        $messageErreur=$_.Exception.Message -replace "\(",""
        $messageErreur=$messageErreur -replace "\)",""
        $messageErreur=$messageErreur -replace "`n"," "
        $messageErreur=$messageErreur -replace ".*Cannot complete login due to an incorrect user name or password","$msg_erreur_mdp"
        $messageErreur=$messageErreur -replace "Connect-VIServer",""
        Show-Messages "Erreur:`n$messageErreur" "erreur" $true
        Show-Messages "[!] Astuce: - $msg_astuce_cloudme_connect_1" "message" $false
        Show-Messages "            - $msg_astuce_cloudme_connect_2" "message" $false
        }
    }


function Get-Inventaire ($type) {
    #---------------------------------------------------------------------------------------------------------------
    # GET-INVENTAIRE :
    # --------------- 
    #
    # [+] DESCRIPTION : 
    #
    # [+] ARGUMENTS : 
    #
    # [+] EXEMPLES :
    # 
    #
    #---------------------------------------------------------------------------------------------------------------

    $fichier_temp="./tmp_inventaire.log";
    switch ($type) {
        vm {
            $liste_complete_vm=Get-VM | Sort-Object GuestId | Sort-Object -Unique Name #|where {$_.PowerState -eq "PoweredOn" }|
            echo $liste_complete_vm|Format-Table -Property "Name", "MemoryGB", "NumCpu", "Powerstate", "VMHost", "GuestId" > $fichier_temp
            
            $nb_ligne=0
            ForEach ( $ligne in Get-Content ($fichier_temp) ) {
                $ligne=$ligne -replace "^ *$",""
                if ($ligne.length -gt 0) {
                    $nb_ligne++
                    if ($nb_ligne -le 2) {
                        #formattage des entetes
                        $ligne=$ligne -replace "Name ","Nom  "
                        $ligne=$ligne -replace "MemoryGB","Mem. Go "
                        $ligne=$ligne -replace "NumCpu","Nb_CPU "
                        $ligne=$ligne -replace "PowerState ","Etat       "
                        $ligne=$ligne -replace "GuestId ","  OS "
                        $ligne=$ligne -replace "VMHost ","ESX "
                        Show-Messages "  $ligne" "titre" $false
                        }#if
                    else  {
                        #formattage du nom des distributions
                        $ligne=$ligne -replace "server"," server "
                        $ligne=$ligne -replace "xLinux","x Linux"
                        $ligne=$ligne -replace "debian","Debian "
                        $ligne=$ligne -replace "centos","CentOS "
                        $ligne=$ligne -replace "windows","Windows "
                        $ligne=$ligne -replace "other","Autre OS "
                        $ligne=$ligne -replace "64Guest","[64bits]"
                        $ligne=$ligne -replace "32Guest","[32bits]"
                        $ligne=$ligne -replace "_"," "
                        
                        if ($ligne -match "PoweredOff") {
                            $ligne=$ligne -replace "PoweredOff"," Eteinte  "
                            Show-Messages "  $ligne" "aucun" $false
                            }
                        else  {
                            $ligne=$ligne -replace "PoweredOn","Allumée  "
                            Show-Messages "  $ligne" "soustitre" $false
                            }#else
                        }#else
                    }#if
                }#foreach
            rm $fichier_temp
            }
        esx {
            
            $liste_complete_esx=Get-View -ViewType HostSystem -Property Name,Config.Product
            echo $liste_complete_esx|Format-Table Name, @{L='ver_build';E={$_.Config.Product.FullName}}  > $fichier_temp
            
            $nb_ligne=0
            ForEach ( $ligne in Get-Content ($fichier_temp) ) {
                $ligne=$ligne -replace "^ *$",""
                if ($ligne.length -gt 0) {
                    $nb_ligne++
                    if ($nb_ligne -le 2) {
                        #formattage des entetes
                        $ligne=$ligne -replace "Name ","Nom  "
                        $ligne=$ligne -replace "ver_build","Version & Build des hôtes"
                        Show-Messages "  $ligne" "titre" $false
                        }#if
                    else  {   
                        Show-Messages "  $ligne" "soustitre" $false 
                        }#else
                    }#if
                }#foreach
            
            rm $fichier_temp
            }
        datastore {
            
            $liste_complete_ds=get-datastore
            echo $liste_complete_ds|Format-Table Name, Datacenter, State, Accessible, CapacityGB, FreeSpaceGB > $fichier_temp
           
            $nb_ligne=0
            ForEach ( $ligne in Get-Content ($fichier_temp) ) {
                $ligne=$ligne -replace "^ *$",""
                if ($ligne.length -gt 0) {
                    $nb_ligne++
                    if ($nb_ligne -le 2) {
                        #formattage des entetes
                        $ligne=$ligne -replace "Name ","Nom  "
                        $ligne=$ligne -replace "Datacenter     ","Datacenter "
                        $ligne=$ligne -replace "CapacityGB","Taille (Go)"
                        $ligne=$ligne -replace "FreeSpaceGB","Libre (Go) "
                        $ligne=$ligne -replace "State","Etat "
                        $ligne=$ligne -replace "----          ----------     ----- ---------- ----------    -----------","----          ---------- ----- ---------- ----------    -----------"
                        Show-Messages "  $ligne" "titre" $false
                        }#if
                    else  {   
                        $ligne=$ligne -replace "Available    ","Dispo."
                        $ligne=$ligne -replace "True","Oui"
                        Show-Messages "  $ligne" "soustitre" $false 
                        }#else
                    }#if
                }#foreach
            
            rm $fichier_temp            
            }
        }
}
function Get-Inventaire-VM {Get-Inventaire "vm" }
function Get-Inventaire-ESX {Get-Inventaire "esx" }
function Get-Inventaire-Datastore {Get-Inventaire "datastore" }
function Get-DatastoreProvisioned {
    #---------------------------------------------------------------------------------------------------------------
    # GET-DATASTORE-PROVISIONED :
    # --------------- 
    #
    # [+] Description : 
    #
    #---------------------------------------------------------------------------------------------------------------

    [CmdletBinding()]
    param (
        # nom du datastore a checker. 
        [Parameter(ValueFromPipeline = $true)]
        $Name
    )

    PROCESS {
        ForEach ($DS in $Name) {
            # Calculat de l'approvisionnement
            $Provisioned = ($DS.ExtensionData.Summary.Capacity -
                $DS.ExtensionData.Summary.FreeSpace +
                $DS.ExtensionData.Summary.Uncommitted) / 1GB

            # Affichage des resultats
            # arrondi a 2 decimales
            [PSCustomObject]@{
                Name           = $DS.Name
                FreeSpaceGB    = [math]::Round($DS.FreeSpaceGB, 2)
                CapacityGB     = [math]::Round($DS.CapacityGB, 2)
                ProvisionedGB  = [math]::Round($Provisioned, 2)
                UsedPct        = [math]::Round((($DS.CapacityGB - $DS.FreeSpaceGB) / $DS.CapacityGB) * 100, 2)
                ProvisionedPct = [math]::Round(($Provisioned / $DS.CapacityGB) * 100, 2)
            } #PSCustomObject
        } #ForEach
    } #PROCESS
}
function Get-DatastoreInfos {
    $fichier_temp="./tmp_inventaire.log";
    #Get-Datastore | Get-DatastoreProvisioned | Format-Table -AutoSize
    $provisionning=Get-Datastore | Get-DatastoreProvisioned | Format-Table -AutoSize > $fichier_temp
        
    $nb_ligne=0

    ForEach ( $ligne in Get-Content ($fichier_temp) ) {
        $ligne=$ligne -replace "^ *$",""
        if ($ligne.length -gt 0) {
            $nb_ligne++
            $ligne=$ligne -replace "Name ","Nom  "
            $ligne=$ligne -replace "FreeSpaceGB","Libre (Go) "
            $ligne=$ligne -replace "CapacityGB","Taille (Go) "
            $ligne=$ligne -replace "ProvisionedGB ","Prov.(Go) "
            $ligne=$ligne -replace "UsedPct ","Util. (%) "
            $ligne=$ligne -replace "ProvisionedPct ","Prov. (%) "
            if ($nb_ligne -le 2) {
                #formattage des entetes
                Show-Messages "  $ligne" "titre" $false
                }#if
            else  {                        
                show-Messages "  $ligne" "soustitre" $false
                }#else
            }#if
        }#foreach

    rm $fichier_temp
}

function Check-VMTools {
    #---------------------------------------------------------------------------------------------------------------
    # CHECK-VMTOOLS :
    # --------------- 
    #
    # [+] DESCRIPTION : 
    #
    # [+] ARGUMENTS : 
    #
    # [+] EXEMPLES :
    # 
    #
    #---------------------------------------------------------------------------------------------------------------
    $vms = Get-VM | where {$_.PowerState -eq "PoweredOn" -and $_.GuestId -match "Windows"}|Sort-Object -Unique
    $total=$vms.Count
    $compteur=0
 
    Show-Messages "$total VM Windows à verifier:`n" "titre" $true

    ForEach ($vm in $vms){
        $compteur=$compteur+1;
	    Show-Messages "[$compteur] $vm :" "soustitre" $false
	    $namespace = "root\CIMV2"
	    $componentPattern = "hcmon|vmci|vmdebug|vmhgfs|VMMEMCTL|vmmouse|vmrawdsk|vmxnet|vmx_svga"
	
        try {
            Get-WmiObject -class Win32_SystemDriver -computername $vm -namespace $namespace | where-object { $_.Name -match $componentPattern } | Format-Table -Auto Name,State,StartMode,DisplayName
            }

        catch {
            $messageErreur=$_.Exception.Message -replace "\(",""
            $messageErreur=$messageErreur -replace "\)",""
            $messageErreur=$messageErreur -replace "Exception de HRESULT","`n             - $msg_erreur_code"
            Show-Messages "Erreur:  - $messageErreur" "erreur" $true
            Show-Messages "Astuce:  - $msg_astuce_vmtools_1 $vm`n" "warning" $true
            #break;
            }

    } #ForEach
    #Write-host "Fin des traitemens."

}

function Check-Centreon {

    $resultat_test_connexion=".\test_connexion.log"
    
    #Set-Header $msg_section_en_dev $col_warning $fnd_warning

    try {
        Show-Messages "$msg_connexion_centreon :" "titre" $true
        
        Test-NetConnection -ComputerName $vcn_centreon_ip > $resultat_test_connexion
        #Test-NetConnection -ComputerName $vcn_centreon_name > $resultat_test_connexion

        foreach ($ligne in get-content ($resultat_test_connexion) ) {
            if ($ligne.length -gt 0){
                $ligne=$ligne -replace "ComputerName  ","Nom de machine"
                $ligne=$ligne -replace "RemoteAddress","IP Centreon  "
                $ligne=$ligne -replace "InterfaceAlias","Carte réseau  "
                $ligne=$ligne -replace "SourceAddress      ","IP $cmx_titre"
                $ligne=$ligne -replace "PingSucceeded   ","Résultat du Ping"
                $ligne=$ligne -replace "True","Oui!"
                $ligne=$ligne -replace "False","Non! "
                $ligne=$ligne -replace "PingReplyDetails","Délai de réponse"
                Show-Messages " |_[i] $ligne" "soustitre" $false
                if ($ligne -match "Non!") {
                    $probleme_centreon=$true
                    }
                if ($ligne -match "Oui!")  {
                    $probleme_centreon=$false
                    }
                }#if
            }#foreach
            
        if ($probleme_centreon) {
            Show-Messages " |_[X] $msg_erreur_connexion_centreon" "erreur" $false
            Show-Messages " |_[!] $msg_astuce_centreon" "warning" $false
            }
        else {
            Show-Messages " |_[OK] $msg_connexion_centreon_ok" "ok" $false
            }
        }#try
    catch {
        $messageErreur=$_.Exception.Message -replace "\(",""
        $messageErreur=$messageErreur -replace "\)",""
        $messageErreur=$messageErreur -replace "Exception de HRESULT","`n             - Code erreur"
        Show-Messages "      |_[X] Erreur:  - $messageErreur" "erreur" $true
        Show-Messages "      |_[X] Astuce:  - $msg_astuce_connexion" "warning" $true
        }#catch
    rm $resultat_test_connexion
}

function Check-Centreon-2 {

    $resultat_ping=".\temp.log"
    
    Set-Header $msg_section_en_dev $col_warning $fnd_warning

    #requete ping 
    ping -n 1 $vcn_centreon_ip > $resultat_ping

    $numero=0
    ForEach ($ligne in Get-Content $resultat_ping) {
        $numero++
        if ($numero -le 2){
            Show-Messages "$ligne" "titre" $false
            }
        else {
            Show-Messages "$ligne" "soustitre" $false
            }
        }

    rm $resultat_ping
    
}