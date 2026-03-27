# Checklist Recette V1

Cette checklist sert a valider les parcours critiques de MoroccoCheck avant livraison.

## Objectif

Verifier que les flux essentiels fonctionnent de bout en bout pour chaque role actif:

- `TOURIST`
- `CONTRIBUTOR`
- `PROFESSIONAL`
- `ADMIN`

## Preconditions

- backend lance sur `http://127.0.0.1:5001`
- front Flutter lance
- admin web lance sur `http://127.0.0.1:5173`
- base de donnees chargee
- seed applique si vous voulez reutiliser les comptes de demo

## Comptes De Test

Comptes seeds connus:

- `admin@moroccocheck.com` / `password123`
- `contributor@test.com` / `password123`
- `pro@test.com` / `password123`

Compte `TOURIST`:

- creer un compte via l application ou preparer un compte dedie pour la recette

## Regle D Execution

Pour chaque cas:

- marquer `OK` si le resultat attendu est conforme
- marquer `KO` si le flux est bloque ou incoherent
- noter les captures, messages d erreur et etapes exactes si echec

## 1. Recette TOURIST

### Authentification

- [ ] creer un nouveau compte `TOURIST`
- [ ] se connecter avec succes
- [ ] fermer puis rouvrir l application et verifier la persistance de session
- [ ] se deconnecter proprement

### Consultation

- [ ] ouvrir la liste des sites
- [ ] ouvrir le detail d un site
- [ ] voir les avis du site
- [ ] voir les photos du site si presentes

### Profil

- [ ] ouvrir le profil
- [ ] voir stats, badges et activite recente
- [ ] modifier le profil

### Demande Contributor

- [ ] verifier que les pre-requis contributor sont visibles dans le profil
- [ ] verifier qu un profil incomplet bloque la demande
- [ ] completer le profil minimum
- [ ] verifier qu une demande peut etre envoyee si le compte est eligible
- [ ] verifier que le statut de la demande apparait ensuite dans le profil

## 2. Recette CONTRIBUTOR

### Authentification

- [ ] se connecter avec `contributor@test.com`
- [ ] verifier que le role remonte correctement dans le profil

### Check-In

- [ ] ouvrir un site compatible check-in
- [ ] verifier que l action check-in est disponible
- [ ] effectuer un check-in valide
- [ ] verifier le message de succes
- [ ] verifier que le check-in apparait dans l activite ou les stats

### Avis Et Activite

- [ ] publier un avis texte
- [ ] modifier un avis si le flux le permet
- [ ] verifier la mise a jour des stats/badges si applicable

## 3. Recette PROFESSIONAL

### Authentification

- [ ] se connecter avec `pro@test.com`
- [ ] verifier l acces a l espace professionnel

### Espace Professionnel

- [ ] ouvrir le hub professionnel
- [ ] ouvrir la liste des etablissements
- [ ] consulter le detail d un site possede si disponible
- [ ] demarrer une revendication de site si le flux est disponible
- [ ] soumettre une fiche de site si le flux est disponible

### Cohabitation Des Roles

- [ ] verifier qu un `PROFESSIONAL` n accede pas a l admin web
- [ ] verifier que les actions admin restent interdites

## 4. Recette ADMIN

### Connexion

- [ ] se connecter sur `http://127.0.0.1:5173/login`
- [ ] verifier le chargement du dashboard

### Dashboard

- [ ] verifier le chargement des stats globales
- [ ] verifier le chargement des listes en attente

### Moderation Sites

- [ ] ouvrir la liste des sites en attente
- [ ] consulter le detail d un site
- [ ] approuver un site
- [ ] rejeter ou archiver un site de test si besoin

### Moderation Avis

- [ ] ouvrir la liste des avis en attente
- [ ] consulter le detail d un avis
- [ ] approuver un avis
- [ ] rejeter ou signaler un avis de test si besoin

### Utilisateurs

- [ ] ouvrir la liste des utilisateurs
- [ ] consulter le detail d un utilisateur
- [ ] modifier le statut d un utilisateur test

### Demandes Contributor

- [ ] ouvrir la page des demandes contributor
- [ ] verifier qu une demande envoyee par un `TOURIST` remonte dans la liste
- [ ] approuver une demande
- [ ] verifier que le compte passe en `CONTRIBUTOR`
- [ ] rejeter une autre demande de test si necessaire

## 5. Verification Croisee Des Permissions

- [ ] un `TOURIST` ne peut pas acceder a l admin web
- [ ] un `TOURIST` ne peut pas faire de check-in avant approbation contributor
- [ ] un `CONTRIBUTOR` peut faire un check-in
- [ ] un `PROFESSIONAL` peut acceder a l espace professionnel
- [ ] seul `ADMIN` peut acceder a l admin web

## 6. Verification Technique Minimum

- [ ] `GET /api/health` repond `200`
- [ ] admin web charge sans erreur reseau
- [ ] aucune erreur bloquante visible dans les logs backend
- [ ] aucune erreur bloquante visible dans la console web/admin

## 7. Go / No-Go Sprint 1

Le Sprint 1 peut etre considere suffisamment avance pour passer au Sprint 2 si:

- la documentation de reference est en place
- les roles sont clarifies
- les flux critiques sont listes
- cette checklist peut etre executee sans ambiguite

