
plaintext# CODEOWNERS - Asignación automática de revisores
# Más info: https://docs.github.com/articles/about-code-owners

# Dueños por defecto de todo el repositorio
# Serán solicitados para revisar cualquier PR
*       @imdemian

# Arquitectura y configuración del core
/lib/core/**                    @imdemian
/lib/injection/**               @imdemian

# Autenticación
/lib/features/auth/**           @imdemian

# UI/UX y temas
/lib/core/themes/**             @imdemian
/lib/features/*/presentation/* @imdemian

# Configuración de CI/CD
/.github/workflows/**           @imdemian

# Configuración de plataformas
/android/**                     @imdemian
/ios/**                         @imdemian

# Documentación
*.md                            @imdemian
/docs/**                        @imdemian

# Dependencias
pubspec.yaml                    @imdemian
pubspec.lock                    @imdemian
