# Credenciales globales y guardado de clave en Github

Para que Git use tu nombre y correo en todos los repositorios de este equipo, configúralos globalmente:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-correo@example.com"
```bash
Comprueba la configuración con:
```bash
git config --global --list
```
Para que en la siguiente sincronización (push) se guarde la clave:
```bash    
git config --global credential.helper store
```
