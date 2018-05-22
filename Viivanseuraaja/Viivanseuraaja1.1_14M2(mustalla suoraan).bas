; Ohjelman nimi: Viivanseuraaja1.1_14M2(mustalla suoraan).bas

; Tekij‰: Olli Pulkkinen

; Tehty: 20.12.2012


; T‰m‰n ohjelman toiminta on tavallista viivaa seurattaessa l‰hes sama kuin alkuper‰isen
; ohjelman toiminta. Kuitenkin jos tehty rata sis‰lt‰‰ mustien viivojen lis‰ksi mustia alueita
; (siis tulee usein hetki‰ jolloin molemmat anturit ovat mustalla), niin mustilla alueilla
; alkuper‰inen ohjelma k‰‰nt‰‰ aina vasemmalle, mik‰ on (ehk‰) hieman "tyhm‰‰" ja t‰ss‰ 
; ohjelmassa menn‰‰nkin mustilla alueilla suoraan, mik‰ on (ehk‰) j‰rkev‰mp‰‰.

; Ohjelma on 14M2:lle, mutta on helposti muunnettavissa 08M2:lle, kuten alla olevista symbol-
; m‰‰rittelyist‰ huomataan.


   symbol oikeaA = pinC.1        ; Oikea anturi. 08M2:n tapauksessa laita t‰h‰n pinC.1:n paikalle pin1,
                                 ; tosin pinC.1 taitaa sellaisenaankin toimia, koska 08M2:n kaikki pinnit
					   ; kuuluvat ainakin manuaalin mukaan C-porttiin.
  
   symbol vasenA = pinC.3        ; Vasen anturi. 08M2:n tapauksessa laita t‰h‰n pinC.3:n paikalle pin3,
                                 ; tosin pinC.3 taitaa sellaisenaankin toimia.

   symbol oikeaM = B.4           ; Oikea moottori. 08M2:n tapauksessa laita t‰h‰n B.4:n paikalle 4.

   symbol vasenM = B.1           ; Vasen moottori. 08M2:n tapauksessa laita t‰h‰n B.1:n paikalle 0.
   
   
; Itse ohjelmakoodi

main:

   
   low oikeaM, vasenM
   
   pause 8
   
   
   if vasenA = 0 and oikeaA = 0 then kaytaMolempia   ; T‰ss‰ alkaa olemaan jo sen verran monta per‰kk‰ist‰ if-lauseketta
   								     ; ett‰ kannattaisi mietti‰ jotain vaihtoehtoista rakennetta, esim.
   if vasenA = 0 then kaytaOikeaa			     ; select-case rakennetta. Yleens‰ suuri m‰‰r‰ if/else -k‰skyj‰ kan-
                                                     ; nattaa korvata jollakin toisella rakenteella, jolloin melko varmasti 
   if oikeaA = 0 then 			                 ; koodi lyhentyy, on selke‰mp‰‰ ja jopa toimii nopeammin.
   
       goto kaytaVasenta
   
   else
   
       goto kaytaMolempia       ; Nyt vaalealla ajettaessa menn‰‰n hieman hiljempaa kuin tummalla ajettaessa,
   					  ; koska pausen pituudesta low oikeaM, vasenM k‰skyn j‰lkeen tulee hieman pidempi
   endif                        ; if-testausten myˆt‰, mutta vaikutus on k‰yt‰nnˆss‰ t‰ysin marginaalinen.
 
   goto main
   
   
kaytaMolempia:
   
   high oikeaM, vasenM
   
   pause 8
   
   goto main
   
kaytaOikeaa:
   
   low oikeaM, vasenM
    
   high oikeaM
   
   pause 20
   
   goto main
   

kaytaVasenta:
   
   low oikeaM, vasenM
   
   high vasenM
   
   pause 20
   
   goto main