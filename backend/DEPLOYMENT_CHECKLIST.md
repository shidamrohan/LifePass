# LifePass Backend - Deployment Checklist

## Pre-Deployment Setup Checklist

### Local Development Environment
- [ ] Python 3.9+ installed
- [ ] Virtual environment created
- [ ] Dependencies installed: `pip install -r requirements.txt`
- [ ] PostgreSQL installed and running
- [ ] Database created: `createdb lifepass`

### Configuration
- [ ] `.env` file created with all required variables:
  - [ ] `DATABASE_URL` - PostgreSQL connection string
  - [ ] `SECRET_KEY` - JWT secret (change from default)
  - [ ] `GEMINI_API_KEY` - From Google AI Studio
  - [ ] `CLOUDINARY_CLOUD_NAME`
  - [ ] `CLOUDINARY_API_KEY`
  - [ ] `CLOUDINARY_API_SECRET`
  - [ ] `DEBUG` - Set to False for production
  - [ ] `ALGORITHM` - HS256
  - [ ] `ACCESS_TOKEN_EXPIRE_MINUTES` - 30

### API Verification
- [ ] Server starts without errors: `python -m uvicorn app.main:app --reload`
- [ ] Health check endpoint works: `GET /health`
- [ ] Swagger UI loads: `http://localhost:8000/docs`
- [ ] All 24 endpoints visible in Swagger

### Database Verification
- [ ] Tables created successfully
- [ ] No schema errors
- [ ] Connection pooling working
- [ ] Sample data inserted (for testing)

### External Services
- [ ] Google Gemini API key tested
- [ ] Cloudinary credentials verified
- [ ] File upload tested
- [ ] AI report analysis tested

### Security
- [ ] JWT tokens generated correctly
- [ ] Password hashing working (bcrypt)
- [ ] CORS properly configured
- [ ] Sensitive data not logged
- [ ] SQL injection protection verified
- [ ] XSS protection verified

### Testing
- [ ] All endpoints tested manually
- [ ] Error scenarios tested
- [ ] Authorization checks verified
- [ ] Audit logging working
- [ ] No console errors

---

## Docker Deployment Checklist

### Dockerfile Creation
```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Docker Compose (Optional)
```yaml
version: '3.8'

services:
  api:
    build: ./backend
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/lifepass
      - DEBUG=False
    depends_on:
      - db

  db:
    image: postgres:14
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=lifepass
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:
```

- [ ] Dockerfile created
- [ ] Docker image builds successfully
- [ ] Container runs without errors
- [ ] Database connection works in container
- [ ] API accessible at http://localhost:8000

---

## Production Deployment (AWS/GCP/Azure)

### Server Setup
- [ ] Ubuntu 20.04 LTS or similar
- [ ] Python 3.11 installed
- [ ] PostgreSQL 14+ installed
- [ ] Nginx/Apache installed (reverse proxy)
- [ ] SSL certificate (Let's Encrypt)

### Application Deployment
- [ ] Repository cloned to server
- [ ] Virtual environment created
- [ ] Dependencies installed
- [ ] `.env` configured with production values
- [ ] Database migrations run
- [ ] Static files collected (if applicable)

### Gunicorn Setup
```bash
# Install Gunicorn
pip install gunicorn

