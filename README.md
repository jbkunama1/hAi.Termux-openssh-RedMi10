# 📱 Termux OpenSSH Server auf Android (z.B. Redmi 10)

Farbig gestaltete Anleitung zur Installation von **Termux**, **OpenSSH** und einem komfortablen Start/Stop/Restart-Script auf Android.

---

## 🎯 Ziel

Mit dieser Anleitung kannst du dein Android‑Smartphone (z.B. **Redmi 10**) so einrichten, dass du per **SSH** aus dem selben WLAN darauf zugreifen kannst.

- ✅ Installation von Termux
- ✅ Einrichten des OpenSSH‑Servers
- ✅ Komfort‑Script zum Starten/Stoppen/Neustarten
- ✅ Android‑Spezialfälle (Akku, Netzwerk) für Xiaomi/Redmi

---

## 1️⃣ Termux installieren

1. Öffne im Browser **F-Droid**: https://f-droid.org
2. Installiere die App **Termux** aus **F-Droid** (nicht aus dem Play Store).
3. Starte **Termux** und führe ein Update durch:

```bash
pkg update && pkg upgrade -y
```

Optional (Zugriff auf internen Speicher):

```bash
termux-setup-storage
```

---

## 2️⃣ OpenSSH-Server in Termux installieren

In Termux:

```bash
pkg install openssh -y

# Passwort für den Termux-User setzen
passwd

# Benutzername merken
whoami
```

- Standard‑Port von Termux‑OpenSSH: **8022**
- Benutzername ist meist etwas wie `u0_a123`

Empfohlen: Wake‑Lock aktivieren, damit Android Termux im Hintergrund nicht beendet:

```bash
termux-wake-lock
```

Du kannst `termux-wake-lock` später auch in `~/.bash_profile` eintragen, damit es bei jedem Start automatisch aktiviert wird.

---

## 3️⃣ Verwaltungs‑Script für SSHD (start/stop/restart)

Damit du den SSH‑Server nicht immer von Hand starten/stoppen musst, legst du ein kleines Script an.

### 📝 Script erstellen

Erstelle die Datei `sshd-manage.sh` in deinem Home‑Verzeichnis:

```bash
nano ~/sshd-manage.sh
```

Füge folgenden Inhalt ein:

```bash
#!/data/data/com.termux/files/usr/bin/bash

case "$1" in
  start)
    if pgrep -x sshd > /dev/null; then
      echo "SSHD läuft bereits."
    else
      termux-wake-lock
      sshd
      echo "SSHD gestartet (Port 8022)."
    fi
    ;;
  stop)
    pkill sshd
    termux-wake-unlock
    echo "SSHD gestoppt."
    ;;
  restart)
    $0 stop
    sleep 1
    $0 start
    ;;
  status)
    if pgrep -x sshd > /dev/null; then
      echo "SSHD läuft (PID: $(pgrep -x sshd))."
    else
      echo "SSHD läuft nicht."
    fi
    ;;
  *)
    echo "Nutzung: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
```

Speichern und Editor schließen.

### 🔧 Script ausführbar und global verfügbar machen

```bash
chmod +x ~/sshd-manage.sh
mv ~/sshd-manage.sh $PREFIX/bin/sshd-manage
```

Ab jetzt kannst du überall in Termux folgendes nutzen:

```bash
sshd-manage start
sshd-manage status
sshd-manage restart
sshd-manage stop
```

---

## 4️⃣ Android‑Einstellungen (Redmi 10 / MIUI / HyperOS)

Damit der SSH‑Zugriff stabil funktioniert, musst du Termux in Android freischalten:

### 🔋 Akku‑Optimierung deaktivieren

1. **Einstellungen** → **Apps** → **Termux** → **Akku**
2. **Keine Einschränkungen** / **Unbegrenzt** wählen

### 🌐 Netzwerkberechtigungen prüfen

1. **Einstellungen** → **Apps** → **Berechtigungen** → **Termux**
2. Sicherstellen, dass **WLAN/Mobilfunkdaten** erlaubt sind

Optional: In der Sicherheits‑/Security‑App den **Autostart** für Termux aktivieren.

---

## 5️⃣ IP-Adresse des Smartphones herausfinden

In Termux:

```bash
ifconfig wlan0 | grep inet
# oder
ip addr show wlan0
```

Du benötigst die IPv4‑Adresse, z.B. `192.168.1.45`.

Wichtig: Dein PC/Laptop muss im **selben WLAN** sein wie das Smartphone.

---

## 6️⃣ Vom PC per SSH verbinden

Auf deinem PC (Linux/macOS/WSL/PowerShell):

```bash
ssh BENUTZERNAME@IP_ADRESSE -p 8022
```

Beispiele:

```bash
ssh u0_a123@192.168.1.45 -p 8022
```

Dann das zuvor mit `passwd` gesetzte Passwort eingeben.

### 🔐 Optional: SSH-Key statt Passwort

Auf dem PC einen SSH‑Key erzeugen (falls noch keiner vorhanden):

```bash
ssh-keygen
```

Key auf das Handy kopieren:

```bash
ssh-copy-id -p 8022 BENUTZERNAME@IP_ADRESSE
```

Danach kannst du dich ohne Passwort anmelden.

---

## 7️⃣ Automatischer Start von SSHD in Termux

Wenn du möchtest, dass beim Öffnen von Termux automatisch der SSH‑Server startet, füge in `~/.bash_profile` folgende Zeile ein:

```bash
sshd-manage start
```

Nun reicht es, Termux zu öffnen, damit der SSH‑Server startet.

---

## 8️⃣ Troubleshooting 🛠️

**Problem:** `Connection timed out`
- IP‑Adresse prüfen (Handy evtl. neues WLAN‑Netz)
- Ist `sshd` gestartet? → `sshd-manage status`
- Läuft das Handy wirklich im gleichen WLAN wie der PC?

**Problem:** `Permission denied`
- Benutzername korrekt? → in Termux `whoami`
- Passwort korrekt gesetzt? → `passwd`
- Richtiger Port? → `-p 8022`

**Problem:** SSH läuft kurz und stoppt dann
- Akku‑Optimierung für Termux wirklich deaktiviert?
- Ggf. Termux im Task‑Manager auf "geschützt" setzen.

---

## ✅ Zusammenfassung

- Termux aus **F-Droid** installieren
- `pkg install openssh`, Passwort setzen, `termux-wake-lock`
- `sshd-manage` Script anlegen und ausführbar machen
- Android‑Akku/Netzwerk‑Einschränkungen lockern
- Vom PC per `ssh BENUTZER@IP -p 8022` verbinden

Viel Spaß beim Remote‑Zugriff auf dein Android‑Gerät! 🚀
