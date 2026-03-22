# MoroccoCheck Admin Web

Web app admin separee pour `ADMIN` et `MODERATOR`, branchee sur le backend
MoroccoCheck.

## Demarrage

```bash
cd admin-web
npm install
npm run dev
```

Par defaut, l application appelle `http://127.0.0.1:5001/api`.

Pour changer l URL backend:

```bash
set VITE_API_BASE_URL=http://127.0.0.1:5001/api
npm run dev
```

## Fonctions actuellement disponibles

- connexion admin/moderator via `POST /api/auth/login`
- dashboard avec stats globales
- routing URL par page avec React Router
- liste des sites en attente
- pagination sur les listes sites, avis et utilisateurs
- detail site admin avec URL dediee
- moderation rapide des sites avec note
- liste des avis en attente
- detail avis admin avec URL dediee
- moderation des avis
- consultation des utilisateurs
- detail utilisateur dans l interface
- mise a jour du statut utilisateur pour `ADMIN`
- deconnexion

## URLs principales

- `/login`
- `/dashboard/overview`
- `/dashboard/sites`
- `/dashboard/sites/:siteId`
- `/dashboard/reviews`
- `/dashboard/reviews/:reviewId`
- `/dashboard/users`
- `/dashboard/users/:id`

## Limites actuelles

- pas encore de module categories / badges / analytics avances

## Note de deploiement

Comme il s agit maintenant d une SPA avec vraies URLs, le serveur de
production devra rewriter les routes inconnues vers `index.html`.
