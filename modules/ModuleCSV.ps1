<#
---------------------------------------------------------------------------------------------------------------
TITRE : Module de fonctions CSV
VERSION : 1.0
DATE CREATION : 20.06.2019

DESCRIPTION :
Liste de fonctions de traitement CSV

LISTE DES FONCTIONS DE CE MODULE : 
 - function Show-Saisie-Fichier-CSV ($type)
 - Check-Entetes-CSV ($entetes, $type)
 - Apercu-CSV ($fichier_csv, $type)
 - Import-VM-From-CSV
 - Import-VM-From-CSV-Basic ($fichier, $total)
 - Import-VM-From-CSV-Template ($fichier, $total)

---------------------------------------------------------------------------------------------------------------
#>

function Show-Saisie-Fichier-CSV ($type)  {    

    do {
        $fichier=Ask-Messages "[+] Saisissez le chemin complet vers votre fichier (laissez vide pour annuler):" $col_titre $fnd_titre
        
        if ($fichier.length -gt 0) {
            $fichier_existe=$(Test-Path "$fichier")
            }
        else {
            $fichier_existe=$false
            $fichier=$false
            break
            }

        If ($fichier_existe -eq $true) {
            Show-Messages " |_[Le fichier existe!]" "soustitre" $false
            
            Show-Messages "`n[+] Verification des entetes du CSV :" "titre" $false
            Foreach ( $ligne1 in Get-Content ($fichier) ) {$entetes=$ligne1 ;break;}#que la 1ere ligne
            $check_entetes=Check-Entetes-CSV $entetes $type
            If ($check_entetes -eq $true) {
                $fichier_ok=$true
                Show-Messages " |_[OK!] Bon type de CSV, on peut continuer!" "soustitre" $false
                }
            else{
                $fichier_ok=$false
                write-host " |_[X] Mauvais format de CSV, saisissez en un autre ou verifiez son contenu`n" -ForegroundColor "red"
                }
            }
        else{
            Run-Commande-Mauvais-Choix-Fichier $fichier
            $fichier_ok=$false
            }
        } while ( $fichier_ok -eq $false)
    return $fichier
        
    } #fucntion

function Check-Entetes-CSV ($entetes, $type)  {
    
    switch ($type){
        basic {
            if ($entetes -eq $entete_csv_basic) {
                $retour=$true
                }
            }
        template {
            if ($entetes -eq $entete_csv_template) {
                $retour=$true
                }
            }
        default {
            $retour=$false
            }
        }#switch
    return $retour
    }#function

function Apercu-CSV ($fichier_csv, $type)  {
    $fichier_tmp=".\apercu_csv.txt"
    $apercu_csv=Import-CSV $fichier_csv
    echo $apercu_csv|Format-Table > $fichier_tmp
    
    $numero=0
    $total_a_importer=0
    $total_ignorees=0
    $total_mem=0
    $total_cpu=0
    $total_hdd=0
    ForEach ($ligne in Get-Content $fichier_tmp) {
        #$ligne=$ligne -replace " ",""
        if ( $ligne.length -gt 0 ) {
            $numero++
            #on affiche pas les lignes vides
            switch ($numero) {#les 2 premieres lignes en gras
                1 {show-messages "`n n°  $ligne" "titre" $false}
                2 {show-messages " --  $ligne" "titre" $false}
                default {
                        $premier_caractere_ligne="$ligne".Substring(0,1)
                        if ( "$premier_caractere_ligne" -ne "#" ) {
                            $total_a_importer++
                            
                            if ($type -eq "basic") {
                                $ligne_format_array=$ligne
                                while ( $ligne_format_array -match "  ") {
                                    $ligne_format_array=$ligne_format_array -replace "  "," "
                                    }
                                $ligne_format_array=$ligne_format_array.split(" ")    
                            
                                $mem=$ligne_format_array[2];if ($ligne_format_array[2] -notmatch "^\d+$") {$mem=0}
                                $cpu=$ligne_format_array[3];if ($ligne_format_array[3] -notmatch "^\d+$") {$cpu=0}
                                $hddc=$ligne_format_array[4];if ($ligne_format_array[4] -notmatch "^\d+$") {$hddc=0}
                                $hddd=$ligne_format_array[5];if ($ligne_format_array[5] -notmatch "^\d+$") {$hddd=0}
                                $hdd=$([int]$hddc+[int]$hddd)

                                $total_mem=$total_mem+$mem
                                $total_cpu=$total_cpu+$cpu
                                $total_hdd=$total_hdd+$hdd
                                }
                            show-messages " [$($total_a_importer)] $ligne " "soustitre" $false
                            }
                        else {
                            $total_ignorees++
                            $ligne=$ligne -replace "^#","*"
                            show-messages " [X] $ligne (*)" "aucun" $false
                            }
                    }
                }
            }#if length
        }#foreach
    write-host "`n[+] Nombre de VM qui vont être importées   : " -BackgroundColor $fnd_titre -ForegroundColor $col_titre -NoNewline
    show-messages "$total_a_importer " "soustitre" $false
    if ("$type" -match "basic") {
        show-messages " |_$p_info Memoire totale  = $total_mem" "soustitre" $false
        show-messages " |_$p_info CPU total       = $total_cpu" "soustitre" $false
        show-messages " |_$p_info HDD (C+D) total = $total_hdd" "soustitre" $false
        }
    write-host "`n[+] Nombre de VM ignorées (*) : " -BackgroundColor $fnd_titre -ForegroundColor $col_titre -NoNewline
    show-messages "$total_ignorees" "soustitre" $false
    rm $fichier_tmp
    return $total_a_importer
    }#function

