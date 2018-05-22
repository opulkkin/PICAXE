; Ohjelman nimi: Viivanseuraaja4.1_14M2.bas

; Tekijä: Olli Pulkkinen

; Tehty: 28.12.2012


; Tämä ohjelma on lähes sama kuin versio 3.1 muuten. mutta nyt nyt mukaan on lisätty infrapunaohjauksen mahdollisuus.
; Alussa on päällä automaattinen viivanseuranta, joka toimii lähes samoin kuin ohjelmaversiossa 3.1. Nyt kuitenkin
; alussa ajetaan suoraan kunnes viiva löytyy tai viivan etsintään käytettävä maksimiaika eMaxAika umpeutuu. Jos viiva
; löytyy aletaan seurata sitä ja jos ei löydy, vaihdetaan etsinnän maksimiajan kuluttua manuaaliohjaukselle.
; Lisäksi tämä ohjelma eroaa versiosta 3.1 s.e jos molemmat anturit ovat mustalla (ajetaan suoraan) niin lisäksi
; "arvotaan" uusiksi kummalla puolella viiva on nähty viimeksi.

; Kaukosäätimellä voidaan milloin tahansa vaihtaa manuaaliohjaukselle. Kun vaihdetaan manuaaliohjaukselta automaatille,
; niin toimitaan samantyyppisesti kuin ohjelman alussa, eli ajetaan suoraan kunnes viiva löytyy tai aikaraja umpeutuu.
; Tarkoitus on siis, että sekä alussa että kytkettäessä automaattiohjaus uudelleen haetaan ensin viivaa suoraan edestä.
; Tällöin siis seuraaja voidaan laittaa hieman kauempaakin menemään kohti viivaa ja sen pitäisi jäädä viivan ympäristöön,
; jos viiva ehditään vain saavuttaa ennen aikarajan umpeutumista. 

; Jos viiva jostain syystä karkaa lopullisesti, niin ei lopeteta ohjelmaa(kuten 3.1-versiossa), vaan pysäytetään
; ja vaihdetaan manuaaliohjaukseen.
 

; Yksi  järkevä päivitys tähän versioon(ja myös muihin) saattaisi olla pwm-ulostulojen käyttö moottorien pyörityksessä, 
; jolloin ei tarvisi turhaan tehdä ohjelman suoritusta keskeyttäviä low/pause-komentoja hitaamman pyörimisen saavuttamiseksi. 
; Tämä ei kuitenkaan taida onnistua 08M2:sta käytettäessä, koska siinä on ainakin manuaalin mukaan vain yksi pwm-tyyppinen
; ulostulo. 14M2:lla luultavasti onnistuisi, mutta infrapunan vastaanoton hoitaminen samalla saattaisi olla hieman
; hankalaa silläkin.

; Koodia alkaa olemaan jo ihan mukavasti, ja erityisesti viivanEtsintä-osiossa koodia saattaisi saada selkeämmäksi ja
; lyhemmäksi esim. aliohjelmien avulla. Tässä kuitenkin ohjelman ensimmäinen versio, toivottavasti toimii yllä kuvatulla
; tavalla :)


   symbol oikeaA = pinC.1        ; Oikea anturi

   symbol vasenA = pinC.3        ; Vasen anturi

   symbol oikeaM = B.4           ; Oikea moottori

   symbol vasenM = B.1           ; Vasen moottori          

   symbol infVastOt = C.4        ;infrapunasignaalin vastaanotto C.4:sta






   symbol viimHav = b8         ; Tieto siitä kummalla puolella viiva on viimeksi havaittu. Jos viiva havaitaan
				       ; molemmilla puolilla, niin tätä arvoa ei muuteta edellisestä arvosta.
				       ; Käytetään muistamisen helpottamiseksi sisääntulona käytettävien 
			             ; jalkojen kanssa yhteensopivaa koodausta ja sovitaan, että
				       ; 1 = oikea puoli ja 3 = vasen puoli.
				    
   symbol viimHavAika = w0     ; Viimeisimmän viivahavainnon aika sekunteina ohjelman
				       ; käynnistymisestä laskettuna(ainakin 4MHz käytettäessä). 

   symbol aikaVali = w1        ; Tähän muuttujaan lasketaan ohjelmassa kulunut aika 
				       ; viimeisimmästä viivahavainnosta.

   symbol maxAika = 2          ; Aika, joka maksimissaan odotetaan viimeisimmästä viivahavainnosta  
					 ; ennen kuin viivan etsintä käynnistetään. Vaihdettu nyt 2:ksi, jotta
				       ; mustalta alueelta voidaan joskus eksyä. Jos tässä on 1, niin ei
                               ; päästä yleensä karkuun(vaatii jo melko erikoisen radan).
                               
   symbol eAAika = w2          ; eAAika = etsinnän aloituksen aika. Tämä otetaan ylös siinä vaiheessa				       
				       ; kun viivaa aletaan etsimään.

   symbol eKAika = w3          ; eKAika = etsintään käytetty aika. Tähän tallennetaan tieto siitä kauanko				       
				       ; viivaa on etsitty.

   symbol eMaxAika = 15         ; Viivan etsintään käytettävä maksimiaika.


   
   
   
   symbol viesti = b9       ; Tähän tallennetaan aina vastaanotettu infrapunasignaali.

   symbol infAika = w5      ; koostuu b10:sta ja b11:sta jotka eivät vielä ole muualla käytössä.
                            ; Käytetään infrapunaohjauksen ja automaattiohjauksen vaihtoon liittyvässä tekniikassa.
   
   
   symbol infAikaVali = w6  ; koostuu b12:sta ja b13:sta jotka eivät vielä ole muualla käytössä.
                            ; Käytetään infrapunaohjauksen ja automaattiohjauksen vaihtoon liittyvässä tekniikassa.



