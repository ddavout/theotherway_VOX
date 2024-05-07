l'utilisateur copie dans un répertoire **Voices**

> build/fr/900_mars

une copie permet à l'utilisateur de faire les modifications qu'il juge nécessaire.

dans ce même répertoire, il copie le répertoire **config**
qui contient les fichiers de configuration qu'ils aura à adapter.

Il fait un lien vers **frenchy**, un lien est préconisé car en principe il n'a pas à modifier les waves.

Il peut alors modifier les variables **voices**, **waves16** du script **build**

## Les fichiers de configuration

### env_festvox_settings0.cfg

L'utilisateur qui désire utiliser une installation existante de festival (de développement) ne devrait pas être trop dérouté.

Pour une nouvelle installation, il suffit de changer une seule variable

WHERE=/home/dop7/Develop

(dans tous les cas, ne pas s'occuper des variables liées à l'installation de SPTK, on ne l'utilise plus)

general.cfg fait état de prérequis "généraux", il ne faut remettre à plus tard **shellcheck** et **rsync** dont la nécessité se fait sentir d'emblée.


# Création d'une voix d'essai
dans un terminal, on lance
 > clear; NEW=1; export NEW ; ./build build_cg_voice build_cg_voice
