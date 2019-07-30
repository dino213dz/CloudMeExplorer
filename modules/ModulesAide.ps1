<#
---------------------------------------------------------------------------------------------------------------
TITRE : Module de fonctions standard CloudMe eXplorer
VERSION : 1.0
DATE CREATION : 06.06.2019

DESCRIPTION :
Ce module contient les fonctions d'aide à l'utilisateur

LISTE DES FONCTIONS DE CE MODULE : 

 - Show-Help ($choix_utilisateur)

---------------------------------------------------------------------------------------------------------------
#>

function Show-Help ($choix_utilisateur) {
    
    #Set-Header "Section en cours de developpement" $col_warning $fnd_warning
    
    show-messages "L'interface graphique: " "titre" $true
    show-messages "L'interface graphique se compose de 3 sections principales (fond noir)." "soustitre" $false
    show-messages "Ces differentes sections sont séparées par des barres de titres (en magenta)." "soustitre" $false

    show-messages "Les sections" "titre" $true
    show-messages "  1. Le menu: Se situe tout en haut. Contient la liste des commandes disponibles" "soustitre" $false
    show-messages "  2. La console: Affiche le résultat de la dérniere commande executée." "soustitre" $false
    show-messages "  3. L'invite de saisie: Affiche votre saisie, vous devez tapez <ENTREE> pour valider votre choix" "soustitre" $false

    show-messages "LA navigation" "titre" $true
    show-messages "  Vous devez saisir le numero de la commande entra accolades [X] et taper <ENTREE> pour valider votre choix." "soustitre" $false

    show-messages "Contacts: " "titre" $true
    show-messages "  administrators@cloudme.local" "soustitre" $false
}

function Show-Help-Params ($autres_params) {
    
    $cmdname="CloudmeExplorer.ps1"
    write-host "AIDE!!!" -ForegroundColor Magenta

    Write-Host " `nCOMMANDE:" -ForegroundColor Magenta
    Write-Host "`t$cmdname :`t`t si aucun parametre n'est précisé l'interface utilisateur est affichée. " -ForegroundColor cyan
    Write-Host "`t$cmdname [OPTIONS] :`t Si un parametre est précisé, le script est lancé en Mode ligne de commande." -ForegroundColor cyan
       
    Write-Host " `nOPTIONS:" -ForegroundColor Magenta
    Write-Host "   Aide : " -ForegroundColor Magenta
    Write-Host "`t -h -help -aide : " -NoNewline -ForegroundColor cyan; Write-Host "Afficher l'aide"
    
    Write-Host "   Deploiement : " -ForegroundColor Magenta
    Write-Host "`t -d -deploy -deployer : " -NoNewline -ForegroundColor cyan; Write-Host "Deployer une ou plusieurs VM"
    Write-Host "`t -vm : " -NoNewline -ForegroundColor cyan; Write-Host "parametre obligatoire si -deploy est utilisé"
    Write-Host "`t -basique|-template : " -NoNewline -ForegroundColor cyan; Write-Host "parametre obligatoire si -vm est utilisé"
    Write-Host "`t -f -file|-fichier : " -NoNewline -ForegroundColor cyan; Write-Host "parametre obligatoire si -deploy est utilisé"
    
    Write-Host "   Configuration : " -ForegroundColor Magenta
    Write-Host "`t -c -config -configuration : " -NoNewline -ForegroundColor cyan; Write-Host "Configuration"
    Write-Host "`t -ntp|-ssh|-dns : " -NoNewline -ForegroundColor cyan; Write-Host "parametre obligatoire si -config est utilisé"
    
    Write-Host "   Inventaire : " -ForegroundColor Magenta
    Write-Host "`t -i -inventaire -inventory: " -NoNewline -ForegroundColor cyan; Write-Host "Faire l'inventaire de vos péripheriques"
    Write-Host "`t -vm|-esx|-ds : " -NoNewline -ForegroundColor cyan; Write-Host "parametre obligatoire si -inventory est utilisé"
    
    Write-Host "   Verifications : " -ForegroundColor Magenta
    Write-Host "`t -t -check -verify: " -NoNewline -ForegroundColor cyan; Write-Host "Faire des verifications"
    Write-Host "`t -vmtools|-centreon : " -NoNewline -ForegroundColor cyan; Write-Host "parametre obligatoire si -check est utilisé"

    
    Write-Host " `nEXEMPLES:" -ForegroundColor Magenta
    Write-Host "`t Deploiement : " -ForegroundColor Magenta
    Write-Host "`t`t $cmdname -deploy -vm -basic -file .\templates\VM_basic.csv" -ForegroundColor yellow
    Write-Host "`t`t $cmdname -deploy -vm -template -file .\templates\VM_by_templates.csv" -ForegroundColor yellow
    
    Write-Host "`t Inventaire : " -ForegroundColor Magenta
    Write-Host "`t`t $cmdname -inventory -vm " -ForegroundColor yellow

    Write-Host "`t Vérifications : " -ForegroundColor Magenta
    Write-Host "`t`t $cmdname -check -vmtools" -ForegroundColor yellow
    Write-Host "`t`t $cmdname -check -centreon" -ForegroundColor yellow

    Write-Host "`n`n"
    }