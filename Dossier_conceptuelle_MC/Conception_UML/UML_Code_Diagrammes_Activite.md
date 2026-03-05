# Code Source UML - Diagrammes d'Activité MoroccoCheck
## Codes PlantUML pour tous les diagrammes d'activité

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [Processus de Check-In](#1-processus-de-check-in)
2. [Processus de Calcul de Fraîcheur](#2-processus-de-calcul-de-fraîcheur)
3. [Processus de Dépôt d'Avis](#3-processus-de-dépôt-davis)
4. [Processus de Validation Professionnelle](#4-processus-de-validation-professionnelle)
5. [Processus de Modération d'Avis](#5-processus-de-modération-davis)
6. [Processus de Modération de Check-In](#6-processus-de-modération-de-check-in)
7. [Processus d'Attribution de Badge](#7-processus-dattribution-de-badge)
8. [Processus de Level-Up](#8-processus-de-level-up)
9. [Processus de Paiement Stripe](#9-processus-de-paiement-stripe)
10. [Processus de Recherche de Sites](#10-processus-de-recherche-de-sites)
11. [Processus d'Inscription](#11-processus-dinscription)
12. [Processus de Récupération de Mot de Passe](#12-processus-de-récupération-de-mot-de-passe)

---

## 1. Processus de Check-In

```plantuml
@startuml CheckInProcess

start

:Utilisateur clique "Check-in";

if (Utilisateur connecté?) then (non)
  :Rediriger vers Login;
  stop
endif

if (Rôle >= CONTRIBUTOR?) then (non)
  :Afficher message "Devenez contributeur";
  stop
endif

:Demander permission localisation;

if (Permission accordée?) then (non)
  :Afficher erreur permission;
  stop
endif

:Récupérer position GPS;

if (GPS disponible?) then (non)
  :Afficher erreur GPS;
  stop
endif

:Calculer distance avec site;

if (Distance < 100m?) then (non)
  :Afficher "Trop loin du site";
  :Afficher distance actuelle;
  stop
endif

:Vérifier cooldown (24h);

if (Check-in récent sur ce site?) then (oui)
  :Afficher "Déjà fait aujourd'hui";
  stop
endif

:Afficher formulaire check-in;

partition "Remplissage formulaire" {
  :Sélectionner statut du site;
  note right
    - Ouvert
    - Fermé temporairement
    - Fermé définitivement
    - En rénovation
    - Déménagé
  end note
  
  :Ajouter commentaire (optionnel);
  
  if (Ajouter photo?) then (oui)
    :Ouvrir caméra/galerie;
    :Sélectionner photo;
    :Compresser image;
  endif
}

:Valider formulaire;

if (Données valides?) then (non)
  :Afficher erreurs validation;
  stop
endif

fork
  :Enregistrer check-in en BD;
fork again
  :Upload photo vers S3;
end fork

:Calculer points gagnés;
note right
  Points = 10 (base)
         + 5 (si photo)
         + bonus éventuel
end note

:Mettre à jour points utilisateur;

:Mettre à jour compteur check-ins;

:Mettre à jour fraîcheur du site;

if (Nouveau badge débloqué?) then (oui)
  :Créer notification badge;
  :Afficher animation badge;
endif

if (Level-up?) then (oui)
  :Créer notification level-up;
  :Afficher animation level-up;
endif

:Afficher message succès;
:Afficher points gagnés;

stop

@enduml
```

---

## 2. Processus de Calcul de Fraîcheur

```plantuml
@startuml FreshnessCalculation

start

:Récupérer site touristique;

partition "Collecte des données" {
  :Obtenir date dernière vérification;
  :Compter check-ins dernières 24h;
  :Compter check-ins derniers 7 jours;
  :Compter check-ins derniers 30 jours;
  :Obtenir avis récents (30 jours);
}

:Initialiser score = 0;

' Calcul basé sur la date
if (Dernière vérification < 24h?) then (oui)
  :score += 40;
  note right: Très récent
elseif (Dernière vérification < 7 jours?) then (oui)
  :score += 30;
  note right: Récent
elseif (Dernière vérification < 30 jours?) then (oui)
  :score += 15;
  note right: Acceptable
else (> 30 jours)
  :score += 0;
  note right: Obsolète
endif

' Calcul basé sur l'activité
if (Check-ins 24h > 5?) then (oui)
  :score += 20;
elseif (Check-ins 24h > 2?) then (oui)
  :score += 15;
elseif (Check-ins 24h > 0?) then (oui)
  :score += 10;
endif

if (Check-ins 7 jours > 10?) then (oui)
  :score += 15;
elseif (Check-ins 7 jours > 5?) then (oui)
  :score += 10;
elseif (Check-ins 7 jours > 0?) then (oui)
  :score += 5;
endif

' Calcul basé sur les avis
if (Avis récents > 5?) then (oui)
  :score += 15;
elseif (Avis récents > 2?) then (oui)
  :score += 10;
elseif (Avis récents > 0?) then (oui)
  :score += 5;
endif

' Bonus site professionnel
if (Site réclamé par professionnel?) then (oui)
  :score += 10;
  note right: Bonus fiabilité
endif

:Limiter score entre 0 et 100;

' Déterminer statut fraîcheur
if (score >= 80?) then (oui)
  :Status = FRESH;
  :Couleur = VERT;
elseif (score >= 50?) then (oui)
  :Status = RECENT;
  :Couleur = ORANGE;
elseif (score >= 20?) then (oui)
  :Status = OLD;
  :Couleur = ROUGE;
else (< 20)
  :Status = OBSOLETE;
  :Couleur = GRIS;
endif

:Enregistrer score en BD;
:Mettre à jour lastCalculatedAt;

if (Score a changé?) then (oui)
  :Créer événement "freshness_updated";
  :Logger changement;
endif

stop

@enduml
```

---

## 3. Processus de Dépôt d'Avis

```plantuml
@startuml ReviewSubmission

start

:Utilisateur clique "Écrire un avis";

if (Utilisateur connecté?) then (non)
  :Rediriger vers Login;
  stop
endif

:Vérifier si avis existant pour ce site;

if (Avis déjà écrit?) then (oui)
  :Afficher "Vous avez déjà donné votre avis";
  :Proposer de modifier l'avis existant;
  stop
endif

:Afficher formulaire avis;

partition "Remplissage formulaire" {
  
  :Saisir note globale (1-5 étoiles);
  note right: OBLIGATOIRE
  
  :Saisir notes détaillées (optionnel);
  note right
    - Service
    - Propreté
    - Rapport qualité/prix
    - Emplacement
  end note
  
  :Saisir titre (optionnel);
  
  :Saisir contenu avis;
  note right
    Min 20 caractères
    Max 2000 caractères
  end note
  
  :Sélectionner date de visite (optionnel);
  
  :Sélectionner type de visite;
  note right
    - Business
    - Couple
    - Famille
    - Amis
    - Solo
  end note
  
  if (Ajouter photos?) then (oui)
    repeat
      :Sélectionner photo;
      :Compresser image;
    repeat while (Plus de photos ET < 10?) is (oui)
  endif
  
  :Ajouter recommandations (optionnel);
}

:Valider formulaire;

if (Note globale présente?) then (non)
  :Erreur "Note obligatoire";
  stop
endif

if (Contenu >= 20 caractères?) then (non)
  :Erreur "Avis trop court";
  stop
endif

if (Détection spam?) then (oui)
  :Marquer pour modération;
  :Status = PENDING;
else (non)
  :Status = PUBLISHED;
endif

fork
  :Enregistrer avis en BD;
fork again
  :Upload photos vers S3;
end fork

:Calculer points gagnés;
note right
  Points = 15 (base)
         + 5 par photo (max 50)
         + 10 si avis détaillé
end note

:Mettre à jour points utilisateur;

:Mettre à jour compteur avis;

:Recalculer note moyenne du site;

:Mettre à jour fraîcheur du site;

if (Nouveau badge débloqué?) then (oui)
  :Créer notification badge;
endif

if (Status = PUBLISHED?) then (oui)
  :Créer notification propriétaire;
  :Afficher "Avis publié";
else (PENDING)
  :Afficher "En attente modération";
endif

:Afficher points gagnés;

stop

@enduml
```

---

## 4. Processus de Validation Professionnelle

```plantuml
@startuml ProfessionalValidation

start

:Professionnel clique "Revendiquer ce site";

if (Utilisateur connecté?) then (non)
  :Rediriger vers Login;
  stop
endif

if (Rôle = PROFESSIONAL?) then (non)
  :Afficher "Créez un compte professionnel";
  :Rediriger vers upgrade;
  stop
endif

if (Site déjà réclamé?) then (oui)
  :Afficher "Site déjà réclamé";
  stop
endif

:Afficher formulaire validation;

partition "Documents requis" {
  :Upload document légal;
  note right
    - Registre de commerce
    - Patente
    - Ou document officiel
  end note
  
  :Upload photo façade/intérieur;
  
  :Confirmer adresse email pro;
  
  :Confirmer numéro téléphone;
  
  :Justifier lien avec établissement;
  note right
    - Propriétaire
    - Gérant
    - Responsable marketing
  end note
}

:Valider formulaire;

if (Tous documents fournis?) then (non)
  :Afficher erreurs validation;
  stop
endif

:Créer demande de revendication;
:Status = PENDING_REVIEW;

:Enregistrer documents en S3;

:Créer notification pour modérateurs;

:Afficher "Demande en cours";
:Estimer délai (24-72h);

stop

note right of stop
  La validation sera faite
  par un modérateur
end note

@enduml
```

---

## 5. Processus de Modération d'Avis

```plantuml
@startuml ReviewModeration

start

:Modérateur accède interface modération;

:Charger avis en attente;

if (Avis disponibles?) then (non)
  :Afficher "Aucun avis en attente";
  stop
endif

:Sélectionner avis à modérer;

partition "Analyse de l'avis" {
  
  :Lire contenu avis;
  
  :Vérifier photos;
  
  :Consulter historique utilisateur;
  
  :Vérifier signaux spam;
  note right
    - Mots-clés suspects
    - Liens externes
    - Contenu dupliqué
    - Profil utilisateur
  end note
  
  if (Contient langage inapproprié?) then (oui)
    :Marquer flag "langage";
  endif
  
  if (Contient spam/pub?) then (oui)
    :Marquer flag "spam";
  endif
  
  if (Hors sujet?) then (oui)
    :Marquer flag "hors-sujet";
  endif
  
  if (Faux avis suspect?) then (oui)
    :Marquer flag "suspect";
  endif
}

:Modérateur prend décision;

if (Décision?) then (APPROUVER)
  
  :Status = APPROVED;
  :ModerationStatus = APPROVED;
  :Enregistrer moderatedBy;
  :Enregistrer moderatedAt;
  
  :Publier avis;
  
  :Créer notification utilisateur;
  note right: "Votre avis a été publié"
  
  :Créer notification propriétaire;
  
  :Attribuer points à l'utilisateur;
  
elseif (REJETER) then
  
  :Status = REJECTED;
  :ModerationStatus = REJECTED;
  :Saisir raison rejet;
  
  :Créer notification utilisateur;
  note right: "Avis rejeté: [raison]"
  
  :Aucun point attribué;
  
elseif (MARQUER SPAM) then
  
  :Status = SPAM;
  :ModerationStatus = SPAM;
  
  :Incrémenter compteur spam utilisateur;
  
  if (Compteur spam > 3?) then (oui)
    :Suspendre compte utilisateur;
    :Créer notification suspension;
  endif
  
else (DEMANDER MODIFICATION)
  
  :ModerationStatus = FLAGGED;
  :Saisir commentaires modération;
  
  :Créer notification utilisateur;
  note right: "Modifications demandées"
  
endif

:Enregistrer action modération;

:Logger dans historique;

:Passer à l'avis suivant;

stop

@enduml
```

---

## 6. Processus de Modération de Check-In

```plantuml
@startuml CheckInModeration

start

:Modérateur accède interface modération;

:Charger check-ins en attente;

if (Check-ins disponibles?) then (non)
  :Afficher "Aucun check-in en attente";
  stop
endif

:Sélectionner check-in à modérer;

partition "Analyse du check-in" {
  
  :Afficher infos check-in;
  note right
    - Utilisateur
    - Site
    - Status déclaré
    - Commentaire
    - Photos
    - Position GPS
    - Distance du site
  end note
  
  :Afficher historique utilisateur;
  note right
    - Nombre check-ins
    - Taux validation
    - Signalements
  end note
  
  :Afficher carte avec position;
  
  if (Distance > 100m?) then (oui)
    :Marquer flag "distance";
  endif
  
  if (Check-in dupliqué suspect?) then (oui)
    :Marquer flag "dupliqué";
  endif
  
  if (Photo incohérente?) then (oui)
    :Marquer flag "photo";
  endif
  
  :Vérifier cohérence status;
  note right
    Comparer avec check-ins récents
  end note
}

:Modérateur prend décision;

if (Décision?) then (APPROUVER)
  
  :ValidationStatus = APPROVED;
  :Enregistrer validatedBy;
  :Enregistrer validatedAt;
  
  :Mettre à jour fraîcheur site;
  
  :Attribuer points utilisateur;
  
  :Créer notification utilisateur;
  note right: "Check-in validé: +X points"
  
  if (Nouveau badge?) then (oui)
    :Déclencher attribution badge;
  endif
  
elseif (REJETER) then
  
  :ValidationStatus = REJECTED;
  :Saisir raison rejet;
  
  :Créer notification utilisateur;
  note right: "Check-in rejeté: [raison]"
  
  :Aucun point attribué;
  
  if (Fraude suspectée?) then (oui)
    :Incrémenter compteur fraude;
    
    if (Compteur fraude > 3?) then (oui)
      :Suspendre compte;
    endif
  endif
  
else (DEMANDER INFO)
  
  :ValidationStatus = FLAGGED;
  :Saisir commentaires;
  
  :Créer notification utilisateur;
  note right: "Informations complémentaires demandées"
  
endif

:Enregistrer action modération;

:Logger dans historique;

stop

@enduml
```

---

## 7. Processus d'Attribution de Badge

```plantuml
@startuml BadgeAttribution

start

:Événement déclencheur;
note right
  - Nouveau check-in
  - Nouvel avis
  - Nouveau niveau
  - Upload photo
  - Milestone atteint
end note

:Récupérer profil utilisateur;

:Charger tous les badges disponibles;

:Filtrer badges non encore obtenus;

if (Badges restants?) then (non)
  :Aucune vérification nécessaire;
  stop
endif

repeat :Sélectionner badge suivant;
  
  partition "Vérification conditions" {
    
    if (Type = CHECKIN_MILESTONE?) then (oui)
      if (checkinsCount >= requiredCheckIns?) then (oui)
        :Badge éligible = true;
      endif
      
    elseif (Type = REVIEW_MILESTONE?) then (oui)
      if (reviewsCount >= requiredReviews?) then (oui)
        :Badge éligible = true;
      endif
      
    elseif (Type = PHOTO_MILESTONE?) then (oui)
      if (photosCount >= requiredPhotos?) then (oui)
        :Badge éligible = true;
      endif
      
    elseif (Type = LEVEL_ACHIEVEMENT?) then (oui)
      if (level >= requiredLevel?) then (oui)
        :Badge éligible = true;
      endif
      
    elseif (Type = CATEGORY_EXPERT?) then (oui)
      :Compter check-ins par catégorie;
      if (Catégorie spécifique >= 10?) then (oui)
        :Badge éligible = true;
      endif
      
    elseif (Type = REGION_EXPLORER?) then (oui)
      :Compter villes visitées;
      if (Villes uniques >= requiredCities?) then (oui)
        :Badge éligible = true;
      endif
      
    elseif (Type = STREAK?) then (oui)
      :Calculer série check-ins consécutifs;
      if (Série >= requiredStreak?) then (oui)
        :Badge éligible = true;
      endif
      
    endif
    
    ' Conditions spécifiques additionnelles
    if (specificConditions exists?) then (oui)
      :Évaluer conditions JSON;
      if (Toutes conditions remplies?) then (non)
        :Badge éligible = false;
      endif
    endif
  }
  
  if (Badge éligible?) then (oui)
    
    :Créer UserBadge;
    :earnedAt = now();
    :notificationSent = false;
    
    :Attribuer points récompense;
    note right: badge.pointsReward
    
    :Ajouter badge à liste nouveaux;
    
  endif

repeat while (Plus de badges à vérifier?) is (oui)

if (Nouveaux badges obtenus?) then (oui)
  
  fork
    :Créer notifications badges;
  fork again
    :Créer événement analytics;
  fork again
    :Mettre à jour classement;
  end fork
  
  :Retourner liste nouveaux badges;
  
  note right
    L'UI affichera une animation
    pour chaque nouveau badge
  end note
  
else (non)
  :Aucun nouveau badge;
endif

stop

@enduml
```

---

## 8. Processus de Level-Up

```plantuml
@startuml LevelUpProcess

start

:Points utilisateur mis à jour;

:Récupérer points actuels;

:Récupérer niveau actuel;

:Charger seuils de niveaux;
note right
  Tableau des seuils:
  Niveau 1: 0 points
  Niveau 2: 100 points
  Niveau 3: 250 points
  Niveau 4: 500 points
  Niveau 5: 1000 points
  etc.
end note

:Calculer niveau basé sur points;

if (Nouveau niveau > Niveau actuel?) then (non)
  :Aucun changement niveau;
  stop
endif

' Level-up détecté
:ancien_niveau = niveau actuel;
:nouveau_niveau = niveau calculé;

repeat
  
  :Incrémenter niveau;
  
  partition "Récompenses niveau" {
    
    :Débloquer nouvelles fonctionnalités;
    note right
      Exemples:
      - Niveau 3: Répondre aux avis
      - Niveau 5: Créer des listes
      - Niveau 10: Devenir modérateur
    end note
    
    if (Niveau multiple de 5?) then (oui)
      :Attribuer badge spécial niveau;
      :Points bonus = niveau * 10;
    endif
    
    :Calculer rank;
    if (niveau < 5) then
      :rank = "Bronze";
    elseif (niveau < 10) then
      :rank = "Argent";
    elseif (niveau < 20) then
      :rank = "Or";
    else
      :rank = "Platine";
    endif
  }
  
  :Créer notification level-up;
  note right
    "Félicitations!
    Vous êtes maintenant niveau X"
  end note
  
  if (Nouveau rank?) then (oui)
    :Créer notification changement rank;
  endif
  
repeat while (Niveau < nouveau_niveau?) is (oui)

:Mettre à jour niveau en BD;
:Mettre à jour rank en BD;
:Enregistrer levelUpAt;

fork
  :Créer événement analytics;
fork again
  :Mettre à jour leaderboard;
fork again
  :Vérifier nouveaux badges débloqués;
end fork

:Retourner info level-up;
note right
  Pour afficher animation
  dans l'interface
end note

stop

@enduml
```

---

## 9. Processus de Paiement Stripe

```plantuml
@startuml StripePayment

start

:Professionnel sélectionne plan;

partition "Sélection plan" {
  :Afficher plans disponibles;
  note right
    - BASIC: 99 MAD/mois
    - PRO: 199 MAD/mois
    - PREMIUM: 399 MAD/mois
  end note
  
  :Utilisateur choisit plan;
  
  :Utilisateur choisit cycle;
  note right
    - Mensuel
    - Trimestriel (-10%)
    - Annuel (-20%)
  end note
  
  :Calculer prix total;
}

if (Méthode paiement enregistrée?) then (non)
  :Rediriger vers ajout carte;
  
  :Afficher formulaire Stripe;
  
  :Utilisateur saisit infos carte;
  
  :Stripe valide carte;
  
  if (Carte valide?) then (non)
    :Afficher erreur carte;
    stop
  endif
  
  :Créer Stripe Customer;
  :Attacher PaymentMethod;
  
endif

:Créer Subscription en BD;
:Status = PENDING_PAYMENT;

:Créer Stripe PaymentIntent;
note right
  Montant + taxe
  Devise: MAD
  Customer ID
  Metadata
end note

if (PaymentIntent créé?) then (non)
  :Erreur Stripe;
  :Logger erreur;
  stop
endif

:Rediriger vers Stripe Checkout;

' Attente paiement utilisateur
note right
  L'utilisateur est sur
  la page Stripe
end note

' --- Webhook Stripe ---

partition "Webhook payment_intent.succeeded" {
  
  :Stripe envoie webhook;
  
  :Vérifier signature webhook;
  
  if (Signature valide?) then (non)
    :Rejeter webhook;
    stop
  endif
  
  :Extraire PaymentIntent;
  
  :Récupérer Subscription par metadata;
  
  :Créer Payment en BD;
  :amount = PaymentIntent.amount;
  :status = SUCCEEDED;
  :stripePaymentIntentId = PaymentIntent.id;
  
  :Mettre à jour Subscription;
  :status = ACTIVE;
  :startDate = now();
  :endDate = now() + billing_cycle;
  :nextBillingDate = endDate;
  
  :Mettre à jour Site;
  :subscriptionPlan = plan choisi;
  :Activer fonctionnalités plan;
  
  fork
    :Créer notification succès;
  fork again
    :Envoyer email confirmation;
  fork again
    :Générer facture PDF;
  fork again
    :Créer événement analytics;
  end fork
}

partition "Webhook payment_intent.payment_failed" {
  
  :Stripe envoie webhook échec;
  
  :Mettre à jour Payment;
  :status = FAILED;
  :failureReason = error.message;
  
  :Mettre à jour Subscription;
  :status = PAYMENT_FAILED;
  
  :Créer notification échec;
  
  :Envoyer email échec;
}

stop

@enduml
```

---

## 10. Processus de Recherche de Sites

```plantuml
@startuml SiteSearch

start

:Utilisateur accède recherche;

:Afficher interface recherche;

partition "Saisie critères" {
  
  if (Recherche textuelle?) then (oui)
    :Saisir mots-clés;
  endif
  
  if (Filtrer par catégorie?) then (oui)
    :Sélectionner catégories;
    note right
      - Restaurant
      - Hôtel
      - Musée
      - etc.
    end note
  endif
  
  if (Filtrer par localisation?) then (oui)
    
    if (Utiliser position actuelle?) then (oui)
      :Demander permission GPS;
      
      if (Permission accordée?) then (oui)
        :Récupérer position GPS;
        :Définir rayon recherche;
      else (non)
        :Saisir ville manuellement;
      endif
      
    else (non)
      :Saisir adresse/ville;
      :Géocoder adresse;
    endif
    
  endif
  
  if (Filtrer par note?) then (oui)
    :Sélectionner note minimum;
    note right: >= 3, >= 4, >= 4.5
  endif
  
  if (Filtrer par fraîcheur?) then (oui)
    :Sélectionner fraîcheur minimum;
    note right
      - Vérifié < 24h
      - Vérifié < 7 jours
      - Vérifié < 30 jours
    end note
  endif
  
  if (Filtrer par prix?) then (oui)
    :Sélectionner gamme prix;
  endif
  
  if (Filtrer par équipements?) then (oui)
    :Sélectionner équipements;
    note right
      - WiFi
      - Parking
      - Accessible
      - Paiement carte
    end note
  endif
}

:Construire requête recherche;

if (Position GPS disponible?) then (oui)
  :Trier par distance;
else (non)
  :Trier par pertinence;
endif

:Exécuter recherche en BD;

if (Résultats trouvés?) then (non)
  :Afficher "Aucun résultat";
  :Suggérer élargir critères;
  stop
endif

partition "Traitement résultats" {
  
  :Charger sites (pagination);
  
  fork
    :Calculer distance pour chaque site;
  fork again
    :Charger photos principales;
  fork again
    :Charger notes moyennes;
  fork again
    :Charger fraîcheur;
  end fork
  
  :Appliquer tri choisi;
  note right
    - Distance
    - Note
    - Fraîcheur
    - Popularité
    - Prix
  end note
}

:Afficher résultats;

if (Afficher sur carte?) then (oui)
  :Afficher carte avec markers;
  :Centrer sur résultats;
endif

:Afficher liste résultats;

partition "Interaction résultats" {
  
  repeat
    
    if (Scroll vers le bas?) then (oui)
      if (Plus de résultats?) then (oui)
        :Charger page suivante;
      endif
    endif
    
    if (Clic sur site?) then (oui)
      :Ouvrir détails site;
      stop
    endif
    
    if (Modifier filtres?) then (oui)
      :Retour saisie critères;
    endif
    
  repeat while (Utilisateur actif?) is (oui)
  
}

stop

@enduml
```

---

## 11. Processus d'Inscription

```plantuml
@startuml Registration

start

:Utilisateur clique "S'inscrire";

:Afficher formulaire inscription;

partition "Saisie informations" {
  
  :Saisir prénom;
  :Saisir nom;
  :Saisir email;
  :Saisir mot de passe;
  :Confirmer mot de passe;
  
  if (Type compte?) then (PROFESSIONNEL)
    :Saisir nom entreprise;
    :Saisir secteur activité;
  else (CONTRIBUTEUR/TOURISTE)
    :Sélectionner pays;
    :Sélectionner ville (optionnel);
  endif
  
  :Accepter CGU;
  :Accepter politique confidentialité;
}

:Valider formulaire;

partition "Validations" {
  
  if (Tous champs obligatoires remplis?) then (non)
    :Afficher "Champs requis manquants";
    stop
  endif
  
  if (Format email valide?) then (non)
    :Afficher "Email invalide";
    stop
  endif
  
  if (Mot de passe >= 8 caractères?) then (non)
    :Afficher "Mot de passe trop court";
    stop
  endif
  
  if (Mot de passe contient chiffre?) then (non)
    :Afficher "Mot de passe doit contenir chiffre";
    stop
  endif
  
  if (Mots de passe correspondent?) then (non)
    :Afficher "Mots de passe différents";
    stop
  endif
  
  if (CGU acceptées?) then (non)
    :Afficher "Vous devez accepter les CGU";
    stop
  endif
}

:Vérifier si email existe;

if (Email déjà utilisé?) then (oui)
  :Afficher "Email déjà enregistré";
  :Proposer connexion;
  stop
endif

:Hasher mot de passe (bcrypt);

:Créer utilisateur en BD;
note right
  - role = TOURIST (par défaut)
  - points = 0
  - level = 1
  - status = PENDING_VERIFICATION
  - isEmailVerified = false
end note

:Générer token vérification email;

fork
  :Envoyer email vérification;
  note right
    Lien: /verify-email?token=xxx
  end note
fork again
  :Créer événement analytics;
  note right: "user_registered"
fork again
  :Attribuer badge "Bienvenue";
end fork

:Créer session utilisateur;
:Générer JWT token;

:Rediriger vers onboarding;

partition "Onboarding" {
  
  :Afficher message bienvenue;
  
  :Expliquer système gamification;
  
  :Proposer activer notifications;
  
  if (Compte professionnel?) then (oui)
    :Proposer ajouter établissement;
  else (non)
    :Proposer explorer sites proches;
  endif
}

:Rediriger vers application;

stop

@enduml
```

---

## 12. Processus de Récupération de Mot de Passe

```plantuml
@startuml PasswordReset

start

:Utilisateur clique "Mot de passe oublié?";

:Afficher formulaire email;

:Saisir adresse email;

:Valider formulaire;

if (Format email valide?) then (non)
  :Afficher "Email invalide";
  stop
endif

:Rechercher utilisateur par email;

if (Utilisateur trouvé?) then (non)
  ' Pour sécurité, ne pas révéler si email existe
  :Afficher "Si l'email existe, vous recevrez un lien";
  note right
    Message identique que succès
    pour éviter énumération comptes
  end note
  stop
endif

:Générer token reset;
note right
  Token unique
  Validité: 1 heure
  Hash stocké en BD
end note

:Enregistrer token en BD;
:passwordResetToken = hash(token);
:passwordResetExpires = now() + 1h;

:Créer URL reset;
note right
  https://app.com/reset-password?token=xxx
end note

fork
  :Envoyer email avec lien;
  note right
    Email contient:
    - Lien reset
    - Durée validité
    - Message sécurité
  end note
fork again
  :Logger événement;
  note right: "password_reset_requested"
fork again
  :Incrémenter compteur tentatives;
  note right
    Rate limiting:
    Max 3 par heure
  end note
end fork

:Afficher "Email envoyé";

stop

' --- Partie 2: Utilisateur clique sur lien ---

partition "Reset mot de passe" {
  
  start
  
  :Utilisateur clique lien email;
  
  :Extraire token depuis URL;
  
  :Vérifier token en BD;
  
  if (Token trouvé?) then (non)
    :Afficher "Lien invalide";
    stop
  endif
  
  if (Token expiré?) then (oui)
    :Afficher "Lien expiré";
    :Proposer nouveau lien;
    stop
  endif
  
  :Afficher formulaire nouveau mot de passe;
  
  :Saisir nouveau mot de passe;
  :Confirmer mot de passe;
  
  :Valider formulaire;
  
  if (Mot de passe >= 8 caractères?) then (non)
    :Afficher "Mot de passe trop court";
    stop
  endif
  
  if (Mots de passe correspondent?) then (non)
    :Afficher "Mots de passe différents";
    stop
  endif
  
  :Hasher nouveau mot de passe;
  
  :Mettre à jour mot de passe en BD;
  :Supprimer token reset;
  :Enregistrer passwordChangedAt;
  
  fork
    :Envoyer email confirmation;
    note right
      "Votre mot de passe
      a été modifié"
    end note
  fork again
    :Logger événement;
    note right: "password_reset_completed"
  fork again
    :Invalider toutes sessions actives;
    note right
      Force reconnexion
      sur tous appareils
    end note
  end fork
  
  :Afficher "Mot de passe modifié";
  :Rediriger vers login;
  
  stop
}

@enduml
```

---

## Instructions d'utilisation

### Génération des diagrammes

**Option 1 - En ligne (Recommandé)** :
```
1. Allez sur http://www.plantuml.com/plantuml/
2. Copiez le code UML
3. Collez dans l'éditeur
4. Cliquez "Submit"
5. Téléchargez en PNG/SVG/PDF
```

**Option 2 - VS Code** :
```
1. Installez l'extension "PlantUML"
2. Créez un fichier .puml
3. Collez le code
4. Appuyez Alt+D pour prévisualiser
```

**Option 3 - CLI** :
```bash
# Installation
brew install plantuml  # macOS
sudo apt-get install plantuml  # Linux

# Génération
plantuml activity_diagram.puml

# Génération en SVG
plantuml -tsvg activity_diagram.puml
```

### Personnalisation

Pour modifier les couleurs et styles, ajoutez au début du diagramme :

```plantuml
@startuml
skinparam backgroundColor #FEFEFE
skinparam activity {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
  FontSize 12
  FontColor #000000
}
skinparam activityDiamond {
  BackgroundColor #FFF9C4
  BorderColor #F57C00
}
@enduml
```

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Codes Source UML Diagrammes d'Activité**  
**Version 1.0 - Complet**
