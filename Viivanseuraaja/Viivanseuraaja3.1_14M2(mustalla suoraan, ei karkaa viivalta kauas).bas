; Ohjelman nimi: Viivanseuraaja2_14M2.bas

; Tekijä: Olli Pulkkinen

; Tehty: 19.12.2012


; Viivaseuraajan pitäsi pysyä melko hyvin viivan läheisyydessä tällä ohjelmalla. Alussa oletetaan että viiva on 
; antureiden välissä. Jos määriteltyyn aikaan mennessä ei ole havaittu viivaa kummallakaan anturilla, niin käynnistetään 
; viivan etsintä. Tämä toimii s.e. pyöritään siihen suuntaan, missä viiva viimeksi havaittiin ja niin kauan että viiva 
; löytyy taas tai määrätty aikaraja umpeutuu. Jos viiva löytyy, niin jatketaan sen seuraamista. Muutoin lopetetaan 
; liikkuminen.

; Ohjelmaversiosta 3.0 poiketen nyt ajetaan suoraan jos molemmat anturit ovat tummalla alustalla.
; Ohjelmaversiossa 3.0 käännyttiin vasemmalle. Uusi tapa on ehkä järkevämpi sellaisessa tilanteessa, jossa rata sisältää
; leveitä "mustia teitä" tai muuten mustia alueita, joihin molemmat anturit mahtuvat yhtä aikaa. 


; Ohjelmassa ei käsitellä sitä, että time-muuttujassa taitaa tulla ylivuototilanne arvon 2^16 - 1 = 65535 jälkeen, 
; eli arvon 65535 jälkeen tulee taas 0, 1, 2,...jne. Ylivuototilanteessa ohjelman toiminta poikkeaa hetkellisesti 
; tavallisesta. Tähän menee kuitenkin yli 18 tuntia ohjelman käynnistymisestä, joten ylivuodolla ei tässä 
; sovelluksessa ole mitään väliä. Mutta periaatteessa joku kauan pyörivä sovellus saattaa kaatua ylivuodon takia, 
; eli se on hyvä pitää mielessä.


; Nimetään uudelleen jalkoja ja muuttujia. Tämä (toivottavasti) selkeyttää koodia.
; ja tekee siitä helpommin ylläpidettävän.


   symbol oikeaA = pinC.1        ; oikea anturi

   symbol vasenA = pinC.3        ; vasen anturi

   symbol oikeaM = B.4           ; oikea moottori

   symbol vasenM = B.1           ; vasen moottori          


   symbol viimHav = b8         ; Tieto siitä kummalla puolella viiva on viimeksi havaittu.
				       ; Käytetään muistamisen helpottamiseksi sisääntulona käytettävien 
			             ; jalkojen kanssa yhteensopivaa koodausta ja sovitaan, että
				       ; 1 = oikea puoli ja 3 = vasen puoli.
				    
   symbol viimHavAika = w0     ; Viimeisimmän viivahavainnon aika sekunteina ohjelman
				       ; käynnistymisestä laskettuna(ainakin 4MHz käytettäessä). 

   symbol aikaVali = w1        ; Tähän muuttujaan lasketaan ohjelmassa kulunut aika 
				       ; viimeisimmästä viivahavainnosta.

   symbol maxAika = 1          ; Aika, joka maksimissaan odotetaan viimeisimmästä viivahavainnosta  
					 ; ennen kuin viivan etsintä käynnistetään.
				       
   
   symbol eAAika = w2          ; eAAika = etsinnän aloituksen aika. Tämä otetaan ylös siinä vaiheessa				       
				       ; kun viivaa aletaan etsimään.

   symbol eKAika = w3          ; eKAika = etsintään käytetty aika. Tähän tallennetaan tieto siitä kauanko				       
				       ; viivaa on etsitty.

   symbol eMaxAika = 15         ; Viivan etsintään käytettävä maksimiaika.


; Tällä hetkellä muuttujista ovat käytössä siis yhdeksän ensimmäistä tavumuuttujaa, eli b0 - b8. Tämä johtuu siitä,
; että w0 koostuu b0:sta ja b1:stä, w1 koostuu b2:sta ja b3:sta, w2 koostuu b4:sta ja b5:sta ja w3 koostuu
; b6:sta ja b7:sta. Lisäksi myös b8 on käytössä.


