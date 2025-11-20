# WAHA Secure Installation Script

סקריפט התקנה אוטומטי מאובטח ל-WAHA (WhatsApp HTTP API) על Ubuntu 22.04.

## ✨ תכונות

### 🔐 אבטחה מקסימלית
- **SSH מחוזק**: פורט מותאם אישית, ללא סיסמאות (רק SSH keys)
- **Firewall (UFW)**: רק פורטים נדרשים פתוחים
- **Fail2ban**: 4 jails להגנה על SSH ו-Nginx
- **SSL/TLS**: תמיכה ב-TLS 1.3 עם Ciphers חזקים
- **עדכוני אבטחה אוטומטיים**: unattended-upgrades מוגדר
- **חיזוק Kernel**: הגנה מפני SYN Flood, IP Spoofing ועוד
- **ניטור יומי**: בדיקת אבטחה אוטומטית

### 📦 WAHA
- תמיכה בכל המנועים: WEBJS, NOWEB, VENOM
- תמיכה ב-WAHA PRO עם מפתח רישיון
- Docker Compose מוכן לשימוש
- Nginx Reverse Proxy עם SSL

### 🎯 אוטומציה מלאה
- התקנה אינטראקטיבית עם שאלות ברורות
- ייצור אקראי של סיסמאות מאובטחות
- שמירה מאובטחת של credentials
- ללא הדפסת מידע רגיש ללוגים

## 📋 דרישות מוקדמות

1. **שרת נקי** עם Ubuntu 22.04 LTS
2. **גישת root** (או sudo)
3. **מפתח SSH** להתחברות (לא סיסמה!)
4. **דומיין** המכוון לשרת
5. **תעודת SSL** מ-Cloudflare (או CA אחר)

## 🚀 התקנה

### שלב 1: העתק את הסקריפט לשרת

```bash
# על המחשב המקומי שלך
scp install-waha.sh root@your-server-ip:/root/
```

### שלב 2: הכנס לשרת

```bash
ssh root@your-server-ip
```

### שלב 3: הרץ את הסקריפט

```bash
cd /root
chmod +x install-waha.sh
sudo bash install-waha.sh
```

## 📝 מה הסקריפט ישאל אותך

### 1. דומיין
```
Enter your domain name (e.g., waha.example.com):
```
הזן את הדומיין שלך, למשל: `waha.mydomain.com`

### 2. פורט SSH
```
Enter SSH port (default: 2222):
```
בחר פורט SSH (ברירת מחדל: 2222). פורט לא סטנדרטי מגביר אבטחה.

### 3. מנוע WAHA
```
Available WAHA Engines:
  1) WEBJS (default, free)
  2) NOWEB (requires PRO)
  3) VENOM (requires PRO)
Select engine (1-3, default: 1):
```
בחר מנוע:
- **WEBJS**: חינמי, מבוסס Puppeteer
- **NOWEB**: דורש PRO, בלי דפדפן
- **VENOM**: דורש PRO, מהיר יותר

### 4. רישיון PRO (אופציונלי)
```
Do you have a WAHA PRO license? (y/N):
```
אם יש לך רישיון PRO:
- הקלד `y`
- הדבק את מפתח הרישיון

### 5. תעודות SSL
```
Paste your SSL CERTIFICATE (including -----BEGIN CERTIFICATE----- ...):
```
הדבק את תעודת ה-SSL שלך ולחץ `Ctrl+D`

```
Paste your SSL PRIVATE KEY (including -----BEGIN PRIVATE KEY----- ...):
```
הדבק את המפתח הפרטי ולחץ `Ctrl+D`

### 6. אישור
```
Proceed with installation? (y/N):
```
הקלד `y` כדי להתחיל את ההתקנה.

## 📦 מה הסקריפט מתקין

1. ✅ עדכוני מערכת
2. ✅ Docker & Docker Compose
3. ✅ UFW Firewall
4. ✅ Nginx עם SSL
5. ✅ WAHA (Docker container)
6. ✅ SSH מחוזק
7. ✅ Fail2ban
8. ✅ עדכוני אבטחה אוטומטיים
9. ✅ חיזוק Kernel
10. ✅ ניטור אבטחה יומי

## 🔑 Credentials

לאחר ההתקנה, הסקריפט ישמור את ה-credentials שלך ב:

```bash
/root/waha-credentials.txt
```

לצפייה:
```bash
cat /root/waha-credentials.txt
```

הקובץ מוגן עם הרשאות `600` (רק root יכול לקרוא).