function Import-VM-From-CSV  {
    
    #en dev!!!!
    Set-Header $msg_section_en_dev $col_warning $fnd_warning    
    
    show-messages "`n[1] Import basique :" "titre" $false
    show-messages " |_[*] Structure CSV :" "soustitre" $false
    show-messages "       $entete_csv_basic" "aucun" $false
    
    show-messages "`n[2] Import par template :" "titre" $false
    show-messages " |_[*] Structure CSV :" "soustitre" $false
    show-messages "       $entete_csv_template" "aucun" $false
    
    show-messages "`n[3] Annuler" "titre" $false
    
    do {
        $choix_utilisateur=$(Ask-Messages "`n[+] Quel type d'import ? " $col_titre $fnd_titre) 

        $index=$(Check-Choix-Import $choix_utilisateur)
        
        if ($index -eq -1) {
            $mauvais_choix=$true
            $index=$lien_par_defaut
            }
        else {
            $mauvais_choix=$false
            }
     
        if ($mauvais_choix) {
            Run-Commande-Mauvais-Choix-Import ($choix_utilisateur)
            }     

    }while ($mauvais_choix -eq $true)


    switch ($choix_utilisateur) {
        1 { #import basique
            show-messages " |_[Import basique]`n" "soustitre" $false

            $fichier_csv=Show-Saisie-Fichier-CSV "basic"
            if ($fichier_csv -eq $false) {
                show-messages " |_[$msg_deploy_annuler]" "soustitre" $false 
                break
                }
            else {
                #Apercu-CSV
                show-messages "`n$msg_deploy_apercu_csv"":" "titre" $true
                $total_a_importer=Apercu-CSV $fichier_csv "basic"
                }
            #confirmation
            show-messages "Confirmation:" "titre" $true
            $confirmation=$(Ask-OuiNon " |_[!] $msg_deploy_confirmation" $col_warning "Black")

            if ($confirmation -eq $true){
                Import-VM-From-CSV-Basic $fichier_csv $total_a_importer
                }#if
             else { #Annuler 
                show-messages " |_[$msg_deploy_annuler]" "soustitre" $false 
                }
            
            }
        2 { #import par template
            show-messages " |_[Import par template]`n" "soustitre" $false

            $fichier_csv=Show-Saisie-Fichier-CSV "template"
            if ($fichier_csv -eq $false) {
                show-messages " |_[$msg_deploy_annuler]" "soustitre" $false 
                break
                }
            else {
                #Apercu-CSV
                show-messages "$msg_deploy_apercu_csv"":" "titre" $true
                $total_a_importer=Apercu-CSV $fichier_csv "template"
                }
            #confirmation
            show-messages "Confirmation:" "titre" $true
            $confirmation=$(Ask-OuiNon " |_[!] $msg_deploy_confirmation" $col_warning "Black")
            
            if ($confirmation -eq $true){
                Import-VM-From-CSV-Template $fichier_csv $total_a_importer
                }#if
             else { #Annuler 
                show-messages " |_[$msg_deploy_annuler]" "soustitre" $false 
                }
            
            }
        default { #Annuler 
            show-messages " |_[$msg_deploy_annuler]" "soustitre" $false 
            }
        }#switch
    
}

