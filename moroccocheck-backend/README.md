# 🇲🇦 MoroccoCheck Backend API

![Node.js](https://img.shields.io/badge/Node.js-20.x-brightgreen)
![Express](https://img.shields.io/badge/Express-4.x-blue)
![MySQL](https://img.shields.io/badge/MySQL-8.0-blue)
![JWT](https://img.shields.io/badge/JWT-Authentication-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 📋 Description

API REST pour l'application MoroccoCheck - vérification communautaire des sites touristiques au Maroc.

MoroccoCheck est une application mobile permettant aux touristes et aux habitants de vérifier la disponibilité et la qualité des sites touristiques marocains en temps réel. Grâce à la géolocalisation GPS, les utilisateurs peuvent valider leur présence sur site et partager leurs expériences avec la communauté.

## 🎯 Fonctionnalités Principales

- **Authentification sécurisée** avec JWT et hashage bcrypt
- **Vérification GPS** des sites touristiques avec validation de distance
- **Système de notation** et d'avis communautaires
- **Gamification** avec badges et classements par points
- **Modération** des contenus avec différents niveaux d'accès
- **Monitoring** complet avec endpoints de santé et statistiques

## 🚀 Installation Rapide

### Prérequis

- Node.js v20.x LTS
- MySQL v8.0
- npm v10.x

### Étapes d'installation

```bash
# Clone le repo
git clone https://github.com/votre-compte/moroccocheck-backend.git
cd moroccocheck-backend

# Installe les dépendances
npm install

# Configure les variables d'environnement
cp .env.example .env

# Configure ta base de données MySQL
# (voir la section Base de Données ci-dessous)

# Initialise la base de données
mysql -u root -p < sql/install_database.sql

# Démarre le serveur
npm run dev
```

### Configuration de la Base de Données

La base de données est déjà créée avec les scripts SQL fournis dans `Phase2_3_MPD_Scripts_SQL.md`. Les scripts incluent :

- Création de la base de données et des tables
- Insertion de données de test
- Création de procédures stockées et fonctions
- Création de déclencheurs pour la logique métier
- Création de vues pour les statistiques

## 📦 Stack Technique

### Backend
- **Node.js** v20.x LTS - Runtime JavaScript
- **Express** v4.x - Framework web
- **MySQL** v8.0 - Système de gestion de base de données
- **bcrypt** - Hashage sécurisé des mots de passe
- **jsonwebtoken** - Authentification JWT
- **joi** - Validation des données

### Outils de Développement
- **nodemon** - Redémarrage automatique en développement
- **morgan** - Logging des requêtes HTTP
- **helmet** - Sécurité HTTP
- **cors** - Gestion des CORS

## 🗄️ Base de Données

### Tables Principales

- **`users`** - Gestion des utilisateurs avec rôles et niveaux
- **`tourist_sites`** - Informations sur les sites touristiques
- **`checkins`** - Vérifications GPS des utilisateurs sur site
- **`reviews`** - Avis et notes des utilisateurs
- **`badges`** - Système de gamification et récompenses
- **`categories`** - Catégories de sites touristiques

### Relations et Contraintes

- Clés étrangères pour maintenir l'intégrité référentielle
- Déclencheurs pour la logique métier (points, niveaux, modération)
- Procédures stockées pour les opérations complexes
- Vues pour les statistiques et rapports

## 🔧 Scripts NPM

```bash
npm start      # Lance le serveur en production
npm run dev    # Lance avec nodemon (hot reload)
npm test       # Lance les tests Jest (à configurer)
npm run lint   # Vérifie le style de code (à configurer)
```

## 🧪 Routes de Test

### Health Check
- `GET /api/health` - Vérification de base du serveur
- `GET /api/health/db` - Connexion et statistiques de la base de données
- `GET /api/health/system` - Informations système et performance

### Endpoints Legacy (à migrer)
- `GET /api/test-db` - Test de connexion à la base de données
- `GET /api/test-tables` - Liste des tables disponibles
- `GET /api/db-stats` - Statistiques détaillées de la base de données

## 📝 Variables d'Environnement

Voir `.env.example` pour la configuration complète :

```bash
# Configuration serveur
PORT=5000
NODE_ENV=development

# Configuration base de données
DB_HOST=localhost
DB_USER=your_username
DB_PASSWORD=your_password
DB_NAME=moroccocheck
DB_PORT=3306

# Configuration JWT
JWT_SECRET=your_jwt_secret_key
JWT_EXPIRES_IN=7d

# Configuration email (optionnel)
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
```

## 🔐 Sécurité

- **Hashage bcrypt** pour les mots de passe
- **JWT** avec expiration pour l'authentification
- **Validation Joi** pour toutes les entrées utilisateur
- **Middleware CORS** pour le contrôle des origines
- **Helmet** pour la sécurité HTTP
- **Middleware d'erreur** centralisé

## 📊 Monitoring et Logging

- **Logging Morgan** pour le suivi des requêtes
- **Health checks** pour la surveillance de l'API
- **Statistiques système** et base de données
- **Gestion d'erreurs** centralisée avec différents niveaux de détail selon l'environnement

## 🏗️ Architecture

```
src/
├── config/           # Configuration (base de données, constantes)
├── middleware/       # Middleware (authentification, validation, erreurs)
├── models/          # Modèles de données (à implémenter)
├── routes/          # Routes API (health check)
├── services/        # Logique métier (à implémenter)
├── utils/           # Utilitaires (GPS, validation)
└── controllers/     # Contrôleurs (à implémenter)
```

## 🤝 Contribuer

1. Fork le projet
2. Crée une branche feature (`git checkout -b feature/NouvelleFonctionnalite`)
3. Commit tes changements (`git commit -m 'Ajoute nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/NouvelleFonctionnalite`)
5. Ouvre une Pull Request

## 📞 Support

Pour toute question ou problème, merci de contacter l'équipe de développement.

## 👥 Contributeurs

- [Votre Nom] - Développeur Principal
- [Nom du Co-développeur] - Contributeur

## 📄 Licence

MIT License

Copyright (c) 2024 MoroccoCheck

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## 🚀 Prochaines Étapes

- [ ] Implémentation des contrôleurs d'utilisateurs
- [ ] Création des contrôleurs de sites touristiques
- [ ] Développement des contrôleurs de vérifications GPS
- [ ] Intégration du système de notifications
- [ ] Tests unitaires et d'intégration
- [ ] Documentation API Swagger/OpenAPI
- [ ] Déploiement en production

---

**MoroccoCheck** - Vérifions ensemble la beauté du Maroc ! 🇲🇦✨