; Alustukset

   low oikeaM, vasenM 

   viimHav = 0                 ; Alustetaan nyt nollaksi toisin kuin ohjelmaversiossa 3.1.
				       
   viimHavAika = 0
 
   viesti = 0
   
   infAika = 0




; Itse ohjelmakoodi

automaatti:

   
   low oikeaM, vasenM
   
   
   irin [5], infVastOt, viesti
   
   if viesti = 7 then
      
      viesti = 0
      
      infAikaVali = time - infAika
       
      if infAikaVali >=2 then      ; Tämä if- testaus on siksi ettei vahingossa pompita
        				     ; nopeasti automaatin ja manuaaliohjauksen välillä.
         infAika = time 
          
         goto manuaalinen
         
      endif   
   
   endif 
   
   
   
   if vasenA = 0 and oikeaA = 1 then kaytaOikeaa                      
                                                      
   if vasenA = 1 and oikeaA = 0 then kaytaVasenta     
    
   if vasenA = 0 and oikeaA = 0 then kaytaMolempia     
 
   
   
   gosub haeAikaVali                                 ; Tänne tullaan täsmälleen silloin kun molemmat ovat vaalealla.
   
   if aikaVali >= maxAika then viivanEtsinta         ; Tässä oleva arvo maxAika määrää sen kuinka kauan odotetaan
   					                       ; viivahavainnosta ennen poikkeustoimien käynnistymistä
                                                     ; ViivanEtsinta käynnistyy jos havainnosta on kulunut 
                                                     ; enenmmän kuin maxAika.
   
   goto kaytaMolempia
                                                                 
      


kaytaMolempia:             
 
   if vasenA = 0 or oikeaA = 0 then                      ; Päivitetään viivan havaintoaika jos vähintään toinen
                                                         ; anturi on viivalla. Jos molemmat ovat vaalealla, niin
      viimHavAika = time		                     ; päivitystä ei tehdä(käytännössä tänne tultaessa molemmat ovat vaalealla      					   ;
                                                         ; tai sitten molemmat ovat mustalla, eli voisi olla myös and or:n tilalla)
      viimHav = time % 2  ; tulos = 0 tai 1	         ; Lisäksi "arvotaan" viimHav uusiksi toisin kuin versiossa 3.1. Tämä tehdään	   .
                                                         ; todella yksinkertaisesti ottamalla jakojäännös modulo 2 time-muuttujasta
                                                         ; Tämä ei todellakaan ole kauhean hyvä "satunnaislukugeneraattori", mutta 
      if viimhav = 0 then                                ; aivan riittävä tässä.
                                                         
         viimHav = 1
      
      else
      
         viimHav = 3
      
      endif
      					   
  
   endif                                
                                       
   high oikeaM, vasenM
   
   pause 10

   goto automaatti

   
   
kaytaOikeaa:
   
   viimHavAika = time
   
   viimHav = 3            ; Viiva havaittu vasemmalla anturilla kun tänne on tultu
   
   high oikeaM
   
   pause 20
   
   goto automaatti
   

kaytaVasenta:
   
   viimHavAika = time
   
   viimHav = 1           ; Viiva havaittu oikealla anturilla kun tänne on tultu
   
   high vasenM
   
   pause 20
   
   goto automaatti

   

