<#
---------------------------------------------------------------------------------------------------------------
TITRE : Module de configuration CloudMe eXplorer
VERSION : 1.0
DATE CREATION : 06.06.2019

DESCRIPTION CE MODULE : 

Ce module contient l'ensemble des parametres du script.
On y trouve les variables et les constantes qui permettent de configuration et de personnalisation du script

---------------------------------------------------------------------------------------------------------------
#>

#Ordre modules important!
$liste_modules=@(   "ModulesStd.ps1", 
                    "ModulesVirt.ps1", 
                    "ModulesIG.ps1", 
                    "ModuleCSV.ps1", 
                    "ModuleExternes.ps1",
                    "ModulesAide.ps1"
                    )

#Versions:
$cmx_version="0.1 Beta"#06.06.2019: Premiere versions sans interface graphique
$cmx_version="0.2 Beta"#08.06.2019: 
$cmx_version="0.2.1 Beta"#08.06.2019: 
$cmx_version="0.2.2 Beta"#09.06.2019: 
$cmx_version="0.2.9 Beta"#10.06.2019: 
$cmx_version="0.3 Beta"#12.06.2019: 
$cmx_version="0.4 Beta"#15.06.2019: Finalisation de la structure : création des modules et leur interactions
$cmx_version="0.5 Beta"#16.06.2019: 
$cmx_version="0.6 Beta"#17.06.2019: 
$cmx_version="0.7 Beta"#18.06.2019: Finalisation de l'interface graphique
$cmx_version="0.8 Beta"#19.06.2019: 
$cmx_version="0.9 Beta"#20.06.2019: 
$cmx_version="1.0" #28.06.2019: version Full-operationnelle 
$cmx_maj_date="20/06/2019"

#-------------------------------------------------------------
#CloudMe Explorer
#-------------------------------------------------------------
$cmx_titre_original=$(get-host).ui.rawui.WindowTitle
$cmx_titre="CloudMe.eXplorer"
$cmx_slogan="ESGI Project SI 2019"

$cmx_format_header=".:: $cmx_titre - Menu principal ::."
$cmx_format_middle=".:: Console - §TITRE_PAGE§ ::." #§TITRE_PAGE§ sera remplacé par le titre ed la console/commande
$cmx_format_footer=".:: $cmx_titre - $cmx_slogan - Ver. $cmx_version - $cmx_maj_date ::."

$lan_domain_name='CloudMe.local'

$vcx_server_1="CloudMe-VCS01.$lan_domain_name"
$vcx_server_2="172.17.101.15"
$vcx_server=$vcx_server_1
$vcx_login="administrator@vsphere.local" #

$vcn_centreon_ip='172.17.111.13'
$vcn_centreon_name="CloudMe-SRV03.$lan_domain_name"

#$cmx_dossierModules="$(Get-Location)\modules" #Dossier courant, pas d'anti-slash a la fin
$cmx_dossierModules="C:\datas\PowerCLI\CloudMe eXplorer\modules"
$cmx_delai_affichage_messages=0.7 #en secondes, pour les messages avec delai
#-------------------------------------------------------------
#Theme etcoloration
#    col= couleur du texte
#    fnd=couleur du fond
#-------------------------------------------------------------
# Menu: Header
$col_header="Cyan"
$fnd_header="DarkMagenta"
#baniere de saisie
$col_saisie="Yellow"
$fnd_saisie="DarkYellow"
# couleurs du texte
$col_default="White"
$fnd_default="Black"
$col_message="Yellow"
$fnd_message="Black"
$col_ok="Green"
$fnd_ok="DarkGreen"
$col_erreur="Red"
$fnd_erreur="DarkRed"
$col_warning="Yellow"
$fnd_warning="DarkYellow"
$col_section="White"
$fnd_section="DarkCyan"
$col_titre="Magenta" #couleur des categories
$fnd_titre="Black" #couleur des categories
$col_soustitre="Cyan" #couleur des liens
$fnd_soustitre="Black" #couleur des liens
$col_highlight="White" #couleur des liens selectionnés
$fnd_highlight="DarkCyan" #couleur des liens selectionnés
#puces
$p_default="[O]"
$p_erreur="[¤]"
$p_warning="[!]"
$p_section="[o]"
$p_titre="[+]"
$p_soustitre="[-]"
$p_infos="[i]"
$p_ok="[OK]"

#-------------------------------------------------------------
#T menus...
#-------------------------------------------------------------

