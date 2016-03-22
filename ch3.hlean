/-
Copyright (c) 2015 Bruno Bentzen. All rights reserved.
Released under the Apache License 2.0 (see "License");

Theorems and exercises of the HoTT book (Chapter 3)
-/

import .ch2 types.bool

open eq prod unit bool sum sigma ua funext nat lift

/- ************************************** -/
/-    Ch.3 Sets and Logic                 -/
/- ************************************** -/

/- §3.1 (Sets and n-types)  -/

 variables {A B P Q Z: Type} 

 -- Definition 3.1.1 :

 definition isSet (A : Type) : Type :=
   Π (x y : A) (p q : x = y), p = q

 -- Example 3.1.2

 definition unit_is_set : isSet(𝟭) :=
 λ (x y : 𝟭) (p q : x = y), ((transport _ (ua (@unit_equiv x y))⁻¹ (λ x y, @unit_eq x y x)) p q)

 -- Example 3.1.3

 definition empty_is_set : isSet(𝟬) :=
 λ (x y : 𝟬) (p q : x=y), (empty.rec_on _ x)

 -- Example 3.1.4

 definition emptyalleq (x y : 𝟬) : x = y := empty.rec_on _ x

/- example : isSet(ℕ) :=
 by intro m n p q; induction m; induction n; exact (transport _ (ua (nat_eq 0 0))⁻¹ (λ x y, unitalleq x y) p q);
   exact (transport _ (ua (nat_eq 0 (succ a)))⁻¹ (λ x y, emptyalleq x y) p q); induction n;
   exact (transport _ (ua (nat_eq (succ a) 0))⁻¹ (λ x y, emptyalleq x y) p q)

-/

 -- Type forming operators preserve sets

 -- Product type

 definition prod_preserves_sets (H₁ : isSet A) (H₂ : isSet B) :
     isSet (A × B) :=
 λ (x y : A × B) (p q : x = y), 
   have H : (ap pr1 p, ap pr2 p) = (ap pr1 q, ap pr2 q), from
     pair_eq (H₁ (pr1 x) (pr1 y) (ap pr1 p) (ap pr1 q),
     H₂ (pr2 x) (pr2 y) (ap pr2 p) (ap pr2 q)),
 (prod_uniq p)⁻¹ ⬝ (ap pair_eq H) ⬝ prod_uniq q

 -- Pi type

 definition pi_preserves_sets (B : A → Type) (H : Π (x : A), isSet (B x)) :
     isSet (Π (x : A), B x) := 
 λ f g p q, have eq : happly p = happly q, from funext (λ x, H x (f x) (g x) ((happly p) x) ((happly q) x)),
 (funext_uniq p)⁻¹ ⬝ (ap funext eq) ⬝ funext_uniq q
 
 -- Homotopy n-types

  definition is_1_Type (A : Type) : Type :=
   Π (x y : A) (p q : x = y) (r s : p = q), r = s

 -- Lemma 3.1.8 (Every set is a 1-type)

 definition set_is_1_type :
     isSet A → is_1_Type A :=
 λ f x y p q r s, let g := f x y p in
 (((lu r) ⬝ ((left_inv (g p) ⬝ᵣ r)⁻¹ ⬝ (((conc_assoc (g p)⁻¹ (g p) r)⁻¹ ⬝ ((g p)⁻¹ ⬝ₗ -- right cancelation of g(p)
 ((id_trans_i p r (g p))⁻¹ ⬝ (apd g r)) ⬝ ((apd g s)⁻¹ ⬝ (id_trans_i p s (g p))))) ⬝ -- computation of g(p) ⬝ r = g(p) ⬝ s
 conc_assoc (g p)⁻¹ (g p) s))) ⬝ (left_inv (g p) ⬝ᵣ s)) ⬝ (lu s)⁻¹ -- left cancelation of g(p)

 -- Example 3.1.8 (The universe is not a type)

 definition bneg_eq :
     𝟮 ≃ 𝟮 :=
 sigma.mk bneg (qinv_to_isequiv bneg (sigma.mk bneg (λ x, bool.rec_on x idp idp,λ x, bool.rec_on x idp idp) ))
 
