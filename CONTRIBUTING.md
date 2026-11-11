# Contribute to Kaeru · Cómo aportar

[English](#english) · [Español](#español)

## English

Kaeru is small on purpose. Every change must keep the player safe and the rescue path open.

**Without code:**

- Test Kaeru on your M9 and tell us the result in an issue (firmware version, what works, what does not).
- Improve the guide or the translation.
- Report a problem with the [bug template](.github/ISSUE_TEMPLATE/error.yml).

**With code (with or without AI):**

1. Read [AGENTS.md](AGENTS.md). It has the rules and the map of the repo.
2. Make a branch and a small change.
3. Run `bash pruebas/correr.sh`. All tests must pass.
4. If you change the system image, flash it on a real M9 and write the result in the PR.
5. Open a pull request with the template.

**Never add** firmware, APKs, system images or private keys to the repository.

### How we review

- A maintainer reviews every pull request. Only the maintainer merges.
- We check: safety for the player, the rescue path, no proprietary files, tests, and both languages in the docs.
- If your idea is better than ours, we say so and we learn from it.

## Español

Kaeru es pequeño a propósito. Cada cambio debe mantener seguro el reproductor y el camino de rescate.

**Sin programar:**

- Prueba Kaeru en tu M9 y cuéntanos el resultado en un issue (versión de firmware, qué funciona, qué no).
- Mejora la guía o la traducción.
- Reporta un problema con la [plantilla de error](.github/ISSUE_TEMPLATE/error.yml).

**Programando (con o sin IA):**

1. Lee [AGENTS.md](AGENTS.md). Tiene las reglas y el mapa del repo.
2. Crea una rama y haz un cambio pequeño.
3. Corre `bash pruebas/correr.sh`. Todas las pruebas deben pasar.
4. Si cambias la imagen del sistema, flashéala en un M9 real y escribe el resultado en el PR.
5. Abre un pull request con la plantilla.

**Nunca agregues** firmware, APKs, imágenes de sistema ni llaves privadas al repositorio.

### Cómo revisamos

- Quien mantiene el proyecto revisa cada pull request. Solo esa persona junta.
- Revisamos: seguridad del reproductor, camino de rescate, que no haya archivos propietarios, pruebas y los dos idiomas en la documentación.
- Si tu idea es mejor que la nuestra, lo decimos y aprendemos de ella.
