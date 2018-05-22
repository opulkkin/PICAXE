; Ohjelman nimi: Viivanseuraaja2_14M2.bas

; Tekij�: Olli Pulkkinen

; Tehty: 19.12.2012


; Viivaseuraajan pit�si pysy� melko hyvin viivan l�heisyydess� t�ll� ohjelmalla. Alussa oletetaan ett� viiva on 
; antureiden v�liss�. Jos m��riteltyyn aikaan menness� ei ole havaittu viivaa kummallakaan anturilla, niin k�ynnistet��n 
; viivan etsint�. T�m� toimii s.e. py�rit��n siihen suuntaan, miss� viiva viimeksi havaittiin ja niin kauan ett� viiva 
; l�ytyy taas tai m��r�tty aikaraja umpeutuu. Jos viiva l�ytyy, niin jatketaan sen seuraamista. Muutoin lopetetaan 
; liikkuminen.

; Ohjelmaversiosta 3.0 poiketen nyt ajetaan suoraan jos molemmat anturit ovat tummalla alustalla.
; Ohjelmaversiossa 3.0 k��nnyttiin vasemmalle. Uusi tapa on ehk� j�rkev�mpi sellaisessa tilanteessa, jossa rata sis�lt��
; leveit� "mustia teit�" tai muuten mustia alueita, joihin molemmat anturit mahtuvat yht� aikaa. 


; Ohjelmassa ei k�sitell� sit�, ett� time-muuttujassa taitaa tulla ylivuototilanne arvon 2^16 - 1 = 65535 j�lkeen, 
; eli arvon 65535 j�lkeen tulee taas 0, 1, 2,...jne. Ylivuototilanteessa ohjelman toiminta poikkeaa hetkellisesti 
; tavallisesta. T�h�n menee kuitenkin yli 18 tuntia ohjelman k�ynnistymisest�, joten ylivuodolla ei t�ss� 
; sovelluksessa ole mit��n v�li�. Mutta periaatteessa joku kauan py�riv� sovellus saattaa kaatua ylivuodon takia, 
; eli se on hyv� pit�� mieless�.


; Nimet��n uudelleen jalkoja ja muuttujia. T�m� (toivottavasti) selkeytt�� koodia.
; ja tekee siit� helpommin yll�pidett�v�n.


   symbol oikeaA = pinC.1        ; oikea anturi

   symbol vasenA = pinC.3        ; vasen anturi

   symbol oikeaM = B.4           ; oikea moottori

   symbol vasenM = B.1           ; vasen moottori          


   symbol viimHav = b8         ; Tieto siit� kummalla puolella viiva on viimeksi havaittu.
				       ; K�ytet��n muistamisen helpottamiseksi sis��ntulona k�ytett�vien 
			             ; jalkojen kanssa yhteensopivaa koodausta ja sovitaan, ett�
				       ; 1 = oikea puoli ja 3 = vasen puoli.
				    
   symbol viimHavAika = w0     ; Viimeisimm�n viivahavainnon aika sekunteina ohjelman
				       ; k�ynnistymisest� laskettuna(ainakin 4MHz k�ytett�ess�). 

   symbol aikaVali = w1        ; T�h�n muuttujaan lasketaan ohjelmassa kulunut aika 
				       ; viimeisimm�st� viivahavainnosta.

   symbol maxAika = 1          ; Aika, joka maksimissaan odotetaan viimeisimm�st� viivahavainnosta  
					 ; ennen kuin viivan etsint� k�ynnistet��n.
				       
   
   symbol eAAika = w2          ; eAAika = etsinn�n aloituksen aika. T�m� otetaan yl�s siin� vaiheessa				       
				       ; kun viivaa aletaan etsim��n.

   symbol eKAika = w3          ; eKAika = etsint��n k�ytetty aika. T�h�n tallennetaan tieto siit� kauanko				       
				       ; viivaa on etsitty.

   symbol eMaxAika = 15         ; Viivan etsint��n k�ytett�v� maksimiaika.


; T�ll� hetkell� muuttujista ovat k�yt�ss� siis yhdeks�n ensimm�ist� tavumuuttujaa, eli b0 - b8. T�m� johtuu siit�,
; ett� w0 koostuu b0:sta ja b1:st�, w1 koostuu b2:sta ja b3:sta, w2 koostuu b4:sta ja b5:sta ja w3 koostuu
; b6:sta ja b7:sta. Lis�ksi my�s b8 on k�yt�ss�.


