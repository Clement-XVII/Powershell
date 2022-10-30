# Powershell

Here are several powershell scripts. MyModule and PSModule group these scripts together.
They can be installed with the command
```pwsh
Copy-Item "Location-Of-Module\PSModule\*" -Destination 'C:\Program Files\WindowsPowerShell\Modules\PSModule' -Recurse -Force
Import-Module PSModule -Verbose -Force
```
## Trolling coworkers

Avant tout il faut connaitre le mot de passe et le nom d'utilisateur de leur ordinateur. Après cela il faut installer le module PSModule sur leur ordinateur (Il est possible de le faire avec un rubber ducky et clé USB qui récupère le fichier CSV) ensuite vous devait arranger votre fichier CSV de la façon suivante.
```
Machines;Users
192.168.1.21;john
```
Vous devez utiliser le séparateur ";". Après cela vous devez importer MyModule. Puis il ne vous reste plus qu'a démarrer toute les Sessions du ficheir CSV avec la command 
```
Start-Session -Username John -CSV "Emplacement du fichier CSV"
```
Pour démarrer une seul Sesison
```
Start-Session -Username John -CSV "Emplacement du fichier CSV" -Name john
```
