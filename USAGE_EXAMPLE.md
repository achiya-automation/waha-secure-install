# דוגמת שימוש - סקריפט התקנת WAHA

מדריך צעד אחר צעד להתקנת WAHA על שרת נקי.

## 📋 לפני שמתחילים

### 1. הכן את המידע הבא:

- ✅ **כתובת IP של השרת**
- ✅ **מפתח SSH** (ודא שאתה יכול להתחבר!)
- ✅ **דומיין** שמכוון לשרת
- ✅ **תעודת SSL** + **מפתח פרטי** מ-Cloudflare
- ✅ (אופציונלי) **מפתח רישיון WAHA PRO**

### 2. תעודת SSL מ-Cloudflare

#### איך להשיג תעודת SSL מ-Cloudflare:

1. היכנס ל-Cloudflare Dashboard
2. בחר את הדומיין שלך
3. לך ל: **SSL/TLS** → **Origin Server**
4. לחץ **Create Certificate**
5. בחר:
   - Certificate Validity: 15 years
   - Include subdomains: כן (אם צריך)
6. לחץ **Create**
7. **העתק את שני הקטעים**:
   - Origin Certificate (ה-CERTIFICATE)
   - Private Key (ה-PRIVATE KEY)

⚠️ **שמור אותם במקום מאובטח! לא תוכל לראות אותם שוב.**

---

## 🚀 תהליך ההתקנה - צעד אחר צעד

### שלב 1: התחבר לשרת

```bash
ssh root@YOUR_SERVER_IP
```

### שלב 2: העלה את הסקריפט

**אופציה א' - מהמחשב שלך:**
```bash
# על המחשב המקומי
scp install-waha.sh root@YOUR_SERVER_IP:/root/
```

**אופציה ב' - הורד ישירות לשרת:**
```bash
# על השרת
cd /root
wget https://raw.githubusercontent.com/YOUR_REPO/install-waha.sh
# או
curl -O https://raw.githubusercontent.com/YOUR_REPO/install-waha.sh
```

### שלב 3: הרץ את הסקריפט

```bash
chmod +x install-waha.sh
sudo bash install-waha.sh
```

---

## 💬 תהליך האינטראקציה

### שאלה 1: דומיין
```
Enter your domain name (e.g., waha.example.com):
```
**דוגמה:**
```
waha.mydomain.com
```

---

### שאלה 2: פורט SSH
```
Enter SSH port (default: 2222):
```
**אפשרויות:**
- לחץ Enter לברירת מחדל (2222)
- או הקלד פורט אחר, למשל: `2345`

**המלצה:** השתמש בפורט לא סטנדרטי (לא 22)

---

### שאלה 3: מנוע WAHA
```
Available WAHA Engines:
  1) WEBJS (default, free)
  2) NOWEB (requires PRO)
  3) VENOM (requires PRO)
Select engine (1-3, default: 1):
```

**הסבר:**

| מנוע | תיאור | נדרש PRO? |
|------|-------|-----------|
| WEBJS | מנוע ברירת מחדל, משתמש ב-Puppeteer | לא |
| NOWEB | מהיר יותר, בלי דפדפן | כן |
| VENOM | הכי מהיר, ביצועים גבוהים | כן |

**בחירה:**
```
1
```

---

### שאלה 4: רישיון PRO
```
Do you have a WAHA PRO license? (y/N):
```

**אם אין לך PRO:**
```
n
```
(או סתם לחץ Enter)

**אם יש לך PRO:**
```
y
```
ואז:
```
Enter your WAHA PRO license key:
```
הדבק את המפתח שלך (לא יוצג על המסך - זה בטוח!)

---

### שאלה 5: תעודת SSL

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SSL Certificate Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Please paste your SSL certificate and private key.
These will be stored securely and NOT logged.

Paste your SSL CERTIFICATE (including -----BEGIN CERTIFICATE----- and -----END CERTIFICATE-----),
then press Ctrl+D when done:
```

**הדבק את התעודה המלאה**, לדוגמה:
```
-----BEGIN CERTIFICATE-----
MIIEpjCCA46gAwIBAgIULnD9nTum0bBwVBjiz0ETjl7KXSIwDQYJKoZIhvcNAQEL
BQAwgYsxCzAJBgNVBAYTAlVTMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTQw
...
(כל השורות)
...
i8srDVNRSUwwn/WoUD+LRecKuoIBsc/Vnux55px+gM/CBoHkqP+WGggo
-----END CERTIFICATE-----
```

**אחרי שהדבקת, לחץ `Ctrl+D`**

---

ואז:
```
Paste your SSL PRIVATE KEY (including -----BEGIN PRIVATE KEY----- and -----END PRIVATE KEY-----),
then press Ctrl+D when done:
```

**הדבק את המפתח הפרטי המלא**, לדוגמה:
```
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC1nQP8AG32fS2o
yqid3rasIredEFnfazh11PuRQMAziyJ7qMNazMoPl1Pp0UxKdMFvmEOQbU+1Xm4S
...
(כל השורות)
...
QlGoq7a0VBu6i1aTseK7PJOS
-----END PRIVATE KEY-----
```

**אחרי שהדבקת, לחץ `Ctrl+D`**

---

### שאלה 6: אישור סופי

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Installation Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Domain: waha.mydomain.com
SSH Port: 2222
WAHA Engine: WEBJS
WAHA Version: core
Credentials: Generated (will be saved to /root/waha-credentials.txt)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Proceed with installation? (y/N):
```

**בדוק שהכל נכון ולחץ:**
```
y
```

---

## ⏱️ זמן ההתקנה

