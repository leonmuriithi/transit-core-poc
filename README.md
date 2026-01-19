#  TransitCore (POC)

**A Offline-First Seat Reservation Engine designed for low-connectivity logistics environments.**

TransitCore solves the "Double Booking" problem in inter-city bus travel using a **Graph-Based Locking Mechanism** and enables field agents to operate without internet access using **Optimistic UI & Background Sync**.

##  System Architecture

```mermaid
graph TD
    Mobile[Flutter Agent App] -->|1. Book Seat| LocalDB[(SQLCipher Encrypted DB)]
    LocalDB -->|2. Queue Action| Sync{Background Sync Worker}
    Sync -->|3. When Online| API[Node.js API Gateway]
    API -->|4. Atomic Lock| Mongo[(MongoDB Transaction)]
    API -->|5. STK Push| Mpesa[Safaricom Daraja API]
    Mpesa -->|6. Callback| Webhook[Payment Webhook]
