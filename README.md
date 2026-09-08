# aws-service-icons

Repositorio público de iconos de servicios AWS con fines exclusivamente educativos y sin ánimo de lucro.

## Descripción

Este proyecto reúne iconos SVG de la arquitectura de AWS, organizados para facilitar su uso en documentación, diagramas, presentaciones y herramientas internas.

La estructura se divide en dos partes principales:

- `Icon-package-aws-temp`: paquete temporal oficial de AWS que se usa como fuente de actualización.
- `icons`: carpeta pública del repositorio que recibe la versión normalizada y lista para publicar.

## Estructura del repositorio

```text
aws-service-icons/
├── .gitignore
├── LICENSE
├── README.md
├── update-icons.ps1
├── Icon-package-aws-temp/
│   ├── Architecture-Group-Icons_07312026/
│   ├── Architecture-Service-Icons_07312026/
│   ├── Category-Icons_07312026/
│   └── Resource-Icons_07312026/
├── icons/
│   ├── groups/
│   ├── services/
│   ├── categories/
│   └── resources/
└── .vscode/   (opcional, ignorado por git)
```

## Cómo actualizar los iconos

1. Descarga el nuevo paquete oficial de AWS en la carpeta `Icon-package-aws-temp`.
2. Verifica que contenga las cuatro secciones principales:
   - `Architecture-Group-Icons*`
   - `Architecture-Service-Icons*`
   - `Category-Icons*`
   - `Resource-Icons*`
3. Ejecuta el script de actualización:

```powershell
./update-icons.ps1
```

## Modo de validación segura

Antes de reemplazar el contenido de `icons`, el script valida que el paquete fuente sea correcto y completo. Si quieres revisar sin cambiar nada:

```powershell
./update-icons.ps1 -DryRun
```

Esto muestra el número de archivos SVG detectados por sección y no modifica el repositorio.

## Reglas importantes

- Los SVG se conservan con sus tamaños originales del paquete oficial de AWS.
- La carpeta `Icon-package-aws-temp` queda fuera del repositorio por `.gitignore`.
- El contenido de `icons` es la versión pública y estable que se puede subir a Git.
- El script reemplaza la salida de `icons` solo después de validar la fuente.

## Licencia

Este repositorio se distribuye bajo la licencia de AWS y con fines educativos, conforme a la política de uso del paquete de iconos original.
