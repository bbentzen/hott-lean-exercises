/-
Copyright (c) 2016 Bruno Bentzen. All rights reserved.
Released under the Apache License 2.0 (see "License");

Theorems and exercises of the HoTT book (Chapter 4)
-/

import .ch2 .ch3 

open eq prod unit bool sum sigma ua funext nat lift

/- ************************************** -/
/-    Ch.4 Equivalences                   -/
/- ************************************** -/

/- §4.1 (Quasi-inverses)  -/

 variables {A B C X Z: Type} 

 universe variables i j

 -- Lemma 4.1.1 

 -- Useful lemmas of preservation of equivalence by type formers

 definition prod_preserves_equiv {A B : Type.{i}} {A' B' : Type.{j}} (e₁ : A ≃ B) (e₂ : A' ≃ B') :
     A × A' ≃  B × B' :=
 by induction (ua e₁); induction (ua e₂); apply typeq_refl _

 definition sigma_preserves_equiv {X : Type} {A B : X → Type} (e : Π (x : X), A x ≃ B x ) :
     (Σ (x : X), A x)  ≃  Σ (x : X), B x :=
 let sigeq := λ w, ⟨(pr1 w), (pr1 (e (pr1 w))) (pr2 w) ⟩ in
 let siginv := λ w', ⟨(pr1 w'),
    pr1 (isequiv_to_qinv (pr1 (e (pr1 w'))) (pr2 (e (pr1 w')))) (pr2 w') ⟩ in
 have comp : sigeq ∘ siginv ~ id _, from
  λ w', sigma.rec_on w' (λ w1' w2', sigma_eq ⟨ refl w1',
  (pr1 (pr2 (isequiv_to_qinv (pr1 (e w1')) (pr2 (e w1'))))) w2' ⟩),
 have uniq : siginv ∘ sigeq ~ id _, from
  λ w, sigma.rec_on w (λ w1 w2, sigma_eq ⟨refl w1,
  (pr2 (pr2 (isequiv_to_qinv (pr1 (e w1)) (pr2 (e w1))))) w2 ⟩),
 ⟨sigeq, (⟨siginv, comp⟩, ⟨siginv, uniq⟩)⟩

 definition pi_preserves_equiv {X : Type} {A B : X → Type} (e : Π (x : X), A x ≃ B x) :
     (Π (x : X), A x) ≃ (Π (x : X), B x) :=
 ⟨(λ f x, (pr1 (e x)) (f x)) , 
  (⟨(λ g x, (pr1 (pr1 (pr2 (e x)))) (g x)), 
  begin
   intro f, apply funext, intro x, 
   exact (show pr1 (e x) ((pr1 (pr1 (pr2 (e x)))) (f x)) = f x,
    from (pr2 (pr1 (pr2 (e x)))) (f x) ) 
  end 
  ⟩,
 ⟨(λ g x, (pr1 (pr2 (pr2 (e x)))) (g x)),
  begin
    intro f, apply funext, intro x, 
    exact (show ((pr1 (pr2 (pr2 (e x)))) ((pr1 (e x)) (f x)) ) = f x,
     from (pr2 (pr2 (pr2 (e x)))) (f x) )
  end
 ⟩)⟩

 -- The "funext" version of quasi-inverse

 definition funext_qinv {A B : Type.{i}} (f : A → B) :
     (Σ (g : B → A), f ∘ g = id B × g ∘ f = id A)  ≃  Σ (g : B → A), f ∘ g ~ id B × g ∘ f ~ id A :=
 have pair_qinv :
   Π (f : A → B) (g : B → A), (f ∘ g = id B × g ∘ f = id A)  ≃  (f ∘ g ~ id B × g ∘ f ~ id A),
 from λ f g, prod_preserves_equiv ⟨happly, fun_extensionality⟩ ⟨happly, fun_extensionality⟩,
 sigma_preserves_equiv (pair_qinv f)
 
 -- Sigma commutes with the product type

 definition sig_prod_comm :     
     (Σ (g : A → A), (g = id A) × (g = id A))  ≃ (Σ (g : A → A) (p : g = id A), (g = id A)) :=
 let f_sig_prod := λ w, ⟨pr1 w, ⟨pr1 (pr2 w), pr2 (pr2 w)⟩⟩ in
 let g_sig_prod := λ h, ⟨ pr1 h, ( pr1 (pr2 h), pr2 (pr2 h) ) ⟩ in
 have η : Π (h : Σ (g : A → A) (p : g = id A), (g = id A)), f_sig_prod (g_sig_prod h) = h, from 
  begin intro h, cases h with h1 h2, cases h2, reflexivity end,
 have ε : Π (w : Σ (g : A → A), (g = id A) × (g = id A)), g_sig_prod (f_sig_prod w) = w, from 
  begin intro w, cases w with w1 w2, cases w2, reflexivity end,
 ⟨f_sig_prod, (⟨g_sig_prod,η⟩,⟨g_sig_prod,ε⟩)⟩

 -- Lemma 4.1.1

 definition qinv_eq {A B : Type.{i}} (e : A ≃ B) :
     qinv (pr1 e) ≃ (Π (x : A), x = x) :=
 have qinv_id : qinv (id A) ≃ (Π (x : A), x = x), from -- proof for f ≡ id, we will transport it over ua_comp
 ((funext_qinv (id A))⁻¹ ∘ sig_prod_comm) ∘ @sigma_assoc (A → A) (λ g, g = id A) (λ h, pr1 h = id A) ∘ 
 (contr_eq_ii (λ h, pr1 h = id A) (@path_contr_r (A → A) (id A))) ∘ ⟨@happly A _ (id A) (id A), fun_extensionality⟩,
 transport _ (ua_comp e) (eq.rec_on (ua e) qinv_id) -- follows by induction on (ua e) ⇒ pr1 e = pr1 (ua (refl A)) = id 

 --

 /- §4.2 (Half adjoint equivalences)  -/ 

 -- Definition 4.2.1 (Half adjoint equivalence)

 definition ishae (f : A → B) : Type :=
     Σ (g : B → A) (ε : f ∘ g ~ id B) (η : g ∘ f ~ id A), Π (x : A), ap f (η x) = ε (f x)

 -- Lemma 4.2.2 (The coherence conditions are logically equivalent)

 definition tau_implies_tau' {f : A → B} {g : B → A} (ε : f ∘ g ~ id B) (η : g ∘ f ~ id A) (τ : Π (x : A), ap f (η x) = ε (f x)) :
     Π (y : B), ap g (ε y) = η (g y) :=
 assume (y : B),
 have nat_ε : ap (f ∘ g) (ε y) = ε (f (g y)), from -- naturality of ε 
   ((ap (f ∘ g) (ε y)) ⬝ₗ (right_inv (ε y))⁻¹) ⬝ 
    conc_assoc (ap (f ∘ g) (ε y)) (ε y) (ε y)⁻¹ ⬝ 
    ((@hom_ap B B (f (g y)) y (f ∘ g) (id B) ε (ε y)) ⬝ᵣ (ε y)⁻¹) ⬝ 
    ((ε (f (g y)) ⬝ₗ ap_func_iv (ε y)) ⬝ᵣ (ε y)⁻¹) ⬝ 
    (conc_assoc (ε (f (g y))) (ε y) (ε y)⁻¹)⁻¹ ⬝ (ε (f (g y)) ⬝ₗ right_inv (ε y)),
 have ap_τ' : ap (g ∘ f) (ap g (ε y)) = ap (g ∘ f) (η (g y)), from 
   (ap_func_iii f g (ap g (ε y)))⁻¹ ⬝        -- we just instantiate τ with (g y) 
    ap (ap g) (ap_func_iii g f (ε y)) ⬝      -- and apply g
    ap (ap g) (nat_ε ⬝ (τ (g y))⁻¹) ⬝
    ap_func_iii f g (η (g y)),
 (ap_func_iv (ap g (ε y)))⁻¹ ⬝  -- cancelation of (g ∘ f) through transport along η
 transport (λ h, ap h (ap g (ε y)) = ap h (η (g y))) (funext η) ap_τ' ⬝
 ap_func_iv (η (g y))

 -- Theorem 4.2.3 (Having a Quasi-inverse implies a Half adjoint equivalence)

 -- Defining τ demands a great deal of computation, so we do it separetly to help the elaborator

 definition ap_ap_eq {x y : A} {p q : x = y} (f : A → B) (α : p = q) :
     ap f p = ap f q :=
 begin induction α, reflexivity end

 definition tau_coro244 (f : A → B) (g : B → A) (ε : f ∘ g ~ id B) (η : g ∘ f ~ id A) (a : A) :
     ap f (η (g (f a))) ⬝ ε (f a) = (ε (f (g (f a)))) ⬝ ap f (η a) :=
 ((ap_ap_eq f (@hom_ap_id A a (g ∘ f) η)) ⬝ᵣ (ε (f a))) ⬝     -- corollary 2.4.4 
 (((ap_ap_eq f (ap_func_iii f g (η a)))⁻¹ ⬝ (ap_func_iii g f (ap f (η a)))) ⬝ᵣ (ε (f a))) ⬝ -- lemma 2.2.2 (iv) [ap and ∘ commutes]
 (@hom_ap B B (f (g (f a))) (f a) (f ∘ g) (id B) ε (ap f (η a))) ⬝ -- application of lemma 2.4.3
 ((ε (f (g (f a)))) ⬝ₗ ap_func_iv (ap f (η a))) -- cancellation of id B

 definition comp1_423 (f : A → B) (g : B → A) (ε : f ∘ g ~ id B) (η : g ∘ f ~ id A) (a : A) :
     (ε (f (g (f a))))⁻¹ ⬝ (ε (f (g (f a)))) ⬝ ap f (η a) = ap f (η a) :=
 ((left_inv (ε (f (g (f a)))) ⬝ᵣ ap f (η a)) ⬝ (lu (ap f (η a)) )⁻¹)

 definition comp2_423 (f : A → B) (g : B → A) (ε : f ∘ g ~ id B) (η : g ∘ f ~ id A) (a : A) :
    (ε (f (g (f a))))⁻¹ ⬝ (ap f (η (g (f a))) ⬝ ε (f a)) = (ε (f (g (f a))))⁻¹ ⬝ ((ε (f (g (f a)))) ⬝ ap f (η a)) :=
 (ε (f (g (f a))))⁻¹  ⬝ₗ tau_coro244 f g ε η a

 definition comp3_423 (f : A → B) (g : B → A) (ε : f ∘ g ~ id B) (η : g ∘ f ~ id A) (a : A) :
   (ε (f (g (f a))))⁻¹ ⬝ ap f (η (g (f a))) ⬝ ε (f a) = (ε (f (g (f a))))⁻¹ ⬝ ((ε (f (g (f a)))) ⬝ ap f (η a)) :=
 (conc_assoc (ε (f (g (f a))))⁻¹ (ap f (η (g (f a)))) (ε (f a)) )⁻¹ ⬝  comp2_423 f g ε η a

 -- Definition of τ

 definition tau_qinv (f : A → B) (g : B → A) (ε : f ∘ g ~ id B) (η : g ∘ f ~ id A) :
     Π (a : A), ap f (η a) = (ε (f (g (f a))))⁻¹ ⬝ ap f (η (g (f a))) ⬝ ε (f a) :=
 λ a, (comp3_423 f g ε η a ⬝ conc_assoc (ε (f (g (f a))))⁻¹ (ε (f (g (f a)))) (ap f (η a)) ⬝ comp1_423 f g ε η a)⁻¹

 -- Theorem 4.2.3 

 definition qinv_to_ishae (f : A → B) :
     qinv f → ishae f :=
 λ e, sigma.rec_on e (λ g w, prod.rec_on w (λ ε η, ⟨g, ⟨ (λ b, (ε (f (g b)))⁻¹ ⬝ ap f (η (g b)) ⬝ ε b) , ⟨η, tau_qinv f g ε η ⟩⟩⟩ ))

 definition ishae_to_qinv (f : A → B) :
     ishae f → qinv f :=
 by intro e; cases e with g e; cases e with ε e; cases e with η τ; apply ⟨g,(ε,η)⟩

 -- The type ishae is a mere proposition

 -- Definition 4.2.4 (Fiber of a map)

 definition fib (f : A → B) (y : B) : Type :=
   Σ (x : A), f x = y

 -- Lemma 4.2.5

 -- Preservation of equivalence by equality and equivalence of inverse paths

 definition eq_preserves_equiv {x y : A} (p q r : x = y) (α : p = q) : 
     (p = r) ≃ (q = r) :=
 by induction α; apply typeq_refl

 definition inv_is_equiv (x y : A) :  
     (x = y) ≃ (y = x) :=
 ⟨(λ p, p⁻¹), ( ⟨(λ p, p⁻¹), λ p, eq.rec idp p ⟩, ⟨(λ p, p⁻¹), λ p, eq.rec idp p ⟩)⟩

 -- This version of lu makes explicit our use of path_conc

 definition lu' {x y : A} (p : x = y) :     
     p = path_conc (refl x) p :=
 eq.rec_on p (refl (refl x)) 

-- Lemma 4.2.5

 definition fib_equiv (f : A → B) (y : B) (h h' : fib f y) :
     h = h' ≃ Σ (γ : pr1 h = pr1 h'), ap f γ ⬝ pr2 h' = pr2 h :=
 have H : Π γ, transport (λ (x : A), f x = y) (γ : pr1 h = pr1 h') (pr2 h) = pr2 h'  ≃  ap f γ⁻¹ ⬝ pr2 h = pr2 h', from
  begin
   intro γ, cases h with a b, cases h' with a' b', esimp at *,
   induction γ, induction b, apply typeq_refl
  end,
 have aps_eq : Π γ, (ap f γ⁻¹ ⬝ pr2 h = pr2 h') ≃ (ap f γ ⬝ pr2 h' = pr2 h), from
 begin
  intro γ, cases h with a b, cases h' with a' b', esimp at *,
  induction γ, induction b, unfold path_inv, esimp at *,
  apply (inv_is_equiv (refl (f a)) b' ∘
    eq_preserves_equiv b' (refl (f a) ⬝ b') (refl (f a)) (lu' b') )
 end,
 (sigma_equiv ∘ (sigma_preserves_equiv H)) ∘ sigma_preserves_equiv aps_eq
 
 -- Theorem 4.2.6

 definition fib_contr (f : A → B) (y : B) (h : ishae f) :
     isContr (fib f y) :=
 begin
  cases h with g h, cases h with ε h, cases h with η τ, apply ⟨(⟨ g y, ε y ⟩ : fib f y),
  show Π (w : fib f y), ⟨g y, ε y⟩ = w, from
    begin
      intro x, cases x with x p,
      apply (transport (λ x, x) (ua (fib_equiv f y ⟨g y, ε y⟩ ⟨x,p⟩))⁻¹ -- transport along lemma 4.2.5:
      ⟨ (ap g p)⁻¹ ⬝ (η x),  -- : g y = x
       by induction p;
       apply ((ap (ap f) (lu' ((η x))))⁻¹ ⬝ τ x) ⟩) -- : ap f ((ap g p)⁻¹ ⬝ (η x)) ⬝ p = ε (f x)
    end⟩ 
 end

 -- Definition 4.2.7 (Left and right inverses)

 definition linv (f : A → B) : Type :=
     Σ (g : B → A), g ∘ f ~ id A

 definition rinv (f : A → B) : Type :=
     Σ (g : B → A), f ∘ g ~ id B

 -- Lemma 4.2.8 

 definition comp_qinv_left (f : A → B) (e : qinv f) :
     qinv (λ (h : C → A), f ∘ h) :=
 sigma.rec_on e (λ g e, prod.rec_on e (λ η ε,
 ⟨(λ (h : C → B), g ∘ h),
  (begin intro h, apply funext, intro x, apply (η (h x)) end, 
   begin intro h, apply funext, intro y, apply (ε (h y)) end ) ⟩ ) )

 definition comp_qinv_right (f : A → B) (e : qinv f) :
     qinv (λ (h : B → C), h ∘ f) :=
 sigma.rec_on e (λ g e, prod.rec_on e (λ η ε,
 ⟨(λ (h : A → C), h ∘ g),
  (begin intro h,
    apply ((comp_assoc f g h)⁻¹ ⬝ funext (h ~ₗ ε)) end, 
   begin intro h,
    apply ((comp_assoc g f h)⁻¹ ⬝ funext (h ~ₗ η)) end ) ⟩ ) )

 -- Lemma 4.2.9

 definition linv_contr {A B : Type.{i}} (f : A → B) (e : qinv f) :
     isContr (linv f) :=
 have linveq : (Σ (g : B → A), g ∘ f = id A)  ≃  Σ (g : B → A), g ∘ f ~ id A, from
   sigma_preserves_equiv (λ g, ⟨happly, fun_extensionality⟩),
 have fib_linv : fib (λ (h : B → A), h ∘ f) (id A) = linv f, from
   transport (λ x, _ = x) (ua linveq) idp,
 transport isContr fib_linv (fib_contr (λ (h : B → A), h ∘ f) (id A)
  (qinv_to_ishae _ (comp_qinv_right f e)))

 definition rinv_contr {A B : Type.{i}} (f : A → B) (e : qinv f) :
     isContr (rinv f) :=
 have rinveq : (Σ (g : B → A), f ∘ g = id B)  ≃  Σ (g : B → A), f ∘ g ~ id B, from
   sigma_preserves_equiv (λ g, ⟨happly, fun_extensionality⟩),
 have fib_rinv : fib (λ (h : B → A), f ∘ h) (id B) = rinv f, from
   transport (λ x, _ = x) (ua rinveq) idp,
 transport isContr fib_rinv (fib_contr (λ (h : B → A), f ∘ h) (id B)
  (qinv_to_ishae _ (comp_qinv_left f e)))

 -- Definition 4.2.10

 definition lcoh (f : A → B) (l : linv f) : Type :=
     Σ (ε : f ∘ (pr1 l) ~ id B), Π (y : B), (pr2 l) ((pr1 l) y) = ap (pr1 l) (ε y)

 definition rcoh (f : A → B) (r : rinv f) : Type :=
     Σ (η : (pr1 r) ∘ f ~ id A), Π (x : A), (pr2 r) (f x) = ap f (η x)

 -- Lemma 4.2.11

 -- Preservation of equivalence by Pi type

 definition pi_preserves_equiv {X : Type} {A B : X → Type.{i}} (H : Π (x : X), A x ≃ B x ) :
     (Π (x : X), A x)  ≃  Π (x : X), B x :=
 ⟨ (λ f x, (pr1 (H x)) (f x)) ,
  (⟨ (λ g x, (pr1 (pr1 (pr2 (H x)))) (g x)) ,
    begin
     intro h, apply funext, intro x,
     apply (pr2 (pr1 (pr2 (H x))) (h x)) -- η (h x)
    end⟩ ,
   ⟨ (λ g x, (pr1 (pr2 (pr2 (H x)))) (g x)) , 
    begin
     intro w, apply funext, intro x,
     apply (pr2 (pr2 (pr2 (H x))) (w x)) -- ε (w x)
    end 
 ⟩) ⟩ 

 definition rcoh_equiv (f : A → B) (r : rinv f) :
    rcoh f r ≃ Π (x : A), ⟨(pr1 r) (f x), (pr2 r) (f x)⟩ = ⟨ x, refl (f x)⟩ :=
 (@dupsig_eq A (λ a, (pr1 r) (f a) = id A a) (λ x η, (pr2 r) (f x) = ap f ((λ x, η) x) ))⁻¹ ∘ -- Π and Σ commutes (Thm 2.15.7 / ac)
 pi_preserves_equiv (λ x, sigma_preserves_equiv (λ η, inv_is_equiv _ _) ∘ -- preservation of equiv by Π, Σ, and inverse path
 (fib_equiv f _ ⟨(pr1 r) (f x), (pr2 r) (f x)⟩  ⟨ x, refl (f x)⟩)⁻¹) -- lemma 4.2.5

 -- Lemma 4.2.12

 definition contr_path_space (x y : A) (c : isContr A) :
     isContr (x = y) :=
 ⟨ (pr2 c x)⁻¹ ⬝ (pr2 c y) ,  λ p, eq.rec_on p (left_inv (pr2 c x)) ⟩ 

 definition rcoh_contr {A B : Type.{i}} (f : A → B) (e : ishae f) (r : rinv f) :
     isContr (rcoh f r) :=
 transport isContr (ua (rcoh_equiv f r))⁻¹ (pi_preserves_contr 
 (show Π (x : A), isContr (⟨(pr1 r) (f x), (pr2 r) (f x)⟩ = ⟨ x, refl (f x)⟩), from
   λ x, contr_path_space _ _ (fib_contr f (f x) e)))

 -- Theorem 4.2.13 (ishae is a mere proposition)

 definition ishae_equiv_rcoh {A B : Type.{i}} (f : A → B) :
     ishae f ≃ Σ (ε : rinv f), rcoh f ε :=
 sigma_preserves_equiv (λ g, sigma_preserves_equiv (λ ε, sigma_preserves_equiv (λ η,
 pi_preserves_equiv (λ x, inv_is_equiv (ap f (η x)) (ε (f x))) ))) ∘ 
 sigma_assoc _ (λ (u : rinv f), rcoh f u)

  definition sigma_preserves_contr {P : A → Type} (a : A) (H : isProp A) (c : Π (a : A), isContr (P a)) :
     isContr (Σ (a : A), P a) :=
 (pr2 (@contr_iff_pprop (Σ (a : A), P a))) ⟨⟨a, pr1 (c a)⟩,
 sigma_preserves_prop H (λ a, pr2 ((pr1 (@contr_iff_pprop (P a))) (c a))) ⟩ 

 definition ishae_is_prop {A B : Type.{i}} (f : A → B) :
     isProp (ishae f) :=
 have ishae_contr : ishae f → isContr (ishae f), 
  from λ e, 
   have r : rinv f,
    from ⟨pr1 e, pr1(pr2 e)⟩,
   have p : isProp (rinv f),
    from pr2 (pr1 (@contr_iff_pprop (rinv f)) (rinv_contr f ((ishae_to_qinv f) e))),
   transport isContr (ua (ishae_equiv_rcoh f))⁻¹ (sigma_preserves_contr r p (λ u, rcoh_contr f e u)),
 transport (λ x, x) (ua prop_eq_contr)⁻¹ ishae_contr

 --

 /- §4.3 (Bi-invertible maps)  -/

 -- Definition 4.3.2  (biinv := isequiv)

 definition biinv (f : A → B) : Type :=
    rinv f × linv f

 -- Products preserve contractible types

 definition prod_preserves_contr (H₁ : isContr A) (H₂ : isContr B) : 
     isContr (A × B) :=
 sigma.rec_on H₁ (λ a p, sigma.rec_on H₂ (λ b q,
  ⟨(a,b), λ x, prod.rec_on x (λ a' b', pair_eq (p a',q b')) ⟩))

 -- Theorem 4.3.2

 definition biinv_is_prop {A B : Type.{i}} (f : A → B) :
     isProp (biinv f) :=
 have biinv_contr : biinv f → isContr (biinv f), from
  λ e, prod_preserves_contr (rinv_contr f (isequiv_to_qinv f e)) (linv_contr f (isequiv_to_qinv f e)),
 transport (λ x, x) (ua prop_eq_contr)⁻¹ biinv_contr

 -- Corollary 4.3.3

 definition biinv_to_ishae (f : A → B) :
     biinv f → ishae f :=
 qinv_to_ishae f ∘ isequiv_to_qinv f

 definition ishae_to_biinv (f : A → B) :
     ishae f → biinv f :=
 qinv_to_isequiv f ∘ ishae_to_qinv f

 definition biinv_eq_ishae {A B : Type.{i}} (f : A → B) :
     biinv f ≃ ishae f :=
 prop_eqv (biinv_is_prop f) (ishae_is_prop f)
 (biinv_to_ishae f) (ishae_to_biinv f)

 --

 /- §4.4 (Contractible maps)  -/ 

 -- Definition 4.4.1

 definition isContrMap (f : A → B) : Type :=
     Π (y : B), isContr (fib f y)

 -- Theorem 4.4.3

 definition contrmap_to_ishae {A B : Type.{i}} (f : A → B) :
     isContrMap f → ishae f :=
 λ P, let g := λ y, pr1 (pr1 (P y)) in let ε := λ y, pr2 (pr1 (P y)) in
 have ητ : rcoh f ⟨g,ε⟩, from
  transport (λ x, x) (ua (rcoh_equiv f ⟨g,ε⟩)⁻¹)
   (λ x, ((pr2 (P (f x))) (⟨ g (f x), ε (f x)⟩ : fib f (f x)))⁻¹ 
   ⬝ (pr2 (P (f x))) (⟨ x, refl (f x)⟩ : fib f (f x))),
 transport (λx,x) (ua(ishae_equiv_rcoh f))⁻¹ ⟨⟨g,ε⟩,ητ⟩

 -- Lemma 4.4.4 (isContrMap is a mere proposition)

 definition contrmap_is_prop {A B : Type.{i}} (f : A → B) :
     isProp (isContrMap f) :=
  pi_preserves_prop (λ y, isContr_is_prop (fib f y))

 -- Theorem 4.4.5

 definition contrmap_eq_ishae {A B : Type.{i}} (f : A → B) :
     isContrMap f ≃ ishae f :=
 prop_eqv (contrmap_is_prop f) (ishae_is_prop f)
 (contrmap_to_ishae f) (λ h, (λ y, fib_contr f y h))

 -- Corollary 4.4.6

 definition cod_inhab_eq {A B : Type.{i}} (f : A → B) (H : B → ishae f) :
     ishae f :=
 transport (λx,x) (ua(contrmap_eq_ishae f)) (λ y, (transport (λx,x) (ua(contrmap_eq_ishae f)⁻¹) (H y)) y)

 definition contrmap_to_isequiv {A B : Type.{i}} (f : A → B) :
     isContrMap f → isequiv f :=
 λ c, ishae_to_biinv f (contrmap_to_ishae f c)

 --

 /- §4.5 (On the definition of equivalences)  -/ 

 --

 -- No formalizable content.

 --

 /- §4.6 (Surjections and embeddings)  -/ 

 -- Definition 4.6.1

 definition isSurjective (f : A → B) : Type :=
     Π (y : B), ║fib f y║

 definition isEmbedding (f : A → B) (x y : A) : Type :=
     ishae (@ap A B f x y)

 -- Theorem 4.6.3

 definition equiv_to_surj_emb (f : A → B) {x y : A} :
    isequiv f → (isSurjective f × isEmbedding f x y) :=
 λ e, (λ y, |pr1 (fib_contr f y (biinv_to_ishae f e))|, biinv_to_ishae _ (id_eq f e))

 definition surj_emb_to_equiv {A B : Type.{i}} (f : A → B)  :
    (isSurjective f × Π (x y : A), isEmbedding f x y) → isequiv f :=
 λ w, prod.rec_on w (λ s e, contrmap_to_isequiv f (λ b,
 pr2 (contr_iff_pprop (fib f b)) ⟨truncation.rec_on (s b) (λ a, a), 
  λ w1 w2, sigma.rec_on w1 (λ x p, sigma.rec_on w2 (λ y q,
    sigma_eq ⟨(pr1 (e x y)) (p ⬝ q⁻¹), sorry ⟩ ))
  ⟩ ) )

 --
