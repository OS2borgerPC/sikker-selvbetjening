# Favorite Apps (GNOME)

Filen:

```
system_files/etc/dconf/db/local.d/favorite_apps
```

definerer hvilke programmer der bliver fastgjort til GNOME’s (brugergrænsefladen) proceslinje (Dash / taskbar).

---

## Standardkonfiguration

Som standard indeholder filen følgende konfiguration:

```ini
[org/gnome/shell]
favorite_apps=[
  'org.gnome.Nautilus.desktop','org.mozilla.firefox.desktop','libreoffice-writer.desktop','logout-button.desktop'
]
```

Denne indstilling styrer GNOME’s `favorite_apps`, som bestemmer hvilke programmer der vises som fastgjorte ikoner i brugerfladen.

GNOME er det grafiske skrivebordsmiljø (user interface), som brugeren interagerer med.

---

## Sådan ændrer du favorite_apps

Hvis du vil tilføje eller fjerne programmer fra listen, skal du følge disse trin:

---

### 0. Find korrekte .desktop-navne (valgfrit)

Hvis du er i tvivl om de korrekte programnavne, kan du finde dem på en hvilken som helst GNOME-baseret maskine:

```bash
find /usr/share/applications -name "*.desktop" | sort
```

Dette vil give en liste som fx:

```
/usr/share/applications/org.gnome.Nautilus.desktop
/usr/share/applications/org.mozilla.firefox.desktop
/usr/share/applications/libreoffice-writer.desktop
```

Det vigtige er navnet efter sidste `/`, fx:

```
org.gnome.Nautilus.desktop
```

Dette er værdien, der skal bruges i konfigurationen.

---

### 1. Find konfigurationsfilen

Åbn din organisations repository:

```
config/config.yml
```

---

### 2. Find eller opret `favorite_apps` sektionen

Under `policies:` skal du finde (eller oprette):

```yaml
favorite_apps:
```

Hvis den ikke findes, kan du selv tilføje den.

---

### 3. Tilføj apps

Inde i `favorite_apps` tilføjes en liste under `apps:`.

Hver app skal stå på sin egen linje med en bindestreg (`-`).

---

### Eksempel

```yaml
favorite_apps:
  apps:
    - org.gnome.Nautilus.desktop
    - org.mozilla.firefox.desktop
    - logout-button.desktop
```

---

### 4. Kontroller og gem

Inden du gemmer:

* Kontrollér at `.desktop`-navne er korrekte
* Kontrollér indentation (YAML er følsomt over for mellemrum)
* Sørg for at strukturen matcher resten af filen
* Commit dine ændringer

---

## Vigtige noter

* Indrykning i YAML er kritisk
* Forkerte `.desktop`-navne vil resultere i manglende apps
* Ændringer træder først i kraft efter ny system-build
* `/etc/dconf/db/local.d/locks/favorite_apps` låser ned for brugerens input, så de ikke kan ændre hvad er fastgjort. det bør ikke røres ved, men kan slettes, hvis du ønsker at give brugeren evnen til at fastgøre og frigør apps selv.