definition universe_not_set :
     isSet(Type₀) → 𝟬 :=
 λ H, ff_ne_tt (happly (ap sigma.pr1 (((ua_comp bnegeq)⁻¹ ⬝ (ap idtoeqv (H 𝟮 𝟮 (ua bnegeq) (refl 𝟮)))) ⬝ idp⁻¹)) tt)

 --
 
 /- §3.2 (Propositions as types?)  -/

 notation `¬` A := A → 𝟬

 -- Theorem 3.2.2 (Double negation elimination does not hold generally)

 -- Some useful lemmas

 definition trans_f2u (f : Π (A : Type₀), ¬¬A → A) :
     Π (u : ¬¬𝟮), (transport (λ A, A) (ua bneg_eq) (f 𝟮 (transport (λ A : Type₀, ¬¬A) (ua bneg_eq)⁻¹ u)) = (f 𝟮) u) :=
 λ u : ¬¬𝟮, happly ((nondep_trans_pi (ua bneg_eq) (f 𝟮))⁻¹ ⬝ (apd f (ua bneg_eq))) u

 definition trans_dne_lemma (u : ¬¬𝟮) : -- used in ap_ua_lemma
    transport (λ (A : Type₀), ¬¬A) (ua bneg_eq)⁻¹ u = u :=
 funext (λ x , empty.rec_on _ (u x) (transport (λ (A : Type₀), ¬¬A ) (ua bneg_eq)⁻¹ u) u)

 definition trans_ua_lemma (f : Π (A : Type₀), ¬¬A → A) (u : ¬¬𝟮) :  -- used in ap_ua_lemma
    transport (λ (A : Type₀), A) (ua bneg_eq) (f 𝟮 u) = bneg ((f 𝟮) u) :=
 by rewrite [trans_univ (ua bneg_eq) (f 𝟮 u) ⬝ trans_idtoequiv (ua bneg_eq) (f 𝟮 u)]; apply (calc
   bneg (f 𝟮 u) = sigma.pr1 bneg_eq (f 𝟮 u)  : idp
   ...          = sigma.pr1 (idtoeqv (ua bneg_eq)) (f 𝟮 u) :  happly (ap sigma.pr1 (ua_comp bneg_eq)⁻¹) (f 𝟮 u)
   ...          = sigma.pr1 (idtoeqv (ap (λ (a : Type₀), a) (ua bneg_eq))) (f 𝟮 u) :
                    (happly (ap sigma.pr1 (ap idtoeqv (@ap_func_iv Type₀ 𝟮 𝟮 𝟮 (ua bneg_eq)))) (f 𝟮 u))⁻¹  )⁻¹

 definition ap_ua_lemma (f : Π (A : Type₀), ¬¬A → A) (u : ¬¬𝟮) :
     (f 𝟮) u = bneg ((f 𝟮) u) :=
 calc
  (f 𝟮) u = transport (λ (A : Type₀), A) (ua bneg_eq) (f 𝟮 (transport (λ A : Type₀, ¬¬A) (ua bneg_eq)⁻¹ u)) : trans_f2u
  ...     = transport (λ (A : Type₀), A) (ua bneg_eq) (f 𝟮 u) : trans_dne_lemma
  ...     = bneg ((f 𝟮) u) : trans_ua_lemma

 definition prop_324 :
     Π (x : 𝟮), ¬(bneg x = x) :=
 λ x, bool.rec_on x (λ p, ff_ne_tt p⁻¹) (λ p, ff_ne_tt p)

 -- Theorem 3.2.2

 definition no_dne :
     (Π A, ¬¬A → A) → 𝟬 :=
 λ f, (λ (u : ¬¬𝟮), (prop_324 ((f 𝟮) u)) (ap_ua_lemma f u)⁻¹) (λ (nu : ¬𝟮), nu tt)

 -- Remark 3.2.6 (see ch1.ndne)

 -- Corollary 3.2.7

 definition no_lem : --(g : Π A, A ⊎ ¬ A) : 𝟬  :=      
     (Π A, A + ¬ A) → 𝟬 :=
 λ g, no_dne (λ (A : Type₀) (x : ¬¬A), sum.rec_on (g (A)) (λ y, y) (λ y, empty.rec_on _ (x y)))

 --

 /- §3.3 (Mere propositions)  -/

 -- Definition 3.3.1

 definition isProp (A : Type) : Type :=
   Π (x y : A), x = y

 -- Lemma 3.3.2

 definition unit_is_prop : isProp(𝟭) :=
 λ x y, @unit_eq x y x

 -- Lemma 3.3.3

 definition prop_eqv (H₁ : isProp P) (H₂ : isProp Q) : 
     (P → Q) → (Q → P) → (P ≃ Q) :=
 λ f g, have comp_rule : f ∘ g ~ id Q, from λ q, H₂ (f (g q)) q,
 have uniq_rule : g ∘ f ~ id P, from λ p, H₁ (g (f p)) p,
 ⟨ f, ( ⟨g, comp_rule⟩, ⟨g, uniq_rule⟩ ) ⟩

 definition prop_eqv_unit (p₀ : P) (H : isProp P) :
    P ≃ 𝟭 :=
 let f : P → 𝟭 :=  λ p, ⋆ in let g : 𝟭 → P :=  λ x, p₀ in
 prop_eqv H unit_is_prop f g

 -- Lemma 3.3.4 Every mere proposition is a set

 definition prop_is_set :
     isProp(P) → isSet(P) :=
 λ H x y p q, let g := H x in (((lu p) ⬝ ((left_inv (g x) ⬝ᵣ p)⁻¹ ⬝ (((conc_assoc (g x)⁻¹ (g x) p)⁻¹ ⬝ ((g x)⁻¹ ⬝ₗ -- right cancelation of g(x)
 ((id_trans_i x p (g x))⁻¹ ⬝ (apd g p)) ⬝ ((apd g q)⁻¹ ⬝ (id_trans_i x q (g x))))) ⬝ -- computation of g(x) ⬝ p = g(x) ⬝ q
 conc_assoc (g x)⁻¹ (g x) q))) ⬝ (left_inv (g x) ⬝ᵣ q)) ⬝ (lu q)⁻¹ -- left cancelation of g(x)

  -- Lemma 3.3.5 The types isProp and isSet are mere propositions

 definition isProp_is_prop (P : Type) :
     isProp (isProp(P)) :=
 λ H₁ H₂, funext (λ x, funext (λ y, (prop_is_set H₁ x y (H₁ x y) (H₂ x y))))

 definition isSet_is_prop (A : Type) :
     isProp (isSet(A)) :=
 λ H₁ H₂, funext (λ x, funext (λ y, funext (λ p, funext (λ q, set_is_1_type H₁ x y p q (H₁ x y p q) (H₂ x y p q) ))))

 --

 /- §3.4 (Classical vs. intuitionistic logic)  -/

 definition lem : Type :=
    Π (A : Type), (isProp(A) → (A + ¬ A))
 
 definition dne : Type :=
    Π (A : Type), (isProp(A) → (¬¬ A → A))

 -- Definition 3.4.3

 namespace decidable

 definition decidable (A : Type) : Type := A + ¬ A
    
 definition decidable_family (B : A → Type) : Type := Π (a : A), B (a) + ¬ B (a)

 definition decidable_eq (A : Type) : Type := Π (a b : A), (a = b) + ¬ (a = b)

 end decidable

 --

 /- §3.5 (Subsets and propositional resizing)  -/

 -- Lemma 3.5.1

 definition prop_sigma_eq (P : A → Type) (H : Π (x : A), isProp(P(x))) (u v : Σ (x : A), P x) :
     (pr1 u = pr1 v) → u = v :=
 λ p, sigma_eq ⟨p, begin cases u with u1 u2, cases v with v1 v2, esimp at *, induction p, apply ((H u1) u2 v2) end ⟩
 
 -- Definitions of subset and subtype

 definition subset (P : A → Type) {H : Π (x : A), isProp(P(x))} : Type :=
     Σ (x : A), P x

 notation `{` binder `|` x :(scoped P, subset P) `}`  := x

 --

 /- §3.6 (The logic of mere propositions)  -/

 -- Example 3.6.1

 definition prod_preserves_prop (H₁ : isProp A) (H₂ : isProp B) :
     isProp (A × B) :=
 λ x y, prod.rec_on x (λ a b, prod.rec_on y (λ a' b', pair_eq (H₁ a a', H₂ b b')))

 definition sigma_preserves_prop (H₁ : isProp A) (B : A → Type) (H₂ : Π (x : A), isProp (B x)) :
     isProp (Σ (x : A), B x) :=
 λ w w', sigma.rec_on w (λ w1 w2, sigma.rec_on w' (λ w1' w2', sigma_eq ⟨H₁ w1 w1', H₂ w1' (transport B (H₁ w1 w1') w2) w2' ⟩  ))

 -- Example 3.6.2

 definition pi_preserves_prop (H₁ : isProp A) (B : A → Type) (H₂ : Π (x : A), isProp (B x)) :
     isProp (Π (x : A), B x) :=
 λ f g, funext (λ x, H₂ x (f x) (g x))

 definition func_preserves_prop (H₁ : isProp A) (H₂ : isProp B) :
     isProp (A → B) :=
 λ f g, funext (λ x, H₂ (f x) (g x))

 definition neg_preserves_prop (H : isProp A) :
     isProp (¬A) :=
 func_preserves_prop H (λ x y, empty.rec_on _ x)

 -- A + B does not preserve propositions

 definition sum_doesnt_pres_prop :
     (Π (A : Type₀) (B : Type₀) (H₁ : isProp A) (H₂ : isProp B), isProp (A + B)) →  𝟬 :=
 λ f, let H := f 𝟭 𝟭 (λ u v, @unit_eq u v u) (λ u v, @unit_eq u v u) in
 down (encode (inr ⋆) (H (inl ⋆) (inr ⋆)))

 --

 /- §3.7 (Propositional truncation)  -/

 inductive truncation (A : Type) : Type :=
 | mk : A → truncation A

 constant isTrunc (A : Type) : isProp (truncation A) 
 
 notation `║` A `║`  := truncation A
 notation `|` a `|`  := truncation.mk a

 definition lor (P Q : Type) : Type :=
   ║P + Q║

 definition lexists (A : Type) (P : A → Type) : Type :=
   ║(Σ (x : A), P x)║

 notation P `∨` Q  := lor P Q

 notation `∃` binder `,` x :(scoped P, lexists _ P) := x

 -- Truncation commutes with the function type

 definition trunc_distrib (f : ║A → B║) :
     (║A║ → ║B║) :=
 λ a, truncation.rec_on a (λ a', truncation.rec_on f (λ f', |f' a'|) )

 --

 /- §3.8 (The axiom of choice)  -/ 

 --

 /- §3.9 (The principle of unique choice)  -/ 

 -- Lemma 3.9.1

 definition prop_eq_trunc (H : isProp P) :
     P ≃ ║P║ :=
 prop_eqv H (isTrunc P) (λ p, |p|) ( λ x, truncation.rec_on x (λ p, p))

 -- Corollary 3.9.2 (The principle of unique choice)

 definition puc {P : A → Type} (H₁ : Π (x : A), isProp (P x)) (H₂ : Π (x : A), ║P x║) :
     Π (x : A), P x :=
 λ x, (pr1 (prop_eq_trunc (H₁ x))⁻¹) (H₂ x)
 
 --
