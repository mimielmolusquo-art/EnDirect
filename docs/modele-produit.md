# EnDirect — périmètre V1

## Positionnement
Petites annonces et mise en relation entre particuliers. Les vendeurs affichent un prix demandé et peuvent recevoir des propositions. Le vendeur décide librement et conclut directement la vente.

## Fonctionnalités de la maquette
- Recherche texte et filtres de catégorie.
- Dépôt local d'annonce.
- Lien de contact externe et lien de live externe.
- Favoris et propositions locales.
- Export/import de sauvegarde JSON.
- Données de démonstration visiblement étiquetées.

## Fonctionnalités backend préparées mais pas encore connectées
- Comptes via Supabase Auth.
- Annonces partagées avec sécurité RLS.
- Offres visibles par acheteur et vendeur.
- Favoris par utilisateur.
- Signalements.

## Non inclus volontairement
- Paiements, portefeuille, crédits virtuels, cadeaux payants.
- Classement payant ou attribution automatique au meilleur contributeur.
- Adjudication et gestion intégrée d'enchères.
- Messagerie temps réel ou streaming vidéo natif.

## Limites
Le mode local n'est pas une marketplace multiutilisateur. Pour une vraie mise en service, il faut connecter le backend, tester les politiques d'accès, ajouter les parcours d'authentification et compléter les informations légales. Le statut juridique dépend du fonctionnement réel, pas seulement du vocabulaire.