; Alustukset

   low oikeaM, vasenM 

   viimHav = 3                 ; Sovitaan, että viimeinen havainto on alussa ollut vasemmalla
				       ; ajanhetkellä 0.
   viimHavAika = 0





; Itse ohjelmakoodi

main:

   
   low oikeaM, vasenM
   
   
   pause 8
   
   
   if vasenA = 0 and oikeaA = 1 then kaytaOikeaa                      
                                                      
   if vasenA = 1 and oikeaA = 0 then kaytaVasenta     
    
   if vasenA = 0 and oikeaA = 0 then kaytaMolempia     
 
   
   
   gosub haeAikaVali                                 ; Tänne tullaan täsmälleen silloin kun molemmat ovat vaalealla.
   
   if aikaVali >= maxAika then viivanEtsinta         ; Tässä oleva arvo maxAika määrää sen kuinka kauan odotetaan
   					                       ; viivahavainnosta ennen poikkeustoimien käynnistymistä
                                                     ; ViivanEtsinta käynnistyy jos havainnosta on kulunut 
                                                     ; enenmmän kuin maxAika.
   
   goto kaytaMolempia
                                                                 
      
 
   goto main               ; Oikeastaan turha käsky koska tänne asti ei koskaan päästä.


kaytaMolempia:             
 
   if vasenA = 0 or oikeaA = 0 then                ; Päivitetään viivan havaintoaika jos vähintään toinen
                                                   ; anturi on viivalla. Jos molemmat ovat vaalealla, niin
      viimHavAika = time		               ; päivitystä ei tehdä(käytännössä tänne tultaessa molemmat ovat vaalealla      					   ;
                                                   ; tai sitten molemmat ovat mustalla, eli voisi olla myös and or:n tilalla).
   ; Tähän voisi tehdä halutessa esim.             ; Vastaava toiminto voitaisiin toteuttaa myös kahdella
   ; samantyyppisen viimHav arvonnan kuin          ; labelilla kaytaMolempiaVaalealla ja kaytaMolempiaTummalla,
   ; versio 4.1:ssä.                               ; joista vain toisessa päivitettäisiin viimHavAika.
      					   
   endif                               
                                       
   high oikeaM, vasenM
   
   pause 10

   goto main

   
   
kaytaOikeaa:
   
   low oikeaM, vasenM
   
   viimHavAika = time
   
   viimHav = 3   ; viiva havaittu vasemmalla anturilla kun tänne on tultu
   
   high oikeaM
   
   pause 22
   
   goto main
   

kaytaVasenta:
   
   low oikeaM, vasenM
   
   viimHavAika = time
   
   viimHav = 1   ; viiva havaittu oikealla anturilla kun tänne on tultu
   
   high vasenM
   
   pause 22
   
   goto main

   

haeAikaVali:                          ; Tämä aliohjelma laskee aikaVali- muuttujaan sen ajan (sekuntien tarkkuudella)
                                      ; kuinka kauan on kulunut viimeisimmästä viivahavainnosta. Tämän jälkeen palataan
   aikaVali = time - viimHavAika      ; koodissa gosub- käskyn jälkeiselle riville ja jatketaan suoritusta siitä.
						  ;
   return
   
   
viivanEtsinta:

   low oikeaM, vasenM
  
   eAAika = time
   
   
   if viimHav = 1 then   ; viiva havaittu viimeksi oikealla
   
      
      do until vasenA = 0 ; pyöritään (hitaasti) myötäpäivään niin kauan että vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         high vasenM
         
         pause 10
   
         low vasenM
   
         pause 10
   
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then lopetus   ; ei jäädä pyörimään kuitenkaan ikuisesti vaan luovutetaan.
                                              ; ja pompataan lopetukseen.
            
      loop 
       
   else                   ; viiva havaittu viimeksi vasemmalla
   
      
      do until oikeaA = 0 ; pyöritään (hitaasti) vastapäivään niin kauan että vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         high oikeaM
         
         pause 10
   
         low oikeaM
   
         pause 10
   
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then lopetus   ; ei jäädä pyörimään kuitenkaan ikuisesti vaan luovutetaan.
                                              ; ja pompataan lopetukseen.
      loop 
       
   endif
   
   if eKAika >= eMaxAika then lopetus   ;lopetetaan ohjelma pomppaamalla lopetukseen
   
   
   goto main                             ; aloitetaan koko systeemi alusta.
   
   
   
   
lopetus:
 
  low oikeaM, vasenM

  ;ohjelma loppuu tähän. 
  
  
 