#categories
$cmx_categories=@(  "Automatisation", #0
                    "Inventaire", #1
                    "Supervision", #2
                    "Autres" #3
                  )

#chaque lien est definit par : titre, categorie(index array cmx_categories), function à executer
#les liens sont affichés dans cet ordre
#les liens de meme categorie doivent se suivre sinon un label de cette categorie sera recree a chaque fois
#le lien quitter doit etre en dernier
$cmx_liens=@(   @( "Deploiement de VMs via CSV", 0, 'Import-VM-From-CSV' ),#ARGS: "$index_1_titre (Work in progress...)" "soustitre" $false
            @("Désactiver SSH sur les ESX", 0, 'Disable-SSH-ESX' ),
            @("Ajout entrée DNS", 0, 'Configure-DNS' ),
            @("Liste des VM", 1, "Get-Inventaire-VM" ),
            @("Liste des ESX", 1, "Get-Inventaire-ESX" ),
            @("Listet Datastore", 1, "Get-Inventaire-Datastore" ),
            @("Approvisionnement Datastore", 1, "Get-DatastoreInfos" ),
            @("Check VMTools", 2, "Check-VMTools" ),
            @("Verifier les services SSH des ESX", 2, 'Check-SSH-2' ),
            @("Supervision Centreon (Health Status)", 2, 'Check-Centreon' ),
            @("Verification de la configuration NTP", 2,  'Configure-NTP' ),
            @("Connexion au VCenter", 3, 'Connect-CloudMe' ),
            @("Aide", 3, 'Show-Help' ),
            @("Quitter $cmx_titre", 3, "Quitter" )#le lien quitter doit etre en dernier
            )

$lien_par_defaut=13 #executé en cas d'erreurs : aide

#textes IG
$entete_csv_basic='Nom,Datastore,VHost,Memoire_Go,Nb_CPU,Hdd_C_Go,Hdd_D_Go,LAN,IP,Netmask,Passerelle,DNS1,DNS2'
$entete_csv_template='Nom,ESX,Datastore,Template,LAN,IP,Passerelle,DNS1,DNS2'

$msg_chargement_ok="CloudMe eXplorer est opérationnel"
$msg_chargement_module="Chargement du module"
$msg_chargement_modules="Chargement des modules..."
$msg_chargement_modules_ok="Modules chargés!"
$msg_chargement_modules_erreur="Impossible de charger les modules!"

$msg_connexion_centreon="Check état du serveur Centreon"
$msg_connexion_centreon_ok="Le serveur Centreon est joignable."
$msg_connexion_vcenter="Connexion au VCenter en cours..."
$msg_connexion_vcenter_ok="Connexion effectuée avec succés!"

$msg_erreur_code="Code erreur"
$msg_erreur_arret_script="Arrêt de CloudMe eXplorer"
$msg_erreur_connexion_centreon="ECHEC DU TEST DE CONNECTIVITE!!!"
$msg_erreur_mdp="Login/mot-de-passe incorrects coco!"
$msg_sortie_avec_erreur="$cmx_titre : `"CTRL+C? un souci?`""

$msg_astuce_vmtools="Démarrez le sercice RPC"
$msg_astuce_ntp="Démarrez le sercice RPC"
$msg_astuce_ssh="Démarrez le sercice SSH"
$msg_astuce_connexion="Essayez de lancez les services ou d'ouvrire les flux"
$msg_astuce_centreon="Veuillez verifier ASAP la disponibilité du serveur svp"
$msg_astuce_chargement_modules_1="Verifiez le dernier module chargé non chargé!"
$msg_astuce_chargement_modules_2="Verifiez qu'il n'y a pas d'erreur dans les modules. Lancez-les un par un."
$msg_astuce_cloudme_connect_1="Verifiez la disponibilité du serveur $vcx_server"
$msg_astuce_cloudme_connect_2="Verifiez vos infos d'identification"
$msg_astuce_vmtools_1="Démarrez le sercice RPC sur la machine"

$msg_deploy_go='I.4m.Th3.Cl0n3.M4$73R!'
$msg_deploy_annuler='Ok, Ok,  on annule tout!'
$msg_deploy_confirmation='Etes-vous sûr de vouloir importer ces VM? Tapez `"oui`" dans ce cas là puis <ENTREE> ? '
$msg_deploy_apercu_csv='Aperçu du fichier csv'


$msg_troubleshooting="Aide à la résolution"
$msg_section_en_dev="Section en developpement. Work In Progress..."