# Wi-Fi

Filen:

```
system_files/etc/NetworkManager/conf.d/disable-wifi.conf
```

bruges til at deaktivere Wi-Fi på systemniveau som standard. Det betyder, at trådløse netværk ikke forsøges aktiveret, medmindre der er skrevet Wi-Fi-indstillinger i overlay-konfigurationen.

Derudover håndterer:

```
system_files/usr/libexec/sikker-overlay/tasks/wifi.yml
```

selve opbygningen af Wi-Fi-forbindelsen, når der findes en `wifi` sektion i build-konfigurationen.

---

## Hvad denne feature gør

- Standardopsætningen slår Wi-Fi fra med en NetworkManager-konfiguration.
- Hvis `wifi` er defineret i overlay-konfigurationen, fjernes denne deaktiverende regel efter build.
- Et Wi-Fi-profilkonfigurationsdokument oprettes i `/etc/NetworkManager/system-connections/` med SSCID og adgangskode.

---

## Sådan angiver du Wi-Fi

Hvis du vil have systemet til at oprette en Wi-Fi-forbindelse automatisk, skal du tilføje `wifi`-policy i den relevante device group konfiguration.

### Eksempel

```yaml
wifi:
  ssid: GUEST
  psk: guest-secret
  hidden: false
```

### Forklaring

- `ssid`: Navnet på det trådløse netværk.
- `psk`: Netværkets adgangskode.
- `hidden`: Valgfri. Bruges kun hvis netværket er skjult og ikke sender sit navn åbent.

---

## Hvad der sker under build

1. Build-processen ser om `wifi.ssid` er defineret.
2. Hvis ja, tilføjer den et script til at fjerne `disable-wifi.conf` efter installation.
3. Den skriver en NetworkManager-forbindelse til:

```
/etc/NetworkManager/system-connections/<SSID>.nmconnection
```

4. Forbindelsen sættes til at autokonnecte til det angivne netværk.

---

## Vigtige noter

- `ssid` og `psk` skal være udfyldt for at Wi-Fi oprettes.
- Hvis `wifi` ikke er defineret, holdes Wi-Fi deaktiveret.
- `disable-wifi.conf` er designet til at forhindre utilsigtet trådløs adgang, indtil en godkendt konfiguration er til stede.
- `psk` er følsomme data. Del ikke adgangskoder åbent i et offentligt repository.

---

## Nyttige begreber

- `NetworkManager`: Den tjeneste, der styrer netværksforbindelser i GNOME-/Linux-systemet.
- `SSID`: Navnet på det trådløse netværk.
- `PSK`: Wi-Fi adgangskode (pre-shared key).
- `overlay`: En build-konfiguration, som fortæller systemet, hvordan image- eller installationsopsætningen skal oprettes.
