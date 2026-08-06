# LifePass Hospital Portal

Browser-based emergency access for authorised hospital staff.

## Run locally

```powershell
cd hospital-portal
npm.cmd run dev
```

The portal uses `http://localhost:8000/api/v1` by default. To point it at a deployed API, set `VITE_API_URL` before starting or building it.

Hospital staff accounts use the `hospital_staff` role and must be created or approved by an administrator; patient mobile registration intentionally creates patient accounts only.

## Available workflow

1. Sign in with an authorised hospital-staff account.
2. Scan a patient QR with the laptop webcam, or paste its encrypted token / enter the patient ID.
3. Review the emergency profile and AI summary.
4. Add an emergency treatment record.
5. Review your access activity.