# Run with Gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 app.main:app
```

- [ ] Gunicorn installed and configured
- [ ] Worker processes set to 4
- [ ] Socket/port configured
- [ ] Auto-restart on failure configured

### Nginx Configuration
```nginx
server {
    listen 80;
    server_name api.lifepass.com;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

- [ ] Nginx configured
- [ ] Proxy settings correct
- [ ] SSL enabled
- [ ] Domain pointing to server

### Database Setup (Production)
- [ ] PostgreSQL running with strong password
- [ ] Database backups configured
- [ ] Replication setup (optional)
- [ ] Connection pooling configured
- [ ] Monitoring enabled

### Environment Variables (Production)
- [ ] `DEBUG=False`
- [ ] `SECRET_KEY` - Strong random value (min 32 chars)
- [ ] `DATABASE_URL` - Production PostgreSQL URL
- [ ] `CORS_ORIGINS` - Specific frontend domain(s)
- [ ] All API keys and credentials stored securely
- [ ] No credentials in code/git

### Security Hardening
- [ ] HTTPS only (SSL certificate)
- [ ] Security headers configured:
  - [ ] `X-Content-Type-Options: nosniff`
  - [ ] `X-Frame-Options: DENY`
  - [ ] `X-XSS-Protection: 1; mode=block`
- [ ] Rate limiting enabled
- [ ] Request size limits configured
- [ ] CORS origins whitelist specific domains
- [ ] SQL injection prevention (SQLAlchemy parameterized queries)
- [ ] CSRF protection (if applicable)

### Monitoring & Logging
- [ ] Application logs configured
- [ ] Log rotation setup
- [ ] Error monitoring (Sentry/DataDog)
- [ ] Performance monitoring enabled
- [ ] Uptime monitoring configured
- [ ] Alert thresholds set

### Backup & Recovery
- [ ] Database backup schedule (daily)
- [ ] Backup storage location
- [ ] Recovery procedure documented
- [ ] Backup restoration tested
- [ ] Point-in-time recovery capability

---

## CI/CD Pipeline Setup

### GitHub Actions
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: '3.11'
      - run: pip install -r requirements.txt
      - run: pytest

  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy to production
        run: |
          # Deploy script here
```

- [ ] GitHub Actions workflow created
- [ ] Tests run on every push
- [ ] Deployment automated
- [ ] Environment secrets configured

---

## Post-Deployment Verification

### Immediate Checks (First Hour)
- [ ] API is accessible: `curl https://api.lifepass.com/health`
- [ ] Database connections established
- [ ] External services (Gemini, Cloudinary) working
- [ ] No error logs
- [ ] Monitoring showing 0% errors

### 24-Hour Checks
- [ ] All endpoints responding correctly
- [ ] No database issues
- [ ] Logs rotate properly
- [ ] Performance acceptable (< 500ms response)
- [ ] Backup completed successfully

### Ongoing Monitoring
- [ ] Daily log review
- [ ] Weekly performance analysis
- [ ] Monthly security audit
- [ ] Quarterly backup restoration test
- [ ] Error rate < 0.1%

---

## Rollback Plan

### If Deployment Fails
1. [ ] Identify error from logs
2. [ ] Revert to previous version: `git revert HEAD`
3. [ ] Restart application
4. [ ] Verify health check passes
5. [ ] Alert team
6. [ ] Post-mortem analysis

### Database Rollback
```bash
# If schema migration fails
pg_dump -U user -d lifepass > backup.sql
psql -U user -d lifepass < backup_previous.sql
```

- [ ] Database backup available
- [ ] Rollback procedure tested
- [ ] Documentation updated

---

## Launch Readiness Checklist

### Final Review (48 Hours Before Launch)
- [ ] All endpoints tested
- [ ] Security audit completed
- [ ] Performance benchmarked
- [ ] Documentation reviewed
- [ ] Team trained
- [ ] Monitoring configured
- [ ] Incident response plan ready
- [ ] Support contact info updated

### Launch Day
- [ ] Team standby during launch
- [ ] Real-time monitoring active
- [ ] Error tracking enabled
- [ ] Rollback ready
- [ ] Communication channels open

### Launch Week
- [ ] Monitor for issues (8-hour checks)
- [ ] Verify all features working
- [ ] Collect user feedback
- [ ] Document any issues
- [ ] Plan hot-fixes if needed

---

## Post-Launch Optimization

### Week 1
- [ ] Performance optimization
- [ ] Bug fixes
- [ ] User feedback incorporation
- [ ] Documentation updates

### Week 2-4
- [ ] Feature refinement
- [ ] Security improvements
- [ ] Caching optimization
- [ ] Database optimization

### Month 2+
- [ ] Advanced features
- [ ] Third-party integrations
- [ ] Analytics implementation
- [ ] A/B testing setup

---

## Success Criteria

- [ ] 99.9% uptime
- [ ] < 500ms average response time
- [ ] 0 critical security issues
- [ ] < 0.1% error rate
- [ ] All endpoints working
- [ ] Audit logs functioning
- [ ] Backups completing
- [ ] Monitoring alerting correctly
- [ ] Team confident in system
- [ ] Users satisfied with service

---

## Contact & Support

**Deployment Team Lead:** [Name]
**DevOps Engineer:** [Name]
**On-Call Support:** [Contact Info]
**Incident Hotline:** [Number]

---

**Last Updated:** August 4, 2026
**Version:** 1.0
**Status:** Ready for Deployment
