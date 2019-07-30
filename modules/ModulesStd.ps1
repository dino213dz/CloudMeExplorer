<#
---------------------------------------------------------------------------------------------------------------
TITRE : Module de fonctions standard CloudMe eXplorer
VERSION : 1.0
DATE CREATION : 06.06.2019

DESCRIPTION :
Ce module contient les fonctions standard ou qui sont frequement utilisées
On y trouve :
 - l'affichage du texte à l'ecran
 - la modification de résolution, position et titre de la fenetre
 - la fermeture du script

LISTE DES FONCTIONS DE CE MODULE : 

 - Set-Resolution ($largeur, $hauteur)
 - Set-Position ($px, $py)
 - Set-Title ($titre)
 - Reset-Title ()
 - Ask-Messages ($message, $col, $fnd)
 - Show-Messages ($message, $type, $affpuce)
 - Quitter ($message)

---------------------------------------------------------------------------------------------------------------
#>

function Set-Resolution ($largeur, $hauteur) {
    #---------------------------------------------------------------------------------------------------------------
    # SET-RESOLUTION :
    # --------------- 
    #
    # [+] Description : Modifie la resolution de la fenetre powershell
    # [+] Arguments :
    #    [-] largeur [int]   : largeur de la fenetre powershell en nombre de caracteres, et non pas en pixels
    #    [-] hauteur [int]   : hauteur de la fenetre powershell en nombre de caracteres, et non pas en pixels
    #
    #---------------------------------------------------------------------------------------------------------------
    $pshost = get-host
    $pswindow = $pshost.ui.rawui
    
    $newsize = $pswindow.windowsize
    $newsize.height = $hauteur
    $newsize.width = $largeur
    $pswindow.windowsize = $newsize
    <#
    $newsize = $pswindow.buffersize
    $newsize.height = $hauteur*
    $newsize.width = $largeur
    $pswindow.buffersize = $newsize
    #>
    }

function Set-Position ($px, $py) {
    #---------------------------------------------------------------------------------------------------------------
    # SET-POSITION :
    # --------------- 
    #
    # [+] Description : Modifie la position de la fenetre powershell
    # [+] Arguments :
    #    [-] px [int]   : position X (horizontale) de la fenetre powershell
    #    [-] py [int]   : position Y (verticale) de la fenetre powershell
    #
    #---------------------------------------------------------------------------------------------------------------

    $pshost = get-host
    $pswindow = $pshost.ui.rawui
    
    $newpos = $pswindow.WindowPosition
    $newpos.X = $px
    $newpos.Y = $py
    $pswindow.WindowPosition = $newpos

}

function Set-Title ($titre) {
    #---------------------------------------------------------------------------------------------------------------
    # SET-TITLE :
    # --------------- 
    #
    # [+] Description : Modifie le titre de la fenetre powershell
    # [+] Arguments :
    #    [-] titre [string]   : texte à afficher dans la barre de titre de la fenetre powershell
    #
    #---------------------------------------------------------------------------------------------------------------

    $pshost = get-host
    $pswindow = $pshost.ui.rawui
    $pswindow.WindowTitle = $titre

}

function Reset-Title () {
    #---------------------------------------------------------------------------------------------------------------
    # RESET-TITLE :
    # --------------- 
    #
    # [+] Description : 
    #        Modifie le titre de la fenetre powershell et remet le titre qu'elle avait avant le lancement du script
    #        Le titre original est sauvegardé au lancement du script dans la variable $cmx_titre_original  
    #
    #---------------------------------------------------------------------------------------------------------------

    $pshost = get-host
    $pswindow = $pshost.ui.rawui
    $pswindow.WindowTitle = $cmx_titre_original

}

function Ask-Messages ($message, $col, $fnd) {
    
    Write-Host "$message" -BackgroundColor $fnd -ForegroundColor $col -NoNewline
    $saisie=read-host

    return $saisie
}

function Ask-OuiNon ($message, $col, $fnd) {
    
    Write-Host "$message" -BackgroundColor $fnd -ForegroundColor $col -NoNewline
    $saisie=read-host

    if ("$saisie" -match "oui") {$retour=$true}
    else {$retour=$false}

    return $retour
}

function Show-Messages ($message, $type, $affpuce) {
    #---------------------------------------------------------------------------------------------------------------
    # SHOW-MESSAGES :
    # --------------- 
    #
    # [+] Description : Fonction qui affiche un message a l'ecran.
    # [+] Arguments :
    #    [-] message [string] : message texte à afficher
    #    [-] $type [string]   : en minuscules, definit le type de message afin d'adapter la coloration
    #    [-] $affpuce [bool]  : $true/$false, affiche une puce avant le texte si $true
    #
    #---------------------------------------------------------------------------------------------------------------
    #coloration selon type du message
    switch ($type){
        aucun {
                $c_texte="gray"
                $c_fond="Black"
                $puce=""
                }
        message {
                $c_texte=$col_message
                $c_fond=$fnd_message
                $puce=$p_default
                }
        erreur {
                $c_texte=$col_erreur
                $c_fond=$fnd_erreur
                $puce=$p_erreur
                }
        warning {
                $c_texte=$col_warning
                $c_fond=$fnd_warning
                $puce=$p_warning
                }
        section {
                $c_texte=$col_section
                $c_fond=$fnd_section
                $puce=$p_section
                }
        titre {
                $c_texte=$col_titre
                $c_fond=$fnd_titre
                $puce=$p_titre
                }
        soustitre {
                $c_texte=$col_soustitre
                $c_fond=$fnd_soustitre
                $puce=$p_soustitre
                }
        highlight {
                $c_texte=$col_highlight
                $c_fond=$fnd_highlight
                $puce=$p_soustitre
                }
        ok {
                $c_texte=$col_ok
                $c_fond=$fnd_ok
                $puce=$p_ok
                }
        #couleur par defaut du message
        default {
                $c_texte=$col_default
                $c_fond=$fnd_default
                $puce=$p_default
                }
            }
    
    #affichage ou pas d'une puce avant le texte
    if (!$affpuce) { $puce=""} #pas de puce affichée
    else {$puce="$puce "}#on ajoute un petit espace entre la puve eet le texte

    #formattage et affichage du message
    Write-Host $puce""$message -BackgroundColor $c_fond -ForegroundColor $c_texte
    
} #fucntion

function Quitter ($message, $sortie_avec_erreur) {
    #---------------------------------------------------------------------------------------------------------------
    # QUITTER :
    # --------------- 
    #
    # [+] Description : 
    #        Fonction qui effectue une liste d'actions avant de quitter le script :
    #        - Elle remet le titre original de la fenetre powershell
    #        - elle efface l'ecran
    #        - elle affiche le message
    #        - elle quitte le script
    #
    # [+] Arguments :
    #    [-] message [string] : message texte à afficher avant de quitter
    #
    #---------------------------------------------------------------------------------------------------------------
    
    Clear-Host
    Reset-Title
    $WarningPreference = $prefBackup
    
    if ($sortie_avec_erreur -ne $false) { 
        Show-Messages "$msg_sortie_avec_erreur`n" "erreur" $false 
        }
    else {
        #if ($Message -ne "") { Show-Messages "`n$Message`n" "soustitre" $false }
        Show-Messages "`n$Message`n" "soustitre" $false
        }
}