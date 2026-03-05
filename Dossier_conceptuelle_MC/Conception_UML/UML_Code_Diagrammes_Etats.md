# Code Source UML - Diagrammes d'États MoroccoCheck
## Codes PlantUML pour tous les diagrammes d'états

*Document créé le 16 janvier 2026*

---

## Table des Matières

1. [États d'un Utilisateur](#1-états-dun-utilisateur)
2. [États d'un Check-In](#2-états-dun-check-in)
3. [États d'un Avis (Review)](#3-états-dun-avis-review)
4. [États d'un Site Touristique](#4-états-dun-site-touristique)
5. [États d'un Abonnement](#5-états-dun-abonnement)
6. [États d'un Paiement](#6-états-dun-paiement)
7. [États d'une Photo](#7-états-dune-photo)
8. [États d'une Notification](#8-états-dune-notification)
9. [États d'un Badge](#9-états-dun-badge)
10. [États d'une Session](#10-états-dune-session)

---

## 1. États d'un Utilisateur

```plantuml
@startuml UserStates

[*] --> PendingVerification : Inscription

state PendingVerification {
  [*] --> EmailNotVerified
  EmailNotVerified --> EmailVerified : Clic lien vérification
  EmailNotVerified --> EmailNotVerified : Renvoyer email
  
  EmailVerified --> PhoneNotVerified : Email vérifié
  PhoneNotVerified --> PhoneVerified : Code SMS validé
  PhoneNotVerified --> PhoneNotVerified : Renvoyer code
}

PendingVerification --> Active : Vérification complète

state Active {
  [*] --> Tourist
  Tourist --> Contributor : Atteindre niveau 3
  Contributor --> Professional : Upgrade compte
  Professional --> Professional : Renouveler abonnement
  
  state "Contributor" as Contributor {
    [*] --> Bronze
    Bronze --> Silver : Niveau 5
    Silver --> Gold : Niveau 10
    Gold --> Platinum : Niveau 20
  }
}

Active --> Inactive : 180 jours inactivité
Inactive --> Active : Reconnexion

Active --> Suspended : Violation règles
Suspended --> Active : Appel résolu
Suspended --> Banned : Violations répétées

Active --> Banned : Fraude détectée
Suspended --> Banned : Violations graves

Banned --> [*]

note right of PendingVerification
  Durée max: 30 jours
  Après: compte supprimé
  
  Actions limitées:
  - Consultation sites
  - Pas de check-in
  - Pas d'avis
end note

note right of Active
  Utilisateur actif complet
  
  Permissions selon rôle:
  - Tourist: Lecture, favoris
  - Contributor: + Check-in, avis
  - Professional: + Gestion site
end note

note right of Suspended
  Suspension temporaire
  
  Durée: 7-30 jours
  
  Raisons:
  - Spam
  - Contenu inapproprié
  - Faux avis
  
  Actions: Aucune
end note

note bottom of Banned
  Bannissement permanent
  
  Raisons:
  - Fraude
  - Violations répétées
  - Activité malveillante
  
  Compte supprimé après 90j
end note

@enduml
```

---

## 2. États d'un Check-In

```plantuml
@startuml CheckInStates

[*] --> Creating : Utilisateur initie check-in

state Creating {
  [*] --> ValidatingLocation
  ValidatingLocation --> LocationValid : GPS dans rayon 100m
  ValidatingLocation --> LocationInvalid : GPS hors rayon
  
  LocationValid --> FillingForm
  FillingForm --> FormComplete : Formulaire rempli
  FormComplete --> UploadingPhoto : Ajouter photo (optionnel)
  UploadingPhoto --> PhotoUploaded
  UploadingPhoto --> FormComplete : Annuler photo
  FormComplete --> PhotoUploaded : Sans photo
}

LocationInvalid --> [*] : Erreur affichée

PhotoUploaded --> Validating : Soumettre

state Validating {
  [*] --> CheckingCooldown
  CheckingCooldown --> CooldownOK : Pas de check-in récent
  CheckingCooldown --> CooldownViolation : Check-in < 24h
  
  CooldownOK --> CheckingData
  CheckingData --> DataValid : Données valides
  CheckingData --> DataInvalid : Erreurs
}

CooldownViolation --> [*] : Refusé
DataInvalid --> Creating : Corrections demandées

DataValid --> PendingModeration : Envoi modération

state PendingModeration {
  [*] --> QueuedForReview
  QueuedForReview --> UnderReview : Modérateur assigné
  
  state UnderReview {
    [*] --> CheckingDistance
    CheckingDistance --> CheckingPhoto
    CheckingPhoto --> CheckingStatus
    CheckingStatus --> CheckingHistory
  }
}

PendingModeration --> Approved : Modérateur approuve
PendingModeration --> Rejected : Modérateur rejette
PendingModeration --> Flagged : Informations suspectes

Flagged --> PendingModeration : Utilisateur répond
Flagged --> Rejected : Délai expiré (7 jours)

state Approved {
  [*] --> UpdatingSiteFreshness
  UpdatingSiteFreshness --> AwardingPoints
  AwardingPoints --> CheckingBadges
  CheckingBadges --> NotifyingUser
}

Approved --> Active : Processus complet

state Active {
  [*] --> Visible
  Visible --> Visible : Affiché sur site
}

Active --> Archived : 90 jours après création
Rejected --> Archived : Après rejet

Archived --> [*]

note right of Creating
  Validations temps réel:
  - Distance <= 100m
  - Cooldown 24h
  - Commentaire < 500 chars
  - Photo < 5MB
end note

note right of PendingModeration
  Délai modération:
  - Normal: 2-24h
  - Prioritaire: < 2h
  
  Priorité si:
  - Utilisateur vérifié
  - Site populaire
  - Changement statut important
end note

note right of Approved
  Actions automatiques:
  1. Mettre à jour fraîcheur site
  2. Calculer points (10 + 5 si photo)
  3. Vérifier badges
  4. Notifier utilisateur
  5. Notifier propriétaire (si pro)
end note

note right of Rejected
  Raisons rejet:
  - Distance incorrecte
  - Photo inappropriée
  - Spam
  - Informations fausses
  - Compte suspect
  
  Utilisateur notifié avec raison
end note

note bottom of Active
  Check-in actif et visible
  
  Utilisé pour:
  - Calcul fraîcheur
  - Statistiques site
  - Historique utilisateur
  
  Archivé après 90 jours
  mais conservé en BD
end note

@enduml
```

---

## 3. États d'un Avis (Review)

```plantuml
@startuml ReviewStates

[*] --> Drafting : Utilisateur commence avis

state Drafting {
  [*] --> WritingContent
  WritingContent --> AddingRatings : Note globale donnée
  AddingRatings --> AddingPhotos : Notes détaillées (optionnel)
  AddingPhotos --> ReviewComplete : Photos ajoutées (optionnel)
  AddingRatings --> ReviewComplete : Sans photos
  
  ReviewComplete --> SavingDraft : Sauvegarder brouillon
  SavingDraft --> WritingContent : Reprendre édition
}

ReviewComplete --> Submitting : Soumettre

state Submitting {
  [*] --> ValidatingContent
  ValidatingContent --> ContentValid : >= 20 caractères
  ValidatingContent --> ContentInvalid : Trop court
  
  ContentValid --> CheckingSpam
  CheckingSpam --> NoSpam : Aucun spam détecté
  CheckingSpam --> PossibleSpam : Mots-clés suspects
}

ContentInvalid --> Drafting : Retour édition

NoSpam --> Published : Publication automatique
PossibleSpam --> PendingModeration : Envoi modération

state PendingModeration {
  [*] --> QueuedForReview
  QueuedForReview --> UnderReview : Modérateur assigné
  
  state UnderReview {
    [*] --> CheckingContent
    CheckingContent --> CheckingPhotos
    CheckingPhotos --> CheckingUserHistory
    CheckingUserHistory --> MakingDecision
  }
}

PendingModeration --> Approved : Approuvé
PendingModeration --> Rejected : Rejeté
PendingModeration --> Flagged : Informations demandées

Flagged --> PendingModeration : Utilisateur modifie
Flagged --> Rejected : Délai expiré (7 jours)

Approved --> Published : Publication

state Published {
  [*] --> Visible
  
  state Visible {
    [*] --> NoOwnerResponse
    NoOwnerResponse --> HasOwnerResponse : Propriétaire répond
    HasOwnerResponse --> HasOwnerResponse : Propriétaire modifie réponse
    
    [*] --> NotHelpful
    NotHelpful --> Helpful : Votes "utile" > 10
    Helpful --> Helpful : Plus de votes
  }
  
  Visible --> Reported : Utilisateur signale
}

Reported --> UnderInvestigation : Modérateur enquête

state UnderInvestigation {
  [*] --> ReviewingReport
  ReviewingReport --> ValidReport : Rapport valide
  ReviewingReport --> InvalidReport : Rapport invalide
}

InvalidReport --> Published : Retour visible
ValidReport --> Hidden : Masquer avis

state Hidden {
  [*] --> NotVisibleToPublic
  NotVisibleToPublic --> NotVisibleToPublic : Caché du public
}

Hidden --> Published : Appel accepté
Hidden --> Deleted : Violation confirmée

Published --> Deleted : Utilisateur supprime
Published --> Edited : Utilisateur modifie

Edited --> PendingModeration : Si modifications majeures
Edited --> Published : Modifications mineures

Deleted --> [*]

note right of Drafting
  Brouillon automatique:
  - Sauvegarde toutes les 30s
  - Conservation 7 jours
  - Restauration possible
  
  Limites:
  - Titre: 100 chars
  - Contenu: 20-2000 chars
  - Photos: max 10
end note

note right of PendingModeration
  Critères modération:
  
  Vérifie:
  - Langage approprié
  - Pas de spam
  - Pas de faux avis
  - Photos pertinentes
  
  Délai: 2-48h
  Priorité selon utilisateur
end note

note right of Published
  Avis public et visible
  
  Actions possibles:
  - Voter "utile"
  - Signaler
  - Partager
  - Propriétaire peut répondre
  
  Modifiable par auteur
  pendant 30 jours
end note

note right of Hidden
  Avis masqué mais conservé
  
  Raisons:
  - Spam confirmé
  - Langage inapproprié
  - Informations fausses
  - Violation CGU
  
  Appel possible sous 15 jours
end note

note bottom of Deleted
  Suppression définitive
  
  Soft delete:
  - Marqué deleted_at
  - Conservation 90 jours
  - Puis purge automatique
  
  Impact:
  - Note site recalculée
  - Points retirés utilisateur
end note

@enduml
```

---

## 4. États d'un Site Touristique

```plantuml
@startuml SiteStates

[*] --> Creating : Création site

state Creating {
  [*] --> EnteringBasicInfo
  EnteringBasicInfo --> EnteringLocation : Nom, catégorie, description
  EnteringLocation --> EnteringContact : Coordonnées GPS
  EnteringContact --> EnteringHours : Contact, website
  EnteringHours --> UploadingPhotos : Horaires
  UploadingPhotos --> SiteComplete : Photos ajoutées
}

SiteComplete --> Draft : Sauvegarder brouillon

state Draft {
  [*] --> Editing
  Editing --> Editing : Modifications
}

Draft --> Submitting : Soumettre pour validation

state Submitting {
  [*] --> ValidatingData
  ValidatingData --> DataValid : Données complètes
  ValidatingData --> DataInvalid : Données manquantes
}

DataInvalid --> Draft : Retour édition

DataValid --> PendingVerification : Envoi vérification

state PendingVerification {
  [*] --> QueuedForReview
  QueuedForReview --> UnderReview : Modérateur assigné
  
  state UnderReview {
    [*] --> VerifyingLocation
    VerifyingLocation --> VerifyingInfo
    VerifyingInfo --> VerifyingPhotos
    VerifyingPhotos --> CheckingDuplicates
  }
}

PendingVerification --> Verified : Approuvé
PendingVerification --> Rejected : Rejeté
PendingVerification --> NeedsClarification : Info demandées

NeedsClarification --> Draft : Créateur modifie
NeedsClarification --> Rejected : Délai expiré (15 jours)

Rejected --> [*] : Site refusé

Verified --> Published : Publication

state Published {
  [*] --> Active
  
  state Active {
    [*] --> Unclaimed
    Unclaimed --> ClaimPending : Professionnel demande
    ClaimPending --> Claimed : Revendication validée
    Claimed --> Claimed : Site géré par pro
    
    [*] --> CalculatingFreshness
    CalculatingFreshness --> Fresh : Score >= 80
    CalculatingFreshness --> Recent : Score >= 50
    CalculatingFreshness --> Old : Score >= 20
    CalculatingFreshness --> Obsolete : Score < 20
    
    Fresh --> Fresh : Check-ins récents
    Fresh --> Recent : Baisse activité
    Recent --> Fresh : Nouvelle activité
    Recent --> Old : Pas de check-in 7j
    Old --> Recent : Nouveau check-in
    Old --> Obsolete : Pas de check-in 30j
    Obsolete --> Old : Check-in récent
  }
  
  Active --> Reported : Signalement
  Active --> UnderMaintenance : Propriétaire met à jour
}

Reported --> UnderInvestigation : Modérateur enquête

state UnderInvestigation {
  [*] --> ReviewingReport
  ReviewingReport --> ValidIssue : Problème confirmé
  ReviewingReport --> InvalidReport : Faux signalement
}

InvalidReport --> Published : Retour actif
ValidIssue --> Suspended : Suspension temporaire

state Suspended {
  [*] --> NotVisible
  NotVisible --> NotVisible : Caché du public
}

Suspended --> Published : Problème résolu
Suspended --> Closed : Violations graves

state UnderMaintenance {
  [*] --> TemporarilyUnavailable
  TemporarilyUnavailable --> TemporarilyUnavailable : En maintenance
}

UnderMaintenance --> Published : Maintenance terminée

state Closed {
  [*] --> ClosedTemporarily : Fermeture temporaire
  [*] --> ClosedPermanently : Fermeture définitive
  
  ClosedTemporarily --> ClosedTemporarily : Rénovation, saison, etc.
  ClosedPermanently --> ClosedPermanently : Business fermé
}

ClosedTemporarily --> Published : Réouverture
ClosedPermanently --> Archived : Après 90 jours

Published --> Archived : Inactivité 1 an

Archived --> [*] : Purge après 2 ans

note right of Creating
  Champs obligatoires:
  - Nom
  - Catégorie
  - Latitude/Longitude
  - Adresse
  - Description (min 50 chars)
  
  Optionnels:
  - Horaires
  - Contact
  - Prix
  - Équipements
end note

note right of PendingVerification
  Vérifications:
  1. Coordonnées GPS valides
  2. Pas de doublon (rayon 50m)
  3. Informations cohérentes
  4. Photos de qualité
  5. Catégorie appropriée
  
  Délai: 24-72h
end note

note right of Published
  Site public et visible
  
  Calcul fraîcheur:
  - Toutes les 6 heures
  - Basé sur check-ins
  - Basé sur avis
  - Basé sur updates
  
  Couleurs:
  - Vert: < 24h
  - Orange: < 7j
  - Rouge: < 30j
  - Gris: > 30j
end note

note right of Claimed
  Site réclamé par propriétaire
  
  Avantages:
  - Répondre aux avis
  - Modifier infos
  - Analytics détaillés
  - Badge "Vérifié"
  - Priorité support
  
  Nécessite abonnement
end note

note bottom of Archived
  Site archivé mais conservé
  
  Raisons:
  - Inactivité prolongée
  - Business fermé
  - Doublon résolu
  
  Restauration possible
  sur demande
  
  Purge après 2 ans
end note

@enduml
```

---

## 5. États d'un Abonnement

```plantuml
@startuml SubscriptionStates

[*] --> SelectingPlan : Professionnel choisit plan

state SelectingPlan {
  [*] --> ViewingPlans
  ViewingPlans --> BasicSelected : Sélectionne BASIC
  ViewingPlans --> ProSelected : Sélectionne PRO
  ViewingPlans --> PremiumSelected : Sélectionne PREMIUM
  
  BasicSelected --> ChoosingCycle
  ProSelected --> ChoosingCycle
  PremiumSelected --> ChoosingCycle
  
  ChoosingCycle --> Monthly : Mensuel
  ChoosingCycle --> Quarterly : Trimestriel (-10%)
  ChoosingCycle --> Yearly : Annuel (-20%)
}

Monthly --> CreatingSubscription
Quarterly --> CreatingSubscription
Yearly --> CreatingSubscription

state CreatingSubscription {
  [*] --> GeneratingInvoice
  GeneratingInvoice --> WaitingPayment
}

WaitingPayment --> ProcessingPayment : Utilisateur confirme

state ProcessingPayment {
  [*] --> ContactingStripe
  ContactingStripe --> VerifyingPayment
  VerifyingPayment --> PaymentSuccessful : Paiement accepté
  VerifyingPayment --> PaymentFailed : Paiement refusé
}

PaymentSuccessful --> Active : Activation

state Active {
  [*] --> CurrentPeriod
  
  state CurrentPeriod {
    [*] --> Monitoring
    Monitoring --> ApproachingRenewal : 7 jours avant fin
    ApproachingRenewal --> ApproachingRenewal : Rappels envoyés
  }
  
  CurrentPeriod --> Renewing : Date renouvellement
}

Renewing --> ProcessingRenewal

state ProcessingRenewal {
  [*] --> ChargingPaymentMethod
  ChargingPaymentMethod --> RenewalSuccessful : Paiement OK
  ChargingPaymentMethod --> RenewalFailed : Paiement KO
}

RenewalSuccessful --> Active : Nouveau cycle
RenewalFailed --> PastDue : Paiement échoué

state PastDue {
  [*] --> GracePeriod
  GracePeriod --> RetryPayment : Tentative 1 (J+1)
  RetryPayment --> RetryPayment : Tentatives 2,3 (J+3, J+5)
  RetryPayment --> PaymentRecovered : Paiement réussi
  RetryPayment --> GracePeriodExpired : 3 échecs
}

PaymentRecovered --> Active : Réactivation
GracePeriodExpired --> Suspended : Suspension

state Suspended {
  [*] --> FeaturesDisabled
  FeaturesDisabled --> FeaturesDisabled : Fonctionnalités limitées
}

Suspended --> Active : Paiement régularisé
Suspended --> Cancelled : 30 jours suspension

Active --> Paused : Utilisateur met en pause

state Paused {
  [*] --> OnHold
  OnHold --> OnHold : En pause (max 90 jours)
}

Paused --> Active : Utilisateur reprend
Paused --> Cancelled : Délai expiré

Active --> Upgrading : Changement plan supérieur

state Upgrading {
  [*] --> CalculatingProration
  CalculatingProration --> ChargingDifference
  ChargingDifference --> UpgradeComplete
}

UpgradeComplete --> Active : Nouveau plan activé

Active --> Downgrading : Changement plan inférieur

state Downgrading {
  [*] --> ScheduledForEndOfPeriod
  ScheduledForEndOfPeriod --> WaitingPeriodEnd
  WaitingPeriodEnd --> ApplyingDowngrade : Fin période
}

ApplyingDowngrade --> Active : Nouveau plan appliqué

Active --> CancelRequested : Demande annulation

state CancelRequested {
  [*] --> ConfirmingCancellation
  ConfirmingCancellation --> CancellationScheduled : Confirmation
  CancellationScheduled --> WaitingPeriodEnd : Fin période actuelle
}

CancellationScheduled --> Active : Utilisateur annule demande
WaitingPeriodEnd --> Cancelled : Fin période

PaymentFailed --> Cancelled : Échec paiement initial

state Cancelled {
  [*] --> Expired
  Expired --> OfferingReactivation : 30 jours
  OfferingReactivation --> OfferingReactivation : Offres envoyées
}

Cancelled --> Active : Réabonnement
Cancelled --> [*] : Après 90 jours

note right of SelectingPlan
  Plans disponibles:
  
  BASIC - 99 MAD/mois:
  - 1 établissement
  - 50 photos
  - Répondre avis
  - Stats basiques
  
  PRO - 199 MAD/mois:
  - 3 établissements
  - 200 photos
  - Analytics avancés
  - Badge vérifié
  
  PREMIUM - 399 MAD/mois:
  - Illimité
  - Photos illimitées
  - Support prioritaire
  - Featured listing
end note

note right of Active
  Abonnement actif
  
  Fonctionnalités:
  - Toutes fonctionnalités du plan
  - Auto-renouvellement
  - Facturation automatique
  
  Notifications:
  - J-7: Rappel renouvellement
  - J-3: Dernier rappel
  - J-0: Facture envoyée
end note

note right of PastDue
  Période de grâce: 7 jours
  
  Tentatives paiement:
  - J+1: 1ère tentative
  - J+3: 2ème tentative
  - J+5: 3ème tentative
  - J+7: Suspension
  
  Notifications à chaque échec
  avec lien mise à jour carte
end note

note right of Suspended
  Fonctionnalités désactivées:
  - Répondre aux avis
  - Analytics
  - Support prioritaire
  
  Fonctionnalités conservées:
  - Consultation
  - Profil public
  
  Réactivation: Paiement des arriérés
end note

note bottom of Cancelled
  Fin abonnement
  
  Données conservées 90 jours:
  - Historique paiements
  - Préférences
  - Établissements réclamés
  
  Après 90 jours:
  - Perte revendications
  - Données archivées
  
  Réabonnement possible
end note

@enduml
```

---

## 6. États d'un Paiement

```plantuml
@startuml PaymentStates

[*] --> Creating : Création paiement

state Creating {
  [*] --> InitializingPayment
  InitializingPayment --> CreatingPaymentIntent : Stripe Payment Intent
  CreatingPaymentIntent --> PaymentIntentCreated
}

PaymentIntentCreated --> AwaitingConfirmation : Redirection Stripe

state AwaitingConfirmation {
  [*] --> DisplayingCheckout
  DisplayingCheckout --> UserConfirms : Utilisateur valide
  DisplayingCheckout --> UserCancels : Utilisateur annule
}

UserCancels --> Cancelled : Annulation

UserConfirms --> Processing : Envoi Stripe

state Processing {
  [*] --> AuthorizingCard
  AuthorizingCard --> CardAuthorized : Carte valide
  AuthorizingCard --> CardDeclined : Carte refusée
  
  CardAuthorized --> CaptureRequested
  CaptureRequested --> CapturingPayment
  CapturingPayment --> CaptureSuccessful : Capture réussie
  CapturingPayment --> CaptureFailed : Capture échouée
}

CardDeclined --> Failed : Échec autorisation
CaptureFailed --> Failed : Échec capture

CaptureSuccessful --> Succeeded : Paiement réussi

state Succeeded {
  [*] --> ActivatingSubscription
  ActivatingSubscription --> SendingReceipt
  SendingReceipt --> GeneratingInvoice
  GeneratingInvoice --> NotifyingUser
}

Succeeded --> Completed : Processus terminé

state Completed {
  [*] --> Paid
  Paid --> Paid : Paiement finalisé
}

Completed --> RefundRequested : Demande remboursement

state RefundRequested {
  [*] --> ReviewingRefundRequest
  ReviewingRefundRequest --> RefundApproved : Approuvé
  ReviewingRefundRequest --> RefundDenied : Refusé
}

RefundDenied --> Completed : Retour état payé

RefundApproved --> RefundProcessing

state RefundProcessing {
  [*] --> InitiatingRefund
  InitiatingRefund --> ContactingStripe
  ContactingStripe --> RefundInProgress
  RefundInProgress --> RefundSuccessful : Remboursement OK
  RefundInProgress --> RefundFailed : Remboursement KO
}

RefundFailed --> Completed : Retour payé
RefundSuccessful --> Refunded : Remboursé

state Refunded {
  [*] --> FullyRefunded : Remboursement total
  [*] --> PartiallyRefunded : Remboursement partiel
  
  PartiallyRefunded --> PartiallyRefunded : Plusieurs remboursements partiels
  PartiallyRefunded --> FullyRefunded : Dernier remboursement
}

Refunded --> Completed : Si partiel

state Failed {
  [*] --> RecordingFailure
  RecordingFailure --> NotifyingUserFailure
  NotifyingUserFailure --> OfferingRetry
}

Failed --> AwaitingConfirmation : Nouvelle tentative
Failed --> [*] : Abandon après 3 tentatives

Completed --> Disputed : Client conteste

state Disputed {
  [*] --> DisputeOpened
  DisputeOpened --> CollectingEvidence
  CollectingEvidence --> SubmittingEvidence
  SubmittingEvidence --> AwaitingDecision
}

Disputed --> DisputeWon : Gagnant
Disputed --> DisputeLost : Perdant
Disputed --> Completed : Dispute retirée

DisputeWon --> Completed : Paiement conservé
DisputeLost --> Refunded : Remboursement forcé

note right of Creating
  Initialisation paiement:
  - Montant + taxes
  - Devise: MAD
  - Metadata (userId, subscriptionId)
  - Description
  
  Stripe Payment Intent:
  - Idempotency key
  - Customer ID
  - Payment method
end note

note right of Processing
  Traitement Stripe:
  
  1. Autorisation carte
     - Vérification fonds
     - Vérification 3D Secure
  
  2. Capture paiement
     - Débit effectif
     - Confirmation
  
  Délai: < 30 secondes
end note

note right of Succeeded
  Paiement réussi
  
  Actions automatiques:
  1. Activer abonnement
  2. Envoyer reçu email
  3. Générer facture PDF
  4. Notifier utilisateur
  5. Enregistrer transaction
  6. Mettre à jour analytics
end note

note right of Failed
  Raisons d'échec:
  - Fonds insuffisants
  - Carte expirée
  - Carte refusée
  - 3D Secure échoué
  - Erreur technique
  
  Actions:
  - Email utilisateur
  - Suggestions solutions
  - Lien mise à jour carte
  
  Max 3 tentatives automatiques
end note

note bottom of Refunded
  Types de remboursement:
  
  Total:
  - Annulation < 24h
  - Service non fourni
  - Erreur facturation
  
  Partiel:
  - Service partiellement fourni
  - Compensation
  - Goodwill
  
  Délai Stripe: 5-10 jours
end note

note bottom of Disputed
  Gestion des litiges:
  
  Stripe Disputes:
  - Client conteste via banque
  - Délai réponse: 7 jours
  
  Preuves à fournir:
  - Facture
  - Logs d'utilisation
  - Communication client
  - CGV
  
  Frais litige: 15€ si perdu
end note

@enduml
```

---

## 7. États d'une Photo

```plantuml
@startuml PhotoStates

[*] --> Uploading : Upload initié

state Uploading {
  [*] --> SelectingSource
  SelectingSource --> FromCamera : Prendre photo
  SelectingSource --> FromGallery : Choisir galerie
  
  FromCamera --> Captured
  FromGallery --> Selected
  
  Captured --> Compressing
  Selected --> Compressing
  
  Compressing --> UploadingToS3
  UploadingToS3 --> UploadComplete : Upload réussi
  UploadingToS3 --> UploadFailed : Erreur réseau
}

UploadFailed --> [*] : Abandon
UploadFailed --> Uploading : Réessayer

UploadComplete --> PendingProcessing : Traitement

state PendingProcessing {
  [*] --> QueuedForProcessing
  QueuedForProcessing --> Processing
  
  state Processing {
    [*] --> ExtractingMetadata
    ExtractingMetadata --> GeneratingThumbnail
    GeneratingThumbnail --> OptimizingImage
    OptimizingImage --> DetectingContent
  }
}

PendingProcessing --> PendingModeration : Traitement terminé

state PendingModeration {
  [*] --> AutoModeration
  
  state AutoModeration {
    [*] --> CheckingNSFW
    CheckingNSFW --> Safe : Contenu approprié
    CheckingNSFW --> Unsafe : Contenu inapproprié
    
    Safe --> CheckingQuality
    CheckingQuality --> QualityOK : Qualité suffisante
    CheckingQuality --> LowQuality : Mauvaise qualité
  }
}

Unsafe --> Rejected : Rejet automatique
LowQuality --> FlaggedForReview : Vérification manuelle

QualityOK --> Approved : Approbation automatique

FlaggedForReview --> ManualReview

state ManualReview {
  [*] --> QueuedForModerator
  QueuedForModerator --> UnderReview
  
  state UnderReview {
    [*] --> ModeratorChecking
    ModeratorChecking --> ModeratorDeciding
  }
}

ManualReview --> Approved : Modérateur approuve
ManualReview --> Rejected : Modérateur rejette

Approved --> Published : Publication

state Published {
  [*] --> Visible
  
  state Visible {
    [*] --> DisplayedOnSite
    DisplayedOnSite --> Primary : Définie comme principale
    DisplayedOnSite --> Secondary : Photo secondaire
    
    Primary --> Primary : Photo de couverture
    Secondary --> Primary : Promue principale
    Primary --> Secondary : Autre photo promue
  }
  
  Visible --> Reported : Signalement utilisateur
}

Reported --> UnderInvestigation

state UnderInvestigation {
  [*] --> ReviewingReport
  ReviewingReport --> ValidReport : Signalement valide
  ReviewingReport --> InvalidReport : Faux signalement
}

InvalidReport --> Published : Retour visible
ValidReport --> Hidden : Masquer photo

state Hidden {
  [*] --> NotPubliclyVisible
  NotPubliclyVisible --> NotPubliclyVisible : Cachée
}

Hidden --> Published : Appel accepté
Hidden --> Deleted : Violation confirmée

Published --> Deleted : Utilisateur supprime
Published --> Replacing : Utilisateur remplace

Replacing --> Uploading : Nouvelle photo

state Deleted {
  [*] --> MarkedDeleted
  MarkedDeleted --> ScheduledForPurge
}

Deleted --> [*] : Purge après 90 jours

note right of Uploading
  Contraintes upload:
  - Taille max: 5MB
  - Formats: JPG, PNG, WEBP
  - Résolution min: 800x600
  - Résolution max: 4096x4096
  
  Compression automatique:
  - Qualité: 85%
  - Format sortie: WEBP
  - Progressive JPEG
end note

note right of PendingProcessing
  Traitement automatique:
  
  1. Extraction EXIF:
     - Date prise
     - GPS (si dispo)
     - Appareil
     - Paramètres
  
  2. Génération thumbnails:
     - 150x150 (mini)
     - 300x300 (small)
     - 800x600 (medium)
  
  3. Optimisation:
     - Compression
     - Conversion WEBP
     - Strip metadata sensible
  
  4. Détection contenu:
     - Google Vision API
     - Labels
     - Safe Search
end note

note right of PendingModeration
  Modération automatique:
  
  Safe Search scores:
  - Adult: 0-5
  - Violence: 0-5
  - Racy: 0-5
  
  Seuils rejet automatique:
  - Adult > 3
  - Violence > 4
  
  Seuils vérification manuelle:
  - Adult > 2
  - Violence > 3
  - Qualité < 50%
  - Flou excessif
end note

note right of Published
  Photo publiée et visible
  
  Utilisations:
  - Page détails site
  - Carte (marker)
  - Galerie photos
  - Résultats recherche
  
  CDN CloudFront:
  - Cache global
  - Compression Brotli
  - WebP si supporté
  - Lazy loading
end note

note bottom of Deleted
  Suppression soft delete:
  - deleted_at timestamp
  - Photo invisible
  - URLs invalides
  - Conservation 90 jours
  
  Purge automatique:
  - Job quotidien
  - Suppression S3
  - Suppression DB
  - Logs conservés
end note

@enduml
```

---

## 8. États d'une Notification

```plantuml
@startuml NotificationStates

[*] --> Creating : Événement déclenche notification

state Creating {
  [*] --> DeterminingType
  DeterminingType --> LoadingTemplate
  LoadingTemplate --> CheckingPreferences
  CheckingPreferences --> UserOptedIn : Préférences OK
  CheckingPreferences --> UserOptedOut : Désactivé
}

UserOptedOut --> [*] : Notification annulée

UserOptedIn --> Pending : En attente envoi

state Pending {
  [*] --> QueuedByPriority
  
  state QueuedByPriority {
    [*] --> HighPriorityQueue : Priorité haute
    [*] --> NormalPriorityQueue : Priorité normale
    [*] --> LowPriorityQueue : Priorité basse
  }
}

Pending --> Sending : Worker traite

state Sending {
  [*] --> DeterminingChannels
  
  state DeterminingChannels {
    [*] --> SendPush : Push activé
    [*] --> SendEmail : Email activé
    [*] --> SendSMS : SMS activé
    [*] --> SendInApp : Toujours In-App
  }
  
  SendPush --> SendingPush
  SendEmail --> SendingEmail
  SendSMS --> SendingSMS
  SendInApp --> SendingInApp
  
  state SendingPush {
    [*] --> ContactingFCM
    ContactingFCM --> PushSent : Envoi réussi
    ContactingFCM --> PushFailed : Erreur FCM
  }
  
  state SendingEmail {
    [*] --> ContactingSendGrid
    ContactingSendGrid --> EmailSent : Envoi réussi
    ContactingSendGrid --> EmailFailed : Erreur SendGrid
  }
  
  state SendingSMS {
    [*] --> ContactingTwilio
    ContactingTwilio --> SMSSent : Envoi réussi
    ContactingTwilio --> SMSFailed : Erreur Twilio
  }
  
  state SendingInApp {
    [*] --> StoringInDatabase
    StoringInDatabase --> InAppSent
  }
}

PushSent --> Sent
EmailSent --> Sent
SMSSent --> Sent
InAppSent --> Sent

PushFailed --> PartialFailure
EmailFailed --> PartialFailure
SMSFailed --> PartialFailure

state PartialFailure {
  [*] --> RecordingFailure
  RecordingFailure --> SchedulingRetry : Tentative < 3
  RecordingFailure --> GivingUp : Tentative >= 3
}

SchedulingRetry --> Pending : Réessayer plus tard
GivingUp --> Failed : Abandon

state Sent {
  [*] --> Delivered
  Delivered --> Delivered : Notification envoyée
}

Sent --> Opened : Utilisateur ouvre (push/email)
Sent --> Clicked : Utilisateur clique lien
Sent --> Read : Utilisateur marque lu (in-app)

state Opened {
  [*] --> TrackingOpen
  TrackingOpen --> RecordingEngagement
}

state Clicked {
  [*] --> TrackingClick
  TrackingClick --> RecordingEngagement
  RecordingEngagement --> NavigatingToTarget
}

state Read {
  [*] --> MarkingAsRead
  MarkingAsRead --> UpdatingBadgeCount
}

Opened --> Expired : TTL expiré
Clicked --> Expired : TTL expiré
Read --> Expired : TTL expiré
Sent --> Expired : TTL expiré (non ouvert)

state Expired {
  [*] --> NoLongerValid
  NoLongerValid --> NoLongerValid : Expirée
}

Expired --> Archived : Après 30 jours

state Archived {
  [*] --> MovedToArchive
}

Archived --> [*] : Purge après 90 jours

note right of Creating
  Types de notifications:
  
  Gamification:
  - Badge earned (HIGH)
  - Level up (HIGH)
  - Points earned (NORMAL)
  
  Contenu:
  - Review response (NORMAL)
  - Check-in validated (NORMAL)
  - Review helpful (LOW)
  
  Système:
  - Subscription expiring (HIGH)
  - Payment failed (HIGH)
  - Account suspended (HIGH)
  
  Marketing:
  - Weekly digest (LOW)
  - New features (LOW)
end note

note right of Pending
  Files d'attente par priorité:
  
  HIGH (0-5 sec):
  - OTP codes
  - Paiements
  - Sécurité
  
  NORMAL (1-5 min):
  - Badges
  - Avis
  - Check-ins
  
  LOW (5-60 min):
  - Digests
  - Marketing
  
  Rate limiting:
  - Max 1000/sec total
  - Max 10/sec par user
end note

note right of Sending
  Canaux d'envoi:
  
  Push (FCM):
  - iOS & Android
  - Payload < 4KB
  - TTL: 24h
  - Priority: high/normal
  
  Email (SendGrid):
  - HTML + Text
  - Templates dynamiques
  - Tracking opens/clicks
  - Unsubscribe link
  
  SMS (Twilio):
  - Uniquement critiques
  - Max 160 caractères
  - Coût par SMS
  
  In-App:
  - Toujours stocké
  - Badge count
  - Consultation historique
end note

note right of PartialFailure
  Gestion des échecs:
  
  Retry strategy:
  - Tentative 1: Immédiat
  - Tentative 2: +5 min
  - Tentative 3: +30 min
  
  Erreurs courantes:
  - Token FCM invalide
  - Email bounce
  - SMS numéro invalide
  - Rate limit atteint
  
  Actions:
  - Log erreur
  - Update device status
  - Alert si taux échec > 5%
end note

note bottom of Archived
  Archivage notifications:
  
  Période conservation:
  - In-App: 30 jours actif
  - Push: 7 jours logs
  - Email: 90 jours logs
  - SMS: 90 jours logs
  
  Métriques conservées:
  - Taux envoi
  - Taux ouverture
  - Taux clic
  - Taux échec
  
  Purge automatique après 90j
end note

@enduml
```

---

## 9. États d'un Badge

```plantuml
@startuml BadgeStates

[*] --> Locked : Badge créé

state Locked {
  [*] --> NotEarned
  
  state NotEarned {
    [*] --> TrackingProgress
    TrackingProgress --> CalculatingProgress
    CalculatingProgress --> Progress0 : 0%
    CalculatingProgress --> Progress25 : 25%
    CalculatingProgress --> Progress50 : 50%
    CalculatingProgress --> Progress75 : 75%
    
    Progress0 --> Progress25 : Progrès
    Progress25 --> Progress50 : Progrès
    Progress50 --> Progress75 : Progrès
    Progress75 --> Progress100 : Progrès
  }
}

Progress100 --> Unlocking : Conditions remplies

state Unlocking {
  [*] --> VerifyingConditions
  VerifyingConditions --> AllConditionsMet : Toutes OK
  VerifyingConditions --> SomeConditionsMissing : Manque conditions
}

SomeConditionsMissing --> Locked : Retour verrouillé

AllConditionsMet --> Awarding : Attribution

state Awarding {
  [*] --> CreatingUserBadge
  CreatingUserBadge --> AwardingPoints
  AwardingPoints --> CreatingNotification
  CreatingNotification --> LoggingAchievement
}

Awarding --> Earned : Badge obtenu

state Earned {
  [*] --> NewlyEarned
  NewlyEarned --> NotificationSent : Notification envoyée
  NotificationSent --> Acknowledged : Utilisateur voit
  
  Acknowledged --> Displayed : Badge affiché profil
  Acknowledged --> Hidden : Badge caché
  
  state Displayed {
    [*] --> VisibleOnProfile
    VisibleOnProfile --> VisibleOnProfile : Affiché publiquement
  }
  
  state Hidden {
    [*] --> NotVisibleOnProfile
    NotVisibleOnProfile --> NotVisibleOnProfile : Caché du public
  }
  
  Hidden --> Displayed : Utilisateur affiche
  Displayed --> Hidden : Utilisateur cache
}

Earned --> Showcased : Badge mis en avant

state Showcased {
  [*] --> FeaturedOnProfile
  FeaturedOnProfile --> FeaturedOnProfile : Badge principal
}

Showcased --> Earned : Autre badge showcased

note right of Locked
  Badge verrouillé
  
  États utilisateur:
  - Visible dans liste badges
  - Conditions affichées
  - Progression visible
  - Incitation à déverrouiller
  
  Types conditions:
  - Check-ins: X check-ins
  - Reviews: X avis
  - Photos: X photos
  - Level: Niveau X
  - Streak: X jours consécutifs
  - Category: Expert catégorie
  - Region: Explorer ville
end note

note right of NotEarned
  Suivi de progression:
  
  Calcul en temps réel:
  - Après chaque action utilisateur
  - Check-in → Vérifier badges check-in
  - Review → Vérifier badges review
  - Level up → Vérifier badges niveau
  
  Affichage progression:
  - Barre progression 0-100%
  - "Plus que X check-ins"
  - "Plus que X points"
  
  Encouragement:
  - Notification 75% : "Presque!"
  - Notification 90% : "Encore peu!"
end note

note right of Unlocking
  Vérification déverrouillage:
  
  Conditions types:
  
  Simple:
  - checkinsCount >= required
  
  Multiple AND:
  - checkinsCount >= X
  - reviewsCount >= Y
  - level >= Z
  
  Catégorie spécifique:
  - checkinsInCategory('restaurant') >= X
  
  Région spécifique:
  - uniqueCitiesVisited >= X
  
  Streak:
  - consecutiveDaysActive >= X
  
  Toutes conditions = true → Unlock
end note

note right of Awarding
  Attribution badge:
  
  Actions séquentielles:
  1. Créer UserBadge
     - userId, badgeId
     - earnedAt = now()
     - progress = 100%
  
  2. Attribuer points récompense
     - badge.pointsReward
     - Peut déclencher level-up
  
  3. Créer notification
     - Type: BADGE_EARNED
     - Priority: HIGH
     - Animation spéciale UI
  
  4. Logger événement
     - Analytics
     - Leaderboard update
end note

note right of Earned
  Badge obtenu
  
  Options utilisateur:
  - Afficher sur profil (défaut)
  - Cacher du public
  - Mettre en avant (showcase)
  
  Affichage public:
  - Page profil utilisateur
  - Liste badges
  - Réalisations
  
  Gamification:
  - Fierté accomplissement
  - Statut communauté
  - Motivation continue
end note

note bottom of Showcased
  Badge showcase:
  
  Limite: 1 badge en avant
  
  Affichage:
  - Grande taille profil
  - Animation spéciale
  - Badge le plus rare/récent
  
  Utilisé pour:
  - Montrer accomplissement
  - Badge préféré
  - Badge le plus rare
  
  Change automatiquement si:
  - Badge plus rare obtenu
  - Badge événement spécial
  (configurable par user)
end note

@enduml
```

---

## 10. États d'une Session

```plantuml
@startuml SessionStates

[*] --> Creating : Utilisateur se connecte

state Creating {
  [*] --> ValidatingCredentials
  ValidatingCredentials --> CredentialsValid : Email/password OK
  ValidatingCredentials --> CredentialsInvalid : Erreur authentification
}

CredentialsInvalid --> [*] : Login échoué

CredentialsValid --> Generating : Créer session

state Generating {
  [*] --> GeneratingTokens
  GeneratingTokens --> CreatingSessionRecord
  CreatingSessionRecord --> StoringInRedis
  StoringInRedis --> SessionCreated
}

SessionCreated --> Active : Session démarrée

state Active {
  [*] --> Valid
  
  state Valid {
    [*] --> Monitoring
    Monitoring --> RefreshingToken : Token proche expiration
    RefreshingToken --> TokenRefreshed
    TokenRefreshed --> Monitoring
    
    Monitoring --> RecordingActivity : Activité utilisateur
    RecordingActivity --> UpdatingLastSeen
    UpdatingLastSeen --> Monitoring
  }
  
  Valid --> ApproachingExpiration : 2 min avant expiration
}

ApproachingExpiration --> AutoRefreshing : Rafraîchir automatiquement

state AutoRefreshing {
  [*] --> RequestingNewToken
  RequestingNewToken --> ValidatingRefreshToken
  ValidatingRefreshToken --> RefreshTokenValid : Refresh token OK
  ValidatingRefreshToken --> RefreshTokenInvalid : Token invalide/expiré
}

RefreshTokenValid --> Active : Nouveau access token
RefreshTokenInvalid --> Expired : Session expirée

Active --> Expired : TTL dépassé (15 min inactivité)
Active --> LoggingOut : Utilisateur déconnecte

state LoggingOut {
  [*] --> InvalidatingTokens
  InvalidatingTokens --> RemovingFromRedis
  RemovingFromRedis --> AddingToBlacklist
  AddingToBlacklist --> NotifyingDevices
}

LoggingOut --> Terminated : Déconnexion complète

Active --> Suspicious : Activité suspecte détectée

state Suspicious {
  [*] --> AnalyzingActivity
  AnalyzingActivity --> SuspiciousIPChange : IP change drastique
  AnalyzingActivity --> SuspiciousLocation : Localisation impossible
  AnalyzingActivity --> SuspiciousPattern : Pattern anormal
}

Suspicious --> RequiringReauth : Réauthentification demandée

state RequiringReauth {
  [*] --> SendingVerificationCode
  SendingVerificationCode --> WaitingForCode
  WaitingForCode --> CodeValid : Code correct
  WaitingForCode --> CodeInvalid : Code incorrect
  WaitingForCode --> CodeExpired : Timeout (5 min)
}

CodeValid --> Active : Session rétablie
CodeInvalid --> Terminated : 3 tentatives échouées
CodeExpired --> Terminated : Délai expiré

state Expired {
  [*] --> TokenExpired
  TokenExpired --> OfferingRenewal
  OfferingRenewal --> OfferingRenewal : Afficher login
}

Expired --> [*] : Après 7 jours
Terminated --> [*] : Immédiat

Active --> ForcedLogout : Admin force déconnexion

state ForcedLogout {
  [*] --> InvalidatingAllTokens
  InvalidatingAllTokens --> NotifyingUser
}

ForcedLogout --> Terminated

note right of Creating
  Authentification initiale:
  
  Méthodes supportées:
  - Email + Password
  - Google OAuth
  - Facebook OAuth
  - Apple Sign-In
  
  Vérifications:
  - Compte actif
  - Email vérifié
  - Pas banni/suspendu
  - Rate limiting (5/15min)
  
  Si 2FA activé:
  → Demander code avant session
end note

note right of Generating
  Création session:
  
  Access Token (JWT):
  - Durée: 15 minutes
  - Claims: userId, role, permissions
  - Signature: HS256
  
  Refresh Token:
  - Durée: 7 jours
  - Stockage: Redis
  - Rotation automatique
  
  Session Record:
  - sessionId (UUID)
  - userId
  - deviceInfo
  - IP address
  - userAgent
  - createdAt
  - lastSeenAt
  - expiresAt
end note

note right of Active
  Session active:
  
  Activités tracées:
  - API requests
  - Pages visitées
  - Actions effectuées
  - Dernière activité
  
  Mise à jour automatique:
  - lastSeenAt (chaque requête)
  - Refresh token (si proche expiration)
  
  Expiration:
  - Access token: 15 min
  - Refresh token: 7 jours
  - Inactivité: 15 min → prompt
  - Inactivité: 30 min → expire
end note

note right of Suspicious
  Détection activités suspectes:
  
  Déclencheurs:
  - IP change pays différent
  - Localisation impossible
    (Paris puis Tokyo en 1h)
  - Trop de requêtes
  - Pattern bot
  - Accès API anormaux
  
  Actions:
  - Alerte utilisateur (email)
  - Demander réauthentification
  - Bloquer si très suspect
  - Logger pour analyse
end note

note bottom of Terminated
  Fin de session:
  
  Raisons:
  - Déconnexion volontaire
  - Expiration tokens
  - Échec réauthentification
  - Admin force logout
  - Compte suspendu/banni
  
  Actions cleanup:
  - Supprimer de Redis
  - Blacklist access token
  - Invalider refresh token
  - Logger événement
  
  Données conservées:
  - Session history (90j)
  - Login logs (1 an)
end note

@enduml
```

---

## Instructions d'utilisation

### Génération des diagrammes

**Option 1 - PlantUML Online (Recommandé pour débuter)** :
```
1. Allez sur http://www.plantuml.com/plantuml/
2. Copiez le code UML d'un diagramme
3. Collez dans l'éditeur web
4. Cliquez "Submit"
5. Téléchargez en PNG, SVG ou PDF
```

**Option 2 - VS Code (Pour développement)** :
```
1. Installez l'extension "PlantUML"
2. Créez un fichier avec extension .puml
3. Collez le code UML
4. Appuyez Alt+D pour prévisualiser
5. Clic droit → Export pour sauvegarder
```

**Option 3 - Ligne de commande (Pour batch)** :
```bash
# Installation macOS
brew install plantuml

# Installation Linux
sudo apt-get install plantuml graphviz

# Génération PNG
plantuml states.puml

# Génération SVG (vectoriel, meilleure qualité)
plantuml -tsvg states.puml

# Génération tous les .puml du dossier
plantuml *.puml

# Génération avec sortie personnalisée
plantuml -o ./output states.puml
```

### Personnalisation des styles

Ajoutez au début de chaque diagramme :

```plantuml
@startuml

' Couleurs personnalisées pour les états
skinparam state {
  BackgroundColor #E3F2FD
  BorderColor #1976D2
  FontSize 12
  FontColor #000000
  
  ' États spéciaux
  StartColor #4CAF50
  EndColor #F44336
  
  ' États actifs
  BackgroundColor<<Active>> #C8E6C9
  BorderColor<<Active>> #388E3C
  
  ' États d'erreur
  BackgroundColor<<Error>> #FFCDD2
  BorderColor<<Error>> #D32F2F
  
  ' États en attente
  BackgroundColor<<Pending>> #FFF9C4
  BorderColor<<Pending>> #F57C00
}

' Style des transitions
skinparam ArrowColor #1976D2
skinparam ArrowThickness 2

' Style des notes
skinparam note {
  BackgroundColor #FFFDE7
  BorderColor #F57C00
  FontSize 11
}

@enduml
```

### Utilisation des stéréotypes

Pour colorer automatiquement certains états :

```plantuml
@startuml

state Active <<Active>>
state Failed <<Error>>
state Pending <<Pending>>

@enduml
```

### Export haute qualité

```bash
# Export SVG (recommandé pour documentation)
plantuml -tsvg -charset UTF-8 states.puml

# Export PNG haute résolution (300 DPI)
plantuml -tpng -Sdpi=300 states.puml

# Export PDF
plantuml -tpdf states.puml

# Export avec Graphviz DOT
plantuml -tdot states.puml
```

---

## Récapitulatif des Diagrammes d'États

| Diagramme | Nombre d'états | Complexité | Utilisation principale |
|-----------|----------------|------------|------------------------|
| 1. Utilisateur | 9 états | Moyenne | Gestion cycle de vie compte |
| 2. Check-In | 12 états | Haute | Workflow validation check-in |
| 3. Avis (Review) | 10 états | Haute | Modération et publication avis |
| 4. Site Touristique | 14 états | Très haute | Gestion complète site |
| 5. Abonnement | 15 états | Très haute | Facturation et renouvellement |
| 6. Paiement | 13 états | Haute | Transaction et remboursement |
| 7. Photo | 11 états | Moyenne | Upload et modération photos |
| 8. Notification | 12 états | Haute | Envoi multi-canal notifications |
| 9. Badge | 8 états | Moyenne | Gamification et achievements |
| 10. Session | 10 états | Moyenne | Authentification et sécurité |

---

## Points clés des diagrammes

### ✅ Caractéristiques communes

Tous les diagrammes incluent :
- **États initiaux et finaux** clairement définis
- **Transitions conditionnelles** avec conditions explicites
- **États composites** pour regrouper la logique
- **Notes explicatives** détaillant les règles métier
- **États d'erreur** et gestion des exceptions
- **États temporaires** (pending, processing, etc.)

### ✅ Patterns utilisés

1. **Workflow de validation** : Creating → Validating → Approved/Rejected
2. **États avec cooldown** : Active → Suspended → Active
3. **États avec expiration** : Active → Expired → Archived
4. **Modération** : Pending → Under Review → Approved/Rejected/Flagged
5. **Retry logic** : Failed → Retrying → Success/Abandon

---

## 🎉 Phase 1 COMPLÈTE !

| Section | Statut | Fichier |
|---------|--------|---------|
| 1.1 Diagrammes de Séquence | ✅ FAIT | - |
| 1.2 Diagrammes de Classes | ✅ FAIT | UML_Code_Source_Diagrammes_Classes.md |
| 1.3 Diagrammes d'Activité | ✅ FAIT | UML_Code_Diagrammes_Activite.md |
| 1.4 Diagrammes de Composants | ✅ FAIT | UML_Code_Diagrammes_Composants.md |
| 1.5 Diagrammes d'États | ✅ **FAIT** | UML_Code_Diagrammes_Etats.md |

**Félicitations ! La Phase 1 : Conception Détaillée est maintenant 100% complète !** 🚀

---

**Document créé le 16 janvier 2026**  
**MoroccoCheck - Codes Source UML Diagrammes d'États**  
**Version 1.0 - Complet**