function Import-VM-From-CSV-Basic ($fichier, $total) {
    
    Set-Header "`n..............................$msg_deploy_go.............................." $col_warning "Black"

    #top depart!
    show-messages "Traitement lancé :" "titre" $true
    show-messages " |_[$(date)]" "soustitre" $false
    
    show-messages "Liste des VM :" "titre" $true
    $numero_vm=0
    foreach($csv_ligne in (Import-Csv -Path $fichier)){
        $new_vm_nom=$csv_ligne.Nom
        $new_vm_ds=$csv_ligne.Datastore
        $new_vm_vhost=$csv_ligne.vhost
        $new_vm_mem=$csv_ligne.Memoire_Go
        $new_vm_cpu=$csv_ligne.Nb_CPU
        $new_vm_hddc=$csv_ligne.Hdd_C_Go
        $new_vm_hddd=$csv_ligne.Hdd_C_Go
        $new_vm_lan=$csv_ligne.LAN
        $new_vm_ip=$csv_ligne.IP
        $new_vm_gw=$csv_ligne.Passerelle
        $new_vm_dns1=$csv_ligne.DNS1
        $new_vm_dns2=$csv_ligne.DNS2
        

        $premier_caractere_ligne="$new_vm_nom".Substring(0,1)

        if ( "$premier_caractere_ligne" -ne "#" ) {
            $numero_vm++
            if ($numero_vm -lt $total) {
                $arbo=" |  |_"
                }
            else {
                $arbo="    |_"
                }
                
            show-messages " |_[$numero_vm] $new_vm_nom" "soustitre" $false
            show-messages "$arbo$p_infos Memoire (Go): $new_vm_mem " "soustitre" $false
            show-messages "$arbo$p_infos Datastore : $new_vm_ds " "soustitre" $false
            show-messages "$arbo$p_infos VHost : $new_vm_vhost " "soustitre" $false
            show-messages "$arbo$p_infos Nb. CPU : $new_vm_cpu " "soustitre" $false
            show-messages "$arbo$p_infos HDD C : $new_vm_hddc " "soustitre" $false
            show-messages "$arbo$p_infos HDD D : $new_vm_hddd " "soustitre" $false
            show-messages "$arbo$p_infos LAN : $new_vm_lan " "soustitre" $false
            show-messages "$arbo$p_infos IP : $new_vm_ip " "soustitre" $false
            show-messages "$arbo$p_infos PAsserelle : $new_vm_gw " "soustitre" $false
            show-messages "$arbo$p_infos DNS 1 : $new_vm_dns1 " "soustitre" $false
            show-messages "$arbo$p_infos DNS 2 : $new_vm_dns2 " "soustitre" $false

            # creer la VM
            show-messages "Creation des VM :" "titre" $true
            show-messages " |_[-] Creation... " "soustitre" $false
            try {
                #$clusterDatastore = Get-DatastoreCluster -Name MyStorageCluster1
                #$advancedOptions = New-Object 'VMware.VimAutomation.ViCore.Types.V1.DatastoreManagement.SdrsVMDiskAntiAffinityRule' 1,2
                $request_creation=$( New-VM -Name $new_vm_nom -Datastore $new_vm_ds –VMHost $new_vm_vhost -DiskGB $new_vm_hddc -MemoryGB $new_vm_mem -NumCpu $new_vm_cpu -NetworkName $new_vm_lan ) # -advancedOption $advancedOptions –VMHost 'VMHost-1' ou -ResourcePool 'ResourcePool'
                
                show-messages " |_[OK] VM new_vm_nom créée : $request_creation" "soustitre" $false

                show-messages "Démarrage de la VM :" "titre" $true
                $demarrerVm=Ask-OuiNon " -\[-] Voulez-vous démarrer la VM?`n " $col_soustitre $fnd_soustitre
                if ($demarrerVm) {
                    show-messages "Démarrage de la VM $new_vm_nom :" "titre" $true
                    show-messages " |_[-] Attente... " "soustitre" $false
                    $request_demarrage=$( Start-VM -vm $new_vm_nom)
                    show-messages " |_[OK] VM démarrée : $request_demarrage " "soustitre" $false                     
                    }
                }
            catch {
                $msgerreur=$($_.exception.message)
                show-messages "Impossible de créer la VM !" "erreur" $true
                show-messages " |_[!] $msgerreur" "erreur" $false 
                }
            
            

            }#if

    }#foreach

    #top fin!
    show-messages "Traitement fini :" "titre" $true
    show-messages " |_[$(date)]" "soustitre" $false
}

