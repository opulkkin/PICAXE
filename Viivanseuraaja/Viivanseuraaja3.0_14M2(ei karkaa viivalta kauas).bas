; Ohjelman nimi: Viivanseuraaja2_14M2.bas

; Tekijä: Olli Pulkkinen

; Tehty: 19.12.2012


; Viivaseuraajan pitäsi pysyä melko hyvin viivan läheisyydessä tällä ohjelmalla. Alussa oletetaan että viiva on 
; antureiden välissä. Jos määriteltyyn aikaan mennessä ei ole havaittu viivaa kummallakaan anturilla, niin käynnistetään 
; viivan etsintä. Tämä toimii s.e. pyöritään siihen suuntaan, missä viiva viimeksi havaittiin ja niin kauan että viiva 
; löytyy taas tai määrätty aikaraja umpeutuu. Jos viiva löytyy, niin jatketaan sen seuraamista. Muutoin lopetetaan 
; liikkuminen.

; Ohjelmassa ei käsitellä sitä, että time-muuttujassa taitaa tulla ylivuototilanne arvon 2^16 - 1 = 65535 jälkeen, 
; eli arvon 65535 jälkeen tulee taas 0, 1, 2,...jne. Ylivuototilanteessa ohjelman toiminta poikkeaa hetkellisesti 
; tavallisesta. Tähän menee kuitenkin yli 18 tuntia ohjelman käynnistymisestä, joten ylivuodolla ei tässä 
; sovelluksessa ole mitään väliä. Mutta periaatteessa joku kauan pyörivä sovellus saattaa kaatua ylivuodon takia, 
; eli se on hyvä pitää mielessä.


; Nimetään uudelleen jalkoja ja muuttujia. Tämä (toivottavasti) selkeyttää koodia.
; ja tekee siitä helpommin ylläpidettävän.


   symbol oikeaA = pinC.1        ; oikea anturi. 08M2:sta käytettäessä laita tähän pin1 pinC.1:n tilalle.

   symbol vasenA = pinC.3        ; vasen anturi. 08M2:sta käytettäessä laita tähän pin3 pinC.1:n tilalle.

   symbol oikeaM = B.4           ; oikea moottori. 08M2:sta käytettäessä laita tähän 4 B.4:n tilalle.

   symbol vasenM = B.1           ; vasen moottori. 08M2:sta käytettäessä laita tähän 0 B.1:n tilalle.          


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
; b6:sta ja b7:sta. Lisäksi myös b8 on käytössä. Joisskin kohti on käyttetty turhankin suurta muistitilaa
; tiedon säilömiseen(esim. viimHav tarvitsisi vain yhden bitin muistitilan ja voitaisiin käyttää
; yhden bitin muistipaikkaa, esim. bit0 jne...Huomaa kuitenkin, että esim. bit0 on w0:n oikeanpuoleisin bitti jne...), 
; mutta eipähän tuo muistitila ihan heti lopu kesken, joten mennään näillä.



; Alustukset

   low oikeaM, vasenM  

   viimHav = 3                 ; Sovitaan, että viimeinen havainto on alussa ollut vasemmalla
				       ; ajanhetkellä 0.
   viimHavAika = 0





; Itse ohjelmakoodi

main:

   
   low oikeaM, vasenM
   
   pause 8
   
   if vasenA = 0 then kaytaOikeaa

   if oikeaA = 0 then kaytaVasenta
   
   gosub haeAikaVali                              
   
   if aikaVali >= maxAika then viivanEtsinta      ; Tässä oleva arvo maxAika määrää sen kuinka kauan odotetaan
   					                    ; viivahavainnosta ennen poikkeustoimien käynnistymistä
                                                  ; ViivanEtsinta käynnistyy jos havainnosta on kulunut 
                                                  ; enenmmän kuin maxAika. 
   high oikeaM, vasenM
   
   pause 10
   
   if vasenA = 0 then kaytaOikeaa

   if oikeaA = 0 then kaytaVasenta

   gosub haeAikaVali                              ; Näitä kahta riviä ei välttämättä tarvita, 
   
   if aikaVali >= maxAika then viivanEtsinta      ; mutta tuskin ainakaan haittaavat.


   goto main
   
   
kaytaOikeaa:
   
   low oikeaM, vasenM
   
   viimHavAika = time
   
   viimHav = 3   ; viiva havaittu vasemmalla anturilla kun tänne on tultu
   
   high oikeaM
   
   pause 20
   
   goto main
   

kaytaVasenta:
   
   low oikeaM, vasenM
   
   viimHavAika = time
   
   viimHav = 1   ; viiva havaittu oikealla anturilla kun tänne on tultu
   
   high vasenM
   
   pause 20
   
   goto main
   

haeAikaVali:                          ; Tämä aliohjelma laskee aikaVali- muuttujaan sen ajan (sekuntien tarkkuudella)
                                      ; kuinka kauan on kulunut viimeisimmästä viivahavainnosta. Tämän jälkeen palataan
   aikaVali = time - viimHavAika      ; koodissa gosub- käskyn jälkeiselle riville ja jatketaan suoritusta siitä.
						  ;
   return
   
   
viivanEtsinta:

   low oikeaM, vasenM
  
   eAAika = time
   
   
   if viimHav = 1 then    ; viiva havaittu viimeksi oikealla
   
      
      do until vasenA = 0 ; pyöritään (hitaasti) myötäpäivään niin kauan että vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         high vasenM
         
         pause 8
   
         low vasenM
   
         pause 8
   
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then exit   ; ei jäädä pyörimään kuitenkaan ikuisesti vaan luovutetaan.
   				             	 ; tähän voisi mahdollisesti laittaa suoraan hypyn lopetukseen...kokeile.
      loop 
       
  else                    ; viiva havaittu viimeksi vasemmalla
   
      
      do until oikeaA = 0 ; pyöritään (hitaasti) vastapäivään niin kauan että vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         high oikeaM
         
         pause 8
   
         low oikeaM
   
         pause 8
   
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then exit   ; ei jäädä pyörimään kuitenkaan ikuisesti vaan luovutetaan.
                                           ; tähän voisi mahdollisesti laittaa suoraan hypyn lopetukseen
      loop 
       
   endif
   
   if eKAika >= eMaxAika then lopetus   ;lopetetaan ohjelma pomppaamalla lopetukseen
   
   
   goto main                   ; aloitetaan koko systeemi alusta.
   
   
   
   
lopetus:
 
  low oikeaM, vasenM

  ;ohjelma loppuu tähän 
  
  
 