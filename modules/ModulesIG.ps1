<#
#---------------------------------------------------------------------------------------------------------------
TITRE : Module de fonctions d'interfaces graphiques CloudMe eXplorer
VERSION : 1.0
DATE CREATION : 06.06.2019

DESCRIPTION
Ce module configure et affiche une interface graphique
Cette interface graphique est dotée :
 - d'une banniere <header>(entete) : titre, version...
 - d'une deuxiemme banniere <console>(milieu) : indique la fonction en cours d'execution et 
 - d'une baniere <footer>(pied) : Copyrights...

Cette inetrface graphique interagit avec les differents fonctions du module virtuel
Ces differentes fonctions sont affichés dans un menu


LISTE DES FONCTIONS DE CE MODULE : 

 - Set-Header ($titre, $col, $fnd)
 - Set-Menu-Header ($titre) {
 - Set-Sousmenu-Header ($titre) {
 - Set-Menu-Footer () {
 - Show-Saisie ()
 - Show-Menu-List ()
 - Show-Main ($index)
 - Check-Choix ($choix)
 - Check-Choix-Import ($choix)
 - Run-Commande-Mauvais-Choix ($choix_utilisateur) 
 - Run-Commande-Mauvais-Choix-Import ($choix_utilisateur) 
 - Run-Commande-Mauvais-Choix-Fichier ($choix_utilisateur)

#---------------------------------------------------------------------------------------------------------------
#>

function Set-Header ($titre, $col, $fnd) {
    #calcul des espaces à remplir
    $largeurEcran=$(Get-Host).UI.RawUI.WindowSize.Width
    $diff=($largeurEcran-$titre.length)
    $arrondi=$([math]::round($diff))

    #si chiffre impair, ajouter un espace a droite
    if ($diff -eq $arrondi) {
        $espace_d=" "
        $espace_g=""
        }
    else {
        $espace_d=""
        $espace_g=""
        }    

    #remplir les espaces
    for ($x=1; $x -le $diff/2; $x++) {
        $espace_d="$espace_d "
        $espace_g="$espace_g "
        }
    
    #afficher le titre
    Write-host $espace_g$titre$espace_g -BackgroundColor $fnd -ForegroundColor $col
    
    #pour debug:
    #Write-host "`nlargeurEcran=$largeurEcran`n titre_taille="($titre.length)"`n diff=$diff`n x=$x" -BackgroundColor $fnd_header -ForegroundColor $col_header
}

function Set-Menu-Header ($titre) {
    #titre du menu principal
    $titre=$cmx_format_header
    Set-Header  $titre $col_header $fnd_header
} #fucntion

function Set-Sousmenu-Header ($titre) {
    #titre de la Console
    $titre=$cmx_format_middle -replace "§TITRE_PAGE§","$titre"
    Set-Header  $titre $col_header $fnd_header
} #fucntion

function Set-Menu-Footer () {
    #titre du menus du bas
    $titre=$cmx_format_footer
    Set-Header $titre $col_header $fnd_header
} #fucntion

function Show-Menu-List ($index) {

    $categorie_actuelle=-1 #aucune categorie selectionnée au depart, on check celle des liens
    $index_lien=0 # position du lien dans array cmx_liens
    $index_user=1  # raccourcis affiché à l'utilisateur, on commence à 1 car incrementation debut boucle

    ForEach ($lien in $cmx_liens) {
        $lien_titre=$lien[0]
        $lien_cat=$lien[1]
        $lien_fct=$lien[2]

        if ($lien_cat -ne $categorie_actuelle ) {
            $cat_titre=$cmx_categories[$lien_cat]
            $categorie_actuelle=$lien_cat
            Show-Messages "$cat_titre :" "titre" $true
            }#if

        if ($index_lien -eq $index) {
            Show-Messages " |_[$index_user] $lien_titre" "highlight" $false
            }
        else {
            Show-Messages " |_[$index_user] $lien_titre" "soustitre" $false
            }
        
        $index_lien++
        $index_user++
        }#ForEach

} #fucntion

function Show-Main ($choix_utilisateur) {
    
    do {           
        $index=$(Check-Choix $choix_utilisateur)
        
        if ($index -eq -1) {
            $mauvais_choix=$true
            $index=$lien_par_defaut
            }
        else {
            $mauvais_choix=$false
            }
   
          
        if ($mauvais_choix) {
            function Run-Commande { & "Show-Help" } 
            }
        else {
            function Run-Commande { & "$lien_fct" }  
            }
        $infos_commande=$cmx_liens[$index]
        $lien_titre=$infos_commande[0]
        $lien_cat=$infos_commande[1]
        $lien_fct=$infos_commande[2]
        $page=$lien_titre      
        Clear-Host
        Set-Menu-Header $cmx_slogan #"Menu Principal"          
        Show-Menu-List ($index)
        Set-Sousmenu-Header $page
        Run-Commande
        Set-Menu-Footer "Copyrights"
        
        #debug
        #write-host "choix_utilisateur : $choix_utilisateur  /   index=$index / fct=$lien_fct / mauvais_choix=$mauvais_choix" -ForegroundColor "red"
        
        if ($mauvais_choix) {
            Run-Commande-Mauvais-Choix ($choix_utilisateur)
            }
        $choix_utilisateur=$(Show-Saisie)        

    }while ($choix_utilisateur -ne ($cmx_liens.count) )
    
    #Quitter                 

} #fucntion

function Show-Saisie () {

    #titre du menus du bas
    $titre="Saisissez une option svp : "
    Set-Header $titre $col_saisie $fnd_saisie
    $saisie_utilisateur=read-host
    $saisie_utilisateur=$saisie_utilisateur -replace "^0*",""
    Show-messages $saisie_utilisateur "message" $false
    return "$saisie_utilisateur"

} #fucntion

function Check-Choix ($choix) {
    
    $choix=$choix -replace " ",""
    $choix_is_int=$choix -match "^\d+$"
    $i_min=1
    $i_max=$cmx_liens.count
    
    if ($choix_is_int){   
        $choix = $choix -as [int]   
        
        if ( ($choix -gt $i_max) -or ($choix -lt $i_min) ) {
            $retour=-1
            }
        else {#integer et bonne plage
            $retour=($choix-1)
            }
              
        }
    else {#not integer
        $retour=-1
        }

    return $retour
}#function

function Check-Choix-Import ($choix) {
    
    $choix=$choix -replace " ",""

    $choix_is_int=$choix -match "^\d+$"
    $i_min=1
    $i_max=3
    
    if ($choix_is_int){   
        $choix = $choix -as [int]
        
        if ( ($choix -gt $i_max) -or ($choix -lt $i_min) ) {
            $retour=-1
            }
        else {#integer et bonne plage
            $retour=($choix-1)
            }
              
        }
    else {#not integer
        $retour=-1
        }

    return $retour
    }
    
function Run-Commande-Mauvais-Choix ($choix_utilisateur) {     
    $message="mauvais choix <$choix_utilisateur>"
    Set-Header $message $col_erreur $fnd_erreur
    }

function Run-Commande-Mauvais-Choix-Import ($choix_utilisateur) {
    write-host " |_[mauvais choix]_______/" -ForegroundColor $col_erreur 
    }

function Run-Commande-Mauvais-Choix-Fichier ($choix_utilisateur) {
    write-host " |_[Fichier introuvable]_______________________________________________________/" -ForegroundColor $col_erreur 
    }

