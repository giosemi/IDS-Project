# ARTID

Applicativo per la gestione del portfolio artistico degli studenti AFAM (Alta Formazione Artistica e Musicale).

## Struttura

```
artid/
├── frontend/   # App Flutter (mobile + web)
└── backend/    # REST API Spring Boot
```

## Avvio

### Frontend
```bash
cd frontend
fvm flutter run -d chrome
```

### Backend
```bash
cd backend
mvn spring-boot:run
```

## Stack

- **Frontend**: Flutter + Riverpod
- **Backend**: Java 21 · Spring Boot · Spring Security · JWT · JPA
- **Database**: PostgreSQL (produzione) · H2 (sviluppo)