function Import-VM-From-CSV-Template ($fichier, $total) {

    
    Set-Header "`n..............................$msg_deploy_go.............................." $col_warning "Black"

    #top depart!
    show-messages "Traitement lancé :" "titre" $true
    show-messages " |_[$(date)]" "soustitre" $false
    
    show-messages "Liste des VM :" "titre" $true
    $numero_vm=0
    foreach($csv_ligne in (Import-Csv -Path $fichier)){
        
        $new_vm_nom=$($csv_ligne.Nom)
        $new_vm_esx=$csv_ligne.ESX
        $new_vm_datastore=$csv_ligne.Datastore
        $new_vm_template=$csv_ligne.Template
        $new_vm_lan=$csv_ligne.LAN
        $new_vm_ip=$csv_ligne.IP
        $new_vm_gw=$csv_ligne.Passerelle
        $new_vm_dns1=$csv_ligne.DNS1
        $new_vm_dns2=$csv_ligne.DNS2

        $premier_caractere_ligne="$new_vm_nom".Substring(0,1)

        if ( "$premier_caractere_ligne" -ne "#" ) {

            $numero_vm++
            if ($numero_vm -lt $total) {
                $arbo=" |  |_"
                }
            else {
                $arbo="    |_"
                }
        
            show-messages " |_[$numero_vm] NOM VM : $new_vm_nom" "soustitre" $false
            show-messages "$arbo$p_infos ESX : $new_vm_esx " "soustitre" $false
            show-messages "$arbo$p_infos Datastore : $new_vm_datastore " "soustitre" $false
            show-messages "$arbo$p_infos Template : $new_vm_template " "soustitre" $false
            show-messages "$arbo$p_infos LAN : $new_vm_lan " "soustitre" $false
            show-messages "$arbo$p_infos IP : $new_vm_ip " "soustitre" $false
            show-messages "$arbo$p_infos PAsserelle : $new_vm_gw " "soustitre" $false
            show-messages "$arbo$p_infos DNS 1 : $new_vm_dns1 " "soustitre" $false
            show-messages "$arbo$p_infos DNS 2 : $new_vm_dns2 " "soustitre" $false

            # creer la VM
            #$new_vm = New-VM -Name $new_vm_nom -VMHost $new_vm_esx -Datastore $new_vm_datastore -Template $new_vm_template
            #Get-NetworkAdapter -VM $new_vm | Set-NetworkAdapter -NetworkName $new_vm_lan -StartConnected

            # demarrer la VM
            #Start-VM -VM $vm
    
            # attendre le lancement de la VM
            #while($vm.Guest.State -ne 'running'){
            #    $vm = Get-VM -Name $vm.Name
            #    sleep 5
            #}

            # Configurer le reseau
            #ip:
            #$netsh = "c:\windows\system32\netsh.exe interface ip set address ""Local Area Connection"" static $($vmLine.IPAddress) $($vmLine.NetMask) $($vmLine.Gateway) 1"
            #Invoke-VMScript -VM $VM -ScriptType bat -ScriptText $netsh
            #dns:
            #$netsh = "c:\windows\system32\netsh.exe interface ip set dns ""Local Area Connection"" static $($vmLine.FirstDNS) $($vmLine.SecondDns)"
            #Invoke-VMScript -VM $VM -ScriptType bat -ScriptText $netsh


        }#if

    }#foreach

    #top fin!
    show-messages "Traitement fini :" "titre" $true
    show-messages " |_[$(date)]" "soustitre" $false

}