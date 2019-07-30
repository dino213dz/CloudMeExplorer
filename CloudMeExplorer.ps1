#-------------------------------------------------- Récuperation des arguments -------------------------------------------------- 
 [CmdletBinding()] 
 param(
   [Parameter(Mandatory=$false)]
  $output,$sortie,$fichier,$file,
  
  [switch] $help,[switch] $aide,[switch] $h,            #commande
  [switch] $deployer,[switch] $deploy,[switch] $d,      #commande
  [switch] $vm,                                    #parametre
  [switch] $basic,[switch] $basique,               #parametre
  [switch] $template,                              #parametre
  [switch] $configuration,[switch] $config,[switch] $c, #commande
  [switch] $ntp,                                   #parametre
  [switch] $dns,                                   #parametre
  [switch] $inventaire,[switch] $inventory,[switch] $i, #commande
  [switch] $esx,                                   #parametre
  [switch] $datastore,[switch] $ds,                #parametre
  [switch] $check,[switch] $verify,[switch] $t,        #commande
  [switch] $vmtools,[switch] $vmtool,              #parametre
  [switch] $centreon                               #parametre

 )

#------------------------------------ CONFIGURATION DE L'ENVIRONNEMENT -------------------------------------- 
#variables
$ErrorActionPreference="Stop"
$prefBackup=$WarningPreference
$WarningPreference='SilentlyContinue'

$cmx_fichier_configuration="modules\Configuration.ps1"

$c_msg="Cyan";$c_fmsg="Black";$c_tit="Cyan"
$e_msg="Red";$e_fmsg="DarkRed"
$h_msg="Yellow";$h_fmsg="Black"

#--------------------arguments : traitement ----------------------------------

# si false: mode verbeux, sinon silent
$mode_cmdline=($help -or $aide -or $h) -or ($check -or $verify -or $t) -or ($inventaire -or $inventory -or $i) -or ($configuration -or $config -or $c) -or ($deploy -or $deployer -or $d)

#DEBUG
#write-host "help= $help aide=$aide h=$h `ndeployer=$deployer deploy=$deploy `nvm=$vm `nbasic=$basic basique=$basique `nmode_cmdline=$mode_cmdline" -ForegroundColor Yellow ;$pause=read-host

#affiche l'aide et quitte le programme
if ($help -or $aide -or $h){

    try {
         . ("modules\ModulesAide.ps1")
         Show-Help-Params ""
        }
    catch {
        #erreur de chargement des modules...
        $cmdname="CloudmeExplorer.ps1"
        Write-Host "Aide "
        Write-Host " `nCOMMANDE:"
        Write-Host "`t$cmdname :`t si aucun parametre n'est précisé le mode interactif avec interface utilisateur est lancé. "
        Write-Host "`t$cmdname [OPTIONS] :`t Si un parametre est précisé, le script est lancé en Mode ligne de commande. utilisé pour etre lancé par d'autres scripts par exemple"
        Write-Host " `nOPTIONS:"
        Write-Host "`t -h -help -aide : Afficher l'aide"
        Write-Host ""
        Write-Host "`t -d -deploy -deployer : Deployer une ou plusieurs VM"
        Write-Host "`t -vm : parametre obligatoire si -deploy est utilisé"
        Write-Host "`t -basique|-template : parametre obligatoire si -vm est utilisé"
        Write-Host ""
        Write-Host "`t -c -config -configuration : Configuration"
        Write-Host "`t -ntp|-ssh|-dns : parametre obligatoire si -config est utilisé"
        Write-Host "`n"
        Write-Host "`t -i -inventaire -inventory: Faire l'inventaire de vos péripheriques"
        Write-Host "`t -vm|-esx|-ds : parametre obligatoire si -inventory est utilisé"
        Write-Host ""
        Write-Host "`t -t -check -verify: Faire des verifications"
        Write-Host "`t -vmtools|-centreon : parametre obligatoire si -check est utilisé"
        
        Write-Host " `nEXEMPLES:"
        Write-Host "`t Deploiement : "
        Write-Host "`t`t $cmdname -deploy -vm -basic -file .\templates\VM_basic.csv"
        Write-Host "`t`t $cmdname -deploy -vm -template -file .\templates\VM_by_templates.csv"
    
        Write-Host "`t Inventaire : "
        Write-Host "`t`t $cmdname -inventory -vm "

        Write-Host "`t Vérifications : " 
        Write-Host "`t`t $cmdname -check -vmtools"
        Write-Host "`t`t $cmdname -check -centreon"
        Write-Host "`n`n"
    }#catch
    exit
}#if
#------------------------------------------------------------------------------*

