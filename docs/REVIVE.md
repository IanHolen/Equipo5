# 🎮 Revivir "Zazacrifice of Shaggy" — jugable en el navegador

Objetivo: dejar el juego jugable en internet (WebGL en GitHub Pages), con su backend y base de
datos hosteados, **sin instalar nada en tu computadora**. La compilación de Unity ocurre en la nube.

Arquitectura:

```
Navegador  ──►  Juego WebGL (GitHub Pages)  ──HTTPS──►  Backend Node/Express (Railway)  ──►  MySQL (Railway)
```

El código ya está preparado. Faltan **3 bloques de configuración** que requieren tus cuentas.
Hazlos en este orden.

---

## Paso 1 — Base de datos + Backend en Railway

1. Crea una cuenta gratis en **https://railway.app** (login con GitHub).
2. **New Project → Deploy MySQL.** Railway crea una base MySQL.
3. Carga el esquema: en el servicio MySQL, pestaña **Data** o **Connect**, usa la conexión que te da
   Railway y corre el archivo [`WEB/Backend_api/db_setup.sql`](../WEB/Backend_api/db_setup.sql).
   Desde tu terminal (o cualquier cliente tipo TablePlus/DBeaver):
   ```bash
   mysql -h <MYSQLHOST> -P <MYSQLPORT> -u <MYSQLUSER> -p < WEB/Backend_api/db_setup.sql
   ```
   Ese script crea el esquema `zazzacrifice` con tablas, triggers, vistas y datos de prueba.
4. En el **mismo proyecto → New → GitHub Repo →** selecciona tu fork `IanHolen/Equipo5`.
5. En el servicio del backend, **Settings**:
   - **Root Directory:** `WEB/Backend_api`
   - **Start Command:** `npm start` (o déjalo en automático)
6. En el backend, pestaña **Variables**, agrega (apuntando a tu MySQL de Railway):
   | Variable | Valor |
   |----------|-------|
   | `DB_HOST` | el host de tu MySQL de Railway |
   | `DB_PORT` | el puerto |
   | `DB_USER` | usuario |
   | `DB_PASSWORD` | contraseña |
   | `DB_NAME` | `zazzacrifice` |

   > Tip: Railway permite referenciar las variables del MySQL con `${{MySQL.MYSQLHOST}}`, etc.
7. En **Settings → Networking → Generate Domain**. Copia la URL pública, ej:
   `https://equipo5-production.up.railway.app`
8. Verifícalo: abre esa URL en el navegador. Debe responder `{"status":"ok",...}`.

---

## Paso 2 — Licencia de Unity (para que GameCI pueda compilar)

GameCI necesita una licencia **Unity Personal** (gratis). Se genera sin instalar Unity:

1. Crea una cuenta en **https://id.unity.com** (gratis).
2. Sigue la guía oficial de game-ci para obtener el archivo de licencia `.ulf`:
   **https://game.ci/docs/github/activation** (corre el workflow de activación, te llega el `.ulf` por correo o lo generas en unity.com/activation).
3. En tu repo `IanHolen/Equipo5` → **Settings → Secrets and variables → Actions → Secrets**, crea:
   | Secret | Valor |
   |--------|-------|
   | `UNITY_LICENSE` | **todo el contenido** del archivo `.ulf` |
   | `UNITY_EMAIL` | el correo de tu cuenta Unity |
   | `UNITY_PASSWORD` | la contraseña de tu cuenta Unity |

---

## Paso 3 — Conectar el juego con el backend + activar Pages

1. En `IanHolen/Equipo5` → **Settings → Secrets and variables → Actions → Variables**, crea:
   | Variable | Valor |
   |----------|-------|
   | `BACKEND_URL` | la URL de Railway del Paso 1.7 (sin `/` final), ej: `https://equipo5-production.up.railway.app` |

   El workflow reemplaza automáticamente el placeholder del código con esta URL al compilar.
2. **Settings → Pages → Build and deployment → Source: GitHub Actions.**
3. Corre el build: **Actions → "Build & Deploy WebGL" → Run workflow** (o haz cualquier push).
4. La primera compilación tarda ~20–40 min (Unity WebGL en el runner gratis). Cuando termine,
   el juego queda en: **https://ianholen.github.io/Equipo5/**

---

## ✅ Verificación final

- [ ] La URL de Railway responde `{"status":"ok"}`.
- [ ] El workflow de Actions terminó en verde.
- [ ] `https://ianholen.github.io/Equipo5/` carga el menú del juego.
- [ ] Registro / login funcionan (eso confirma que WebGL ↔ backend ↔ MySQL están conectados).

## Notas
- Los guardados locales del juego usan el almacenamiento del navegador (IndexedDB) en WebGL.
- Si el login falla con error de CORS: el backend ya usa `cors()` abierto, revisa que `BACKEND_URL`
  sea **https** y sin `/` final.
- Railway free tier puede dormir el servicio por inactividad; la primera petición tras dormir tarda unos segundos.
