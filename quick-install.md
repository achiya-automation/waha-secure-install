# התקנה מהירה של WAHA בפקודה אחת

## פקודה אחת להורדה והרצה:

```bash
curl -fsSL https://raw.githubusercontent.com/achiya-automation/waha-secure-install/main/install-waha.sh -o /tmp/install-waha.sh && chmod +x /tmp/install-waha.sh && sudo bash /tmp/install-waha.sh
```

או עם `wget`:

```bash
wget -qO /tmp/install-waha.sh https://raw.githubusercontent.com/achiya-automation/waha-secure-install/main/install-waha.sh && chmod +x /tmp/install-waha.sh && sudo bash /tmp/install-waha.sh
```

## הסבר מה הפקודה עושה:

1. **מורידה את הסקריפט** מ-GitHub לתיקייה זמנית `/tmp/`
2. **נותנת הרשאות הרצה** לסקריפט (`chmod +x`)
3. **מריצה אותו** עם הרשאות root (`sudo bash`)

## שימוש:

פשוט התחבר לשרת והרץ את הפקודה:

```bash
ssh root@YOUR_SERVER_IP
```

ואז העתק והדבק את הפקודה המלאה.

---

**זהו! 🚀**
