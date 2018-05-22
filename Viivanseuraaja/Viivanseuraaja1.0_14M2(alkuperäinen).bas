; Ohjelman nimi: Viivanseuraaja1.bas

; Tekijä: Olli Pulkkinen

; Tehty: 20.12.2012


; Tämä on alkuperäinen hyväksi havaittu viivanseuraajan ohjelma 14M2:lle. Koodissa on kuitenkin
; nimetty uudelleen jalkoja, mikä toivottavasti helpottaa lukemista ja varsinkin
; ohjelman muokkausta/ylläpitoa. 


   symbol oikeaA = pinC.1        ; oikea anturi

   symbol vasenA = pinC.3        ; vasen anturi

   symbol oikeaM = B.4           ; oikea moottori

   symbol vasenM = B.1           ; vasen moottori
   
   
   
; Itse ohjelmakoodi

main:

   
   low oikeaM, vasenM
   
   pause 8
   
   
   if vasenA = 0 then kaytaOikeaa

   if oikeaA = 0 then kaytaVasenta
   
                                                         
   high oikeaM, vasenM
   
   pause 8
   
   
   if vasenA = 0 then kaytaOikeaa

   if oikeaA = 0 then kaytaVasenta

 
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