haeAikaVali:                          ; Tämä aliohjelma laskee aikaVali- muuttujaan sen ajan (sekuntien tarkkuudella)
                                      ; kuinka kauan on kulunut viimeisimmästä viivahavainnosta. Tämän jälkeen palataan
   aikaVali = time - viimHavAika      ; koodissa gosub- käskyn jälkeiselle riville ja jatketaan suoritusta siitä.
						  ; Ei välttämättä kannattaisi tehdä näin lyhyitä aliohjelmia, mutta olkoon.
   return
   
   
viivanEtsinta:

  
   eAAika = time
   
   
   select case viimHav    
   
    
    case 1                ; Viiva havaittu viimeksi oikealla
      
      do until vasenA = 0 ; Pyöritään (hitaasti) myötäpäivään niin kauan että vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         
         gosub kaytaVasenta2
         
         
         irin [5], infVastOt, viesti
   
         if viesti = 7 then
      
            viesti = 0
      
            infAikaVali = time - infAika
       
            if infAikaVali >=2 then      
        				           
               infAika = time 
          
               goto manuaalinen
         
            endif   
   
         endif
   
         
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then manuaalinen   ; Ei jäädä pyörimään kuitenkaan ikuisesti vaan vaihdetaan manuaaliseen.
            
      
      loop 
       
    
    case 3                   ; Viiva havaittu viimeksi vasemmalla
   
      
      do until oikeaA = 0 ; Pyöritään (hitaasti) vastapäivään niin kauan että vasen anturi osuu viivaan.
   				  ; tai sallittu aikaraja ylittyy!
         
         gosub kaytaOikeaa2
         
         irin [5], infVastOt, viesti
   
         if viesti = 7 then
      
             viesti = 0
      
             infAikaVali = time - infAika
       
             if infAikaVali >=2 then      
        				     
                 infAika = time 
          
                 goto manuaalinen
         
             endif   
   
         endif
         
   
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then manuaalinen   ; Ei jäädä pyörimään kuitenkaan ikuisesti vaan vaihdetaan manuaaliseen.
      
         
      loop 
       
    case 0                                 ; Viivasta ei havaintoa, ts. havainto nollattu.
   
      do until vasenA = 0 or oikeaA = 0    ; Ajetaan (hitaasti) suoraan niin kauan että viiva löytyy 
   				                   ; tai sallittu aikaraja ylittyy!
         
         gosub kaytaMolempia2
         
         irin [5], infVastOt, viesti
   
         if viesti = 7 then
      
            viesti = 0
      
            infAikaVali = time - infAika
       
            if infAikaVali >=2 then      
        				           
               infAika = time 
          
               goto manuaalinen
         
            endif   
   
         endif
   
         
         eKAika = time - eAAika
   
         if eKAika >= eMaxAika then manuaalinen   ; Ei jäädä pyörimään kuitenkaan ikuisesti vaan vaihdetaan manuaaliseen.
           
            
      loop
  
  
   endselect
  
  
  
   goto automaatti                             ; Aloitetaan koko systeemi alusta.
   


kaytaVasenta2:

   high vasenM
         
   pause 10
   
   low vasenM
         
   return
   
   
   
kaytaOikeaa2:

   high oikeaM
         
   pause 10
   
   low oikeaM
         
   return
   
   
   
kaytaMolempia2:
   
   high vasenM, oikeaM
         
   pause 10
   
   low vasenM, oikeaM 
   
   return
   
   
   
   
manuaalinen:          ; Tässä on manuaalisen infrapunaohjauksen koodi. Manuaaliohjauksella päästään hieman
                      ; kovempaa, koska low + pause komentoja ei (turhaan) ole välissä.
   
   irin [100, pysaytys], infVastOt, viesti   ; 100:n tilalle voi laittaa jotain pienempääkin tarvittaessa, jolloin
                                             ; liike loppuu vielä nopeammin kun painonapit päästetään ylös
                                             ; ohjaimesta(Ainakin tähän ohjelmaan tehdyn lähettimen tapauksessa)
   select case viesti
   
     case 1
      
       high vasenM, oikeaM
   
   
     case 3
   
       low vasenM
      
       high oikeaM
      
   
     case 5
   
       low oikeaM
      
       high vasenM
   
     case 7
      
       low vasenM, oikeaM
      
       viesti = 0
      
       infAikaVali = time - infAika
       
       if infAikaVali >=2 then  
        
          infAika = time 
          
          viimHav = 0       ; Nollataan viimHav, jotta jatketaan suoraan automaattiohjauksen alkaessa uudelleen,
                            ; jos ollaan vaalealla.
          goto automaatti
         
       endif   
   
   
     ;else                   Tätä ei varmaan tarvita!
   
       ;low vasenM, oikeaM
      
                                                            
   endselect                   
    	                               
   
   goto manuaalinen
                        		  

pysaytys:

   low vasenM, oikeaM

   goto manuaalinen
  
  
 