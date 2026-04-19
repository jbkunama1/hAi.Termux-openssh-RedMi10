# 📱 Termux OpenSSH Server on Android (e.g. Redmi 10)

Colorful step‑by‑step guide to install **Termux**, **OpenSSH** and a convenient start/stop/restart script on Android.

---

## 🎯 Goal

With this guide you can turn your Android phone (e.g. **Redmi 10**) into an SSH target inside your local Wi‑Fi.

- ✅ Install Termux
- ✅ Set up the OpenSSH server
- ✅ Handy management script (start/stop/restart/status)
- ✅ Android specifics (battery, network) for Xiaomi/Redmi

---

## 1️⃣ Install Termux

1. Open **F-Droid** in your browser: https://f-droid.org
2. Install the **Termux** app from **F-Droid** (do *not* use the Play Store version).
3. Start **Termux** and update packages:

```bash
pkg update && pkg upgrade -y
```

Optional (access internal storage):

```bash
termux-setup-storage
```

---

## 2️⃣ Install OpenSSH server in Termux

In Termux:

```bash
pkg install openssh -y

# Set password for the Termux user
passwd

# Remember the username
whoami
```

- Default Termux OpenSSH port: **8022**
- Username usually looks like `u0_a123`

Recommended: enable a wake‑lock so Android does not kill Termux in the background:

```bash
termux-wake-lock
```

You can later add `termux-wake-lock` to `~/.bash_profile` so it runs automatically.

---

## 3️⃣ SSHD management script (start/stop/restart)

To avoid typing long commands every time, create a small helper script.

### 📝 Create script

Create the file `sshd-manage.sh` in your home directory:

```bash
nano ~/sshd-manage.sh
```

Paste this content:

```bash
#!/data/data/com.termux/files/usr/bin/bash

case "$1" in
  start)
    if pgrep -x sshd > /dev/null; then
      echo "SSHD is already running."
    else
      termux-wake-lock
      sshd
      echo "SSHD started (port 8022)."
    fi
    ;;
  stop)
    pkill sshd
    termux-wake-unlock
    echo "SSHD stopped."
    ;;
  restart)
    $0 stop
    sleep 1
    $0 start
    ;;
  status)
    if pgrep -x sshd > /dev/null; then
      echo "SSHD is running (PID: $(pgrep -x sshd))."
    else
      echo "SSHD is not running."
    fi
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac
```

Save and exit the editor.

### 🔧 Make script executable and globally available

```bash
chmod +x ~/sshd-manage.sh
mv ~/sshd-manage.sh $PREFIX/bin/sshd-manage
```

Now you can control the SSH server with:

```bash
sshd-manage start
sshd-manage status
sshd-manage restart
sshd-manage stop
```

---

## 4️⃣ Android settings (Redmi 10 / MIUI / HyperOS)

To keep SSH stable, you must relax some Android restrictions for Termux.

### 🔋 Disable battery optimization

1. **Settings** → **Apps** → **Termux** → **Battery**
2. Choose **No restrictions** / **Unrestricted**

### 🌐 Check network permissions

1. **Settings** → **Apps** → **Permissions** → **Termux**
2. Ensure **Wi‑Fi/Mobile data** is allowed

Optionally, enable **Autostart** for Termux in the Security app.

---

## 5️⃣ Get the phone's IP address

In Termux:

```bash
ifconfig wlan0 | grep inet
# or
ip addr show wlan0
```

Use the IPv4 address, e.g. `192.168.1.45`.

Important: your PC/laptop must be in the **same Wi‑Fi network** as the phone.

---

## 6️⃣ Connect via SSH from your PC

On your PC (Linux/macOS/WSL/PowerShell):

```bash
ssh USERNAME@IP_ADDRESS -p 8022
```

Example:

```bash
ssh u0_a123@192.168.1.45 -p 8022
```

Enter the password you set with `passwd`.

### 🔐 Optional: SSH key instead of password

Create an SSH key on your PC (if you do not already have one):

```bash
ssh-keygen
```

Copy the key to the phone:

```bash
ssh-copy-id -p 8022 USERNAME@IP_ADDRESS
```

After that you can log in without a password.

---

## 7️⃣ Auto‑start SSHD in Termux

If you want SSHD to start automatically when you open Termux, add this line to `~/.bash_profile`:

```bash
sshd-manage start
```

Now simply opening Termux will start the SSH server.

---

## 8️⃣ Troubleshooting 🛠️

**Issue:** `Connection timed out`
- Check IP address (phone may have changed networks)
- Is `sshd` running? → `sshd-manage status`
- Is the phone really in the same Wi‑Fi as your PC?

**Issue:** `Permission denied`
- Correct username? → `whoami` in Termux
- Password set correctly? → `passwd`
- Correct port? → `-p 8022`

**Issue:** SSH runs for a while and then stops
- Battery optimization really disabled for Termux?
- Optionally set Termux as a protected/locked app in the task manager.

---

## ✅ Summary

- Install Termux from **F-Droid**
- `pkg install openssh`, set password, `termux-wake-lock`
- Create and install the `sshd-manage` helper script
- Relax Android battery/network restrictions for Termux
- Connect from your PC with `ssh USER@IP -p 8022`

Enjoy remote access to your Android device! 🚀