; Alustukset

   low oikeaM, vasenM 

   viimHav = 3                 ; Sovitaan, ett� viimeinen havainto on alussa ollut vasemmalla
				       ; ajanhetkell� 0.
   viimHavAika = 0





; Itse ohjelmakoodi

main:

   
   low oikeaM, vasenM
   
   
   pause 8
   
   
   if vasenA = 0 and oikeaA = 1 then kaytaOikeaa                      
                                                      
   if vasenA = 1 and oikeaA = 0 then kaytaVasenta     
    
   if vasenA = 0 and oikeaA = 0 then kaytaMolempia     
 
   
   
   gosub haeAikaVali                                 ; T�nne tullaan t�sm�lleen silloin kun molemmat ovat vaalealla.
   
   if aikaVali >= maxAika then viivanEtsinta         ; T�ss� oleva arvo maxAika m��r�� sen kuinka kauan odotetaan
   					                       ; viivahavainnosta ennen poikkeustoimien k�ynnistymist�
                                                     ; ViivanEtsinta k�ynnistyy jos havainnosta on kulunut 
                                                     ; enenmm�n kuin maxAika.
   
   goto kaytaMolempia
                                                                 
      
 
   goto main               ; Oikeastaan turha k�sky koska t�nne asti ei koskaan p��st�.


kaytaMolempia:             
 
   if vasenA = 0 or oikeaA = 0 then                ; P�ivitet��n viivan havaintoaika jos v�hint��n toinen
                                                   ; anturi on viivalla. Jos molemmat ovat vaalealla, niin
      viimHavAika = time		               ; p�ivityst� ei tehd�(k�yt�nn�ss� t�nne tultaessa molemmat ovat vaalealla      					   ;
                                                   ; tai sitten molemmat ovat mustalla, eli voisi olla my�s and or:n tilalla).
   ; T�h�n voisi tehd� halutessa esim.             ; Vastaava toiminto voitaisiin toteuttaa my�s kahdella
   ; samantyyppisen viimHav arvonnan kuin          ; labelilla kaytaMolempiaVaalealla ja kaytaMolempiaTummalla,
   ; versio 4.1:ss�.                               ; joista vain toisessa p�ivitett�isiin viimHavAika.
      					   
   endif                               
                                       
   high oikeaM, vasenM
   
   pause 10

   goto main

   
   
kaytaOikeaa:
   
   low oikeaM, vasenM
   
   viimHavAika = time
   
   viimHav = 3   ; viiva havaittu vasemmalla anturilla kun t�nne on tultu
   
   high oikeaM
   
   pause 22
   
   goto main
   

kaytaVasenta:
   
   low oikeaM, vasenM
   
   viimHavAika = time
   
   viimHav = 1   ; viiva havaittu oikealla anturilla kun t�nne on tultu
   
   high vasenM
   
   pause 22
   
   goto main

   

haeAikaVali:                          ; T�m� aliohjelma laskee aikaVali- muuttujaan sen ajan (sekuntien tarkkuudella)
                                      ; kuinka kauan on kulunut viimeisimm�st� viivahavainnosta. T�m�n j�lkeen palataan
   aikaVali = time - viimHavAika      ; koodissa gosub- k�skyn j�lkeiselle riville ja jatketaan suoritusta siit�.
						  ;
   return
   
   
viivanEtsinta:

   low oikeaM, vasenM
  
   eAAika = time
   
   
   if viimHav = 1 then   ; viiva havaittu viimeksi oikealla
   
      
      do until vasenA = 0 ; py�rit��n (hitaasti) my�t�p�iv��n niin kauan ett� vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         high vasenM
         
         pause 10
   
         low vasenM
   
         pause 10
   
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then lopetus   ; ei j��d� py�rim��n kuitenkaan ikuisesti vaan luovutetaan.
                                              ; ja pompataan lopetukseen.
            
      loop 
       
   else                   ; viiva havaittu viimeksi vasemmalla
   
      
      do until oikeaA = 0 ; py�rit��n (hitaasti) vastap�iv��n niin kauan ett� vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         high oikeaM
         
         pause 10
   
         low oikeaM
   
         pause 10
   
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then lopetus   ; ei j��d� py�rim��n kuitenkaan ikuisesti vaan luovutetaan.
                                              ; ja pompataan lopetukseen.
      loop 
       
   endif
   
   if eKAika >= eMaxAika then lopetus   ;lopetetaan ohjelma pomppaamalla lopetukseen
   
   
   goto main                             ; aloitetaan koko systeemi alusta.
   
   
   
   
lopetus:
 
  low oikeaM, vasenM

  ;ohjelma loppuu t�h�n. 
  
  
 