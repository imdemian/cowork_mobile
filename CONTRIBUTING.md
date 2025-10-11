# Guía de Contribución - Cowork Frontend

## 🌊 Flujo de Trabajo (GitHub Flow)

Este proyecto utiliza **GitHub Flow** para el desarrollo colaborativo.

### Proceso de Contribución

1. **Crear una rama desde `main`**
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/nombre-descriptivo
   ```

2. **Desarrollar y hacer commits**
   - Sigue la convención de commits (ver abajo)
   - Haz commits pequeños y frecuentes
   - Prueba tu código localmente

3. **Abrir Pull Request**
   - Asegúrate de que el CI pase
   - Describe claramente los cambios
   - Solicita revisión de al menos 1 compañero

4. **Code Review**
   - Responde a los comentarios
   - Realiza los cambios solicitados
   - Espera aprobación

5. **Merge y Deploy**
   - Usa **Squash and Merge**
   - Elimina la rama después del merge
   - Verifica que el CI/CD se ejecute correctamente

---

## 📝 Convención de Commits (Conventional Commits)

Usamos **Conventional Commits** para mantener un historial claro y automatizar releases.

### Formato
```
<tipo>(<scope>): <descripción>

[cuerpo opcional]

[footer opcional]
```

### Tipos de Commits

- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Cambios en documentación
- `style`: Formato, espacios en blanco (no afecta el código)
- `refactor`: Refactorización de código
- `test`: Agregar o modificar tests
- `chore`: Tareas de mantenimiento, configuración
- `perf`: Mejoras de rendimiento
- `ci`: Cambios en CI/CD

### Ejemplos

```bash
feat(auth): agregar login con Google
fix(api): corregir timeout en peticiones
docs(readme): actualizar instrucciones de instalación
refactor(ui): simplificar LoginPage widget
test(auth): agregar tests unitarios para AuthRepository
chore(deps): actualizar dependencias de Flutter
```

---

## 🏷️ Versionado Semántico (SemVer)

Usamos **Semantic Versioning**: `vMAJOR.MINOR.PATCH`

- **MAJOR**: Cambios incompatibles con versiones anteriores
- **MINOR**: Nueva funcionalidad compatible
- **PATCH**: Correcciones de bugs compatibles

### Crear un Tag

Después de un merge importante a `main`:

```bash
git checkout main
git pull origin main
git tag -a v1.2.0 -m "Release v1.2.0: Agregar autenticación con Google"
git push origin v1.2.0
```

---

## 🔍 Code Review Guidelines

### Para el Autor
- Mantén los PRs pequeños (< 400 líneas)
- Describe el "qué" y el "por qué"
- Incluye capturas si hay cambios visuales
- Asegúrate de que el CI pase antes de pedir revisión

### Para el Revisor
- Revisa dentro de las 24 horas
- Sé constructivo y específico
- Aprueba solo si entiendes y confías en el código
- Usa "Request Changes" si hay problemas críticos

---

## ✅ Checklist Antes de Merge

- [ ] CI/CD pasa sin errores
- [ ] Al menos 1 aprobación de code review
- [ ] Código sigue las convenciones del proyecto
- [ ] Tests agregados/actualizados si aplica
- [ ] Documentación actualizada si aplica
- [ ] Sin merge conflicts

---

## 🚫 Reglas de Branch Protection

La rama `main` está protegida con:
- Requiere Pull Request antes de merge
- Requiere 1-2 aprobaciones
- Requiere que CI/CD pase
- No permite force push
- No permite borrado directo

---

## 🛠️ Comandos Útiles

```bash
# Actualizar tu rama con los últimos cambios de main
git checkout main
git pull origin main
git checkout tu-rama
git rebase main

# Ver el estado de tu rama
git status

# Deshacer el último commit (mantener cambios)
git reset --soft HEAD~1

# Limpiar ramas locales ya mergeadas
git branch --merged | grep -v "main" | xargs git branch -d
```

---

## 📞 ¿Necesitas Ayuda?

Si tienes dudas sobre el proceso de contribución:
1. Revisa esta guía
2. Pregunta en el canal de Slack del equipo
3. Solicita ayuda a un mentor del proyecto

¡Gracias por contribuir a Cowork Frontend! 🎉