#-------------------------------------CHARGEMENT DU FICHIER DE CONFIGURATION --------------------------------
if (!$mode_cmdline) {Write-Host "`n[+] Chargement du fichier de configuration..." -BackgroundColor $c_fmsg -ForegroundColor $c_tit}
try {
    #chargement.....
    . ("$cmx_fichier_configuration")
    if (!$mode_cmdline) {Write-Host " |_[OK] Configuration chargée!" -BackgroundColor $c_fmsg -ForegroundColor $c_msg}
}
catch {
    #erreur de chargement fichier config...
    Write-Host " |_[!] Impossible de charger le fichier de configuration!" -BackgroundColor $e_fmsg -ForegroundColor $e_msg
    Write-Host " |_[!] Arret du script" -BackgroundColor $e_fmsg -ForegroundColor $e_msg
    #Astuces de resolution
    Write-Host "[+] Troubleshooting: " -BackgroundColor "DarkYellow" -ForegroundColor $h_msg
    Write-Host " |_[1] Verifiez la présence du fichier de configuration : $fichier_configuration" -BackgroundColor $h_fmsg -ForegroundColor $h_msg
    exit
}

#---------------------------------------- CHARGEMENT DES MODULES -------------------------------------------- 
if (!$mode_cmdline) {Write-Host "`n[+] $msg_chargement_modules" -BackgroundColor $c_fmsg -ForegroundColor $c_tit}
try {
    #chargement.....
    ForEAch ($module in $liste_modules) {
        if (!$mode_cmdline) {Write-Host " |_[-] $msg_chargement_module $module..." -BackgroundColor $c_fmsg -ForegroundColor $c_msg}
        . ("$cmx_dossierModules\$module")
        }
    #debug: read-host
    if (!$mode_cmdline) {Write-Host " |_[OK] $msg_chargement_modules_ok" -BackgroundColor $c_fmsg -ForegroundColor $c_msg}
}
catch {
    #erreur de chargement des modules...
    Write-Host " |_[!] $msg_chargement_modules_erreur" -BackgroundColor $e_fmsg -ForegroundColor $e_msg
    Write-Host " |_[!] $msg_erreur_arret_script" -BackgroundColor $e_fmsg -ForegroundColor $e_msg
    Write-Host "`n`n"
    #Astuces de resolution
    Write-Host "[+] $msg_troubleshooting : " -BackgroundColor "DarkYellow" -ForegroundColor $h_msg
    Write-Host " |_[1] $msg_astuce_chargement_modules_1" -BackgroundColor "Black" -ForegroundColor $h_msg
    Write-Host " |_[2] $msg_astuce_chargement_modules_2" -BackgroundColor $h_fmsg -ForegroundColor $h_msg
    Write-Host "`n`n"
    exit
}


#------------------------------------------------------------------------------*
## test de la connexionau Vcenter
try{
    get-vm > .\tmp.log
    }#try
catch {
    try{
        #Connect-CloudMe
        write-host "`n[+] $msg_connexion_vcenter" -ForegroundColor cyan
        Connect-VIServer $vcx_server        
     }#try
    catch {
        write-host "Erreur: Connexion au vcenter impossible" -ForegroundColor red
        exit
     }#catch
    }#catch

## fin du test de connexion



#------------------------------------------------------------------------------------------------------------
#                                            MODE LIGNE DE COMMANDE 
#
#                    si un argument/parametre n'est présent dans la ligne de commande
#
#------------------------------------------------------------------------------------------------------------ 
if ($deploy -or $deployer -or $d){
    write-host "DEPLOYER!!!" -ForegroundColor red
    exit
    }
if ($configuration -or $config -or $c){
    write-host "CONFIG!!!" -ForegroundColor blue
    exit
    }
if ($inventaire -or $inventory -or $i) {
    try {
        if ($vm) { Get-Inventaire-VM }
        if ($esx) { Get-Inventaire-ESX }
        if ($ds -or $datastore) { Get-Inventaire-Datastore }
        }
    catch {
        write-host "Impossible de charger le module Virt : modules\ModulesVirt.ps1"
        }
    exit
    }
if ($check -or $verify -or $t){
    write-host "CHECK!!!" -ForegroundColor green
    Check-VMTools
    exit
    }


#------------------------------------------------------------------------------------------------------------
#                                            MODE INTERACTIF 
#
#                    si aucun argument/parametre n'est présent dans la ligne de commande
#
#------------------------------------------------------------------------------------------------------------ 
#debug
Write-Host "`n$msg_chargement_ok"  -BackgroundColor $c_fmsg -ForegroundColor $c_msg -NoNewline
sleep $cmx_delai_affichage_messages;Write-Host "." -BackgroundColor $c_fmsg -ForegroundColor $c_msg -NoNewline
sleep $cmx_delai_affichage_messages;Write-Host "." -BackgroundColor $c_fmsg -ForegroundColor $c_msg -NoNewline
#sleep $cmx_delai_affichage_messages;Write-Host "." -BackgroundColor $c_fmsg -ForegroundColor $c_msg -NoNewline

#-------------------------------------------------- Affichage du titre -------------------------------------------------- 
Clear-Host

#Set-Position 1 1
#Set-Resolution 140 40
Set-Title "$cmx_titre $cmx_version"

#-------------------------------------------------- Affichage du menu -------------------------------------------------- 
try {
    Show-Main $lien_par_defaut
    }
#un CTRL+C

finally {
    Quitter "$cmx_titre $cmx_version vous dit à bientôt!" $true
    }

#-------------------------------------------------- fin du script -------------------------------------------------- 
#quitter dans les regles...
Quitter "$cmx_titre $cmx_version vous dit à bientôt!" $false