## 🛠️ פקודות שימושיות

### ניהול WAHA

```bash
# צפה בלוגים
docker logs waha -f

# הפעל מחדש
cd /opt/waha && docker compose restart

# עצור
cd /opt/waha && docker compose down

# הפעל
cd /opt/waha && docker compose up -d

# סטטוס
cd /opt/waha && docker compose ps
```

### אבטחה

```bash
# סטטוס Firewall
sudo ufw status verbose

# סטטוס Fail2ban
sudo fail2ban-client status

# בדוק IP-ים חסומים ב-SSH
sudo fail2ban-client status sshd

# צפה בלוג אבטחה יומי
cat /var/log/security-check.log

# הרץ בדיקת אבטחה ידנית
/opt/monitoring/daily-security-check.sh
```

### Nginx

```bash
# בדוק תצורה
sudo nginx -t

# הפעל מחדש
sudo systemctl restart nginx

# צפה בלוגים
sudo tail -f /var/log/nginx/your-domain-access.log
sudo tail -f /var/log/nginx/your-domain-error.log
```

## ⚠️ הערות חשובות

### SSH Port Changed
לאחר ההתקנה, פורט ה-SSH ישתנה!

התחבר עם:
```bash
ssh -p YOUR_SSH_PORT root@your-server-ip
```

### Password Authentication Disabled
ניתן להתחבר **רק** עם SSH keys. אם אין לך SSH key, **אל תריץ את הסקריפט** לפני שתגדיר אחד!

### Credentials Security
- ה-credentials נשמרים ב-`/root/waha-credentials.txt`
- **העתק אותם למקום מאובטח!**
- השתמש במנהל סיסמאות
- אל תשמור במייל או בענן לא מוצפן

## 🔒 רמת אבטחה

הסקריפט מיישם:

| תחום | רמת אבטחה |
|------|-----------|
| SSH | ⭐⭐⭐⭐⭐ Keys only, non-standard port |
| Firewall | ⭐⭐⭐⭐⭐ Minimal ports, strict rules |
| SSL/TLS | ⭐⭐⭐⭐⭐ TLS 1.3, strong ciphers |
| Fail2ban | ⭐⭐⭐⭐⭐ 4 jails active |
| Updates | ⭐⭐⭐⭐⭐ Automatic security updates |
| Monitoring | ⭐⭐⭐⭐⭐ Daily security checks |
| Kernel | ⭐⭐⭐⭐⭐ Hardened parameters |

**דירוג כולל: A+ 🏆**

## 📊 השפעה על משאבים

השיפורים האבטחתיים צורכים:
- **RAM**: ~50 MB (1-2%)
- **CPU**: ~0%
- **Disk**: ~100 MB

השרת נשאר מהיר ויעיל! ⚡

## 🐛 פתרון בעיות

### לא יכול להתחבר ב-SSH
```bash
# בדוק שהפורט הנכון נפתח ב-firewall
sudo ufw status | grep SSH_PORT

# בדוק ש-SSH רץ
sudo systemctl status sshd
```

### WAHA לא עובד
```bash
# בדוק לוגים
docker logs waha

# בדוק שהקונטיינר רץ
docker ps -a

# הפעל מחדש
cd /opt/waha && docker compose restart
```

### Nginx Error 502
```bash
# בדוק ש-WAHA רץ
docker ps | grep waha

# בדוק לוגי Nginx
sudo tail -f /var/log/nginx/*error.log
```

### אין גישה לדומיין
```bash
# בדוק DNS
nslookup your-domain.com

# בדוק SSL certificates
sudo ls -la /etc/nginx/ssl/your-domain/

# בדוק Nginx config
sudo nginx -t
```

## 📚 מידע נוסף

- [WAHA Documentation](https://waha.devlike.pro/)
- [WAHA GitHub](https://github.com/devlikeapro/waha)
- [Ubuntu Security](https://ubuntu.com/security)
- [Fail2ban Documentation](https://www.fail2ban.org/)

## 🆘 תמיכה

אם נתקלת בבעיה:

1. בדוק את הלוגים
2. הרץ בדיקת אבטחה: `/opt/monitoring/daily-security-check.sh`
3. בדוק תיעוד של WAHA
4. פתח issue ב-GitHub של WAHA

## 📜 רישיון

הסקריפט הזה הוא קוד פתוח. השתמש בו בחופשיות!

---

**נוצר עם ❤️ לשם הקלה על התקנת WAHA מאובטחת**