הסקריפט יתקין את הכל תוך **3-5 דקות**.

תראה הודעות כמו:
```
[STEP] Updating system packages...
[INFO] System updated successfully
[STEP] Installing Docker...
[INFO] Docker installed successfully
...
```

---

## ✅ סיום ההתקנה

כשהסקריפט מסיים, תראה:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your WAHA instance is ready at: https://waha.mydomain.com

📋 Credentials have been saved to: /root/waha-credentials.txt
   View with: cat /root/waha-credentials.txt

⚠️  IMPORTANT NOTES:
   1. SSH port has been changed to: 2222
   2. Reconnect with: ssh -p 2222 root@your-server-ip
   3. Password authentication is DISABLED - only SSH keys work
   4. Your credentials file is stored securely with 600 permissions

🛡️  Security Features Enabled:
   ✓ Firewall (UFW) - Only essential ports open
   ✓ Fail2ban - 4 jails protecting SSH and Nginx
   ✓ Automatic security updates
   ✓ Daily security monitoring
   ✓ Kernel hardening
   ✓ SSL/TLS with strong ciphers
```

והסקריפט יציג את ה-**credentials** שלך (פעם אחת בלבד!):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WAHA Installation Credentials
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Domain: https://waha.mydomain.com
SSH Port: 2222

WAHA Dashboard:
  Username: admin
  Password: d55e2653e31541b097cb8fd495f7b22c

API Access:
  API Key: e6fb3dc3c37f4f0fab612044d06fc8bf

Swagger Documentation:
  URL: https://waha.mydomain.com/docs
  Username: admin
  Password: d55e2653e31541b097cb8fd495f7b22c
...
```

**⚠️ העתק והדבק את ה-credentials למקום מאובטח!**

---

## 🔐 אחרי ההתקנה

### 1. התנתק והתחבר מחדש

הסשן הנוכחי יתנתק. התחבר שוב עם הפורט החדש:

```bash
ssh -p 2222 root@YOUR_SERVER_IP
```

### 2. שמור את ה-Credentials

```bash
cat /root/waha-credentials.txt
```

העתק והדבק למנהל סיסמאות (1Password, LastPass, וכו').

### 3. בדוק שהאתר עובד

פתח בדפדפן:
```
https://waha.mydomain.com
```

תתבקש להזין username ו-password (מה-credentials שקיבלת).

---

## 🧪 בדיקות

### בדוק Docker
```bash
docker ps
```
אמור להראות container בשם `waha` ב-status `Up`.

### בדוק Nginx
```bash
sudo systemctl status nginx
```
אמור להראות `active (running)`.

### בדוק Firewall
```bash
sudo ufw status
```
אמור להראות רק את הפורטים: 2222, 80, 443.

### בדוק Fail2ban
```bash
sudo fail2ban-client status
```
אמור להראות 4 jails: sshd, nginx-http-auth, nginx-limit-req, nginx-botsearch.

---

## 📱 שימוש ב-WAHA

### 1. צור סשן חדש

גש ל-Dashboard:
```
https://waha.mydomain.com
```

### 2. התחבר עם WhatsApp

- לחץ על "Create Session"
- הזן שם לסשן (למשל: "my-whatsapp")
- סרוק את ה-QR code עם WhatsApp שלך

### 3. שלח הודעה דרך API

```bash
curl -X POST https://waha.mydomain.com/api/sendText \
  -H "X-Api-Key: YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "session": "my-whatsapp",
    "chatId": "972501234567@c.us",
    "text": "Hello from WAHA!"
  }'
```

---

## 🔧 פקודות שימושיות

```bash
# צפה בלוגים של WAHA
docker logs waha -f

# הפעל מחדש WAHA
cd /opt/waha && docker compose restart

# בדוק סטטוס אבטחה
cat /var/log/security-check.log

# הרץ בדיקת אבטחה
/opt/monitoring/daily-security-check.sh

# צפה ב-credentials
cat /root/waha-credentials.txt
```

---

## ❓ שאלות נפוצות

### איך אני משנה את הסיסמה?

ערוך את `/opt/waha/docker-compose.yml`:
```bash
nano /opt/waha/docker-compose.yml
```
שנה את `WAHA_DASHBOARD_PASSWORD` והפעל מחדש:
```bash
cd /opt/waha && docker compose restart
```

### איך אני מוסיף עוד דומיין?

צור קובץ Nginx חדש:
```bash
sudo nano /etc/nginx/sites-available/new-domain.com
```
העתק את התצורה מהדומיין הקיים, שנה את `server_name`, והפעל:
```bash
sudo ln -s /etc/nginx/sites-available/new-domain.com /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### איך אני עושה אפגרייד ל-WAHA PRO?

ערוך את `/opt/waha/docker-compose.yml`:
```bash
nano /opt/waha/docker-compose.yml
```
שנה:
- `image:` מ-`devlikeapro/waha:latest` ל-`devlikeapro/waha-plus:latest`
- הוסף שורה: `- WAHA_LICENSE_KEY=YOUR_LICENSE_KEY`

והפעל מחדש:
```bash
cd /opt/waha && docker compose down
cd /opt/waha && docker compose up -d
```

---

## 🆘 עזרה

אם משהו לא עובד:

1. **בדוק לוגים**: `docker logs waha`
2. **בדוק Nginx**: `sudo tail -f /var/log/nginx/*error.log`
3. **בדוק אבטחה**: `cat /var/log/security-check.log`
4. **בדוק תיעוד**: https://waha.devlike.pro/

---

**בהצלחה! 🚀**
